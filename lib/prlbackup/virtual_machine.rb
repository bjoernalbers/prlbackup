module PrlBackup
  class VirtualMachine
    include PrlBackup

    class << self
      include Enumerable

      # Iterate over all virtual machines.
      # @param [Block]
      def each
        all.each { |virtual_machine| yield(virtual_machine) }
      end

      # Return a list of all virtual machines.
      # @return [Array<VirtualMachine>]
      def all
        cmd = %w{prlctl list --all --output uuid}
        Command.run(*cmd).stdout.split("\n").grep(/(\{[a-f0-9-]+\})/) { new($1) }
      end
    end

    def initialize(name_or_uuid)
      @name_or_uuid = name_or_uuid
      @shutdown = nil
    end

    def config
      PrlBackup.config
    end

    # Safely backup the virtual machine.
    # @note A running virtual machine will be stopped during the backup!
    def safe_backup(full=false)
      stop if shutdown?
      backup
      start if shutdown?
      ###logger.info("Incremental backup of #{name} #{uuid} successfully created")
    end

    # Cleanup (delete) old backups.
    def cleanup
      backups = full_backups
      delete_backup(backups.shift) while backups.count > config[:keep_only]
    end

    # Return the virtual machine's name.
    # @return [String]
    def name
      info[/^Name:\s+(.+)$/,1]
    end

    # Return the virtual machine's UUID.
    # @return [String]
    def uuid
      info[/^ID:\s+(\{[a-f0-9-]+\})$/,1]
    end

    # Is equal if the virtual machines UUIDs are equal.
    def ==(other_vm)
      uuid == other_vm.uuid
    end

  private

    # Start the virtual machine.
    def start
      maybe_run('prlctl', 'start', uuid)
    end

    # Stop the virtual machine.
    def stop
      maybe_run('prlctl', 'stop', uuid)
    end

    # Backup the virtual machine.
    def backup
      cmd = ['prlctl', 'backup', uuid]
      cmd << '--full' if config[:full]
      maybe_run(*cmd)
    end

    def shutdown?
      @shutdown = !stopped? if @shutdown.nil?
      @shutdown
    end

    # Get infos about the VM
    def info
      @info ||= run('prlctl', 'list', '--info', @name_or_uuid).stdout
    end

    # Run the command unless option --dry-run is given.
    def maybe_run(*args)
      run(*args) unless config[:dry_run]
    end

    # Run the command.
    def run(*args)
      Command.run(*args)
    end

    def stopped?
      cmd = ['prlctl', 'list', "--info", @name_or_uuid]
      run(*cmd).stdout[/^State:\s+stopped$/]
    end

    # List of full backups for the virtual machine.
    def full_backups
      run('prlctl', 'backup-list', uuid).stdout.split("\n").map { |l| $1 if l[/^\{[a-f0-9-]+\}\s+(\{[a-f0-9-]+\})[^(\.\d+)]/] }.compact
    end

    # Delete the backup given by backup UUID.
    def delete_backup(backup_uuid)
      maybe_run('prlctl', 'backup-delete', '--tag', backup_uuid)
    end
  end
end
