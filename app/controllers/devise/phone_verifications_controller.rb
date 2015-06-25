class Devise::PhoneVerificationsController < DeviseController

  # GET /resource/phone_verification/new
  # def new
  #   build_resource({})
  #   render :new
  # end

  # POST /resource/phone_verification
  # def create
  # end
  
  # GET /resource/phone_verification/send_code
  def send_code
    current_user.generate_verification_code_and_send_sms
    # render nothing: true
    respond_to do |format|
      msg = { :status => "ok", :message => "SMS sent!" }
      format.json  { render :json => msg } # don't do msg.to_json
    end
  end
  
  # GET or POST /resource/phone_verification/verify_code
  def verify_code
    verify_success = current_user.verify_phone_number_with_code_entered(params[:code_entered])
    # render nothing: true
    respond_to do |format|
      if verify_success
        message_response = "verification successful"
      else
        message_response = "verification fail"
      end
      msg = { :status => "ok", :message => message_response }
      format.json  { render :json => msg } # don't do msg.to_json
    end
  end
  
  protected
  
    def build_resource(hash = nil)
      self.resource = resource_class.new
    end

end
