package game

import (
	"errors"
	"sync"

	"data"
)

var (
	NumQuestions = 5
)

type Game struct {
	player [2]struct {
		mu     sync.RWMutex
		score  int
		nick   string
		picks  *Player
		clock  int
		client *client
	}
	gameStart *sync.Cond
	gameClock int
	mu        sync.Mutex

	db *data.Database
}

func newGame(db *data.Database) *Game {
	g := &Game{db: db}
	g.gameStart = sync.NewCond(&g.mu)
	return g
}

// opponentPicks registers a player's picks, and then waits for the
// opponent to pick, promising to provide it on the returned channel.
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

// writeAllMessage broadcasts a message to all (two) clients in a game.
func (g *Game) writeAllMessage(m *Message) error {
	for i := range g.player {
		if g.player[i].client != nil {
			if err := writeMessage(g.player[i].client.conn, m); err != nil {
				return err
			}
		}
	}
	return nil
}

// updateProgress updates the progress to all (two) clients in a game.
func (g *Game) updateProgress() error {
	g.player[0].mu.RLock()
	g.player[1].mu.RLock()
	prog0 := Progress{
		YourScore:     g.player[0].score,
		OpponentScore: g.player[1].score,
	}
	prog1 := Progress{
		YourScore:     g.player[1].score,
		OpponentScore: g.player[0].score,
	}
	g.player[0].mu.RUnlock()
	g.player[1].mu.RUnlock()
	if err := writeMessage(g.player[0].client.conn, &Message{
		Type: "Progress",
		Data: prog0,
	}); err != nil {
		return err
	}
	return writeMessage(g.player[1].client.conn, &Message{
		Type: "Progress",
		Data: prog1,
	})
}
