
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





Set loginctx = CreateObject(LOGIN_CONTEXT_PROGID)
Set policy = CreateObject(SECURITY_POLICY_PROGID)
Set scsr = CreateObject(ACCOUNT_PROGID)
Set jcsr = CreateObject(ACCOUNT_PROGID)
Set su = CreateObject(ACCOUNT_PROGID)





wscript.echo "-- Login as superuser --"
Set ctx = loginctx.Login("su", "csr", "csr123")



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



wscript.echo "-- Test getRoleByID --"
Dim caps1
dim cap1
dim at
Set role = policy.GetRoleByID(ctx, 1)
Set caps1 = role.GetActivePolicy().Capabilities
Dim idx
idx = 1
for each cap1 in caps1
	wscript.echo "Capability " & idx & ": " & cap1.CapabilityType.Name
	idx = idx + 1 
	 for each at in cap1.AtomicCapabilities
	 	if at.CapabilityType.Name = "MTAccessTypeCapability" then
			wscript.echo "Access type:" & at.AccessType
		end if
		if at.CapabilityType.Name = "MTPathCapability" then
			wscript.echo "Path:" & at.PathParameter.Path
		end if
	 
	Next

Next

wscript.echo "-- Done --"

wscript.echo "-- Test RemoveCapabilitiesOfType --"
Set role = policy.GetRoleByID(ctx, 1)
role.GetActivePolicy().RemoveCapabilitiesOfType(3)
role.Save()
Set role = policy.GetRoleByID(ctx, 1)
Set caps1 = role.GetActivePolicy().Capabilities
For each cap1 in caps1
	wscript.echo "Capability " & idx & ": " & cap1.CapabilityType.Name
	idx = idx + 1 
	 for each at in cap1.AtomicCapabilities
	 	if at.CapabilityType.Name = "MTAccessTypeCapability" then
			wscript.echo "Access type:" & at.AccessType
		end if
		if at.CapabilityType.Name = "MTPathCapability" then
			wscript.echo "Path:" & at.PathParameter.Path
		end if
	 
	Next

Next

wscript.echo "-- Done --"










		





