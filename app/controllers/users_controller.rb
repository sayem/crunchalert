class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      sign_in @user
      redirect_to root_path
      UserMailer.welcome_email(@user).deliver
      UserMailer.welcome_preview(@user).deliver
    else
      render 'new'
    end
  end

  def forgot_password
    if request.post?
      u = User.find_by_email(params[:user][:email])
      if u and u.send_new_password
        flash[:message] = "A new password was just emailed to you."
        redirect_to login_path
      else
        flash.now[:notice] = "Invalid email. Couldn't send password."
      end
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      sign_in @user  
      redirect_to root_path
    else
      render 'edit'
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    if News.find_by_user_id(params[:id])
      News.find_by_user_id(params[:id]).delete
    end
    alerts = Alert.where(:user_id => params[:id])
    alerts.each {|x| x.delete }
    redirect_to root_path
  end
end
