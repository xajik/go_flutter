package handlers

import (
	"fmt"
	"net/http"
	"strconv"

	"github.com/labstack/echo"
	"github.com/xajik/pngf/golang/env"
	"github.com/xajik/pngf/golang/model/note"
)

func Register(e env.Env) {
	registerErrorHandling(e)
	registerPing(e)
	registerNote(e)
}

func registerErrorHandling(e env.Env) {
	srv := e.HttpServer()
	srv.Use(func(next echo.HandlerFunc) echo.HandlerFunc {
		return func(c echo.Context) error {
			return echo.NewHTTPError(http.StatusUnauthorized, "Please kurwa provide valid credentials")
		}
	})
}

func registerPing(e env.Env) {
	srv := e.HttpServer()
	srv.GET("/api/ping", func(c echo.Context) error {
		return c.String(http.StatusOK, "Ping!")
	})
}

func registerNote(e env.Env) {
	srv := e.HttpServer()
	g := srv.Group("/api/note")

	g.GET("/", func(c echo.Context) error {
		res, err := e.NoteRepo().GetAll()
		if err != nil {
			c.String(http.StatusBadRequest, err.Error())
		}
		return c.JSON(http.StatusOK, res)
	})

	g.POST("/", func(c echo.Context) error {

		note := new(note.Note)

		if err := c.Bind(note); err != nil {
			return c.String(http.StatusBadRequest, err.Error())
		}

		res, err := e.NoteRepo().Create(note)

		if err != nil {
			return c.String(http.StatusBadRequest, err.Error())
		}

		return c.JSON(http.StatusOK, res)
	})

	g.GET("/:id/bytag", func(c echo.Context) error {
		s := c.Param("id")
		id, err := strconv.ParseInt(s, 10, 64)
		if err != nil {
			return c.String(http.StatusBadRequest, err.Error())
		}
		res, err := e.NoteRepo().GetByTag(id)
		if err != nil {
			return c.String(http.StatusBadRequest, err.Error())
		}
		return c.JSON(http.StatusOK, res)
	})

	g.GET("/:id", func(c echo.Context) error {
		s := c.Param("id")

		id, err := strconv.ParseInt(s, 10, 64)
		if err != nil {
			return c.String(http.StatusBadRequest, err.Error())
		}
		res, err := e.NoteRepo().GetByID(id)
		if err != nil {
			return c.String(http.StatusBadRequest, err.Error())
		}
		return c.JSON(http.StatusOK, res)
	})

	g.DELETE("/:id", func(c echo.Context) error {
		s := c.Param("id")

		id, err := strconv.ParseInt(s, 10, 64)
		if err != nil {
			return c.String(http.StatusBadRequest, err.Error())
		}
		err = e.NoteRepo().DeleteByID(id)
		if err != nil {
			return c.String(http.StatusBadRequest, err.Error())
		}
		return c.String(http.StatusOK, fmt.Sprintf("Removed: %d", id))
	})
}
