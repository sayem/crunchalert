class Picture < ActiveRecord::Base
  has_many :alerts

  attr_accessible :content, :url

  content_regex = /[\w+\-.]/i
 
  validates_uniqueness_of :content

  validates :content, :presence   => true,
                      :format     => { :with => content_regex }

  def self.update(content, picture)
    begin
      pic = Picture.find_by_content(content)
      unless pic == picture
        pic = Picture.find_by_content(content)
        pic.url = picture
        pic.save
      end
    rescue NameError
      Picture.create(:content => content, :url => picture)
    end
  end
end
