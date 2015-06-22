require "devise"
require "twilio-ruby"

$: << File.expand_path("..", __FILE__)

require "devise_phone/routes"
require "devise_phone/schema"
require 'devise_phone/controllers/url_helpers'
require 'devise_phone/controllers/helpers'
require 'devise_phone/rails'

module Devise
end

Devise.add_module :phone, :model => "models/phone", :controller => :phone_verifications, :route => :phone_verification
