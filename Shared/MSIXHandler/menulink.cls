VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MenuLink"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Attribute VB_Ext_KEY = "RVB_UniqueId" ,"399321D100FF"
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
' CLASS         :
' AUTHOR        : F.Torres
' CREATION DATE : 08/xx/2000
' VERSION       : 1.0
' DESCRIPTION   : MetraTech Extentable Service.
'
'
' $Date$
' $Author$
' $Revision$
' $Workfile$
'
'
'
'*****************************************************************************
Option Explicit


' MAM 3.0

Public capability           As String
Public capabilityParameters As String
Public AccountType          As String

Public capabilities As New capabilities

' MAM 2.1

Public TRACE_ID             As Long

Public Id                   As String
Public TextId               As String
Public Page                 As String
Public image                As String
Public Visible              As Boolean
Public Enabled              As Boolean
Public Target               As String
Public Order                As Integer
Public Removed              As Boolean ' This property can be set in a menu xml file, if true the entry will be removed after the XML file is loaded



' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : ToString()
' PARAMETERS    :
' DESCRIPTION   : Returns the value(s) of the instance in a string
' RETURN        :
Public Function ToString() As String

    On Error GoTo ErrMgr

    ToString = "LINK id=" & Id & "; TextId=" & TextId & "; page=" & Page & "; image=" & image & "; Removed=" & Removed & "; visible=" & Visible

    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "menulink.cls", "ToString", LOG_ERROR
End Function

Private Sub Class_Initialize()

    On Error GoTo ErrMgr

    Visible = True
    Enabled = True
    TRACE_CONSTRUCTOR_DESTRUCTOR Me, TRACE_CONSTRUCTOR_MODE

    Exit Sub
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "menulink.cls", "Class_Initialize", LOG_ERROR
End Sub

Private Sub Class_Terminate()
    TRACE_CONSTRUCTOR_DESTRUCTOR Me, TRACE_DESTRUCTOR_MODE
End Sub
