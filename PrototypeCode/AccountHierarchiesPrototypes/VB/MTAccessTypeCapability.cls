VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MTAccessTypeCapability"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Public Enum AccessType
  READ_ = 0
  WRITE_ = 1
End Enum

Private NetMeter As New SQLRowsetWrapper
Private mParentID As Integer
Private mAccessType As AccessType

' Add properties that actually live on IMTCapability interface
'Private mID As Integer
'Private mType As Object

' fake inheritance by aggregating the 'parent'
Private mAtomicCap As New MTAtomicCapability


Private Sub Class_Initialize()
    NetMeter.InitRowset
    mAtomicCap.ID = -1

End Sub

Public Property Let AccessType(ByVal vData As AccessType)
  mAccessType = vData
End Property

Public Property Get AccessType() As AccessType
  AccessType = mAccessType
End Property

' Methods that actually live on IMTCapability interface
Public Property Get ParentID() As Integer
  mAtomicCap.ParentID = mParentID
End Property

Public Property Let ParentID(ByVal vData As Integer)
  mAtomicCap.ParentID = vData
End Property


' Add methods/properties that actually live on IMTCapability interface

' this one I actually have to implement here
Public Function Implies(ByVal aDemandedCap As Object) As Boolean
  ' check that the object passed in is of same type
  ' in C++ query for interface
  If (aDemandedCap Is Nothing) Or TypeName(aDemandedCap) <> "MTAccessTypeCapability" Then
   Implies = False
   Exit Function
  End If
  Implies = AccessType >= aDemandedCap.AccessType
End Function

Public Function Save(ByVal aPolicy As Object)
  Dim query As String
  Dim Principal As String
  Dim at As String
  Dim Recordset As Recordset
  
  ID = mAtomicCap.Save(aPolicy)
  
  If AccessType = READ_ Then
    at = "R"
  Else
    at = "W"
  End If
  
  'delete previous params first
  If HasID(Me) = True Then
    query = "DELETE FROM t_access_type_capability WHERE id_cap_instance=" + str(ID)
    NetMeter.Execute DebugStr(query)
  End If
  
  'now insert into t_access_type table
  query = "INSERT INTO t_access_type_capability (id_cap_instance, param_value) VALUES("
  query = query + str(ID) + ", '" + at + "')"
  NetMeter.Execute DebugStr(query)
End Function

Public Function Remove(ByVal aPolicy As Object)
  Dim query As String
  Dim Principal As String
  Dim at As String
  Dim Recordset As Recordset
  
  'delete previous params
  If HasID(Me) = True Then
    query = "DELETE FROM t_access_type_capability WHERE id_cap_instance=" + str(ID)
    NetMeter.Execute DebugStr(query)
  End If
  
  mAtomicCap.Remove aPolicy
  
End Function

Public Function Init(ByVal aPolicy As Object)

  Dim query As String
  Dim Principal As String
  ' Dim AccessType As String
  Dim Recordset As MTSQLRowset
  
  query = "SELECT t_capability_instance.id_cap_instance, param_value FROM t_capability_instance, t_access_type_capability "
  query = query + "WHERE id_policy=" + str(aPolicy.ID) + " And id_parent_cap_instance = " + str(mAtomicCap.ParentID)
  query = query + " AND t_capability_instance.id_cap_instance = t_access_type_capability.id_cap_instance"
  
  Set Recordset = NetMeter.Execute(DebugStr(query))
  
  If Recordset.EOF = True Then
    'error
    Exit Function
  End If
  
  Recordset.MoveFirst
  
  ID = Recordset.Value(0)
  
  If Recordset.Value(1) = "R" Then
    AccessType = READ_
  Else
    AccessType = WRITE_
  End If
  
End Function

Public Property Let ID(ByVal vData As Integer)
  mAtomicCap.ID = vData
End Property

Public Property Get ID() As Integer
 ID = mAtomicCap.ID
End Property

Public Property Get CapabilityType() As Object
  Set CapabilityType = mAtomicCap.CapabilityType
End Property

Public Property Let CapabilityType(ByVal vData As Object)
  Set mAtomicCap.CapabilityType = vData
End Property

Public Function Clone() As Object
 
End Function








