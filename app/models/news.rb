class News < ActiveRecord::Base
  belongs_to :user

  attr_accessible :freq, :news

  validates :user_id, :presence   => true,
                      :uniqueness  => true
end
