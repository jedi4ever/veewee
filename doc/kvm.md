NOTE:Virtualbox doesn't like KVM to be enabled

check with 

    kvm_ok

Remove modules:

    rmmod kvm_intel
    rmmod kvm
