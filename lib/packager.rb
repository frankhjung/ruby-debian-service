#!/usr/bin/env ruby
# coding: utf-8

require 'erb'

# Create a Debian package from a directory.
#
# Author:: Frank Jung
# License:: see LICENSE
class Packager
  # Version
  VERSION = '0.3.0'
  # template of command to create package
  FPM_TEMPLATE = ['fpm',
                  '-s dir',
                  '-t deb',
                  '-n fhj-timer',
                  '-v <%= VERSION %>',
                  '--iteration <%= @iteration %>',
                  '-a all',
                  '-m frankhjung@linux.com',
                  '--description "Simple debian service"',
                  '-d "bash (>=4.3)"',
                  '-d "chkconfig (>=11.4)"',
                  '-d "curl (>=7.33)"',
                  '-d "dash (>=0.5.7)"',
                  '-d "grep (>=2.15)"',
                  '--pre-install <%= @preinstall %>',
                  '--post-install <%= @postinstall %>',
                  '--pre-uninstall <%= @preuninstall %>',
                  '--category Utility',
                  '--vendor frankhjung',
                  '--url "http://frankhjung.blogspot.com.au/"',
                  '--verbose',
                  '-C <%= @changedir %>',
                  'etc/init.d',
                  'opt/app'
                 ]

  # command to check package creation
  CHECK_TEMPLATE = ['dpkg',
                    '-I',
                    'fhj-timer_<%= VERSION %>-<%= @iteration %>*.deb'
                   ]

  # binding for ERB
  attr_accessor :iteration
  attr_accessor :preinstall
  attr_accessor :postinstall
  attr_accessor :preuninstall
  attr_accessor :changedir

  # Returns with the expected package name
  def name
    return "fhj-timer_#{VERSION}-#{@iteration}_all.deb"
  end

  # Package for a specific environment configuration
  def pack
    puts "Packaging for #{@iteration} ..."
    renderer = ERB.new(FPM_TEMPLATE.join(' '))
    fpm_command = renderer.result(binding)
    puts fpm_command
    rc = system fpm_command
    fail "ERROR: could not create package #{rc}" unless rc
  end

  # Check package was built correctly
  def check
    renderer = ERB.new(CHECK_TEMPLATE.join(' '))
    check_command = renderer.result(binding)
    system check_command
  end
end
