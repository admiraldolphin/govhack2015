package game

import (
	"data"
)

type Player struct {
	Nickname string
	*data.Hero
	*data.Portfolio
}

func RunServer(*data.Database) error {
	// TODO(josh): net.Conn, bind, serve ...
	return nil
}
