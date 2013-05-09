VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MTAuthAccount"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

'simulate inheritance by aggregating base class
Private mSP As New MTSecurityPrincipal

Private mDefaultPolicy As MTPrincipalPolicy

Private Sub Class_Initialize()
    
    Dim propMeta As MTPropertyMetaData
    Dim prop As MTProperty
  
    Set mDefaultPolicy = Nothing
    For Each propMeta In AccountMetaDataCollection
      Set prop = mSP.Properties.Add(propMeta)
    Next
    'in implementation this property
    'will be initialize according to flags
    'in t_av_internal
    mSP.PrincipalType = SUBSCRIBER_ACCOUNT_
End Sub


''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' methods/properties 'inherited' from MTSecurityPrincipal
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function GetActivePolicy(Optional ByVal aCtx As MTSessionContext) As MTPrincipalPolicy
  Set GetActivePolicy = mSP.GetActivePolicy()
End Function

Public Property Get Properties() As MTProperties
  Set Properties = mSP.Properties
End Property

Public Property Let ID(ByVal vData As Integer)
  mSP.ID = vData
End Property

Public Property Get ID() As Integer
  ID = mSP.ID
End Property

Public Function Save() As Integer
 'will save active policy
 mSP.Save
 If Not mDefaultPolicy Is Nothing Then
  mDefaultPolicy.Save
 End If
 Save = ID
End Function


Public Function Init()
End Function


'================================================================
' Methods live on MTAuthAccount
'================================================================

Public Function IsInRole(aRoleName As String) As Boolean
  IsInRole = mSP.GetActivePolicy().IsPrincipalInRole(aRoleName)
End Function

Public Function GetDefaultPolicy(Optional ByVal aCtx As MTSessionContext) As MTPrincipalPolicy
  Dim prpol As New MTPrincipalPolicy
  'return error if account type is not folder
  If mDefaultPolicy Is Nothing Then
    Set mDefaultPolicy = mSP.GetDefaultPolicy(aCtx)
  End If
  Set GetDefaultPolicy = mDefaultPolicy
End Function





