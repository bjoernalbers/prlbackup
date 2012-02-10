Feature: Development Steps

	In order to keep my cucumber scenarios nice and tight
	As a developer of Parallels-Backup
	I want convenient development steps to fake virtual machines

	Scenario: `prlctl list --all`
		Given the following virtual machines:
		  | uuid                                   | status  | name          |
		  | {97351580-afd7-4aff-9960-814196b28e37} | stopped | Mac OS X Lion |
		  | {423dba54-45e3-46f1-9aa2-87d61ce6b757} | running | Windows XP    |
		  | {55aae003-298d-4199-82ed-23658a218605} | stopped | Ubuntu        |
		When I run `prlctl list --all`
		Then the stdout should contain:
			"""
			UUID                                    STATUS       IP_ADDR         NAME
			"""
		And the stdout should contain:
			"""
			{97351580-afd7-4aff-9960-814196b28e37}  stopped      -               Mac OS X Lion
			"""
		And the stdout should contain:
			"""
			{423dba54-45e3-46f1-9aa2-87d61ce6b757}  running      -               Windows XP
			"""
		And the stdout should contain:
			"""
			{55aae003-298d-4199-82ed-23658a218605}  stopped      -               Ubuntu
			"""