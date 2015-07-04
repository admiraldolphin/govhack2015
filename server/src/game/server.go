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

func (g *Game) handleMessage(conn net.Conn, m *Message) error {
	d := m.Data.(map[string]interface{})

	switch m.Type {
	case "Player":
		// Game has a Player from someone else?
		// Yes: Decide questions to send.
		// No: Send KeepAlive once per keepAliveInterval up to gameTimeout until we have another ClientHello.
		// Then decide questions to send.
		ticker := time.NewTicker(keepAliveInterval)
		defer ticker.Stop()
		p := Player{
			HeroPick:      data.ID(d["HeroPick"].(float64)),
			PortfolioPick: data.ID(d["PortfolioPick"].(float64)),
		}
		match, err := g.match(p)
		if err != nil {
			return err
		}
		for {
			select {
			case opponent := <-match:
				// Proceed!
				s := Message{
					Type: "ServerHello",
					Data: ServerHello{
						Opponent:  opponent,
						Questions: g.db.PickQuestions(opponent.PortfolioPick, numQuestions),
					},
				}
				if err := writeMessage(conn, &s); err != nil {
					return err
				}

			case <-ticker.C:
				// Send keepalives.
				if err := writeMessage(conn, &KeepAlive); err != nil {
					return err
				}
			case <-time.After(gameTimeout):
				return errors.New("game not matched within timeout")
			}
		}

	case "Answer":
		// TODO(josh): Handle ClientAnswer.
	}
	return nil
}

// handle handles incoming connections.
func (g *Game) handle(conn net.Conn) {
	defer conn.Close()
	for {
		m, err := readMessage(conn)
		if err != nil {
			log.Println(err)
			return
		}
		log.Printf("%v: %v\n", conn.RemoteAddr(), m)

		if err := g.handleMessage(conn, m); err != nil {
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

	// TODO(josh): Someday, handle more than one game.
	g := newGame(db)
	for {
		conn, err := ln.Accept()
		if err != nil {
			log.Println(err)
		}
		log.Printf("Accepted connection from %v\n", conn.RemoteAddr())

		go g.handle(conn)
	}
	return nil
}
