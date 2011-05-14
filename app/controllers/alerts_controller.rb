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
        render :text => check
      end
    else
      check = "bad regex input"
      render :text => check
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
          check = "exists"
          picurl = pic[1]
          picture = "<img src=#{picurl}></img>"
          if url.slice(-1) == '/'
            url.slice!(-1)
          end
          name = url.scan(/\w+$/)[0]
          type = url.scan(/\/\w+\//)[0].delete('/')
          profile = [picurl, picture, name, type]
          render :json => profile
        elsif error == "The page you are looking for is temporarily unavailable.\nPlease try again later."
          check = "crunchbase is unavailable"
          render :text => check
        else
          check = "not there"
          render :text => check
        end
      rescue OpenURI::HTTPError
        check = 'not there'
        render :text => check
      end
    else
      check = "bad regex input"
      render :text => check
    end
  end

  def crunchalert
    Alert.crunchalert(params[:content].downcase, params[:type], params[:news], params[:freq], current_user[:id])
    Picture.update(params[:content].downcase, params[:pic])
  end

  def edit
    Alert.edit(params[:content].downcase, params[:freq], params[:news], current_user[:id])
  end

  def remove
    Alert.remove(params[:content].downcase, current_user[:id])
  end

  private

    def authorized_user
      @alert = Alert.find(params[:id])
      redirect_to root_path unless current_user?(@alert.user)
    end
end
