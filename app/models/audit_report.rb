# frozen_string_literal: true

# A single audit report
class AuditReport < ApplicationRecord
  # Audit types:
  #
  # psi   Google PageSpeed Insights
  #   https://developers.google.com/speed/docs/insights/v5/get-started?hl=en
  #   * Chrome User Experience Report
  #   * Lighthouse Report included
  #
  # lighthouse  Lighthouse
  #   https://github.com/GoogleChrome/lighthouse
  #   * Lighthouse Report only

  scope :without_body, -> { select(AuditReport.column_names - ["body"]) }

  enum audit_type: {
    psi: 0,
    lighthouse: 1
  }

  belongs_to :page

  def lighthouse_result
    body && body["lighthouseResult"]
  end
end
