class WeeklyAlert < ActiveRecord::Base
  attr_accessible :content
  validates :content, :presence => true, :uniqueness => true
  serialize :sun
  serialize :mon
  serialize :tue
  serialize :wed
  serialize :thu
  serialize :fri
  serialize :sat
end
