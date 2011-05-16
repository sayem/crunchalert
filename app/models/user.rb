require 'date'
require 'mail'
require 'nokogiri'
require 'open-uri'

class User < ActiveRecord::Base
  validates_presence_of     :email
  validates_uniqueness_of   :email

  attr_accessor  :password_confirmation

  validates_confirmation_of  :password

  validate  :password_non_blank

  attr_protected  :id, :salt

  has_many :alerts, :dependent => :destroy
  has_many :news, :dependent => :destroy

  def self.authenticate(email, password)
    user = self.find_by_email(email)
    if user
      expected_password = encrypted_password(password, user.salt)
      if user.hashed_password != expected_password
        user = nil
      end
    end
    user
  end

  def password
    @password
  end

  def password=(pwd)
    @password = pwd
    return if pwd.blank?
    create_new_salt
    self.hashed_password = User.encrypted_password(self.password, self.salt)
  end

  def self.authenticate_with_salt(id, cookie_salt)
    user = find_by_id(id)
    (user && user.salt == cookie_salt) ? user : nil
  end

  def send_new_password
    new_pass = User.random_string(10)
    self.password = self.password_confirmation = new_pass
    self.save
    UserMailer.deliver_forgot_password(self.email, new_pass)
  end

  def self.daily
    month = Date.today.prev_day.month.to_s
    day = Date.today.prev_day.day.to_s
    year = Date.today.prev_day.year.to_s
    year.slice!(0..1)
    yesterday = month << '/' << day << '/' << year
    today = Date.today.strftime("%a").downcase

    User.all.each do |user|
      crunchalerts = Array.new
      alerts = Alert.where(:user_id => user.id, :freq => true)
      alerts.each do |alert|
        content_url = alert.content.gsub(/[\s\.]/,'-')
        doc = Nokogiri::HTML(open("http://crunchbase.com/#{alert.content_type}/#{content_url}"))
        milestones = doc.css('#milestones li').each do |milestone|
          alert_milestones = Array.new
          if milestone.text =~ /#{yesterday}/
            text = milestone.at_css('.milestone_text').to_s.gsub(/\/#{alert.content_type}\/#{alert.content}/,"http://crunchbase.com/#{alert.content_type}/#{alert.con
tent}").gsub(/<div class="milestone_text">|<\/div>/,'')
            alert_milestones.push(text)
          end
          if !alert_milestones.empty?
            alert_milestones.insert(0, "<b>#{alert.content.capitalize}</b>")
            crunchalerts = crunchalerts + alert_milestones
          end
        end

        techcrunch = Date.today.prev_day.strftime("%Y/%m/%d")
        techmeme = Date.today.prev_day.strftime("%y%m%d")
        alertlinks = doc.css('.recently_link').each do |alertlink|
          if alertlink.to_s =~ /#{techcrunch}|#{techmeme}/
            links = alertlink.to_s.gsub(/<div class="recently_link">|<\/div>/,'')
            crunchalerts.push("<b>#{alert.content.capitalize} News:</b>")
            crunchalerts.push(links)

            weekly_alert = WeeklyAlert.find_by_content(alert.content)
            if weekly_alert
              unless weekly_alert.send(today)   
                if crunchalerts.empty?
                  crunchalerts = nil
                end
                weekly_alert.send("#{today}=", crunchalerts)
                weekly_alert.save
              end
            end
          end
        end
      end

      if !crunchalerts.empty?
        DailyMailer.deliver_alerts(user.email, crunchalerts)
      end
    end

    doc = Nokogiri::HTML(open('http://crunchbase.com'))
    news_alerts = Array.new
    milestones = doc.css('#milestones li').each do |milestone|
      if milestone.text =~ /#{yesterday}/
        text = milestone.at_css('.milestone_text').to_s.gsub(/\/company\//,'http://crunchbase.com/company/').gsub(/\/person\//,'http://crunchbase.com/person/').gsub(/\/financial-organization\//,'http://crunchbase.com/financial-organization/').gsub(/\/product\//,'http://crunchbase.com/product/').gsub(/\/service-provider\//,'http://crunchbase.com/service-provider/').gsub(/<div class="milestone_text">|<\/div>/,'')
        news_alerts.push(text)
      end
    end

    if !news_alerts.empty?
      weekly_news = WeeklyNews.find_by_id('1')
      unless weekly_news.send(today)
        weekly_news.send("#{today}=", news_alerts)
        weekly_news.save
      end

      news = News.where(:news => true)
      news.each do |news|
        id = news.user_id
        user = User.find_by_id(id)
        DailyMailer.deliver_news(user.email, news_alerts)
      end  
    end
  end

  def self.weekly
    User.all.each do |user|
      days = ['sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat']
      alerts = Alert.where(:user_id => user.id, :freq => false)
      if !alerts.empty?
        weekly_total = Array.new
        alerts.each do |alert|
          weekly_alert = WeeklyAlert.find_by_content(alert.content) 
          alert.content = days.collect {|day| weekly_alert.send(day)}
          weekly_total.push(alert.content)
        end
        if !weekly_total.empty?
          WeeklyMailer.deliver_alerts(user.email, weekly_total)
        end
      end

      if News.where(:user_id => user.id, :freq => false)
        weekly_news = WeeklyNews.find_by_id('1')
        weekly_digest = days.collect {|day| weekly_news.send(day)}
        if !weekly_digest.empty?
          WeeklyMailer.deliver_news(user.email, weekly_digest)
        end
      end
    end
  end

  private

    def password_non_blank
      errors.add(:password, "Missing password") if hashed_password.blank?
    end

    def create_new_salt
      self.salt = BCrypt::Engine.generate_salt
    end

    def self.encrypted_password(password, salt)
      BCrypt::Engine.hash_secret(password, salt)
    end

    def self.random_string(len)
      chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
      newpass = ""
      1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }
      return newpass
    end
end
