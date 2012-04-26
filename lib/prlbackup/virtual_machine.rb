module PrlBackup
  class VirtualMachine
    include PrlBackup

    class << self
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

    # Create backup of the virtual machine.
    # @note A running virtual machine will be stopped during the backup!
    def backup(full=false)
      run('prlctl', 'stop', @name_or_uuid) if shutdown?
      cmd = ['prlctl', 'backup', @name_or_uuid]
      cmd << '--full' if full
      run(*cmd)
      run('prlctl', 'start', @name_or_uuid) if shutdown?
      #logger.info("Incremental backup of #{name} #{uuid} successfully created")
    end

    def shutdown?
      @shutdown = !stopped? if @shutdown.nil?
      @shutdown
    end

    def stopped?
      cmd = ['prlctl', 'list', "--info", @name_or_uuid]
      run(*cmd).stdout[/^State:\s+stopped$/]
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

    def run(*args)
      Command.run(*args)
    end

    # Get infos about the VM
    def info
      @info ||= run('prlctl', 'list', '--info', @name_or_uuid).stdout
    end

    # Is equal if object is equal with the virtual machine's name or uuid.
    def ==(obj)
      name == obj || uuid == obj
    end
  end
end
