# frozen_string_literal: true

# Serializer for +Page+
class PageSerializer
  include FastJsonapi::ObjectSerializer

  set_key_transform :camel_lower

  set_id :id
  attributes :url, :status, :audit_frequency, :last_audited_at
end
