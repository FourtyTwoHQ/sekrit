module Sekrit

    class Pull

        def initialize(bundle_id: String, config: Config, passphrase: String)
            @bundle_id = bundle_id
            @config = config
            @decoder = Decoder.new(password: passphrase)

            raise Thor::Error, Rainbow("Bundle id cannot be nil").red if @bundle_id.nil?
        end

        def copy_bundled_files(dir: String)
            bundle = @config.bundles.select { |b| b.id == @bundle_id }.first
            raise Thor::Error, Rainbow("Cannot find bundle with id '#{@bundle_id}' in Sekritfile").red if bundle.nil?

            bundled_files = @config.bundled_files.files + bundle.files
            bundled_files.each do |f|
                src = "#{dir}/#{bundle.id}/#{f}"
                file_path = "#{Dir.pwd}/#{f}"
                if File.exist?(src)
                    log.debug "Preparing to copy '#{src}' to '#{file_path}'"
                    FileUtils.cp(src, f)
                    log.debug "Copied '#{src}' to '#{file_path}'"
                else
                    log.warn("Could not find file at path '#{src}'")
                end
            end

            encrypted_files = @config.bundled_files.encrypted + bundle.encrypted
            encrypted_files.each do |f|
                src = "#{dir}/#{bundle.id}/#{f}"
                file_path = "#{Dir.pwd}/#{f}"
                if File.exist?(src)
                    log.debug "Preparing to decrypt and copy '#{src}' to '#{file_path}'"
                    FileUtils.cp(src, f)
                    log.debug "Copied '#{src}' to '#{file_path}'"

                    log.debug "Preparing to decrypt '#{file_path}'"
                    File.write(file_path, @decoder.decode(string: File.read(file_path)))
                    log.debug "Decrypted '#{file_path}'"
                else
                    log.warn("Could not find file at path '#{src}'")
                end
            end
        end

        def copy_shared_files(dir: String)
            @config.shared_files.files.each do |f|
                src = "#{dir}/shared/#{f}"
                file_path = "#{Dir.pwd}/#{f}"
                if File.exist?(src)
                    log.debug "Preparing to copy '#{src}' to '#{file_path}'"
                    FileUtils.cp(src, f)
                    log.debug "Copied '#{src}' to '#{file_path}'"
                else
                    log.warn("Could not find file at path '#{src}'")
                end
            end

            @config.shared_files.encrypted.each do |f|
                src = "#{dir}/shared/#{f}"
                file_path = "#{Dir.pwd}/#{f}"
                if File.exist?(src)
                    log.debug "Preparing to decrypt and copy '#{src}' to '#{file_path}'"
                    FileUtils.cp(src, f)
                    log.debug "Copied '#{src}' to '#{file_path}'"

                    log.debug "Preparing to decrypt '#{file_path}'"
                    File.write(file_path, @decoder.decode(string: File.read(file_path)))
                    log.debug "Dencrypted '#{file_path}'"
                else
                    log.warn("Could not find file at path '#{src}'")
                end
            end
        end
    end

end
