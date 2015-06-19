class Devise::SmsSender
  #Actually sends the sms token. feel free to modify and adapt to your provider and/or gem
  def send_sms_verification_code_to(user)
    number_to_send_to = user.phone_number
    verification_code = user.phone_verification_code

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
end
