require "devise"
require "twilio-ruby"

$: << File.expand_path("..", __FILE__)

require "devise_phone/routes"
require "devise_phone/schema"
require 'devise_phone/controllers/url_helpers'
require 'devise_phone/controllers/helpers'
require 'devise_phone/rails'

module Devise
  # mattr_accessor :sms_confirm_within
  # @@sms_confirm_within = 2.days
  # mattr_accessor :sms_confirmation_keys
  # @@sms_confirmation_keys = [:email]
  
  # Get the sms sender class from the mailer reference object.
  def self.sms_sender
    @@sms_sender_ref.get
  end

  # Set the smser reference object to access the smser.
  def self.sms_sender=(class_name)
    @@sms_sender_ref = ActiveSupport::Dependencies.reference(class_name)
  end
  
  self.sms_sender = "Devise::SmsSender"
end

Devise.add_module :phone, :model => "models/phone", :controller => :phone_verifications, :route => :phone_verification
