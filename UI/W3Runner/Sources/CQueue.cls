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
Attribute VB_Exposed = False
Private mColData As Collection
Private mMutex As Long

Private Sub Class_Initialize()

    mMutex = CreateMutex(ByVal 0&, 0, QueueMutex)
    If (Err.LastDllError = ERROR_ALREADY_EXISTS) Then
      frmMain.TRACE "Reseting Mutex...", w3rINFO
      UnLockIt
    End If

    LockIt
    Set mColData = New Collection
    UnLockIt
End Sub

Public Sub Clear()
    LockIt
    Set mColData = New Collection
    UnLockIt
End Sub

Public Function Count() As Long
    LockIt
    Count = mColData.Count
    UnLockIt
End Function

Public Sub Enqueue(Value As cQueueItem)
    LockIt
    mColData.Add Value
    UnLockIt
End Sub

Public Function Dequeue() As cQueueItem
    LockIt
    Set Dequeue = mColData.Item(1)
    mColData.Remove 1
    UnLockIt
End Function

Public Function Peek() As cQueueItem
    LockIt
    Set Peek = mColData.Item(1)
    UnLockIt
End Function

Private Sub Class_Terminate()
    Set mColData = Nothing
    CloseHandle mMutex
End Sub

Public Sub LockIt()
    Dim lRet As Long
    lRet = WaitForSingleObject(mMutex, QUEUE_INFINITE)
End Sub

Public Sub UnLockIt()
    Dim lRet
    lRet = ReleaseMutex(mMutex)
End Sub

