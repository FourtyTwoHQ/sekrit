module Sekrit

    class Push

        def initialize(bundle_id: String, config: Config, passphrase: String)
            @bundle_id = bundle_id
            @config = config
            @encoder = Encoder.new(password: passphrase)
        end

        def copy_bundled_files(dir: String)
            bundle = @config.bundles.select { |b| b.id == @bundle_id }.first
            raise Thor::Error, Rainbow("Cannot find bundle with id '#{@bundle_id}' in Sekritfile").red if bundle.nil?

            bundled_files = @config.bundled_files.files + bundle.files
            bundled_files.each do |f|
                puts "Copying '#{f}' to '#{dir}/#{bundle.id}/#{f}'"
            end

            encrypted_files = @config.bundled_files.encrypted + bundle.encrypted
            encrypted_files.each do |f|
                puts "Encrypting and copying '#{f}' to '#{dir}/#{bundle.id}/#{f}'"
            end
        end

        def copy_shared_files(dir: String)
            @config.shared_files.files.each do |f|
                puts "Copying '#{f}' to '#{dir}/shared/#{f}'"
            end

            @config.shared_files.encrypted.each do |f|
                puts "Encrypting and copying '#{f}' to '#{dir}/shared/#{f}'"
            end
        end
    end

end
