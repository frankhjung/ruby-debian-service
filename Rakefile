# coding: utf-8

require 'fpm'
require 'rake/clean'
require 'rdoc/task'
require 'rubocop/rake_task'

require_relative 'lib/builder'
require_relative 'lib/packager'

# Build Debian application package.
#
# * the service is called fhj-timer (based of /etc/init.d/skeleton)
# * the script is called fhj-timer.sh
#
# To build CentOS package and service read
#
# * http://www.cyberciti.biz/tips/linux-write-sys-v-init-script-to-start-stop-service.html
# * http://www.linux.com/learn/tutorials/442412-managing-linux-daemons-with-init-scripts

VERSION = '0.3.0'

task default: [:help]
task cleanall: [:clean, :clobber]
task all: [:clean, :clobber, :check, :package, :doc]

desc 'Show help'
task :help do
  puts <<HELP
For Rakefile help call:

  rake -D

Or

  rake -T

To cleanup unused Gems use:

  bundle clean --force -V

To show gemsets use:

  rvm gemset list

Version:

  #{VERSION}
HELP
  # system 'fpm --help'
end

desc 'Generate target files from source and templates'
task build: :clean do
  builder = Builder.new
  Dir.glob 'src/main/config/*' do |d|
    @config = File.basename d
    puts "Building for #{@config} ..."
    properties_file = File.expand_path "src/main/config/#{@config}/debian-service.properties"
    service_file = File.expand_path "target/#{@config}/etc/init.d/fhj-timer"
    builder.copy_file(Builder::SERVICE, service_file)
    script_file = File.expand_path "target/#{@config}/opt/app/fhj-timer.sh"
    builder.from_template(Builder::SCRIPT, script_file, properties_file)
    postinstall_file = File.expand_path "target/#{@config}/postinstall"
    builder.from_template(Builder::POST_INSTALL_ERB, postinstall_file, properties_file)
  end
end

desc 'Create Debian package using command line fpm'
task package: :build do
  packager = Packager.new
  packager.version = VERSION
  Dir.glob 'src/main/config/*' do |d|
    packager.iteration = File.basename d
    packager.preinstall = Builder::PRE_INSTALL
    packager.postinstall = File.expand_path "target/#{packager.iteration}/postinstall"
    packager.preuninstall = Builder::PRE_UNINSTALL
    packager.changedir = File.expand_path "target/#{packager.iteration}"
    packager.pack
    fail "ERROR: could not create package #{packager.name}" unless packager.check
    FileUtils.mv packager.name, 'target'
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

desc 'Check project syntax with RuboCop'
RuboCop::RakeTask.new(:check) do |task|
  # run standard syntax check first
  # ruby "-c #{srcs}"
  # files to check
  task.patterns = ['Rakefile', 'lib/*.rb']
  # report format: simple, progress, files, offenses, clang, disabled
  task.formatters = ['simple']
  # continue on finding errors
  task.fail_on_error = false
  # show it working
  task.verbose = true
end

desc 'Document project'
RDoc::Task.new(:doc) do |task|
  task.main = 'README'
  task.options << '--all'
  task.rdoc_dir = 'doc'
  task.rdoc_files.include('Rakefile')
  task.rdoc_files.include('README.rdoc')
  task.rdoc_files.include('CHANGES')
  task.rdoc_files.include('LICENSE')
  # task.rdoc_files.include('VERSION')
  task.title = ENV['title'] || 'Ruby example to generate a Debian package'
end

CLEAN.include('fhj-timer*.deb', 'target/*.deb')
CLOBBER.include('doc/', 'target/', '**/*.bak', '**/*~')
