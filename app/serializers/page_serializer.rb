# frozen_string_literal: true

# Serializer for +Page+
class PageSerializer
  include SimpleSerializer::ObjectSerializer

  attributes :id, :url, :status, :audit_frequency, :last_audited_at
end
