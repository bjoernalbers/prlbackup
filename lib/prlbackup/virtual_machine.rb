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
        run(*cmd).split("\n").grep(/(\{[a-f0-9-]+\})/) { new($1) }
      end
    end

    # Initialize with a valid name or UUID from the virtual machine.
    def initialize(name_or_uuid)
      @name_or_uuid = name_or_uuid
      update_info
    end

    def config
      PrlBackup.config
    end

    # Safely backup the virtual machine.
    # @note A running virtual machine will be stopped during the backup!
    def safely_backup(full=false)
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
      info[/^Name:\s+(.+)$/,1] if info
    end

    # Return the virtual machine's UUID.
    # @return [String]
    def uuid
      info[/^ID:\s+(\{[a-f0-9-]+\})$/,1] if info
    end

    # Is equal if the virtual machines UUIDs are equal.
    def ==(other_vm)
      uuid == other_vm.uuid
    end

    # Return the name of the virtual machine.
    def to_s
      name || 'Unknown VM'
    end

  private

    # Info string about the virtual machine.
    # @Note These infos will only be updated when calling `update_info`.
    attr_reader :info

    # Start the virtual machine.
    def start
      conditionally_run('prlctl', 'start', uuid)
    end

    # Stop the virtual machine.
    def stop
      conditionally_run('prlctl', 'stop', uuid)
    end

    # Backup the virtual machine.
    def backup
      cmd = ['prlctl', 'backup', uuid]
      cmd << '--full' if config[:full]
      conditionally_run(*cmd)
    end

    # Update and return info string for the virtual machine.
    # @return [String] infos
    def update_info
      @info = run('prlctl', 'list', '--info', @name_or_uuid)
    end

    def stopped?
      update_info[/^State:\s+stopped$/]
    end

    # List of full backups for the virtual machine.
    def full_backups
      run('prlctl', 'backup-list', uuid).split("\n").map { |l| $1 if l[/^\{[a-f0-9-]+\}\s+(\{[a-f0-9-]+\})[^(\.\d+)]/] }.compact
    end

    # Delete the backup given by backup UUID.
    def delete_backup(backup_uuid)
      conditionally_run('prlctl', 'backup-delete', '--tag', backup_uuid)
    end
  end
end
