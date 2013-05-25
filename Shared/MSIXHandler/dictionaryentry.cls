VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "DictionaryEntry"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Attribute VB_Ext_KEY = "RVB_UniqueId" ,"399321D1031B"
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
' ****************************************************************************
' CLASS         : DictionaryEntry
' AUTHOR        : F.Torres
' CREATION DATE : 08/xx/2000
' VERSION       : 1.0
' DESCRIPTION   : See Dictionary description
'
' MODIFIED      : $Date$
' LAST AUTHOR   : $Author$
' REVISION      : $Revision$
' FILENAME      : $Workfile$
'
'*****************************************************************************
Option Explicit


Public Id           As String
Public Description  As String
Private m_varValue  As Variant
Private m_EntryType   As String

' -------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Property Get Name() As String

    On Error GoTo ErrMgr

    Name = Id
    Exit Property
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "dictionaryentry.cls", "Name", LOG_ERROR
End Property

' -------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Property Let Name(ByVal vNewValue As String)

    On Error GoTo ErrMgr

    Id = vNewValue

    Exit Property
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "dictionaryentry.cls", "Name", LOG_ERROR
End Property


' -------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Function ToString() As String

    On Error GoTo ErrMgr

    ToString = "name=" & Name & "; value=" & Value & ";" & " Description=" & Me.Description & ";"

    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "dictionaryentry.cls", "ToString", LOG_ERROR
End Function

Public Property Get Value() As Variant
Attribute Value.VB_UserMemId = 0




    On Error GoTo ErrMgr



    ' Recursiv systen so a dictionary entry can reference another.
    'If (Parent.Exist(m_varValue)) Then
    
    '    Value = Parent.Item(m_varValue).Value
    'Else
        Value = m_varValue
    'End If
    

    Exit Property
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "dictionaryentry.cls", "Value", LOG_ERROR
End Property

Public Property Let Value(ByVal vNewValue As Variant)

    On Error GoTo ErrMgr

    m_varValue = vNewValue

    Exit Property
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "dictionaryentry.cls", "Value", LOG_ERROR
End Property



'' --------------------------------------------------------------------------------------------------------------------------------------------------------------
'' FUNCTION      : Delete
'' PARAMETERS    :
'' DESCRIPTION   : Internal Delete function called by the parent object when the parent is about to be deleted.
''                 The purpose of this function is to free the parent ref from the child so the parent can be deleted.
''                 This deals with the COM problem of circular reference.
''                 This function cannot be called from the out side (Friend)!
'' RETURN        :
'Friend Function Delete() As Boolean
'
'    'Set Parent = Nothing
'    Delete = True
'
'    Exit Function
'ErrMgr:
'  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "dictionaryentry.cls", "Value", LOG_ERROR
'End Function

Private Sub Class_Terminate()

    On Error GoTo ErrMgr

    Exit Sub
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "dictionaryentry.cls", "Class_Terminate", LOG_ERROR
End Sub

Public Property Get EntryType() As String
     EntryType = m_EntryType
End Property

Public Property Let EntryType(ByVal vNewValue As String)

    m_EntryType = vNewValue
End Property
