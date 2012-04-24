Before do
  @aruba_timeout_seconds = 30
end

Given /^the following virtual machines?:$/ do |vm_table|
  format = "%-40s%-13s%-16s%s"
  #all_vm = [format % %w{UUID STATUS IP_ADDR NAME"}]
  all_vm = %w[UUID]
  vm_table.hashes.each do |vm|
    name, uuid, status  = vm["name"], vm["uuid"], vm["status"]
    #all_vm << format % [vm["uuid"], vm["status"], "-", vm["name"]]
    all_vm << vm['uuid']
    steps %Q{
      Given I double `prlctl list --info "#{name}"` with stdout:
        """
        ID: #{uuid}
        Name: #{name}
        State: #{status}
        """
      And I double `prlctl list --info #{uuid}` with stdout:
        """
        ID: #{uuid}
        Name: #{name}
        State: running
        """
      And I double `prlctl stop #{uuid}` with stdout:
        """
        ...successfully stopped.
        """
      And I double `prlctl backup #{uuid}` with stdout:
        """
        ...successfully backed up with backup id {a3935342-e8b6-4e67-b9f6-1b2adf844837}.1
        """
      And I double `prlctl backup "#{name}"` with stdout:
        """
        Backing up the VM #{name}
        The virtual machine has been successfully backed up with backup id {d51e6df1-83e9-46e2-aef1-3807d721c1be}.
        """
      And I double `prlctl start #{uuid}` with stdout:
        """
        ...successfully started.
        """
    }
  end
  
  all_vm = all_vm.join("\n")
  steps %Q{
    Given I double `prlctl list --all --output uuid` with stdout:
      """
	    #{all_vm}
	    """
  }
end
