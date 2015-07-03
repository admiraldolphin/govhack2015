package game

import (
	"sync"

	"data"
)

type Game struct {
	player1, player2 *Player
}

type (g *Game) match(p *Player) <-chan *Player {
	// TODO(josh): Finish the lobby matching routine.
	ch := make(chan *Player)
	if g.player1 != nil {
		g.player2 = p
		go func() {
			ch <- g.player1
		}
		return ch
	}
	
}