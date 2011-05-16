class WeeklyMailer < ActionMailer::Base
  default :from => "CrunchAlert <admin@crunchalert.com>"

  def alerts(to, body)
    @weeklyalerts = body
    mail(:to => to,
         :subject => "CrunchAlert | Weekly Alerts")
  end

  def news(to, body)
    @weeklynews = body
    mail(:to => to,
         :subject => "CrunchAlert | Weekly News")
  end
end
