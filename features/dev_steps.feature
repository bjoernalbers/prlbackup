Feature: Development Steps

  In order to keep my cucumber scenarios nice and tight
  As a developer of prlbackup
  I want convenient development steps to fake virtual machines

  Background:
    Given the following virtual machines:
      | uuid                                   | status  | name          |
      | {97351580-afd7-4aff-9960-814196b28e37} | stopped | Mac OS X Lion |
      | {423dba54-45e3-46f1-9aa2-87d61ce6b757} | running | Windows XP    |
      | {55aae003-298d-4199-82ed-23658a218605} | stopped | Ubuntu        |

  Scenario: prlctl list --info Ubuntu
    When I successfully run `prlctl list --info Ubuntu`
    Then the stdout should contain exactly:
      """
      ID: {55aae003-298d-4199-82ed-23658a218605}
      Name: Ubuntu
      State: stopped

      """

  Scenario: prlctl backup Ubuntu
    When I successfully run `prlctl backup Ubuntu`
    Then the stdout should contain exactly:
      """
      Backing up the VM Ubuntu
      The virtual machine has been successfully backed up with backup id {d51e6df1-83e9-46e2-aef1-3807d721c1be}.

      """

  Scenario: `prlctl list --all`
    When I run `prlctl list --all --output uuid`
    Then the stdout should contain exactly:
      """
      UUID
      {97351580-afd7-4aff-9960-814196b28e37}
      {423dba54-45e3-46f1-9aa2-87d61ce6b757}
      {55aae003-298d-4199-82ed-23658a218605}

      """
