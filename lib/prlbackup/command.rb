module PrlBackup
  class Command
    attr_reader :stdout

    class << self
      def run(*cmd)
        self.new(*cmd).run
      end
    end
    
    def initialize(*cmd)
      @cmd = cmd
      @stdout = @stderr = @status = nil
    end

    def run
      pid, stdin, stdout, stderr = Open4::popen4(*@cmd)
      ignored, status = Process::waitpid2(pid)
      @stdout = stdout.read
    end
  end
end
