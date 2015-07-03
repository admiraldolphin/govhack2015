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
	return json.NewEncoder(conn).Encode(m)
}

// handle handles incoming connections.
func (g *Game) handle(conn net.Conn, db *data.Database) {
	defer conn.Close()
outerHandleLoop:
	for {
		m, err := readMessage(conn)
		if err != nil {
			log.Println(err)
			return
		}
		log.Printf("%v: %v\n", conn.RemoteAddr(), m)
		
		d := m.Data.(map[string]interface{})
		
		switch m.Type {
		case "Player":
			// Game has a ClientHello from someone else?
			// Yes: Decide questions to send.
			// No: Send KeepAlive once per keepAliveInterval up to gameTimeout until we have another ClientHello.
			// Then decide questions to send.
			ticker := time.NewTicker(keepAliveInterval)
			gto := time.Now().Add(gameTimeout)
			p := &Player{
				HeroPick: data.ID(d["HeroPick"].(int)),
				PortfolioPick: data.ID(d["PortfolioPick"].(int)),
			}
			match := g.match(p)
			for {
				select {
				case op := <-match:
					// Proceed!
				case <-ticker:
					// Send keepalive
					if time.Now().After(gto) {
						break outerHandleLoop
					}
				}
			}
			
		case "Answer":
			// TODO(josh): Handle ClientAnswer.
			// 
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
	g := &Game{}
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
