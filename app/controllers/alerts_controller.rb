class AlertsController < ApplicationController
  before_filter :authenticate
  before_filter :authorized_user, :only => :destroy





  
  def create
    @alert = current_user.alerts.build(params[:alert])
    if @alert.save
      redirect_to root_path, :flash => { :success => "Alert created!" }
    else
      render 'pages/home'
    end
  end

  def destroy
    @alert.destroy
    redirect_to root_path, :flash => { :success => "Alert deleted!" }
  end
  
  private

    def authorized_user
      @alert = Alert.find(params[:id])
      redirect_to root_path unless current_user?(@alert.user)
    end
end
