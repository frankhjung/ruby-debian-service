#!/usr/bin/env ruby
# coding: utf-8

require 'erb'
require_relative 'properties'

# Build uses a template and properties to generate a target file.
#
# Author:: Frank Jung
# License:: see LICENSE
class Builder
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

  # Copy file as is from source to target.
  def copy_file(source_file, target_file)
    fail "ERROR: #{source_file} not a file" unless File.file?(source_file)
    FileUtils.mkdir_p(File.dirname(target_file))
    FileUtils.cp source_file, target_file
  end

  # Build from a template.
  # Preserves file modes
  def from_template(source_file, target_file, properties_file)
    fail "ERROR: #{source_file} not a file" unless File.file?(source_file)
    FileUtils.mkdir_p(File.dirname(target_file))
    source = File.read(source_file)
    properties = Properties.new(properties_file)
    renderer = ERB.new(source)
    File.write(target_file, renderer.result(properties.get_binding))
    s = File.stat(source_file)
    File.chmod(s.mode, target_file)
  end
end
