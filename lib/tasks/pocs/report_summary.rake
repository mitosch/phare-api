# frozen_string_literal: true

namespace :pocs do
  desc "Extract summary part of all lighthouse v6 reports"
  task summary_upgrade: :environment do
    SUMMARY_METRICS = {
      max_potential_fid: "max-potential-fid",               # LH5 only, eol by LH6
      first_meaningful_paint: "first-meaningful-paint",     # LH5 only, eol by LH6
      first_cpu_idle: "first-cpu-idle",                     # LH5 only, eol by LH6
      first_contentful_paint: "first-contentful-paint",     # LH5, LH6
      speed_index: "speed-index",                           # LH5, LH6
      interactive: "interactive",                           # LH5, LH6
      largest_contentful_paint: "largest-contentful-paint", # LH6 (new)
      total_blocking_time: "total-blocking-time",           # LH6 (new)
      cumulative_layout_shift: "cumulative-layout-shift"    # LH6 (new)
    }.freeze

    EXCLUDE_ATTRIBUTES = %w[
      description
      details
      title
      scoreDisplayMode
    ].freeze

    version = "6.1.0"

    select_fields = %i[id summary]
    select_fields.push("body->'lighthouseResult'->" \
                       "'fetchTime' as fetch_time")
    select_fields.push("body->'lighthouseResult'->" \
                       "'lighthouseVersion' as version")

    SUMMARY_METRICS.each do |key, metric|
      delete_op = EXCLUDE_ATTRIBUTES.map { |a| "#- '{#{a}}'" }
                                    .join(" ")

      select_fields
        .push("body->'lighthouseResult'->" \
              "'audits'->'#{metric}' #{delete_op} as #{key}")
    end

    print "\n"
    AuditReport
      .all
      .select(select_fields)
      .where("summary->>'fetchTime' > ?", 170.days.ago)
      .where("body->'lighthouseResult'->>'lighthouseVersion' LIKE '6._._'")
      .find_each do |ar|

      summary = {
        fetchTime: ar.fetch_time
      }

      SUMMARY_METRICS.each do |key, metric|
        summary[metric] = ar[key]
      end

      audit_report = AuditReport.find(ar.id)
      audit_report.summary = summary
      audit_report.save

      print "."
    end
    print "\n"
  end

  desc "Extract summary part of reports to separate column"
  task summary_extract: :environment do
    SUMMARY_METRICS = {
      max_potential_fid: "max-potential-fid",
      first_meaningful_paint: "first-meaningful-paint",
      first_cpu_idle: "first-cpu-idle",
      first_contentful_paint: "first-contentful-paint",
      speed_index: "speed-index",
      interactive: "interactive"
    }.freeze

    EXCLUDE_ATTRIBUTES = %w[
      description
      title
      scoreDisplayMode
    ].freeze

    select_fields = %i[id summary]
    select_fields.push("body->'lighthouseResult'->" \
                       "'fetchTime' as fetch_time")

    SUMMARY_METRICS.each do |key, metric|
      delete_op = EXCLUDE_ATTRIBUTES.map { |a| "#- '{#{a}}'" }
                                    .join(" ")

      select_fields
        .push("body->'lighthouseResult'->" \
              "'audits'->'#{metric}' #{delete_op} as #{key}")
    end

    print "\n"
    AuditReport
      .all
      .select(select_fields)
      .where(summary: nil)
      .find_each do |ar|
      summary = {
        fetchTime: ar.fetch_time
      }

      SUMMARY_METRICS.each do |key, metric|
        summary[metric] = ar[key]
      end

      audit_report = AuditReport.find(ar.id)
      audit_report.summary = summary
      audit_report.save

      print "."
    end
    print "\n"
  end
end
