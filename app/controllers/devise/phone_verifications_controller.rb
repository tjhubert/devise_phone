class Devise::PhoneVerificationsController < DeviseController

  # GET /resource/phone_verification/new
  def new
    build_resource({})
    render :new
  end

  # POST /resource/phone_verification
  def create
  end
  
  # GET /resource/phone_verification/insert
  def insert
    current_user.generate_verification_code_and_send_sms
    puts "hey"
    render nothing: true
  end
  
  # GET or POST /resource/phone_verification/consume?sms_token=abcdef
  def consume
    current_user.verify_phone_number_with_code_entered(params[:code_entered])
    puts "hey2"

    render nothing: true
  end
  
  protected
  
    def build_resource(hash = nil)
      self.resource = resource_class.new
    end

end
