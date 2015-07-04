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

var KeepAlive = Message{Type: "KeepAlive"}

// Messages from client.

type Player struct {
	HeroPick      data.ID // For self.
	PortfolioPick data.ID // For opponent.
}

type Answer struct {
	Question data.ID
	Answer   data.Answer
}

// Messages from server.

type ServerHello struct {
	Opponent  Player // Stuff the other guy picked.
	Questions []data.Question
}

type ServerAnswerMarking struct {
	Question        data.ID
	Correct         bool
	OpponentCorrect bool
	GameOver        bool
	YourScore       int
	OpponentScore   int
}

type ServerGameOver struct {
	// TODO(josh): The correct answers for each question.
}
