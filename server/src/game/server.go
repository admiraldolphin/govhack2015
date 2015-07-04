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
	keepAliveInterval = 1 * time.Second
	gameTimeout       = 1 * time.Minute
	idleReadTimeout   = 20 * time.Second
	idleWriteTimeout  = 5 * time.Second

	numQuestions = 5
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
	d := m.Data.(map[string]interface{})
	ps, ops := &c.game.player[c.playerNum], &c.game.player[1-c.playerNum]

	switch m.Type {
	case "Nickname":
		// TODO(josh): Handle nicname command.

	case "Player":
		// Game has a Player from someone else?
		// Yes: Decide questions to send.
		// No: Send KeepAlive once per keepAliveInterval up to gameTimeout until we have another ClientHello.
		// Then decide questions to send.
		ticker := time.NewTicker(keepAliveInterval)
		defer ticker.Stop()
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
						Questions:     c.game.db.PickQuestions(opp.PortfolioPick, numQuestions),
					},
				}
				return writeMessage(c.conn, &s)
			case <-ticker.C:
				// Send keepalives.
				if err := writeMessage(c.conn, &KeepAlive); err != nil {
					return err
				}
			case <-time.After(gameTimeout):
				return errors.New("game not matched within timeout")
			}
		}

	case "Answer":
		// Look up the answer my hero gave to the question.
		qid := int(d["Question"].(float64))
		got := data.Answer(d["Answer"].(float64))
		want := c.game.db.Heroes[ps.picks.HeroPick].Answers[qid]
		if got == want {
			// Correct!
			ps.mu.Lock()
			ps.score++
			ps.mu.Unlock()
		}

		// Send an updated progress message.
		ps.mu.RLock()
		ops.mu.RLock()
		prog := Message{
			Type: "Progress",
			Data: Progress{
				YourScore:     ps.score,
				OpponentScore: ops.score,
			},
		}
		ps.mu.RUnlock()
		ops.mu.RUnlock()
		if err := writeMessage(c.conn, &prog); err != nil {
			return err
		}
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

	defer conn.Close()
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

	nextPlayerNum := 0
	g := newGame(db)
	for {
		conn, err := ln.Accept()
		if err != nil {
			log.Println(err)
		}
		log.Printf("Accepted connection from %v\n", conn.RemoteAddr())

		go g.handleConn(conn, nextPlayerNum)
		nextPlayerNum++
		if nextPlayerNum >= 2 {
			g = newGame(db)
			nextPlayerNum = 0
		}
	}
	return nil
}
