class PagesController < ApplicationController
  def home
    if signed_in?
      @alerts = Alert.find_all_by_user_id(current_user[:id])
    end
  end
end
