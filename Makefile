.PHONY: default build image run

default: build

build:
	go build -o bitcoin-app

image:
	docker build -t bitcoin-app:latest .

run:
	go run main.go