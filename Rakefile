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

task default: [:help]
task cleanall: [:clean, :clobber]
task all: [:clean, :clobber, :check, :package, :doc]

# path to init.d service
SERVICE = File.expand_path 'src/main/resources/fhj-timer-service.sh'

# path to script run by service (templated)
SCRIPT = File.expand_path 'src/main/resources/fhj-timer-script.sh.erb'

# path to configuration properties
CONFIG_DIR = File.expand_path 'src/main/config'

# pre-installation script
PRE_INSTALL = File.expand_path 'src/main/resources/preinstall'

# post-installation script (templated)
POST_INSTALL_ERB = File.expand_path 'src/main/resources/postinstall.erb'

# pre-un-installation script
PRE_UNINSTALL = File.expand_path 'src/main/resources/preuninstall'

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
  rvm gemsets list

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
    builder.copy_file(SERVICE, service_file)
    script_file = File.expand_path "target/#{@config}/opt/app/fhj-timer.sh"
    builder.from_template(SCRIPT, script_file, properties_file)
    postinstall_file = File.expand_path "target/#{@config}/postinstall"
    builder.from_template(POST_INSTALL_ERB, postinstall_file, properties_file)
  end
end

desc 'Create Debian package using command line fpm'
task package: :build do
  packager = Packager.new
  Dir.glob 'src/main/config/*' do |d|
    packager.iteration = File.basename d
    packager.preinstall = PRE_INSTALL
    packager.postinstall = File.expand_path "target/#{packager.iteration}/postinstall"
    packager.preuninstall = PRE_UNINSTALL
    packager.changedir = File.expand_path "target/#{packager.iteration}"
    packager.pack
    fail "ERROR: could not create package #{packager.name}" unless packager.check
    FileUtils.mv packager.name, 'target'
  end
end

desc 'Check packages were built correctly'
task :validate do
  packager = Packager.new
  Dir.glob 'src/main/config/*' do |d|
    packager.iteration = File.basename d
    puts "\nChecking package for #{packager.iteration} ..."
    puts "\nERROR: bad package for #{packager.iteration}\n" unless packager.check
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
