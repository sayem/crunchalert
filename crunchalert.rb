require 'nokogiri'
require 'open-uri'

begin
  doc = Nokogiri::HTML(open('http://www.crunchbase.com/company/facebook'))
  milestones = doc.css('#milestones li').each do |milestone|
    text = milestone.at_css('.milestone_text').to_s().gsub(/<div class="milestone_text">|<\/div>/,'')  
    meta = milestone.at_css('.meta_milestone').to_s().gsub(/<div class="meta_milestone">|<\/div>/,'')
    puts text 
    puts meta
  end

rescue OpenURI::HTTPError
  puts "not there"
end


# need to also insert crunchbase.com w/in URLs
