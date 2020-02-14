FactoryBot.define do
  factory :page do
    url { "https://www.google.com" }
    audit_frequency { "hourly" }
    status { "active" }
  end
end
