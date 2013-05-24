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

' service ID of the parent session
Private ParentService_ID    As Long

' name IDs for inputs
Private Units_ID            As Long

' name IDs for outputs
Private Amount_ID           As Long
Private PerUnit_ID          As Long

' rate per unit.  Stored in the plug-in configuration
Private Rate                As Double

'****************************************************************************

Private Sub IMTPipelinePlugIn2_Configure(ByVal systemContextObj As Object, _
                ByVal propSet As MTPipelineLib.IMTConfigPropSet)

    Dim systemContext As IMTSystemContext
    Set systemContext = systemContextObj

    ' read the configuration
    Dim units   As String
    Dim amount  As String
    Dim PerUnit As String
    Dim nameID  As IMTNameID
    
    Set Logger = systemContext.GetLog
    
    ' log strings if desired..
    Logger.LogString 5, "VB Plug-in: Configure"
    
    Set nameID = systemContext.GetNameID

    amount = propSet.NextStringWithName("Amount")
    units = propSet.NextStringWithName("Units")
    PerUnit = propSet.NextStringWithName("PerUnit")
    Rate = propSet.NextDoubleWithName("Rate")

    ' look up name IDs for inputs
    Units_ID = nameID.GetNameID(units)
    
    ' look up name IDs for outputs
    Amount_ID = nameID.GetNameID(amount)
    PerUnit_ID = nameID.GetNameID(PerUnit)

    ' look up ID of the parent service
    ParentService_ID = nameID.GetNameID("metratech.com/testparent")
End Sub




'****************************************************************************
Private Sub IMTPipelinePlugIn2_Shutdown()
    Logger.LogString 5, "VB Plug-in: Shutdown"
    Set Logger = Nothing
End Sub

'****************************************************************************
Private Sub IMTPipelinePlugIn2_ProcessSessions(ByVal sessions As MTPipelineLib.IMTSessionSet)

    Logger.LogString 5, "VB Plug-in: ProcessSessions"

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

    Dim amount  As Double
    Dim units   As Double
    
    If session.ServiceID = ParentService_ID Then
        units = 1#
    Else
        ' read the inputs
        units = session.GetDoubleProperty(Units_ID)
    End If

    ' rate the session
    amount = units * Rate

    ' set outputs
    session.SetDoubleProperty PerUnit_ID, Rate
    session.SetDoubleProperty Amount_ID, amount
End Sub

