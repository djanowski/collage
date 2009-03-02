Collage
=======

This is a Rack middleware that will package all your Javascript into a single file – very much inspired by Rails' `javascript_include_tag(:all, :cache => true)`.

Examples:

    use Collage, :path => File.dirname(__FILE__) + "/public"

    use Collage, 
      :path  => File.dirname(__FILE__) + "/public",
      :files => ["jquery*.js", "*.js"]

Collage also provides a handy helper for your views. This is useful because it appends the correct timestamp to the `src` attribute, so you won't have any issues with intermediate caches.

    <%= Collage.html_tag("./public") %>
