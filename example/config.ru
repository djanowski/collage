require File.dirname(__FILE__) + "/../lib/collage"

app = proc do |env|
  [200, { 'Content-Type' => 'text/html' }, ['Hi there!'] ]
end
 
use Collage, :path => File.dirname(__FILE__) + "/public"
run app
