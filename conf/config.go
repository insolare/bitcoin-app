package conf

import (
	"strconv"
	"time"

	"github.com/eliona-smart-building-assistant/go-utils/db"
)

type ConfiguredCurrencies struct {
	Name    string
	ProjIds []string
}

type AppConfig struct {
	Endpoint string `json:"endpoint"`
	PollRate string `json:"poll_rate"`
	Timeout  string `json:"request_timeout"`
}

func GetAppConfig() AppConfig {
	return AppConfig{
		Endpoint: GetEndpoint(),
		PollRate: strconv.Itoa(int(GetPollingRate()) / int(time.Second)),
		Timeout:  strconv.Itoa(int(GetTimeout()) / int(time.Second)),
	}
}

func GetEndpoint() string {
	return getConfigFromDB("endpoint", "https://api.coindesk.com/v1/bpi/currentprice.json")
}

func GetTimeout() time.Duration {
	value := getConfigFromDB("polling_rate", "10")
	timeout, err := strconv.Atoi(value)
	if err != nil {
		return time.Duration(10) * time.Second
	}

	return time.Duration(timeout) * time.Second
}

func GetPollingRate() time.Duration {
	value := getConfigFromDB("polling_rate", "10")
	poll_rate, err := strconv.Atoi(value)
	if err != nil {
		return time.Duration(10) * time.Second
	}

	return time.Duration(poll_rate) * time.Second
}

func GetConfiguredCurrencies(currency chan ConfiguredCurrencies) error {
	return db.Query(db.Pool(), "SELECT name, proj_id FROM bitcoin.currencies", currency)
}

func getConfigFromDB(name string, fallback string) string {
	valueCh := make(chan string)
	go func() {
		db.Query(db.Pool(), "SELECT value from bitcoin.configuration WHERE name = $1", valueCh, name)
	}()

	value := <-valueCh
	if len(value) == 0 {
		return fallback
	}

	return value
}

func UpsertConfig(name string, value string) error {
	return saveConfigToDB(db.Pool(), name, value)
}

func saveConfigToDB(conn db.Connection, name string, value string) error {
	return db.Exec(conn, "INSERT INTO bitcoin.configuration (name, value) VALUES ($1, $2) ON CONFLICT (name) DO UPDATE SET value = excluded.value",
		name, value,
	)
}

func UpdateCurrencyProjects(name string, proj_id string) error {
	return db.Exec(db.Pool(), "UPDATE bitcoin.currencies SET proj_id = array_append(proj_id, $1) WHERE name = $2", proj_id, name)
}
