package data

import (
	"fmt"
	"math/rand"
)

type Database struct {
	Heroes     map[int]Hero      // Includes answers.
	Portfolios map[int]Portfolio // Includes question IDs.
	Questions  map[int]Question
}

func (db *Database) PickQuestions(portfolio, numQuestions int) []int {
	pf, ok := db.Portfolios[portfolio]
	if !ok {
		return nil
	}
	qs := rand.Perm(len(pf.Questions))
	fqs := make([]int, 0, numQuestions)
	for i := 0; i < numQuestions; i++ {
		fqs = append(fqs, pf.Questions[qs[i]])
	}
	return fqs
}

func newDatabase() *Database {
	return &Database{
		Heroes:     make(map[int]Hero),
		Portfolios: make(map[int]Portfolio),
		Questions:  make(map[int]Question),
	}
}

func Fake() *Database {
	db := newDatabase()

	// Mock up some data.
	qids := make([]int, 0, 300)
	for i := 0; i < 300; i++ {
		db.Questions[i] = Question{
			ID:   i,
			Text: fmt.Sprintf("question%d", i),
		}
		qids = append(qids, i)
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
