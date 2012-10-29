import sys
import prlsdkapi
import string

if len(sys.argv) != 3:
    print "Usage: parallels_send_string '<VM_NAME>' '<string>'"
    exit()

# Parse arguments
vm_name=sys.argv[1]
# String to use
keynames = sys.argv[2].split(' ');

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

for keyname in keynames:
    if(keyname != ''): 
	# Keys can also contain special keys like shift, that has to be pressed before and release after
	# eg. SHIFT-C (Press shift, then press C)
	keys = keyname.split('#');

	for keypress in keys: 
    		scan_code = consts.ScanCodesList[keypress]
    		vm_io.send_key_event(VM,scan_code,press,50)

	# And now the reversed order
	# eg. Now release C then SHIFT
	for keypress in reversed(keys):
    		scan_code = consts.ScanCodesList[keypress]
    		vm_io.send_key_event(VM,scan_code,release,50)

# End the Remote Deskop Access session
vm_io.disconnect_from_vm(VM)

# Logoff and deinitialize the library
server.logoff()
prlsdkapi.deinit_sdk
