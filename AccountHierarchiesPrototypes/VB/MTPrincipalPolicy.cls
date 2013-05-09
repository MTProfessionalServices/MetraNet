VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MTPrincipalPolicy"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Public Enum PolicyType
  ACTIVE_ = 0
  DEFAULT_ = 1
  SUSPENDED_ = 2
End Enum

Private mCaps As New Collection
Private mDeletedCaps As New Collection
Private mRoles As New Collection
Private policy As New MTSecurityPolicy
Private NetMeter As New SQLRowsetWrapper
Private mID As Integer
Private mPrincipal As MTSecurityPrincipal
Private mPolicyType As PolicyType
Private mName As String
Private mDesc As String
Private mSc As MTSessionContext



Public Property Let Name(ByVal vData As String)
  mName = vData
End Property

Public Property Get Name() As String
  Name = mName
End Property

Public Property Let Description(ByVal vData As String)
  mDesc = vData
End Property

Public Property Get Description() As String
  Description = mDesc
End Property

Public Property Let Principal(ByVal vData As Object)
  Set mPrincipal = vData
End Property

Public Property Get Principal() As Object
  Set Principal = mPrincipal
End Property

Public Property Let PolicyType(ByVal vData As PolicyType)
  mPolicyType = vData
End Property

Public Property Get PolicyType() As PolicyType
  PolicyType = mPolicyType
End Property

Public Property Let ID(ByVal vData As Integer)
  mID = vData
End Property

Public Property Get ID() As Integer
  ID = mID
End Property


Public Function AddCapability(aCap As Object)
'  Dim this As Object
'  Dim idx
'  idx = 0
'  For Each this In mCaps
'    idx = idx + 1
'    If this.ID = aCap.ID Then
'      mDeletedCaps.Add this
'      mCaps.Remove idx
'    End If
'  Next
  mCaps.Add aCap
End Function

Public Function RemoveCapability(aCapID As Integer)
  Dim this As Object
  Dim idx
  idx = 0
  For Each this In mCaps
    idx = idx + 1
    If this.ID = aCapID Then
      mDeletedCaps.Add this
      mCaps.Remove idx
      Exit Function
    End If
  Next
End Function

Public Function RemoveCapabilitiesOfType(aCapTypeID As Integer)
  Dim this As Object
  Dim coll As Collection
  Dim idx
  idx = 0
  For Each this In mCaps
    idx = idx + 1
    If this.CapabilityType.ID = aCapTypeID Then
      mDeletedCaps.Add this
  '    mCaps.Remove idx
    End If
  Next
End Function

Public Function GetCapabilitiesOfType(aCapTypeID As Integer) As Collection
  Dim coll As New Collection
  Dim this As Object
  For Each this In mCaps
    If this.CapabilityType.ID = aCapTypeID Then
      coll.Add this
    End If
  Next
  Set GetCapabilitiesOfType = coll
End Function

Public Function AddRole(aRole As Object)
  Dim this As Object
  On Error GoTo ErrMgr:
  Set this = mRoles.Item(aRole.Name)
  Exit Function
ErrMgr:
  mRoles.Add aRole, aRole.Name
End Function

Public Function RemoveRole(aRoleID As Integer)
  Dim r As MTRole
  For Each r In mRoles
    If r.ID = aRoleID Then
      mRoles.Remove r.Name
      Exit Function
    End If
  Next
End Function


' really should be protected
Public Function SaveCapabilities()
  Dim cap As Object
  Dim delcap As Object
  
  
  For Each cap In mCaps
    cap.Save Me
  Next
  
  'Hack - handle update/remove scenario better
  For Each delcap In mDeletedCaps
    delcap.Remove Me
  Next

  

End Function

'Internal,
'not even put it on interface, call C++ method directly

Public Function Init(aPrincipal As MTSecurityPrincipal)
  'Initialize capabilities and roles by
  'Principal and policy status
  'Status has to be set before calling init
  Dim rs As MTSQLRowset
  Set mPrincipal = aPrincipal
  Dim query As String
  
  query = "SELECT id_policy FROM t_principal_policy WHERE "
  query = query + GetPrincipalColumn() + "=" + str(mPrincipal.ID)
  query = query + " AND policy_type='" + GetStringStatus() + "'"
  
  Set rs = NetMeter.Execute(DebugStr(query))
  
  If rs.EOF = False Then
    'should check for number of records - if more then one found
    'it's an error
    rs.MoveFirst
    ID = rs.Value(0)
    InitCapabilities
    InitRoles
  End If
End Function

Public Function Save() As Integer
  Dim clean As String
  Dim query As String
  Dim role As MTRole
  Dim rs As MTSQLRowset
  Dim bNew As Boolean
  bNew = False
  Set rs = NetMeter.Rowset
  
  If ID = -1 Then
    bNew = True
    rs.InitializeForStoredProc ("sp_InsertPolicy")
    rs.AddInputParameterToStoredProc "aPrincipalColumn", MTParameterType.MTTYPE_VARCHAR, MTParameterDirection.INPUT_PARAM, GetPrincipalColumn()
    rs.AddInputParameterToStoredProc "aPrincipalID", MTParameterType.MTTYPE_INTEGER, MTParameterDirection.INPUT_PARAM, Me.Principal.ID
    rs.AddInputParameterToStoredProc "aPolicyType", MTParameterType.MTTYPE_VARCHAR, MTParameterDirection.INPUT_PARAM, GetStringStatus()
    rs.AddOutputParameterToStoredProc "ap_id_prop", MTParameterType.MTTYPE_INTEGER, MTParameterDirection.OUTPUT_PARAM
    rs.ExecuteStoredProc
    
    ID = rs.GetParameterFromStoredProc("ap_id_prop")
  End If
  
  If bNew = False Then
    clean = "DELETE FROM t_policy_role WHERE"
    clean = clean + " id_policy= " + str(ID)
    NetMeter.Execute DebugStr(clean)
  End If
  For Each role In mRoles
    query = "INSERT INTO t_policy_role VALUES"
    query = query + "(" + str(ID) + ", " + str(role.ID) + ")"
    NetMeter.Execute DebugStr(query)
  Next
 SaveCapabilities
End Function




Private Function InitCapabilities()
  Dim query As String
  Dim table As String
  Dim field As String
  Dim classname As String
  Dim captype As New MTCompositeCapabilityType
  Dim cap As Object
  Dim Recordset As MTSQLRowset
  
  Set mCaps = Nothing
  Set mCaps = New Collection
  
  query = "SELECT cap.id_cap_type, cap.id_cap_instance, capclass.tx_name from t_capability_instance cap, t_composite_capability_type capclass"
  query = query + " WHERE cap.id_policy=" + str(ID) + " AND cap.id_parent_cap_instance IS NULL AND cap.id_cap_type=capclass.id_cap_type"
  
  Set Recordset = NetMeter.Execute(DebugStr(query))
  
  If Recordset.EOF = False Then
  
  Recordset.MoveFirst
  
  While Recordset.EOF = False
    classname = Recordset.Value(2)
    Set captype = policy.GetCapabilityTypeByName(classname)
    Set cap = captype.CreateInstance()
    cap.ID = Recordset.Value(1) 'id_cap_instance
    cap.Init Me
    'mCaps.Add cap, cap.CapabilityType.Name
    AddCapability cap
    Recordset.MoveNext
  Wend
  
  End If
  
End Function
Private Function InitRoles()
  Dim Recordset As MTSQLRowset
  Dim role As New MTRole
  Dim roleid As Integer
  Dim query As String
  query = "SELECT t_role.id_role FROM t_policy_role, t_role WHERE t_policy_role.id_role=t_role.id_role AND id_policy = " + str(ID)
  Set Recordset = NetMeter.Execute(DebugStr(query))
  
  If Recordset.EOF = False Then
   
    Recordset.MoveFirst
    While Recordset.EOF = False
      Set role = New MTRole
      role.ID = Recordset.Value(0)
      role.Init
      mRoles.Add role, role.Name
      Recordset.MoveNext
    Wend
    
  End If
End Function

Private Sub Class_Initialize()
    NetMeter.InitRowset
    mPolicyType = ACTIVE_
    ID = -1
End Sub


Public Function GetCapabilitiesAsRowset() As IMTSQLRowset
  Dim rs As MTSQLRowset
  Dim Rowset
  Dim query As String
  query = "select id_cap_instance, t_capability_instance.id_cap_type, tx_name, tx_desc, tx_progid, tx_editor, "
  query = query + "csr_assignable, subscriber_assignable, (SELECT COUNT(*) FROM t_compositor WHERE id_composite = t_capability_instance.id_cap_type) num_atomic FROM t_capability_instance INNER JOIN t_composite_capability_type ON t_capability_instance.id_cap_type = t_composite_capability_type.id_cap_type WHERE id_parent_cap_instance IS NULL AND id_policy = "
  query = query + str(ID)
  
  Set Rowset = CreateObject("MTSQLRowset.MTSQLRowset.1")
  Rowset.InitDisconnected
  
  
  Rowset.AddColumnDefinition "id_cap_instance", "int32", 255
  Rowset.AddColumnDefinition "id_cap_type", "int32", 255
  Rowset.AddColumnDefinition "tx_name", "string", 255
  Rowset.AddColumnDefinition "tx_desc", "string", 255
  Rowset.AddColumnDefinition "tx_progid", "string", 255
  Rowset.AddColumnDefinition "tx_editor", "string", 255
  Rowset.AddColumnDefinition "csr_assignable", "string", 1
  Rowset.AddColumnDefinition "subscriber_assignable", "string", 1
   Rowset.AddColumnDefinition "num_atomic", "int32", 1
  
  Rowset.OpenDisconnected
  
  Set rs = NetMeter.Execute(DebugStr(query))
  If rs.EOF = True Then
    Set GetCapabilitiesAsRowset = Rowset
    Exit Function
    End If
  rs.MoveFirst
  
  While rs.EOF = False
    Rowset.AddRow
    Rowset.AddColumnData "id_cap_instance", rs.Value(0)
    Rowset.AddColumnData "id_cap_type", rs.Value(1)
    Rowset.AddColumnData "tx_name", rs.Value(2)
    Rowset.AddColumnData "tx_desc", rs.Value(3)
    Rowset.AddColumnData "tx_progid", rs.Value(4)
    Rowset.AddColumnData "tx_editor", rs.Value(5)
    Rowset.AddColumnData "csr_assignable", rs.Value(6)
    Rowset.AddColumnData "subscriber_assignable", rs.Value(7)
    Rowset.AddColumnData "num_atomic", rs.Value(8)
    rs.MoveNext
  Wend
  
  Set GetCapabilitiesAsRowset = Rowset

End Function

Public Function GetRolesAsRowset()
  Dim rs As MTSQLRowset
  Dim Rowset
  Dim query As String
  query = "select t_role.id_role, tx_name, tx_desc FROM t_role  INNER JOIN t_policy_role ON t_role.id_role = t_policy_role.id_role WHERE id_policy = "
  query = query & str(ID)
  
  Set Rowset = CreateObject("MTSQLRowset.MTSQLRowset.1")
  Rowset.InitDisconnected
  
  
  Rowset.AddColumnDefinition "id_role", "int32", 255
  Rowset.AddColumnDefinition "tx_name", "string", 255
  Rowset.AddColumnDefinition "tx_desc", "string", 255
  Rowset.OpenDisconnected
  
  Set rs = NetMeter.Execute(DebugStr(query))
  If rs.EOF = True Then
    Set GetRolesAsRowset = Rowset
    Exit Function
    End If
  rs.MoveFirst
  
  While rs.EOF = False
    Rowset.AddRow
    Rowset.AddColumnData "id_role", rs.Value(0)
    Rowset.AddColumnData "tx_name", rs.Value(1)
    Rowset.AddColumnData "tx_desc", rs.Value(2)
    rs.MoveNext
  Wend
  
  Set GetRolesAsRowset = Rowset

End Function

Public Property Get Capabilities() As Collection
    Set Capabilities = mCaps
End Property

Public Property Get Roles() As Collection
    Set Roles = mRoles
End Property

Public Function GetActive(aCtx As MTSessionContext, aPrincipal As MTSecurityPrincipal) As MTPrincipalPolicy
  
  ' do access control check
  'depending on who the principal is
  
  Dim prpol As New MTPrincipalPolicy
  prpol.PolicyType = ACTIVE_
  prpol.Init aPrincipal
  Set GetActive = prpol
End Function

' GetDefault should return error if a principal is
' 1. a Role
' 2. not a 'Folder' account
'
Public Function GetDefault(aCtx As MTSessionContext, aPrincipal As MTSecurityPrincipal) As MTPrincipalPolicy
  
  ' do access control check
  'depending on who the principal is
  Dim prpol As New MTPrincipalPolicy
  prpol.PolicyType = DEFAULT_
  prpol.Init aPrincipal
  Set GetDefault = prpol
End Function

Public Function GetAll(aPrincipal As MTSecurityPrincipal, aCtx As MTSessionContext) As Collection
  ' do access control check
  'depending on who the principal is
  Dim coll As New Collection
  Set GetAll = coll
End Function

Public Function IsPrincipalInRole(aRoleName As String) As Boolean
  ' do access control check
  'depending on who the principal is
  Dim role
  On Error GoTo err
  Set role = mRoles.Item(aRoleName)
  IsPrincipalInRole = True
  Exit Function
err:
  IsPrincipalInRole = False
End Function



Private Function GetStringStatus() As String
  Dim str
  If mPolicyType = ACTIVE_ Then
    str = "A"
  Else
  If mPolicyType = DEFAULT_ Then
    str = "D"
  Else
    str = "S"
  End If
  End If
  GetStringStatus = str
End Function

Private Function GetPrincipalColumn() As String
  Dim str
  If mPrincipal.PrincipalType = ROLE_ Then
    str = "id_role"
  Else
    str = "id_acc"
  End If
  GetPrincipalColumn = str
End Function


            

