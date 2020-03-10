# frozen_string_literal: true

# A Page with an URL which will be fetched continuously
class Page < ApplicationRecord
  SUMMARY_METRICS = {
    max_potential_fid: "max-potential-fid",
    first_meaningful_paint: "first-meaningful-paint",
    first_cpu_idle: "first-cpu-idle",
    first_contentful_paint: "first-contentful-paint",
    speed_index: "speed-index",
    interactive: "interactive"
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
