package game

import (
	"data"
)

type Message struct {
	Type    string
	Message interface{}
}

type ClientHello struct{}
type KeepAlive struct{}
type ServerHello struct{}

type Player struct {
	Nickname string
	*data.HeroH
	*data.Portfolio
}
