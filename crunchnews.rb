require 'nokogiri'
require 'open-uri'

begin
  doc = Nokogiri::HTML(open('http://www.crunchbase.com/company/facebook'))
  news = doc.css('.col3_content').each do |news|
    links = news.css('.recently_link').to_s().gsub(/<div class="recently_link">|<div class="recently_desc">|<\/div>/,'')
    puts links
  end

rescue OpenURI::HTTPError
  puts "not there"
end


# will need to limit it to just the techcrunch and techmeme posts
