VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CPCView"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private m_PCTree As TreeView

Public Function Initialize(PCTree As TreeView) As Boolean
    Set m_PCTree = PCTree
    Initialize = True
End Function

Public Property Get ProductCatalog() As MTProductCatalog

    If Not IsValidObject(m_objMTProductCatalog) Then
        Set m_objMTProductCatalog = CreateObject("MetraTech.MTProductCatalog")
    End If
    Set ProductCatalog = m_objMTProductCatalog
End Property


Public Function Load() As Boolean

    m_PCTree.Nodes.Clear
    
    Dim strPOsString    As String
    Dim i               As Long
    Dim arr             As Variant
    
    strPOsString = GetPOsString()
    arr = Split(strPOsString, ",")
    
    For i = 0 To UBound(arr) Step 2
        Set PONode = AddNode("", arr(i + 1), arr(i), "PO")
    Next
    Load = True
End Function

Private Function GetPOsString() As String

    Dim Rowset As IMTRowSet
    Dim strTmp As String
        
    Set Rowset = ProductCatalog.FindProductOfferingsAsRowset()
        
    Do While Not Rowset.EOF
        strTmp = strTmp & Rowset.Value("nm_name") & "," & Rowset.Value("id_prop") & ","
        Rowset.MoveNext
    Loop
    If Len(strTmp) Then
        strTmp = Mid(strTmp, 1, Len(strTmp) - 1)
    End If
    GetPOsString = strTmp
End Function

Private Function AddNode(strParentKey As String, strKey As String, strText As String, strIcon As String) As Node
    Set AddNode = m_PCTree.Nodes.Add(strParentKey, , strKey, strText, strIcon)
End Function
