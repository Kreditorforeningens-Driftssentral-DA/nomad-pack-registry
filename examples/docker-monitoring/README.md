# Example Monitoring stack

## Description

  * [Grafana](http://localhost:3000) for visualizing metrics & logs. (grafana/grafana)
  * [MinIO](http://localhost:3001) for loki backend storage (aws/s3). (lokiadmin/lokiadmin)
  * [Prometheus](http://localhost:9090) for scraping metrics from services.
  * Loki for storing & receiving logs.
  * Fluent-bit for generating logs (dummy) to loki

## Running

```bash
# Start/build services
$ docker compose -f docker-compose.yml up

# Stop
$ docker compose -f docker-compose.yml down

# Cleanup minio data
$ docker compose -f docker-compose.yml down --volumes
```

## References

  * https://raw.githubusercontent.com/minio/minio/master/docs/orchestration/docker-compose/docker-compose.yaml
  * https://grafana.com/docs/loki/latest/fundamentals/architecture/
