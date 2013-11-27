VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MTCompositeCapabilityType"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
' All the methods taking Object as parameter will  take IMTCompositeCapability
' instead (have to do this in VB cuz there is no inheritance)


Option Explicit

Private NetMeter As New SQLRowsetWrapper
Private mID As Integer
Private mName As String
Private mDesc As String
Private mProgID As String
Private mEditor As String
Private mAtomicCaps As New Collection
Private mbCSRAssignable As Boolean
Private mbSubscriberAssignable As Boolean
Private mbMultipleInstances As Boolean
Private mGUID As String

     


Private Sub Class_Initialize()
    'netmeter.ConnectionString = ConnectionString
    NetMeter.InitRowset
    
End Sub

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
 Public Property Let ProgID(ByVal vData As String)
    mProgID = vData
 End Property
 Public Property Get ProgID() As String
   ProgID = mProgID
 End Property
 Public Property Let Editor(ByVal vData As String)
    mEditor = vData
 End Property
 Public Property Get Editor() As String
   Editor = mEditor
 End Property
 Public Property Let ID(ByVal vData As Integer)
    mID = vData
 End Property
 Public Property Get ID() As Integer
   ID = mID
 End Property
 
 Public Property Let CSRAssignable(ByVal vData As Boolean)
    mbCSRAssignable = vData
 End Property
 Public Property Get CSRAssignable() As Boolean
   CSRAssignable = mbCSRAssignable
 End Property
 
 Public Property Let SubscriberAssignable(ByVal vData As Boolean)
    mbSubscriberAssignable = vData
 End Property
 Public Property Get SubscriberAssignable() As Boolean
   SubscriberAssignable = mbSubscriberAssignable
 End Property
 
 Public Property Let AllowMultipleInstances(ByVal vData As Boolean)
    mbMultipleInstances = vData
 End Property
 Public Property Get AllowMultipleInstances() As Boolean
   AllowMultipleInstances = mbMultipleInstances
 End Property

Public Property Get GUID() As String
   GUID = mGUID
 End Property

Public Property Let GUID(vData As String)
   mGUID = GUID
 End Property

Public Property Get NumberAtomic() As Integer
   NumberAtomic = mAtomicCaps.Count
 End Property

Public Function CreateInstance() As Object
    Dim cap As Object
    Dim atomictype
    Set cap = CreateObject(mProgID)
    cap.CapabilityType = Me
    'initialize instances of included atomics
    For Each atomictype In mAtomicCaps
      cap.AddAtomicCapability (atomictype.CreateInstance())
    Next
    
    Set CreateInstance = cap
End Function

Public Function Save() As Integer

Dim sel As String
Dim mapping As String
Dim atomicCap
' Dim ID As Integer
Dim insert As String
Dim result As MTSQLRowset
Dim rs As MTSQLRowset
Dim bFound

bFound = False

Dim insertrelation As String

Set rs = NetMeter.Rowset

sel = "SELECT id_cap_type FROM t_composite_capability_type"
sel = sel + " WHERE UPPER(tx_progid)= UPPER('" + Me.ProgID + "')"

Set result = NetMeter.Execute(DebugStr(sel))

If result.EOF = False Then
  bFound = True
  result.MoveFirst
  ID = result.Value(0)
End If

  If HasID(Me) Or bFound = True Then
    'TODO: update case
    'also remove the t_compositor mappings
    mapping = "DELETE FROM t_compositor WHERE id_composite = " + str(Me.ID)
    
    NetMeter.Execute DebugStr(mapping)
  Else
    rs.InitializeForStoredProc ("sp_InsertCompositeCapType")
    rs.AddInputParameterToStoredProc "aGuid", MTParameterType.MTTYPE_VARCHAR, MTParameterDirection.INPUT_PARAM, CreateGUID
    rs.AddInputParameterToStoredProc "aName", MTParameterType.MTTYPE_VARCHAR, MTParameterDirection.INPUT_PARAM, Name
    rs.AddInputParameterToStoredProc "aDesc", MTParameterType.MTTYPE_VARCHAR, MTParameterDirection.INPUT_PARAM, Description
    rs.AddInputParameterToStoredProc "aProgid", MTParameterType.MTTYPE_VARCHAR, MTParameterDirection.INPUT_PARAM, ProgID
    rs.AddInputParameterToStoredProc "aEditor", MTParameterType.MTTYPE_VARCHAR, MTParameterDirection.INPUT_PARAM, Editor
    rs.AddInputParameterToStoredProc "aCSRAssignable", MTParameterType.MTTYPE_VARCHAR, MTParameterDirection.INPUT_PARAM, GetCharFromBool(CSRAssignable)
    rs.AddInputParameterToStoredProc "aSubAssignable", MTParameterType.MTTYPE_VARCHAR, MTParameterDirection.INPUT_PARAM, GetCharFromBool(SubscriberAssignable)
    rs.AddInputParameterToStoredProc "aMultipleInstances", MTParameterType.MTTYPE_VARCHAR, MTParameterDirection.INPUT_PARAM, GetCharFromBool(AllowMultipleInstances)
    rs.AddOutputParameterToStoredProc "ap_id_prop", MTParameterType.MTTYPE_INTEGER, MTParameterDirection.OUTPUT_PARAM
    rs.ExecuteStoredProc
    ID = rs.GetParameterFromStoredProc("ap_id_prop")
  End If
  
  For Each atomicCap In mAtomicCaps
      mapping = " INSERT INTO t_compositor (id_atomic, id_composite, tx_description) VALUES( "
      mapping = mapping + str(atomicCap.ID) + ", " + str(Me.ID) + ", '" + atomicCap.CompositionDescription + "')"
      NetMeter.Execute DebugStr(mapping)
    Next

  Save = ID
End Function

Public Function Init(ByVal aTypeID As Integer)
    ' 1. Read from t_composite_capability_type
    Dim sel As String
    Dim result As MTSQLRowset
    Dim found As Boolean
    Dim atomic As New MTAtomicCapabilityType



    sel = "SELECT id_cap_type, RAWTOHEX(tx_guid), tx_name, tx_desc, tx_progid, tx_editor, csr_assignable, "
    sel = sel + "subscriber_assignable, multiple_instances FROM t_composite_capability_type "
    sel = sel + " WHERE id_cap_type=" + str(aTypeID)

    Set result = NetMeter.Execute(DebugStr(sel))

    found = (result.EOF = False)

    If found = False Then
        'LOGTODO
        Exit Function
    End If
    
    ID = aTypeID
    
    result.MoveFirst
    
    GUID = result.Value(1)
    Name = result.Value(2)
    Description = result.Value(3)
    ProgID = result.Value(4)
    If IsNull(result.Value(5)) Then
      Editor = ""
    Else
      Editor = result.Value(5)
    End If
    
    CSRAssignable = GetBoolFromChar(result.Value(6))
    SubscriberAssignable = GetBoolFromChar(result.Value(7))
    AllowMultipleInstances = GetBoolFromChar(result.Value(8))
    
    '2. read t_compositor

    sel = "SELECT id_atomic, tx_description FROM t_compositor"
    sel = sel + " WHERE id_composite=" + str(aTypeID)
    
    Set result = NetMeter.Execute(DebugStr(sel))
    
    If result.EOF = True Then
      ' no atomics
      Exit Function
    
    End If
    
    result.MoveFirst
    
    While result.EOF = False
        Set atomic = New MTAtomicCapabilityType
        atomic.Init (result.Value(0))
        atomic.CompositionDescription = result.Value(1)
        mAtomicCaps.Add atomic
        result.MoveNext
    Wend

End Function

Public Function InitByName(ByVal aTypeName As String)

    

End Function

Public Function AddAtomicCapabilityType(ByVal aType As MTAtomicCapabilityType, ByVal aCompositionDesc As String)
    
    aType.CompositionDescription = aCompositionDesc
    mAtomicCaps.Add aType

End Function

Public Function GetAtomicCapabilityTypeByName(ByVal aName As String) As MTAtomicCapabilityType
 'Dim cap
 
 Set GetAtomicCapabilityTypeByName = mAtomicCaps.Item(aName)
    
End Function

Public Function GetAtomicCapabilityTypes() As Collection
 'Dim cap
 
 Set GetAtomicCapabilityTypes = mAtomicCaps
    
End Function

Public Function RemoveAtomicCapabilityType(ByVal aType As MTAtomicCapabilityType)
  mAtomicCaps.Remove (aType)
    
End Function


Private Function GetCSRAssignableString() As String
  If mbCSRAssignable = True Then
    GetCSRAssignableString = "Y"
  Else
    GetCSRAssignableString = "N"
  End If

End Function

Private Function GetSubscriberAssignableString() As String
  If mbSubscriberAssignable = True Then
    GetSubscriberAssignableString = "Y"
  Else
    GetSubscriberAssignableString = "N"
  End If

End Function

