require 'yaml'

module Sekrit

  class Config
    attr_reader :bundles
    attr_reader :shared_files
    attr_reader :bundled_files
    attr_reader :passphrase
    attr_reader :repo
    attr_reader :raw

    def initialize(path: 'Sekritfile')
      @raw = File.read(path)
      config = YAML::load_file(path)
      @bundled_files = Bundle.new(hash: config['bundled_files']) unless config['bundled_files'].nil?
      @bundles       = (config['bundles'] || []).map { |b| Bundle.new(hash: b) }
      @passphrase    = config['passphrase']
      @repo          = config['repo']
      @shared_files  = Bundle.new(hash: config['shared_files']) unless config['shared_files'].nil?
    end
  end

end
