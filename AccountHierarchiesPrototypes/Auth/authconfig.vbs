
Dim SECURITY_POLICY_PROGID
Dim SECURITY_CONTEXT_PROGID
Dim COMPOSITE_TYPE_PROGID
Dim ATOMIC_TYPE_PROGID
Dim COMPOSITE_PROGID
Dim ROLE_PROGID
Dim ACCOUNT_PROGID
Dim dsp


SECURITY_POLICY_PROGID = "MTAuthProto.MTSecurityPolicy"
ACCOUNT_PROGID = "MTAuthProto.MTAuthAccount"
ROLE_PROGID = "MTAuthProto.MTRole"
SECURITY_CONTEXT_PROGID = "MTAuthProto.MTSecurityContext"
LOGIN_CONTEXT_PROGID = "MTAuthProto.MTLoginContext"
COMPOSITE_TYPE_PROGID = "MTAuthProto.MTCompositeCapabilityType"
ATOMIC_TYPE_PROGID = "MTAuthProto.MTAtomicCapabilityType"
COMPOSITE_PROGID = "MTAuthProto.MTCompositeCapability"
PATH_CAP_PROGID = "MTAuthProto.MTPathCapability"
ACCESSTYPE_CAP_PROGID = "MTAuthProto.MTAccessTypeCapability"




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
'accounts
Dim scsr
Dim jcsr
Dim su
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
Set scsr = CreateObject(ACCOUNT_PROGID)
Set jcsr = CreateObject(ACCOUNT_PROGID)
Set su = CreateObject(ACCOUNT_PROGID)

Set ctx = CreateObject(SECURITY_CONTEXT_PROGID)



wscript.echo "-- Configuring su account (126) --"
su.ID = 126
su.GetActivePolicy().AddRole(all)
su.Save()
wscript.echo "-- Done --"

wscript.echo "-- Configuring scsr account (128) --"
scsr.ID = 128
wscript.echo "-- Adding SeniorCSR Role to 128 --"
scsr.GetActivePolicy().AddRole(seniorcsr)
scsr.Save()

wscript.echo "-- Configuring jcsr account (127) --"
jcsr.ID = 127
jcsr.GetActivePolicy().AddRole(engcsr)
jcsr.Save()




wscript.echo "-- Query Policy for all existing roles --"
Dim allroles
Dim role
Set allroles = policy.GetAllRoles(ctx)


For each role in allroles
	wscript.echo "Name:" & role.Name & bvNewLine
	wscript.echo "Description:" & role.Description & bvNewLine

Next

wscript.echo "-- Query Policy for all existing roles as rowset --"
Dim rs
Set rs = policy.GetAllRolesAsRowset(ctx)

rs.MoveFirst

While rs.EOF = false
	wscript.echo rs.Value(1)
	rs.MoveNext
Wend
wscript.echo "-- Done --"

wscript.echo "-- Query Policy for role by it's ID --"
Set role = policy.GetRoleByID(ctx, 1)
wscript.echo role.Name
wscript.echo role.Description
wscript.echo "-- Done --"

Dim captype
wscript.echo "-- Query Policy for capability type by it's ID --"
Set captype = policy.GetCapabilityTypeByID(ctx, 3)
wscript.echo captype.Name
wscript.echo captype.Description
wscript.echo "-- Done --"


wscript.echo "-- Query Policy for available to role capabilities by it's ID --"

Set rs = policy.GetAvailableCapabilityTypesAsRowset(ctx, 1, 0) ' 1 for ROLE_

If rs.EOF = true Then
	wscript.echo "-- No available capability types for role with id " & Str(3) & " --"

Else
rs.MoveFirst

While rs.EOF = false
	wscript.echo rs.Value(1)
	rs.MoveNext
Wend
End If
wscript.echo "-- Done --"



wscript.echo "-- Testing Properties on Role --"
Dim pr
For each pr in role.Properties
	wscript.echo "Property Name:" & pr.Name
	wscript.echo "Property Value:" & pr.Value
Next
wscript.echo "-- Done --"

wscript.echo "-- Query Policy for SeniorCSR Role --"
Set role = policy.GetRoleByName(ctx, "SeniorCSR")
wscript.echo "Name:" & role.Name & bvNewLine
wscript.echo "Description:" & role.Description & bvNewLine
wscript.echo "-- Done --"

wscript.echo "-- Query Active policy on SeniorCSR role for existing capabilities --"
Dim existingcap
For each existingcap in role.GetActivePolicy().Capabilities
	wscript.echo "Name:" & existingcap.CapabilityType.Name & bvNewLine
Next
wscript.echo "-- Done --"

wscript.echo "-- Adding ManageGlobalAuth capability to SeniorCSR Role --"
Set mgacap = policy.GetCapabilityTypeByName(ctx, "MTManageGlobalAuth").CreateInstance()
role.GetActivePolicy().AddCapability(mgacap)
wscript.echo "-- Saving SeniorCSR Role --"
role.Save
wscript.echo "-- Done --"
Set role = nothing
wscript.echo "-- Query Active policy on SeniorCSR role for existing capabilities (again) It should have two capabilities --"
For each existingcap in policy.GetRoleByName(ctx, "SeniorCSR").GetActivePolicy().Capabilities
	wscript.echo "Name:" & existingcap.CapabilityType.Name & bvNewLine
Next
wscript.echo "-- Done --"

wscript.echo "-- Test Updating MTManageAH capability on SeniorCSR role--"
Dim param
Dim pathcap
Set role = policy.GetRoleByName(ctx, "SeniorCSR")
Set mahcap = role.GetActivePolicy().Capabilities.Item(1)
wscript.echo "-- Existing path parameters: --"
Set pathcap = mahcap.AtomicCapabilities.Item(2)
	For each param in pathcap.PathParameters
		wscript.echo "Path:" & param
	Next
pathcap.AddPathParameter("/boris/-")
Role.Save

wscript.echo "-- Done --"

wscript.echo "-- Test Removing MTManageAH capability from SeniorCSR role--"
Set role = policy.GetRoleByName(ctx, "SeniorCSR")
Set mahcap = role.GetActivePolicy().Capabilities.Item("MTManageGlobalAuth")
role.GetActivePolicy().RemoveCapability(mahcap)
Role.Save

wscript.echo "-- Done --"



wscript.echo "-- Creating Default Security Policy on Engineering folder (134) --"
Set eng = policy.GetAccountByID(ctx, 134)
Set dsp = eng.GetDefaultPolicy()
dsp.AddRole(DefaultEngineeringRole)
eng.Save
'DefaultEngineeringRole



' wscript.echo "-- Performing runtime access check --"









		




