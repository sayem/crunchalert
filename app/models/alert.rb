class Alert < ActiveRecord::Base
  belongs_to :user

  attr_accessible :content, :content_type, :user_id, :freq, :news

  content_regex = /[\w+\-.]/i

  validates :user_id, :presence   => true

  validates_uniqueness_of :content, :scope => :user_id

  validates :content, :presence   => true,
                      :format     => { :with => content_regex }

  default_scope :order => 'alerts.created_at DESC'

  def self.crunchalert(content, type, news, freq, user)
    alert = Alert.where(:content => content)
    unless alert
      if freq == 'false'
        if !WeeklyAlert.where(:content => content).exists?
          WeeklyAlert.create(:content => content)
        end
      end
    end
    add_alert = Alert.new(:content => content, :content_type => type, :user_id => user, :news => news, :freq => freq)
    if add_alert.save
      Alert.create(:content => content, :content_type => type, :user_id => user, :news => news, :freq => freq)   
    else


      format.json { render :json => add_alert.errors } # 

      
    end
  end

  def self.edit(content, freq, news, user)
    alert = Alert.find_by_content_and_user_id(content, user)
    alert.update_attributes(:freq => freq, :news => news)
    if freq == 'true'
      check_weekly = Alert.where(:content => content, :freq => false)
      weekly = WeeklyAlert.find_by_content(content)
      if check_weekly.empty? && weekly
        weekly.delete
      end
    else
      weekly_alert = WeeklyAlert.find_by_content(content)
      if !weekly_alert
        WeeklyAlert.create(:content => content)
      end
    end
  end

  def self.remove(content, user)
    delete_alert = Alert.find_by_content_and_user_id(content, user)
    delete_alert.delete

    check_alert = Alert.where(:content => content)
    weekly_alert = WeeklyAlert.find_by_content(content)
    alert_pic = Picture.find_by_content(content)
    if check_alert.empty? 
      if weekly_alert
        weekly_alert.delete
      end
      if alert_pic
        alert_pic.delete
      end
    end
  end
end
