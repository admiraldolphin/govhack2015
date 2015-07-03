package data

type ID int

type Answer int

const (
	DisagreeStrong Answer = iota
	Disagree
	DisagreeWeak
	Neutral
	AgreeWeak
	Agree
	AgreeStrong
)

type Hero struct {
	ID
	Name, Electorate string
	Answers          map[ID]Answer
}

type Portfolio struct {
	ID
	Name      string
	Questions []ID
}

type Question struct {
	ID
	Text string
}

type Database struct {
	Heroes     []Hero
	Portfolios []Porfolio
	Questions  []Question
}

