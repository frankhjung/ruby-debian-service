#!/usr/bin/env ruby

# Load a properties file into a hash.
#
# Author:: Frank Jung
# License:: see LICENSE
class Properties
  # binding for ERB
  attr_accessor :properties

  # Parse a properties file
  #
  # * Load cleansed lines into an array
  # * Load key values into a hash
  def parse(file)
    @properties = {}
    raise unless File.file?(file)
    IO.foreach(file) do |line|
      work = line.strip
      next if work.empty?
      next if '#' == work[0]
      if work.include? '='
        k, v = work.split('=')
        _append k, v
      end
    end
  end

  # expose private ERB binding method.
  def erb_binding
    binding
  end

  alias get_binding erb_binding

  private

  # write only valid properties to list and hash
  def _append(key, value)
    return unless key
    k = key.strip
    return if k.empty?
    v = value ? value.strip : ''
    @properties[k] = v
  end
end
