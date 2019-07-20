require 'git'
require 'rainbow'
require 'sekrit/bundle'
require 'sekrit/config'
require 'sekrit/decoder'
require 'sekrit/encoder'
require "sekrit/pull"
require "sekrit/push"
require "sekrit/version"
require 'terminal-table'
require 'thor'

module Sekrit
    class Error < StandardError; end

    class CLI < Thor
        class_option :verbose, aliases: :v, type: :boolean, default: false

        desc 'push --config <path to Sekritfile> --git_ref <branch>', 'Encrypts and pushes files according to the contents of `Sekritfile`'
        option :bundle_id, aliases: :b, type: :string
        option :config, aliases: :c, type: :string, default: "#{ENV['PWD']}/Sekritfile"
        option :git_ref, aliases: :g, type: :string, default: 'master'
        option :passphrase, aliases: :p, type: :string
        option :working_directory, aliases: :d, type: :string, default: '.'
        def push
            delete_sekrit_dir_if_exist?

            begin
                print_command_config(name: "Push")

                raise Thor::Error, Rainbow("Cannot find Sekritfile at #{options[:config]}").red unless File.exist?(options[:config])

                @config = Sekrit::Config.new(path: options[:config])
                bundle_id = options[:bundle_id] || @config.bundles.first.name

                print_sekrit_config(bundle_id: bundle_id)

                @passphrase = options[:passphrase] || ENV[@config.passphrase]
                raise Thor::Error, Rainbow("passphrase cannot be nil").red if @passphrase.nil?
                raise Thor::Error, Rainbow("passphrase cannot be empty").red if @passphrase.empty?

                git_name = @config.repo.split('/').last.chomp('.git')

                bundled_dst = "#{sekrit_dir}/#{git_name}/#{bundle_id}"
                git = Git.clone(@config.repo, git_name, path: sekrit_dir)

                push = Push.new(bundle_id: bundle_id, config: @config, passphrase: @passphrase)
                push.copy_bundled_files(dir: working_directory)
                push.copy_shared_files(dir: working_directory)
            rescue => error
                delete_sekrit_dir_if_exist?
                raise Thor::Error, Rainbow(error).red
            ensure
                delete_sekrit_dir_if_exist?
            end
        end

        desc 'pull --config <path to Sekritfile> --git_ref <branch>', 'Pulls and decrypts files according to the contents of `Sekritfile`'
        option :bundle_id, aliases: :b, type: :string
        option :config, aliases: :c, type: :string, default: "#{ENV['PWD']}/Sekritfile"
        option :git_ref, aliases: :g, type: :string, default: 'master'
        option :passphrase, aliases: :p, type: :string
        option :working_directory, aliases: :d, type: :string, default: '.'
        def pull
            delete_sekrit_dir_if_exist?

            begin
                print_command_config(name: "Pull")

                raise Thor::Error, Rainbow("Cannot find Sekritfile at #{options[:config]}").red unless File.exist?(options[:config])

                @config = Sekrit::Config.new(path: options[:config])
                bundle_id = options[:bundle_id] || @config.bundles.first.name

                print_sekrit_config(bundle_id: bundle_id)

                @passphrase = options[:passphrase] || ENV[@config.passphrase]
                raise Thor::Error, Rainbow("passphrase cannot be nil").red if @passphrase.nil?
                raise Thor::Error, Rainbow("passphrase cannot be empty").red if @passphrase.empty?

                git_name = @config.repo.split('/').last.chomp('.git')

                bundled_dst = "#{sekrit_dir}/#{git_name}/#{bundle_id}"
                git = Git.clone(@config.repo, git_name, path: sekrit_dir)

                push = Pull.new(bundle_id: bundle_id, config: @config, passphrase: @passphrase)
                push.copy_bundled_files(dir: working_directory)
                push.copy_shared_files(dir: working_directory)
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
            rows << ['config file', options[:config]]
            rows << ['git reference (branch)', options[:git_ref]]
            rows << ['working directory', options[:working_directory]]
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
            rows << ['bundles', @config.bundles.map { |b| b.name }.join("\n") ]
            table = Terminal::Table.new(title: title, headings: headings, rows: rows, style: { all_separators: true })
            puts("\n" + table.to_s + "\n")
        end

        def sekrit_dir
            '.sekrit'
        end

        def working_directory
            "#{options[:working_directory]}/#{sekrit_dir}"
        end

        def delete_sekrit_dir_if_exist?
            FileUtils.remove_dir(working_directory) if Dir.exist?(working_directory)
        end

    end

end
