#!/usr/bin/env ruby
# coding: utf-8

require 'erb'
require_relative 'properties'

# Build uses a template and properties to generate a target file.
#
# Author:: Frank Jung
# License:: see LICENSE
class Builder
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
