class PagesController < ApplicationController
  def home
    if signed_in?
      @alert = Alert.new
    end
  end
end
