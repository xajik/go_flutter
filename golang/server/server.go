package server

import (
	"github.com/xajik/pngf/golang/env"
	"github.com/xajik/pngf/golang/server/handlers"
)


type server struct {
	env env.Env
}

type Server interface {
	Start()
}

func New() (*server, error) {
	env, err := env.New() 
	if err != nil {
		return nil, err
	}
	
	return &server{
		env: env,
	}, nil
}

func (srv *server) Start() {
	handler := srv.env.HttpServer()
	handlers.Register(srv.env)
	handler.Logger.Fatal(handler.Start(":5000"))
}