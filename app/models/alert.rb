class Alert < ActiveRecord::Base
  belongs_to :user

  attr_accessible :content

  content_regex = /[\w+\-.]/i

  validates :user_id, :presence   => true
  validates :content, :presence   => true,
                      :format     => { :with => content_regex },
                      :uniqueness => { :case_sensitive => false }

  default_scope :order => 'alerts.created_at DESC'
end
