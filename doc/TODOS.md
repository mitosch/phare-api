# Todos

The following tasks are still open and have to be done. Some will be breaking
changes.

## Open

- [ ] Add full lighthouse result in FactoryBot specs (AuditReport) and update spec

## Done

- [x] Change all attributes in responses to camelCase:
  - [x] Change fieldset selection e.g. "with=summary" to JSON:API standard, like:
    ```txt
    GET /articles?include=author&fields[articles]=title,body&fields[people]=name HTTP/1.1
    ```
  - [x] audit report controller: Re-Implement "with=lighthouse" as fields[auditReports]=lighthouseReport
  - [x] audit report controller: Re-Implement limit=1 as page[limit]=1
  - [x] extract lighthouseReport from body and rename field in serializer
  - [-] Add default_url_options in production.rb like development.rb (not needed)
  - [-] Implement serializer with JSON:API standard spec (tried it, lots of caveats...)
- [x] Create index for summary->'fetchTime'
- [-] Add fetch time as DB column for selecting range and performance (extracted summary, fast enough)
  - [-] Drop index on audit_reports.created_at DESC
- [-] Deprecate /pages/{id}/statistics and transfer to logic pages#show (moved to pages controller, ok)
- [x] Implement filter for specific urls in pages/{id}/dive for displaying only matching results
