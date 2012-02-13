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
      arguments = parse_options(argv)
      if config[:all]
        VirtualMachine.each do |vm|
          vm.backup
        end
      else
        VirtualMachine.new(arguments.first).backup
      end
    end
  end
end
