#Steps

0. Copy the template as a definition.
    ```
    veewee vbox define 'vagrant-solaris10' 'solaris-10-ga-x86'
    ```

1. Build as usual and validate.

    ```
    veewee vbox build vagrant-solaris10
    veewee vbox validate vagrant-solaris10
    ```


2. After creation and validation of the host, execute (using 'vagrant' as password):

   ```
   veewee vbox ssh 'vagrant-solaris10' './cleanup.sh -f'
   ```
   This is recommended to remove validation related cruft, such as shared folders mount points.
   It also shuts down the box in the process, to allow packaging.

3. Export the basebox and use it freely.

   ```
   veewee vbox export 'vagrant-solaris10'
   ```

   You may find some issues if you run this command from your veewee installation, due to the relationship between vagrant and veewee.
   It's advisable to switch to the system's ruby (`rvm use system`) and running the command directly from the definition folder.


#Migration to VMWare
VirtualBox VMs can easily be migrated to VMWare but, in the case of Solaris 10 (at least), some differences regarding the use of IDE and SCSI render the migrated box unusable.

An easier migration process is to be created, but for the time being take a look at [the following blog entry](https://blogs.oracle.com/VirtualGuru/entry/3_fix_hw_difference_between) and additionally to [this](http://www.horizonsystems.com/forum/13-virtualization-central/54-solaris-10-x8664-conversion-to-vmware-howto) and [similar](http://prefetch.net/blog/index.php/2007/08/18/repairing-the-solaris-dev-and-devices-directories/) [entries](http://communities.vmware.com/message/728713).
