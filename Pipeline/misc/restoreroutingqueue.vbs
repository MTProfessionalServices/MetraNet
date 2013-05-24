'
' restore the routing queue and error queue from backup queues
' Derek Young - Jan 21 2000
'
option explicit

const MQ_RECEIVE_ACCESS = 00000001
const MQ_DENY_NONE = 00000000
const MQ_PEEK_ACCESS = &h00000020
const MQ_SEND_ACCESS = &h00000002
const MQMSG_DELIVERY_EXPRESS = 0
const MQMSG_DELIVERY_RECOVERABLE = 1

sub CopyQueue(source, dest, journal)
	wscript.echo "Copying queue " & source & " to queue " & dest

	Dim newQueueInfo
	set newQueueInfo = CreateObject("MSMQ.MSMQQueueInfo")
	newQueueInfo.PathName = ".\" & dest
	newQueueInfo.Refresh
	Dim newQueue
	set newQueue = newQueueInfo.Open(MQ_SEND_ACCESS, MQ_DENY_NONE)

	Dim iq
	set iq = CreateObject("MSMQ.MSMQQueueInfo")
	iq.PathName = ".\" & source
	iq.Refresh

	Dim iqJournal
	set iqJournal = CreateObject("MSMQ.MSMQQueueInfo")
	if journal then
		iqJournal.FormatName = iq.FormatName + ";JOURNAL"
	else
		iqJournal.FormatName = iq.FormatName
	end if

	Dim queue
	set queue = iqJournal.Open(MQ_PEEK_ACCESS, MQ_DENY_NONE)

	' Point the cursor to the first message in the queue.
	Dim msgRec
	Set msgRec = queue.PeekCurrent(false, true, 0)
	If msgRec Is Nothing Then
		Exit Sub
	End If
  
	Do While True
		wscript.echo "Label: " + msgRec.Label
		' send to the new queue
		msgRec.Delivery = MQMSG_DELIVERY_RECOVERABLE
		msgRec.Send newQueue

		Set msgRec = queue.PeekNext(false, true, 0)
		If msgRec Is Nothing Then Exit Do
	Loop

	queue.close
end sub


Sub ReceiveAll(name)
	wscript.echo "Receiving all messages from queue " & name
	Dim iq
	set iq = CreateObject("MSMQ.MSMQQueueInfo")
	iq.PathName = ".\" & name
	iq.Refresh
	Dim queue
	set queue = iq.Open(MQ_RECEIVE_ACCESS, MQ_DENY_NONE)

	Dim message
	Set message = queue.Receive(0, false, true, 0)

	Do While True
		If message is nothing then Exit Do
		wscript.echo "Label: " + message.Label

		Set message = queue.Receive(0, false, true, 0)
	Loop
		
	queue.close
End Sub

CopyQueue "errorqueuebackup", "errorqueue", false

' to skip the restore of the routing queue journal, comment out the next
' two lines by placing a ' at the beginning of the lines:
CopyQueue "routingqueuebackup", "routingqueue", false
ReceiveAll "routingqueue"




