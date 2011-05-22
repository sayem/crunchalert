class PagesController < ApplicationController
  def home
    require 'date'
    require 'htmlentities'
    coder = HTMLEntities.new
    yesterday = Date.today.prev_day.strftime("%a").downcase
    news = WeeklyNews.find_by_id('1').send(yesterday).to_s.split(/\"/)
    news.collect! {|x| coder.decode(x)}
    news.collect! {|x| x.gsub(/--- /, '').gsub(/\n- /, '').gsub(/\\xE2\\x80\\x94/,'&mdash;')}
    @news = news

    alert_count = Alert.group('content').count
    popular = alert_count.sort {|a,b| -1*(a[1]<=>b[1])}
    popular.slice!(5..-1)
    @popular = popular

    @recent = Alert.group('content').order('created_at').limit('10')

    if signed_in?
      @alerts = Alert.where(:user_id => current_user[:id])
    end
  end
end
