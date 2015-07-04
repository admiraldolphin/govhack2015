package game

import (
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"log"
	"net"
	"time"

	"data"
)

const (
	keepAliveInterval = 5 * time.Second
	gameTimeout       = 1 * time.Minute
	idleReadTimeout   = 20 * time.Second
	idleWriteTimeout  = 5 * time.Second
)

func readMessage(conn net.Conn) (*Message, error) {
	conn.SetReadDeadline(time.Now().Add(idleReadTimeout))
	dec := json.NewDecoder(conn)
	var m Message
	err := dec.Decode(&m)
	if err == io.EOF {
		return nil, errors.New("unexpected EOF")
	}
	if err != nil {
		return nil, err
	}
	return &m, nil
}

func writeMessage(conn net.Conn, m *Message) error {
	conn.SetWriteDeadline(time.Now().Add(idleWriteTimeout))
	if err := json.NewEncoder(conn).Encode(m); err != nil {
		return err
	}
	// Jon wants double newline after each message.
	_, err := conn.Write([]byte("\n\n"))
	return err
}

type client struct {
	playerNum int
	conn      net.Conn
	game      *Game
}

func (c *client) handleCommand(m *Message) error {
	d, ok := m.Data.(map[string]interface{})
	if !ok {
		return nil
	}
	ps := &c.game.player[c.playerNum]

	switch m.Type {
	case "Nickname":
		ps.mu.Lock()
		ps.nick = d["Name"].(string)
		ps.mu.Unlock()
		return writeMessage(c.conn, &Hello)

	case "Player":
		// Game has a Player from someone else?
		// Yes: Decide questions to send.
		// No: Send KeepAlive once per keepAliveInterval up to gameTimeout until we have another Player pick.
		// Then decide questions to send.
		pick := Player{
			HeroPick:      int(d["HeroPick"].(float64)),
			PortfolioPick: int(d["PortfolioPick"].(float64)),
		}
		opick, err := c.game.opponentPicks(c.playerNum, pick)
		if err != nil {
			return err
		}
		for {
			select {
			case opp := <-opick:
				// Proceed!
				s := Message{
					Type: "GameStart",
					Data: GameStart{
						OpponentHero:  opp.HeroPick,
						PortfolioName: c.game.db.Portfolios[opp.PortfolioPick].Name,
						Questions:     c.game.db.PickQuestions(opp.PortfolioPick, NumQuestions),
					},
				}
				return writeMessage(c.conn, &s)
			case <-time.After(gameTimeout):
				return errors.New("game not matched within timeout")
			}
		}

	case "Answer":
		// Look up the answer my hero gave to the question.
		qid := int(d["Question"].(float64))
		got := data.Answer(d["Answer"].(float64))
		want := c.game.db.Heroes[ps.picks.HeroPick].Answers[qid]

		ps.mu.Lock()
		ps.clock++
		if got == want {
			// Correct!
			ps.score++
		}
		ps.mu.Unlock()
		return c.game.updateProgress()
	}
	return nil
}

// handleConn handles incoming connections.
func (g *Game) handleConn(conn net.Conn, playerNum int) {
	cl := &client{
		conn:      conn,
		game:      g,
		playerNum: playerNum,
	}
	g.player[playerNum].client = cl
	defer conn.Close()
	defer func() {
		// Close the companion connection - game over.
		if oc := g.player[1-playerNum].client; oc != nil {
			oc.conn.Close()
		}
	}()
	go func() {
		for range time.Tick(keepAliveInterval) {	
			if err := g.writeAllMessage(&KeepAlive); err != nil {
				log.Println(err)
				return
			}
		}
	}()
	for {
		m, err := readMessage(conn)
		if err != nil {
			log.Println(err)
			return
		}
		log.Printf("%v (player %d): %v\n", conn.RemoteAddr(), playerNum, m)

		if err := cl.handleCommand(m); err != nil {
			log.Println(err)
			return
		}
	}

	if err := conn.Close(); err != nil {
		log.Println(err)
	}
}

func RunServer(db *data.Database, port int) error {
	ln, err := net.Listen("tcp", fmt.Sprintf(":%d", port))
	if err != nil {
		return err
	}
	defer ln.Close()

	n, g := 0, newGame(db)
	for {
		conn, err := ln.Accept()
		if err != nil {
			log.Println(err)
		}
		log.Printf("Accepted connection from %v\n", conn.RemoteAddr())

		go g.handleConn(conn, n)
		n++
		if n >= 2 {
			n, g = 0, newGame(db)
		}
	}
	return nil
}
