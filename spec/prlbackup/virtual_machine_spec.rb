require 'spec_helper'

module PrlBackup
  describe VirtualMachine do
    before do
      @uuid = '{deadbeef}'
      @vm = VirtualMachine.new('foo')
      @vm.stub(:uuid).and_return(@uuid)
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

    describe '#config' do
      it 'should return the global config' do
        PrlBackup.should_receive(:config).and_return({:foo => 'bar'})
        @vm.config.should eql({:foo => 'bar'})
      end
    end

    %w[start stop].each do |cmd|
      describe "##{cmd}" do
        it "should #{cmd} the virtual machine" do
          @vm.should_receive(:maybe_run).with('prlctl', cmd, @uuid)
          @vm.send(cmd)
        end
      end
    end

    describe '#backup' do
      it 'should create an incremental backup by default' do
        @vm.stub(:config).and_return({})
        @vm.should_receive(:maybe_run).with('prlctl', 'backup', @uuid)
        @vm.backup
      end

      it 'should create a full backup when configured' do
        @vm.stub(:config).and_return({:full => true})
        @vm.should_receive(:maybe_run).with('prlctl', 'backup', @uuid, '--full')
        @vm.backup
      end
    end

    describe '#safe_backup' do
      before do
        @vm.stub(:shutdown?).and_return(false)
        @vm.stub(:config).and_return({:full => false})
      end

      it 'should stop the VM during the backup' do
        @vm.stub(:shutdown?).and_return(true)
        @vm.should_receive(:run).with('prlctl', 'stop', @uuid).ordered
        @vm.should_receive(:run).with('prlctl', 'backup', @uuid).ordered
        @vm.should_receive(:run).with('prlctl', 'start', @uuid).ordered
        @vm.safe_backup
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
        @vm.should_receive(:delete_backup).with(@old_backup).once
        @vm.should_receive(:delete_backup).with(@new_backup).once
        @vm.cleanup
      end

      it 'should delete the oldest backup when there is 1 more backup than to keep' do
        @vm.stub(:config).and_return({:keep_only => 1})
        @vm.should_receive(:delete_backup).with(@old_backup).once
        @vm.should_not_receive(:delete_backup).with(@new_backup)
        @vm.cleanup
      end

      it 'should not delete any backups when there are as many backups as to keep' do
        @vm.stub(:config).and_return({:keep_only => 2})
        @vm.should_not_receive(:delete_backup)
        @vm.cleanup
      end
    end

    describe '#delete_backup' do
      it 'should delete the virtual machines backup' do
        @vm.should_receive(:maybe_run).with('prlctl', 'backup-delete', '--tag', '{some-backup-uuid}')
        @vm.delete_backup('{some-backup-uuid}')
      end
    end

    describe '#full_backups' do
      before do
        output = double('output')
        output.stub(:stdout).and_return('prlctl backup-list {bf364fd4-8f6b-4032-818d-4958f9c0945b}
ID Backup_ID                              Node                 Date                 Type       Size
{deadbeef} {ae6565dd-7f8f-42cb-a088-8b1d98f5160b} psfm.example.com 02/27/2012 13:11:32     f 10537597943
{deadbeef} {ae6565dd-7f8f-42cb-a088-8b1d98f5160b}.2 psfm.example.com 02/27/2012 15:26:02     i 2951747588
{deadbeef} {5f9dd263-ec56-443e-9917-dab9b40d3027} psfm.example.com 03/13/2012 18:06:00     f 11748325372
{deadbeef} {2aeb4ada-6623-4087-9fc5-f09aeaafd81e} psfm.example.com 03/23/2012 21:25:50     f 47315014888
{deadbeef} {68f7e154-6755-46f6-ad1f-a79c5f488f35} psfm.example.com 03/28/2012 15:09:05     f 23462808438
{deadbeef} {68f7e154-6755-46f6-ad1f-a79c5f488f35}.2 psfm.example.com 04/05/2012 17:21:12     i 12841952117')
        @vm.stub(:run).and_return(output)
      end

      it 'should query the backup list by CLI' do
        @vm.should_receive(:run).with('prlctl', 'backup-list', @uuid)
        @vm.full_backups
      end

      it 'should return a list of the virtual machines full backup UUIDs' do
        @vm.full_backups.should eql(['{ae6565dd-7f8f-42cb-a088-8b1d98f5160b}',
                                     '{5f9dd263-ec56-443e-9917-dab9b40d3027}',
                                     '{2aeb4ada-6623-4087-9fc5-f09aeaafd81e}',
                                     '{68f7e154-6755-46f6-ad1f-a79c5f488f35}'])
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
  end
end
