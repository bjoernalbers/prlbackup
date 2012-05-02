module PrlBackup
  class CLI
    include Mixlib::CLI

    option :full,
      :long         => '--full',
      :short        => '-f',
      :description  => 'Create full backups.',
      :boolean      => true,
      :default      => false

    option :all,
      :long         => '--all',
      :short        => '-a',
      :description  => 'Backup all virtual machines.',
      :boolean      => true,
      :default      => false

    option :verbose,
      :long         => '--verbose',
      :short        => '-v',
      :description  => 'Display commands before executing them.',
      :boolean      => 'true',
      :default      => false

    option :exclude,
      :long         => '--exclude',
      :short        => '-e',
      :description  => 'Exclude given virtual machines from backup (in combination with --all).',
      :boolean      => true,
      :default      => false

    option :dry_run,
      :long         => '--dry-run',
      :short        => '-n',
      :description  => 'Don\'t run commands with an impact on VMs (display them instead).',
      :boolean      => true,
      :default      => false

    option :keep_only,
      :long         => '--keep-only n',
      :short        => '-k n',
      :description  => 'Keep only n full backups (delete the oldest!)',
      :proc         => Proc.new { |k| k.to_i }

    class << self
      # Run the backups with given options and arguments.
      def start
        self.new.start(ARGV)
      end
    end

    # Parse options and create safe backups for the selected virtual machines.
    def start(argv)
      parse_options!(argv)
      selected_virtual_machines.each do |vm|
        vm.safely_backup
        vm.cleanup if config[:keep_only]
      end
    end

  private

    # Parse options and set global configuration.
    def parse_options!(argv)
      @arguments = parse_options(argv)
      PrlBackup.config = config
    end

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
