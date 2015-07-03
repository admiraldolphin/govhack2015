package data

import (
	"errors"
)

type Database struct {
	Heroes     map[ID]Hero     // Includes answers.
	Portfolios map[ID]Porfolio // Includes questions.
}

func Load() (*Database, error) {
	// TODO(josh): Load data from file
	return nil, errors.New("not yet implemeneted")
}
