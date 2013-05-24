VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "PlugIn"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
'******************************************************************************
'* Copyright 2000 by MetraTech Corporation
'* All rights reserved.
'*
'* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
'* NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
'* example, but not limitation, MetraTech Corporation MAKES NO
'* REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
'* PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
'* DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
'* COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
'*
'* Title to copyright in this software and any associated
'* documentation shall at all times remain with MetraTech Corporation,
'* and USER agrees to preserve the same.
'*
'* Written by: Derek Young
'*
'****************************************************************************

Implements IMTPipelinePlugIn2

' require that all variables are declared
Option Explicit

Const E_NOTIMPL = &H80004001

' logger interface received from configure
Private Logger              As IMTLog


' name IDs for inputs
Private FirstNameID            As Long
Private LastNameID            As Long

' name IDs for outputs
Private ConcatNameID           As Long


'****************************************************************************

Private Sub IMTPipelinePlugIn2_Configure(ByVal systemContextObj As Object, _
                ByVal propSet As MTPipelineLib.IMTConfigPropSet)

    Dim systemContext As IMTSystemContext
    Set systemContext = systemContextObj

    ' read the configuration
    Dim nameID  As IMTNameID
    
    Set Logger = systemContext.GetLog
    
    ' log strings if desired..
    Logger.LogString 5, "NameConcatPlugIn: Configure"
    
    Set nameID = systemContext.GetNameID

    ' look up name IDs for inputs
    FirstNameID = nameID.GetNameID("firstname")
    LastNameID = nameID.GetNameID("lastname")
    
    ' look up name IDs for outputs
    ConcatNameID = nameID.GetNameID("concatname")

End Sub




'****************************************************************************
Private Sub IMTPipelinePlugIn2_Shutdown()
    Logger.LogString 5, "NameConcatPlugIn: Shutdown"
    Set Logger = Nothing
End Sub

'****************************************************************************
Private Sub IMTPipelinePlugIn2_ProcessSessions(ByVal sessions As MTPipelineLib.IMTSessionSet)

    Logger.LogString 5, "NameConcatPlugIn: ProcessSessions"

    Dim mysess As IMTSession

    ' go through each session
    For Each mysess In sessions
        Call ProcessSession(mysess)
    Next
End Sub

'****************************************************************************

Private Property Get IMTPipelinePlugIn2_ProcessorInfo() As Long
    ' this method is currently not used.
    Err.Raise E_NOTIMPL
End Property

'****************************************************************************
' helper function used by ProcessSessions.
' This is not part of the COM interface
Private Sub ProcessSession(ByRef session As IMTSession)

    Dim FirstName As String
    Dim LastName As String
    Dim ConcatName As String
        
    ' read the inputs
    If session.PropertyExists(FirstNameID, SESS_PROP_TYPE_STRING) And _
       session.PropertyExists(LastNameID, SESS_PROP_TYPE_STRING) Then
        FirstName = session.GetStringProperty(FirstNameID)
        LastName = session.GetStringProperty(LastNameID)
        ConcatName = FirstName & " " & LastName
    Else
        ConcatName = ""
    End If
    
    ' set outputs
    session.SetStringProperty ConcatNameID, ConcatName
End Sub

