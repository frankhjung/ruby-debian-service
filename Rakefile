require 'rake/clean'
require 'rdoc/task'
require 'rubocop/rake_task'

require_relative 'lib/builder'
require_relative 'lib/packager'
require_relative 'lib/publisher'

# if snapshot, mimic publishing artifacts
VERSION = ENV['VERSION'] || 'SNAPSHOT'

task default: %i[help]
task cleanall: %i[clean clobber]
task all: %i[cleanall check build package publish doc]

tests = FileList.new('tests/test_*.rb')
srcs = FileList.new('lib/*.rb')

desc 'Show help'
task :help do
  puts <<HELP
  For Rakefile help call:
    rake -D
  Or
    rake -T

  To cleanup unused Gems use:
    bundle clean --force -V

  The main goals are:

  * build - build target files from templates
    * package - create Debian package from targets
    * publish - upload Debian packages to WebDAV

  * FPM
    * install fpm gem
    * can also get more help on FPM with system 'fpm --help'

  Version:
    #{VERSION}
HELP
end

desc 'Show bundle and Gem information'
task :info do
  # showing RVM information:
  system 'rvm info'
  # system 'rvm list'
  # showing Gem information:
  # system 'gem list --local'
  system 'gem environment'
  # showing bundle information
  system 'bundle list'
  puts 'Showing stale gems:'
  system 'gem stale'
end

desc 'Install bundles'
task :bundles do
  system 'bundle check'
  system 'bundle install'
  # system 'bundle update'
  system 'bundle list --verbose'
end

desc 'Check project syntax with RuboCop'
RuboCop::RakeTask.new(:check) do |task|
  # run standard syntax check first
  # ruby "-c #{srcs}"
  # files to check
  task.patterns = ['Rakefile'] + srcs + tests
  # report format: simple, progress, files, offenses, clang, disabled
  task.formatters = ['simple']
  # continue on finding errors
  task.fail_on_error = false
  # show it working
  task.verbose = true
end

desc 'Generate target files from source and templates'
task build: :clean do
  Dir.glob 'src/main/config/*.properties' do |env|
    next unless File.file? env
    builder = Builder.new
    environment = (File.basename env)[/^([^.]*).properties/, 1]
    puts "Building #{environment} ..."
    builder.build environment
  end
end

desc 'package installation files for each environment'
task :package do
  Dir.glob 'target/*' do |env|
    next unless File.directory? env
    packager = Packager.new
    environment = File.basename env
    puts "Packaging #{environment} ..."
    packager.pack(VERSION, environment)
    raise "ERROR: could not create package #{packager.name}" unless packager.check
    FileUtils.mv(packager.name, 'target')
  end
end

desc 'Publish build artifacts to webdav server'
task :publish do
  Dir.glob('target/*.deb').each do |deb|
    next unless File.file? deb
    puts "Publishing #{deb} ..."
    publisher = Publisher.new
    publisher.publish(VERSION, deb)
  end
end

desc 'Document project'
RDoc::Task.new(:doc) do |task|
  task.main = 'README'
  task.options << '--all'
  task.rdoc_dir = 'doc'
  task.rdoc_files.include('Rakefile')
  task.rdoc_files.include('lib/*.rb')
  task.rdoc_files.include('README.rdoc')
  task.rdoc_files.include('CHANGES')
  task.rdoc_files.include('TODO')
  task.rdoc_files.include('LICENSE')
  # task.rdoc_files.include('VERSION')
  task.title = ENV['title'] || 'Ruby example to generate a Debian package'
end

desc 'Check project syntax with RuboCop'
RuboCop::RakeTask.new(:check) do |task|
  # run standard syntax check first
  ruby '-c Rakefile lib/*.rb'
  # report format: simple, progress, files, offenses, clang, disabled
  task.patterns = ['Rakefile', 'lib/*.rb']
  task.fail_on_error = true
  task.formatters = ['progress']
  task.verbose = false
end

CLEAN.include('fhj-timer*.deb')
CLOBBER.include('doc/', 'target/', '**/*.bak', '**/*~')
