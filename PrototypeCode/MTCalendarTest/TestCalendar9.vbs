wscript.echo "-- Testing calendar creation --"
set ucal = CreateObject("MTUserCalendar.MTUserCalendar.1")

wscript.echo "-- Testing range collection 1 creation --"
set rc1 = CreateObject("MTRangeCollection.MTRangeCollection.1")

wscript.echo "-- Testing range collection 1 creation --"
set rc2 = CreateObject("MTRangeCollection.MTRangeCollection.1")

wscript.echo "-- Testing range 1 creation --"
set r1 = CreateObject("MTRange.MTRange.1")

wscript.echo "-- Testing range 1 creation --"
set r2 = CreateObject("MTRange.MTRange.1")

wscript.echo "-- setting r1 properties --"
r1.starttime = "07:00 AM"
r1.endtime = "07:00 PM"
r1.code = "peak"

wscript.echo "-- setting r1 properties --"
r2.starttime = "08:00 AM"
r2.endtime = "09:00 PM"
r2.code = "peak"

wscript.echo "-- setting rc1.code = monday --"
rc1.code = "monday"
rc1.add(r1)

wscript.echo "-- setting ucal.monday = rc1 --"
ucal.monday = rc1

wscript.echo "-- setting rc2.code = wednesday --"
rc2.code = "wednesday"
rc2.add(r2)

wscript.echo "-- setting ucal.wednesday = rc2 --"
ucal.wednesday = rc2

ucal.write ("E:\build\debug\bin\outfile2.xml")
wscript.echo "Successful Execution"




