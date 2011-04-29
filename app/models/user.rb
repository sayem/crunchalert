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

  def self.cron
    require 'mail'
    require 'nokogiri'
    require 'open-uri'
    User.all.each do |user|

=begin

- (1) alerts email, (2) news email for each user ---> focus on daily first
- (1) for each alert/pref get parsed milestones and insert and set entire thing
- (2) news/pref --- order by funding, acq, products/companies and send

- then put in filters for current date

- parse for current date rules (daily first)
- subst all crunchbase links with crunchbase in the URL
- format for html email ---- and make it just mail.deliver with html and text part



current date - 1

date with spaces before and after

techcrunch.com/date

techmeme.com/date

=end

      crunchalerts = Array.new
      alerts = Alert.find_all_by_user_id_and_freq(user.id, true)
      alerts.each do |alert|

        crunchalerts.push(alert.content)

        content_url = alert.content.gsub(/[\s\.]/,'-')
        doc = Nokogiri::HTML(open("http://www.crunchbase.com/#{alert.content_type}/#{content_url}"))

        milestones = doc.css('#milestones li').each do |milestone|
          text = milestone.at_css('.milestone_text').to_s().gsub(/<div class="milestone_text">|<\/div>/,'')  
          meta = milestone.at_css('.meta_milestone').to_s().gsub(/<div class="meta_milestone">|<\/div>/,'')


          crunchalerts.push(text)
          crunchalerts.push(meta)
        end


        crunchalerts.push('NEWS')

        news = doc.css('.col3_content').each do |news|
          links = news.css('.recently_link').to_s().gsub(/<div class="recently_link">|<div class="recently_desc">|<\/div>/,'')


          crunchalerts.push(links)
        end


      end              
      puts crunchalerts


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
