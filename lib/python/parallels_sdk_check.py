import sys
import prlsdkapi

prlsdk = prlsdkapi.prlsdk
consts = prlsdkapi.prlsdk.consts

# Initialize the Parallels API Library
prlsdk.InitializeSDK(consts.PAM_DESKTOP_MAC)

# Obtain a server object identifying the Parallels Service.
server = prlsdkapi.Server()

# Log in. (local as we do Parallels Desktop
login_job=server.login_local()
login_job.wait()

# Logoff and deinitialize the library
server.logoff()
prlsdkapi.deinit_sdk
