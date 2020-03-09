# frozen_string_literal: true

require "simple_serializer/serialization_core"

module SimpleSerializer
  # Serialize a Rails ActiveModel object
  module ObjectSerializer
    extend ActiveSupport::Concern
    include SerializationCore

    def initialize(resource, options = {})
      process_options(options)

      @resource = resource
    end

    def serializable_hash
      return hash_for_collection if collection?(@resource)

      hash_for_one_record
    end

    def hash_for_one_record
      return {} unless @resource

      self.class.record_hash(@resource, @params)
    end

    def hash_for_collection
      serializable_collection = []

      @resource.each do |record|
        serializable_collection << self.class.record_hash(record, @params)
      end

      serializable_collection
    end

    def serialized_json
      ActiveSupport::JSON.encode(serializable_hash)
    end

    private
      def process_options(options)
        @params = {}

        return if options.blank?

        @params = options[:params] || {}

        raise ArgumentError, "params must be hash" unless @params.is_a?(Hash)
      end

      def collection?(resource)
        resource.respond_to?(:size) && !resource.respond_to?(:each_pair)
      end

      class_methods do
        def attributes(*attributes_list, &block)
          self.attributes_to_serialize = {} if attributes_to_serialize.nil?

          attributes_list.each do |attr_name|
            method_name = attr_name
            key = method_name.to_s.camelize(:lower)
            attributes_to_serialize[key] = {
              key: key,
              method: block || method_name
            }
          end
        end
        alias_method :attribute, :attributes
      end
  end
end
