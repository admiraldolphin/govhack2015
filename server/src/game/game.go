package game

import (
	"errors"
	"net"
	"sync"

	"data"
)

type PlayerState struct {
	addr  net.Addr
	mu    sync.RWMutex
	score int
	picks *Player
}

type Game struct {
	player    [2]PlayerState
	gameStart *sync.Cond

	db *data.Database
}

func newGame(db *data.Database) *Game {
	g := &Game{db: db}
	g.gameStart = sync.NewCond(&g.player[1].mu)
	return g
}

// opponentPicks registers a player's picks, and then waits for the
// opponent to pick hero/portfolio, promising to provide it on the
// returned channel.
func (g *Game) opponentPicks(addr net.Addr, p Player) (<-chan Player, error) {
	g.player[0].mu.Lock()
	defer g.player[0].mu.Unlock()
	if g.player[0].picks != nil {
		g.player[1].mu.Lock()
		defer g.player[1].mu.Unlock()
		if g.player[1].picks != nil {
			return nil, errors.New("both players already set")
		}
		g.player[1].picks = &p
		g.player[1].addr = addr
		g.gameStart.Broadcast()
		ch := make(chan Player, 1)
		ch <- *g.player[0].picks
		return ch, nil
	}
	g.player[0].picks = &p
	g.player[0].addr = addr
	ch := make(chan Player)
	go func() {
		// Wait until player 2 exists.
		g.player[1].mu.Lock()
		for g.player[1].picks == nil {
			g.gameStart.Wait()
		}
		ch <- *g.player[1].picks
		g.player[1].mu.Unlock()
	}()
	return ch, nil
}
