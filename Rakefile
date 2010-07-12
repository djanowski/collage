gem_spec_file = "collage.gemspec"

gem_spec = eval(File.read(gem_spec_file)) rescue nil

task :default => :test

task :test do
  Dir["test/**/*_test.rb"].each { |file| load file }
end
