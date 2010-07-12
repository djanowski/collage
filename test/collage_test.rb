require "rack/mock"
require "test/unit"
require "fileutils"
require "time"
require "override"

require "sass"

include Override

$VERBOSE = true

require File.expand_path("../lib/collage", File.dirname(__FILE__))

(class << File; self; end).send(:alias_method, :original_mtime, :mtime)

PATH = File.expand_path(File.dirname(__FILE__) + "/public")

class MiddlewareTest < Test::Unit::TestCase
  def setup
    @app = lambda { |env| [200, {'Content-Type' => 'text/plain', 'Content-Length' => '5'}, ["Hello"]] }

    @request = Rack::MockRequest.new(Rack::Lint.new(Collage.new(@app, :path => PATH)))

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
    newer = File.join(PATH, "two.js")

    override(File, :mtime => lambda { |path| path == newer ? stamp : stamp - 1 })

    assert_equal stamp.to_i.to_s, Collage.timestamp(PATH)
  end

  def test_provides_html_tag
    stamp = Time.now

    override(File, :mtime => stamp)

    assert_equal %{<script type="text/javascript" src="/js.js?#{stamp.to_i}"></script>}, Collage.html_tag(PATH)
  end

  def test_sets_last_modified_header
    stamp = Time.parse("Wed, 04 Mar 2009 12:57:45 GMT")

    override(File, :mtime => lambda { |path| stamp if path == File.join(PATH, "js.js") })

    assert_equal "Wed, 04 Mar 2009 12:57:45 GMT", response.headers['Last-Modified']
  end

  def test_allows_custom_patterns
    @request = Rack::MockRequest.new(Rack::Lint.new(Collage.new(@app, :path => PATH, :files => ["o*.js"])))

    assert_equal "// One\n\n\n", response.body
  end

  def test_does_not_include_files_twice
    @request = Rack::MockRequest.new(Rack::Lint.new(Collage.new(@app, :path => PATH, :files => ["two.js", "o*.js", "two.js"])))

    assert_equal "// Two\n\n\n// One\n\n\n", response.body
  end

  def test_does_not_include_the_collage
    File.open(File.join(PATH, Collage.filename), 'w') {|f| f.write("Unified!") }

    assert_no_match /Unified!/, response.body
  end
end

class PackagerTest < Test::Unit::TestCase
  def setup
    @path = File.join(PATH, "all.js")

    FileUtils.rm_f(@path)
  end

  def test_minification
    collage = Collage::Packager.new(PATH, ["function.js"])

    normal = collage.to_s
    minified = collage.minify

    assert minified.size > 0
    assert minified.size < normal.size
  end

  def test_write_minified
    collage = Collage::Packager.new(PATH, ["function.js"])

    collage.write(@path, true)

    assert File.read(@path) == collage.minify
  end
end

class SassPackagerTest < Test::Unit::TestCase
  def setup
    @path = File.join(PATH, "all.css")

    FileUtils.rm_f(@path)
  end

  def test_writes_file
    Collage::Packager::Sass.new(PATH, ["one.sass"]).write(@path)

    assert_equal "body {\n  font-size: 1em; }\n\n\n", File.read(@path)
  end

  def test_keeps_correct_timestamp
    stamp = Time.parse("2009-11-30 15:00:00 UTC")

    override(File, :mtime => lambda { |path| stamp if path == File.join(PATH, "one.sass") })

    Collage::Packager::Sass.new(PATH, ["one.sass"]).write(@path)

    (class << File; self; end).send(:alias_method, :mtime, :original_mtime)

    assert_equal stamp.to_i, File.mtime(@path).to_i
  end
end

class SassPackagerTest < Test::Unit::TestCase
  def test_packages_sass
    output = Collage::Packager::Sass.new(PATH, ["one.sass"]).package

    assert_equal "body {\n  font-size: 1em; }\n\n\n", output
  end

  def test_appends_timestamp_to_images
    (class << File; self; end).send(:alias_method, :mtime, :original_mtime)

    output = Collage::Packager::Sass.new(PATH, ["backgrounds.sass"]).package

    stamp = File.mtime(File.join(PATH, "collage.png")).to_i

    assert_equal "body {\n  font-size: 1em;\n  background: url(/collage.png?#{stamp}) no-repeat left top; }\n\nheader {\n  background: url(\"/collage.png?#{stamp}\") no-repeat right bottom; }\n\nfooter {\n  background: url(http://example.org/foo.png) repeat-x; }\n\n\n", output
  end

  def test_allows_css_too
    output = Collage::Packager::Sass.new(PATH, ["one.sass", "two.css"]).package

    assert_equal "body {\n  font-size: 1em; }\n\n\n/* Two */\n\n\n", output
  end

  def test_minification
    collage = Collage::Packager::Sass.new(PATH, ["one.sass"])

    normal = collage.to_s
    minified = collage.minify

    assert minified.size > 0
    assert minified.size < normal.size
  end
end
