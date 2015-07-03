package game

import (
	"encoding/json"
	"errors"
	"io"
	"log"
	"net"
	"time"

	"data"
)


const (
	keepAliveInterval = 1 * time.Second
	idleTimeout       = 5 * time.Second
)

func readMessage(conn net.Conn) (*Message, error) {
	conn.SetDeadline(time.Now().Add(idleTimeout))
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
	conn.SetDeadline(time.Now().Add(idleTimeout))
	return json.NewEncoder(conn).Encode(m)
}

// handle handles incoming connections.
func handle(conn net.Conn) {
	defer conn.Close()
	for {
		m, err := readMessage(conn)
		if err != nil {
			log.Println(err)
			return
		}
		log.Printf("%v: %v\n", conn.RemoteAddr(), m)
		
		switch m.Type {
		case "ClientHello":
			// TODO(josh): Handle ClientHello.
			
		case "ClientAnswer":
			// TODO(josh): Handle ClientAnswer.
		}
	}

	if err := conn.Close(); err != nil {
		log.Println(err)
	}
}

func RunServer(*data.Database) error {
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
		log.Printf("Accepted connection from %v\n", conn.RemoteAddr())

		go handle(conn)
	}
	return nil
}
