class NewsController < ApplicationController
  def update
    news = News.find_by_user_id(current_user[:id])
    news.update_attributes(:news => params[:news], :freq => params[:freq])
    redirect_to root_path
  end
  
  def prefs
    prefs = News.find_by_user_id(current_user[:id])
    news = prefs.news
    freq = prefs.freq
    news_prefs = [news, freq]
    render :json => news_prefs
  end
end
