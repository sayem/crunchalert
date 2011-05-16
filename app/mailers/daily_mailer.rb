class DailyMailer < ActionMailer::Base
  default :from => "CrunchAlert <admin@crunchalert.com>"

  def alerts(to, body)
    @dailyalerts = body
    mail(:to => to,
         :subject => "CrunchAlert | Daily Alerts")
  end

  def news(to, body)
    @dailynews = body
    mail(:to => to,
         :subject => "CrunchAlert | Daily News")
  end
end
