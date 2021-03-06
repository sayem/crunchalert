require 'date'
require 'mail'
require 'nokogiri'
require 'open-uri'
require 'htmlentities'

class User < ActiveRecord::Base
  attr_accessor  :password_confirmation
  attr_protected  :id, :salt

  has_many :alerts, :dependent => :destroy
  has_many :news, :dependent => :destroy

  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates :email, :presence   => true,
                    :format     => { :with => email_regex },
                    :uniqueness => { :case_sensitive => false }

  validates :password, :presence => true,
                       :confirmation => true,
                       :length => { :within => 6..40 }

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
    coder = HTMLEntities.new
    crunchalerts = Array.new

    User.find_each do |user|
      alerts = Alert.where(:user_id => user.id, :freq => true)
      alerts.each do |alert|
        content_url = alert.content.gsub(/[\s\.]/,'-')
        doc = Nokogiri::HTML(open("http://crunchbase.com/#{alert.content_type}/#{content_url}"))
        alert_milestones = Array.new
        milestones = doc.css('#milestones li').each do |milestone|
          if milestone.text =~ /#{yesterday}/
            text = milestone.at_css('.milestone_text').to_s.gsub(/\/company\//,'http://crunchbase.com/company/').gsub(/\/person\//,'http://crunchbase.com/person/').gsub(/\/financial-organization\//,'http://crunchbase.com/financial-organization/').gsub(/\/product\//,'http://crunchbase.com/product/').gsub(/\/service-provider\//,'http://crunchbase.com/service-provider/').gsub(/<div class="milestone_text">|<\/div>/,'')
            alert_milestones.push(text)
          end
        end

        unless alert.content.split[1]
          name = alert.content.capitalize
        else
          name = Array.new
          alert.content.split.each do |x|
            name.push(x.capitalize)
          end
          name = name.join(' ')
        end

        if !alert_milestones.empty?
          alert_milestones.insert(0, "<br /><b>#{name}</b>")
          crunchalerts = crunchalerts + alert_milestones
        end

        alert_news = Array.new
        if alert.news
          techcrunch = Date.today.prev_day.strftime("%Y/%m/%d")
          techmeme = Date.today.prev_day.strftime("%y%m%d")
          alertlinks = doc.css('.recently_link').each do |alertlink|
            if alertlink.to_s =~ /#{techcrunch}|#{techmeme}/
              links = alertlink.to_s.gsub(/<div class="recently_link">|<\/div>/,'')
              alert_news.push(links)
            end
          end
          if !alert_news.empty?
            alert_news.insert(0, "<br /><b>#{name} News</b>")
            crunchalerts = crunchalerts + alert_news
          end
        end
             
        weekly_alert = WeeklyAlert.find_by_content(alert.content)
        if weekly_alert
          weekly_milestones = alert_milestones
          weekly_news = alert_news
          weekly_crunchalerts = Array.new

          unless weekly_alert.send(today)
            if weekly_milestones.empty?
              weekly_milestones = nil
            else
              weekly_milestones.slice!(0)
              weekly_milestones.collect! {|x| coder.encode(x.squish)}
            end
            if weekly_news.empty?
              weekly_news = nil
            else
              weekly_news.slice!(0)
              weekly_news.collect! {|x| coder.encode(x.squish)}
            end
  
            input_weely = Array.new;
            input_weekly = [weekly_milestones, weekly_news];
            weekly_alert.send("#{today}=", input_weekly)
            weekly_alert.save
          end
        end
      end
      if !crunchalerts.empty?
        DailyMailer.deliver_alerts(user.email, crunchalerts)
        crunchalerts.clear
      end
    end

    weeklies = WeeklyAlert.find_each do |weekly|
      alerts = Alert.where(:content => weekly.content)
      check_alerts = Array.new
      alerts.each do |alert|
        check_alerts.push(alert.freq)
      end
      check_alerts = check_alerts.uniq
      if check_alerts.length == 1
        content_url = weekly.content.gsub(/[\s\.]/,'-')
        content_type = Alert.find_by_content(weekly.content).content_type
        doc = Nokogiri::HTML(open("http://crunchbase.com/#{content_type}/#{content_url}"))
        alert_milestones = Array.new
        milestones = doc.css('#milestones li').each do |milestone|
          if milestone.text =~ /#{yesterday}/
            text = milestone.at_css('.milestone_text').to_s.gsub(/\/company\//,'http://crunchbase.com/company/').gsub(/\/person\//,'http://crunchbase.com/person/').gsub(/\/financial-organization\//,'http://crunchbase.com/financial-organization/').gsub(/\/product\//,'http://crunchbase.com/product/').gsub(/\/service-provider\//,'http://crunchbase.com/service-provider/').gsub(/<div class="milestone_text">|<\/div>/,'')
            alert_milestones.push(text)
          end
        end

        techcrunch = Date.today.prev_day.strftime("%Y/%m/%d")
        techmeme = Date.today.prev_day.strftime("%y%m%d")
        alert_news = Array.new
        alertlinks = doc.css('.recently_link').each do |alertlink|
          if alertlink.to_s =~ /#{techcrunch}|#{techmeme}/
            links = alertlink.to_s.gsub(/<div class="recently_link">|<\/div>/,'')
            alert_news.push(links)
          end
        end

        if alert_milestones.empty?
          alert_milestones = nil
        else 
          alert_milestones.collect! {|x| coder.encode(x.squish)}
        end
        if alert_news.empty?
          alert_news = nil
        else
          alert_news.collect! {|x| coder.encode(x.squish)}
        end

        input_weekly = [alert_milestones, alert_news]
        weekly.send("#{today}=", input_weekly)
        weekly.save
      end
    end

    doc = Nokogiri::HTML(open('http://crunchbase.com'))
    news_alerts = Array.new
    acquisitions = Array.[]("<br /><b>Acquisitions</b>")
    fundings = Array.[]("<br /><b>Fundings</b>")
    procos = Array.[]("<br /><b>Products and Companies</b>")

    milestones = doc.css('#milestones li').each do |milestone|
      if milestone.text =~ /#{yesterday}/
        text = milestone.at_css('.milestone_text').to_s.gsub(/\/company\//,'http://crunchbase.com/company/').gsub(/\/person\//,'http://crunchbase.com/person/').gsub(/\/financial-organization\//,'http://crunchbase.com/financial-organization/').gsub(/\/product\//,'http://crunchbase.com/product/').gsub(/\/service-provider\//,'http://crunchbase.com/service-provider/').gsub(/<div class="milestone_text">|<\/div>/,'')
        if milestone.to_s =~ /milestone_acquisition/
          acquisitions.push(text)
        elsif milestone.to_s =~ /milestone_funding_round/
          fundings.push(text)
        else
          procos.push(text)
        end
      end
    end

    input = Array.new
    input = [acquisitions, fundings, procos]
    input.delete_if {|x| x.length == 1}
    news_alerts = input.flatten

    if !news_alerts.empty?
      news = News.where(:news => true, :freq => true)
      news.each do |news|
        id = news.user_id
        user = User.find_by_id(id)
        DailyMailer.deliver_news(user.email, news_alerts)
      end
      weekly_news = WeeklyNews.find_by_id('1')
      unless weekly_news.send(today)
        time = Time.new
        day = time.strftime("%A, %b #{time.day.ordinalize}")
        news_alerts.insert(0, "<br /><u>#{day}</u>")
        news_alerts.collect! {|x| coder.encode(x.squish)}
        weekly_news.send("#{today}=", news_alerts)
        weekly_news.save
      end
    end
  end

  def self.weekly
    coder = HTMLEntities.new
    User.find_each do |user|
      days = ['sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat']
      alerts = Alert.where(:user_id => user.id, :freq => false)
      if !alerts.empty?
        weekly_total = Array.new
        alerts.each do |alert|
          unless alert.content.split[1]
            name = alert.content.capitalize
          else
            name = Array.new
            alert.content.split.each do |x|
              name.push(x.capitalize)
            end
            name = name.join(' ')
          end

          weekly_alert = WeeklyAlert.find_by_content(alert.content)
          alert.content = days.collect {|day| weekly_alert.send(day)}
          alert.content = alert.content.flatten
              
          if alert.news
            alert.content = alert.content.compact
          else 
            alert.content.each_index {|x|
              if x%2 != 0
                alert.content[x] = nil
              end
            }
            alert.content = alert.content.compact
          end

          if !alert.content.empty?
            alert.content.insert(0, "<br /><b>#{name}</b>")
            weekly_total.push(alert.content)
          end
        end
        if !weekly_total.empty? 
          weekly_total = weekly_total.flatten
          weekly_total.collect! {|x| coder.decode(x)}
          WeeklyMailer.deliver_alerts(user.email, weekly_total)
        end
      end

      if News.find_by_user_id_and_freq(user.id, false)
        weekly_news = WeeklyNews.find_by_id('1')
        weekly_digest = days.collect {|day| weekly_news.send(day).to_s.split(/\"/)}
        weekly_digest = weekly_digest.compact
   
        if !weekly_digest.empty?
          weekly_digest = weekly_digest.flatten
          weekly_digest.collect! {|x| coder.decode(x)}
          weekly_digest.collect! {|x| x.gsub(/--- /, '').gsub(/\n- /, '').gsub(/\\xE2\\x80\\x94/,'&mdash;')}
          WeeklyMailer.deliver_news(user.email, weekly_digest)
        end
      end
    end

    WeeklyAlert.all.each do |x|
      if Alert.where(:content => x.content).empty?
        x.delete
      end
    end

    Picture.all.each do |x|
      if Alert.where(:content => x.content).empty?
        x.delete
      end
    end
    
    WeeklyAlert.update_all(:sun => nil, :mon => nil, :tue => nil, :wed => nil, :thu => nil, :fri => nil, :sat => nil)
    weekly_news = WeeklyNews.find_by_id('1')    
    yesterday = Date.today.prev_day.strftime("%a").downcase
    yesterday_news = weekly_news.send(yesterday)
    WeeklyNews.update_all(:sun => nil, :mon => nil, :tue => nil, :wed => nil, :thu => nil, :fri => nil, :sat => nil)
    weekly_news.send("#{yesterday}=", yesterday_news)
    weekly_news.save
  end

  private

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
