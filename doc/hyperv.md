# HyperV VM Provider

The HyperV PowerShell libraries provided by Microsoft and also those found on CodePlex are constrained to specific
host and hyperV windows versions, meaning that only the following combinations are possible:
 - Windows 7 => HyperV 2008
 - Windows 8 => HyperV 2012

To get around this limitation the HyperV provider relies on remote command invocation on the target HyperV server using
the Invoke-Command PowerShell cmdlet.