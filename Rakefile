# coding: utf-8

require 'fpm'
require 'rake/clean'
require 'rdoc/task'
require 'rubocop/rake_task'

require_relative 'lib/builder'
require_relative 'lib/packager'
require_relative 'lib/publisher'

# if snapshot, mimic publishing artifacts
VERSION = 'SNAPSHOT'

task default: [:help]
task cleanall: [:clean, :clobber]
task all: [:clean, :clobber, :check, :package, :doc]

desc 'Show help'
task :help do
  puts <<HELP
The main goals are

  * build - build target files from templates
  * package - create RPM package from targets
  * publish - upload RPM packages to WebDAV

For Rakefile help call:

  rake -D

Or

  rake -T
To show Ruby environment use:

  go.sh info

To cleanup unused Gems use:

  bundle clean --force -V

To show gemsets use:

  rvm gemset list

Version:

  #{VERSION}
HELP
  # can also get more help on FPM with
  # system 'fpm --help'
end

desc 'Generate target files from source and templates'
task build: [:clean, :check] do
  Dir.glob 'src/main/env/*' do |env|
    builder = Builder.new
    @environment = File.basename env
    puts "Building #{@environment} ..."
    builder.build @environment
  end
end

desc 'Check project syntax with RuboCop'
RuboCop::RakeTask.new(:check) do |task|
  # run standard syntax check first
  ruby '-c Rakefile lib/*.rb'
  # files to check
  task.patterns = ['Rakefile', 'lib/*.rb']
  # report format: simple, progress, files, offenses, clang, disabled
  task.formatters = ['progress']
  # continue on finding errors
  task.fail_on_error = false
  # show it working
  task.verbose = true
end

desc 'package installation files for each environment'
task :package do
  Dir.glob 'target/*' do |env|
    packager = Packager.new
    environment = File.basename env
    next if environment == '_local'
    packager.pack(VERSION, environment)
    fail "ERROR: could not create package #{packager.name}" unless packager.check
    FileUtils.mv(packager.name, 'target')
  end
end

desc 'Publish build artifacts to webdav server'
task :publish do
  Dir.glob('target/*.deb').each do |deb|
    publisher = Publisher.new
    publisher.publish(VERSION, deb)
  end
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

desc 'Document project'
RDoc::Task.new(:doc) do |task|
  task.main = 'README'
  task.options << '--all'
  task.rdoc_dir = 'doc'
  task.rdoc_files.include('Rakefile')
  task.rdoc_files.include('lib/*.rb')
  task.rdoc_files.include('README.rdoc')
  task.rdoc_files.include('CHANGES')
  task.rdoc_files.include('LICENSE')
  # task.rdoc_files.include('VERSION')
  task.title = ENV['title'] || 'Ruby example to generate a Debian package'
end

CLEAN.include('fhj-timer*.deb', 'target/*.deb')
CLOBBER.include('doc/', 'target/', '**/*.bak', '**/*~')
