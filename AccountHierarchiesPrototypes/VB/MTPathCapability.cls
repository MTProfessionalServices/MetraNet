VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MTPathCapability"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Public Enum WildCard_
  NONE = 0
  CURRENT_FOLDER = 1
  RECURSIVE = 2
End Enum



Private NetMeter As New SQLRowsetWrapper
Private mParentID As Integer
Private mParam As New MTPathParameter

' Add properties that actually live on IMTCapability interface

' fake inheritance by aggregating the 'parent'
Private mAtomicCap As New MTAtomicCapability


Private Sub Class_Initialize()
    NetMeter.InitRowset
    mAtomicCap.ID = -1

End Sub

Private Function GetWildCardTokenFromEnum(aEnum As WildCard_) As String
  Dim ret
  If aEnum = NONE Then
    ret = ""
  Else
    If aEnum = CURRENT_FOLDER Then
      ret = "*"
  Else
    ret = "-"
  End If
  End If
    
  GetWildCardTokenFromEnum = ret
End Function

Private Function GetWildCardTokenFromString(aTok As String) As WildCard_
  Dim ret As WildCard_
  If aTok = "" Then
    ret = NONE
  Else
    If aTok = "*" Then
      ret = CURRENT_FOLDER
  Else
    ret = RECURSIVE
  End If
  End If
  GetWildCardTokenFromString = ret

End Function

Private Function ParseWildCardTokenFromFullString(aPath As String) As WildCard_
  Dim ret As WildCard_
  If InStr(1, aPath, "*", 1) = Len(aPath) Then
    ParseWildCardTokenFromFullString = CURRENT_FOLDER
    Exit Function
  Else
  If InStr(1, aPath, "-", 1) = Len(aPath) Then
    ParseWildCardTokenFromFullString = RECURSIVE
    Exit Function
  Else
    ParseWildCardTokenFromFullString = NONE
    Exit Function
  End If
  End If
End Function

Private Function GetFullString(aPath As MTPathParameter) As String
  Dim ret As String
  ret = aPath.Path
  If aPath.WildCard = NONE Then
    GetFullString = ret
    Exit Function
  Else
  If aPath.WildCard = CURRENT_FOLDER Then
    GetFullString = ret + "/*"
    Exit Function
  Else
    GetFullString = ret + "/-"
    Exit Function
  End If
  End If
End Function

Private Function ParsePurePathFromFullString(aPath As String) As String
  Dim Path As String
  If (Len(aPath) < 3) Then
    ParsePurePathFromFullString = aPath
     Exit Function
  End If
  
  Path = Left(aPath, Len(aPath) - 2)
  If ParseWildCardTokenFromFullString(aPath) = NONE Then
    ParsePurePathFromFullString = aPath
    Exit Function
  Else
    ParsePurePathFromFullString = Path
  End If
End Function

Public Function SetPathParameter(aPath As String, aWildCard As WildCard_)
  mParam.Path = aPath
  mParam.WildCard = aWildCard
End Function

Public Property Get PathParameter() As MTPathParameter
  Set PathParameter = mParam
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
  Dim thatparam As MTPathParameter
  Dim thisparam As MTPathParameter
  Dim match As Boolean
  Dim objPath As New MTHierarchyPath
  
  ' check that the object passed in is of same type
  ' in C++ query for interface
  If (aDemandedCap Is Nothing) Or TypeName(aDemandedCap) <> "MTPathCapability" Then
   Implies = False
   Exit Function
  End If
  ' on demanded cap there will be probably only one path parameter
  ' whereas on possessed cap there could be more then one
  Set thatparam = aDemandedCap.PathParameter
  Set thisparam = Me.PathParameter
  
  objPath.Pattern = GetFullString(thisparam)
  Implies = objPath.Implies(GetFullString(thatparam))
End Function

Public Function Save(ByVal aPolicy As Object)
  Dim query As String
  Dim Principal As String
  Dim param As MTPathParameter
  
  ID = mAtomicCap.Save(aPolicy)
  
  
  'delete previous params first
  If HasID(Me) Then
    query = "DELETE FROM t_path_capability WHERE id_cap_instance=" + str(ID)
    NetMeter.Execute DebugStr(query)
  End If
  
  query = "INSERT INTO t_path_capability VALUES"
  query = query + "(" + str(ID) + ", '" + GetFullString(PathParameter) + "')"
  NetMeter.Execute DebugStr(query)
  
  Save = ID
  
End Function

Public Function Remove(ByVal aPolicy As Object)
  Dim query As String
  'delete previous params first
  If HasID(Me) Then
    query = "DELETE FROM t_path_capability WHERE id_cap_instance=" + str(ID)
    NetMeter.Execute DebugStr(query)
  End If
  mAtomicCap.Remove aPolicy
End Function


Public Function Init(ByVal aPolicy As Object)

  Dim query As String
  Dim Path As String
  Dim Principal As String
  Dim Recordset As MTSQLRowset
  query = "SELECT t_capability_instance.id_cap_instance, param_value FROM t_capability_instance, t_path_capability "
  query = query + "WHERE id_policy = " + str(aPolicy.ID) + " AND id_parent_cap_instance = " + str(mAtomicCap.ParentID)
  query = query + " AND t_capability_instance.id_cap_instance = t_path_capability.id_cap_instance"
  
  Set Recordset = NetMeter.Execute(DebugStr(query))
  
  If Recordset.EOF = True Then
    'error
    Exit Function
  End If
  
  Recordset.MoveFirst
  
  ID = Recordset.Value(0)
  If IsNull(Recordset.Value(1)) Then
    Path = ""
  Else
    Path = Recordset.Value(1)
  End If
  SetPathParameter ParsePurePathFromFullString(Path), ParseWildCardTokenFromFullString(Path)
  
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










