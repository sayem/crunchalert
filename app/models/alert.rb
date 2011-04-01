class Alert < ActiveRecord::Base
  attr_acccessible :content

  belongs_to :user

  validates :content, :presence => true
  validates :user_id, :presence => true

  default_scope :order => 'alerts.created_at DESC'
end
