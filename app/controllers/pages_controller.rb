class PagesController < ApplicationController
  def home
  end

  def register
    @user = User.new
    respond_to do | format |
      format.html
      format.xml { render :xml => @user }
    end
  end

  def login
    @user = User.new
    respond_to do | format |
      format.html
      format.xml { render :xml => @user }
    end
  end

  def account
  end
end
