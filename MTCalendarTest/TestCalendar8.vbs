wscript.echo "-- Testing calendar creation --"
set ucal = CreateObject("MTUserCalendar.MTUserCalendar.1")

wscript.echo "-- Testing range collection 1 creation --"
set rc1 = CreateObject("MTRangeCollection.MTRangeCollection.1")

wscript.echo "-- Testing range collection 2 creation --"
set rc2 = CreateObject("MTRangeCollection.MTRangeCollection.1")

wscript.echo "-- Testing range collection 3 creation --"
set rc3 = CreateObject("MTRangeCollection.MTRangeCollection.1")

wscript.echo "-- setting rc1.code = monday --"
rc1.code = "monday"

wscript.echo "-- setting ucal.monday = rc1 --"
ucal.monday = rc1

wscript.echo "-- setting rc2.code = wednesday --"
rc2.code = "wednesday"

wscript.echo "-- setting ucal.wednesday = rc2 --"
ucal.wednesday = rc2

wscript.echo "-- setting rc3.code = defaultweekend --"
rc3.code = "defaultweekend"

wscript.echo "-- setting ucal.defaultweekend = rc3 --"
ucal.defaultweekend = rc3

ucal.write ("E:\build\debug\bin\outfile2.xml")
wscript.echo "Successful Execution"


