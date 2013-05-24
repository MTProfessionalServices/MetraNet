VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "autoSDKIO"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
'----------------------------------------------------------------------------
' Copyright 1998, 1999 by MetraTech Corporation
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
' $Workfile$
' $Date$
' $Author$
' $Revision$
'
'
'----------------------------------------------------------------------------
'----------------------------------------------------------------------------
' This module contains error codes used by the service wizard for setting up
' IO objects for AutoSDK files
'----------------------------------------------------------------------------
Option Explicit
'---------------------------------------------------------------------------'
' Global Variables                                                          '
'---------------------------------------------------------------------------'
Private mstrName As String        'the name of the property
Private mintPType As Integer      'the properties ptype (as an int)
Private mstrValue As String       'the properties value

Private marrPtypeStrings          'possible ptypes as strings
Private marrDefaultValues         'default values for each ptype
'---------------------------------------------------------------------------'
' Lets and Gets                                                             '
'---------------------------------------------------------------------------'
'Name
Public Property Get Name() As String
  Let Name = mstrName
End Property

Public Property Let Name(ByVal Val As String)
  Let mstrName = Val
End Property

'Type
Public Property Get Ptype() As Integer
  Let Ptype = mintPType
End Property

Public Property Let Ptype(ByVal Val As Integer)
  Let mintPType = Val
End Property

'Type as string
Public Property Let PtypeAsString(ByVal Val As String)
  Dim i
  
  For i = 0 To UBound(marrPtypeStrings)
    If UCase(marrPtypeStrings(i)) = UCase(Val) Then
      Let mintPType = i
      Exit For
    End If
  Next
  
End Property

Public Property Get PtypeAsString() As String
  Let PtypeAsString = marrPtypeStrings(mintPType)
End Property
'Value
Public Property Get Value() As String
  If Len(mstrValue) > 0 Then
    Let Value = mstrValue
  Else
    Let Value = marrDefaultValues(mintPType)
  End If
End Property

Public Property Let Value(ByVal Val As String)
  Let mstrValue = Val
End Property

Private Sub Class_Initialize()
  'Init the ptype strings

  marrPtypeStrings = Array("undefined", _
                           "undefined", _
                           "INTEGER", _
                           "DOUBLE", _
                           "STRING", _
                           "DATETIME", _
                           "TIME", _
                           "BOOL", _
                           "undefined", _
                           "undefined", _
                           "ENUM", _
                           "DECIMAL")
  
  marrDefaultValues = Array("", _
                            "", _
                            "(blank)", _
                            "0", _
                            "0.0", _
                            "(blank)", _
                            "1998-1-01T00:00:00Z", _
                            "08:00AM", _
                            "FALSE", _
                            "", _
                            "", _
                            "", _
                            "0.0")
                            
  mintPType = 0

End Sub
