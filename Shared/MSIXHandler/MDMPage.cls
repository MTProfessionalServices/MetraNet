VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MDMPage"
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

Option Explicit

Public TRACE_ID As Long

Public NoRecordUserMessage  As String

Private m_MaxRow               As Long
Private m_Rowset               As Object

Private m_Index                As Long ' The current page index

Public Property Get MaxPage() As Long

    On Error GoTo ErrMgr


    Dim dblD As Long
    
    If (IsValidObject(Rowset)) Then
    
        MaxPage = Int(Rowset.RecordCount / MaxRow) + IIf(CBool(Rowset.RecordCount Mod MaxRow), 1, 0)
    Else
        TRACE MTMSIX_ERROR_01034, "MDMPage.cls", "MaxPage", LOG_ERROR
        MaxPage = -1
    End If

    Exit Property
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MDMPage.cls", "MaxPage", LOG_ERROR
End Property

Private Sub Class_Initialize()

    On Error GoTo ErrMgr

   #If LOG_OBJECT_INFO Then
        TRACE_CONSTRUCTOR_DESTRUCTOR Me, TRACE_CONSTRUCTOR_MODE
    #End If
    
    m_MaxRow = 40
    NoRecordUserMessage = "No record(s) found."

    Exit Sub
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MDMPage.cls", "Class_Initialize", LOG_ERROR
End Sub

Private Sub Class_Terminate()

    On Error GoTo ErrMgr

    
    Clear
    #If LOG_OBJECT_INFO Then
        TRACE_CONSTRUCTOR_DESTRUCTOR Me, TRACE_DESTRUCTOR_MODE
    #End If

    Exit Sub
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MDMPage.cls", "Class_Terminate", LOG_ERROR
End Sub

Public Property Get Index() As Long

    On Error GoTo ErrMgr

    Index = m_Index

    Exit Property
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MDMPage.cls", "Index", LOG_ERROR
End Property

Public Property Let Index(ByVal vNewValue As Long)

    On Error GoTo ErrMgr


    m_Index = vNewValue
    
    If (m_Index > MaxPage) Then
        m_Index = MaxPage
    End If
    If (m_Index < 1) Then
        m_Index = 1
    End If

    Exit Property
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MDMPage.cls", "Index", LOG_ERROR
End Property

Public Property Get Rowset() As Variant

    On Error GoTo ErrMgr

    Set Rowset = m_Rowset

    Exit Property
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MDMPage.cls", "Rowset", LOG_ERROR
End Property

Public Property Set Rowset(ByVal vNewValue As Variant)

    On Error GoTo ErrMgr

    Set m_Rowset = vNewValue

    Exit Property
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MDMPage.cls", "Rowset", LOG_ERROR
End Property

Public Property Get MaxRow() As Long

    On Error GoTo ErrMgr

    MaxRow = m_MaxRow

    Exit Property
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MDMPage.cls", "MaxRow", LOG_ERROR
End Property

Public Property Let MaxRow(ByVal vNewValue As Long)

    On Error GoTo ErrMgr

    m_MaxRow = vNewValue

    Exit Property
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MDMPage.cls", "MaxRow", LOG_ERROR
End Property

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Clear
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        : TRUE if Ok.
Public Function Clear() As Boolean

    On Error GoTo ErrMgr
    
    #If LOG_OBJECT_INFO Then
        TRACE_CONSTRUCTOR_DESTRUCTOR Me, TRACE_CLEAR_MODE
    #End If

    Set Rowset = Nothing
    Clear = True

    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MDMPage.cls", "Clear", LOG_ERROR
End Function

