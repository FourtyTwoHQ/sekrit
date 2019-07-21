module Sekrit

    class Runner

        def initialize(name: String, options: Hash, driver: lambda)
            @name = name
            @options = options
            @driver = driver
        end

        def run
            delete_sekrit_dir_if_exist?

            begin
                print_command_config(name: @name)

                raise Thor::Error, Rainbow("Cannot find Sekritfile at #{@options[:config]}").red unless File.exist?(@options[:config])

                @config = Sekrit::Config.new(path: @options[:config])
                bundle_id = @options[:bundle_id] || @config.bundles.first.id

                print_sekrit_config(bundle_id: bundle_id)

                @passphrase = @options[:passphrase] || ENV[@config.passphrase]
                raise Thor::Error, Rainbow("passphrase cannot be nil").red if @passphrase.nil?
                raise Thor::Error, Rainbow("passphrase cannot be empty").red if @passphrase.empty?

                git_name = @config.repo.split('/').last.chomp('.git')
                git = Git.clone(@config.repo, git_name, path: sekrit_dir)

                directory = "#{working_directory}/#{git_name}"
                driver = @driver.call(bundle_id, @config, @passphrase)
                driver.copy_bundled_files(dir: directory)
                driver.copy_shared_files(dir: directory)
            rescue => error
                delete_sekrit_dir_if_exist?
                raise Thor::Error, Rainbow(error).red
            ensure
                delete_sekrit_dir_if_exist?
            end
        end

        private

        def print_command_config(name: String)
            title = Rainbow("Sekrit #{name}").green
            headings = ['Option', 'Value']
            rows = []
            rows << ['config file', @options[:config]]
            rows << ['git reference (branch)', @options[:git_ref]]
            rows << ['working directory', @options[:working_directory]]
            table = Terminal::Table.new(title: title, headings: headings, rows: rows)
            puts("\n" + table.to_s + "\n")
        end

        def print_sekrit_config(bundle_id: String)
            title = Rainbow('Sekrit Config').green
            headings = ['Option', 'Value']
            rows = []
            rows << ['bundle_id', bundle_id]
            rows << ['repo', @config.repo]
            rows << ['passphrase key', @config.passphrase]
            rows << ['shared_files', @config.shared_files.files.nil? ? '<none>' : @config.shared_files.files.map { |f| '- ' + f }.join("\n")]
            rows << ['shared_encrypted', @config.shared_files.encrypted.nil? ? '<none>' : @config.shared_files.encrypted.map { |f| '- ' + f }.join("\n")]
            rows << ['bundled_files', @config.bundled_files.files.nil? ? '<none>' : @config.bundled_files.files.map { |f| '- ' + f }.join("\n")]
            rows << ['bundled_encrypted', @config.bundled_files.encrypted.nil? ? '<none>' : @config.bundled_files.encrypted.map { |f| '- ' + f }.join("\n")]
            rows << ['bundles', @config.bundles.map { |b| b.id }.join("\n") ]
            table = Terminal::Table.new(title: title, headings: headings, rows: rows, style: { all_separators: true })
            puts("\n" + table.to_s + "\n")
        end

        def sekrit_dir
            '.sekrit'
        end

        def working_directory
            "#{@options[:working_directory]}/#{sekrit_dir}"
        end

        def delete_sekrit_dir_if_exist?
            FileUtils.remove_dir(working_directory) if Dir.exist?(working_directory)
        end
    end
end
