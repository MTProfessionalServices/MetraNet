
on error resume next

wscript.echo "-- Creating Account Adapter --"
dim acc_adapter 
set acc_adapter = CreateObject("MTAccount.MTAccountServer.1")
if err then
    wscript.echo "ERROR:" & err.description 
end if

if acc_adapter is nothing then
    wscript.echo "Object is nothing"
end if

wscript.echo "-- initializing account server --"
acc_adapter.initialize("Internal")
if err then
    wscript.echo "ERROR:" & err.description 
end if

wscript.echo "-- Testing account property collection --"
set acc_prop_coll = CreateObject("MTAccount.MTAccountPropertyCollection.1")
If Err Then
    wscript.echo "ERROR:" & Err.Description
End If

'
' Call GetData --"
Set acc_prop_coll = acc_adapter.GetData(123)
If Err Then
    wscript.echo "ERROR:" & Err.Description
End If
    
'wscript.echo "-- iterate --"
For Each obj In acc_prop_coll
    For Each obj2 In obj
        wscript.echo "Name :: " & obj2.Name & " --> Value :: " & obj2.Value
    Next
Next
If Err Then
    wscript.echo "ERROR:" & Err.Description
End If
wscript.echo "Successful Execution"
' --------------- Account Adapter Stuff -----------------------------'
