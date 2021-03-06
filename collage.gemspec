Gem::Specification.new do |s|
  s.name = 'collage'
  s.version = '0.1.5'
  s.summary = %{Rack middleware that packages your JS into a single file.}
  s.date = %q{2009-03-01}
  s.author = "Damian Janowski"
  s.email = "damian.janowski@gmail.com"

  s.specification_version = 2 if s.respond_to? :specification_version=

  s.files = ["lib/collage.rb", "README.markdown", "Rakefile", "vendor/yuicompressor-2.4.2.jar", "example/config.ru", "example/public", "example/public/app.js", "example/public/jquery.js"]

  s.require_paths = ['lib']

  s.bindir = "bin"

  s.extra_rdoc_files = ["README.markdown"]
  s.has_rdoc = false
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "collage", "--main", "README.markdown"]
end
