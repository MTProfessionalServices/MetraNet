'
' routing queue preprocessor
' Derek Young - Jan 21 2000
'
option explicit

const MQ_RECEIVE_ACCESS = 00000001
const MQ_DENY_NONE = 00000000

'
' the Services array contains a list of services names.  Messages
' with any of these services are removed from the routing queue journal
' before the auditor is run.
' NOTE: Be sure to include the <dn></dn> tags!
'
Dim Services
Services = Array ( _
	"<dn>metratech.com/accountcreation</dn>", _
	"<dn>metratech.com/findbynumberdatetype</dn>", _
	"<dn>metratech.com/findupdatebynumberdatetype</dn>", _
	"<dn>metratech.com/addaccount</dn>", _
	"<dn>metratech.com/updateaccount</dn>", _
	"<dn>metratech.com/deleteaccount</dn>", _
	"<dn>metratech.com/findbyaccountid</dn>", _
	"<dn>metratech.com/findbyaccountidlast4type</dn>", _
	"<dn>metratech.com/validatecard</dn>")


' utility class to convert the body to a string
Dim auditLib
set auditLib = CreateObject("AuditUtilLib.AuditUtil")


function OpenRoutingQueueJournal(name)
	Dim iq
	set iq = CreateObject ("MSMQ.MSMQQueueInfo")
	iq.PathName = ".\" & name
	iq.Refresh

	Dim iqJournal
	set iqJournal = CreateObject ("MSMQ.MSMQQueueInfo")
	iqJournal.FormatName = iq.FormatName + ";JOURNAL"
	Dim queue
	set queue = iqJournal.Open(MQ_RECEIVE_ACCESS, MQ_DENY_NONE)
	set OpenRoutingQueueJournal = queue
end function

function HandleMsg(msg)
	' conver the body to a string so we can sear
	Dim body
	body = auditLib.ConvertToString(msg.Body, 500)

	' lowercase it
	body = lcase(body)

	' don't erase
	HandleMsg = false

	dim i
	for i = LBound(Services) to UBound(Services)
		Dim service
		service = lcase(Services(i))

		if Instr(body, service) > 0 then
			'wscript.echo "label: " & msg.Label
			'wscript.echo "body: " & body
			' erase the message
			HandleMsg = true
		end if
	next
end function

Dim queue
set queue = OpenRoutingQueueJournal("routingqueue")

dim firstread
firstread = true
do while true
	' read the message
	Dim msg
	if firstread then
		set msg = queue.PeekCurrent(false, true, 0)
		firstread = false
	else
		set msg = queue.PeekNext(false, true, 0)
	end if

	' exit if it's the last
	if msg is nothing then
		exit do
	end if

	' handle this message
	dim erase
	erase = HandleMsg(msg)

	if erase then
		wscript.echo "Removing message " & msg.Label
		Dim received
		received = queue.ReceiveCurrent(0, null, false, false)
		' do a PeekCurrent next time through the loop
		firstread = true
	end if
loop

queue.close

