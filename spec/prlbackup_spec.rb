require 'spec_helper'

module PrlBackup
  class Foo
    include PrlBackup
  end

  describe '#command!' do
    before do
      @foo = Foo.new
      @foo.stub(:command).and_return('')
      @foo.stub_chain(:logger, :info)
    end

    context 'without option --dry-run' do
      before do
        PrlBackup.stub(:config).and_return({:dry_run => false})
      end

      it 'should run the command' do
        @foo.should_receive(:command).with('hello', 'world')
        @foo.command!('hello', 'world')
      end

      it 'should return stdout from command' do
        @foo.stub(:command).and_return("hello\nworld")
        @foo.command!.should eql("hello\nworld")
      end

      it 'should log the last stdout line' do
        @foo.stub(:command).and_return("first line\nlast line")
        @foo.logger.should_receive(:info).with('last line')
        @foo.command!
      end
    end

    context 'with option --dry run' do
      before do
        PrlBackup.stub(:config).and_return({:dry_run => true})
      end

      it 'should not run the command' do
        @foo.should_not_receive(:command)
        @foo.command!
      end

      it 'should return a blank string' do
        @foo.command!.should eql('')
      end
    end

    context 'with options --dry-run and --verbose' do
      before do
        PrlBackup.stub(:config).and_return({:dry_run => true, :verbose => true})
      end

      it 'should log which command would be running' do
        @foo.logger.should_receive(:info).with('Running `some command`...')
        @foo.command!('some', 'command')
      end
    end
  end

  describe '#logger' do
    before do
      @logger = double('logger')
      @logger.stub(:formatter=)
      Logger.stub(:new).and_return(@logger)
      @foo = Foo.new
    end

    it 'should initialize a new logger' do
      Logger.should_receive(:new).with(STDOUT).and_return(@logger)
      @foo.logger
    end
  end
end
