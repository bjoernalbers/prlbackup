module PrlBackup
  class VirtualMachine
    include PrlBackup

    def initialize(name)
      @name = name
      @command = Command
      @shutdown = nil
    end

    def backup
      @command.stop(uuid) if shutdown?
      @command.backup(uuid)
      @command.start(uuid) if shutdown?
      logger.info("Incremental backup of #{@name} #{uuid} successfully created")
    end

    def shutdown?
      @shutdown = !stopped? if @shutdown.nil?
      @shutdown
    end

    def stopped?
      @command.list("--info \"#{uuid}\"")[/^State:\s+stopped$/]
    end

    def uuid
      @uuid ||= @command.list("--info \"#{@name}\"")[/^ID:\s+(\{[a-f0-9-]+\})$/,1]
    end
  end
end
