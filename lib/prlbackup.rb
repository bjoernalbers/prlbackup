require 'mixlib/cli'
require 'logger'
require 'open4'
require 'shellwords'
require 'prlbackup/version'
require 'prlbackup/cli'
require 'prlbackup/virtual_machine'

module PrlBackup
  class << self
    # The global configuration based on command line options.
    attr_accessor :config
  end

  # Run the command and log the last line from stdout unless --dry-run.
  # @return [String] stdout of the comand.
  def run(*args)
    logger.info("Running `#{args.shelljoin}`...") if PrlBackup.config[:verbose]
    unless PrlBackup.config[:dry_run]
      output = run!(*args)
      logger.info(output.split("\n").last)
    else
      output = ''
    end
    output
  end

  # Run the command until it is finished.
  # @Note This will even run when option --dry-run is selected!
  # @return [String] stdout of the comand.
  def run!(*args)
    pid, stdin, stdout, stderr = Open4::popen4(*args)
    ignored, status = Process::waitpid2(pid)
    unless status.success?
      logger.error("Command `#{args.shelljoin}` failed with exit status #{status.exitstatus}:\n#{stdout.read}#{stderr.read}")
      exit(1)
    end
    stdout.read
  end

  def logger
    @logger ||= create_logger
  end

private

  def create_logger
    l = Logger.new(STDOUT)
    l.formatter = proc { |severity, datetime, progname, msg| "prlbackup #{severity}: [#{self}] #{msg}\n" }
    l
  end
end
