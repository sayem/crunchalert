class Picture < ActiveRecord::Base
  has_many :alerts
  attr_accessible :content, :url

  content_regex = /[\w+\-.]/i
  validates_uniqueness_of :content
  validates :content, :presence => true,
                      :format => { :with => content_regex }

  def self.update(content, picture)
    if Picture.find_by_content(content)
      unless pic == picture
        pic.url = picture
        pic.save
      end
    else
      Picture.create(:content => content, :url => picture)
    end
  end
end
