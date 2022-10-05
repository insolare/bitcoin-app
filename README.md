# Bitcoin excersise app
## Running

### Compose
Application have docker-compose.yml file which runs all required stuff preconfigured (mock and app).
Easiest way to start the app is `docker compose up`

### Standalone
If running standalone, environment needs to be provided:
`APPNAME=example`
APPNAME should hold name authorized in database (leave it 'example')

`CONNECTION_STRING=postgres://postgres:secret@localhost:5432`
Provide connection string to mock-database here

`API_TOKEN=secret`
Provide existing ElionaAPI tocken here

`API_ENDPOINT=http://localhost:3000/v2`
ElionaAPI endoint

`API_SERVER_PORT=3001`
Bitcoin-app API will listen on this port

## Controlling
App provides API to control it's configuration aspects and Eliona asset instances.
See openapi.yaml for slighly more information.

`/config`, method GET returns actual configuration
`/config/endpoint`, method POST allows to change endpoint (but don't do this :))
`/config/poll_rate`, method POST allows to change Coindesk API polling rate
`/config/timeout`, method POST allows to change timeout for Coindesk API call

## Example
Calling POST method on `/config/poll_rate` with following payload:
`
{
    "newValue" : "5"
}
`

will set polling rate to 5 seconds

## Eliona
API provides endpoint to add assets to eliona projects in basic way

`/addCurrencyToProject`, method POST does the thing.

### Example
Calling POST method on `/config/poll_rate` with following payload:
`
{
  "currency": "USD",
  "project_id": "99"
}
`
will add BTC to USD  exchange rate as asset to project '99'

## Limitations
Only 3 currencies are supported: USD, EUR, GBP as they are the only provided by v1 Coindesk API
