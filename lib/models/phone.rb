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
        after_create  :generate_verification_code_and_send_sms, :if => :phone_verification_needed?
      end

      # # Confirm a user by setting it's sms_confirmed_at to actual time. If the user
      # # is already confirmed, add en error to email field
      # def confirm_sms!
      #   unless_sms_confirmed do
      #     self.sms_confirmation_token = nil
      #     self.sms_confirmed_at = Time.now
      #     save(:validate => false)
      #   end
      # end

      # # Verifies whether a user is sms-confirmed or not
      # def confirmed_sms?
      #   !!sms_confirmed_at
      # end

      # Send confirmation token by sms
      def generate_verification_code_and_send_sms
        if(self.phone_number?)
          update!(phone_verification_code: generate_phone_verification_code)
          send_sms_verification_code
        else
          self.errors.add(:phone_verification_code, :no_phone_associated)
          false
        end
      end

      def verify_phone_number_with_code_entered(code_entered)
        if (code_entered == self.phone_verification_code)
          mark_phone_as_verified!
          true
        else
          self.errors.add(:phone_verification_code, :wrong_code_entered)
          false
        end
      end


      # # Resend sms confirmation token. This method does not need to generate a new token.
      # def resend_sms_token
      #   unless_sms_confirmed { send_sms_token }
      # end

      # Overwrites active? from Devise::Models::Activatable for sms confirmation
      # by verifying whether a user is active to sign in or not. If the user
      # is already confirmed, it should never be blocked. Otherwise we need to
      # calculate if the confirm time has not expired for this user.

      # def active?
      #   !sms_confirmation_required? || confirmed_sms? || confirmation_sms_period_valid?
      # end

      # # The message to be shown if the account is inactive.
      # def inactive_message
      #   !confirmed_sms? ? I18n.t(:"devise.sms_activations.unconfirmed_sms") : super
      # end

      # # If you don't want confirmation to be sent on create, neither a code
      # # to be generated, call skip_sms_confirmation!
      # def skip_sms_confirmation!
      #   self.sms_confirmed_at = Time.now
      # end

      private

        # Callback to overwrite if an sms confirmation is required or not.
        def phone_verification_needed?
          phone_number.present? && !phone_number_verified
        end

        # Generates a new random token for confirmation, and stores the time
        # this token is being generated
        def set_unverified_phone_attributes

          self.phone_number_verified = false
          self.phone_verification_code_sent_at = DateTime.now
          self.phone_verified_at = nil
          # removes all white spaces, hyphens, and parenthesis
          self.phone_number.gsub!(/[\s\-\(\)]+/, '')
        end

        def generate_phone_verification_code
          verification_code = SecureRandom.hex(3)
          verification_code
        end

        def send_sms_verification_code
            number_to_send_to = self.phone_number
            verification_code = self.phone_verification_code

            twilio_sid = "ACd35391c08cde7926e2295d1812ada918"
            twilio_token = "44d79a36adb3d54cc15711d94d149119"
            twilio_phone_number = "6502810746"

            @twilio_client = Twilio::REST::Client.new twilio_sid, twilio_token
         
            @twilio_client.account.sms.messages.create(
              :from => "+1#{twilio_phone_number}",
              :to => number_to_send_to,
              :body => "Hi! This is MathCrunch. Your verification code is #{verification_code}"
            )
        end

        # module ClassMethods

        #   def mark_phone_as_verified!
        #     update!(phone_number_verified: true,
        #            phone_verification_code: nil,
        #            phone_verification_code_sent_at: nil,
        #            phone_verified_at: DateTime.now)
        #   end 

        #   def verify_phone_number_with_code_entered(code_entered)
        #     if self.phone_verification_code == code_entered
        #       mark_phone_as_verified!
        #     end
        #   end

        #   def set_unverified_phone_attributes_and_send_verification_code
        #     self.set_verified_phone_attributes
        #     if self.save!
        #       send_sms_for_verification_code
        #     end
        #   end

        # end
    end
  end
end
