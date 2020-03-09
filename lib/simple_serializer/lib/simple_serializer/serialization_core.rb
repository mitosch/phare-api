# frozen_string_literal: true

module SimpleSerializer
  # Core functionalities for serialization
  module SerializationCore
    extend ActiveSupport::Concern

    included do
      class << self
        attr_accessor :attributes_to_serialize
      end
    end

    class_methods do
      def record_hash(record, params = {})
        record_hash = {}
        attributes = attributes_to_serialize
        attributes.each do |_k, hash|
          record_hash[hash[:key]] = if hash[:method].is_a?(Proc)
                                      hash[:method].call(record, params)
                                    else
                                      record.public_send(hash[:method])
                                    end
        end

        record_hash
      end
    end
  end
end
