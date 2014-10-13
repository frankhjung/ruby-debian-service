#!/usr/bin/env ruby
# coding: utf-8

require 'erb'

# Create a Debian package from a directory.
#
# Author:: Frank Jung
# License:: see LICENSE
class Packager
  # Version
  @version = nil
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
                  '-m frankhjung@linux.com',
                  '--url "http://frankhjung.blogspot.com.au/"',
                  '-C <%= @changedir %>',
                  'etc/init.d',
                  'opt/app'
                 ]

  # command to check package creation
  CHECK_TEMPLATE = 'dpkg -I <%= name %>'

  # binding for ERB
  attr_accessor :changedir
  attr_accessor :iteration
  attr_accessor :postinstall
  attr_accessor :preinstall
  attr_accessor :preuninstall
  attr_accessor :version

  # Returns with the expected package name
  def name
    fail 'ERROR: no version supplied' unless @version
    fail 'ERROR: no iteration supplied' unless @iteration
    "fhj-timer_#{@version}-#{@iteration}_all.deb"
  end

  # Package for a specific environment configuration
  def pack
    renderer = ERB.new(FPM_TEMPLATE.join(' '))
    fpm_command = renderer.result(binding)
    rc = system fpm_command
    fail "ERROR: could not create package #{rc}" unless rc
  end

  # Check package was built correctly
  def check
    renderer = ERB.new(CHECK_TEMPLATE)
    system renderer.result(binding)
  end
end
