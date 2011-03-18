
=begin

require 'open-uri'
require 'nokogiri'

doc = Nokogiri::HTML(open('http://www.crunchbase.com/company/bit-ly'))
doc.css('li').each do |link|
  puts link.content
end

=end


=begin

# Milestones Added Last 24 hours

doc = Nokogiri::HTML(open('http://www.crunchbase.com'))
doc.css('li').each do |link|
  puts link.content
end

=end

