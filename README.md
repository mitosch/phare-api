# Phare - Web Performance Monitoring

Phare is a web performance monitoring API, built with Ruby On Rails, to periodically monitor URLs with [Google PageSpeed Insights API](https://developers.google.com/speed/docs/insights/v5/get-started?hl=en) and provide the most relevant statistics.

## Prerequisites

* Postgres >= 10

## API

### PUT /api/v1/pub/pages

Add an URL to the monitoring pool.

Payload:
```json
{
  "url": "https://www.google.com"
}
```

## Licensing

This project is [MIT licensed](./LICENSE.md).
