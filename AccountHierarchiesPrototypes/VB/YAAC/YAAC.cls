VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "YAAC"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit
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
' $Date$
' $Author$
' $Revision$
' $Workfile$
'
'
'*****************************************************************************

'Implements MTAUTHLib.IMTSecurityPrincipal

' properties
Private mBillable As Boolean
Private mFolder As Boolean
Private mSessionContext As MTSessionContext
Private mState As String
Private mExternalState As Long
Private mAccountID As Long



' cached properties
Private mAccountTemplate As MTAccountTemplate
Private mAncestorMgr As MTAncestorMgr
Private mAccountStateMgr As MTAccountStateManager
Private mPaymentMgr As MTPaymentMgr

Public Enum AccountState
    PendingActiveApproval
    Active
    Suspended
    PendingFinalBill
    Closed
    Archived
End Enum

Private Const E_NOTIMPL As Long = &H80004001


Public Property Get AccountTemplate() As MTAccountTemplate
 
  If IsFolder() Then
  
    If mAccountTemplate Is Nothing Then
    
        Set mAccountTemplate = New MTAccountTemplate
        mAccountTemplate.Initialize Me.AccountID, mSessionContext.SecurityContext
    End If
    Set AccountTemplate = mAccountTemplate
  End If
End Property


Public Property Get AccountID() As Long
  AccountID = mAccountID
End Property


' methods

Public Sub InitAsActor(ByVal aCTX As MTSessionContext)
  Set mSessionContext = aCTX
  mAccountID = mSessionContext.AccountID
  
  ' load account data
End Sub

' should be hidden
Public Sub InitAsSecuredResource(ByVal acc_id As Long, ByVal secCtx As MTSessionContext)
  Set mSessionContext = secCtx
  mAccountID = acc_id
  
  ' load account data
End Sub

'===========================================================================
' payment redirection
'===========================================================================

Public Function GetPaymentMgr() As MTPaymentMgr
  If mPaymentMgr Is Nothing Then
    Set mPaymentMgr = New MTPaymentMgr
    
    ' XXX fix this.... we need to find out if this account is billable or not
    mPaymentMgr.Initialize mSessionContext, True, Me
  End If
  Set GetPaymentMgr = mPaymentMgr

End Function





'===========================================================================
' Account state stuff
'===========================================================================

Public Function GetAccountStateMgr() As MTAccountStateManager

  If mAccountStateMgr Is Nothing Then
    Set mAccountStateMgr = New MTAccountStateManager
    GetAccountStateMgr.Initialize
  End If
  
  Set GetAccountStateMgr = mAccountStateMgr
  

End Function


Public Property Get AccountState() As AccountState
    AccountState = mState
End Property


Public Function GetStateHistory(Optional ByVal sysDate As Date) As MTSQLRowset
    Dim Rs As New MTSQLRowset
    Rs.Init ("queries\accountstates")
    Rs.SetQueryTag ("__GET_STATE_HISTORY__")
    Rs.AddParam "%%ID_ACC%%", mAccountID
    Rs.Execute
    Set GetStateHistory = Rs
End Function

Public Function GetParentNow() As YAAC

    Call Err.Raise(E_NOTIMPL, "YAAC", "Not Implemented")
End Function


Public Function GetPayerNow() As YAAC

    Call Err.Raise(E_NOTIMPL, "YAAC", "Not Implemented")
End Function


Public Sub AddOwnedFolderByID(id_folder As Long)
  Dim Rs As New MTSQLRowset
  Rs.Init ("queries\AccHierarchies")
  Rs.InitializeForStoredProc "AddOwnedFolder"
  Rs.AddInputParameterToStoredProc "owner", 1, 0, mAccountID
  Rs.AddInputParameterToStoredProc "folder", 1, 0, id_folder
  Rs.AddOutputParameterToStoredProc "status", 1, 1
  Rs.ExecuteStoredProc
  
  Dim status As Long
  status = Rs.GetParameterFromStoredProc("status")
  If status = -1 Then
    Call Err.Raise(&H80004005, "MTYAAC", "Target account is not a folder!")
  End If
  If status <> 0 Then
    Call Err.Raise(&H80004005, "MTYAAC", "Folder is allready owned by another account")
  End If

End Sub

Public Function RemovedOwnedFolderById(ByVal id_folder As Long)

    Dim Rs As New MTSQLRowset
    Rs.Init ("queries\AccHierarchies")
    Rs.SetQueryTag ("__REMOVE_OWNED_FOLDER__")
    Rs.AddParam "%%ID_ACC%%", mAccountID
    Rs.AddParam "%%ID_FOLDER%%", id_folder
    Rs.Execute
End Function

Public Function GetOwnedFolderList() As MTSQLRowset

    Dim Rs As New MTSQLRowset
    Rs.Init ("queries\database")
    Rs.SetQueryTag ("__FIND_OWNED_FOLDERS__")
    Rs.AddParam "%%NAME_SPACE%%", "mt"
    Rs.AddParam "%%ID_ACC%%", mAccountID
    Rs.Execute
    Set GetOwnedFolderList = Rs
End Function


Public Function GetAncestorMgr() As MTAncestorMgr
  
  If mAncestorMgr Is Nothing Then
    Set mAncestorMgr = New MTAncestorMgr
    mAncestorMgr.Initialize mSessionContext
  End If
    
  Set GetAncestorMgr = mAncestorMgr

End Function






'===========================================================================
' Security Principals interface methods
'===========================================================================




Public Function IsFolder() As Boolean
    IsFolder = True
End Function
