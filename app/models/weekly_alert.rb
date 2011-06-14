class WeeklyAlert < ActiveRecord::Base
  attr_accessible :content, :weekly_data
  validates :content, :presence => true, :uniqueness => true
  serialize :sun
  serialize :mon
  serialize :tue
  serialize :wed
  serialize :thu
  serialize :fri
  serialize :sat
end
