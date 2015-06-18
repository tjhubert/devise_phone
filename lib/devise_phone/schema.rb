module DevisePhone
  module Schema

    def phone
      apply_devise_schema :phone_number,   String
      apply_devise_schema :phone_number_verified,   Boolean
      apply_devise_schema :phone_verification_code,   String, :limit => 6
      apply_devise_schema :phone_verification_code_sent_at, DateTime
      apply_devise_schema :phone_verified_at, DateTime
    end
  end
end

#Devise::Schema.send :include, DeviseSmsActivable::Schema
