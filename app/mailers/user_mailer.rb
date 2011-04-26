class UserMailer < ActionMailer::Base
  default :from => "CrunchAlert <admin@crunchalert.com>"
 
  def welcome_email(user)
    @user = user
    @url  = "http://crunchalert.com/login"
    mail(:to => user.email,
         :subject => "Welcome to CrunchAlert")
  end

  def forgot_password(to, pass)
    @pass = pass
    mail(:to => to,
         :subject => "Your password is ...") 
  end



end
