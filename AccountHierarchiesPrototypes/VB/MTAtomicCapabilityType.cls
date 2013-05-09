VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MTAtomicCapabilityType"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Private NetMeter As New SQLRowsetWrapper
Private mID As Integer
Private mName As String
Private mDesc As String
Private mCompositionDesc As String
Private mProgID As String
Private mEditor As String
Private mAtomicCaps As New Collection
     


Private Sub Class_Initialize()
    NetMeter.InitRowset
    ID = -1
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
 Public Property Let CompositionDescription(ByVal vData As String)
    mCompositionDesc = vData
 End Property
 Public Property Get CompositionDescription() As String
   CompositionDescription = mCompositionDesc
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

Public Function CreateInstance() As Object
    Dim cap As Object
    Set cap = CreateObject(mProgID)
    cap.CapabilityType = Me
    Set CreateInstance = cap
End Function

Public Function Save() As Integer

' 1. see if record for this type is already in t
't_atomic_capability_type
'if not, insert it there, if yes, just get the ID
Dim sel As String
Dim atomicCap
' Dim ID As Integer
Dim insert As String
Dim result As MTSQLRowset
Dim rs As MTSQLRowset
Dim bFound

bFound = False

Dim insertrelation As String

Set rs = NetMeter.Rowset

sel = "SELECT id_cap_type FROM t_atomic_capability_type"
sel = sel + " WHERE UPPER(tx_progid)= UPPER('" + Me.ProgID + "')"

Set result = NetMeter.Execute(DebugStr(sel))

If result.EOF = False Then
  bFound = True
  result.MoveFirst
  ID = result.Value(0)
End If

If HasID(Me) Or bFound = True Then
  'TODO: update case
Else
  rs.InitializeForStoredProc ("sp_insertAtomiccaptype")
  rs.AddInputParameterToStoredProc "aGuid", MTParameterType.MTTYPE_VARCHAR, MTParameterDirection.INPUT_PARAM, CreateGUID
  rs.AddInputParameterToStoredProc "aName", MTParameterType.MTTYPE_VARCHAR, MTParameterDirection.INPUT_PARAM, Name
  rs.AddInputParameterToStoredProc "aDesc", MTParameterType.MTTYPE_VARCHAR, MTParameterDirection.INPUT_PARAM, Description
  rs.AddInputParameterToStoredProc "aProgid", MTParameterType.MTTYPE_VARCHAR, MTParameterDirection.INPUT_PARAM, ProgID
  rs.AddInputParameterToStoredProc "aEditor", MTParameterType.MTTYPE_VARCHAR, MTParameterDirection.INPUT_PARAM, Editor
  rs.AddOutputParameterToStoredProc "ap_id_prop", MTParameterType.MTTYPE_INTEGER, MTParameterDirection.OUTPUT_PARAM
  rs.ExecuteStoredProc
  
  ID = rs.GetParameterFromStoredProc("ap_id_prop")
  
End If

Save = ID


End Function




Public Function Init(ByVal aTypeID As Integer)
    ' 1. Read from t_atomic_capability_type
    Dim sel As String
    Dim result As MTSQLRowset
    Dim found As Boolean
    Dim atomic As New MTAtomicCapabilityType
    
  

    sel = "SELECT * FROM t_atomic_capability_type "
    sel = sel + " WHERE id_cap_type=" + str(aTypeID)

    Set result = NetMeter.Execute(DebugStr(sel))

    found = (result.EOF = False)

    If found = True Then
    
      ID = aTypeID
    
      result.MoveFirst
      'GUID = result.Value(1)
      Name = result.Value(2)
      Description = result.Value(3)
      ProgID = result.Value(4)
      If IsNull(result.Value(5)) Then
        Editor = ""
      Else
        Editor = result.Value(5)
      End If

    End If
    

End Function

