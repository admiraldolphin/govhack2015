package main

import (
	"fmt"
	"log"
	"net/http"
)

func main() {
	fmt.Println("This is the server, dawg!")
	
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "Game server! Woot.")
	})
	log.Fatal(http.ListenAndServe(":8080", nil))
}
