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
    date = params[:due_date]
    msg = params[:message]

    RequestMailer.translation_request(from_name, email, length, type, date, msg).deliver_later

    render text: "Success"
  end
end
