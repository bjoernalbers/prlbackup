module PrlBackup
  class CLI
    include Mixlib::CLI

    option :all,
      :short => "-a",
      :long => "--all",
      :description => "Backup all virtual machines",
      :boolean => true,
      :default => false

    class << self
      def run(argv=ARGV)
        self.new.run(argv)
      end
    end

    def run(argv)
      args = parse_options(argv)
      VirtualMachine.new(args.first).backup
    end
  end
end
