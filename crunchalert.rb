require 'nokogiri'
require 'open-uri'
require 'date'

begin
  doc = Nokogiri::HTML(open('http://www.crunchbase.com/company/nestio'))
  milestones = doc.css('#milestones li').each do |milestone|


    month = Date.today.prev_day.month.to_s()
    day = Date.today.prev_day.day.to_s()
    year = Date.today.prev_day.year.to_s()
    year.slice!(0..1)
    yesterday = month << '/' << day << '/' << year


    if milestone.text =~ /#{yesterday}/
      text = milestone.at_css('.milestone_text').to_s().gsub(/\/company\/nestio/,'http://crunchbase.com/company/nestio').gsub(/<div class="milestone_text">|<\/div>/,'')
      puts text
    end




  end

rescue OpenURI::HTTPError
  puts "not there"
end
