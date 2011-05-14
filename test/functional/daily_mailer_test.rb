require 'test_helper'

class DailyMailerTest < ActionMailer::TestCase
  test "alerts" do
    mail = DailyMailer.alerts
    assert_equal "Alerts", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

  test "news" do
    mail = DailyMailer.news
    assert_equal "News", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
