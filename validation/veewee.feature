Feature: veewee box validation
  As a valid veewee box
  I need to comply to a set of rules

  @vmfusion @virtualbox @kvm
  Scenario: Valid definition
    Given a veeweebox was build
    And I run "whoami" over ssh
    Then I should see the provided username in the output

  @vmfusion @virtualbox @kvm
  Scenario: Checking sudo
    Given a veeweebox was build
    And I run "sudo whoami" over ssh
    Then I should see "root" in the output

  @vmfusion @virtualbox @kvm
  Scenario: Checking ruby
    Given a veeweebox was build
    And I run ". /etc/profile ;ruby --version 2> /dev/null 1> /dev/null;  echo $?" over ssh
    Then I should see "0" in the output

  @vmfusion @virtualbox @kvm
  Scenario: Checking gem
    Given a veeweebox was build
    And I run ". /etc/profile; gem --version 2> /dev/null 1> /dev/null ; echo $?" over ssh
    Then I should see "0" in the output

  @vmfusion @virtualbox @kvm
  Scenario: Checking chef
    Given a veeweebox was build
    And I run ". /etc/profile ;chef-client --version 2> /dev/null 1>/dev/null; echo $?" over ssh
    Then I should see "0" in the output

  @vmfusion @virtualbox @kvm
  Scenario: Checking puppet
    Given a veeweebox was build
    And I run ". /etc/profile ; puppet --version 2> /dev/null 1>/dev/null; echo $?" over ssh
    Then I should see "0" in the output

  @vagrant
  Scenario: Checking shared folders
    Given a veeweebox was build
    And I run "mount|grep veewee-validation" over ssh
    Then I should see "veewee-validation" in the output
