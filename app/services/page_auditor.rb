# frozen_string_literal: true

# Runs a Google PageSpeed audit and saves it to the database
class PageAuditor < ApplicationService
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
        @page.audit_reports.create(
          audit_type: "psi",
          body: JSON.parse(psi_response.body)
        )
      end
    end
  end
end
