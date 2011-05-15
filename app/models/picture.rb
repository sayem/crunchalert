class Picture < ActiveRecord::Base
  has_many :alerts

  attr_accessible :content, :url

  content_regex = /[\w+\-.]/i
 
  validates_uniqueness_of :content

  validates :content, :presence   => true,
                      :format     => { :with => content_regex }

  def self.update(content, picture)
    begin
      pic = Picture.where(:content => content)
      unless pic == picture
        pic.url = picture
        pic.save
      end
    rescue NameError
      Picture.create(:content => content, :url => picture)
    end
  end
end
