require 'spec_helper'

module PrlBackup
  class Foo
    include PrlBackup
  end

  describe '#conditionally_run' do
    before do
      @foo = Foo.new
      @foo.stub(:run).and_return('')
      @foo.stub_chain(:logger, :info)
    end

    context 'without option --dry-run' do
      before do
        PrlBackup.stub(:config).and_return({:dry_run => false})
      end

      it 'should run the command' do
        @foo.should_receive(:run).with('hello', 'world')
        @foo.conditionally_run('hello', 'world')
      end

      it 'should return stdout from command' do
        @foo.stub(:run).and_return("hello\nworld")
        @foo.conditionally_run.should eql("hello\nworld")
      end

      it 'should log the last stdout line' do
        @foo.stub(:run).and_return("first line\nlast line")
        @foo.logger.should_receive(:info).with('last line')
        @foo.conditionally_run
      end
    end

    context 'with option --dry run' do
      before do
        PrlBackup.stub(:config).and_return({:dry_run => true})
      end

      it 'should not run the command' do
        @foo.should_not_receive(:run)
        @foo.conditionally_run
      end

      it 'should return a blank string' do
        @foo.conditionally_run.should eql('')
      end

      it 'should log the command which would be performed' do
        @foo.logger.should_receive(:info).with('Dry-running `some command`...')
        @foo.conditionally_run('some', 'command')
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

  describe '#run' do
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
        @foo.run('some', 'command')
      end
    end
  end
end
