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

Response:
```json
{
  "id": 1,
  "url": "https://www.google.com"
}
```

* If the URL does not exist, it will be created and fetched soon
* If the URL exists, it will be fetched again soon

### GET /api/v1/pub/pages/1/statistics

Returns statistics of the most relevant metrics.

Response:
```json
[
  {
    "fetchTime": "2020-02-12T15:35:29.594Z",
    "mpf": 971,
    "fmp": 10355,
    "fci": 17878,
    "fcp": 9856,
    "si": 12419.72590831366,
    "ia": 19767.5
  },
  { ... }
]
```

Attributes:
```txt
mpf: max-potential-fid
fmp: first-meaningful-paint
fci: first-cpu-idle
fcp: first-contentful-paint
si:  speed-index
ia:  interactive
```


## Licensing

This project is [MIT licensed](./LICENSE.md).
