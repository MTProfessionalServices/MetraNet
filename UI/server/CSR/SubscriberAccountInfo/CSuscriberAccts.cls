VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "SubscriberAccts"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
'**************************************************************************
'
'  Copyright 1998 by MetraTech Corporation
'  All rights reserved.
'
'  THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
'  NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
'  example, but not limitation, MetraTech Corporation MAKES NO
'  REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
'  PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
'  DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
'  COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
'
'  Title to copyright in this software and any associated
'  documentation shall at all times remain with MetraTech Corporation,
'  and USER agrees to preserve the same.
'
'  AUTHOR       : Frederic Torres
'  DATE         : 4/xx/00
'  DESCRIPTION  :
'
'***************************************************************************
Option Explicit


Private mCol As Collection

Public Property Get Item(vntKey As Variant) As SubscriberAcct
Attribute Item.VB_UserMemId = 0

   On Error GoTo ErrMgr
   If IsNumeric(vntKey) Then
        Set Item = mCol(vntKey)
   Else
        Set Item = mCol(UCase(vntKey))
   End If
   Exit Property
ErrMgr:
   Set Item = Nothing
End Property

Public Sub Remove(vntKey As Variant)

    On Error GoTo ErrMgr
    mCol.Remove vntKey
    Exit Sub
ErrMgr:
    Debug.Print Err.Description: Debug.Assert False
End Sub

Public Property Get Count() As Long

    On Error GoTo ErrMgr
    Count = mCol.Count
    Exit Property
ErrMgr:
    Debug.Print Err.Description: Debug.Assert False
End Property

Public Property Get NewEnum() As IUnknown
Attribute NewEnum.VB_UserMemId = -4

    On Error GoTo ErrMgr
    Set NewEnum = mCol.[_NewEnum]
    Exit Property
ErrMgr:
    Debug.Print Err.Description: Debug.Assert False
End Property

Private Sub Class_Initialize()

    On Error GoTo ErrMgr
    Set mCol = New Collection
    Exit Sub
ErrMgr:
    Debug.Print Err.Description: Debug.Assert False
End Sub

Private Sub Class_Terminate()

    On Error GoTo ErrMgr
    
    Clear
    Set mCol = Nothing
    Exit Sub
ErrMgr:
    Debug.Print Err.Description: Debug.Assert False
End Sub

Public Sub Clear()

    On Error GoTo ErrMgr

    Do While Count > 0
        Remove 1
    Loop
    Exit Sub
ErrMgr:
    Debug.Print Err.Description: Debug.Assert False
End Sub

Public Function Add(Optional objSubscriberAcct As SubscriberAcct) As SubscriberAcct

    On Error GoTo ErrMgr
    
    If (objSubscriberAcct Is Nothing) Then
    
        Set objSubscriberAcct = New SubscriberAcct
    End If
    
    mCol.Add objSubscriberAcct
    objSubscriberAcct.Index = mCol.Count
    objSubscriberAcct.Id = mCol.Count
    Set Add = objSubscriberAcct
    Exit Function
ErrMgr:
    Set Add = Nothing
End Function

Public Function ToString() As String

    Dim objSubscriberAcct   As SubscriberAcct
    Dim strS                As String
    
    On Error GoTo ErrMgr
    
    For Each objSubscriberAcct In Me
    
        strS = strS & objSubscriberAcct.ToString() & vbCrLf
    Next
    ToString = strS
    Exit Function
ErrMgr:
    Debug.Print Err.Description: Debug.Assert False
End Function


