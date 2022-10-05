package eliona

import (
	"time"

	api "github.com/eliona-smart-building-assistant/go-eliona-api-client/v2"
	"github.com/eliona-smart-building-assistant/go-eliona/asset"
	"github.com/eliona-smart-building-assistant/go-utils/common"
)

type BtcRate struct {
	Currency string
	Rate     float64
}

func UpsertBtcData(target *api.Data, name string, rate float64, ts time.Time) error {
	target.SetTimestamp(ts)
	target.SetData(common.StructToMap(BtcRate{Currency: name, Rate: rate}))
	return asset.UpsertData(*target)
}

func CreateAsset(proj_id string, guid string) (int32, error) {
	newAsset := api.NewAsset(proj_id, guid, "btc_exchange_rate")

	newAssetId, err := asset.UpsertAsset(*newAsset)
	if err != nil {
		return 0, err
	}

	return *newAssetId, nil
}
