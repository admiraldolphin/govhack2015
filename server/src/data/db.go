package data

import (
	"fmt"
	"math/rand"
)

type Database struct {
	Heroes     map[int]Hero      // Includes answers.
	Portfolios map[int]Portfolio // Includes policy IDs.
}

func (db *Database) PickQuestions(pf1, pf2, numQuestions int) []int {
	qSet := make(map[int]bool)
	for _, qid := range db.Portfolios[pf1].Questions {
		qSet[qid] = true
	}
	for _, qid := range db.Portfolios[pf2].Questions {
		qSet[qid] = true
	}
	qids := make([]int, 0, len(qSet))
	for qid := range qSet {
		qids = append(qids, qid)
	}
	qs := rand.Perm(len(qids))
	fqs := make([]int, 0, numQuestions)
	for _, i := range qs[:numQuestions] {
		fqs = append(fqs, qids[i])
	}
	return fqs
}

func newDatabase() *Database {
	return &Database{
		Heroes:     make(map[int]Hero),
		Portfolios: make(map[int]Portfolio),
	}
}

// Fake returns a fake database.
func Fake() *Database {
	db := newDatabase()

	// Mock up some data.
	qids := make([]int, 300)
	for i := 0; i < 300; i++ {
		qids[i] = i
	}

	for i := 0; i < 10; i++ {
		db.Portfolios[i] = Portfolio{
			ID:        i,
			Name:      fmt.Sprintf("portfolio%d", i),
			Questions: qids[30*i : 30*(i+1)],
		}
	}

	for i := 0; i < 150; i++ {
		db.Heroes[i] = Hero{
			ID:         i,
			Name:       fmt.Sprintf("hero%d_name", i),
			Electorate: fmt.Sprintf("hero%d_electorate", i),
			Answers: func() map[int]Answer {
				m := make(map[int]Answer)
				for _, qid := range qids {
					m[qid] = Answer(rand.Intn(6))
				}
				return m
			}(),
		}
	}
	return db
}
