require 'spec_helper'

module PrlBackup
  describe CLI do
    describe '.run' do
      before do
        @cli = double('cli')
        @cli.stub(:run)
        CLI.stub(:new).and_return(@cli)
      end

      it 'should initialize a new instance' do
        CLI.should_receive(:new).and_return(@cli)
        CLI.run
      end

      it 'should run the new instance with ARGV' do
        @cli.should_receive(:run).with(ARGV)
        CLI.run
      end
    end

    describe '#run' do
      before do
        @vm = double('vm')
        @vm.stub(:safe_backup)
        @vm.stub(:cleanup)
        VirtualMachine.stub(:new).and_return(@vm)
        @cli = CLI.new
      end

      context 'without options' do
        before do
          VirtualMachine.should_receive(:new).with('foo').and_return(@vm)
        end

        it 'should backup each selected virtual machine' do
          @vm.should_receive(:safe_backup).once
          @cli.run %w[foo]
        end

        it 'should not perform cleanup actions' do
          @vm.should_not_receive(:cleanup)
          @cli.run %w[foo]
        end
      end

      context 'with option --all' do
        it 'should backup all virtual machines' do
          VirtualMachine.should_receive(:all).and_return([@vm, @vm])
          @vm.should_receive(:safe_backup).twice
          @cli.run %w[--all]
        end
      end

      context 'with options --all and --exclude' do
        before do
          VirtualMachine.should_receive(:all).and_return([@vm, @vm])
        end

        it 'should not backup virtual machines which are given' do
          @cli.stub(:given_virtual_machines).and_return([@vm])
          @vm.should_not_receive(:safe_backup)
          @cli.run %w[--all --exclude foo]
        end

        it 'should backup virtual machines which are not given' do
          @cli.stub(:given_virtual_machines).and_return([])
          @vm.should_receive(:safe_backup).twice
          @cli.run %w[--all --exclude foo]
        end
      end

      context 'with option --keep-only' do
        it 'should perform cleanup actions after backing up' do
          @vm.should_receive(:safe_backup).ordered
          @vm.should_receive(:cleanup).ordered
          @cli.stub(:config).and_return({:keep_only => 3})
          @cli.run %w[foo]
        end
      end
    end
  end
end
