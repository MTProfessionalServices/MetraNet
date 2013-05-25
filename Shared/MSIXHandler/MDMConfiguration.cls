VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MDMConfiguration"
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
Public DebugMode    As Boolean
Public ProfilerMode As Boolean
Public LogWarning   As Boolean
Public LogDebug     As Boolean
Public CheckRequiredField As Boolean
Public Id           As String
Public HtmlFormMethod As String



Function LoadXMLFile(ByVal strXMLFileName As String) As Boolean

    Dim objOM               As New XMLLoader
    Dim objFile             As New cTextFile
    Dim strHTMLFileName     As String
    Dim objTool             As New cTool
    Dim strHTML             As Variant
    Dim objProfiler         As New CProfiler
    
    objProfiler.Start MTMSIX_PROFILER_ON, "MDMConfiguration.cls", "LoadXMLFile", "XMLFileName=" & strXMLFileName

    If (objOM.LoadObjectModelData(Me, strXMLFileName)) Then
    
        LoadXMLFile = True
    End If
    Exit Function
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MDMConfiguration.cls", "LoadXMLFile", LOG_ERROR

End Function


Private Sub Class_Initialize()

    On Error GoTo ErrMgr

    CheckRequiredField = True
    #If LOG_OBJECT_INFO Then
        TRACE_CONSTRUCTOR_DESTRUCTOR Me, TRACE_CONSTRUCTOR_MODE
    #End If
    
    HtmlFormMethod = "post"

    Exit Sub
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MDMConfiguration.cls", "Class_Initialize", LOG_ERROR
End Sub

Private Sub Class_Terminate()

    On Error GoTo ErrMgr

    #If LOG_OBJECT_INFO Then
        TRACE_CONSTRUCTOR_DESTRUCTOR Me, TRACE_DESTRUCTOR_MODE
    #End If

    Exit Sub
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MDMConfiguration.cls", "Class_Terminate", LOG_ERROR
End Sub

Public Function ToString() As String

    Dim strS As String
    
    strS = strS & "DebugMode=" & DebugMode & "; "
    strS = strS & "ProfilerMode=" & ProfilerMode & "; "
    strS = strS & "LogWarning=" & LogWarning & "; "
    strS = strS & "CheckRequiredField=" & CheckRequiredField & "; "
    strS = strS & "HtmlFormMethod=" & HtmlFormMethod & "; "
    
    ToString = strS
End Function

