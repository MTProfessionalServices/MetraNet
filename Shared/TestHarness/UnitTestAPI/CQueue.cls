VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CQueue"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Public GUID         As String
Public PathName     As String
Public Initialized  As Boolean

Private m_objQInfo  As MSMQQueueInfo
Private m_objQ      As MSMQQueue

Private m_booOpened As Boolean

Private Function UpdateQueueInfo(ByVal strPathName As String) As Boolean

    Dim objQuery        As MSMQQuery
    Dim objQInfos       As MSMQQueueInfos
    Dim objQInfo        As MSMQQueueInfo
    Dim objQinfoTemp    As MSMQQueueInfo
    Dim lngCount        As Long
    
    Set objQuery = New MSMQQuery
    Set objQInfos = objQuery.LookupQueue()    'Label:=strQueueName
    
    objQInfos.Reset 'Go back to the beginning (Is this necessary?)

    strPathName = LCase(strPathName)
    
    Set objQinfoTemp = objQInfos.Next
    Do While Not (objQinfoTemp Is Nothing)
        Set objQInfo = objQinfoTemp
        
        If (strPathName = objQInfo.PathName) Then
        
            Me.GUID = objQInfo.QueueGuid
            Set m_objQInfo = objQInfo
            UpdateQueueInfo = True
            Exit Function
        End If
        Set objQinfoTemp = objQInfos.Next
    Loop
End Function

Public Function Initialize(ByVal strPathName As String) As Boolean
    PathName = strPathName
    Initialized = UpdateQueueInfo(PathName)
    Initialize = Initialized
End Function

Public Function OpenIt(Optional eAccess As MQACCESS = MQ_PEEK_ACCESS)
    
    Set m_objQ = m_objQInfo.Open(eAccess, MQ_DENY_NONE)
    m_booOpened = True
    OpenIt = m_booOpened
End Function

Public Function CloseIt() As Boolean
    If (m_booOpened) Then
        m_objQ.Close
        m_booOpened = False
    End If
    CloseIt = True
End Function

Private Sub Class_Terminate()
    CloseIt
End Sub

Public Function IsEmpty() As Boolean

    Dim objMessage As MSMQMessage
    m_objQ.Reset
    Set objMessage = m_objQ.PeekCurrent(, False, 100)
    IsEmpty = objMessage Is Nothing
End Function
