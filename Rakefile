require 'rake'
require 'rake/gempackagetask'
require 'rake/clean'
require 'rake/testtask'

gem_spec_file = 'collage.gemspec'

gem_spec = eval(File.read(gem_spec_file)) rescue nil

Rake::GemPackageTask.new(gem_spec) do |pkg|
  pkg.need_zip = false
  pkg.need_tar = false
  rm_f FileList['pkg/**/*.*']
end if gem_spec

desc "Generate the gemspec file."
task :gemspec do
  require 'erb'

  File.open(gem_spec_file, 'w') do |f|
    f.write ERB.new(File.read("#{gem_spec_file}.erb")).result(binding)
  end
end

desc "Builds and installs the gem."
task :install => :repackage do
  `sudo gem install pkg/#{gem_spec.name}-#{gem_spec.version}.gem`
end
