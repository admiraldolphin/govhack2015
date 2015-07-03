package game

type Message struct {
	Type string
	Data interface{}
}

// Messages from client
type ClientHello struct {
	Nickname     string
	HeroPick     data.ID
	OpponentPorfolioPick data.ID
}

// Messages form server
type ServerHello struct{
	Opponent ClientHello
	Questions []data.Question
}

type KeepAlive struct{}


