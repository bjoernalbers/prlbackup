require 'spec_helper'

module PrlBackup
  describe Command do
    describe '.run' do
      before do
        @pid = double('pid')
        @stdin = double('stdin')
        @stdout = double('stdout', :read => "")
        @stderr = double('stderr')
        @status = double('status')
        @popen4_return = [@pid, @stdin, @stdout, @stderr]
        @waitpid2_return = [nil, @status]
      end

      it 'should run a command and wait for it' do
        Open4.should_receive(:popen4).with('prlctl', 'list', '--info').and_return(@popen4_return)
        Process::should_receive(:waitpid2).with(@pid).and_return(@waitpid2_return)

        Command.run('prlctl', 'list', '--info')
      end

      it 'should return an instance of that command' do
        Open4.stub(:popen4).and_return(@popen4_return)
        Process::stub(:waitpid2).and_return(@waitpid2_return)

        Command.run('prlctl', 'list', '--info').class.should eql(Command)
      end
    end

    describe '#run' do
      it 'should capture stdout' do
        cmd = Command.new "ruby -e 'puts %q{hello, world.}'"
        cmd.run.stdout.should eql("hello, world.\n")
      end
    end
  end
end
