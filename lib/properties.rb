#!/usr/bin/env ruby
# coding: utf-8

# Load a properties file into a hash.
#
# Author:: Frank Jung
# License:: see LICENSE
class Properties
  # binding for ERB
  attr_accessor :properties

  # Default constructor
  def initialize(file)
    @properties = {}
    _parse(file)
  end

  # expose private ERB binding method.
  def get_binding
    binding
  end

  private

  # Parse a properties file
  #
  # * Load cleansed lines into an array
  # * Load key values into a hash
  def _parse(file)
    fail unless File.file?(file)
    IO.foreach(file) do |line|
      work = line.strip
      if work.empty?
        next
      elsif '#' == work[0] then
        next
      elsif work.include? '=' then
        k, v = work.split('=')
        _append k, v
      end
    end
  end

  # write only valid properties to list and hash
  def _append(key, value)
    return unless key
    k = key.strip
    return unless k.length > 0
    v = value ? value.strip : ''
    @properties[k] = v
  end
end
