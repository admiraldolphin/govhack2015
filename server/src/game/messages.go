package game

import (
	"data"
)

// Message encapsulates all the messages.
// Messages of Type "KeepAlive" are expected to have nil (empty) Data.
// Otherwise, Type is the type of the message (one of the structs below).
type Message struct {
	Type string
	Data interface{} `json:",omitempty"`
}

// Messages from client.

type ClientHello struct {
	Nickname     string
	HeroPick     data.Hero      // For self.
	PorfolioPick data.Portfolio // For opponent.
}

type ClientAnswer struct {
	Question data.ID
	Answer   data.Answer
}

// Messages from server.

type ServerHello struct {
	Opponent  ClientHello // Stuff the other guy picked.
	Questions []data.Question
}

type ServerAnswerMarking struct {
	Question        data.ID
	Correct         bool
	OpponentCorrect bool
}

type ServerGameOver struct {
	YourScore, OpponentScore int
	// TODO(josh): The correct answers for each question.
}
