require 'nokogiri'
require 'open-uri'


crunchalerts = Array.new
doc = Nokogiri::HTML(open("http://crunchbase.com/company/facebook"))
milestones = doc.css('#milestones li').each do |milestone|

  ass = milestone.at_css('.milestone_text').to_s.gsub(/\/company\/facebook/,"http://crunchbase.com/company/facebook").gsub(/<div class="milestone_text">|<\/div>/,'')

  crunchalerts.push(ass)

end


puts crunchalerts
