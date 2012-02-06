# Note: the veewee03 is now merged into master

Maintaining two branches with complete different structures isn't fun. So..... I want to merge the two.

Veewee03 will bring many new features:

- kvm and vmware fusion support -
- veewee as a standalone tool tool if you don't use virtualbox,vagrant 
- postinstall scripts can now be toggle with --include and --exclude

Caveat: it's functional but not as polished as the previous version. But I'm sure with your help this won't take long.

My apologies for all the pull-requests to the previous version that will not be merged automatically. I'm focusing more on get this version stable and will incorporate the ideas later (some already are)

# The current state of the github is highly unstable, use the 'veewee' gem to use the latest stable version

---
**VeeWee:** the tool to easily build vagrant base boxes or kvm,virtualbox and fusion images

Vagrant is a great tool to test new things or changes in a virtual machine(Virtualbox) using either chef or puppet.
The first step is to download an existing 'base box'. I believe this scares a lot of people as they don't know who or how this box was build. Therefore lots of people end up first building their own base box to use with vagrant.

Besides building Vagrant boxes, veewee can also be used for:

- create vmware (fusion), kvm  virtual machines 
- interact with with those vms (up, destroy, halt, ssh)
- export them : OVA for fusion, IMG for KVM and ovf for virtualbox

Before you start read through:

- the [requirements](doc/requirements)
- the [installation](doc/installation) procedure

Depending on how you want to use veewee, read through one of the following guides: (**work in progres**)

- [guide for vagrant](doc/vagrant)

- [guide for Virtualbox](doc/vbox)
- [guide for Vmware fusion](doc/fusion)
- [guide for KVM](doc/kvm)

You can also look at the more detailed pages on each subject in the [documentation directory](doc)

People have reported good experiences, why don't you give it a try?

## If you have a setup working, share your 'definition' with me. That would be fun! 

IDEAS:

- Now you integrate this with your CI build to create a daily basebox
