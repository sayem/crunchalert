class UserMailer < ActionMailer::Base
  default :from => "CrunchAlert <admin@crunchalert.com>"

  def welcome_email(user)
    @user = user
    @url  = "http://crunchalert.com/login"
    mail(:to => user.email,
         :subject => "Welcome to CrunchAlert")
  end

  def welcome_preview(user)
    @user = user
    require 'date'
    require 'htmlentities'
    coder = HTMLEntities.new
    yesterday = Date.today.prev_day.strftime("%a").downcase    
    news = WeeklyNews.find_by_id('1').send(yesterday).to_s.split(/\"/)
    news.collect! {|x| coder.decode(x)}
    news.collect! {|x| x.gsub(/--- /, '').gsub(/\n- /, '').gsub(/\\xE2\\x80\\x94/,'&mdash;')}
    @welcome_news = news

    mail(:to => user.email,
         :subject => "CrunchAlert | News Sample")
  end

  def forgot_password(to, pass)
    @pass = pass
    mail(:to => to,
         :subject => "CrunchAlert | Password Reset") 
  end
end
