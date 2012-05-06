require 'spec_helper'

module PrlBackup
  describe VirtualMachine do
    before do
      VirtualMachine.any_instance.stub(:run).and_return('')
      @uuid = '{deadbeef}'
      @vm = VirtualMachine.new('foo')
      @vm.stub(:uuid).and_return(@uuid)
      @vm.stub(:logger).and_return(stub(:info => nil))
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
        VirtualMachine.stub(:run).and_return(@stdout)
        VirtualMachine.stub(:new).and_return(vm)
        VirtualMachine.all.should eql([vm, vm, vm])
      end

      it 'should return an empty list if no virtual machines exist' do
        VirtualMachine.stub(:run).and_return('')
        VirtualMachine.all.should eql([])
      end

      it 'should instantiate all virtual machines by their uuid' do
        VirtualMachine.stub(:run).and_return(@stdout)
        @uuids.each { |uuid| VirtualMachine.should_receive(:new).with(uuid) }
        VirtualMachine.all
      end

      it 'should query a list of all virtual machines via command' do
        cmd = %w{prlctl list --all --output uuid}
        VirtualMachine.should_receive(:run).with(*cmd).and_return(@stdout)
        VirtualMachine.stub(:new)
        VirtualMachine.all
      end
    end

    describe '.to_s' do
      it 'should display the context' do
        VirtualMachine.to_s.should eql('VM')
      end
    end

    describe '#config' do
      it 'should return the global config' do
        PrlBackup.should_receive(:config).and_return({:foo => 'bar'})
        @vm.config.should eql({:foo => 'bar'})
      end
    end

    %w[start stop].each do |cmd|
      describe "##{cmd}" do
        it "should #{cmd} the virtual machine" do
          @vm.should_receive(:conditionally_run).with('prlctl', cmd, @uuid).and_return('')
          @vm.send(cmd)
        end
      end
    end

    describe '#backup' do
      it 'should create an incremental backup by default' do
        @vm.stub(:config).and_return({})
        @vm.should_receive(:conditionally_run).with('prlctl', 'backup', @uuid)
        @vm.instance_eval { backup }
      end

      it 'should create a full backup when configured' do
        @vm.stub(:config).and_return({:full => true})
        @vm.should_receive(:conditionally_run).with('prlctl', 'backup', @uuid, '--full')
        @vm.instance_eval { backup }
      end
    end

    describe '#safely_backup' do
      it 'should stop the VM during the backup' do
        @vm.stub(:stopped?).and_return(false)
        @vm.should_receive(:stop).ordered
        @vm.should_receive(:backup).ordered
        @vm.should_receive(:start).ordered
        @vm.safely_backup
      end

      it 'should not stop the VM when already shutdown' do
        @vm.stub(:stopped?).and_return(true)
        @vm.should_receive(:backup)
        @vm.safely_backup
      end
    end

    describe '#cleanup' do
      before do
        @old_backup = double('old backup')
        @new_backup = double('new backup')
        @vm.stub(:full_backups).and_return([@old_backup, @new_backup])
      end

      it 'should delete 2 backups when there are 2 more backups than to keep' do
        @vm.stub(:config).and_return({:keep_only => 0})
        @old_backup.should_receive(:delete).once
        @new_backup.should_receive(:delete).once
        @vm.cleanup
      end

      it 'should delete the oldest backup when there is 1 more backup than to keep' do
        @vm.stub(:config).and_return({:keep_only => 1})
        @old_backup.should_receive(:delete).once
        @new_backup.should_not_receive(:delete)
        @vm.cleanup
      end

      it 'should not delete any backups when there are as many backups as to keep' do
        @vm.stub(:config).and_return({:keep_only => 2})
        @old_backup.should_not_receive(:delete)
        @new_backup.should_not_receive(:delete)
        @vm.cleanup
      end
    end

    describe '#full_backups' do
      before do
        Backup.stub(:all).and_return([])
      end

      it 'should query list of backups for given UUID once' do
        Backup.should_receive(:all).with(@vm.uuid).once
        2.times { @vm.instance_eval { full_backups } }
      end

      it 'should return only full backups' do
        full_backup = double('full backup')
        full_backup.stub(:full?).and_return(true)
        incremental_backup = double('incremental backup')
        incremental_backup.stub(:full?).and_return(false)
        Backup.stub(:all).and_return([full_backup, incremental_backup])
        @vm.instance_eval { full_backups }.should eql([full_backup])
      end
    end

    describe '#name' do
      it 'should return the name of the virtual machine' do
        @vm.stub(:info).and_return('Name: foo')
        @vm.name.should eql('foo')
      end

      it 'should return nil if the name cannot be parsed' do
        @vm.stub(:info).and_return(nil)
        @vm.name.should be_nil
      end
    end

    describe '#uuid' do
      before do
        @vm = VirtualMachine.new('foo')
      end

      it "should return the virtual machine's UUID" do
        @vm.stub(:info).and_return('ID: {423dba54-45e3-46f1-9aa2-87d61ce6b757}')
        @vm.uuid.should eql('{423dba54-45e3-46f1-9aa2-87d61ce6b757}')
      end

      it 'should return nil if the uuid cannot be parsed' do
        @vm.stub(:info).and_return(nil)
        @vm.uuid.should be_nil
      end
    end

    describe '#update_info' do
      it 'should query infos about the virtual machine' do
        @vm.should_receive(:run).with('prlctl', 'list', '--info', 'foo')
        @vm.instance_eval { update_info }
      end

      it 'should update and return the infos' do
        @vm.stub(:run).and_return('Foo: Bar', 'Foo: Baz')
        @vm.instance_eval { update_info }.should eql('Foo: Bar')
        @vm.instance_eval { info }.should eql('Foo: Bar')
        @vm.instance_eval { update_info }.should eql('Foo: Baz')
        @vm.instance_eval { info }.should eql('Foo: Baz')
      end
    end

    describe '#stopped?' do
      it 'should return true when virtual machine is stopped' do
        @vm.stub!(:update_info).and_return('State: stopped')
        @vm.should be_stopped
      end

      it 'should return false when virtual machine is not stopped' do
        @vm.stub!(:update_info).and_return('State: running')
        @vm.should_not be_stopped
      end
    end

    describe '#==' do
      before do
        @other_vm = VirtualMachine.new('other_vm')
      end

      it 'should be true when UUIDs are equal' do
        @other_vm.stub(:uuid).and_return(@vm.uuid)
        @vm.should == @other_vm
        @other_vm.should == @vm
      end

      it 'should be false when UUIDs are not equal' do
        @other_vm.stub(:uuid).and_return('{a-completely-different-uuid}')
        @vm.should_not == @other_vm
        @other_vm.should_not == @vm
      end
    end

    describe '#to_s' do
      it 'should return the name' do
        @vm.should_receive('name').and_return('name_of_the_vm')
        @vm.to_s.should eql('VM: name_of_the_vm')
      end

      it 'should return "Unknown VM" if name is nil' do
        @vm.should_receive(:name).and_return(nil)
        @vm.to_s.should eql('VM: Unknown')
      end
    end
  end
end
