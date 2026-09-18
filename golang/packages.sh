#!/usr/bin/env bash

GO_CORE_PACKAGES=(
  "github.com/golangci/golangci-lint/cmd/golangci-lint@latest"
  "mvdan.cc/gofumpt@latest"
  "github.com/go-delve/delve/cmd/dlv@latest"
  "honnef.co/go/tools/cmd/staticcheck@latest"
)

GO_FULL_PACKAGES=(
  "github.com/golangci/golangci-lint/cmd/golangci-lint@latest"
  "mvdan.cc/gofumpt@latest"
  "github.com/go-delve/delve/cmd/dlv@latest"
  "honnef.co/go/tools/cmd/staticcheck@latest"
  "github.com/google/wire/cmd/wire@latest"
  "github.com/golang-migrate/migrate/v4/cmd/migrate@latest"
  "github.com/go-swagger/go-swagger/cmd/swagger@latest"
  "github.com/air-verse/air@latest"
  "gotest.tools/gotestsum@latest"
  "github.com/segmentio/golines@latest"
)
