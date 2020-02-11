# frozen_string_literal: true

# Main service class
#
#   SomeService.call(args)
class ApplicationService
  def self.call(*args, &block)
    new(*args, &block).call
  end
end
