VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MTAncestorMgr"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Private mSessionContext As MTSessionContext

Const HIERARCHY_ROOTNODE As Long = 1
Private Const E_NOTIMPL As Long = &H80004001
Private Const E_FAIL As Long = &H80004005



' should be hidden.... the ancestor manager should be
' created by the YAAC
Public Sub Initialize(context As MTSessionContext)
    Set mSessionContext = context
End Sub

Public Function HierarchySlice(ByVal Ancestor As Long, ByVal RefDate As Date) As MTAccountHierarchySlice
  Dim slice As New MTAccountHierarchySlice
  slice.Initialize Ancestor, RefDate
  Set HierarchySlice = slice

End Function

Public Function HierarchySliceNow(ByVal Ancestor As Long) As MTAccountHierarchySlice
    Set HierarchySliceNow = HierarchySlice(Ancestor, Now)
End Function

Public Function HierarchySliceAtSystemDate(ByVal Ancestor As Long, ByVal RefDate As Date, ByVal SystemDate As Date) As MTAccountHierarchySlice
  Dim slice As New MTAccountHierarchySlice
  slice.InitializeBitemporal Ancestor, RefDate, SystemDate
  Set HierarchySliceAtSystemDate = slice
End Function


Public Function HierarchyRoot(ByVal RefDate As Date) As MTAccountHierarchySlice

  ' should be a capability check here to filter out the corporate hierarchies
  ' that the user can manage.
  Dim slice As New MTAccountHierarchySlice
  slice.Initialize HIERARCHY_ROOTNODE, RefDate
  Set HierarchyRoot = slice

End Function

Public Function HierarchyRootAtSystemDate(ByVal RefDate As Date, ByVal SystemDate As Date) As MTAccountHierarchySlice
  Dim slice As New MTAccountHierarchySlice
  slice.InitializeBitemporal HIERARCHY_ROOTNODE, RefDate, SystemDate
  Set HierarchyRootAtSystemDate = slice
End Function


Public Sub MoveAccount(ByVal NewAncestor As Long, ByVal Descendent As Long, ByVal StartDate As Date)
  Dim Rs As New MTSQLRowset
  Dim status As Long
  Rs.Init "queries\\AccHierarchies"
  Rs.SetQueryString "queries\\AccHierarchies"

  Rs.InitializeForStoredProc "MoveAccount"
  Rs.AddInputParameterToStoredProc "p_id_ancestor", MTTYPE_INTEGER, INPUT_PARAM, NewAncestor
  Rs.AddInputParameterToStoredProc "p_id_descendent", MTTYPE_INTEGER, INPUT_PARAM, Descendent
  Rs.AddInputParameterToStoredProc "p_dt_start", MTTYPE_DATE, INPUT_PARAM, StartDate
  Rs.AddOutputParameterToStoredProc "status", MTTYPE_INTEGER, OUTPUT_PARAM
  Rs.ExecuteStoredProc
  status = Rs.GetParameterFromStoredProc("status")
  If status <> 1 Then
    Call Err.Raise(status, "MTAncestorMgr", "Failed to move account in hierarchy")
  End If
  
End Sub

Public Sub MoveAccountColllection(ByVal Ancestor As Long, ByVal ChildrenList As Object, ByVal StartDate As Date)
  Call Err.Raise(E_NOTIMPL, "MTAncestorMgr", "Not Implemented")
End Sub


Public Sub AddToHierarchy(ByVal Ancestor As Long, ByVal Descendent As Long, ByVal StartDate As Date, ByVal EndDate As Date)

  Dim Rs As New MTSQLRowset
  
  Dim paramType As MTRowsetEnumsLib.COM_MTMTParameterType
  Dim direction As MTRowsetEnumsLib.COM_MTParameterDirection
  Dim status As Long
  
  Rs.Init "queries\\AccHierarchies"
  Rs.SetQueryString "queries\\AccHierarchies"
  Rs.InitializeForStoredProc "AddAccToHierarchy"
  paramType = MTTYPE_INTEGER
  direction = INPUT_PARAM
  Rs.AddInputParameterToStoredProc "p_id_ancestor", paramType, direction, Ancestor
  Rs.AddInputParameterToStoredProc "p_id_descendent", paramType, direction, Descendent
  paramType = MTTYPE_DATE
  Rs.AddInputParameterToStoredProc "p_dt_start", paramType, direction, StartDate
  Rs.AddInputParameterToStoredProc "p_dt_end", paramType, direction, EndDate
  Rs.AddOutputParameterToStoredProc "status", MTTYPE_INTEGER, OUTPUT_PARAM
  Rs.ExecuteStoredProc
  status = Rs.GetParameterFromStoredProc("status")
  
  ' XXX need to check the status code here to detect other errors like
  ' account is already in the hierarchy
  
  If status <> 1 Then
    Dim rcd As New MTRcd
    Call Err.Raise(status, "MTAncestorMgr", rcd.ErrorMessage(status))
  End If


End Sub


Public Sub SetRelationshipEffectiveDate(ByVal Ancestor As Long, ByVal Descendent As Long, ByVal StartDate As Date, ByVal EndDate As Date)
  Call Err.Raise(E_NOTIMPL, "MTAncestorMgr", "Not Implemented")
End Sub


' XXX What does this method do??
Public Sub HierarchySliceHistory(ByVal Descendent As Long, ByVal StartDate As Date, ByVal EndDate As Date)
  Call Err.Raise(E_NOTIMPL, "MTAncestorMgr", "Not Implemented")
End Sub

Public Function GetAllParents() As MTSQLRowset
  Call Err.Raise(E_NOTIMPL, "MTAncestorMgr", "Not Implemented")

End Function




