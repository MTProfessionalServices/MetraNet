'
' print a list of lost sessions
' Derek Young - Dec 4 2001
'
option explicit

const MQ_RECEIVE_ACCESS = 00000001
const MQ_DENY_NONE = 00000000
const MQ_PEEK_ACCESS = &h00000020
const MQ_SEND_ACCESS = &h00000002
const MQMSG_DELIVERY_EXPRESS = 0
const MQMSG_DELIVERY_RECOVERABLE = 1

'


sub GetLabelList(machine, source, journal, dict)
  Dim iq
  set iq = CreateObject("MSMQ.MSMQQueueInfo")
'  iq.PathName = ".\" & source
  iq.FormatName = "DIRECT=OS:" + machine + "\PRIVATE$\" + source
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
    dict.Add msgRec.Label, msgRec.Label
    'wscript.echo "Label: " + msgRec.Label
    ' send to the new queue

    Set msgRec = queue.PeekNext(false, true, 0)
    If msgRec Is Nothing Then Exit Do
  Loop

  queue.close
end sub

Dim rq
Set rq = CreateObject("Scripting.Dictionary")
GetLabelList ".", "routingqueue", True, rq

Dim label
'For Each label in rq
'    wscript.echo "--> " + label
'Next

Dim eq
Set eq = CreateObject("Scripting.Dictionary")
GetLabelList ".", "errorqueue", false, eq

'For Each label in eq
'    wscript.echo "==> " + label
'Next

'wscript.echo "Lost sessions"
For Each label in rq
    If Not eq.exists(label) then
        wscript.echo "controlpipeline -resubmitlost " + label
    End If
Next

