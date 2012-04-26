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
        @vm.stub(:backup)
        VirtualMachine.stub(:new).and_return(@vm)
        @cli = CLI.new
      end

      context 'without options' do
        it 'should backup each selected virtual machine' do
          VirtualMachine.should_receive(:new).with('foo').and_return(@vm)
          @vm.should_receive(:backup).once
          @cli.run %w[foo]
        end
      end

      context 'with option --all' do
        it 'should backup all virtual machines' do
          VirtualMachine.should_receive(:all).and_return([@vm, @vm])
          @vm.should_receive(:backup).twice
          @cli.run %w[--all]
        end
      end

      context 'with options --all and --exclude' do
        it 'should backup all but not the selected virtual machines' do
          VirtualMachine.should_receive(:all).and_return([@vm, @vm])
          @vm.should_receive(:==).with('foo').and_return(true, false)
          @vm.should_receive(:backup).once
          @cli.run %w[--all --exclude foo]
        end
      end
    end
  end
end
