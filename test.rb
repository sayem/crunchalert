
link = "http://www.crunchbase.com/company/buddymedia"

if link =~ /^(http:\/\/)(www\.)?(crunchbase.com\/)(company|person|financial-organization)\/([\w+\-]+)(\/)?$/

  puts 'good crunchbase link'

else

  puts 'not a good link'

end



=begin

require 'open-uri'
require 'nokogiri'

content = "buddy media"
formatted = content.downcase.gsub(/[\s\.]/,'-')


begin
  doc = Nokogiri::HTML(open("http://crunchbase.com/company/#{formatted}"))
  puts doc
rescue OpenURI::HTTPError
  puts formatted
  
end

=end
