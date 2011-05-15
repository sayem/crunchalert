class PagesController < ApplicationController
  def home
    if signed_in?
      @alerts = Alert.where(:user_id => current_user[:id])
    end
  end
end
