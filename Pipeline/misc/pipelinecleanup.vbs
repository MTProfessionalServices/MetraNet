'
' pipeline cleanup
' purges queues and deletes shared memory file before the pipeline starts
' Derek Young - Jan 21 2000
'
option explicit

const MQ_RECEIVE_ACCESS = 00000001
const MQ_DENY_NONE = 00000000


'
' list of queues to be purged
'
Dim Queues
Queues = Array ( _
	"accountcreationqueue", _
	"acctccmapqueue", _
	"audioconfcallqueue", _
	"audioconfconnqueue", _
	"creditqueue", _
	"debitqueue", _
	"discountsqueue", _
	"errorqueue", _
	"feedbackqueue", _
	"passthroughqueue", _
	"postauthqueue", _
	"quotequeue", _
	"recurringchargequeue", _
	"settlequeue", _
	"testqueue", _
	"validatecardqueue", _
	"writeproductviewqueue")

Dim Sessions
Sessions = "c:\metratech\rmp\sessions.bin"



sub PurgeQueue(name)
	wscript.echo "Purging queue " & name

	Dim iq
	set iq = CreateObject ("MSMQ.MSMQQueueInfo")
	iq.PathName = ".\" & name
	iq.Refresh
	Dim queue
	set queue = iq.Open(MQ_RECEIVE_ACCESS, MQ_DENY_NONE)

	Dim count
	count = 0
	do while true
		' read the message
		Dim msg

		set msg = queue.Receive(0, false, false, 0)

		' exit if it's the last
		if msg is nothing then
			exit do
		end if
		count = count + 1
	loop

	wscript.echo "" & count & " messages removed"

	queue.close
end sub

' ignore errors - do as much cleanup as we can
'on error resume next

' purge all queues listed above
dim queuename
for each queuename in Queues
	PurgeQueue queuename
next

' delete the sessions file
wscript.echo "Deleting file " & Sessions
dim fso
set fso = CreateObject("Scripting.FileSystemObject")
fso.DeleteFile(Sessions)

