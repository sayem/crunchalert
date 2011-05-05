class WeeklyAlert < ActiveRecord::Base
  attr_accessible :content, :weekly_data
  validates :content, :presence   => true,
                      :uniqueness  => true



end
