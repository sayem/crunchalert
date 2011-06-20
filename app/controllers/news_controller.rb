class NewsController < ApplicationController
  def update
    news = News.find_by_user_id(current_user[:id])
    if news
      news.update_attributes(:news => params[:news], :freq => params[:freq])
      redirect_to root_path
    else
      News.create(:user_id => current_user[:id], :news => params[:news], :freq => params[:freq])
      redirect_to root_path
    end
  end
  
  def prefs
    prefs = News.find_by_user_id(current_user[:id])
    if prefs
      news = prefs.news
      freq = prefs.freq
      news_prefs = [news, freq]
    else 
      news_prefs = ['undefined']
    end
    render :json => news_prefs
  end
end
