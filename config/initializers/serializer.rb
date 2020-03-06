# frozen_string_literal: true

ActiveModelSerializers.config.adapter = ActiveModelSerializers::Adapter::JsonApi
ActiveModelSerializers.config.key_transform = :camel_lower
ActiveModelSerializers.config.default_includes = ""
