
link = "http://www.crunchbase.com/company/buddymedia"


#name = link.scan(/\w+$/)[0]  .gsub(/\//, '')

# type = link.scan(/\/\w+\//)[0].delete('/')

# puts type.class


=begin
if link =~ /^(http:\/\/)(www\.)?(crunchbase.com\/)(company|person|financial-organization)\/([\w+\-]+)(\/)?$/

  puts 'good crunchbase link'

else

  puts 'not a good link'

end
=end


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



Mail.deliver do
  from 'CrunchAlert <admin@crunchalert.com>'
  to user.email
  subject 'CrunchAlert.com'

  html_part do
    content_type 'text/html; charset=UTF-8'
    body crunchalerts
  end
end


=end
