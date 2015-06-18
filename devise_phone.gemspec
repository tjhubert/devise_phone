# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'devise_phone/version'

Gem::Specification.new do |s|
  s.name         = "devise_phone"
  s.version      = DevisePhone::VERSION
  s.authors      = ["Hubert Theodore"]
  s.email        = ["htheodore@gmail.com"]
  s.homepage     = "https://github.com/tjhubert/devise_phone"
  s.license      = "MIT"
  s.summary      = "Send SMS to verify phone number"
  s.description  = "It sends verification code via SMS (using Twilio). User enters the code to confirm the phone number."
  s.files        = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  # s.files        = Dir["{app,config,lib}/**/*"] + %w[LICENSE README.rdoc]
  # s.require_path = "lib"
  # s.rdoc_options = ["--main", "README.rdoc", "--charset=UTF-8"]

  # s.required_ruby_version     = '>= 1.8.6'
  # s.required_rubygems_version = '>= 1.3.6'
  s.bindir        = "exe"
  s.executables   = s.files.grep(%r{^exe/}) { |f| File.basename(f) }
  s.require_paths = ["lib"]

  {
    'bundler'     => '~> 1.10',
    # 'rspec',
    'rake'        => '~> 10.0'
  }.each do |lib, version|
    s.add_development_dependency(lib, version)
  end

  {
    'rails'  => '>= 4.0.0',
    'devise' => '>= 3.0.0',
    'twilio-ruby' => '>= 4.0.0'
  }.each do |lib, version|
    s.add_runtime_dependency(lib, version)
  end

end
