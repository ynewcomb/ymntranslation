class RequestMailer < ApplicationMailer

  def translation_request(from_name, email, length, type, file_name, date, msg, skip)
    @from_name = from_name
    @email = email
    @translation_length = length
    @translation_type = type
    @skip = skip
    @file_name = file_name
    @due_date = date
    @message = msg

    mail to: "jnewcomb125@gmail.com"
  end
end
