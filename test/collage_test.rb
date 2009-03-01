require 'rubygems'

gem 'rack', '>= 0.9'
gem 'rr', '>= 0.6'

require 'rack/mock'
require 'test/unit'
require 'fileutils'
require 'time'
require 'rr'

require File.dirname(__FILE__) + "/../lib/collage"

class MiddlewareTest < Test::Unit::TestCase
  include RR::Adapters::TestUnit
  
  PATH = File.dirname(__FILE__) + "/public"

  def setup
    @app = lambda { |env| [200, {'Content-Type' => 'text/plain', 'Content-Length' => '5'}, ["Hello"]] }

    @request = Rack::MockRequest.new(Rack::Lint.new(Collage.new(@app, PATH)))

    FileUtils.rm_f(File.join(PATH, Collage.filename))
  end

  def response(path = "/#{Collage.filename}")
    @request.get(path)
  end

  def test_pass_through
    assert_equal "Hello", response("/").body
  end

  def test_unifies_files
    assert_match %r{// One\n\n\n}, response.body
    assert_match %r{// Two\n}, response.body
  end

  def test_writes_unified_file_to_disk
    assert_equal response.body, File.read(File.join(PATH, Collage.filename))
  end

  def test_traverses_subdirectories
    assert_match %r{// Subdir\n}, response.body
  end

  def test_only_picks_up_javascripts
    assert_no_match %r{// Just text\n}, response.body
  end

  def test_provides_a_timestamp
    stamp = Time.now

    stub(File).mtime(File.join(PATH, "two.js")) { stamp }
    stub(File).mtime(anything) { stamp - 1 }

    assert_equal stamp.to_i.to_s, Collage.timestamp(PATH)
  end

  def test_provides_html_tag
    stamp = Time.now

    stub(File).mtime { stamp }

    assert_equal %{<script type="text/javascript" src="/js.js?#{stamp.to_i}"></script>}, Collage.html_tag(PATH)
  end

  def test_sets_last_modified_header
    stamp = Time.now

    stub(File).mtime { stamp }

    assert_equal stamp.httpdate, response.headers['Last-Modified']
  end

  def test_does_not_include_the_collage
    File.open(File.join(PATH, Collage.filename), 'w') {|f| f.write("Unified!") }

    assert_no_match /Unified!/, response.body
  end
end
