# frozen_string_literal: true

# Background Job for a page audit which calls the PageAuditor
class PageAuditJob < ApplicationJob
  queue_as :audits

  def perform(page)
    page.last_audited_at = DateTime.now
    page.save
    PageAuditor.call(page)
  end
end
