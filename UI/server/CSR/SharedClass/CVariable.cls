VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CVariable"
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
'  CLASS        : CVariable
'  AUTHOR       : Frederic Torres
'  DATE         : 03/xx/2000
'  DESCRIPTION  : This class describe a Variable another name will be a property that is to say : Name, Type and Value.
'                 Index define the index in the parent collection.
'
' ****************************************************************************************************************************************************************

Option Explicit

Private m_strName   As String
Private m_varValue  As Variant
Private m_lngType   As Long ' This is the vbtype like vbLong
Public Index        As Long
Private Sub Class_Initialize()
    m_lngType = vbVariant
End Sub

Public Property Get Name() As String
    Name = m_strName
End Property

Public Property Let Name(ByVal vNewValue As String)
    m_strName = vNewValue
End Property

Public Property Get Value() As Variant
Attribute Value.VB_UserMemId = 0
    Value = m_varValue
End Property

Public Property Let Value(ByVal vNewValue As Variant)
    m_varValue = vNewValue
End Property

Public Property Get VbType() As Long
    VbType = m_lngType
End Property

Public Property Let VbType(ByVal vNewValue As Long)
    m_lngType = vNewValue
End Property

Public Function ToString() As String
    Select Case VbType
        Case vbString
            ToString = "string " & Name & "=""" & Value & """;"
        Case vbDate
            ToString = "date " & Name & "=""" & Value & """;"
        Case vbLong
            ToString = "long " & Name & "=" & Value & ";"
        Case vbDouble
            ToString = "double " & Name & "=" & Value & ";"
        Case Else
            ToString = "string " & Name & "=" & Value & ";"
    End Select
End Function

