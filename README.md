**VeeWee:** the tool to easily build vagrant base boxes or kvm, virtualbox and fusion images.

Vagrant is a great tool to test out new things or changes in a Virtual Machine (Virtualbox) using either chef or puppet.

The first step to build a new Virtual Machine is to download an existing 'base box'.

I believe this scares a lot of people as they don't know who or how this box was built. Therefore lots of people end up first building their own base box which is time consuming and often cumbersome.

Veewee aims to automate all the steps for building base boxes and to collect best practices in a transparent way.

Besides building Vagrant boxes, veewee can also be used for:

- create Virtual Machines for [VMware (Fusion)](http://www.vmware.com/products/fusion/) and [KVM](http://www.linux-kvm.org/)
- interact with with those VMs (up, destroy, halt, ssh)
- export them to `OVA` for [Fusion](http://www.vmware.com/products/fusion/), `IMG` for [KVM](http://www.linux-kvm.org/) and `OVF` for [Virtualbox](https://www.virtualbox.org/)


## Get started

Before you start we recommend to read through these pages:

- the [requirements](doc/requirements.md)
- the [installation](doc/installation.md) procedure

Depending on how you want to use veewee, we suggest to read through one of the following guides: (**work in progress**)

- [Guide for Vagrant](doc/vagrant.md)
- [Guide for Virtualbox](doc/vbox.md)
- [Guide for VMware Fusion](doc/fusion.md)
- [Guide for KVM](doc/kvm.md)

More detailed pages on each subject are located in the [documentation directory](doc).


## Contribute

People have reported good experiences, why don't you give it a try?

If you have a setup working, share your 'definition' with me. That would be fun!

See [CONTRIBUTE](CONTRIBUTE.md).

## Ideas

- Integrate veewee with your CI build to create baseboxes on a daily basis
- Use of pre_postinstall_file in `definition.rb` by whren - 2012/04/12 <br>
  See [use of pre_postinstall_file in definition.rb](https://github.com/whren/veewee/wiki/Use-of-pre_postinstall_file-in-definition.rb)
