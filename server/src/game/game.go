package game

import (
	"log"
	"net"
	"time"

	"data"
)

const (
	keepAliveInterval = 1 * time.Second
	idleTimeout       = 5 * time.Second
)

type Player struct {
	Nickname string
	*data.Hero
	*data.Portfolio
}

func RunServer(*data.Database) error {
	tick := time.Ticker()

	ln, err := net.Listen("tcp", ":8888")
	if err != nil {
		return err
	}
	defer ln.Close()

	for {
		conn, err := ln.Accept()
		if err != nil {
			log.Println(err)
		}
		log.Printf("Accepted connection from %v\n", conn.RemoateAddr())
		conn.SetDeadline(time.Now().Add(idleTimeout))
		

		// TODO(josh): Implement protocol.
		if err := conn.Close(); err != nil {
			return err
		}
	}
	return nil
}
