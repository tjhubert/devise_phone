class Devise::PhoneVerificationsController < DeviseController

  # GET /resource/phone_verification/new
  def new
    build_resource({})
    render :new
  end

  # POST /resource/phone_verification
  def create

    self.set_default_phone_attributes_and_send_verification_code

    # self.resource = resource_class.send_verification_code
    
    # if resource.errors.empty?
    #   set_flash_message :notice, :send_token, :phone => self.resource.phone
    #   redirect_to new_session_path(resource_name)
    # else
    #   render :new
    # end
  end
  
  # GET /resource/phone_verification/insert
  def insert
    build_resource({})
  end
  
  # GET or POST /resource/phone_verification/consume?sms_token=abcdef
  def consume
    
    self.verify_phone_number_with_code_entered(params[:code_entered])

    # self.resource = resource_class.verify_phone_number_with_code_entered(params[:code_entered])

    # if resource.errors.empty?
    #   set_flash_message :notice, :confirmed
    #   sign_in_and_redirect(resource_name, resource)
    # else
    #   render :new
    # end

  end
  
  protected
  
    def build_resource(hash = nil)
      self.resource = resource_class.new
    end

end
