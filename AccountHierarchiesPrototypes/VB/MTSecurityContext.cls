VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MTSecurityContext"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Private mPolicy As New MTPrincipalPolicy
Private mSecurity As New MTSecurityPolicy
Private mPrincipals As New Collection
Private mAccount As MTAuthAccount
Private mCaps As Collection

Public Property Get AccountID() As Integer
    AccountID = mAccount.ID
End Property


Public Function Init(ByVal aAccountID As Integer)

  Dim role, cap, cap1
  
  Dim ctx As New MTSecurityContext
  
  Set mAccount = mSecurity.GetAccountByID(aAccountID)
  Set mPolicy = mAccount.GetActivePolicy()
  Set mCaps = New Collection
  
  For Each role In mPolicy.Roles
  
    For Each cap In role.GetActivePolicy().Capabilities
    
         mCaps.Add cap
    Next
  Next
  
  For Each cap1 In mPolicy.Capabilities
  
        mCaps.Add cap1
  Next
  Init = True
  
End Function

Public Function CheckAccess(ByVal aCompositeCapability As Object) As Boolean
  Dim role
  Dim cap
  
  'iterate through each capability on roles first
  For Each role In mPolicy.Roles
    For Each cap In role.GetActivePolicy().Capabilities
      If cap.Implies(aCompositeCapability) Then
        CheckAccess = True
        Exit Function
      End If
    Next
  Next
  'iterate through each capability on this account directly
  For Each cap In mPolicy.Capabilities
      If cap.Implies(aCompositeCapability) Then
        CheckAccess = True
        Exit Function
      End If
  Next
  
'  err.Raise 5, "MTSecurityContext", "Access to perform requested operation Denied"

End Function

Public Function CoarseCheckAccess(ByVal aCompositeCapability As Object) As Boolean
  Dim role
  Dim cap
  
  'temporarily just call CheckAccess
  'later the behavior will change to do coarse check and
  'not throw an error
  CoarseCheckAccess = CheckAccess(aCompositeCapability)

End Function

Public Function IsCallerInRole(ByVal aRoleName As String) As Boolean
  IsCallerInRole = mPolicy.IsPrincipalInRole(aRoleName)
End Function



Public Function ToXml() As String
  ToXml = "<SecurityContext>blah</SecurityContext>"
End Function

Public Function FromXml(ByVal aXml As String)

End Function

Public Function HasExpired() As Boolean
  HasExpired = False
End Function

Public Property Get CreationTimestamp() As Variant
  CreationTimestamp = Nothing
End Property

Public Property Get Roles() As Collection
  Set Roles = mPolicy.Roles
End Property



Public Function GetCapabiltiesOfType(ByVal aName As String) As Collection

    Dim coll As New Collection
    Dim cap
    For Each cap In mPolicy.Capabilities
    
        If cap.CapabilityType.Name = aName Then
        
            coll.Add cap
        End If
    Next
    Set GetCapabiltiesOfType = coll
End Function

Public Function IsSuperUser() As Boolean

    Dim cap
    Debug.Assert 0
    
    For Each cap In mCaps
    
        If cap.CapabilityType.Name = "Unlimited Capability" Then
        
            IsSuperUser = True
            Exit Function
        End If
    Next
End Function


