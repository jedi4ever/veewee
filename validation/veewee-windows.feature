Feature: veewee box validation
  As a valid veewee box
  I need to comply to a set of rules
  In order to make sure it works on Windows with Winrm

  @vmfusion @virtualbox @kvm
  Scenario: Valid definition
    Given a veeweebox was build
    And I run "whoami" over ssh
    Then I should see the provided username in the output

  @vmfusion @virtualbox @kvm
  Scenario: Checking ruby
    Given a veeweebox was build
    And I run "ruby --version > %TEMP%\devnull && echo %ERRORLEVEL%" over ssh
    Then I should see "0" in the output

  @vmfusion @virtualbox @kvm
  Scenario: Checking gem
    Given a veeweebox was build
    And I run "gem --version > %TEMP%\devnull && echo %ERRORLEVEL%" over ssh
    Then I should see "0" in the output

  @vmfusion @virtualbox @kvm
  Scenario: Checking chef
    Given a veeweebox was build
    And I run "chef-client --version > %TEMP%\devnull && echo %ERRORLEVEL%" over ssh
    Then I should see "0" in the output

  @vagrant
  Scenario: Checking shared folders
    Given a veeweebox was build
    And I run "net use|grep veewee-validation" over ssh
    Then I should see "veewee-validation" in the output
