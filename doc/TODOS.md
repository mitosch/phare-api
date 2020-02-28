# Todos

The following tasks are still open and have to be done. Some will be breaking
changes.

## Open

- [-] Add fetch time as DB column for selecting range and performance (extracted summary, fast enough)
  - [ ] Drop index on audit_reports.created_at DESC
  - [ ] Create index for summary->'fetchTime'
- [-] Deprecate /pages/{id}/statistics and transfer to logic pages#show (moved to pages controller)
- [ ] Add full lighthouse result in FactoryBot specs (AuditReport) and update spec
- [ ] Change all attributes in responses to camelCase

## Done

- [x] Implement filter for specific urls in pages/{id}/dive for displaying only matching results
