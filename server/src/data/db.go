package data

import (
	"fmt"
	"math/rand"
)

type Database struct {
	Heroes     map[ID]Hero      // Includes answers.
	Portfolios map[ID]Portfolio // Includes question IDs.
	Questions  map[ID]Question
}

func Load() (*Database, error) {
	db := &Database{
		Heroes: make(map[ID]Hero),
		Portfolios: make(map[ID]Portfolio),
		Questions: make(map[ID]Question),
	}
	
	// TODO(josh): Load data from file
	
	// Mock up some data.
	qids := make([]ID, 0, 300)
	for i:=0; i<300; i++ {
		db.Questions[ID(i)] = Question{
			ID: ID(i),
			Text: fmt.Sprintf("question%d", i),
		}
		qids = append(qids, ID(i))
	}
	
	for i:=0; i<10; i++ {
		db.Portfolios[ID(i)] = Portfolio{
			ID: ID(i),
			Name: fmt.Sprintf("portfolio%d", i),
			Questions: qids[30*i:30*(i+1)],
		}
	}
	
	for i:=0; i<150; i++ {
		db.Heroes[ID(i)] = Hero{
			ID: ID(i),
			Name: fmt.Sprintf("hero%d_name", i),
			Electorate: fmt.Sprintf("hero%d_electorate", i),
			Answers: func() map[ID]Answer {
				m := make(map[ID]Answer)
				for _, qid := range qids {
					m[qid] = Answer(rand.Intn(7))
				}
				return m
			}(),
		}
	}
	return db, nil
}

func (db *Database) PickQuestions(portfolio ID, numQuestions int) []Question {
	pf, ok := db.Portfolios[portfolio]
	if !ok {
		return nil
	}
	qs := rand.Perm(len(pf.Questions))
	fqs := make([]Question, 0, numQuestions)
	for i := 0; i < numQuestions; i++ {
		fqs = append(fqs, db.Questions[pf.Questions[qs[i]]])
	}
	return fqs
}
