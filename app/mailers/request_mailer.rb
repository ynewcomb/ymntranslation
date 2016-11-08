class RequestMailer < ApplicationMailer

  def translation_request(from_name, email, phone, length, type, file_name, date, msg, skip)
    @from_name = from_name
    @email = email
    @phone = phone
    @translation_length = length
    @translation_type = type
    @skip = skip
    @file_name = file_name
    @due_date = date
    @message = msg

    mail to: "yolanda@ymntranslation.com"
  end
end
