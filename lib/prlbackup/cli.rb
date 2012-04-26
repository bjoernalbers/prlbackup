module PrlBackup
  class CLI
    include Mixlib::CLI

    option :full,
      :long         => '--full',
      :short        => '-f',
      :description  => 'Create full backup',
      :boolean      => true,
      :default      => false

    option :all,
      :short => "-a",
      :long => "--all",
      :description => "Backup all virtual machines",
      :boolean => true,
      :default => false

    option :exclude,
      :short => "-e",
      :long => "--exclude",
      :description => "Exclude selected virtual machines from backup",
      :boolean => true,
      :default => false

    class << self
      def run
        self.new.run(ARGV)
      end
    end

    def run(argv)
      arguments = parse_options(argv)
      if config[:all]
        VirtualMachine.each do |vm|
          if config[:exclude]
            next if arguments.any? { |arg| vm == arg }
          end
          vm.backup
        end
      else
        VirtualMachine.new(arguments.first).backup(config[:full])
      end
    end
  end
end
