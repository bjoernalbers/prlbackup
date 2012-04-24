require 'spec_helper'

module PrlBackup
  describe VirtualMachine do
    describe '#backup' do
      it 'should ...'
    end

    describe '.each' do
      it 'should iterate over all virtual machines' do
        virtual_machines = []
        3.times { |i| virtual_machines << mock("virtual_machine_#{i}") }
        virtual_machines.map { |vm| vm.should_receive(:foo) }
        VirtualMachine.stub(:all).and_return(virtual_machines)
        VirtualMachine.each { |vm| vm.foo }
      end
    end

    describe '.all' do
      before do
        @stdout = %q{UUID                
  {264eab18-563e-4ccb-935d-50269130c592} 
  {b0749d89-27c5-4d0f-88e4-b8aeab95cd35} 
  {b893da77-f465-4de4-ab3f-f77e16f0c485} }
        @uuids = ['{264eab18-563e-4ccb-935d-50269130c592}',
          '{b0749d89-27c5-4d0f-88e4-b8aeab95cd35}',
          '{b893da77-f465-4de4-ab3f-f77e16f0c485}']
      end

      it 'should return a list of all virtual machines' do
        vm = mock('virtual_machine')
        Command.stub(:run).and_return(stub(:stdout => @stdout))
        VirtualMachine.stub(:new).and_return(vm)
        VirtualMachine.all.should eql([vm, vm, vm])
      end

      it 'should return an empty list if no virtual machines exist' do
        Command.stub(:run).and_return(stub(:stdout => ''))
        VirtualMachine.all.should eql([])
      end

      it 'should instantiate all virtual machines by their uuid' do
        Command.stub(:run).and_return(stub(:stdout => @stdout))
        @uuids.each { |uuid| VirtualMachine.should_receive(:new).with(uuid) }
        VirtualMachine.all
      end

      it 'should query a list of all virtual machines via command' do
        cmd = %w{prlctl list --all --output uuid}
        Command.should_receive(:run).with(*cmd).and_return(stub(:stdout => @stdout))
        VirtualMachine.stub(:new)
        VirtualMachine.all
      end
    end

    describe '#name' do
      it "should return the virtual machine's name" do
        Command.stub(:run).and_return(stub(:stdout => "Name: foo"))
        VirtualMachine.new(nil).name.should eql('foo')
      end
    end

    describe '#uuid' do
      it "should return the virtual machine's UUID" do
        Command.stub(:run).and_return(stub(:stdout => 'ID: {423dba54-45e3-46f1-9aa2-87d61ce6b757}'))
        VirtualMachine.new(nil).uuid.should eql('{423dba54-45e3-46f1-9aa2-87d61ce6b757}')
      end
    end
  end
end
