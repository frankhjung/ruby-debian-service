#!/usr/bin/ruby

require 'net/http'
require 'uri'

require_relative 'packager'

# Publish service limiter trigger service.
# For debugging and tested this does not do anything for SNAPSHOT versions, but
# it does show what it intends to do.
#
# Author:: Frank Jung
# License:: see LICENSE
class Publisher
  # Name of project to publish
  PROJECT_NAME = 'fhj-timer'.freeze
  # WebDAV host
  REMOTE_HOST = 'http://localhost'.freeze
  # base directory on WebDAV host
  REMOTE_BASEDIR = 'artifact-repository/fhj/'.freeze
  # Do not perform actions if this is a development build
  SNAPSHOT = 'SNAPSHOT'.freeze

  # publish this version of the artifact (ignore snapshots)
  attr_accessor :version

  # Publish artifacts to WebDAV server, except if SNAPSHOT
  def publish(version, file)
    # fail "ERROR: can not publish SNAPSHOT versions" if (SNAPSHOT == version)
    @version = version
    # what environment does this RPM belong to?
    @env = _environment(file)
    # create parent paths on WebDAV server
    currentpath = REMOTE_BASEDIR
    [PROJECT_NAME, @version, @env].each do |path|
      currentpath = File.join(currentpath, path)
      _create_directory URI.join(REMOTE_HOST, currentpath)
    end
    # can now upload file
    _upload file
  end

  private

  # Helper method to extract environment from RPM file name
  def _environment(file)
    Packager.environment(file)
  end

  # Upload file to WebDAV server
  def _upload(file)
    # target = host + basedir + project + version + environment
    target = URI.join(REMOTE_HOST,
                      ['', REMOTE_BASEDIR, PROJECT_NAME, @version, @env, '']
                      .join(File::SEPARATOR))
    # now can upload file as paths all created
    _upload_file file, target
  end

  # Recursively create directories
  def _create_directory(uri)
    return if SNAPSHOT == version
    puts "Creating #{uri} ..."
    Net::HTTP.start(uri.host, uri.port) do |http|
      response = http.mkcol uri.path
      case response
      when Net::HTTPSuccess, Net::HTTPRedirection
        break
      else
        puts response.to_hash.inspect
        puts response.body
        response.error!
      end
    end
  end

  # Upload a single file (source) to target URI
  def _upload_file(file, target)
    uri = URI.join(target, File.basename(file))
    puts "Upload from #{file}\nUpload to #{uri}"
    return if SNAPSHOT == @version
    Net::HTTP.start(uri.host, uri.port) do |http|
      response = File.open(file) do |fp|
        _request(uri, file, fp, http)
      end
      case response
      when Net::HTTPSuccess
        break
      else
        _response(response)
      end
    end
  end

  # manage request
  def _request(uri, file, fp, http)
    request = Net::HTTP::Put.new(uri.path)
    request.content_length = File.size(file)
    request.body_stream = fp
    http.request(request)
  end

  # manage response
  def _response(response)
    puts response.to_hash.inspect
    puts response.body
    response.error!
  end
end
