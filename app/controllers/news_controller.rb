class NewsController < ApplicationController
  def update
    News.create(:user_id => current_user[:id], :news => params[:news], :freq => params[:freq])
  end
end
