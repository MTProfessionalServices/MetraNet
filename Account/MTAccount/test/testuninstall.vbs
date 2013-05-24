
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
acc_adapter.initialize("internal")
if err then
    wscript.echo "ERROR:" & err.description 
end if

wscript.echo "-- installing --"
acc_adapter.Uninstall

wscript.echo "Successful Execution"
' --------------- Account Adapter Stuff -----------------------------'
