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
	mu        sync.Mutex

	db *data.Database
}

func newGame(db *data.Database) *Game {
	g := &Game{db: db}
	g.gameStart = sync.NewCond(&g.mu)
	return g
}

// opponentPicks registers a player's picks, and then waits for the
// opponent to pick hero/portfolio, promising to provide it on the
// returned channel.
func (g *Game) opponentPicks(playerNum int, p Player) (<-chan Player, error) {
	ps := &g.player[playerNum]
	ps.mu.Lock()
	defer ps.mu.Unlock()
	if ps.picks != nil {
		return nil, errors.New("player already made picks")
	}
	ps.picks = &p
	g.gameStart.Broadcast()
	ch := make(chan Player)
	go func() {
		// Wait until both players have picked.
		g.mu.Lock()
		for g.player[0].picks == nil || g.player[1].picks == nil {
			g.gameStart.Wait()
		}
		ch <- *g.player[1-playerNum].picks
		g.mu.Unlock()
	}()
	return ch, nil
}
