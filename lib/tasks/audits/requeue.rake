# frozen_string_literal: true

namespace :audits do
  # This task is meant to be executed periodically, e.g. by a cron job.
  #
  # Recommended execution: every 5 minutes.
  desc "Enqueue Page audits based on it's settings"
  task requeue: :environment do
    pages = Page.all
    pages.each do |page|
      max_age = case page.audit_frequency
                when "hourly"
                  1.hour
                when "daily"
                  1.day
                else
                  1.day
                end

      if page.last_audited_at && page.last_audited_at > max_age.ago
        Rails.logger.info("Page #{page.id} skipped, max age not reached")
        next
      end

      Rails.logger.info("Page #{page.id} added to queue")
      PageAuditJob.perform_later(page)
    end
  end
end
