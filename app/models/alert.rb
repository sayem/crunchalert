class Alert < ActiveRecord::Base
  belongs_to :user

  has_many :users

  attr_accessible :content, :user_id, :freq, :news

  content_regex = /[\w+\-.]/i

  validates :user_id, :presence   => true

  validates_uniqueness_of :content, :scope => :user_id, :case_sensitive => false

  validates :content, :presence   => true,
                      :format     => { :with => content_regex }

  default_scope :order => 'alerts.created_at DESC'
end
