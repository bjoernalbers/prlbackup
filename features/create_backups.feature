Feature: Create Backups

	In order to sleep well
	As a sysadmin using Parallels Server
	I want to create my backups with prlbackup

	Scenario Outline: Backup single VM by name or UUID
		Given the following virtual machine:
			| uuid                                   | status  | name          |
	  	| {55aae003-298d-4199-82ed-23658a218605} | stopped | Ubuntu        |
		And I could run `prlctl backup {55aae003-298d-4199-82ed-23658a218605}`
		When I successfully run `prlbackup <vm>`
		Then `prlctl backup <vm>` should have been run
		And the output should contain:
			"""
			Incremental backup of Ubuntu {55aae003-298d-4199-82ed-23658a218605} successfully created
			"""
		Examples:
		 | vm                                     |
		 | Ubuntu                                 |
		 | {55aae003-298d-4199-82ed-23658a218605} |

	# Scenario: Stop VM during backup
	# 	Given the following virtual machine:
	# 	  | uuid                                   | status  | name          |
	# 	  | {423dba54-45e3-46f1-9aa2-87d61ce6b757} | running | Windows XP    |
	# 	When I should run `prlctl stop {423dba54-45e3-46f1-9aa2-87d61ce6b757}`
	# 	And I should run `prlctl backup {423dba54-45e3-46f1-9aa2-87d61ce6b757} --full`
	# 	And I should run `prlctl start {423dba54-45e3-46f1-9aa2-87d61ce6b757}`
	# 	Then I successfully run `prlbackup --full "Windows XP"`
	# 	And the output should contain:
	# 		"""
	# 		Full backup of Windows XP {55aae003-298d-4199-82ed-23658a218605} successfully created
	# 		"""
	# 
	# Scenario: Backup of all VMs
	# 	Given the following virtual machines:
	# 	  | uuid                                   | status  | name          |
	# 	  | {97351580-afd7-4aff-9960-814196b28e37} | stopped | Mac OS X Lion |
	# 	  | {423dba54-45e3-46f1-9aa2-87d61ce6b757} | stopped | Windows XP    |
	# 	  | {55aae003-298d-4199-82ed-23658a218605} | stopped | Ubuntu        |
	# 	When I should run `prlctl backup {97351580-afd7-4aff-9960-814196b28e37}`
	# 	And I should run `prlctl backup {423dba54-45e3-46f1-9aa2-87d61ce6b757}`
	# 	And I should run `prlctl backup {55aae003-298d-4199-82ed-23658a218605}`
	# 	Then I successfully run `prlbackup --all`
	# 	And the output should contain "{97351580-afd7-4aff-9960-814196b28e37} successfully created"
	# 	And the output should contain "{423dba54-45e3-46f1-9aa2-87d61ce6b757} successfully created"
	# 	And the output should contain "{55aae003-298d-4199-82ed-23658a218605} successfully created"
	# 
	# Scenario: Exclude VM from backup
	# 	Given the following virtual machines:
	# 	  | uuid                                   | status  | name          |
	# 	  | {97351580-afd7-4aff-9960-814196b28e37} | stopped | Mac OS X Lion |
	# 	  | {423dba54-45e3-46f1-9aa2-87d61ce6b757} | stopped | Windows XP    |
	# 	  | {55aae003-298d-4199-82ed-23658a218605} | stopped | Ubuntu        |
	# 	When I should run `prlctl backup {97351580-afd7-4aff-9960-814196b28e37}`
	# 	And I should run `prlctl backup {55aae003-298d-4199-82ed-23658a218605}`
	# 	Then I successfully run `prlbackup --exclude "Windows XP"`
	# 	And the output should contain "{97351580-afd7-4aff-9960-814196b28e37} successfully created"
	# 	And the output should not contain "{423dba54-45e3-46f1-9aa2-87d61ce6b757} successfully created"
	# 	And the output should contain "{55aae003-298d-4199-82ed-23658a218605} successfully created"
