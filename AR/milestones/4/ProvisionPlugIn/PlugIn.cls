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

Private Logger              As IMTLog
Private mEnumConfig         As IEnumConfig

' name IDs for inputs
Private CountryID            As Long

'****************************************************************************

Private Sub IMTPipelinePlugIn2_Configure(ByVal systemContextObj As Object, _
                ByVal propSet As MTPipelineLib.IMTConfigPropSet)

    Dim systemContext As IMTSystemContext
    Set systemContext = systemContextObj

    Dim nameID  As IMTNameID
    
    Set Logger = systemContext.GetLog
    
    ' log strings if desired..
    Logger.LogString 5, "ProvisionPlugin: Configure"
    
    Set nameID = systemContext.GetNameID
    Set mEnumConfig = systemContext.GetEnumConfig
    

    ' look up name IDs for inputs
    CountryID = nameID.GetNameID("country")
    
End Sub




'****************************************************************************
Private Sub IMTPipelinePlugIn2_Shutdown()
    Logger.LogString 5, "ProvisionPlugin: Shutdown"
    Set Logger = Nothing
End Sub

'****************************************************************************
Private Sub IMTPipelinePlugIn2_ProcessSessions(ByVal sessions As MTPipelineLib.IMTSessionSet)

    Logger.LogString 5, "ProvisionPlugin: ProcessSessions"

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

    Dim countryVal  As Long
    Dim countryStr  As String
   
    ' read the inputs
    If session.PropertyExists(CountryID, SESS_PROP_TYPE_ENUM) Then
    
        countryVal = session.GetEnumProperty(CountryID)
        countryStr = mEnumConfig.GetEnumeratorByID(countryVal)
    
        Logger.LogString 5, "ProvisionPlugin: countryVal = " & countryVal & ", countryStr = " & countryStr
    
        If countryStr = "France" Then
            Err.Raise 1000, "ProvisionPlugin", "Cannot provision accounts in France. Country is on strike."
        End If
    End If
    
End Sub

