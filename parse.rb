require 'nokogiri'
require 'open-uri'

crunchalerts = Array.new
doc = Nokogiri::HTML(open("http://crunchbase.com"))
milestones = doc.css('#milestones li').each do |milestone|


  if milestone.to_s =~ /milestone_acquisition/
    crunchalerts.push('acquisitions')
  elsif milestone.to_s =~ /milestone_funding_round/
    crunchalerts.push('fundings')
  else
    crunchalerts.push('products and companies')
  end

  text = milestone.at_css('.milestone_text').to_s.gsub(/\/company\//,'http://crunchbase.com/company/').gsub(/\/person\//,'http://crunchbase.com/person/').gsub(/\/financial-organization\//,'http://crunchbase.com/financial-organization/').gsub(/\/product\//,'http://crunchbase.com/product/').gsub(/\/service-provider\//,'http://crunchbase.com/service-provider/').gsub(/<div class="milestone_text">|<\/div>/,'')
  crunchalerts.push(text)

end

puts crunchalerts



