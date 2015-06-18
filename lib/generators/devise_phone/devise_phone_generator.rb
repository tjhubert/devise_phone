module DevisePhone
  module Generators
    class DevisePhoneGenerator < Rails::Generators::NamedBase
      namespace "devise_phone"

      desc "Add :phone_number directive in the given model. Also generate migration for ActiveRecord"

      # def devise_generate_model
      #   invoke "devise", [name]
      # end

      def inject_devise_phone_content
        path = File.join("app", "models", "#{file_path}.rb")
        inject_into_file(path, "phone_number, :", :after => "devise :") if File.exists?(path)
      end

      hook_for :orm
    end
  end
end