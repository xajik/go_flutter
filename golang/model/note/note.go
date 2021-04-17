package note

import (
	"database/sql"
	"time"

	"github.com/xajik/pngf/golang/errors"

	"github.com/jmoiron/sqlx"
	"github.com/lib/pq"
)

type Note struct {
	ID        int64     `json:"id"`
	Title     string    `json:"title"`
	Body      string    `json:"body"`
	Tags      pq.StringArray  `json:"tags"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

// REPO stuff
// TODO: consider moving repo to separate package
type Repo interface {
	Create(p *Note) (post *Note, err error)
	GetByID(id int64) (post *Note, err error)
	GetByTag(id int64) (post []*Note, err error)
	DeleteByID(id int64) (err error)
	GetAll() (post []*Note, err error)
}

type repo struct {
	create     *sqlx.NamedStmt
	getByID    *sqlx.Stmt
	getByTag    *sqlx.Stmt
	deleteByID *sqlx.Stmt
	getAll *sqlx.Stmt
}

// NewRepo prepares statements, and panics if a statement fails to create
func NewRepo(db *sqlx.DB) Repo {
	create, err := db.PrepareNamed(`INSERT INTO notes (title, body, tags) VALUES (:title, :body, :tags) RETURNING *`)
	if err != nil {
		panic(err)
	}
	getByID, err := db.Preparex(`SELECT * FROM notes WHERE id = $1 LIMIT 1`)
	if err != nil {
		panic(err)
	}
	getByTag, err := db.Preparex(`SELECT * FROM notes WHERE tags = ANY(SELECT tags FROM notes WHERE id = $1) AND id != $1`)
	if err != nil {
		panic(err)
	}
	deleteByID, err := db.Preparex(`DELETE FROM notes WHERE id = $1`)
	if err != nil {
		panic(err)
	}
	getAll, err := db.Preparex(`SELECT * FROM notes`)
	if err != nil {
		panic(err)
	}

	return &repo{
		create,
		getByID,
		getByTag,
		deleteByID,
		getAll,
	}
}

func (r *repo) GetByID(id int64) (post *Note, err error) {
	post = &Note{}
	err = r.getByID.Get(post, id)
	if err == sql.ErrNoRows {
		err = errors.PostNotFound
	}
	return
}

func (r *repo) GetByTag(id int64) (post []*Note, err error) {
	post = []*Note{}
	err = r.getByTag.Select(&post, id)
	if err == sql.ErrNoRows {
		err = errors.PostNotFound
	}
	return
}

func (r *repo) Create(p *Note) (post *Note, err error) {
	post = &Note{}
	err = r.create.Get(post, p)
	return
}

func (r *repo) DeleteByID(id int64) (err error) {
	_, err = r.deleteByID.Exec(id)
	return
}

func (r *repo) GetAll() (post []*Note, err error) {
	post = []*Note{}
	err = r.getAll.Select(&post)
	if err == sql.ErrNoRows {
		err = errors.PostNotFound
	}
	return
}
