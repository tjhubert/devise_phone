require "devise_phone/hooks"

module Devise
  module Models
    # SmsActivable is responsible to verify if an account is already confirmed to
    # sign in, and to send sms with confirmation instructions.
    # Confirmation instructions are sent to the user phone after creating a
    # record and when manually requested by a new confirmation instruction request.
    #
    # == Options
    #
    # Confirmable adds the following options to devise_for:
    #
    #   * +sms_confirm_within+: the time you want to allow the user to access his account
    #     before confirming it. After this period, the user access is denied. You can
    #     use this to let your user access some features of your application without
    #     confirming the account, but blocking it after a certain period (ie 7 days).
    #     By default confirm_within is 0 days, so the user must confirm before entering.
    #     If you want to allow user to use parts of the site and block others override 
    #     sms_confirmation_required? and check manually on selected pages using the
    #     require_sms_activated! helper or sms_confirmed? property on record
    #
    # == Examples
    #
    #   User.find(1).sms_confirm!      # returns true unless it's already confirmed
    #   User.find(1).sms_confirmed?    # true/false
    #   User.find(1).send_sms_token # manually send token
    #
    module Phone
      extend ActiveSupport::Concern

      included do
        before_create :set_unverified_phone_attributes, :if => :phone_verification_needed?
        after_create  :private_generate_verification_code_and_send_sms, :if => :phone_verification_needed?
        # before_save  :remember_old_phone_number
        before_save  :private_generate_verification_code_and_send_sms, :if => :phone_number_changed?
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
        end
      end

      private

        # def remember_old_phone_number
        #   puts "phone number changed?: "
        #   puts phone_number_changed?
        #   if phone_number.present?
        #     puts "Old phone number before save:"
        #     puts phone_number
        #     @old_phone_number = phone_number
        #   else
        #     @old_phone_number = nil
        #   end
        # end

        # def phone_number_changed?
        #   puts "Old phone number after save:"
        #   puts @old_phone_number
        #   if @old_phone_number.present? && phone_number.present?
        #     puts "condition 1"
        #     @old_phone_number != phone_number
        #   elsif @old_phone_number.blank? && phone_number.present?
        #     puts "condition 2"
        #     true
        #   else
        #     puts "condition 3"
        #     set_unverified_phone_attributes
        #     false
        #   end
        # end

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

            twilio_sid = Rails.application.secrets.twilio_sid
            twilio_token = Rails.application.secrets.twilio_token
            twilio_phone_number = Rails.application.secrets.twilio_phone_number

            @twilio_client = Twilio::REST::Client.new twilio_sid, twilio_token
         
            @twilio_client.account.sms.messages.create(
              :from => "+1#{twilio_phone_number}",
              :to => number_to_send_to,
              :body => "Hi! This is MathCrunch. Your verification code is #{verification_code}"
            )
        end
      #end of private methods

      # module ClassMethods # 'public' methods for class user

      #   def generate_verification_code_and_send_sms
      #     if(phone_verification_needed?)
      #       private_generate_verification_code_and_send_sms
      #     end
      #     self.save!
      #   end

      #   def verify_phone_number_with_code_entered(code_entered)
      #     if phone_verification_needed? && (code_entered == self.phone_verification_code)
      #         mark_phone_as_verified!
      #     end
      #   end
        
      # end #end of ClassMethods

    end
  end
end
