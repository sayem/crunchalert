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
    User.all.each do |user|
      crunchalerts = Array.new
      yesterday = Date.today.prev_day.strftime("%m/%d/%y")
      yesterday.slice!(0) if yesterday.slice(0) == '0'
      alerts = Alert.find_all_by_user_id_and_freq(user.id, true)
      alerts.each do |alert|
        content_url = alert.content.gsub(/[\s\.]/,'-')
        doc = Nokogiri::HTML(open("http://crunchbase.com/#{alert.content_type}/#{content_url}"))
        milestones = doc.css('#milestones li').each do |milestone|
          if milestone.text =~ /#{yesterday}/
            text = milestone.at_css('.milestone_text').to_s().gsub(/\/#{alert.content_type}\/#{alert.content}/,"http://crunchbase.com/#{alert.content_type}/#{alert.content}").gsub(/<div class="milestone_text">|<\/div>/,'')


            crunchalerts.push("<p>#{alert.content.capitalize}</p>")            
            crunchalerts.push("<p>#{text}<p>")
          end
        end

        techcrunch = Date.today.prev_day.strftime("%Y/%m/%d")
        techmeme = Date.today.prev_day.strftime("%y%m%d")
        alertlinks = doc.css('.recently_link').each do |alertlink|
          if alertlink.to_s() =~ /#{techcrunch}|#{techmeme}/
            links = alertlink.to_s().gsub(/<div class="recently_link">|<\/div>/,'')


            crunchalerts.push('News:')
            crunchalerts.push("<p>#{links}</p>")
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






      news = News.find_all_by_user_id_and_freq(user.id, true)
      if !news.empty?

=begin

- EDIT once crunchbase has some milestones up on the homepage 
- order funding, acq, products/companies
- separate email

=end      

      end




    end
  end




  def self.weekly

=begin

- store daily crawls of alerts/news and crunchbase front page into DB 
- send mail of all the saved feeds/links since one week and empty DB

=end

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
