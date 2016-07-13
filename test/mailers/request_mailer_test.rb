require 'test_helper'

class RequestMailerTest < ActionMailer::TestCase
  test "translation_request" do
    mail = RequestMailer.translation_request
    assert_equal "Translation request", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
