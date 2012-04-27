Feature: Cleanup

  In order to not waste my time manually cleaning up
  As a sysadmin using Parallels Server
  I want to old backups to be automatically deleted

  Background:
    Given the following virtual machines:
      | uuid                                   | status  | name          |
      | {97351580-afd7-4aff-9960-814196b28e37} | stopped | Mac OS X Lion |
      | {423dba54-45e3-46f1-9aa2-87d61ce6b757} | running | Windows XP    |
      | {55aae003-298d-4199-82ed-23658a218605} | stopped | Ubuntu        |

  Scenario: Delete old backups
    Given I double `prlctl backup-list {55aae003-298d-4199-82ed-23658a218605}` with stdout:
      """
      ID Backup_ID                              Node                 Date                 Type       Size
      {55aae003-298d-4199-82ed-23658a218605} {ae6565dd-7f8f-42cb-a088-8b1d98f5160b} psfm.example.com 02/27/2012 13:11:32     f 10537597943
      {55aae003-298d-4199-82ed-23658a218605} {ae6565dd-7f8f-42cb-a088-8b1d98f5160b}.2 psfm.example.com 02/27/2012 15:26:02     i 2951747588
      {55aae003-298d-4199-82ed-23658a218605} {5f9dd263-ec56-443e-9917-dab9b40d3027} psfm.example.com 03/13/2012 18:06:00     f 11748325372
      {55aae003-298d-4199-82ed-23658a218605} {2aeb4ada-6623-4087-9fc5-f09aeaafd81e} psfm.example.com 03/23/2012 21:25:50     f 47315014888
      {55aae003-298d-4199-82ed-23658a218605} {68f7e154-6755-46f6-ad1f-a79c5f488f35} psfm.example.com 03/28/2012 15:09:05     f 23462808438
      {55aae003-298d-4199-82ed-23658a218605} {68f7e154-6755-46f6-ad1f-a79c5f488f35}.2 psfm.example.com 04/05/2012 17:21:12     i 12841952117
      """
    When I successfully run `prlbackup --keep-only 2 Ubuntu`
    Then the double `prlctl backup-delete --tag {ae6565dd-7f8f-42cb-a088-8b1d98f5160b}` should have been run
    And the double `prlctl backup-delete --tag {5f9dd263-ec56-443e-9917-dab9b40d3027}` should have been run
    But the double `prlctl backup-delete --tag {2aeb4ada-6623-4087-9fc5-f09aeaafd81e}` should not have been run
    And the double `prlctl backup-delete --tag {68f7e154-6755-46f6-ad1f-a79c5f488f35}` should not have been run
