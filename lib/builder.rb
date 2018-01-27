#!/usr/bin/env ruby

require 'erb'

require_relative 'properties'

# Build uses a template and properties to generate a target file.
#
# Author:: Frank Jung
# License:: see LICENSE
class Builder
  # application name
  APP_NAME = 'fhj-timer'.freeze
  # application target directory on server
  APP_DIR = 'opt/fhj'.freeze
  # path to init.d service
  SERVICE = File.expand_path 'src/main/resources/fhj-timer-service.sh'
  # path to script run by service (templated)
  SCRIPT_ERB = File.expand_path 'src/main/resources/fhj-timer-script.sh.erb'
  # pre-installation script
  PRE_INSTALL = File.expand_path 'src/main/resources/preinstall'
  # post-installation script (templated)
  POST_INSTALL_ERB = File.expand_path 'src/main/resources/postinstall.erb'
  # pre-un-installation script
  PRE_UNINSTALL = File.expand_path 'src/main/resources/preuninstall'

  # Build files for a specific environment
  def build(env)
    properties_file = File.expand_path "src/main/config/#{env}.properties"
    service_file = File.expand_path "target/#{env}/etc/init.d/#{APP_NAME}"
    copy_file SERVICE, service_file
    script_file = File.expand_path "target/#{env}/#{APP_DIR}/#{APP_NAME}.sh"
    from_template SCRIPT_ERB, script_file, properties_file
    postinstall_file = File.expand_path "target/#{env}/postinstall"
    from_template POST_INSTALL_ERB, postinstall_file, properties_file
  end

  # Copy file as is from source to target.
  def copy_file(source_file, target_file)
    raise "ERROR: #{source_file} not a file" unless File.file? source_file
    FileUtils.mkdir_p File.dirname target_file
    FileUtils.cp source_file, target_file
  end

  # Build from a template, while preserving file modes.
  def from_template(source_file, target_file, properties_file)
    raise "ERROR: #{source_file} not a file" unless File.file? source_file
    raise "ERROR: #{properties_file} not a file" unless File.file? properties_file
    _from_template(source_file, target_file, properties_file)
    _set_permissions(source_file, target_file)
  end

  def _from_template(source_file, target_file, properties_file)
    FileUtils.mkdir_p File.dirname(target_file)
    source = File.read source_file
    properties = Properties.new
    properties.parse properties_file
    renderer = ERB.new(source)
    File.write target_file, renderer.result(properties.get_binding)
  end

  def _set_permissions(source_file, target_file)
    s = File.stat source_file
    File.chmod s.mode, target_file
  end
end
