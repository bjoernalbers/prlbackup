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

  describe '#command' do
    before do
      @foo = Foo.new
      @pid = double('pid')
      @stdin = double('stdin')
      @stdout = double('stdout', :read => "")
      @stderr = double('stderr')
      @status = double('status')
      @status.stub(:success?).and_return(true)
      @popen4_return = [@pid, @stdin, @stdout, @stderr]
      @waitpid2_return = [nil, @status]
      Open4.stub(:popen4).and_return(@popen4_return)
      Process.stub(:waitpid2).and_return(@waitpid2_return)
      PrlBackup.stub(:config).and_return({:verbose => false})
    end

    it 'should run a command and wait for it' do
      Open4.should_receive(:popen4).with('hello', 'world').and_return(@popen4_return)
      Process::should_receive(:waitpid2).with(@pid).and_return(@waitpid2_return)
      @foo.command('hello', 'world')
    end

    it 'should read and return the stdout' do
      @stdout.stub(:read).and_return('hello')
      @foo.command("ruby -e 'puts %q{hello}'").should eql('hello')
    end

    context 'with a failing command' do
      before do
        @foo.stub(:exit)
        @foo.stub_chain(:logger, :error)
        @status.stub(:success?).and_return(false)
        @stdout.stub(:read).and_return('stdout')
        @stderr.stub(:read).and_return('stderr')
        @status.stub(:exitstatus).and_return(42)
      end

      it 'should log failing commands' do
        @foo.logger.should_receive(:error).with("Command `some command` failed with exit status 42:\nstdoutstderr")
        output = @foo.command('some', 'command')
      end

      it 'should exit immediately' do
        @foo.should_receive(:exit).with(1)
        @foo.command('some', 'command')
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
