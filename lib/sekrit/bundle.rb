module Sekrit

    class Bundle
        attr_reader :encrypted
        attr_reader :files
        attr_reader :name

        def initialize(hash: Hash)
            @encrypted = hash['encrypted']
            @files = hash['files']
            @name = hash['name']
        end
    end

end