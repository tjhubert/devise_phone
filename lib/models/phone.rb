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
        before_save :set_phone_attributes, :if => :phone_verification_needed?
        after_save  :generate_verification_code_and_send_sms, :if => :phone_verification_needed?
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
          self.phone_verification_code = generate_phone_verification_code
          send_sms_verification_code
        else
          # self.errors.add(:sms_confirmation_token, :no_phone_associated)
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

      protected

        # Callback to overwrite if an sms confirmation is required or not.
        def phone_verification_needed?
          phone_number.present? && !phone_number_verified
        end

        # def sms_confirmation_required?
        #   !confirmed_sms?
        # end

        # Checks if the confirmation for the user is within the limit time.
        # We do this by calculating if the difference between today and the
        # confirmation sent date does not exceed the confirm in time configured.
        # Confirm_in is a model configuration, must always be an integer value.
        #
        # Example:
        #
        #   # sms_confirm_within = 1.day and sms_confirmation_sent_at = today
        #   confirmation_period_valid?   # returns true
        #
        #   # sms_confirm_within = 5.days and sms_confirmation_sent_at = 4.days.ago
        #   confirmation_period_valid?   # returns true
        #
        #   # sms_confirm_within = 5.days and sms_confirmation_sent_at = 5.days.ago
        #   confirmation_period_valid?   # returns false
        #
        #   # sms_confirm_within = 0.days
        #   confirmation_period_valid?   # will always return false
        #
        # def confirmation_sms_period_valid?
        #   sms_confirmation_sent_at && sms_confirmation_sent_at.utc >= self.class.sms_confirm_within.ago
        # end

        # # Checks whether the record is confirmed or not, yielding to the block
        # # if it's already confirmed, otherwise adds an error to email.
        # def unless_sms_confirmed
        #   unless confirmed_sms?
        #     yield
        #   else
        #     self.errors.add(:sms_confirmation_token, :sms_already_confirmed)
        #     false
        #   end
        # end

        # Generates a new random token for confirmation, and stores the time
        # this token is being generated
        def set_phone_attributes

          self.phone_number_verified = false
          self.phone_verification_code_sent_at = DateTime.now
          self.phone_verified_at = nil
          # removes all white spaces, hyphens, and parenthesis
          self.phone_number.gsub!(/[\s\-\(\)]+/, '')
        end

        def generate_phone_verification_code
          # begin
          verification_code = SecureRandom.hex(3)
          # end while self.class.exists?(phone_verification_code: verification_code)
          verification_code
        end

        # def generate_sms_token!
        #   generate_sms_token && save(:validate => false)
        # end

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

        module ClassMethods
          # # Attempt to find a user by it's email. If a record is found, send a new
          # # sms token instructions to it. If not user is found, returns a new user
          # # with an email not found error.
          # # Options must contain the user email
          # def send_sms_token(attributes={})
          #   sms_confirmable = find_or_initialize_with_errors(sms_confirmation_keys, attributes, :not_found)
          #   sms_confirmable.resend_sms_token if sms_confirmable.persisted?
          #   sms_confirmable
          # end

          # # Find a user by it's sms confirmation token and try to confirm it.
          # # If no user is found, returns a new user with an error.
          # # If the user is already confirmed, create an error for the user
          # # Options must have the sms_confirmation_token
          # def confirm_by_sms_token(sms_confirmation_token)
          #   sms_confirmable = find_or_initialize_with_error_by(:sms_confirmation_token, sms_confirmation_token)
          #   sms_confirmable.confirm_sms! if sms_confirmable.persisted?
          #   sms_confirmable
          # end

          def mark_phone_as_verified!
            update!(phone_number_verified: true,
                   phone_verification_code: nil,
                   phone_verification_code_sent_at: nil,
                   phone_verified_at: DateTime.now)
          end 

          def verify_phone_number_with_code_entered(code_entered)
            if self.phone_verification_code == code_entered
              mark_phone_as_verified!
            end
          end

          def set_default_phone_attributes_and_send_verification_code
            self.set_phone_attributes
            if self.save!
              send_sms_for_verification_code
            end
          end

          

          # # Generates a small token that can be used conveniently on SMS's.
          # # The token is 5 chars long and uppercased.

          # def generate_small_token(column)
          #   loop do
          #     token = Devise.friendly_token[0,5].upcase
          #     break token unless to_adapter.find_first({ column => token })
          #   end
          # end

          # # Generate an sms token checking if one does not already exist in the database.
          # def sms_confirmation_token
          #   generate_small_token(:sms_confirmation_token)
          # end

          # Devise::Models.config(self, :sms_confirm_within, :sms_confirmation_keys)
        end
    end
  end
end
