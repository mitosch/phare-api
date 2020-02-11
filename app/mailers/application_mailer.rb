# frozen_string_literal: true

# Example Rails ActionMailer
class ApplicationMailer < ActionMailer::Base
  default from: "from@example.com"
  layout "mailer"
end
