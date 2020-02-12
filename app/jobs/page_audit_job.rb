# frozen_string_literal: true

# Background Job for a page audit which calls the PageAuditor
class PageAuditJob < ApplicationJob
  queue_as :audits

  def perform(page)
    PageAuditor.call(page)
  end
end
