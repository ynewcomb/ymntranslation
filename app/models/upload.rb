class Upload < ApplicationRecord
  has_attached_file :file,
    :storage => :dropbox,
    :dropbox_credentials => { app_key: ENV['APP_KEY'],
                              app_secret: ENV['APP_SECRET'],
                              access_token: ENV['ACCESS_TOKEN'],
                              access_token_secret: ENV['ACCESS_TOKEN_SECRET'],
                              user_id: ENV['USER_ID'],
                              access_type: 'app_folder'}

  validates_attachment :file, presence: true, content_type: { content_type: ["application/msword",
     "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
     "application/vnd.openxmlformats-officedocument.wordprocessingml.template",
     "pplication/vnd.ms-word.document.macroEnabled.12",
     "application/vnd.ms-word.template.macroEnabled.12",
     "application/vnd.ms-word.document.12",
     "application/vnd.ms-word.template.12"] }
end
