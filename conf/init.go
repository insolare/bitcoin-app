package conf

import (
	"github.com/eliona-smart-building-assistant/go-utils/db"
)

func SetDefaultConfig(conn db.Connection) error {
	var err error

	err = UpsertConfig("endpoint", "https://api.coindesk.com/v1/bpi/currentprice.json")
	if err != nil {
		return err
	}

	err = UpsertConfig("polling_rate", "10")
	if err != nil {
		return err
	}

	err = UpsertConfig("response_timeout", "5")
	if err != nil {
		return err
	}
	return nil
}

func SetDefaultCurrencies(conn db.Connection) error {
	return db.Exec(conn, "INSERT INTO bitcoin.currencies VALUES ('USD', array[]::text[]), ('EUR', array[]::text[]), ('GBP', array[]::text[])")
}
