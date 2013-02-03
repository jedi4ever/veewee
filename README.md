**VeeWee:** the tool to easily build vagrant base boxes or kvm, virtualbox and fusion images.

Vagrant is a great tool to test out new things or changes in a Virtual Machine (Virtualbox) using either chef or puppet.

The first step to build a new Virtual Machine is to download an existing 'base box'.

I believe this scares a lot of people as they don't know who or how this box was built. Therefore lots of people end up first building their own base box which is time consuming and often cumbersome.

Veewee aims to automate all the steps for building base boxes and to collect best practices in a transparent way. 

Besides building Vagrant boxes, veewee can also be used for:

- create Virtual Machines for VMware (Fusion) and kvm
- interact with with those VMs (up, destroy, halt, ssh)
- export them to `OVA` for fusion, `IMG` for KVM and `OVF` for Virtualbox


## Get started

Before you start we recommend to read through these pages:

- the [requirements](https://github.com/jedi4ever/veewee/tree/master/doc/requirements.md)
- the [installation](https://github.com/jedi4ever/veewee/tree/master/doc/installation.md) procedure

Depending on how you want to use veewee, we suggest to read through one of the following guides: (**work in progress**)

- [Guide for Vagrant](https://github.com/jedi4ever/veewee/tree/master/doc/vagrant.md)
- [Guide for Virtualbox](https://github.com/jedi4ever/veewee/tree/master/doc/vbox.md)
- [Guide for VMware Fusion](https://github.com/jedi4ever/veewee/tree/master/doc/fusion.md)
- [Guide for KVM](https://github.com/jedi4ever/veewee/tree/master/doc/kvm.md)

More detailed pages on each subject are located in the [documentation directory](https://github.com/jedi4ever/veewee/tree/master/doc).


## Contribute

People have reported good experiences, why don't you give it a try?

If you have a setup working, share your 'definition' with me. That would be fun!


## Ideas

- Integrate veewee with your CI build to create baseboxes on a daily basis
- Use of pre_postinstall_file in `definition.rb` by whren - 2012/04/12 <br>
  See [use of pre_postinstall_file in definition.rb](https://github.com/whren/veewee/wiki/Use-of-pre_postinstall_file-in-definition.rb)
