VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MTCompositeCapability"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

' Add properties that actually live on IMTCapability interface
Private mID As Integer
Private mType As MTCompositeCapabilityType
Public CapabilityType As Object


Private NetMeter As New SQLRowsetWrapper
Private mAtomicCaps As New Collection

Private Sub Class_Initialize()
    NetMeter.InitRowset
    ID = -1
End Sub

Public Property Get AtomicCapabilities() As Collection
  Set AtomicCapabilities = mAtomicCaps
End Property

Public Function AddAtomicCapability(ByVal aCap As Object)
  mAtomicCaps.Add aCap, aCap.CapabilityType.Name
End Function

Public Function GetAtomicCapabilityByName(aName As String) As Object
  Dim cap
  On Error GoTo err:
  Set cap = mAtomicCaps.Item(aName)
  Set GetAtomicCapabilityByName = cap
  Exit Function
err:
  GetAtomicCapabilityByName = Nothing
End Function



' Add methods that actually live on IMTCapability interface

Public Function Implies(ByVal aCap As Object)
  Dim cap, Name As String
  
  For Each cap In mAtomicCaps
  
    Name = cap.CapabilityType.Name
    
    If (cap.Implies(aCap.GetAtomicCapabilityByName(Name))) Then
    
        Implies = True
        Exit Function
    End If
  Next
  Implies = True
End Function

Public Function Save(ByVal aPolicy As Object) As Integer

Dim Principal As String
Dim query As String
Dim rs As MTSQLRowset
Dim cap As Object

Set rs = NetMeter.Rowset

If HasID(Me) Then
  Save = ID
  Exit Function
End If
        
rs.InitializeForStoredProc ("sp_InsertCapabilityInstance")
rs.AddInputParameterToStoredProc "aGuid", MTParameterType.MTTYPE_VARCHAR, MTParameterDirection.INPUT_PARAM, CreateGUID
rs.AddInputParameterToStoredProc "aParentInstance", MTParameterType.MTTYPE_INTEGER, MTParameterDirection.INPUT_PARAM, Null
rs.AddInputParameterToStoredProc "aPolicy", MTParameterType.MTTYPE_INTEGER, MTParameterDirection.INPUT_PARAM, aPolicy.ID
rs.AddInputParameterToStoredProc "aCapType", MTParameterType.MTTYPE_INTEGER, MTParameterDirection.INPUT_PARAM, CapabilityType.ID
rs.AddOutputParameterToStoredProc "ap_id_prop", MTParameterType.MTTYPE_INTEGER, MTParameterDirection.OUTPUT_PARAM
rs.ExecuteStoredProc
  
ID = rs.GetParameterFromStoredProc("ap_id_prop")
    
For Each cap In mAtomicCaps
  cap.ParentID = ID
  cap.Save aPolicy
Next
  
End Function

Public Function Remove(ByVal aPolicy As Object)

Dim Principal As String
Dim query As String
Dim cap As Object
        
  If (HasID(Me)) Then
    'first remove all atomic caps
    'because of the referential constraint
    For Each cap In mAtomicCaps
      cap.ParentID = ID
      cap.Remove aPolicy
    Next

    'Clean of capabilities of type for now, implementation will
    'have better update scenario
    
    query = "DELETE FROM t_capability_instance WHERE id_parent_cap_instance IS NULL AND"
    query = query + " id_policy=" + str(aPolicy.ID) + " And id_cap_type = " + str(CapabilityType.ID)
    'query = "DELETE FROM t_capability_instance WHERE id_cap_instance = " + str(ID)
    NetMeter.Execute DebugStr(query)
  Else
    'error, can't remove unitialized instance
  End If
  
End Function

Public Function Init(ByVal aPolicy As Object)
  Dim Principal As String
  Dim query As String
  Dim Recordset As Recordset
  Dim cap As Object
        
        
'  query = "SELECT id_cap_instance FROM t_capability_instance "
'  query = query + "WHERE id_parent_cap_instance IS NULL AND id_policy = " + str(aPolicy.ID) + " AND id_cap_type = " + str(CapabilityType.ID)
'  query = query + " AND id_cap_instance"
'  Set recordset = netmeter.Execute(query)
'  If recordset.EOF = False Then
'    recordset.MoveFirst
'    ID = recordset.Fields(0).Value
'
    For Each cap In mAtomicCaps
      cap.ParentID = ID
      cap.Init aPolicy
    Next
' End If
  
End Function


Public Property Let ID(ByVal vData As Integer)
  mID = vData
End Property

Public Property Get ID() As Integer
 ID = mID
End Property


'Public Property Get CapabilityType() As Object
'  CapabilityType = mType
'End Property

'Public Property Let CapabilityType(ByVal vData As Object)
'  Set mType = vData
'End Property


Public Function Clone() As Object
 
End Function





