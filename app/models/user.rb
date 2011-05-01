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

=begin

- then compile into user.rb and set emails


- clean up all HTML spacing and shit
- then weekly cron
- then work on newsfeed portion daily/weekly ---- put in alongside user/alert loop for daily/weekly (order by funding, acq, products/companies) 

---> then start working on other comp to work on design 

=end
  
      crunchalerts = Array.new
      yesterday = Date.today.prev_day.strftime("%m/%d/%y")
      yesterday.slice!(0) if yesterday.slice(0) == '0'
      alerts = Alert.find_all_by_user_id_and_freq(user.id, true)
      alerts.each do |alert|


        crunchalerts.push(alert.content)


        content_url = alert.content.gsub(/[\s\.]/,'-')
        doc = Nokogiri::HTML(open("http://crunchbase.com/#{alert.content_type}/#{content_url}"))
        milestones = doc.css('#milestones li').each do |milestone|
          if milestone.text =~ /#{yesterday}/
            text = milestone.at_css('.milestone_text').to_s().gsub(/\/#{alert.content_type}\/#{alert.content}/,"http://crunchbase.com/#{alert.content_type}/#{alert.content}").gsub(/<div class="milestone_text">|<\/div>/,'')


            crunchalerts.push(text)
          end
        end




        crunchalerts.push('NEWS')
        techcrunch = Date.today.prev_day.strftime("%Y/%m/%d")
        techmeme = Date.today.prev_day.strftime("%y%m%d")

        news = doc.css('.recently_link').each do |news|
          if news.to_s() =~ /#{techcrunch}|#{techmeme}/
            links = news.to_s().gsub(/<div class="recently_link">|<\/div>/,'')


            crunchalerts.push(links)
          end
        end

      end              
      puts crunchalerts
      puts techcrunch
      puts techmeme


=begin
        mail = Mail.new do
          from 'CrunchAlert <admin@crunchalert.com>'
          to user.email
          subject 'whatsup'
          body alert.content
        end
        mail.deliver!
=end

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
