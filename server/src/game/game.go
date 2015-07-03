package game

import (
	"data"
)

type Player struct {
	Nickname string
	*data.Hero
	*data.Portfolio
}
