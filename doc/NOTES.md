# Performance

Select items like:
```sql
select body->'lighthouseResult'->'audits'->'render-blocking-resources'->'details'->'items' as test from audit_reports limit 1;
```
