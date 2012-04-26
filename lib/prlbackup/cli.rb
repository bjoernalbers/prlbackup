module PrlBackup
  class CLI
    include Mixlib::CLI

    option :full,
      :long         => '--full',
      :short        => '-f',
      :description  => 'Create full backup.',
      :boolean      => true,
      :default      => false

    option :all,
      :long         => '--all',
      :short        => '-a',
      :description  => 'Backup all virtual machines.',
      :boolean      => true,
      :default      => false

    option :exclude,
      :long         => '--exclude',
      :short        => '-e',
      :description  => 'Exclude given virtual machines from backup.',
      :boolean      => true,
      :default      => false

    class << self
      # Run the backups with given options and arguments.
      def run
        self.new.run(ARGV)
      end
    end

    # Parse options and run backups.
    def run(argv)
      @arguments = parse_options(argv)
      selected_virtual_machines.each do |vm|
        vm.backup(config[:full])
      end
    end

  private

    # The list of selected virtual machines which will be backed up.
    # Note that this selection is based on the options and arguments.
    # @return [Array<VirtualMachine>]
    def selected_virtual_machines
      case
      when config[:all] && config[:exclude]
        VirtualMachine.select { |vm| !given_virtual_machines.include?(vm) }
      when config[:all]
        VirtualMachine.all
      else
        given_virtual_machines
      end
    end

    # The list of virtual machines given as arguments via ARGV.
    # @return [Array<VirtualMachine>]
    def given_virtual_machines
      @given_virtual_machines ||= @arguments.map { |a| VirtualMachine.new(a) }
    end
  end
end
