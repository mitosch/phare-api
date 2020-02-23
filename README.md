# Phare - Web Performance Monitoring

Phare is a web performance monitoring API, built with Ruby On Rails, to periodically monitor URLs with [Google PageSpeed Insights API](https://developers.google.com/speed/docs/insights/v5/get-started?hl=en) and provide the most relevant statistics.

## Prerequisites

* Postgres >= 10

## API

### Example Usage

Add an URL to the monitoring pool:

Request: `PUT /api/v1/pub/pages`

Payload:
```json
{
  "url": "https://www.google.com",
  "audit_frequency": "hourly"
}
```

Response:
```json
{
  "id": 1,
  "url": "https://www.google.com"
}
```

* If the URL does not exist, it will be created and fetched soon
* If the URL exists, it will be fetched again soon

### Documentation

Find the full documentation of the [Phare API on SwaggerHub](https://app.swaggerhub.com/apis-docs/Mitosch/phare-api/v1).

## Licensing

This project is [MIT licensed](./LICENSE.md).
