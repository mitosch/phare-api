FactoryBot.define do
  factory :page do
    url { "https://www.google.ch" }
    audit_frequency { "hourly" }
    status { "active" }

    factory :page_with_audit_report do
      after(:create) do |page, evaluator|
        create(:audit_report, page: page)
      end
    end

    factory :page_with_audit_reports do
      transient do
        audit_report_count { 2 }
      end

      after(:create) do |page, evaluator|
        create_list(:audit_report, evaluator.audit_report_count, page: page)
      end
    end
  end
end
