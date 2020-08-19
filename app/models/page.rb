# frozen_string_literal: true

# A Page with an URL which will be fetched continuously
class Page < ApplicationRecord
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

  enum status: {
    active: 0,
    inactive: 1,
    archived: 2
  }

  enum audit_frequency: {
    hourly: 0,
    daily: 1
  }

  has_many :audit_reports, dependent: :destroy

  has_one :label_page, dependent: :destroy
  has_one :label, through: :label_page

  def statistics
    audit_reports
      .select(statistic_fields)
      .group("day")
      .order("day")
      .to_json(except: :id)
  end

  private
    def statistic_fields
      select_fields = [
        "TO_DATE(summary" \
        "->>'fetchTime', 'YYYY-MM-DD') AS day"
      ]

      SUMMARY_METRICS.each do |key, metric|
        select_fields.push("AVG(CAST(summary" \
                           "->'#{metric}'->>'numericValue' " \
                           "AS FLOAT)) AS #{key}")
      end

      select_fields
    end
end
