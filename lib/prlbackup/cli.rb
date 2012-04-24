module PrlBackup
  class CLI
    include Mixlib::CLI

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
      def run(argv=ARGV)
        self.new.run(argv)
      end
    end

    def run(argv)
      arguments = parse_options(argv)
      if config[:all]
        VirtualMachine.each do |vm|
          if config[:exclude]
            next if [vm.name, vm.uuid].any? { |name_or_uuid| arguments.include? name_or_uuid }
          end
          vm.backup unless arguments.any? { |a| vm.name == a || vm.uuid == a }
        end
      else
        VirtualMachine.new(arguments.first).backup
      end
    end
  end
end
