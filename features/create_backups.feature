Feature: Create Backups

  In order to sleep well
  As a sysadmin using Parallels Server
  I want to create my backups with prlbackup

  Background:
    Given the following virtual machines:
      | uuid                                   | status  | name          |
      | {97351580-afd7-4aff-9960-814196b28e37} | stopped | Mac OS X Lion |
      | {423dba54-45e3-46f1-9aa2-87d61ce6b757} | running | Windows XP    |
      | {55aae003-298d-4199-82ed-23658a218605} | stopped | Ubuntu        |

  Scenario: Backup single VM (already stopped)
    When I successfully run `prlbackup Ubuntu`
    Then the double `prlctl stop Ubuntu` should not have been run
    And the double `prlctl backup Ubuntu` should have been run
    And the double `prlctl start Ubuntu` should not have been run

  Scenario: Stop VM during backup
    When I successfully run `prlbackup "Windows XP"`
    Then the double `prlctl stop "Windows XP"` should have been run
    And the double `prlctl backup "Windows XP"` should have been run
    And the double `prlctl start "Windows XP"` should have been run

  Scenario: Create full backup
    When I successfully run `prlbackup --full Ubuntu`
    And the double `prlctl backup Ubuntu --full` should have been run

  #  Scenario: Backup of all VMs
  #    Given the following virtual machines:
  #      | uuid                                   | status  | name          |
  #      | {97351580-afd7-4aff-9960-814196b28e37} | stopped | Mac OS X Lion |
  #      | {423dba54-45e3-46f1-9aa2-87d61ce6b757} | stopped | Windows XP    |
  #      | {55aae003-298d-4199-82ed-23658a218605} | stopped | Ubuntu        |
  #    Then I successfully run `prlbackup --all`
  #    And the output should contain "{97351580-afd7-4aff-9960-814196b28e37} successfully created"
  #    And the output should contain "{423dba54-45e3-46f1-9aa2-87d61ce6b757} successfully created"
  #    And the output should contain "{55aae003-298d-4199-82ed-23658a218605} successfully created"
  #
  #  @foo
  #  @announce-stdout
  #  Scenario: Exclude VM from backup
  #    Given the following virtual machines:
  #      | uuid                                   | status  | name          |
  #      | {97351580-afd7-4aff-9960-814196b28e37} | stopped | Mac OS X Lion |
  #      | {423dba54-45e3-46f1-9aa2-87d61ce6b757} | stopped | Windows XP    |
  #      | {55aae003-298d-4199-82ed-23658a218605} | stopped | Ubuntu        |
  #    When I successfully run `prlbackup --all --exclude "Windows XP"`
  #    Then `prlctl backup \{423dba54-45e3-46f1-9aa2-87d61ce6b757\}` should not have been run
  #    And the output should contain "{97351580-afd7-4aff-9960-814196b28e37} successfully created"
  #    And the output should not contain "{423dba54-45e3-46f1-9aa2-87d61ce6b757} successfully created"
  #    And the output should contain "{55aae003-298d-4199-82ed-23658a218605} successfully created"
