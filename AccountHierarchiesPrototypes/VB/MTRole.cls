VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MTRole"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit


Private NetMeter As New SQLRowsetWrapper

' mname and mDescs belongs to MTRole


'simulate inheritance by aggregating base class
Private mSP As New MTSecurityPrincipal

Private mGUID As String

Private Sub Class_Initialize()
  Dim propMeta As MTPropertyMetaData
  Dim prop As MTProperty
  NetMeter.InitRowset
  ' create a property for each property meta data
  For Each propMeta In RoleMetaDataCollection
    Set prop = mSP.Properties.Add(propMeta)
  Next
  mSP.PrincipalType = ROLE_
  mSP.ID = -1
End Sub


''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' methods/properties 'inherited' from MTSecurityPrincipal
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Property Get Properties() As MTProperties
  Set Properties = mSP.Properties
End Property

Public Property Let PrincipalType(ByVal vData As PrincipalType)
  mSP.PrincipalType = vData
End Property

Public Property Get PrincipalType() As PrincipalType
  PrincipalType = mSP.PrincipalType
End Property

Public Property Let ID(ByVal vData As Integer)
  mSP.ID = vData
End Property

Public Property Get ID() As Integer
  ID = mSP.ID
End Property

Public Property Let GUID(ByVal vData As String)
  mGUID = vData
End Property

Public Property Get GUID() As String
  GUID = mGUID
End Property

Public Function Save() As Integer
 Dim query As String
 Dim sel As String
 Dim rs As MTSQLRowset
 Dim bNameCollision As Boolean
 Dim tempid As Integer
 bNameCollision = False
 
 'check if role with this name already exists
 query = "SELECT id_role FROM t_role WHERE tx_name = N'" + Name + "'"
 Set rs = NetMeter.Execute(DebugStr(query))
 If rs.EOF = False Then
  bNameCollision = True
  rs.MoveFirst
  tempid = rs.Value(0)
 End If
 
 If bNameCollision = True Then
  ' Call Update on Executant
  query = "UPDATE t_role SET tx_desc='" + Description + "', "
  query = query + "csr_assignable = '" + GetCharFromBool(CSRAssignable) + "' , "
  query = query + "subscriber_assignable = '" + GetCharFromBool(SubscriberAssignable) + "' WHERE id_role="
  query = query + str(ID)
  NetMeter.Execute DebugStr(query)
  
  If HasID(Me) = False Then
    ID = tempid
    Save = ID
    Exit Function
  End If
    
  Else
    ' Call Create on Executant
    rs.InitializeForStoredProc ("sp_InsertRole")
    rs.AddInputParameterToStoredProc "aGuid", MTParameterType.MTTYPE_VARCHAR, MTParameterDirection.INPUT_PARAM, CreateGUID
    rs.AddInputParameterToStoredProc "aName", MTParameterType.MTTYPE_VARCHAR, MTParameterDirection.INPUT_PARAM, Name
    rs.AddInputParameterToStoredProc "aDesc", MTParameterType.MTTYPE_VARCHAR, MTParameterDirection.INPUT_PARAM, Description
    rs.AddInputParameterToStoredProc "aCSRAssignable", MTParameterType.MTTYPE_VARCHAR, MTParameterDirection.INPUT_PARAM, GetCharFromBool(CSRAssignable)
    rs.AddInputParameterToStoredProc "aSubAssignable", MTParameterType.MTTYPE_VARCHAR, MTParameterDirection.INPUT_PARAM, GetCharFromBool(SubscriberAssignable)
    rs.AddOutputParameterToStoredProc "ap_id_prop", MTParameterType.MTTYPE_INTEGER, MTParameterDirection.OUTPUT_PARAM
    rs.ExecuteStoredProc
    
    ID = rs.GetParameterFromStoredProc("ap_id_prop")
  
  End If

'save policy
 mSP.Save
  
 Save = ID
End Function


Public Function Init()
  Dim sel As String
  Dim prpol As New MTPrincipalPolicy
  Dim rs As MTSQLRowset
  sel = " SELECT tx_guid, tx_name, tx_desc, csr_assignable, subscriber_assignable FROM t_role WHERE id_role=" + str(ID)
  Set rs = NetMeter.Execute(DebugStr(sel))
  If rs.EOF = True Then
    'Error
    Exit Function
  End If
  rs.MoveFirst
  ' GUID = rs.Value(0)
  Name = rs.Value(1)
  Description = rs.Value(2)
  CSRAssignable = GetBoolFromChar(rs.Value(3))
  SubscriberAssignable = GetBoolFromChar(rs.Value(4))
End Function

Public Function GetActivePolicy(Optional ByVal aCtx As MTSessionContext) As MTPrincipalPolicy
  Set GetActivePolicy = mSP.GetActivePolicy()
End Function

''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' methods/properties that belong to MTRole
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Public Function ToXml() As String


End Function

Public Function FromXml(aXml As String)


End Function

Public Property Let Name(vData As String)
  mSP.Properties.Item("Name").Value = vData
End Property

Public Property Get Name() As String
  Name = mSP.Properties.Item("Name").Value
End Property


Public Property Let Description(vData As String)
  mSP.Properties.Item("Description").Value = vData
End Property

Public Property Get Description() As String
  Description = mSP.Properties.Item("Description").Value

End Property

Public Property Let CSRAssignable(vData As Boolean)
  mSP.Properties.Item("CSRAssignable").Value = vData
End Property

Public Property Get CSRAssignable() As Boolean
  CSRAssignable = mSP.Properties.Item("CSRAssignable").Value
End Property

Public Property Let SubscriberAssignable(vData As Boolean)
  mSP.Properties.Item("SubscriberAssignable").Value = vData
End Property

Public Property Get SubscriberAssignable() As Boolean
  SubscriberAssignable = mSP.Properties.Item("SubscriberAssignable").Value
End Property
'================================================================
' If this property is set then
' can not add capability of type that's not marked as
' "SubscriberAssignable" to this role
' May be a role itself should be marked as "SubscriberAssignable"
' or "CSRAssignable" or both at creation time
'=================================================================

Public Function HasSubscriberMembers() As Boolean

End Function

'================================================================
' If this property is set then
' can not add capability of type that's not marked as
' "CSRAssignable" to this role
' May be a role itself should be marked as "SubscriberAssignable"
' or "CSRAssignable" or both at creation time
'=================================================================

Public Function HasCSRMembers() As Boolean

End Function

