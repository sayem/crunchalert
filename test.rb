
require 'net/http'
require 'uri'

url = URI.parse( "http://www.crunchbase.com/company/stocktwits" )
content = Net::HTTP.get_print( url )


