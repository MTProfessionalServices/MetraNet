
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
acc_adapter.initialize("myadapter")
if err then
    wscript.echo "ERROR:" & err.description 
end if

wscript.echo "-- Testing account property collection --"
wscript.echo "-- Testing AddData --"
set acc_prop_coll = CreateObject("MTAccount.MTAccountPropertyCollection.1")
acc_prop_coll.Add "SalesPersonID", 222
acc_prop_coll.Add "id_acc", 123
acc_prop_coll.Add "LastName", "Schmoe"
acc_prop_coll.Add "MyTime", "11/22/00"
acc_prop_coll.Add "MyFloat", 23423.45324
acc_prop_coll.Add "MyDecimal", 99999.99999

'wscript.echo "-- call addcontact --"
acc_adapter.adddata "MyAdapter", acc_prop_coll
if err then
    wscript.echo "ERROR:" & err.description 
end if



wscript.echo "-- Testing UpdateData --"
set acc_prop_coll = CreateObject("MTAccount.MTAccountPropertyCollection.1")
acc_prop_coll.Add "SalesPersonID", 222
acc_prop_coll.Add "id_acc", 123
acc_prop_coll.Add "LastName", "BlahBlah"
acc_prop_coll.Add "MyTime", "11/22/00"
acc_prop_coll.Add "MyFloat", 23423.45324
acc_prop_coll.Add "MyDecimal", 99999.99999

'wscript.echo "-- call addcontact --"
acc_adapter.updatedata "MyAdapter", acc_prop_coll
if err then
    wscript.echo "ERROR:" & err.description 
end If

wscript.echo "-- Testing SearchData --"
set acc_prop_coll = CreateObject("MTAccount.MTAccountPropertyCollection.1")

acc_prop_coll.Add "id_acc", 123

'wscript.echo "-- call addcontact --"
Set src = acc_adapter.searchdata ( "MyAdapter", acc_prop_coll)
if err then
    wscript.echo "ERROR:" & err.description 
end if


wscript.echo "Successful Execution"
' --------------- Account Adapter Stuff -----------------------------'
