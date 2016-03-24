#!/usr/bin/env ruby
# coding: utf-8

require 'erb'
require_relative 'builder'

# Create a Debian package from a directory.
#
# Author:: Frank Jung
# License:: see LICENSE
class Packager
  # template of command to create package
  FPM_TEMPLATE = ['fpm',
                  '-s dir',
                  '-t deb',
                  '-n fhj-timer',
                  '-v <%= @version %>',
                  '--iteration <%= @iteration %>',
                  '-a all',
                  '--description "Simple debian service"',
                  '-d "bash > 4.3"',
                  '-d "chkconfig > 11.4"',
                  '-d "curl > 7.33"',
                  '-d "dash > 0.5.7"',
                  '--pre-install <%= @preinstall %>',
                  '--post-install <%= @postinstall %>',
                  '--pre-uninstall <%= @preuninstall %>',
                  '--category Utility',
                  '--vendor frankhjung',
                  '--license http://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html',
                  '-m frankhjung@linux.com',
                  '--url "http://frankhjung.blogspot.com.au/"',
                  '-C <%= @changedir %>',
                  'etc/init.d',
                  'opt/fhj'
                 ]

  # command to check package creation
  CHECK_TEMPLATE = 'dpkg -I <%= name %>'

  # binding for ERB - base directory to get artifacts
  attr_accessor :changedir
  # binding for ERB - iteration contains target environment
  attr_accessor :iteration
  # binding for ERB - post-installation
  attr_accessor :postinstall
  # binding for ERB - pre-installation
  attr_accessor :preinstall
  # binding for ERB - pre-uninstall
  attr_accessor :preuninstall
  # binding for ERB - package version
  attr_accessor :version

  # Version
  @version = nil

  # Iteration (same as environment)
  @iteration = nil

  # Create RPM package for a specific environment configuration
  def pack(version, iteration)
    @version = version
    @iteration = iteration
    @preinstall = Builder::PRE_INSTALL
    @postinstall = File.expand_path "target/#{@iteration}/postinstall"
    @preuninstall = Builder::PRE_UNINSTALL
    @changedir = File.expand_path "target/#{@iteration}"
    _pack
  end

  # Returns with the expected package name
  def name
    fail 'ERROR: no version supplied' unless @version
    fail 'ERROR: no iteration supplied' unless @iteration
    "fhj-timer_#{@version}-#{@iteration}_all.deb"
  end

  # Check package was built correctly
  def check
    renderer = ERB.new(CHECK_TEMPLATE)
    system renderer.result(binding)
  end

  # Returns the environment given a package name
  def self.environment(package)
    # "fhj-timer_[version]-[environment]_all.deb"
    (package.strip)[/.*-([^.-]*)_all\.deb/, 1]
  end

  private

  # Package for a specific environment configuration
  def _pack
    renderer = ERB.new(FPM_TEMPLATE.join(' '))
    fpm_command = renderer.result(binding)
    rc = system fpm_command
    fail 'ERROR: could not create package' unless rc
  end
end
