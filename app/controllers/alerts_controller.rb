require 'open-uri'
require 'nokogiri'

class AlertsController < ApplicationController
  before_filter :authenticate
  before_filter :authorized_user, :only => :destroy

  # need to have some unique index in here

  
  def create


    begin
      content = params[:alert]['content'].gsub(/[\s\.]/,'-')
      doc = Nokogiri::HTML(open("http://crunchbase.com/#{params[:cbase]}/#{content}"))
      @ass = "exists"
      @alert = current_user.alerts.build(params[:alert])
      if @alert.save
        respond_to do |format|        
          format.html { redirect_to root_path }
          format.js
        end
      end
    rescue OpenURI::HTTPError
      @ass = "not there"
      respond_to do |format|
        format.html { redirect_to root_path }
        format.js
      end
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
