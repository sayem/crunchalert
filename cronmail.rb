
require 'mail'

mail = Mail.new do
  from 'CrunchAlert <admin@crunchalert.com>'
  to 'sayem.islam@gmail.com'
  subject 'whatsup'
  body 'hi'
end

mail.deliver!
