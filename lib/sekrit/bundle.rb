module Sekrit

  class Bundle
    attr_reader :encrypted
    attr_reader :files
    attr_reader :id

    def initialize(hash: Hash)
      @encrypted = hash['encrypted'] || []
      @files = hash['files'] || []
      @id = hash['id']
    end
  end

end
