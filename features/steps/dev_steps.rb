Given /^the following virtual machines?:$/ do |vm_table|
  format = "%-40s%-13s%-16s%s"
  all_vm = [format % %w{UUID STATUS IP_ADDR NAME"}]
  vm_table.hashes.each do |vm|
    name, uuid = vm["name"], vm["uuid"]
    all_vm << format % [vm["uuid"], vm["status"], "-", vm["name"]]
    steps %Q{
      Given I could run `prlctl list --info "#{name}"` with stdout:
        """
        ID: #{uuid}
        State: running
        """
      And I could run `prlctl list --info #{uuid}` with stdout:
        """
        ID: #{uuid}
        State: running
        """
      And I could run `prlctl stop #{uuid}` with stdout:
        """
        ...successfully stopped.
        """
      And I could run `prlctl backup #{uuid}` with stdout:
        """
        ...successfully backed up with backup id {a3935342-e8b6-4e67-b9f6-1b2adf844837}.1
        """
      And I could run `prlctl start #{uuid}` with stdout:
        """
        ...successfully started.
        """
    }
  end
  
  all_vm = all_vm.join("\n")
  steps %Q{
    Given I could run `prlctl list --all` with stdout:
      """
	    #{all_vm}
	    """
  }
end
