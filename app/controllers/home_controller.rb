class HomeController < ApplicationController
  def index
    @title = "YMN Translation Services"
    @upload = Upload.new
    @year = Time.new.year.to_s
  end

  def send_request
    from_name = params[:from_name]
    email = params[:email]
    length = params[:translation_length]
    type = params[:translation_type]
    file_name = params[:file_name]
    date = params[:due_date]
    msg = params[:message]
    skip = params[:skip] == "false" ? false : true
    puts skip

    RequestMailer.translation_request(from_name, email, length, type, file_name, date, msg, skip).deliver_later

    render text: "Success"
  end
end
