VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MDMEvent"
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
' MODIFIED      : $Date$
' LAST AUTHOR   : $Author$
' REVISION      : $Revision$
' FILENAME      : $Workfile$
'
Option Explicit
Public TRACE_ID As Long
Public Error               As MDMError


Public Id               As String
Public HTMLRendered     As String
Public Name             As String
Public UIParameters     As Variant ' Used to stored a CVariables instance that contains the IIS querystring and IIS form name/value
Public Grid             As MDMGrid



Private Sub Class_Initialize()

    On Error GoTo ErrMgr
    
    Set Error = New MDMError
    Error.Initialize Me

    #If LOG_OBJECT_INFO Then
        TRACE_CONSTRUCTOR_DESTRUCTOR Me, TRACE_CONSTRUCTOR_MODE
    #End If

    Exit Sub
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MDMEventInfo.cls", "Class_Initialize", LOG_ERROR
End Sub

Public Function Initialize() As Boolean

    On Error GoTo ErrMgr

    
    Initialize = True

    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MDMEventInfo.cls", "Initialize", LOG_ERROR
End Function


Private Sub Class_Terminate()

    On Error GoTo ErrMgr
    
    Error.Clear
    Set Error = Nothing

    #If LOG_OBJECT_INFO Then
        TRACE_CONSTRUCTOR_DESTRUCTOR Me, TRACE_DESTRUCTOR_MODE
    #End If

    Exit Sub
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MDMEventInfo.cls", "Class_Terminate", LOG_ERROR
End Sub

Public Function Clear() As Boolean

    On Error GoTo ErrMgr

    Error.Clear
    HTMLRendered = ""
    Name = ""
    Clear = True
    Set UIParameters = Nothing
    Set Grid = Nothing

    Exit Function
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MDMEventInfo.cls", "Clear", LOG_ERROR
End Function
