require "devise_phone/hooks"

module Devise
  module Models
    module Phone
      extend ActiveSupport::Concern

      included do
        before_create :set_unverified_phone_attributes, :if => :phone_verification_needed?
        # after_create  :private_generate_verification_code_and_send_sms, :if => :phone_verification_needed?
        # before_save  :remember_old_phone_number
        after_save  :private_generate_verification_code_and_send_sms, :if => :regenerate_phone_verification_needed?
      end

      def generate_verification_code_and_send_sms
          if(phone_verification_needed?)
            private_generate_verification_code_and_send_sms
          end
          self.save!
        end

      def verify_phone_number_with_code_entered(code_entered)
        if phone_verification_needed? && (code_entered == self.phone_verification_code)
          mark_phone_as_verified!
          true
        else
          false
        end
      end

      private

        def private_generate_verification_code_and_send_sms
            self.phone_verification_code = generate_phone_verification_code
            set_unverified_phone_attributes
            if phone_number.present?
              send_sms_verification_code
            end
        end


        def mark_phone_as_verified!
          update!(phone_number_verified: true,
                 phone_verification_code: nil,
                 phone_verification_code_sent_at: nil,
                 phone_verified_at: DateTime.now)
        end

        # check if phone verification is needed and set errors here
        def phone_verification_needed?
          if phone_number.blank?
            self.errors.add(:phone_verification_code, :empty_phone_number_field)
            false
          elsif phone_number_verified
            self.errors.add(:phone_verification_code, :phone_verification_not_needed)
            false
          else
            true
          end
        end

        def regenerate_phone_verification_needed?
          if phone_number.present?
            if phone_number_changed?
              true
            else
              false
            end
            # self.errors.add(:phone_verification_code, :empty_phone_number_field)
            # false
          else
            false
          end
        end

        # set attributes to user indicating the phone number is unverified
        def set_unverified_phone_attributes
          self.phone_number_verified = false
          self.phone_verification_code_sent_at = DateTime.now
          self.phone_verified_at = nil
          # removes all white spaces, hyphens, and parenthesis
          if self.phone_number
            self.phone_number.gsub!(/[\s\-\(\)]+/, '')
          end
        end

        # return 6 digits random code a-z,0-9
        def generate_phone_verification_code
          verification_code = SecureRandom.hex(3)
          verification_code
        end

        # sends a message to number indicated in the secrets.yml
        def send_sms_verification_code
            number_to_send_to = self.phone_number
            verification_code = self.phone_verification_code

            twilio_sid = Rails.application.config.twilio[:sid]
            twilio_token = Rails.application.config.twilio[:token]
            twilio_phone_number = Rails.application.config.twilio[:phone_number]
            twilio_message_body = Rails.application.config.twilio[:message_body]

            @twilio_client = Twilio::REST::Client.new twilio_sid, twilio_token
         
            @twilio_client.account.messages.create(
              :from => "+1#{twilio_phone_number}",
              :to => number_to_send_to,
              :body => twilio_message_body
            )
        end

    end
  end
end
