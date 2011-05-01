require 'nokogiri'
require 'open-uri'
require 'date'

begin
  doc = Nokogiri::HTML(open('http://www.crunchbase.com/company/ideeli'))
  milestones = doc.css('#milestones li').each do |milestone|

    yesterday = Date.today.prev_day.strftime("%m/%d/%y")
    yesterday.slice!(0) if yesterday.slice(0) == '0'



    if milestone.text =~ /#{yesterday}/
      text = milestone.at_css('.milestone_text').to_s().gsub(/\/company\/ideeli/,'http://crunchbase.com/company/ideeli').gsub(/<div class="milestone_text">|<\/div>/,'')
      puts text
    end
    


=begin   
    text = milestone.at_css('.milestone_text').to_s().gsub(/<div class="milestone_text">|<\/div>/,'')  
    meta = milestone.at_css('.meta_milestone').to_s().gsub(/<div class="meta_milestone">|<\/div>/,'')
    puts text 
    puts meta
=end

  end

rescue OpenURI::HTTPError
  puts "not there"
end
