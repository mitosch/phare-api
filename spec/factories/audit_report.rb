FactoryBot.define do
  factory :audit_report do
    body do
      JSON.parse(
        File.read(
          Rails
            .root
            .join("spec/factories/psi_data/2020-03-15-0815_psi-google.json")
        )
      )
    end
    summary do
      JSON.parse(
        File.read(
          Rails
            .root
            .join("spec/factories/psi_data/2020-03-15-0815_psi-google_summary.json")
        )
      )
    end
    audit_type { 0 }
    page
  end
end
