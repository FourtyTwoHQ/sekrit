require 'rainbow'

module Sekrit

    class Push

        def initialize(bundle_id: String, config: Config, passphrase: String)
            @bundle_id = bundle_id
            @config = config
            @encoder = Encoder.new(password: passphrase)

            raise Thor::Error, Rainbow("Bundle id cannot be nil").red if @bundle_id.nil?
        end

        def bundle
            @config.bundles.select { |b| b.id == @bundle_id }.first
        end

        def copy_bundled_files(dir: String)
            raise Thor::Error, Rainbow("Cannot find bundle with id '#{@bundle_id}' in Sekritfile").red if bundle.nil?

            config_bundled_files = @config.bundled_files.nil? ? [] : @config.bundled_files.files
            config_bundled_files += bundle.files
            config_bundled_files.each do |f|
                dest = "#{dir}/#{bundle.id}/#{f}"
                file_path = "#{Dir.pwd}/#{f}"
                if File.exist?(file_path)
                    log.debug Rainbow("Preparing to copy '#{file_path}' to '#{dest}'").purple
                    FileUtils.mkdir_p(File.dirname(dest))
                    FileUtils.cp(f, dest)
                    log.debug Rainbow("Copied '#{file_path}' to '#{dest}'").purple
                else
                    log.warn(Rainbow("Could not find file at path '#{file_path}'").yellow)
                end
            end

            config_encrypted_files = @config.bundled_files.nil? ? [] : @config.bundled_files.encrypted
            config_encrypted_files += bundle.encrypted
            config_encrypted_files.each do |f|
                dest = "#{dir}/#{bundle.id}/#{f}"
                file_path = "#{Dir.pwd}/#{f}"
                if File.exist?(file_path)
                    log.debug Rainbow("Preparing to encrypt and copy '#{file_path}' to '#{dest}'").purple
                    FileUtils.mkdir_p(File.dirname(dest))
                    FileUtils.cp(f, dest)
                    log.debug Rainbow("Copied '#{file_path}' to '#{dest}'").purple

                    log.debug Rainbow("Preparing to encrypt '#{dest}'").purple
                    File.write(dest, @encoder.encode(string: File.read(dest)))
                    log.debug Rainbow("Encrypted '#{dest}'").purple
                else
                    log.warn(Rainbow("Could not find file at path '#{file_path}'").yellow)
                end
            end
        end

        def copy_shared_files(dir: String)
            config_shared_files = @config.shared_files.nil? ? [] : @config.shared_files.files
            config_shared_files += bundle.files
            config_shared_files.each do |f|
                dest = "#{dir}/shared/#{f}"
                file_path = "#{Dir.pwd}/#{f}"
                if File.exist?(file_path)
                    log.debug Rainbow("Preparing to copy '#{file_path}' to '#{dest}'").purple
                    FileUtils.mkdir_p(File.dirname(dest))
                    FileUtils.cp(f, dest)
                    log.debug Rainbow("Copied '#{file_path}' to '#{dest}'").purple
                else
                    log.warn(Rainbow("Could not find file at path '#{file_path}'").yellow)
                end
            end

            config_encrypted_files = @config.shared_files.nil? ? [] : @config.shared_files.encrypted
            config_encrypted_files += bundle.encrypted
            config_encrypted_files.each do |f|
                dest = "#{dir}/shared/#{f}"
                file_path = "#{Dir.pwd}/#{f}"
                if File.exist?(file_path)
                    log.debug Rainbow("Preparing to encrypt and copy '#{file_path}' to '#{dest}'").purple
                    FileUtils.mkdir_p(File.dirname(dest))
                    FileUtils.cp(f, dest)
                    log.debug Rainbow("Copied '#{file_path}' to '#{dest}'").purple

                    log.debug Rainbow("Preparing to encrypt '#{dest}'").purple
                    File.write(dest, @encoder.encode(string: File.read(dest)))
                    log.debug Rainbow("Encrypted '#{dest}'").purple
                else
                    log.warn(Rainbow("Could not find file at path '#{file_path}'").yellow)
                end
            end
        end
    end

end
