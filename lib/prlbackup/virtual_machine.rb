module PrlBackup
  class VirtualMachine
    include PrlBackup

    class << self
      include Enumerable
      include PrlBackup

      # Iterate over all virtual machines.
      # @param [Block]
      def each
        all.each { |virtual_machine| yield(virtual_machine) }
      end

      # Return a list of all virtual machines.
      # @return [Array<VirtualMachine>]
      def all
        cmd = %w{prlctl list --all --output uuid}
        run!(*cmd).split("\n").grep(/(\{[a-f0-9-]+\})/) { new($1) }
      end
    end

    # Initialize with a valid name or UUID from the virtual machine.
    def initialize(name_or_uuid)
      @name_or_uuid = name_or_uuid
    end

    def config
      PrlBackup.config
    end

    # Safely backup the virtual machine.
    # @note A running virtual machine will be stopped during the backup!
    def safe_backup(full=false)
      logger.info('Starting backup...')
      stopped? ? backup : (stop; backup; start)
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

    # Return the name of the virtual machine.
    def to_s
      name
    end

  private

    # Start the virtual machine.
    def start
      run('prlctl', 'start', uuid)
    end

    # Stop the virtual machine.
    def stop
      run('prlctl', 'stop', uuid)
    end

    # Backup the virtual machine.
    def backup
      cmd = ['prlctl', 'backup', uuid]
      cmd << '--full' if config[:full]
      run(*cmd)
    end

    # Return infos for the virtual machine.
    # @Note These infos will only be updated when calling `info!`.
    # @return [String] infos
    def info
      @info ||= info!
    end

    # Update and return infos for the virtual machine.
    # @return [String] infos
    def info!
      @info = run!('prlctl', 'list', '--info', @name_or_uuid)
    end

    def stopped?
      info![/^State:\s+stopped$/]
    end

    # List of full backups for the virtual machine.
    def full_backups
      run!('prlctl', 'backup-list', uuid).split("\n").map { |l| $1 if l[/^\{[a-f0-9-]+\}\s+(\{[a-f0-9-]+\})[^(\.\d+)]/] }.compact
    end

    # Delete the backup given by backup UUID.
    def delete_backup(backup_uuid)
      run('prlctl', 'backup-delete', '--tag', backup_uuid)
    end
  end
end
