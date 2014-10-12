require 'fpm'
require 'rake/clean'
require 'rdoc/task'
require 'rubocop/rake_task'
require_relative 'lib/builder'

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
POST_INSTALL = File.expand_path 'target/postinstall'

# pre-un-installation script
PRE_UNINSTALL = File.expand_path 'src/main/resources/preuninstall'

# command to create package
CONFIG = 'local'
PACKAGE_COMMAND = ['fpm',
                   '-s dir',
                   '-t deb',
                   '-n fhj-timer',
                   '-v 0.1.0',
                   "--iteration #{CONFIG}",
                   '-a all',
                   '-m frankhjung@linux.com',
                   '--description "Simple debian service"',
                   '-d "bash (>=4.3)"',
                   '-d "chkconfig (>=11.4)"',
                   '-d "curl (>=7.33)"',
                   '-d "dash (>=0.5.7)"',
                   '-d "grep (>=2.15)"',
                   "--pre-install #{PRE_INSTALL}",
                   "--post-install #{POST_INSTALL}",
                   "--pre-uninstall #{PRE_UNINSTALL}",
                   '--category Utility',
                   '--vendor frankhjung',
                   '--url "http://frankhjung.blogspot.com.au/"',
                   '--verbose',
                   '-C target',
                   'etc/init.d',
                   'opt/app'
                  ]

# command to check package creation
CHECK_COMMAND = ['dpkg',
                 '-I',
                 'fhj-timer*.deb'
                ]

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
  system 'fpm --help'
end

desc 'Generate target files from source and templates'
task build: :clean do
  properties_file = File.expand_path "src/main/config/#{CONFIG}/debian-service.properties"
  # service
  build = Builder.new
  target_file = File.expand_path 'target/etc/init.d/fhj-timer'
  build.copy_file(SERVICE, target_file)
  # script - timer (sets sleep time)
  target_file = File.expand_path 'target/opt/app/fhj-timer.sh'
  build.from_template(SCRIPT, target_file, properties_file)
  # script - postinstall (starts service if active)
  build.from_template(POST_INSTALL_ERB, POST_INSTALL, properties_file)
end

desc 'Create Debian package using command line fpm'
task package: :build do
  # build package
  rc = system PACKAGE_COMMAND.join(' ')
  fail "ERROR: could not create package #{rc}" unless rc
  # show information of built package
  system CHECK_COMMAND.join(' ')
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

CLEAN.include('fhj-timer*.deb')
CLOBBER.include('doc/', 'target/', '**/*.bak', '**/*~')
