'
' How to wait for the pipeline to finish to process the transaction
'
Dim objRoutingQueue ' As Object
Dim lngTime         ' As Long

Set objRoutingQueue = CreateObject("MTTestApi.MTRoutingQueue")

WScript.Echo "Initializing the RoutingQueue..."

' Initialize use by default the current machine. You can also define the machine name this way : objRoutingQueue.Initialize "SOGE"
' If you care about timing, please initialize the object before you start send transaction to the pipeline. The Initialization
' can take a couples of second.

If(objRoutingQueue.Initialize())Then

	WScript.Echo "Waiting..."

	' The function will wait until the routing queue is empty and returns the time in milli-second.
	lngTime = objRoutingQueue.WaitUntilEmpty(5000) ' 5000 defines the number of second the task must sleep for each loop.
						       ' If you do some timing performance study, this may affect a little bit the result!
						       ' A to small value will also affect the result because this function will use to much CPU.
						       ' Up to you to chose the right value.

	' 
	' DO NOT FORGET THIS.
	'
	' Though the routing queue is empty the pipeline may be still processing more than one transactions.
	' So if you do not care about timing, just put WScript.Sleep 15000 at the end.
	' If you care about timing I will advice you to monitor the CPU and wait for the Performance Monitor
	' CPU Value go down to 0.
		
	WScript.Echo "Done..."
Else
	WScript.Echo "Cannot Initialize the Routing Queue"
End If

Set objRoutingQueue = Nothing