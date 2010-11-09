#!/usr/bin/ruby
##
## mysql-replication.rb
##
## This script uses facter to setup mysql replication based upon the
#facts mysql_master and mysql_repl_dbs
##
## It is currently in beta
##
#
## 1) Require the relevant libraries
require 'rubygems'
require 'facter'
#
## 2) Get the relevant facts and echo them to the screen
puts "Getting facts"
#begin
       Facter.loadfacts()
      puts "Facts received"
      puts  Facter.ipaddress
#rescue
#      Facter.loadfacts()
#      puts "running rescue"
#end

#                                mysql_master = Facter.value('mysql_master')
#                                mysql_repl_dbs = Facter.value('mysql_master')
#
#                                puts "Master Server: #{mysql_master}\nDatabases: #{mysql_repl_dbs}"
