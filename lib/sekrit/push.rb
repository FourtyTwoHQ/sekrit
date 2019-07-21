module Sekrit

    class Push

        def initialize(bundle_id: String, config: Config, passphrase: String)
            @bundle_id = bundle_id
            @config = config
            @encoder = Encoder.new(password: passphrase)

            raise Thor::Error, Rainbow("Bundle id cannot be nil").red if @bundle_id.nil?
        end

        def copy_bundled_files(dir: String)
            bundle = @config.bundles.select { |b| b.id == @bundle_id }.first
            raise Thor::Error, Rainbow("Cannot find bundle with id '#{@bundle_id}' in Sekritfile").red if bundle.nil?

            bundled_files = @config.bundled_files.files + bundle.files
            bundled_files.each do |f|
                dest = "#{dir}/#{bundle.id}/#{f}"
                file_path = "#{Dir.pwd}/#{f}"
                if File.exist?(file_path)
                    log.debug "Preparing to copy '#{file_path}' to '#{dest}'"
                    FileUtils.mkdir_p(File.dirname(dest))
                    FileUtils.cp(f, dest)
                    log.debug "Copied '#{file_path}' to '#{dest}'"
                else
                    log.warn("Could not find file at path '#{file_path}'")
                end
            end

            encrypted_files = @config.bundled_files.encrypted + bundle.encrypted
            encrypted_files.each do |f|
                dest = "#{dir}/#{bundle.id}/#{f}"
                file_path = "#{Dir.pwd}/#{f}"
                if File.exist?(file_path)
                    log.debug "Preparing to encrypt and copy '#{file_path}' to '#{dest}'"
                    FileUtils.mkdir_p(File.dirname(dest))
                    FileUtils.cp(f, dest)
                    log.debug "Copied '#{file_path}' to '#{dest}'"

                    log.debug "Preparing to encrypt '#{dest}'"
                    File.write(dest, @encoder.encode(string: File.read(dest)))
                    log.debug "Encrypted '#{dest}'"
                else
                    log.warn("Could not find file at path '#{file_path}'")
                end
            end
        end

        def copy_shared_files(dir: String)
            @config.shared_files.files.each do |f|
                dest = "#{dir}/shared/#{f}"
                file_path = "#{Dir.pwd}/#{f}"
                if File.exist?(file_path)
                    log.debug "Preparing to copy '#{file_path}' to '#{dest}'"
                    FileUtils.mkdir_p(File.dirname(dest))
                    FileUtils.cp(f, dest)
                    log.debug "Copied '#{file_path}' to '#{dest}'"
                else
                    log.warn("Could not find file at path '#{file_path}'")
                end
            end

            @config.shared_files.encrypted.each do |f|
                dest = "#{dir}/shared/#{f}"
                file_path = "#{Dir.pwd}/#{f}"
                if File.exist?(file_path)
                    log.debug "Preparing to encrypt and copy '#{file_path}' to '#{dest}'"
                    FileUtils.mkdir_p(File.dirname(dest))
                    FileUtils.cp(f, dest)
                    log.debug "Copied '#{file_path}' to '#{dest}'"

                    log.debug "Preparing to encrypt '#{dest}'"
                    File.write(dest, @encoder.encode(string: File.read(dest)))
                    log.debug "Encrypted '#{dest}'"
                else
                    log.warn("Could not find file at path '#{file_path}'")
                end
            end
        end
    end

end
