require 'nokogiri'
require 'open-uri'
require 'date'

begin
  doc = Nokogiri::HTML(open('http://crunchbase.com'))

  month = Date.today.month.to_s()
  day = Date.today.day.to_s()
  year = Date.today.year.to_s()
  year.slice!(0..1)
  today = month << '/' << day << '/' << year

  milestones = doc.css('#milestones li').each do |milestone|

=begin
    yesterday = Date.today.prev_day.strftime("%m/%d/%y")
    yesterday.slice!(0) if yesterday.slice(0) == '0'
=end

    if milestone.text =~ /#{today}/
      text = milestone.at_css('.milestone_text').to_s().gsub(/\/company\//,'http://crunchbase.com/company/').gsub(/\/person\//,'http://crunchbase.com/person/').gsub(/\/financial-organization\//,'http://crunchbase.com/financial-organization/').gsub(/<div class="milestone_text">|<\/div>/,'')
      puts text
    end
  end

rescue OpenURI::HTTPError
  puts "not there"
end
