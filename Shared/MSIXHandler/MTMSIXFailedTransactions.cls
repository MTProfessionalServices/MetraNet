VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MSIXFailedTransactions"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
'****************************************************************************************************************************************************
'
' Copyright 1998-2000 by MetraTech Corporation
' All rights reserved.
'
' THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
' NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
' example, but not limitation, MetraTech Corporation MAKES NO
' REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
' PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
' DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
' COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
'
' Title to copyright in this software and any associated
' documentation shall at all times remain with MetraTech Corporation,
' and USER agrees to preserve the same.
'
' $Date$
' $Author$
' $Revision$
' $Workfile$
'
'****************************************************************************************************************************************************
Option Explicit
Public TRACE_ID As Long

Private m_Col As Collection

'Public Parent As MSIXFailedTransaction

Public Property Get Item(vntKey As Variant) As MSIXFailedTransaction
Attribute Item.VB_UserMemId = 0
   On Error GoTo ErrMgr
   If IsNumeric(vntKey) Then
        Set Item = m_Col(vntKey)
   Else
        Set Item = m_Col(UCase(vntKey))
   End If
   Exit Property
ErrMgr:
   Set Item = Nothing
End Property

Public Function Remove(vntKey As Variant) As Boolean
    On Error GoTo ErrMgr
    m_Col.Remove vntKey
    Remove = True
    Exit Function
ErrMgr:
    Debug.Print Err.Description: Debug.Assert False
End Function

Public Property Get Count() As Long
    On Error GoTo ErrMgr
    If IsValidObject(m_Col) Then
    
        Count = m_Col.Count
    End If
    Exit Property
ErrMgr:
    Debug.Print Err.Description: Debug.Assert False
End Property

Public Property Get NewEnum() As IUnknown
Attribute NewEnum.VB_UserMemId = -4
    On Error GoTo ErrMgr
    Set NewEnum = m_Col.[_NewEnum]
    Exit Property
ErrMgr:
    Debug.Print Err.Description: Debug.Assert False
End Property

Private Sub Class_Initialize()
    On Error GoTo ErrMgr
    Set m_Col = New Collection
    TRACE_CONSTRUCTOR_DESTRUCTOR Me, TRACE_CONSTRUCTOR_MODE
    Exit Sub
ErrMgr:
    Debug.Print Err.Description: Debug.Assert False
End Sub

Private Sub Class_Terminate()
    On Error GoTo ErrMgr
    Clear
    Set m_Col = Nothing
    'Set Parent = Nothing
    TRACE_CONSTRUCTOR_DESTRUCTOR Me, TRACE_DESTRUCTOR_MODE
    Exit Sub
ErrMgr:
    Debug.Print Err.Description: Debug.Assert False
End Sub

Public Sub Clear()
    On Error GoTo ErrMgr
    Do While Count > 0
        Remove 1
    Loop
    
    #If LOG_OBJECT_INFO Then
        TRACE_CONSTRUCTOR_DESTRUCTOR Me, TRACE_CLEAR_MODE
    #End If
    
    Exit Sub
ErrMgr:
    Debug.Print Err.Description: Debug.Assert False
End Sub

Public Function Add(objCMeteredTransaction As MSIXFailedTransaction, Optional varId As Variant) As MSIXFailedTransaction
    On Error GoTo ErrMgr
    If (IsMissing(varId)) Then
        m_Col.Add objCMeteredTransaction
    Else
        m_Col.Add objCMeteredTransaction, UCase("" & varId)
        objCMeteredTransaction.Id = varId
    End If
    Set Add = objCMeteredTransaction

    objCMeteredTransaction.Index = Count()
    Set objCMeteredTransaction.Parent = Me
    Exit Function
ErrMgr:
    Set Add = Nothing
End Function

Public Function AddNew(Optional varId As Variant) As MSIXFailedTransaction

    On Error GoTo ErrMgr
    Dim objCMeteredTransaction As MSIXFailedTransaction

    Set objCMeteredTransaction = New MSIXFailedTransaction
    
    If (IsMissing(varId)) Then
        m_Col.Add objCMeteredTransaction
    Else
        m_Col.Add objCMeteredTransaction, UCase("" & varId)
        objCMeteredTransaction.Id = varId
    End If
    objCMeteredTransaction.Index = Count()
    Set objCMeteredTransaction.Parent = Me

    Set AddNew = objCMeteredTransaction

    Exit Function
ErrMgr:
    Set AddNew = Nothing
End Function

Public Function ToString() As String

    Dim objCMeteredTransaction  As MSIXFailedTransaction
    Dim strS            As String
    For Each objCMeteredTransaction In Me
        strS = strS & objCMeteredTransaction.ToString() & vbCrLf
    Next
    ToString = strS
End Function


Public Function Clean() As Boolean

    On Error GoTo ErrMgr
    Dim i As Long
    
    For i = 1 To Me.Count
    
        Me.Item(i).CleanCurrentTransaction
    Next
    Exit Function
ErrMgr:
    Debug.Print Err.Description: Debug.Assert False
End Function

