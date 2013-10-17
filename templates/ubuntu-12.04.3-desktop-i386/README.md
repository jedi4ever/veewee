# Template Manifest #

This file explains the goals of this template definition. For details
about the function of veewee template files, see the documentation on
how to [Customize Definitions](../../doc/customize.md).

### Overview ###

**Template Name:**
`Ubuntu-12.04.3-desktop-i386`

**Box Objective:**
The aim is to setup a vanilla `Ubuntu 32-bit (i386) desktop` plus setup
what's needed for veewee automation, VirtualBox guest additions, and to
install the foundation so that either `puppet` or `chef` can easily
customize as needed.

The template was loosely based on `ubuntu-12.04.3-server-i386` and
`ubuntu-12.04.2-desktop-amd64`.  It improves the
`ubuntu-12.04.2-desktop-amd64` template by moving Desktop setup to
the `preseed.cfg` file instead of a post installation; which essentially
caused setup to run twice (first for the linux server kernel install,
then a second time for the install of the standard kernel).

As a result, this definition is less complex and the build is faster.

#### System Details ####

* **Version:**                  Ubuntu 12.04.3 Desktop
* **Locale:**                   en_US
* **Keyboard layout:**          US
* **Timezone:**                 UTC
* **Extra Language Support:**   none
* **Machine:**                  1.9GB RAM, 30GB HD
* **VirtualBox Config:**        IO_APIC ON, UTC time, 3D acceleration,
                                Shared clipboard.
* **Deviations from a vanilla Ubuntu Desktop:**
   * Add `vagrant` user and add to `admin group`, disable password
     requirement for `admin group` to run `sudo` commands.
   * Install VirtualBox `Guest Additions`
   * Install `Ruby`
   * Install `Puppet`
   * Install `Chef`

### CHANGELOG ###

* Completely reorganize `preseed.cfg` based on 12.04 (precise) examples
  and add useful comments
* Change disk size to 30GB (exports to 1.1GB box)
* Improve VirtualBox default settings for a desktop image and document
* Cleanup various cruft
