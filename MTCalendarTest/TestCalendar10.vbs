wscript.echo "-- Testing calendar creation --"
set ucal = CreateObject("MTUserCalendar.MTUserCalendar.1")

wscript.echo "-- Testing date 1 creation --"
set date1 = CreateObject("MTDate.MTDate.1")

wscript.echo "-- Testing date 2 creation --"
set date2 = CreateObject("MTDate.MTDate.1")

wscript.echo "-- Testing range collection 1 creation --"
set rc1 = CreateObject("MTRangeCollection.MTRangeCollection.1")

wscript.echo "-- Testing range collection 2 creation --"
set rc2 = CreateObject("MTRangeCollection.MTRangeCollection.1")

wscript.echo "-- Testing range collection 3 creation --"
set rc3 = CreateObject("MTRangeCollection.MTRangeCollection.1")

wscript.echo "-- Testing range collection 4 creation --"
set rc4 = CreateObject("MTRangeCollection.MTRangeCollection.1")

wscript.echo "-- Testing range 1 creation --"
set r1 = CreateObject("MTRange.MTRange.1")

wscript.echo "-- Testing range 2 creation --"
set r2 = CreateObject("MTRange.MTRange.1")

wscript.echo "-- Testing range 3 creation --"
set r3 = CreateObject("MTRange.MTRange.1")

wscript.echo "-- Testing range 4 creation --"
set r4 = CreateObject("MTRange.MTRange.1")


wscript.echo "-- setting r1 properties --"
r1.starttime = "07:00 AM"
r1.endtime = "07:00 PM"
r1.code = "peak"

wscript.echo "-- setting r1 properties --"
r2.starttime = "08:00 AM"
r2.endtime = "09:00 PM"
r2.code = "peak"

wscript.echo "-- setting r3 properties --"
r3.starttime = "11:00 AM"
r3.endtime = "09:00 PM"
r3.code = "peak"

wscript.echo "-- setting r4 properties --"
r4.starttime = "12:00 AM"
r4.endtime = "09:00 PM"
r4.code = "peak"

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

wscript.echo "-- setting date1 properties --"
rc3.code = "holiday"
rc3.add(r3)
date1.date = "7/4/99"
date1.notes = "Independence Day"
date1.rangecollection = rc3

wscript.echo "-- setting date2 properties --"
rc4.code = "holiday"
rc4.add(r3)
date2.date = "12/25/99"
date2.notes = "Christmas"
date2.rangecollection = rc4

ucal.add(date1)
ucal.add(date2)

ucal.write ("E:\build\debug\bin\outfile2.xml")
wscript.echo "Successful Execution"


