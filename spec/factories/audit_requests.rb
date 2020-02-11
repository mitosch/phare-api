FactoryBot.define do
  factory :audit_request do
    body { "" }
    url { "MyText" }
    audit_type { 1 }
  end
end
