package main

import (
	"flag"
	"log"

	"github.com/troptropcontent/factoche/internal/config"
	"github.com/troptropcontent/factoche/internal/infrastructure/database/postgres"
	"github.com/troptropcontent/factoche/internal/infrastructure/database/postgres/migrator"
)

func main() {
	down := flag.Bool("down", false, "Roll back migrations")
	flag.Parse()

	cfg := config.NewConfig()

	db, err := postgres.NewConnection(cfg.DB())
	if err != nil {
		log.Fatal(err)
	}

	migrator, err := migrator.New(db, cfg.DB())
	if err != nil {
		log.Fatal(err)
	}

	if *down {
		if err := migrator.Down(); err != nil {
			log.Fatal(err)
		}
		log.Println("Successfully rolled back migrations")
	} else {
		if err := migrator.Up(); err != nil {
			log.Fatal(err)
		}
		log.Println("Successfully applied migrations")
	}
}
