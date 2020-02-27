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
CREATE INDEX test2_audits ON audit_reports ((body->'lighthouseResult'->'audits'->'max-potential-fid'->'id'));
CREATE INDEX test3_audits ON audit_reports USING GIN ((body->'lighthouseResult'->'audits'));
CREATE INDEX test4_audits ON audit_reports USING GIN ((body->'lighthouseResult'->'audits'->'max-potential-fid'));
CREATE INDEX test1_fetch_time ON audit_reports ((body->'lighthouseResult'->'fetchTime'));
```
