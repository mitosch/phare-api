# frozen_string_literal: true

namespace :pocs do
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
