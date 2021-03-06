require 'mixlib/cli'
require 'logger'
require 'shellwords'
require 'date'
require 'prlbackup/version'
require 'prlbackup/cli'
require 'prlbackup/virtual_machine'
require 'prlbackup/backup'

module PrlBackup
  class << self
    # The global configuration based on command line options.
    attr_accessor :config
  end

  # Run the command and log the last line from stdout unless --dry-run.
  # @return [String] stdout of the comand.
  def conditionally_run(*args)
    unless PrlBackup.config[:dry_run]
      output = run(*args)
      logger.info(output.split("\n").last)
    else
      output = ''
      logger.info("Dry-running `#{args.shelljoin}`...")
    end
    output
  end

  # Run the command until it is finished.
  # @Note This will even run when option --dry-run is selected!
  # @return [String] stdout of the comand.
  def run(*args)
    logger.info("Running `#{args.shelljoin}`...") if PrlBackup.config[:verbose]
    output = `#{args.shelljoin} 2>&1`
    status = $?
    unless status.success?
      logger.error("Command `#{args.shelljoin}` failed with exit status #{status.exitstatus}:\n#{output}")
      exit(1)
    end
    output
  end

  def logger
    @logger ||= create_logger
  end

private

  def create_logger
    STDOUT.sync = true
    l = Logger.new(STDOUT)
    l.formatter = proc { |severity, datetime, progname, msg| "prlbackup #{severity}: [#{self}] #{msg}\n" }
    l
  end
end
