require 'git'
require 'rainbow'
require 'sekrit/bundle'
require 'sekrit/config'
require 'sekrit/decoder'
require 'sekrit/encoder'
require 'sekrit/logger'
require 'sekrit/pull'
require 'sekrit/push'
require 'sekrit/runner'
require 'sekrit/version'
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
      configure_logger(verbose: options[:verbose])
      driver = lambda do |bundle_id, config, passphrase|
        Push.new(
          bundle_id: bundle_id,
          config: config,
          passphrase: passphrase
        )
      end

      runner = Runner.new(name: 'Push', options: options, driver: driver)
      runner.run
    end

    desc 'pull --config <path to Sekritfile> --git_ref <branch>', 'Pulls and decrypts files according to the contents of `Sekritfile`'
    option :bundle_id, aliases: :b, type: :string
    option :config, aliases: :c, type: :string, default: "#{ENV['PWD']}/Sekritfile"
    option :git_ref, aliases: :g, type: :string, default: 'master'
    option :passphrase, aliases: :p, type: :string
    option :working_directory, aliases: :d, type: :string, default: '.'
    def pull
      configure_logger(verbose: options[:verbose])
      driver = lambda do |bundle_id, config, passphrase|
        Pull.new(
          bundle_id: bundle_id,
          config: config,
          passphrase: passphrase
        )
      end

      runner = Runner.new(name: 'Pull', options: options, driver: driver)
      runner.run
    end

      private

    def configure_logger(verbose: Boolean)
      log.level = verbose ? Logger::DEBUG : Logger::INFO
    end
  end

end
