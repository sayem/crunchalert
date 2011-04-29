
require 'mail'

crap = '<h1>This is purrree</h1>'


Mail.deliver do
  from 'CrunchAlert <admin@crunchalert.com>'
  to 'sayem.islam@gmail.com'
  subject 'whatsup'

  html_part do
    content_type 'text/html; charset=UTF-8'
    body crap
  end
end
