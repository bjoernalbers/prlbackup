module PrlBackup
  class VirtualMachine
    include PrlBackup

    class << self
      def each
        all_uuids.each { |uuid| yield(new(uuid)) }
      end

      def all_uuids
        Command2.run('prlctl', 'list', '--all').stdout.split("\n").grep(/^(\{[a-f0-9-]+\})\s/){$1}
      end
    end

    def initialize(name)
      @name = name
      @command = Command2
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
