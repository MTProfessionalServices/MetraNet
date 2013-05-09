VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MTEnumCapability"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Private NetMeter    As New SQLRowsetWrapper
Private mParentID   As Integer
Private m_varValue  As Variant

Public NameSpace    As String
Public Name         As String


Private mAtomicCap As New MTAtomicCapability ' fake inheritance by aggregating the 'parent'

Private Sub Class_Initialize()
    NetMeter.InitRowset
    mAtomicCap.ID = -1
     NameSpace = "global"
    Name = "Application"
End Sub

Public Property Get DBValueID() As Long

    Dim objEnumTypeconfig As Object
    
    If Not IsEmpty(Value) Then
        Set objEnumTypeconfig = CreateObject("Metratech.MTEnumConfig.1") ' create the object and add it to the cache...
        DBValueID = objEnumTypeconfig.GetID(Me.NameSpace, Me.Name, Me.Value)
    End If
End Property

Public Property Let DBValueID(v As Long)

    Dim objEnumTypeconfig  As Object
    
    Set objEnumTypeconfig = CreateObject("Metratech.MTEnumConfig.1") ' create the object and add it to the cache...
    Value = objEnumTypeconfig.GetEnumeratorValueByID(v)
End Property


Public Property Get ParentID() As Integer ' Methods that actually live on IMTCapability interface
  mAtomicCap.ParentID = mParentID
End Property
Public Property Let ParentID(ByVal vData As Integer)
  mAtomicCap.ParentID = vData
End Property


' -- Add methods/properties that actually live on IMTCapability interface --

' this one I actually have to implement here
Public Function Implies(ByVal aDemandedCap As Object) As Boolean

  Dim match             As Boolean
  Dim objPath           As New MTHierarchyPath
  
  If (aDemandedCap Is Nothing) Or TypeName(aDemandedCap) <> TypeName(Me) Then ' Check that the object passed in is of same type in C++ query for interface
  
        Implies = False
        Exit Function
  End If
  
  If IsEmpty(aDemandedCap.Value) Then ' value is required
  
        Implies = False
  Else
        Implies = True
  End If
End Function

Public Function Save(ByVal aPolicy As Object) As Boolean

  Dim query         As String
  Dim Principal     As String
  Dim param         As MTPathParameter
  
  ID = mAtomicCap.Save(aPolicy)
  
  ' -- delete previous params first --
  If HasID(Me) Then
    query = "DELETE FROM t_enum_capability WHERE id_cap_instance=" + str(ID)
    NetMeter.Execute DebugStr(query)
  End If
  
  If Me.DBValueID <> 0 Then
    query = PreProcess("insert into t_enum_capability (id_cap_instance,tx_param_name,param_value,tx_op) values ([CAP_ID],'EnumTypeValue',[DBVALUEID],'!')", "CAP_ID", ID, "DBVALUEID", Me.DBValueID)
    NetMeter.Execute DebugStr(query)
  End If
  Save = ID
End Function

Public Function Remove(ByVal aPolicy As Object) As Boolean

  Dim query As String
  
  If HasID(Me) Then 'delete previous params first
  
        query = "DELETE FROM t_enum_capability WHERE id_cap_instance=" + str(ID)
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
  
  query = PreProcess("SELECT t_capability_instance.id_cap_instance, t_enum_capability.* FROM t_capability_instance, t_enum_capability WHERE id_policy = [POLICY_ID] AND id_parent_cap_instance = [ATOMICCAP_PARENTID]  AND t_capability_instance.id_cap_instance = t_enum_capability.id_cap_instance", "POLICY_ID", aPolicy.ID, "ATOMICCAP_PARENTID", mAtomicCap.ParentID)
  
  Set Recordset = NetMeter.Execute(DebugStr(query))
  
  If Recordset.EOF = True Then Exit Function
  DBValueID = Recordset.Value("param_value")
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


Public Property Get Value() As Variant
    Value = m_varValue
End Property

Public Property Let Value(ByVal vNewValue As Variant)
    m_varValue = vNewValue
End Property
