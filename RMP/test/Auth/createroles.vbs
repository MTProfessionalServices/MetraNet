Dim SECURITY_POLICY_PROGID
Dim SECURITY_CONTEXT_PROGID
Dim COMPOSITE_TYPE_PROGID
Dim ATOMIC_TYPE_PROGID
Dim COMPOSITE_PROGID
Dim ROLE_PROGID
Dim ACCOUNT_PROGID
Dim dsp


SECURITY_POLICY_PROGID = "Metratech.MTSecurity"
ACCOUNT_PROGID = "Metratech.MTYAAC"
ROLE_PROGID = "Metratech.MTRole"
SECURITY_CONTEXT_PROGID = "Metratech.MTSecurityContext"
LOGIN_CONTEXT_PROGID = "Metratech.MTLoginContext"
COMPOSITE_TYPE_PROGID = "Metratech.MTCompositeCapabilityType"
ATOMIC_TYPE_PROGID = "Metratech.MTAtomicCapabilityType"
COMPOSITE_PROGID = "Metratech.MTCompositeCapability"
PATH_CAP_PROGID = "Metratech.MTPathCapability"
ACCESSTYPE_CAP_PROGID = "Metratech.MTAccessTypeCapability"
SESSION_CONTEXT_PROGID = "Metratech.MTSessionContext"




Dim allcaps
Dim cap
Dim loginctx
Dim ctx
Dim policy
'roles
Dim seniorcsr
Dim engcsr
Dim all
Dim defaultengineeringrole
'caps
Dim allcap
Dim mgacap
Dim id

Dim mrc 
Dim mahcap
Dim defaultmahcap
Dim rolecap

Dim atomics

Dim eng

Set loginctx = CreateObject(LOGIN_CONTEXT_PROGID)
Set policy = CreateObject(SECURITY_POLICY_PROGID)
Set seniorcsr = CreateObject(ROLE_PROGID)
Set secadmin = CreateObject(ROLE_PROGID)
Set defaultengineeringrole = CreateObject(ROLE_PROGID)
Set engcsr = CreateObject(ROLE_PROGID)
Set all = CreateObject(ROLE_PROGID)

Set scsr = CreateObject(ACCOUNT_PROGID)
Set jcsr = CreateObject(ACCOUNT_PROGID)
Set su = CreateObject(ACCOUNT_PROGID)

Set login = CreateObject("Metratech.MTLoginContext")

Set ctx = login.Login("su", "system_user", "su123")

secadmin.Name = "SecurityAdministrator"
secadmin.Description = "Can manage Auth & Auth related information"
secadmin.CSRAssignable = True
secadmin.SubscriberAssignable = False

Set mrc = policy.GetCapabilityTypeByName("Manage System Wide Authorization Policies").CreateInstance()
wscript.echo "-- adding MTManageGlobalAuth cap to SecurityAdministrator role --"
secadmin.GetActivePolicy(ctx).AddCapability(mrc)
secadmin.Save()

Set rolecap = policy.GetCapabilityTypeByName("Manage Account Hierarchies").CreateInstance()

'reflection sort of behaviour is used here
'one can also call "helper" method to return
' needed atomic capability directly
' no interface enforces someone to add those helper methods, it's up to a developer
For each atomic in rolecap.AtomicCapabilities
	
	'discover existing atomic capabilities and
	'set parameters. This will be used by a GenericEditor
	'however for convenience every composite capability should provide accessors to get
	' an atomic directly, like composite.GetAtomicAccessTypeCapability etc. so that access checking code
	' doesn't have to iterate in order to find the right one (look at SeniorCSR role next)
	If atomic.CapabilityType.Name = "MTPathCapability" Then
		atomic.SetParameter "/metratech/engineering", 1 ' 1 == CURRENT_FOLDER
	Else If atomic.CapabilityType.Name = "MTEnumTypeCapability" Then
		atomic.SetParameter "WRITE" ' 1 for WRITE
	End If
	End If

Next

wscript.echo "-- configuring EngineeringCSR Role --"
engcsr.Name = "EngineeringCSR"
engcsr.Description = "Can view and modify all the accounts in Engineering folder"
engcsr.CSRAssignable = True
engcsr.SubscriberAssignable = True

wscript.echo "-- adding MTPathCapability cap to EngineeringCSR role --"
engcsr.GetActivePolicy(ctx).AddCapability(rolecap)
engcsr.Save()


wscript.echo "-- configuring SeniorCSR Role --"
seniorcsr.Name = "SeniorCSR"
seniorcsr.Description = "Big cheese, can manage all Metratech hierarchy and issue unlimited credits"
seniorcsr.CSRAssignable = True
seniorcsr.SubscriberAssignable = False

' create manage AH capability and grant it to SeniorCSR
Set mahcap = policy.GetCapabilityTypeByName("Manage Account Hierarchies").CreateInstance()
mahcap.GetAtomicEnumCapability().SetParameter "WRITE"
mahcap.GetAtomicPathCapability.SetParameter "/metratech", 1

seniorcsr.GetActivePolicy(ctx).AddCapability(mahcap)
seniorcsr.Save()

wscript.echo "-- configuring DefaultEngineeringRole Role --"
DefaultEngineeringRole.Name = "EgineeringFolderRole"
DefaultEngineeringRole.Description = "This role is applied as a DSP to any account, created under engineering"
Set defaultmahcap = policy.GetCapabilityTypeByName("Manage Account Hierarchies").CreateInstance()
defaultmahcap.GetAtomicEnumCapability().SetParameter "WRITE"
defaultmahcap.GetAtomicPathCapability.SetParameter "/metratech/engineering/", 1
wscript.echo "-- adding MTManageAH cap to EgineeringFolderRole role --"
DefaultEngineeringRole.GetActivePolicy(ctx).AddCapability(defaultmahcap)
DefaultEngineeringRole.Save()

wscript.echo "-- configuring SuperUser Role --"
wscript.echo "-- For now bypass security check by creating roles directly --"
all.Name = "SuperUser"
all.Description = "Unlimited access to the system"
all.CSRAssignable = True
all.SubscriberAssignable = False

Set allcap = policy.GetCapabilityTypeByName("Unlimited Capability").CreateInstance()
wscript.echo "-- adding MTAllCapability cap to SuperUser role --"
all.GetActivePolicy(ctx).AddCapability(allcap)
all.Save()

Dim cap1
Dim path
For each cap1 in seniorcsr.GetActivePolicy(ctx).GetCapabilitiesOfType(policy.GetCapabilityTypeByName("Manage Account Hierarchies").ID)
		wscript.echo cap1.CapabilityType.Name
		wscript.echo cap1.GetAtomicPathCapability().GetParameter.Path
	
Next

wscript.echo "-- Removing capabilities of type MTManageAH--"
seniorcsr.GetActivePolicy(ctx).RemoveCapabilitiesOfType(policy.GetCapabilityTypeByName("Manage Account Hierarchies").ID)
seniorcsr.Save()

Set seniorcsr = nothing
Set seniorcsr = policy.GetRoleByName(ctx,"SeniorCSR")

wscript.echo "-- done --"
For each cap1 in seniorcsr.GetActivePolicy(ctx).GetCapabilitiesOfType(policy.GetCapabilityTypeByName("Manage Account Hierarchies").ID)
		wscript.echo cap1.CapabilityType.Name
	
Next
