'
' receive all messages from the routing queue
' Derek Young - Jan 21 2000
'
option explicit

const MQ_RECEIVE_ACCESS = 00000001
const MQ_DENY_NONE = 00000000
const MQ_PEEK_ACCESS = &h00000020
const MQ_SEND_ACCESS = &h00000002
const MQMSG_DELIVERY_EXPRESS = 0
const MQMSG_DELIVERY_RECOVERABLE = 1


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

ReceiveAll "routingqueue"
