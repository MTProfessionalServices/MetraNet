VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MTAccountHierarchySlice"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit
Private mRefDate As Date
Private mSystemDate As Date ' used for the bitemporal data
Private mBuseBitemporalData As Date
Private mSysDate As Date
Private mRowset As MTSQLRowset
Private mDomNode As IXMLDOMNode
Private mAncestor As Variant
Private mDescendent As Long
Private mLoaded As Boolean

Private Const E_NOTIMPL As Long = &H80004001
Const HIERARCHY_ROOTNODE As Long = 1

Private Sub Class_Initialize()
  Set mAncestor = Nothing
End Sub



' hidden, created by factory class
Public Sub Initialize(Descendent As Long, RefDate As Date)
Attribute Initialize.VB_MemberFlags = "40"
  mDescendent = Descendent
  mRefDate = RefDate
  mLoaded = False
  
End Sub


' hidden, created by factory class
Public Sub InitializeBitemporal(Descendent As Long, RefDate As Date, sysDate As Date)
  mDescendent = Descendent
  Call Err.Raise(E_NOTIMPL, "MTAccountHierarchySlice", "Not Implemented")
End Sub


Public Function GetChildListAsRowset() As MTSQLRowset
  CheckAndLoadData
  Set GetChildListAsRowset = mRowset
End Function


Public Function GetChildListXML() As IXMLDOMNode
  
  ' step : load data if neccesary
  CheckAndLoadData
  
  ' step : return the cached copy if we have it
  If Not mDomNode Is Nothing Then
    Set GetChildListXML = mDomNode
  End If
  
  
  
  ' step : Build the XML object
  Dim aDomDoc As New DOMDocument
  Call aDomDoc.loadXML("<xmlconfig />")
  Dim ParentNode As IXMLDOMNode
  Dim childNode As IXMLDOMNode
  Dim AccIDNode As IXMLDOMNode
  Dim HierarchyNode As IXMLDOMNode
  Dim ObjAttr As IXMLDOMAttribute

  ' create the top level element
  Set mDomNode = aDomDoc.createElement("hierarchy")
  ' set the output value
  Set GetChildListXML = mDomNode

  Set ObjAttr = aDomDoc.createAttribute("bFolder")
  ObjAttr.Value = "Y"
  Call mDomNode.Attributes.setNamedItem(ObjAttr)
  Set ObjAttr = aDomDoc.createAttribute("bChildren")
  
  ' step : check if any data exists or there are children
  If mRowset Is Nothing Or mRowset.RecordCount = 0 Then
    ObjAttr.Value = "N"
  Else
    ObjAttr.Value = "Y"
  End If
  
  Call mDomNode.Attributes.setNamedItem(ObjAttr)
  
  ' create parent node
  Set ParentNode = aDomDoc.createElement("parent_id")
  ParentNode.Text = CStr(mDescendent)
  Call mDomNode.appendChild(ParentNode)
  ' child node
  Set childNode = aDomDoc.createElement("child")
  childNode.Text = "What do I put here?"
  Call mDomNode.appendChild(childNode)
  ' id_acc node
  Set AccIDNode = aDomDoc.createElement("id_acc")
  AccIDNode.Text = CStr(mDescendent)
  Call mDomNode.appendChild(AccIDNode)
  
  ' exit now if we have no children
  If mRowset Is Nothing Or mRowset.RecordCount = 0 Then
    Exit Function
  End If
  
  
  ' iterate through the list of children
  Dim index As Long
  For index = 0 To mRowset.RecordCount - 1
    Set HierarchyNode = aDomDoc.createElement("hierarchy")
    
    Set ObjAttr = aDomDoc.createAttribute("bChildren")
    ObjAttr.Value = mRowset.Value("children")
    Call HierarchyNode.Attributes.setNamedItem(ObjAttr)
    
    Set ObjAttr = aDomDoc.createAttribute("bFolder")
    ObjAttr.Value = mRowset.Value("folder")
    Call HierarchyNode.Attributes.setNamedItem(ObjAttr)
    
    Set ObjAttr = aDomDoc.createAttribute("bPayer")
    If IsNull(mRowset.Value("payer")) Then
      ObjAttr.Value = "N"
    Else
      ObjAttr.Value = "Y"
    End If
    Call HierarchyNode.Attributes.setNamedItem(ObjAttr)
    
    Set ObjAttr = aDomDoc.createAttribute("status")
    ObjAttr.Value = mRowset.Value("status")
    Call HierarchyNode.Attributes.setNamedItem(ObjAttr)
    
    
    Set ParentNode = aDomDoc.createElement("parent_id")
    ParentNode.Text = mRowset.Value("parent_id")
    ParentNode.Text = CStr(mDescendent)
    Call HierarchyNode.appendChild(ParentNode)
    Set childNode = aDomDoc.createElement("child")
    childNode.Text = mRowset.Value("nm_login")
    Call HierarchyNode.appendChild(childNode)
    Set AccIDNode = aDomDoc.createElement("id_acc")
    AccIDNode.Text = mRowset.Value("child_id")
    Call HierarchyNode.appendChild(AccIDNode)
    Call mDomNode.appendChild(HierarchyNode)
    mRowset.MoveNext
  Next
      

End Function


Public Function GetAncestorList() As MTSQLRowset
  Call Err.Raise(E_NOTIMPL, "MTAccountHierarchySlice", "Not Implemented")
End Function

Public Function HierarchyPath() As String
  Call Err.Raise(E_NOTIMPL, "MTAccountHierarchySlice", "Not Implemented")

End Function


Public Property Get Item(vntKey As Variant) As MTAccountHierarchySlice
  Call Err.Raise(E_NOTIMPL, "MTAccountHierarchySlice", "Not Implemented")

End Property

Public Property Get Count() As Long

  CheckAndLoadData
  If Not mRowset Is Nothing Then
    Count = mRowset.RecordCount
  Else
    Count = 0
  End If
End Property


Public Property Get NewEnum() As IUnknown
  Call Err.Raise(E_NOTIMPL, "MTAccountHierarchySlice", "Not Implemented")
End Property

Public Function FindChild(Descendent As Integer, Optional Depth As Integer) As MTAccountHierarchySlice
  Call Err.Raise(E_NOTIMPL, "MTAccountHierarchySlice", "Not Implemented")
End Function



Public Property Get Parent() As Long

  LoadParent

  ' special case the root node
  Parent = mAncestor

End Property

Public Property Get CurrentNodeID() As Long
  CurrentNodeID = mDescendent
End Property


Public Function GetParentSlice() As MTAccountHierarchySlice
  Dim parentSlice As New MTAccountHierarchySlice
  
  
End Function



'===========================================================================
' private methods
'===========================================================================


Private Sub LoadData()
  
  ' put a lock around this thank you very much
  Set mRowset = Nothing
  Set mDomNode = Nothing
  Dim prettyDate
  
  ' always reload
  Dim Rs As New MTSQLRowset
  Rs.Init ("queries\AccHierarchies")
  Rs.SetQueryTag "__LOAD_HIERACHY_LEVEL__"
  Rs.AddParam "%%ANCESTOR%%", mDescendent
  ' XXX fix this to use the correct dates!! mRefDate
  prettyDate = Format(mRefDate, "YYYY-MM-DD HH:MM:SS")
  Rs.AddParam "%%REF_DATE%%", prettyDate
  Rs.Execute
  
  
  
  Set mRowset = Rs
  mLoaded = True

End Sub


Private Sub CheckAndLoadData()

  If Not mLoaded Then
    LoadData
  End If
End Sub


Private Sub LoadParent()
    
  If mAncestor Is Nothing Then
    ' special case the root node
    If mDescendent = HIERARCHY_ROOTNODE Then
      mAncestor = HIERARCHY_ROOTNODE
    End If
    
    Dim Rs As New MTSQLRowset
    Rs.Init "queries\AccHierarchies"
    Rs.SetQueryTag "__FIND_HIERARCHY_PARENT__"
    Rs.AddParam "%%DESCENDENT%%", mDescendent
    ' XXX fix this to use the correct date!!
    Rs.AddParam "%%REF_DATE%%", Format(mRefDate, "YYYY-MM-DD HH:MM:SS")
    Rs.Execute
    If Not Rs.EOF Then
      mAncestor = Rs.Value(0)
    Else
      mAncestor = "1"
    End If
  End If

End Sub
