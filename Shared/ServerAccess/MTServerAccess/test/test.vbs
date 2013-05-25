

wscript.echo "-- Testing MTServerAccess creation --"
set sa = CreateObject("MTServerAccess.MTServerAccessDataSet.1")
'sa.initialize 
sa.initializefromlocation ("e:\development\config\serveraccess")

For Each obj In sa
	wscript.echo " -----------------------------"
	wscript.echo " ServerType: " & obj.ServerType
	wscript.echo " ServerName: " & obj.ServerName
	wscript.echo " NumRetries: " & obj.NumRetries
	wscript.echo " Timeout: " & obj.Timeout
	wscript.echo " Priority: " & obj.Priority
	wscript.echo " Secure: " & obj.Secure
	wscript.echo " Port Number: " & obj.PortNumber
	wscript.echo " UserName: " & obj.UserName
	wscript.echo " Password: " & obj.Password
Next

wscript.echo " -------------- Edited Failed Transaction ------------"
dim anotherobj
set anotherobj = sa.FindAndReturnObject("EditedFailedTransaction") 
wscript.echo " ServerType (E F T): " & anotherobj.ServerType
wscript.echo " ServerName (E F T): " & anotherobj.ServerName
wscript.echo " NumRetries (E F T): " & anotherobj.NumRetries
wscript.echo " Timeout (E F T): " & anotherobj.Timeout
wscript.echo " Priority (E F T): " & anotherobj.Priority
wscript.echo " Secure (E F T): " & anotherobj.Secure
wscript.echo " Port Number (E F T): " & anotherobj.PortNumber
wscript.echo " UserName (E F T): " & anotherobj.UserName
wscript.echo " Password (E F T): " & anotherobj.Password

wscript.echo "Successful Execution"
