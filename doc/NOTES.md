# Performance

Select items like:
```sql
select body->'lighthouseResult'->'audits'->'render-blocking-resources'->'details'->'items' as test from audit_reports limit 1;
```

Add the following index when adding server-side-pagination:
```sql
CREATE INDEX test3_order_by_created_at ON audit_reports (created_at DESC);
```

```sql
select id, to_date(body->'lighthouseResult'->>'fetchTime', 'YYYY-MM-DD') as ts, body->'lighthouseResult'->'audits'->'max-potential-fid'->'numericValue' as mpf from audit_reports where page_id=4 limit 10;

SELECT TO_DATE(body->'lighthouseResult'->>'fetchTime', 'YYYY-MM-DD') AS day, AVG(CAST(body->'lighthouseResult'->'audits'->'max-potential-fid'->>'numericValue' AS INTEGER)) AS mpf FROM audit_reports WHERE page_id=4 GROUP BY day ORDER BY day;
```

```sql
EXPLAIN ANALYZE SELECT "audit_reports"."id", summary->'fetchTime' as fetch_time, body->'lighthouseResult'->'audits'->'render-blocking-resources'->'details'->'items' as items FROM "audit_reports" WHERE "audit_reports"."page_id" = 1 AND (summary->>'fetchTime' >= '2020-02-23') AND (summary->>'fetchTime' <= '2020-03-01');
```
