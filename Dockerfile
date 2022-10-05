FROM golang:1.18-alpine3.15 AS build

WORKDIR /
COPY . ./

RUN go mod download
RUN go build -o ../app

FROM alpine:3.15 AS target

COPY --from=build /app ./
COPY conf/*.sql ./conf/
COPY eliona/*.json ./eliona/

ENV APPNAME=example CONNECTION_STRING="postgres://postgres:secret@database-mock:5432" API_TOKEN=secret API_ENDPOINT=http://api-v2:3000/v2 API_SERVER_PORT=3001

ENV TZ=Europe/Zurich
CMD [ "/app" ]