class RequestMailer < ApplicationMailer

  def translation_request(from_name, email, length, type, date, msg)
    @from_name = from_name
    @email = email
    @translation_length = length
    @translation_type = type
    @due_date = date
    @message = msg

    mail to: "jnewcomb125@gmail.com"
  end
end
