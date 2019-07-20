require 'yaml'

module Sekrit

    class Config
        attr_reader :bundles
        attr_reader :shared_files
        attr_reader :bundled_files
        attr_reader :passphrase
        attr_reader :repo

        def initialize(path: 'Sekritfile')
            config = YAML::load_file(path)
            @bundled_files = Bundle.new(hash: config['bundled_files'])
            @bundles       = config['bundles'].map { |b| Bundle.new(hash: b) }
            @passphrase    = config['passphrase']
            @repo          = config['repo']
            @shared_files  = Bundle.new(hash: config['shared_files'])
        end
    end

end