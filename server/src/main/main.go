package main

import (
	"log"

	"data"
	"game"
)

func main() {
	log.Println("Starting QuestionTime server...")
	db, err := data.Load()
	if err != nil {
		log.Fatal(err)
	}

	log.Fatal(game.RunServer(db))

	log.Println("QuestionTime server stopped")
}
