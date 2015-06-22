module DevisePhone
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../../templates", __FILE__)
      desc "Add DevisePhone config variables to the Devise initializer and copy DeviseSms locale files to your application."
      
      # def devise_install
      #   invoke "devise:install"
      # end
      
      def add_config_options_to_initializer
        devise_initializer_path = "config/initializers/devise.rb"
        if File.exist?(devise_initializer_path)
          old_content = File.read(devise_initializer_path)
          
          if old_content.match(Regexp.new(/^\s# ==> Configuration for :phone\n/))
            false
          end

        end

      end
      
    end
  end
end