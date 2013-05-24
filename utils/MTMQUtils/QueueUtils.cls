VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "QueueUtils"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True


Option Explicit

Private Declare Function MQPurgeQueue Lib "mqrt.dll" (ByVal hQueue As Long) As Long
Private Const MQ_OK = 0

Public Sub ConnectToQueue(ByVal fmtname As String)
    Dim QInfo As MSMQQueueInfo
    Dim queue As MSMQQueue
    
    Set QInfo = New MSMQQueueInfo
    QInfo.formatname = fmtname

    ' open it, then close it
    Set queue = QInfo.Open(MQ_RECEIVE_ACCESS, MQ_DENY_NONE)
    queue.Close
    
    Set queue = Nothing
    Set QInfo = Nothing

End Sub

Public Sub PurgeQueue(ByVal name As String)
    Dim QInfo As MSMQQueueInfo
    Dim queue As MSMQQueue
    
    Set QInfo = New MSMQQueueInfo
    QInfo.PathName = name

    Set queue = QInfo.Open(MQ_RECEIVE_ACCESS, MQ_DENY_NONE)
    
    'If Queue Is Nothing Then
    '     "Couldn't open queue."
    '    Exit Sub
    'End If
        
    Dim result As Long
    
    result = MQPurgeQueue(queue.Handle)
    
    ' You should check the result for errors here
    If result <> MQ_OK Then
        Err.Raise result, "Unable to purge queue" & name
    End If
    
    queue.Close
    
    Set queue = Nothing
    Set QInfo = Nothing
End Sub

Public Sub PurgeJournal(ByVal name As String)
    Dim QInfo As MSMQQueueInfo
    Dim queue As MSMQQueue
    
    Set QInfo = New MSMQQueueInfo
    QInfo.PathName = name
    'QInfo.FormatName = QInfo.FormatName & ";JOURNAL"
    'QInfo.Refresh

    QInfo.formatname = QInfo.formatname & ";JOURNAL"

    Set queue = QInfo.Open(MQ_RECEIVE_ACCESS, MQ_DENY_NONE)
    
    'If Queue Is Nothing Then
    '     "Couldn't open queue."
    '    Exit Sub
    'End If
        
    Dim result As Long
    
    result = MQPurgeQueue(queue.Handle)
    
    ' You should check the result for errors here
    If result <> MQ_OK Then
        Err.Raise result, "Unable to purge queue" & name
    End If
    
    queue.Close
    
    Set queue = Nothing
    Set QInfo = Nothing
End Sub

Public Sub PurgeDeadLetterQueue()
    Dim qinfoJournal As New MSMQQueueInfo
    Dim queue As MSMQQueue

    Dim strMachineId As String

    ' Obtain machine GUID.
    'strMachineId = MachineIdOfMachineName(vbNullString)
  
    'Set QInfo = New MSMQQueueInfo
    'qinfoJournal.PathName = "fission\deadletter$"
    qinfoJournal.formatname = "DIRECT=OS:.\SYSTEM$;DEADLETTER"

    ' Construct format name of dead-letter queue.
    ' MSMQQueueInfo.Refresh must be called to obtain registered
    ' format name of destination queue.
    'qinfoJournal.FormatName = "MACHINE=" + strMachineId + "\Private$\;DEADLETTER"
    
    '***********************************************************
    ' Open queue for retrieving messages.
    '***********************************************************
    Set queue = qinfoJournal.Open(MQ_RECEIVE_ACCESS, MQ_DENY_NONE)
  
    Dim result As Long
    
    result = MQPurgeQueue(queue.Handle)
    
    ' You should check the result for errors here
    If result <> MQ_OK Then
        Err.Raise result, "Unable to purge dead letter queue"
    End If
    
    queue.Close

End Sub
  

