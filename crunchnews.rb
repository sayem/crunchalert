require 'nokogiri'
require 'open-uri'
require 'date'

begin
  doc = Nokogiri::HTML(open('http://crunchbase.com/company/facebook'))
  techcrunch = Date.today.prev_day.strftime("%Y/%m/%d")
  techmeme = Date.today.prev_day.strftime("%y%m%d")

  news = doc.css('.recently_link').each do |news|
    if news.to_s() =~ /#{techcrunch}|#{techmeme}/
      links = news.to_s().gsub(/<div class="recently_link">|<\/div>/,'')
      puts links
    end

=begin

    links = news.css('.recently_link').to_s().gsub(/<div class="recently_link">|<div class="recently_desc">|<\/div>/,'')    
    if links =~ /#{yesterday}/
      puts links
      puts 'asshole'
    end

=end

  end

rescue OpenURI::HTTPError
  puts "not there"
end
