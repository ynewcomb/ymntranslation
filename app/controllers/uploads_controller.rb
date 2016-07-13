class UploadsController < ApplicationController
  def create
    @upload = Upload.new(upload_params)
    if @upload.save
      @message = "File uploaded to dropbox"
      # after uploading the file to dropbox, we delete it from the database
      # this way, we never have to actually store anything on Heroku
      Upload.delete_all
    else
      @message = "File upload failed"
    end

    respond_to do |format|
      format.js {render layout: false, content_type: 'text/javascript'}
    end
  end

  private

  def upload_params
    params.require(:upload).permit(:file, :title)
  end
end
