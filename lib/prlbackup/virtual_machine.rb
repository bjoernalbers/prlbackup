module PrlBackup
  class VirtualMachine
    include PrlBackup

    attr_reader :name
    
    class << self
      def each
        all.each { |virtual_machine| yield(virtual_machine) }
      end

      def all
        cmd = %w{prlctl list --all --output uuid}
        Command.run(*cmd).stdout.split("\n").grep(/(\{[a-f0-9-]+\})/) { new($1) }
      end
    end

    def initialize(name)
      @name = name
      @command = Command
      @shutdown = nil
    end

    def backup
      @command.run('prlctl', 'stop', uuid) if shutdown?
      @command.run('prlctl', 'backup', uuid)
      @command.run('prlctl', 'start', uuid) if shutdown?
      logger.info("Incremental backup of #{@name} #{uuid} successfully created")
    end

    def shutdown?
      @shutdown = !stopped? if @shutdown.nil?
      @shutdown
    end

    def stopped?
      @command.run('prlctl', 'list', "--info", uuid).stdout[/^State:\s+stopped$/]
    end

    def uuid
      @uuid ||= @command.run('prlctl', 'list', "--info", @name).stdout[/^ID:\s+(\{[a-f0-9-]+\})$/,1]
    end
  end
end
