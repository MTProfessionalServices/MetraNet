VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 2  'RequiresTransaction
END
Attribute VB_Name = "Writer"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Attribute VB_Ext_KEY = "SavedWithClassBuilder6" ,"Yes"
Attribute VB_Ext_KEY = "Top_Level" ,"Yes"
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
'* Written by: Ralf Boeck
'*
'****************************************************************************
'* Description:
'* This VB project demonstrates how to write a (COM+) executant in VB
'* for the ComPlusPlugin.
'* It contains two objects:
'*  - an executant (VBSubscribeExec.Writer) that implements IMTPipelineExecutant
'*  - a ConfigState object (VBSubscribeExec.ConfigState) to hold nameIDs
'* The executant uses the product catalog objects to subscribe an
'* account to a product offering. It uses these session parameters:
'* _AccountID, ProductOfferingName,  SubscriptionStartDateType, and SubscriptionStartDate.
'*
'* To create an executant in VB:
'*  - set the MTSTransactionMode property of the executant object as "Requires Transaction"
'*  - make sure to set the project's compatibility mode to "Binary Compatibility"
'*  - register the dll in COM+ (Component Services)
'*
'* See the AccountCreateAndSubscribe stage in the pcsample extension for
'* an example that uses this executant.
'****************************************************************************

Implements IMTPipelineExecutant

' require that all variables are declared
Option Explicit

'****************************************************************************

Private Function IMTPipelineExecutant_Configure( _
                ByVal aSystemContext As Object, _
                ByVal aPropSet As MTPipelineLib.IMTConfigPropSet) As Variant

    Dim systemContext As IMTSystemContext
    Set systemContext = aSystemContext

    ' read the configuration
    Dim accountID_Name As String
    Dim prodOffName_Name  As String
    Dim subscrStartDateType_Name As String
    Dim subscrStartDate_Name As String
    Dim subscrID_Name As String
    
    Dim nameID  As IMTNameID
    Dim Logger As IMTLog
    
    Set Logger = systemContext.GetLog
    Set nameID = systemContext.GetNameID
        
    ' log
    Logger.LogString 5, "VB SubscribeExec: Configure"
    
    accountID_Name = aPropSet.NextStringWithName("_AccountID")
    prodOffName_Name = aPropSet.NextStringWithName("ProductOfferingName")
    subscrStartDateType_Name = aPropSet.NextStringWithName("SubscriptionStartDateType")
    subscrStartDate_Name = aPropSet.NextStringWithName("SubscriptionStartDate")
    subscrID_Name = aPropSet.NextStringWithName("SubscriptionID")

    ' look up name IDs
    Dim state As New ConfigState
    state.accountID_ID = nameID.GetNameID(accountID_Name)
    state.prodOffName_ID = nameID.GetNameID(prodOffName_Name)
    state.subscrStartDateType_ID = nameID.GetNameID(subscrStartDateType_Name)
    state.subscrStartDate_ID = nameID.GetNameID(subscrStartDate_Name)
    state.subscrID_ID = nameID.GetNameID(subscrID_Name)

    ' return state for caller to hang on to
    ' since this object will be destroyed
    Set IMTPipelineExecutant_Configure = state
End Function



'****************************************************************************
Private Sub IMTPipelineExecutant_ProcessSessions(ByVal aSessions As MTPipelineLib.IMTSessionSet, _
    ByVal aSystemContext As Object, _
    ByVal aConfigState As Variant)

    Dim systemContext As IMTSystemContext
    Set systemContext = aSystemContext
    
    systemContext.GetLog.LogString 5, "VB SubscribeExec: ProcessSessions"

    ' go through each session
    Dim session As IMTSession
    For Each session In aSessions
        Call ProcessSession(session, systemContext, aConfigState)
    Next
End Sub


'****************************************************************************
Private Sub ProcessSession(ByRef session As IMTSession, systemContext As IMTSystemContext, ByVal aConfigState As ConfigState)
    
    Const DATE_TYPE_ABSOLUTE = 1

    ' read inputs
    Dim accountID As Long
    Dim poName As String
    Dim subscrStartDateType As Long
    Dim subscrStartDate As Date
    
    accountID = session.GetLongProperty(aConfigState.accountID_ID)
    poName = session.GetStringProperty(aConfigState.prodOffName_ID)
    subscrStartDateType = session.GetLongProperty(aConfigState.subscrStartDateType_ID)
    subscrStartDate = session.GetOLEDateProperty(aConfigState.subscrStartDate_ID)
    
    ' construct a product catalog within the current session context
    Dim pc As New MTProductCatalog
    Call pc.SetSessionContext(session.SessionContext)
    
    ' get the PC account object for the account
    Dim acc As MTPCAccount
    Set acc = pc.GetAccount(accountID)
        
    ' find the product offering
    Dim po As MTProductOffering
    Set po = pc.GetProductOfferingByName(poName)
    If (po Is Nothing) Then
        Err.Raise -1, "VBSubscribeExec.ProcessSessions", "ProductOffering '" & poName & "' not found"
    End If
             
    ' subscribe
    Dim effDate As New MTPCTimeSpan
    Dim subscrID As Long
    
    effDate.StartDateType = subscrStartDateType
    effDate.StartDate = subscrStartDate
    effDate.SetEndDateNull
    
    Dim datemodified As Boolean
  
    subscrID = acc.Subscribe(po.id, effDate, datemodified)

    ' set outputs
    Call session.SetLongProperty(aConfigState.subscrID_ID, subscrID)

    ' log success
    systemContext.GetLog.LogString 5, "Subscribed account " & accountID & " to product offering " & po.id & ". SubscriptionID is " & subscrID

End Sub

