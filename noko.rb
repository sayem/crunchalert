
require 'open-uri'
require 'nokogiri'

begin
  doc = Nokogiri::HTML(open('http://www.crunchbase.com/company/facebook'))
  puts "exists"

rescue OpenURI::HTTPError 
  puts "not there"
end



=begin

if doc?
  puts "exists"
else
  puts "not there"
end

=end

=begin

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

