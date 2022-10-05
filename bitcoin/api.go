package bitcoin

import (
	"bitcoin/conf"
	"encoding/json"
	"time"

	"github.com/eliona-smart-building-assistant/go-utils/http"
)

type exhangeRate struct {
	Rate float64 `json:"rate_float"`
}

type BtcData struct {
	UpdatedAt struct {
		Iso time.Time `json:"updatedISO"`
	} `json:"time"`

	Rates map[string]exhangeRate `json:"bpi"`
}

func FetchRates() (BtcData, error) {
	rates := BtcData{}

	payload, err := fetchUrl(conf.GetEndpoint())
	if err != nil {
		return rates, err
	}

	err = json.Unmarshal(payload, &rates)
	if err != nil {
		return rates, err
	}

	return rates, nil
}

func fetchUrl(url string) ([]byte, error) {
	request, err := http.NewRequest(url)
	if err != nil {
		return nil, err
	}

	payload, err := http.Do(request, conf.GetTimeout(), true)
	if err != nil {
		return nil, err
	}

	return payload, nil
}
