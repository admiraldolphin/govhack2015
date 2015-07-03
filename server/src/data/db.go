package data

type Database struct {
	Heroes     map[ID]Hero      // Includes answers.
	Portfolios map[ID]Portfolio // Includes questions.
}

func Load() (*Database, error) {
	// TODO(josh): Load data from file
	return nil, nil
}
