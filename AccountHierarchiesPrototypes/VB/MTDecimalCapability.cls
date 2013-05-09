VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MTDecimalCapability"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Private NetMeter    As New SQLRowsetWrapper
Private mParentID   As Integer

Public Parameter    As Variant
Public Operator     As String

' Add properties that actually live on IMTCapability interface

' fake inheritance by aggregating the 'parent'
Private mAtomicCap As New MTAtomicCapability



Private Sub Class_Initialize()
    NetMeter.InitRowset
    mAtomicCap.ID = -1
    
End Sub


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

  Dim match             As Boolean
  Dim objPath           As New MTHierarchyPath
  
  If (aDemandedCap Is Nothing) Or TypeName(aDemandedCap) <> TypeName(Me) Then ' Check that the object passed in is of same type in C++ query for interface
  
        Implies = False
        Exit Function
  End If
  
  If IsEmpty(aDemandedCap.Parameter) Then
  
        Implies = True
  Else
    If aDemandedCap.Parameter >= Me.Parameter Then
    
        Implies = True
    End If
  End If
End Function

Public Function Save(ByVal aPolicy As Object) As Boolean

  Dim query         As String
  Dim Principal     As String
  Dim param         As MTPathParameter
  
  ID = mAtomicCap.Save(aPolicy)
  
  'delete previous params first
  If HasID(Me) Then
        query = "DELETE FROM t_decimal_capability WHERE id_cap_instance=" + str(ID)
        NetMeter.Execute DebugStr(query)
  End If
  
  If Not IsEmpty(Parameter) Then
  
    query = PreProcess("insert into t_decimal_capability (id_cap_instance,tx_param_name,tx_op,param_value) values ([CAP_ID],'Amount','<',[PARAMETER])", "CAP_ID", ID, "PARAMETER", Parameter)
    NetMeter.Execute DebugStr(query)
  End If
  Save = ID
  
End Function

Public Function Remove(ByVal aPolicy As Object) As Boolean

  Dim query As String
  
  If HasID(Me) Then 'delete previous params first
  
        query = "DELETE FROM t_decimal_capability WHERE id_cap_instance=" + str(ID)
        NetMeter.Execute DebugStr(query)
  End If
  mAtomicCap.Remove aPolicy
  Remove = True
End Function


Public Function Init(ByVal aPolicy As Object) As Boolean

  Dim query         As String
  Dim Path          As String
  Dim Principal     As String
  Dim Recordset     As MTSQLRowset
  
  query = "SELECT t_capability_instance.id_cap_instance, t_decimal_capability.* FROM t_capability_instance, t_decimal_capability WHERE id_policy = " + str(aPolicy.ID) + " AND id_parent_cap_instance = " & str(mAtomicCap.ParentID) & " AND t_capability_instance.id_cap_instance = t_decimal_capability.id_cap_instance"
  
  Set Recordset = NetMeter.Execute(DebugStr(query))
  
  If Recordset.EOF = True Then Exit Function
  Parameter = Recordset.Value("PARAM_VALUE")
  Init = False
  
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




