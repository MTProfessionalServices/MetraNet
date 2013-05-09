VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MTSecurityPolicy"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Private NetMeter As New SQLRowsetWrapper
Private mRoles As New Collection
Private mCapTypes As New Collection


Private Function CheckManageGlobalAuth(ByVal aCtx As MTSessionContext) As Boolean
  Dim mga As New MTManageGlobalAuth
  CheckManageGlobalAuth = aCtx.SecurityContext.CheckAccess(mga)
End Function
      
Public Function GetAccountByID(aAccountID As Integer) As MTAuthAccount
  'do security check
  Dim acc As New MTAuthAccount
  acc.ID = aAccountID
  acc.Init
  Set GetAccountByID = acc
End Function

Public Function GetAnonymousAccount() As MTAuthAccount
  'do security check
  Dim acc As New MTAuthAccount
  Dim a As New COMAccount
  a.Initialize
  a.GetAccountInfo "anonymous", "anonymous"
  Set GetAnonymousAccount = acc

End Function

Public Function GetSystemAccount() As MTAuthAccount
  Dim acc As New MTAuthAccount
  Dim a As New COMAccount
  a.Initialize
  a.GetAccountInfo "system", "system"
  Set GetSystemAccount = acc
End Function


Private Sub Class_Initialize()
    NetMeter.InitRowset

End Sub


Public Function GetRoleByName(ByVal aCtx As MTSessionContext, ByVal aRoleName As String) As MTRole
  'do security check
  Dim accessCheck
  
  ' accessCheck = CheckManageGlobalAuth(aCtx)

  On Error GoTo ErrMgr
  
  'If mRoles.Count = 0 Then
   GetAllRoles aCtx
  'End If
  Set GetRoleByName = mRoles.Item(aRoleName)
  Exit Function
ErrMgr:
End Function

Public Function CreateRole(ByVal aCtx As MTSessionContext) As MTRole
  'check access
  Dim accessCheck
  ' accessCheck = CheckManageGlobalAuth(aCtx)
  
  Dim newRole As New MTRole
  Set CreateRole = newRole
End Function

Public Function GetRoleByID(ByVal aCtx As MTSessionContext, ByVal aRoleID As Integer) As MTRole
  'do security check
  Dim role
  On Error GoTo ErrMgr
  
  'If mRoles.Count = 0 Then
   GetAllRoles aCtx
 ' End If
  'Set GetRoleByName = mRoles.Item(aRoleName)
  For Each role In mRoles
    If role.ID = aRoleID Then
      Set GetRoleByID = role
      Exit Function
    End If
  Next
  Set GetRoleByID = Nothing
ErrMgr:
End Function

Public Function GetAllRoles(ByVal aCtx As MTSessionContext) As Collection

  'do security check
  'if (ctx == null){}
  On Error GoTo ErrMgr
  Set mRoles = Nothing
  Set mRoles = New Collection
  Dim query As String
  Dim role
  Dim roleid
  Dim bDiffRole As Boolean
  Dim Recordset As MTSQLRowset
  Dim id_cap_type
  Dim captype
  Dim cap
  query = "SELECT role.id_role, role.tx_name, role.tx_desc, role.csr_assignable, role.subscriber_assignable  FROM t_role role"
  'query = query + " WHERE cap.id_role=role.id_role and cap.id_parent_cap_instance IS NULL AND cap.id_cap_type=capclass.id_cap_type"
  Set Recordset = NetMeter.Execute(DebugStr(query))
  bDiffRole = False
  roleid = 0
  
  If Recordset.EOF = True Then
    GoTo funcend
  End If
  
  Recordset.MoveFirst
  
  While Recordset.EOF = False
    
    If roleid <> Recordset.Value(0) Then
      Set role = New MTRole
      roleid = Recordset.Value(0)
      role.ID = roleid
      role.Name = Recordset.Value(1)
      role.Description = Recordset.Value(2)
      role.CSRAssignable = GetBoolFromChar(Recordset.Value(3))
      role.SubscriberAssignable = GetBoolFromChar(Recordset.Value(4))
      bDiffRole = True
    End If
    
    If bDiffRole = True Then
      bDiffRole = False
      mRoles.Add role, role.Name
    End If
  
    Recordset.MoveNext
  Wend
  Set GetAllRoles = mRoles
funcend:
ErrMgr:
End Function

Public Function GetAllRolesAsRowset(ByVal aCtx As MTSessionContext) As IMTSQLRowset
  'do security check
  'if (ctx == null){}
  On Error GoTo ErrMgr
  Dim Rowset As IMTSQLRowset
  Dim role As MTRole
  
  'If mRoles.Count = 0 Then
   GetAllRoles aCtx
  'End If
  
  Set Rowset = CreateObject("MTSQLRowset.MTSQLRowset.1")
  Rowset.InitDisconnected
  
  
  Rowset.AddColumnDefinition "id_role", "int32", 255
  Rowset.AddColumnDefinition "tx_name", "string", 255
  Rowset.AddColumnDefinition "tx_desc", "string", 255
  Rowset.AddColumnDefinition "csr_assignable", "string", 1
  Rowset.AddColumnDefinition "subscriber_assignable", "string", 1
  
  Rowset.OpenDisconnected
  
  For Each role In mRoles
    Rowset.AddRow
    Rowset.AddColumnData "id_role", role.ID
    Rowset.AddColumnData "tx_name", role.Name
    Rowset.AddColumnData "tx_desc", role.Description
    Rowset.AddColumnData "csr_assignable", GetCharFromBool(role.CSRAssignable)
    Rowset.AddColumnData "subscriber_assignable", GetCharFromBool(role.SubscriberAssignable)
  Next
  Set GetAllRolesAsRowset = Rowset
ErrMgr:
End Function

Public Function GetCapabilityTypes() As Collection
  On Error GoTo ErrMgr
  Dim query As String
  Dim cap As MTCompositeCapabilityType
  Dim rs As MTSQLRowset
  
  query = "SELECT id_cap_type from t_composite_capability_type"
  Set rs = NetMeter.Execute(DebugStr(query))
  
  If rs.EOF = True Then
    GoTo funcend
  End If
  rs.MoveFirst
  
  While rs.EOF = False
    Set cap = New MTCompositeCapabilityType
    cap.Init (rs.Value(0))
    mCapTypes.Add cap, cap.Name
    rs.MoveNext
  Wend
    
  Set GetCapabilityTypes = mCapTypes
funcend:
ErrMgr:
End Function

Public Function GetCapabilityTypesAsRowset(ByVal aCtx As MTSessionContext) As IMTSQLRowset
  On Error GoTo ErrMgr
  Dim query As String
  Dim cap As MTCompositeCapabilityType
  Dim Rowset
  
  'If mRoles.Count = 0 Then
   GetAllRoles aCtx
  'End If
  
  'TODO: execute query directly without having to initialize
  'collection first
  Set Rowset = CreateObject("MTSQLRowset.MTSQLRowset.1")
  Rowset.InitDisconnected
  
  
  Rowset.AddColumnDefinition "id_cap_type", "int32", 255
  Rowset.AddColumnDefinition "tx_name", "string", 255
  Rowset.AddColumnDefinition "tx_desc", "string", 255
  Rowset.AddColumnDefinition "tx_progid", "string", 255
  Rowset.AddColumnDefinition "tx_editor", "string", 255
  Rowset.AddColumnDefinition "csr_assignable", "string", 1
  Rowset.AddColumnDefinition "subscriber_assignable", "string", 1
  Rowset.AddColumnDefinition "num_atomic", "string", 1
  Rowset.AddColumnDefinition "multiple_instances", "string", 1
  
  Rowset.OpenDisconnected
  
  For Each cap In mCapTypes
    Rowset.AddRow
    Rowset.AddColumnData "id_cap_type", cap.ID
    Rowset.AddColumnData "tx_name", cap.Name
    Rowset.AddColumnData "tx_desc", cap.Description
    Rowset.AddColumnData "tx_progid", cap.ProgID
    Rowset.AddColumnData "tx_editor", cap.Editor
    Rowset.AddColumnData "csr_assignable", GetCharFromBool(cap.CSRAssignable)
    Rowset.AddColumnData "subscriber_assignable", GetCharFromBool(cap.SubscriberAssignable)
    Rowset.AddColumnDefinition "num_atomic", "string", cap.NumberAtomic
    Rowset.AddColumnDefinition "multiple_instances", "string", GetCharFromBool(cap.AllowMultipleInstances)
  Next
  Set GetCapabilityTypesAsRowset = Rowset
ErrMgr:
End Function

Public Function GetAvailableCapabilityTypesAsRowset(ByVal aCtx As MTSessionContext, aPrincipalID As Integer, aPrincipalType As PrincipalType) As IMTSQLRowset
  On Error GoTo ErrMgr
  Dim query As String
  Dim cap As MTCompositeCapabilityType
  Dim rs As MTSQLRowset
  Dim Rowset
  Dim column As String
  
  If aPrincipalType = ROLE_ Then
    column = "id_role"
  Else
    column = "id_acc"
  End If
  
  Set Rowset = CreateObject("MTSQLRowset.MTSQLRowset.1")
  Rowset.InitDisconnected
  
  
  Rowset.AddColumnDefinition "id_cap_type", "int32", 255
  Rowset.AddColumnDefinition "tx_name", "string", 255
  Rowset.AddColumnDefinition "tx_desc", "string", 255
  Rowset.AddColumnDefinition "tx_progid", "string", 255
  Rowset.AddColumnDefinition "tx_editor", "string", 255
  Rowset.AddColumnDefinition "csr_assignable", "string", 1
  Rowset.AddColumnDefinition "subscriber_assignable", "string", 1
  Rowset.AddColumnDefinition "num_atomic", "int32", 1
  
  Rowset.OpenDisconnected
  
 query = "SELECT DISTINCT type.id_cap_type, type.tx_name, type.tx_desc, type.tx_progid, type.tx_editor, type.csr_assignable, type.subscriber_assignable, type.multiple_instances, "
 query = query + "(SELECT COUNT(*) FROM t_compositor WHERE id_composite = type.id_cap_type) num_atomic"
 query = query + " FROM t_composite_capability_type type "
 ' only show capabilities that have atomics
 ' query = query + "INNER JOIN t_compositor map ON type.id_cap_type = map.id_composite"
 ' query = query + " pp." + column + " = " + str(aPrincipalID) + ")"
  
  Set rs = NetMeter.Execute(DebugStr(query))
  
  If rs.EOF = True Then
    'this principal already has capabilities of
    'all available types
    Set GetAvailableCapabilityTypesAsRowset = Rowset
    Exit Function
  End If
  
  rs.MoveFirst
  While rs.EOF = False
    Rowset.AddRow
    Rowset.AddColumnData "id_cap_type", rs.Value(0)
    Rowset.AddColumnData "tx_name", rs.Value(1)
    Rowset.AddColumnData "tx_desc", rs.Value(2)
    Rowset.AddColumnData "tx_progid", rs.Value(3)
    Rowset.AddColumnData "tx_editor", rs.Value(4)
    Rowset.AddColumnData "csr_assignable", rs.Value(5)
    Rowset.AddColumnData "subscriber_assignable", rs.Value(6)
    Rowset.AddColumnData "multiple_instances", rs.Value(7)
    Rowset.AddColumnData "num_atomic", rs.Value(8)
    rs.MoveNext
  Wend
  ' rs.Close
  Set GetAvailableCapabilityTypesAsRowset = Rowset
ErrMgr:
End Function


Public Function GetCapabilityTypeByName(ByVal aName As String) As MTCompositeCapabilityType
On Error GoTo ErrMgr
  Dim cap
  Dim sc
  'If mCapTypes.Count = 0 Then
  GetCapabilityTypes
  'End If
  
  Set cap = mCapTypes.Item(aName)
  Set GetCapabilityTypeByName = cap
ErrMgr:
End Function

'Internal, marked hidden
Public Function GetAtomicCapabilityTypeByName(ByVal aName As String) As MTCompositeCapabilityType
    Dim sel As String
    Dim result As MTSQLRowset
    Dim found As Boolean
    Dim atomic As MTAtomicCapabilityType
    sel = "SELECT id_cap_type, tx_desc, tx_progid, tx_editor FROM t_atomic_capability_type "
    sel = sel + " WHERE UPPER(tx_name)=UPPER('" + aName + "')"

    Set result = NetMeter.Execute(DebugStr(sel))

    found = (result.EOF = False)

    If found = True Then
    
      atomic.Name = aName
    
      result.MoveFirst
    
      atomic.ID = result.Value(0)
      atomic.Description = result.Value(1)
      atomic.ProgID = result.Value(2)
      atomic.Editor = result.Value(3)
    
      result.Close
    End If
    Set GetAtomicCapabilityTypeByName = atomic
End Function

Public Function GetCapabilityTypeByID(ByVal aCapTypeID As Integer) As MTCompositeCapabilityType
  'do security check
  Dim captype
  On Error GoTo ErrMgr
  
  GetCapabilityTypes
  'Set GetRoleByName = mRoles.Item(aRoleName)
  For Each captype In mCapTypes
    If captype.ID = aCapTypeID Then
      Set GetCapabilityTypeByID = captype
      Exit Function
    End If
  Next
  Set GetCapabilityTypeByID = Nothing
ErrMgr:
End Function

