VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MTAtomicCapability"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Private NetMeter As New SQLRowsetWrapper
Private mParentID As Integer

' Add properties that actually live on IMTCapability interface
Private mID As Integer
Private mType As Object

Public CapabilityType As Object

Private Sub Class_Initialize()
    NetMeter.InitRowset
    ID = -1

End Sub

Public Property Get ParentID() As Integer
  ParentID = mParentID
End Property

Public Property Let ParentID(ByVal vData As Integer)
  mParentID = vData
End Property


' Add methods/properties that actually live on IMTCapability interface
Public Function Implies(ByVal aCap As Object) As Boolean

End Function

Public Function Save(ByVal aPolicy As Object) As Integer
' Save base instance. This method is called by every concrete
' atomic capability before saving individual parameters

 Dim Principal As String
Dim query As String
Dim rs As MTSQLRowset
Dim cap As Object

If HasID(Me) Then
  Save = ID
  Exit Function
End If

Set rs = NetMeter.Rowset
        
    rs.InitializeForStoredProc ("sp_InsertCapabilityInstance")
    rs.AddInputParameterToStoredProc "aGuid", MTParameterType.MTTYPE_VARCHAR, MTParameterDirection.INPUT_PARAM, CreateGUID
    rs.AddInputParameterToStoredProc "aParentInstance", MTParameterType.MTTYPE_INTEGER, MTParameterDirection.INPUT_PARAM, Me.ParentID
    rs.AddInputParameterToStoredProc "aPolicy", MTParameterType.MTTYPE_INTEGER, MTParameterDirection.INPUT_PARAM, aPolicy.ID
    rs.AddInputParameterToStoredProc "aCapType", MTParameterType.MTTYPE_INTEGER, MTParameterDirection.INPUT_PARAM, CapabilityType.ID
    rs.AddOutputParameterToStoredProc "ap_id_prop", MTParameterType.MTTYPE_INTEGER, MTParameterDirection.OUTPUT_PARAM
    rs.ExecuteStoredProc
  
  ID = rs.GetParameterFromStoredProc("ap_id_prop")
    
  Save = ID

End Function

Public Function Remove(ByVal aPolicy As Object)
  ' removes base instance. This method is called by every concrete
  ' atomic capability after removing individual parameters
  'because of the referential constraint

  Dim query As String
  Dim Principal As String
  Dim AccessType As String
  
  If (HasID(Me)) Then
    query = "DELETE FROM t_capability_instance WHERE id_parent_cap_instance=" + str(ParentID) + " AND "
    query = query + " id_policy=" + str(aPolicy.ID) + " AND id_cap_type=" + str(CapabilityType.ID)
    NetMeter.Execute DebugStr(query)
  Else
    'error - can't remove uninitialized instance
  End If
End Function


Public Function Init(ByVal aPolicy As Object)

End Function

Public Property Let ID(ByVal vData As Integer)
  mID = vData
End Property

Public Property Get ID() As Integer
 ID = mID
End Property

'Public Property Get CapabilityType() As Object
'  Set CapabilityType = mType
'End Property

'Public Property Let CapabilityType(ByVal vData As Object)
'  Set mType = vData
'End Property




Public Function Clone() As Object
 
End Function






