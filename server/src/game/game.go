package game

import (
	"crypto/rand"
)

type ID [16]byte

func NewID() (id ID) {
	rand.Read(id[:])
	return
}

var Games map[ID]*Game

type State int
const (
	StateStart State = iota
	StateEnd
)

type Game struct {
	ID
	State
	Players [2]*Player
}

func NewGame(player1, player2 *Player) *Game {
	return &Game{
		ID: NewID(),
		Players: [2]*Player{player1, player2},
	}
}

type Player struct {
	ID
	Nickname string
}


