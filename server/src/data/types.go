package data

// type ID int

type Answer int

const (
	Abstain        = Answer(-1)
	DisagreeStrong = Answer(1)
	Disagree       = Answer(2)
	Neutral        = Answer(3)
	Agree          = Answer(4)
	AgreeStrong    = Answer(5)
)

type Hero struct {
	ID               int
	Name, Electorate string
	Answers          map[int]Answer // Question ID -> Answer for question.
}

type Portfolio struct {
	ID        int
	Name      string
	Questions []int
}

type Question struct {
	ID   int
	Text string
}
