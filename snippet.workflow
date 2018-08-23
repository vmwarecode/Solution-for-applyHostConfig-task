Done with an Orchestrator Workflow invoking powershell, this is a workaround. However it works.

var	vlanKey = '<our vlan key>';
script="Get-Module -Name VMware* -ListAvailable | Import-Module -ErrorAction SilentlyContinue\n"
script+='$username="'+username+'"\n'
script+="$secpasswd = ConvertTo-SecureString "+password+" -AsPlainText -Force\n"
script+="$vccredential = New-Object System.Management.Automation.PSCredential ($username, $secpasswd)\n"
script+="Connect-VIServer $vcenter -Credential $vccredential  -ErrorAction Continue -WarningAction SilentlyContinue | out-null\n"
script+="$esxhost = get-vmhost "+esxHostname+"\n"
script+="$profile = get-vmhost "+esxHostname+"|Get-VMHostProfile\n"
script+="$additionalConfiguration = Apply-VMHostProfile -ApplyOnly -Profile $profile -Entity $esxhost -Confirm:$false\n"
script+="$additionalConfiguration['network.dvsHostNic[\"key-vim-profile-host-DvsHostVnicProfile-dvSwitch-"+vlanKey+"-vmk1\"].ipConfig.IpAddressPolicy.address'] = 'x.x.x.x'\n"
script+="$additionalConfiguration['network.dvsHostNic[\"key-vim-profile-host-DvsHostVnicProfile-dvSwitch-"+vlanKey+"-vmk1\"].ipConfig.IpAddressPolicy.subnetmask'] = '255.255.255.0'\n"
script+="Apply-VMHostProfile -ApplyOnly -Profile $profile -Entity $esxhost -Variable $additionalConfiguration -Confirm:$false\n"
System.log(script);
var output;
var session;
try {
	session = host.openSession();
	output = System.getModule("com.vmware.library.powershell").invokeScript(host,script,session.getSessionId()) ;
	
	
} finally {
	if (session){
		host.closeSession(session.getSessionId());
	}
}