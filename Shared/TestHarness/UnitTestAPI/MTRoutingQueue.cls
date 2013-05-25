VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MTRoutingQueue"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Private RQueue As CQueue

Public Function Initialize(Optional ByVal strMachineName As String) As Boolean
    If (Len(strMachineName) = 0) Then
        strMachineName = GetComputerName
    End If
    Set RQueue = New CQueue
    Initialize = RQueue.Initialize(strMachineName & "\RoutingQueue")
End Function

Private Function GetComputerName() As String
    Dim objWinApi As Object
    Set objWinApi = CreateObject("MTVBLIB.CWINDOWS")
    GetComputerName = objWinApi.ComputerName()
End Function

Public Function IsEmpty() As Boolean

    If (RQueue.OpenIt()) Then
    
        IsEmpty = RQueue.IsEmpty()
        RQueue.CloseIt
    Else
        Err.Raise 1000 + vbObjectError, "MTRoutingQueue.cls", "Cannot open the queue"
    End If
End Function

Public Function WaitUntilEmpty(Optional ByVal lngSleepPeriode As Long = 5000, Optional frmCallBack As Object) As Long

    Dim lngTime As Long
    
    lngTime = GetTickCount()
    Do While Not IsEmpty()
    
        DoEvents
        Sleep lngSleepPeriode
        If (IsValidObject(frmCallBack)) Then
        
            frmCallBack.RoutingQueueRefreh
        End If
    Loop
    WaitUntilEmpty = GetTickCount() - lngTime
End Function
