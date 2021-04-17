package env

import (
	"github.com/jmoiron/sqlx"
	"github.com/labstack/echo"
	"github.com/labstack/echo/middleware"
	"github.com/xajik/pngf/golang/db"
	"github.com/xajik/pngf/golang/model/note"
)

type env struct {
	db       *sqlx.DB
	noteRepo note.Repo
	echo     *echo.Echo
}

type Env interface {
	NoteRepo() note.Repo
	HttpServer() echo.Echo
}

func New() (Env, error) {
	db, err := db.New()
	if err != nil {
		return nil, err
	}

	e := echo.New()
	e.Use(middleware.LoggerWithConfig(middleware.LoggerConfig{
		Format: "method=${method}, uri=${uri}, status=${status}, error=${error}\n",
	  }))

	return &env{
		db: db,
		noteRepo: note.NewRepo(db),
		echo: e,
	}, nil
}

func (e *env) NoteRepo() note.Repo {
	return e.noteRepo
}

func (e *env) HttpServer() echo.Echo {
	return *e.echo
}