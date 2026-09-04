# Local developer services

This folder contains a small local Docker Compose stack for common application dependencies. It is intentionally isolated from the rest of the repo and uses non-standard ports so it can coexist with other local development services.

## Included services

- PostgreSQL on a dynamic port per environment
- Redis on a dynamic port per environment
- RabbitMQ AMQP on a dynamic port per environment
- RabbitMQ management UI on a dynamic port per environment
- MongoDB on a dynamic port per environment
- Elasticsearch on a dynamic port per environment (optional advanced service)
- MySQL on a dynamic port per environment (optional advanced service)
- Kafka on a dynamic port per environment (optional advanced service)
- Prometheus on a dynamic port per environment (optional observability service)
- Grafana on a dynamic port per environment (optional observability dashboard)

## Quick start

From the repo root:

```bash
bash ./services/local-dev.sh
```

You will be prompted to choose a preset such as:

- everything
- data-cache
- queue-cache
- lamp
- lemp
- mern
- mevn
- jamstack
- serverless
- xampp
- observability
- custom
- exit

The custom selector accepts numbered multi-select input such as `1 3 5` or `all`, and includes the optional Elasticsearch, MySQL, Kafka, Prometheus, and Grafana services in the selection list.

## Useful commands

```bash
bash ./services/local-dev.sh status
bash ./services/local-dev.sh logs postgres
bash ./services/local-dev.sh down
```

## Notes

This stack keeps the common local development needs focused on database-backed and event-driven apps, while still exposing Elasticsearch, MySQL, Kafka, Prometheus, and Grafana as optional advanced services for search-heavy, event-driven, and observability-focused workflows.
