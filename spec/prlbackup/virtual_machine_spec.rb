require 'spec_helper'

describe VirtualMachine do
  describe '.each' do
    it 'should iterate over all virtual machines' do
      all_uuids = ["{264eab18-563e-4ccb-935d-50269130c592}",
        "{b893da77-f465-4de4-ab3f-f77e16f0c485}",
        "{d1f53a89-9c39-4cd8-a3be-17f8a4b98272}"]
      VirtualMachine.stub(:all_uuids).and_return(all_uuids)
      all_uuids.each do |uuid|
        mock = mock(uuid)
        mock.should_receive(:foo)
        VirtualMachine.should_receive(:new).with(uuid).and_return(mock)
      end
      VirtualMachine.each { |vm| vm.foo }
    end
  end

  describe '.all_uuids' do
    it 'should request a list of all virtual machines via prlctl' do
      Command.should_receive(:run).with('prlctl', 'list', '--all').and_return(stub(:stdout => ""))
      VirtualMachine.all_uuids
    end

    it 'should return list of all virtual machines by UUIDs' do
      stdout = %q{UUID                                    STATUS       IP_ADDR         NAME
{264eab18-563e-4ccb-935d-50269130c592}  stopped      -               Ubuntu
{b0749d89-27c5-4d0f-88e4-b8aeab95cd35}  running      192.168.1.11    Management Node
{b893da77-f465-4de4-ab3f-f77e16f0c485}  running      192.168.1.12    Solaris}
      all_uuids = ["{264eab18-563e-4ccb-935d-50269130c592}",
        "{b0749d89-27c5-4d0f-88e4-b8aeab95cd35}",
        "{b893da77-f465-4de4-ab3f-f77e16f0c485}"]
      Command.stub(:run).and_return(stub(:stdout => stdout))
      VirtualMachine.all_uuids.should eql(all_uuids)
    end
  end
end
