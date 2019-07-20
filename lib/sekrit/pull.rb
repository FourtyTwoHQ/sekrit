module Sekrit

    class Pull

        def initialize(bundle_id: String, config: Config, passphrase: String)
            @bundle_id = bundle_id
            @config = config
            @encoder = Decoder.new(password: passphrase)
        end

        def copy_bundled_files(dir: String)
            bundle = @config.bundles.select { |b| b.id == @bundle_id }.first
            raise Thor::Error, Rainbow("Cannot find bundle with id '#{@bundle_id}' in Sekritfile").red if bundle.nil?

            bundled_files = @config.bundled_files.files + bundle.files
            bundled_files.each do |f|
                puts "Copying '#{dir}/#{bundle.id}/#{f}' to '#{f}'"
            end

            encrypted_files = @config.bundled_files.encrypted + bundle.encrypted
            encrypted_files.each do |f|
                puts "Decryptingg and copying '#{dir}/#{bundle.id}/#{f}' to '#{f}'"
            end
        end

        def copy_shared_files(dir: String)
            @config.shared_files.files.each do |f|
                puts "Copying '#{dir}/shared/#{f}' to '#{f}'"
            end

            @config.shared_files.encrypted.each do |f|
                puts "Decryptingg and copying '#{dir}/shared/#{f}' to '#{f}'"
            end
        end
    end

end
