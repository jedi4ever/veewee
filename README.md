**VeeWee:** the tool to easily build vagrant base boxes or kvm,virtualbox and fusion images

Vagrant is a great tool to test new things or changes in a virtual machine(Virtualbox) using either chef or puppet.
The first step is to download an existing 'base box'. I believe this scares a lot of people as they don't know who or how this box was built. Therefore lots of people end up first building their own base box to use with vagrant.

Besides building Vagrant boxes, veewee can also be used for:

- create vmware (fusion), kvm  virtual machines 
- interact with with those vms (up, destroy, halt, ssh)
- export them : OVA for fusion, IMG for KVM and ovf for virtualbox

Before you start read through:

- the [requirements](https://github.com/jedi4ever/veewee/tree/master/doc/requirements.md)
- the [installation](https://github.com/jedi4ever/veewee/tree/master/doc/installation.md) procedure

Depending on how you want to use veewee, read through one of the following guides: (**work in progress**)

- [guide for vagrant](https://github.com/jedi4ever/veewee/tree/master/doc/vagrant.md)

- [guide for Virtualbox](https://github.com/jedi4ever/veewee/tree/master/doc/vbox.md)
- [guide for Vmware fusion](https://github.com/jedi4ever/veewee/tree/master/doc/fusion.md)
- [guide for KVM](https://github.com/jedi4ever/veewee/tree/master/doc/kvm.md)

You can also look at the more detailed pages on each subject in the [documentation directory](https://github.com/jedi4ever/veewee/tree/master/doc)

People have reported good experiences, why don't you give it a try?

## If you have a setup working, share your 'definition' with me. That would be fun! 

IDEAS:

- Now you integrate this with your CI build to create a daily basebox

[whren - 2012/04/12]

See [use of pre_postinstall_file in definition.rb](https://github.com/whren/veewee/wiki/Use-of-pre_postinstall_file-in-definition.rb)
