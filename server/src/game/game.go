package game

import (
	"errors"
	"sync"

	"data"
)

type Game struct {
	player1, player2 *Player
	p1Mu, p2Mu       sync.Mutex
	p2Cond           *sync.Cond

	db *data.Database
}

func newGame(db *data.Database) *Game {
	g := &Game{
		db: db,
	}
	g.p2Cond = sync.NewCond(&g.p2Mu)
	return g
}

// match adds the player to the lobby and promises to provide the other
// player on the channel.
func (g *Game) match(p Player) (<-chan Player, error) {
	g.p1Mu.Lock()
	defer g.p1Mu.Unlock()
	if g.player1 != nil {
		g.p2Mu.Lock()
		defer g.p2Mu.Unlock()
		if g.player2 != nil {
			return nil, errors.New("both players already set")
		}
		g.player2 = &p
		g.p2Cond.Broadcast()
		ch := make(chan Player, 1)
		ch <- *g.player1
		return ch, nil
	}
	g.player1 = &p
	ch := make(chan Player)
	go func() {
		// Wait until player 2 exists
		g.p2Mu.Lock()
		for g.player2 == nil {
			g.p2Cond.Wait()
		}
		ch <- *g.player2
		g.p2Mu.Unlock()
	}()
	return ch, nil
}
