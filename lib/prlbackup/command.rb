module PrlBackup
  class Command
    class << self
      include PrlBackup
      
      [:list, :stop, :backup, :start].each do |action|
        define_method action do |args|
          run(action, args)
        end
      end

      def run(action, *args)
        cmd = (["prlctl", action] + args).compact * ' '
        logger.debug("Running `#{cmd}`:")
        out = `#{cmd} 2>&1`.strip
        unless $?.success?
            error_msg = "`#{cmd}` failed with exit status #{$?.exitstatus}: #{out}"
          logger.error(error_msg)
          raise(PrlctlError, error_msg)
        end
        logger.debug(out)
        out
      end
    end
  end
end
