# frozen_string_literal: true

# Serializer for +Label+
class LabelSerializer
  include SimpleSerializer::ObjectSerializer

  attributes :id, :name, :color
end
