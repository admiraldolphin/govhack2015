package main

import (
	"flag"
	"log"

	"data"
	"game"
)

var (
	dataPath     = flag.String("data", "../data", "Path to the data directory.")
	port         = flag.Int("port", 8888, "TCP port for serving.")
	numQuestions = flag.Int("questions", 5, "Number of questions in a game.")
)

func main() {
	flag.Parse()
	game.NumQuestions = *numQuestions
	log.Println("Starting QuestionTime server...")
	db, err := data.Load(*dataPath)
	if err != nil {
		log.Println(err)
		log.Println("Using fake data instead...")
		db = data.Fake()
	}
	log.Fatal(game.RunServer(db, *port))

	log.Println("QuestionTime server stopped")
}
