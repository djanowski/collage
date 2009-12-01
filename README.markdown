Collage
=======

Rack middleware that packages your JS into a single file.

Usage
-----

This middleware will package all your JavaScript into a single file – very much inspired by Rails' `javascript_include_tag(:all, :cache => true)`.

    use Collage, :path => File.dirname(__FILE__) + "/public"

    use Collage,
      :path  => File.dirname(__FILE__) + "/public",
      :files => ["jquery*.js", "*.js"]

Collage also provides a handy helper for your views. This is useful because it appends the correct timestamp to the `src` attribute, so you won't have any issues with intermediate caches.

    <%= Collage.html_tag("./public") %>

Installation
------------

    $ gem sources -a http://gems.github.com (you only have to do this once)
    $ sudo gem install djanowski-collage

License
-------

Copyright (c) 2009 Damian Janowski for Citrusbyte

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
