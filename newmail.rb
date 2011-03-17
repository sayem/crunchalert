
 require 'mail'

 mail = Mail.new do
       from 'admin@crunchalert.com'
         to 'mail@sayemislam.com'
    subject 'Here is the image you wanted'
       body 'hi'
 end

 mail.deliver!
