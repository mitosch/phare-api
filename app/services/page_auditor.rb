# frozen_string_literal: true

require "net/http"

# Runs a Google PageSpeed audit and saves it to the database
class PageAuditor < ApplicationService
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

  def initialize(page)
    @page = page
  end

  def call
    key = ENV.fetch("GOOGLE_KEY") { nil }

    key_param = "&key=#{key}" if key

    psi_url = "https://www.googleapis.com" \
              "/pagespeedonline/v5/runPagespeed?" \
              "strategy=mobile#{key_param}&url=#{CGI.escape(@page.url)}"

    psi_uri = URI.parse(psi_url)

    psi_session = Net::HTTP
    psi_session.start(psi_uri.host, nil, use_ssl: true) do |http|
      psi_request = Net::HTTP::Get.new(psi_uri.request_uri)
      psi_response = http.request(psi_request)
      if psi_response.is_a?(Net::HTTPSuccess)
        lh_report = JSON.parse(psi_response.body)
        summary = {
          fetchTime: lh_report.dig("lighthouseResult", "fetchTime")
        }

        SUMMARY_METRICS.values.each do |metric|
          summary[metric] = lh_report.dig("lighthouseResult",
                                          "audits",
                                          metric).except(*EXCLUDE_ATTRIBUTES)
        end

        @page.audit_reports.create(
          audit_type: "psi",
          body: lh_report,
          summary: summary
        )
      end
    end
  end
end
