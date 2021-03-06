require 'open-uri'
require 'nokogiri'

class AlertsController < ApplicationController
  before_filter :authenticate
  before_filter :authorized_user, :only => :destroy

  def crunchbase
    content = params[:crunchbase].downcase.gsub(/[\s\.]/,'-')
    type = params[:cbase]
    if content =~ /[\w+\-]/i
      begin
        doc = Nokogiri::HTML(open("http://crunchbase.com/#{type}/#{content}"))
        milestones = doc.css('#milestones').text.strip!
        error = doc.css('td').text.strip!
        logo = doc.css('#company_logo img').to_s()
        pic = logo.split('"');
        if milestones
          picurl = pic[1]
          picture = "<img src=#{picurl} id='form-img' />"
          link = "<a href=http://crunchbase.com/#{type}/#{content} target=_blank>#{params[:crunchbase]}</a>"
          profile = [picurl, picture, link]
          render :json => profile
        elsif error == "The page you are looking for is temporarily unavailable.\nPlease try again later."
          alert = "connection error"
          render :json => alert
        else
          alert = "error"
          render :json => alert
        end
      rescue OpenURI::HTTPError
        alert = "error"
        render :text => alert
      end
    else
      alert = "regex error"
      render :text => alert
    end
  end
  
  def crunchbaseurl
    url = params[:url]
    if url =~ /^(http:\/\/)(www\.)?(crunchbase.com\/)(company|person|financial-organization)\/([\w+\-]+)(\/)?$/
      begin
        doc = Nokogiri::HTML(open(url))
        milestones = doc.css('#milestones').text.strip!
        error = doc.css('td').text.strip!
        logo = doc.css('#company_logo img').to_s()
        pic = logo.split('"');
        if milestones
          picurl = pic[1]
          picture = "<img src=#{picurl} id='form-img' />"
          if url.slice(-1) == '/'
            url.slice!(-1)
          end
          name = url.scan(/\w+$/)[0]
          type = url.scan(/\/\w+\//)[0].delete('/')
          profile = [picurl, picture, name, type]
          render :json => profile
        elsif error == "The page you are looking for is temporarily unavailable.\nPlease try again later."
          alert = "connection error"
          render :text => alert
        else
          alert = "error"
          render :text => alert
        end
      rescue OpenURI::HTTPError
        alert = 'error'
        render :text => alert
      end
    else
      alert = "regex error"
      render :text => alert
    end
  end

  def crunchalert
    content = params[:content].downcase
    alert = Alert.where(:content => content)
    if alert.empty?
      if params[:freq] == 'false' && !WeeklyAlert.find_by_content(content)
        WeeklyAlert.create(:content => content)
      end
    end
  
    add_alert = Alert.new(:content => content, :content_type => params[:type], :user_id => current_user[:id], :news => params[:news], :freq => params[:freq])
    if add_alert.save
      Picture.update(content, params[:pic])
      redirect_to root_path
    else
      render :text => add_alert.errors[:content]
    end
  end

  def prefs
    prefs = Alert.find_by_user_id_and_content(current_user[:id], params[:content])
    freq = prefs.freq
    news = prefs.news
    alert_prefs = [freq, news]
    render :json => alert_prefs
  end

  def edit
    Alert.edit(params[:content].downcase, params[:freq], params[:news], current_user[:id])
    redirect_to root_path
  end

  def remove
    Alert.remove(params[:content].downcase, current_user[:id])
    redirect_to root_path
  end

  private

    def authorized_user
      @alert = Alert.find(params[:id])
      redirect_to root_path unless current_user?(@alert.user)
    end
end
