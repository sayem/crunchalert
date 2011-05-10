class UserMailer < ActionMailer::Base
  default :from => "CrunchAlert <admin@crunchalert.com>"

  def welcome_email(user)
    @user = user
    @url  = "http://crunchalert.com/login"
    mail(:to => user.email,
         :subject => "Welcome to CrunchAlert")
  end

  def welcome_preview(user)
    require 'date'
    yesterday = Date.today.prev_day.strftime("%a").downcase
    @user = user
    @news = WeeklyNews.find_by_id('1').send(yesterday)
    mail(:to => user.email,
         :subject => "CrunchAlert News Preview")
  end

  def forgot_password(to, pass)
    @pass = pass
    mail(:to => to,
         :subject => "Your password is ...") 
  end
end
