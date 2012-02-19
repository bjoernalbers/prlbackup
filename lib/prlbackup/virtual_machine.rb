module PrlBackup
  class VirtualMachine
    include PrlBackup

    class << self
      def each
        all.each { |virtual_machine| yield(virtual_machine) }
      end

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

    def name
      @info[/^Name:\s+(.+)$/,1]
    end

    def uuid
      @info[/^ID:\s+(\{[a-f0-9-]+\})$/,1]
    end
  end
end
