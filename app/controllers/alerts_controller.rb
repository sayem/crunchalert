require 'open-uri'
require 'nokogiri'

class AlertsController < ApplicationController
  before_filter :authenticate
  before_filter :authorized_user, :only => :destroy

  def crunchbase
    content = params[:crunchbase].gsub(/[\s\.]/,'-')
    type = params[:cbase]
    if content =~ /[\w+\-]/i
      begin
        doc = Nokogiri::HTML(open("http://crunchbase.com/#{type}/#{content}"))
        milestones = doc.css('#milestones').text.strip!
        error = doc.css('td').text.strip!
        logo = doc.css('#company_logo img').to_s()
        pic = logo.split('"');
        if milestones
          check = "exists"
          picurl = pic[1]
          picture = "<img src=#{picurl}></img>"
          link = "<a href=http://crunchbase.com/#{type}/#{content} target=_blank>#{params[:crunchbase]}</a>"
          profile = [picurl, picture, link]        
          render :json => profile
        elsif error == "The page you are looking for is temporarily unavailable.\nPlease try again later."
          check = "crunchbase is unavailable"
          render :json => check
        else
          check = "not there"
          render :json => check
        end
      rescue OpenURI::HTTPError
        check = "not there"
        render :json => check
      end
    else
      check = "bad regex input"
      render :json => check
    end
  end

  def crunchalert
    Alert.create(:content => params[:content].downcase, :user_id => current_user[:id], :news => params[:news], :freq => params[:freq])
    begin
      pic = Picture.find_by_content(params[:content])
      unless pic == params[:pic]
        pic = Picture.find_by_content(params[:content])
        pic.url = params[:pic]
        pic.save
      end
    rescue NameError
      Picture.create(:content => params[:content].downcase, :url => params[:pic])
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
