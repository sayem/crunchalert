require 'nokogiri'
require 'open-uri'

begin

# need to edit once crunchbase has some milestones


  doc = Nokogiri::HTML(open('http://www.crunchbase.com'))
  milestones = doc.css('#milestones li').each do |milestone|
    text = milestone.at_css('.milestone_text').to_s().gsub(/<div class="milestone_text">|<\/div>/,'') 
    meta = milestone.at_css('.meta_milestone').to_s().gsub(/<div class="meta_milestone">|<\/div>/,'')
    puts text 
    puts meta
  end

rescue OpenURI::HTTPError
  puts "not there"
end


# insert crunchbase.com into the URLs
