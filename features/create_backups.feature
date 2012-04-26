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

  Scenario: Backup all VMs
    When I successfully run `prlbackup --all`
    Then the double `prlctl backup {97351580-afd7-4aff-9960-814196b28e37}` should have been run
    And the double `prlctl backup {423dba54-45e3-46f1-9aa2-87d61ce6b757}` should have been run
    And the double `prlctl backup {55aae003-298d-4199-82ed-23658a218605}` should have been run

  Scenario: Exclude VMs from Backup
    When I successfully run `prlbackup --all --exclude "Mac OS X Lion"`
    Then the double `prlctl backup {423dba54-45e3-46f1-9aa2-87d61ce6b757}` should have been run
    And the double `prlctl backup {55aae003-298d-4199-82ed-23658a218605}` should have been run
    But the double `prlctl backup {97351580-afd7-4aff-9960-814196b28e37}` should not have been run
