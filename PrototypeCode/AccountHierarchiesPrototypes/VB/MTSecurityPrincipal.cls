VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MTSecurityPrincipal"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
' All the methods taking Object as parameter will  take IMTCompositeCapability
' instead (have to do this in VB cuz there is no inheritance)

Option Explicit

Public Enum PrincipalType

ROLE_ = 0
SUBSCRIBER_ACCOUNT_ = 1
CSR_ACCOUNT_ = 2
FOLDER_ACCOUNT = 3

End Enum

Public Properties As New MTProperties
'Private mPrincipalType As PrincipalType
Private mID As Integer
Private mActivePolicy As MTPrincipalPolicy
Private mDefaultPolicy As MTPrincipalPolicy


Public Property Let PrincipalType(ByVal vData As PrincipalType)
  'mPrincipalType = vData
  Properties.Item("PrincipalType").Value = vData
End Property

Public Property Get PrincipalType() As PrincipalType
  PrincipalType = Properties.Item("PrincipalType").Value
End Property

Public Property Let ID(ByVal vData As Integer)
  Properties.Item("ID").Value = vData
End Property

Public Property Get ID() As Integer
  ID = Properties.Item("ID").Value
End Property


Public Function Init()
  'InitActivePolicy
End Function

Public Function Save() As Integer
 If Not mActivePolicy Is Nothing Then
  mActivePolicy.Save
 End If
End Function


Private Sub Class_Initialize()
    Set mActivePolicy = Nothing
End Sub

Public Function GetActivePolicy(Optional ByVal aCtx As MTSessionContext) As MTPrincipalPolicy

  Dim prpol As New MTPrincipalPolicy
  ' we probably won't have "READ" or "WRITE" access level
  'to Manage Auth
  'Depending on type of the principal check MTManageGlobalAuth (in case of Role)
  'or MTManageSubscriberAuth - in case of subscriber account
  'or MTManage CSR - in case of CSR account
  'ISSUE: how do these properties become available to MTAuthAccount??
  If mActivePolicy Is Nothing Then
    Set mActivePolicy = prpol.GetActive(aCtx, Me)
    'pass security context just in case we want to make auth check
    'more granular
  End If
  
  Set GetActivePolicy = mActivePolicy
End Function

Public Function GetDefaultPolicy(Optional ByVal aCtx As MTSessionContext) As MTPrincipalPolicy

  Dim prpol As New MTPrincipalPolicy
  If mDefaultPolicy Is Nothing Then
    Set mDefaultPolicy = prpol.GetDefault(aCtx, Me)
    'pass security context just in case we want to make auth check
    'more granular
  End If
  
  Set GetDefaultPolicy = mDefaultPolicy
End Function



            
