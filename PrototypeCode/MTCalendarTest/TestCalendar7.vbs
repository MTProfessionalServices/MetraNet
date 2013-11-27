

wscript.echo "-- Testing calendar creation --"
set ucal = CreateObject("MTUserCalendar.MTUserCalendar.1")
ucal.readfromhost "gargoyle", "calendar.xml"


wscript.echo "Testing Monday:"
if ucal.Monday is nothing then
	wscript.echo "    Monday is Nothing"
else
	wscript.echo "    Monday is valid"
end if

wscript.echo "Testing Tuesday:"
if ucal.Tuesday is nothing then
	wscript.echo "    Tuesday is Nothing"
else
	wscript.echo "    Tuesday is valid"
end if

wscript.echo "Testing Wednesday:"
if ucal.Wednesday is nothing then
	wscript.echo "    Wednesday is Nothing"
else
	wscript.echo "    Wednesday is valid"
end if

wscript.echo "Testing Thursday:"
if ucal.Thursday is nothing then
	wscript.echo "    Thursday is Nothing"
else
	wscript.echo "    Thursday is valid"
end if

wscript.echo "Testing Friday:"
if ucal.Friday is nothing then
	wscript.echo "    Friday is Nothing"
else
	wscript.echo "    Friday is valid"
end if


wscript.echo "Testing Saturday:"
if ucal.Saturday is nothing then
	wscript.echo "    Saturday is Nothing"
else
	wscript.echo "    Saturday is valid"
end if


wscript.echo "Testing Sunday:"
if ucal.Sunday is nothing then
	wscript.echo "    Sunday is Nothing"
else
	wscript.echo "    Sunday is valid"
end if


For Each obj In ucal
	wscript.echo " Date: " & obj.date
	wscript.echo " Notes: " & obj.notes
Next

ucal.remove (cdate("12/12/99")) 
ucal.remove (cdate("7/4/99")) 
ucal.remove (cdate("1/1/99")) 
ucal.remove (cdate("12/25/99")) 

For Each obj In ucal
	wscript.echo " Date: " & obj.date
	wscript.echo " Notes: " & obj.notes
Next

ucal.writetohost "gargoyle", "eatshit.xml"

wscript.echo "Successful Execution"
