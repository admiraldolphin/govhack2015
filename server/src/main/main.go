package main

import (
	"flag"
	"log"

	"data"
	"game"
)

var port = flag.Int("port", 8888, "TCP port for serving.")

func main() {
	flag.Parse()
	log.Println("Starting QuestionTime server...")
	db, err := data.Load()
	if err != nil {
		log.Fatal(err)
	}

	log.Fatal(game.RunServer(db, *port))

	log.Println("QuestionTime server stopped")
}
