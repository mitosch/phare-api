# frozen_string_literal: true

require "net/http"

# Runs a Google PageSpeed audit and saves it to the database
class PageAuditor < ApplicationService
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

  def initialize(page)
    @page = page
  end

  def call
    psi_url = "https://www.googleapis.com" \
              "/pagespeedonline/v5/runPagespeed?" \
              "strategy=mobile&url=#{CGI.escape(@page.url)}"
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
