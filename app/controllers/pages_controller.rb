class PagesController < ApplicationController
  def home
    redirect_to current_user, and return if signed_in?
  end
end
