require 'generators/devise/views_generator'

module DevisePhone
  module Generators
    class ViewsGenerator < Devise::Generators::ViewsGenerator
      source_root File.expand_path("../../../../app/views/devise", __FILE__)
      desc 'Copies all DevisePhone views to your application.'

      def generate_view
      	directory 'phone', "#{target_path}/phone"
      	# directory 'path_to_install_directory', 'path_to_source_directory'
      end

      def target_path
        @target_path ||= "app/views/#{scope || :devise}"
      end


    end
  end
end