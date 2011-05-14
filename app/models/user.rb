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
      alerts = Alert.find_all_by_user_id_and_freq(user.id, true)
      alerts.each do |alert|
        content_url = alert.content.gsub(/[\s\.]/,'-')
        doc = Nokogiri::HTML(open("http://crunchbase.com/#{alert.content_type}/#{content_url}"))
        milestones = doc.css('#milestones li').each do |milestone|
          if milestone.text =~ /#{yesterday}/
            text = milestone.at_css('.milestone_text').to_s.gsub(/\/#{alert.content_type}\/#{alert.content}/,"http://crunchbase.com/#{alert.content_type}/#{alert.content}").gsub(/<div class="milestone_text">|<\/div>/,'')
            crunchalerts.push("<p>#{alert.content.capitalize}</p>")            
            crunchalerts.push("<p>#{text}<p>")
          end
        end

        techcrunch = Date.today.prev_day.strftime("%Y/%m/%d")
        techmeme = Date.today.prev_day.strftime("%y%m%d")
        alertlinks = doc.css('.recently_link').each do |alertlink|
          if alertlink.to_s =~ /#{techcrunch}|#{techmeme}/
            links = alertlink.to_s.gsub(/<div class="recently_link">|<\/div>/,'')
            crunchalerts.push('News:')
            crunchalerts.push("<p>#{links}</p>")

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
        Mail.deliver do
          from 'CrunchAlert <admin@crunchalert.com>'
          to user.email
          subject 'CrunchAlert.com'

          html_part do
            content_type 'text/html; charset=UTF-8'
            body crunchalerts
          end
        end
      end
    end

    doc = Nokogiri::HTML(open('http://crunchbase.com'))
    news_alerts = Array.new
    milestones = doc.css('#milestones li').each do |milestone|
      if milestone.text =~ /#{yesterday}/
        text = milestone.at_css('.milestone_text').to_s.gsub(/\/company\//,'http://crunchbase.com/company/').gsub(/\/person\//,'http://crunchbase.com/person/').gsub(/\/financial-organization\//,'http://crunchbase.com/financial-organization/').gsub(/<div class="milestone_text">|<\/div>/,'')
        news_alerts.push("<p>#{text}</p>")
      end
    end

    if !news_alerts.empty?
      weekly_news = WeeklyNews.find_by_id('1')
      unless weekly_news.send(today)
        weekly_news.send("#{today}=", news_alerts)
        weekly_news.save
      end

      news = News.find_all_by_news(true)
      news.each do |news|
        id = news.user_id
        user = User.find_by_id(id)
        Mail.deliver do
          from 'CrunchAlert <admin@crunchalert.com>'
          to user.email
          subject 'CrunchAlert.com News'

          html_part do
            content_type 'text/html; charset=UTF-8'
            body news_alerts
          end
        end
      end  
    end
  end

  def self.weekly
    User.all.each do |user|
      days = ['sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat']
      alerts = Alert.find_all_by_user_id_and_freq(user.id, false)
      if !alerts.empty?
        weekly_total = Array.new
        alerts.each do |alert|
          weekly_alert = WeeklyAlert.find_by_content(alert.content) 
          alert.content = days.collect {|day| weekly_alert.send(day)}
          weekly_total.push("<p>#{alert.content}</p>")
        end
        if !weekly_total.empty?
          Mail.deliver do
            from 'CrunchAlert <admin@crunchalert.com>'
            to user.email
            subject 'CrunchAlert.com Weekly Alerts'

            html_part do
              content_type 'text/html; charset=UTF-8'
              body weekly_total
            end
          end
        end
      end

      if News.find_by_user_id_and_freq(user.id, false)
        weekly_news = WeeklyNews.find_by_id('1')
        weekly_digest = days.collect {|day| weekly_news.send(day)}
        if !weekly_digest.empty?
          Mail.deliver do
            from 'CrunchAlert <admin@crunchalert.com>'
            to user.email
            subject 'CrunchAlert.com Weekly News'

            html_part do
              content_type 'text/html; charset=UTF-8'
              body weekly_digest
            end
          end
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
