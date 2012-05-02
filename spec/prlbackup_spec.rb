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

      it 'should log the action which would be performed'
    end
  end

  describe '#logger' do
    before do
      @logger = double('logger')
      @logger.stub(:formatter=)
      Logger.stub(:new).and_return(@logger)
      @foo = Foo.new
    end

    it 'should initialize a new logger once' do
      Logger.should_receive(:new).once.with(STDOUT)
      2.times { @foo.logger }
    end

    it 'should return the logger' do
      @foo.logger.should eql(@logger)
    end

    it 'should flush to stdout' do
      original_sync_state = STDOUT.sync
      STDOUT.sync = false
      STDOUT.sync.should be_false
      @foo.logger
      STDOUT.sync.should be_true
      STDOUT.sync = original_sync_state 
    end
  end

  describe '#command' do
    context 'with option --verbose' do
      before do
        @foo = Foo.new
        @foo.stub(:`).and_return('')
        @logger = double('logger')
        @foo.stub(:logger).and_return(@logger)
        PrlBackup.stub(:config).and_return({:verbose => true})
      end

      it 'should log which command would be running' do
        @foo.logger.should_receive(:info).with('Running `some command`...')
        @foo.command('some', 'command')
      end
    end
  end
end
