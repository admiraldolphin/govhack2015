package data

import (
	"math/rand"
)

type Database struct {
	Heroes     map[ID]Hero      // Includes answers.
	Portfolios map[ID]Portfolio // Includes question IDs.
	Questions  map[ID]Question
}

func Load() (*Database, error) {
	// TODO(josh): Load data from file
	return nil, nil
}

func (db *Database) PickQuestions(portfolio ID, numQuestions int) []Question {
	pf, ok := db.Portfolios[portfolio]
	if !ok {
		return nil
	}
	qs := append([]ID(nil), pf.Questions...)
	fqs := make([]Question, 0, numQuestions)
	for i := 0; i < numQuestions; i++ {
		j := rand.Intn(len(qs)-i) + i
		qs[i], qs[j] = qs[j], qs[i]
		fqs = append(fqs, db.Questions[qs[i]])
	}
	return fqs
}
