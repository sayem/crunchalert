class Picture < ActiveRecord::Base
  has_many :alerts

  attr_accessible :content, :url

  content_regex = /[\w+\-.]/i
 
  validates_uniqueness_of :content

  validates :content, :presence   => true,
                      :format     => { :with => content_regex }

end
