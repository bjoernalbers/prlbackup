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
      @info = Command.run('prlctl', 'list', '--info', name_or_uuid).stdout
      @command = Command
      @shutdown = nil
    end

    # Create backup of the virtual machine.
    # @note A running virtual machine will be stopped during the backup!
    def backup
      @command.run('prlctl', 'stop', uuid) if shutdown?
      @command.run('prlctl', 'backup', uuid)
      @command.run('prlctl', 'start', uuid) if shutdown?
      logger.info("Incremental backup of #{name} #{uuid} successfully created")
    end

    def shutdown?
      @shutdown = !stopped? if @shutdown.nil?
      @shutdown
    end

    def stopped?
      cmd = ['prlctl', 'list', "--info", uuid]
      @command.run(*cmd).stdout[/^State:\s+stopped$/]
    end

    # Return the virtual machine's name.
    # @return [String]
    def name
      @info[/^Name:\s+(.+)$/,1]
    end

    # Return the virtual machine's UUID.
    # @return [String]
    def uuid
      @info[/^ID:\s+(\{[a-f0-9-]+\})$/,1]
    end
  end
end
