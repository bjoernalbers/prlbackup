Feature: Logging

  In order to be able to review the backup activities
  As a sysadmin using Parallels Server
  I want to have a logging feature

  Background:
    Given the following virtual machines:
      | uuid                                   | status  | name          |
      | {97351580-afd7-4aff-9960-814196b28e37} | stopped | Mac OS X Lion |
      | {423dba54-45e3-46f1-9aa2-87d61ce6b757} | running | Windows XP    |
      | {55aae003-298d-4199-82ed-23658a218605} | stopped | Ubuntu        |

  Scenario: Log the last stdout line from prlctl
    When I successfully run `prlbackup "Windows XP"`
    Then the stdout should contain "The VM has been successfully stopped"
    And the stdout should contain "The virtual machine has been successfully backed up with backup id"
    And the stdout should contain "The VM has been successfully started"

  Scenario: Log the virtual machines name
    When I successfully run `prlbackup --all`
    Then the output should match /Mac OS X Lion.+successfully backed up/
    And the output should match /Windows XP.+successfully backed up/
    And the output should match /Ubuntu.+successfully backed up/

  Scenario: Log errors
    Given I double `prlctl backup {55aae003-298d-4199-82ed-23658a218605}` with exit status 42 and stderr:
      """
      BOOOOM!
      """
    When I run `prlbackup Ubuntu`
    Then the output should match /ERROR.+BOOOOM/

  Scenario: Display commands with option --verbose
    When I run `prlbackup --verbose "Windows XP"`
    Then the stdout should contain "prlctl list --info"
    And the stdout should contain "prlctl stop" 
    And the stdout should contain "prlctl backup" 
    And the stdout should contain "prlctl start" 

  Scenario: Display commands with VM impact with option --dry-run
    When I run `prlbackup --dry-run "Windows XP"`
    Then the stdout should contain "prlctl stop"
    And the stdout should contain "prlctl backup"
    And the stdout should contain "prlctl start"
    But the stdout should not contain "prlctl list"
