package game

import (
	"data"
)

// Message encapsulates all the messages.
// Messages of Type "KeepAlive" are expected to have nil (empty) Data.
// Otherwise, Type is the type of the message (one of the structs below).
// Note that when encoding/json unmarshals Message, Data will have the
// generic type map[string]interface{}.
type Message struct {
	Type string
	Data interface{} `json:",omitempty"`
}

// Commands from client.

type Nickname struct {
	Name string
}

type Player struct {
	HeroPick      int // For self.
	PortfolioPick int // For opponent.
}

type Answer struct {
	Question int
	Answer   data.Answer
}

// Messages from server.

var KeepAlive = Message{Type: "KeepAlive"}

var Hello = Message{Type: "Hello"}

type GameStart struct {
	OpponentHero  int
	PortfolioName string
	Questions     []int
}

type Progress struct {
	YourScore     int
	OpponentScore int
}

type GameOver struct {
	YouWon     bool
	Portfolios []int
}
