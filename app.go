package main

import (
	"fmt"
	"net/http"

	"bitcoin/apiserver"
	"bitcoin/apiservice"
	"bitcoin/bitcoin"
	"bitcoin/conf"
	"bitcoin/eliona"

	api "github.com/eliona-smart-building-assistant/go-eliona-api-client/v2"
	"github.com/eliona-smart-building-assistant/go-eliona/app"
	"github.com/eliona-smart-building-assistant/go-utils/common"
	"github.com/eliona-smart-building-assistant/go-utils/log"
)

type BtcRate struct {
	Currency string
	Rate     float64
}

var cache = make(map[string]*api.Data)

func GetData() {
	conf.GetAppConfig()
	data, err := bitcoin.FetchRates()
	if err != nil {
		log.Error(app.AppName(), "error fetching BTC rates: %v", err)
		return
	}

	curs := make(chan conf.ConfiguredCurrencies)

	go func() {
		conf.GetConfiguredCurrencies(curs)
	}()

	for c := range curs {
		if len(c.ProjIds) == 0 {
			log.Error(app.AppName(), "No project ID's found for currency '%s'. Skipping", c.Name)
			continue
		}

		for i := range c.ProjIds {
			assetGuid := fmt.Sprintf("%s_%s", c.Name, c.ProjIds[i])

			// Some reduction of API calls: storing already created assets in map
			if _, ok := cache[assetGuid]; !ok {
				assetId, err := eliona.CreateAsset(c.ProjIds[i], assetGuid)
				if err != nil {
					log.Error(app.AppName(), "error creating asset for project %s: %v", c.ProjIds, err)
					continue
				}

				newData := api.NewData(assetId, api.SUBTYPE_INPUT, nil)
				cache[assetGuid] = newData
			}

			// Asset is already existing or created at this point, so we can continue with data insertion
			err = eliona.UpsertBtcData(cache[assetGuid], c.Name, data.Rates[c.Name].Rate, data.UpdatedAt.Iso)
			if err != nil {
				log.Error(app.AppName(), "error inserting data for asset %s: %v", assetGuid, err)
			}
		}
	}
}

func ListenApi() *http.Server {
	server := &http.Server{Addr: ":" + common.Getenv("API_SERVER_PORT", "3001"),
		Handler: apiserver.NewRouter(apiserver.NewDefaultApiController(apiservice.NewConfigurationService())),
	}

	go server.ListenAndServe()

	// err := http.ListenAndServe(":"+common.Getenv("API_SERVER_PORT", "3001"),
	// 	apiserver.NewRouter(apiserver.NewDefaultApiController(apiservice.NewConfigurationService())),
	// )
	// log.Fatal(app.AppName(), "Error in API server: %v", err)

	return server
}

func CleanCache() {
	for k := range cache {
		delete(cache, k)
	}
}
