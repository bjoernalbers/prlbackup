require 'mixlib/cli'
require 'logger'
require 'open4'
require 'prlbackup/version'
require 'prlbackup/cli'
require 'prlbackup/virtual_machine'
require 'prlbackup/command'

module PrlBackup
  def logger
    @logger ||= Logger.new(STDOUT)
  end
end
