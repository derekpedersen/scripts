# Local developer services

This folder contains a small local Docker Compose stack for common application dependencies. It is intentionally isolated from the rest of the repo and uses non-standard ports so it can coexist with other local development services.

## Included services

- PostgreSQL on `localhost:5433`
- Redis on `localhost:6380`
- RabbitMQ AMQP on `localhost:5673`
- RabbitMQ management UI on `localhost:15673`
- MongoDB on `localhost:27018`
- Elasticsearch on `localhost:9201` (optional advanced service)

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
- custom
- exit

The custom selector accepts numbered multi-select input such as `1 3 5` or `all`, and includes the optional Elasticsearch service in the selection list.

## Useful commands

```bash
bash ./services/local-dev.sh status
bash ./services/local-dev.sh logs postgres
bash ./services/local-dev.sh down
```

## Notes

This stack keeps the common local development needs focused on database-backed and event-driven apps, while still exposing Elasticsearch as an optional advanced service for search-heavy workflows.
