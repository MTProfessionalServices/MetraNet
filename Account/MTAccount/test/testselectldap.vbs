
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
acc_adapter.initialize("LDAP")
if err then
    wscript.echo "ERROR:" & err.description 
end if

wscript.echo "-- Testing account property collection --"
set acc_prop_coll = CreateObject("MTAccount.MTAccountPropertyCollection.1")
'acc_prop_coll.Add "firstname", "Joe"
'acc_prop_coll.Add "lastname", "Schmoe"
'acc_prop_coll.Add "email", "schmoe@metratech.com"
'acc_prop_coll.Add "phonenumber", "2125551212"
'acc_prop_coll.Add "accounttype", 765
acc_prop_coll.Add "_accountid", 126 
'acc_prop_coll.Add "company", "MetraTech"
'acc_prop_coll.Add "address1", "330 Bear Hill Road"
'acc_prop_coll.Add "address2", ""
'acc_prop_coll.Add "address3", ""
'acc_prop_coll.Add "city", "Waltham"
'acc_prop_coll.Add "state", "MA"
'acc_prop_coll.Add "zip", "02451"
'acc_prop_coll.Add "country", "USA"
'acc_prop_coll.Add "facsimiletelephonenumber", "212 555 1212"
'acc_prop_coll.Add "middleinitial", "V"

' Creating Search Result Collection
'set searchresultcoll = CreateObject("MTAccount.MTSearchResultCollection.1")
'If Err Then
'wscript.echo "ERROR:" & Err.Description
'End If

' Call search --"
wscript.echo "-- Call Search --"
dim searchresultcoll
Set searchresultcoll = acc_adapter.SearchData ("LDAP", acc_prop_coll)
If Err Then
    wscript.echo "ERROR:" & Err.Description
End If
    
'wscript.echo "-- iterate --"
For Each obj In searchresultcoll
    For Each obj2 In obj
        wscript.echo "Name :: " & obj2.Name & " --> Value :: " & obj2.Value
    Next
Next
If Err Then
    wscript.echo "ERROR:" & Err.Description
End If
wscript.echo "Successful Execution"
' --------------- Account Adapter Stuff -----------------------------'
