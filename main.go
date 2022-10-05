package main

import (
	"bitcoin/conf"
	"context"

	"github.com/eliona-smart-building-assistant/go-eliona/app"
	"github.com/eliona-smart-building-assistant/go-eliona/asset"
	"github.com/eliona-smart-building-assistant/go-utils/common"
	"github.com/eliona-smart-building-assistant/go-utils/db"
	"github.com/eliona-smart-building-assistant/go-utils/log"
)

type ExhangeRate struct {
	Rate float64 `json:"exchange_rate"`
}

func main() {
	log.SetLevel(log.DebugLevel)
	log.Info(app.AppName(), "Application startup")

	defer db.ClosePool()

	app.Init(
		db.Pool(),
		app.AppName(),
		app.ExecSqlFile("conf/init.sql"),
		asset.InitAssetTypeFile("eliona/asset-type-rate.json"),
		conf.SetDefaultConfig,
		conf.SetDefaultCurrencies,
	)

	server := ListenApi()

	common.WaitFor(
		common.Loop(GetData, conf.GetPollingRate()),
		//ListenApi,
	)

	server.Shutdown(context.Background())

	CleanCache()

	log.Info(app.AppName(), "Application shutdown")
}
