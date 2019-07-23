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
                git = Git.clone(@config.repo, git_name, path: sekrit_dir, log: log)
                begin
                    git.checkout(@options[:git_ref])
                    log.info Rainbow("Checking out #{@options[:git_ref]}").blue
                rescue
                    git.branch(@options[:git_ref]).checkout
                    log.info Rainbow("Creating new branch #{@options[:git_ref]}").blue
                end

                directory = "#{working_directory}/#{git_name}"
                driver = @driver.call(bundle_id, @config, @passphrase)
                driver.copy_bundled_files(dir: directory)
                driver.copy_shared_files(dir: directory)

                if driver.class == Push
                    log.info Rainbow("git adding...").green
                    git.add
                    log.info Rainbow("git committing...").green
                    git.commit "[Sekrit] Updating files for #{bundle_id}"
                    log.info Rainbow("git pushing...").green
                    git.push(git.remote('origin'), git.branch(@options[:git_ref]))
                    log.info Rainbow("git completed!").green
                end

            rescue => error
                log.warn Rainbow("git repo at `#{sekrit_dir}/#{git_name}` was not deleted").yellow
                raise Thor::Error, Rainbow(error.full_message).red
            end

            delete_sekrit_dir_if_exist?
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
            rows << ['bundles', @config.bundles.map { |b| '- ' + b.id }.join("\n") ]

            if @config.shared_files.nil?
                rows << ['shared_files', '<does not exist in Sekritfile>']
            else
                rows << ['shared_files', @config.shared_files.files.nil? ? '<none>' : @config.shared_files.files.map { |f| '- ' + f }.join("\n")]
                rows << ['shared_encrypted', @config.shared_files.encrypted.nil? ? '<none>' : @config.shared_files.encrypted.map { |f| '- ' + f }.join("\n")]
            end

            if @config.bundled_files.nil?
                rows << ['bundled_files', '<does not exist in Sekritfile>']
            else
                rows << ['bundled_files', @config.bundled_files.files.nil? ? '<none>' : @config.bundled_files.files.map { |f| '- ' + f }.join("\n")]
                rows << ['bundled_encrypted', @config.bundled_files.encrypted.nil? ? '<none>' : @config.bundled_files.encrypted.map { |f| '- ' + f }.join("\n")]
            end

            rows << ['Sekrifile', @config.raw]

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
