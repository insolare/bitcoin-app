package apiservice

import (
	"context"
	"net/http"

	"bitcoin/apiserver"
	"bitcoin/conf"
)

type ConfigurationService struct{}

func NewConfigurationService() apiserver.DefaultApiServicer {
	return &ConfigurationService{}
}

func (s *ConfigurationService) ConfigGet(ctx context.Context) (apiserver.ImplResponse, error) {
	cfg := conf.GetAppConfig()

	return apiserver.ImplResponse{Code: http.StatusOK, Body: cfg}, nil
}

func (s *ConfigurationService) ConfigEndpointPost(ctx context.Context, update apiserver.ConfigurationFieldUpdate) (apiserver.ImplResponse, error) {
	err := conf.UpsertConfig("endpoint", update.NewValue)

	if err != nil {
		return apiserver.ImplResponse{Code: http.StatusBadRequest}, err
	}

	return apiserver.ImplResponse{Code: http.StatusOK}, nil
}

func (s *ConfigurationService) ConfigPollRatePost(ctx context.Context, update apiserver.ConfigurationFieldUpdate) (apiserver.ImplResponse, error) {
	err := conf.UpsertConfig("polling_rate", update.NewValue)

	if err != nil {
		return apiserver.ImplResponse{Code: http.StatusBadRequest}, err
	}

	return apiserver.ImplResponse{Code: http.StatusOK}, nil
}

func (s *ConfigurationService) ConfigTimeoutPost(ctx context.Context, update apiserver.ConfigurationFieldUpdate) (apiserver.ImplResponse, error) {
	err := conf.UpsertConfig("response_timeout", update.NewValue)

	if err != nil {
		return apiserver.ImplResponse{Code: http.StatusBadRequest}, err
	}

	return apiserver.ImplResponse{Code: http.StatusOK}, nil
}

func (s *ConfigurationService) AddCurrencyToProjectPost(ctx context.Context, update apiserver.CurrencyUpdate) (apiserver.ImplResponse, error) {
	err := conf.UpdateCurrencyProjects(update.Currency, update.ProjectId)
	if err != nil {
		return apiserver.ImplResponse{Code: http.StatusBadRequest}, err
	}

	return apiserver.ImplResponse{Code: http.StatusOK}, nil
}
