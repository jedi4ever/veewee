import sys
import prlsdkapi

if len(sys.argv) != 4:
    print "Usage: parallels_send_keycode '<VM_NAME>' '<keyname>' '<press|release>'"
    exit()

# Parse arguments
vm_name=sys.argv[1]
# Keycode to use
keyname=sys.argv[2]
# Release or press
state=sys.argv[3]

print "Sending keyname '%(keyname)s' to VM '%(vm_name)s'" % {"keyname": keyname, "vm_name":vm_name}

prlsdk = prlsdkapi.prlsdk
consts = prlsdkapi.prlsdk.consts

# Initialize the Parallels API Library
prlsdk.InitializeSDK(consts.PAM_DESKTOP_MAC)

# Obtain a server object identifying the Parallels Service.
server = prlsdkapi.Server()

# Log in. (local as we do Parallels Desktop
login_job=server.login_local()
login_job.wait()

# Get a list of virtual machines.
# Find the specified virtual machine and
# obtain an object identifying it.
vm_list = server.get_vm_list()
result= vm_list.wait()

print prlsdkapi.prlsdk.consts.ScanCodesList

# Look for the VM with the name speficied on the CLI
found = False
for i in range(result.get_params_count()):
  VM = result.get_param_by_index(i)
  print VM.get_name()
  if VM.get_name() == vm_name:
    found = True
    break

press = consts.PKE_PRESS
release = consts.PKE_RELEASE

# Access the Remote Desktop Access session
vm_io = prlsdkapi.VmIO()
try:
  vm_io.connect_to_vm(VM).wait()
except prlsdkapi.PrlSDKError, e:
  print "Error: %s" % e
  exit()

scan_code = consts.ScanCodesList[keyname]

if state == 'press':
  vm_io.send_key_event(VM,scan_code,press)
elif  state == 'release':
  vm_io.send_key_event(VM,scan_code,release)
else:
  print "invalid state: %s" % state
  exit()

# End the Remote Deskop Access session
vm_io.disconnect_from_vm(VM)

# Logoff and deinitialize the library
server.logoff()
prlsdkapi.deinit_sdk
