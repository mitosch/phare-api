# frozen_string_literal: true

namespace :pocs do
  desc "Testing specific scripts in audits"
  task :script, [:url] => [:environment] do |_task, args|
    url = args[:url]

    page = Page.find(2)
    page.audit_reports.each do |report|
      next unless report.body["lighthouseResult"]

      lh = report.body["lighthouseResult"]
      fetch_time = lh.dig("fetchTime")

      puts "\n"
      puts fetch_time

      render_blocking = lh.dig("audits", "render-blocking-resources")
      items = render_blocking.dig("details", "items")
      opportunity_item = items.find { |item| item["url"].include?(url) }
      next unless opportunity_item

      puts  "  Render Blocking - Potential Savings: " +
        opportunity_item["wastedMs"].to_s

      bootup_time = lh.dig("audits", "bootup-time")
      items = bootup_time.dig("details", "items")
      opportunity_item = items.find { |item| item["url"].include?(url) }
      next unless opportunity_item

      puts  "  Bootup Time - Script Parse Compile: " +
            opportunity_item["scriptParseCompile"].to_s
    end
  end
end
