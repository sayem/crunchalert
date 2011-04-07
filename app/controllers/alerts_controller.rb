require 'open-uri'
require 'nokogiri'

class AlertsController < ApplicationController
  before_filter :authenticate
  before_filter :authorized_user, :only => :destroy

 
  def create    
    content = params[:alert]['content'].gsub(/[\s\.]/,'-')
    if content =~ /[\w+\-]/i
      begin
        doc = Nokogiri::HTML(open("http://crunchbase.com/#{params[:cbase]}/#{content}"))
        milestones = doc.css('#milestones').text.strip!
        if milestones
          @check = "exists"
          @alert = current_user.alerts.build(params[:alert])
          if @alert.save
            respond_to do |format|        
              format.html { redirect_to root_path }
              format.js
            end
          end
        else
          @check = "not there"
          respond_to do |format|
            format.html { redirect_to root_path }
            format.js
          end
        end
      rescue OpenURI::HTTPError
        @check = "not there"
        respond_to do |format|
          format.html { redirect_to root_path }
          format.js
        end
      end
    else
      @check = "bad input"
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
