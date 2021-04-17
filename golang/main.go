package main

import (
	"log"
	"github.com/xajik/pngf/golang/server"
)

func main() {
	server, err := server.New()
	if err != nil {
		log.Fatalln("Unable to initialize server", err)
	}
	server.Start()
}
