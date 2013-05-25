VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CPCViewManager"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private m_PCTree As TreeView

Private m_objMTProductCatalog As MTProductCatalog

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
    Dim ii              As Long
    Dim Arr             As Variant
    Dim ArrIns          As Variant
    Dim PONode          As Node
    Dim PO              As MTProductOffering
    Dim PINS            As MTPriceableItem
    
'    Debug.Assert 0
    
    strPOsString = GetPOsString()
    Arr = Split(strPOsString, ",")
    
    For i = 0 To UBound(Arr) Step 2
    
        Set PONode = AddNode("", Arr(i + 1), Arr(i), "PO")
        Set PO = Me.ProductCatalog.GetProductOffering(Arr(i + 1))
        
        AddNode MakeID(Arr(i + 1)), MakeID(Arr(i + 1)) + ".Properties", "Properties", "Property"
        AddMTProperties PO, MakeID(Arr(i + 1)) + ".Properties"
        
        AddNode MakeID(Arr(i + 1)), MakeID(Arr(i + 1)) + ".Instances", "Instances", "Property"
        ArrIns = Split(GetPOInstancesString(PO), ",")
        For ii = 0 To UBound(ArrIns) Step 2
        
            AddNode MakeID(Arr(i + 1)) + ".Instances", MakeID(ArrIns(ii + 1)), ArrIns(ii), "Property"
            Set PINS = PO.GetPriceableItem(ArrIns(ii + 1))
            AddMTProperties PINS, MakeID(ArrIns(ii + 1))
        Next
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




Private Function GetPOInstancesString(ProductOffering As MTProductOffering) As String

    Dim Rowset As IMTRowSet
    Dim strTmp As String
        
    Set Rowset = ProductOffering.GetPriceableItemsAsRowset()
        
    Do While Not Rowset.EOF
        strTmp = strTmp & Rowset.Value("nm_name") & "," & Rowset.Value("id_prop") & ","
        Rowset.MoveNext
    Loop
    If Len(strTmp) Then
        strTmp = Mid(strTmp, 1, Len(strTmp) - 1)
    End If
    GetPOInstancesString = strTmp
End Function

Private Function AddNode(ByVal strParentKey As String, ByVal strKey As String, ByVal strText As String, ByVal strIcon As String) As Node
    strKey = MakeID(strKey)
    If strParentKey = "" Then
        Set AddNode = m_PCTree.Nodes.Add(, tvwChild, strKey, strText, strIcon)
    Else
        Set AddNode = m_PCTree.Nodes.Add(strParentKey, tvwChild, strKey, strText, strIcon)
    End If
End Function

Private Function AddMTProperties(MTObject As Object, ByVal strParentKey As String) As Boolean

    Dim Property                As MTProperty
    Dim SubMTObject             As Object
    
    For Each Property In MTObject.Properties
    
        If Property.DataTypeAsString = "object" Then
        
            If Property.Name <> "UnitValueEnumeration" Then
                Set SubMTObject = Property.Value
                
                If TypeName(SubMTObject) = "IMTPCTimeSpan" Then
                
                    AddNode strParentKey, strParentKey & "." & Property.Name, Property.Name, "Property"
                    AddMTProperties SubMTObject, strParentKey & "." & Property.Name
                End If
            End If
        Else
            AddNode strParentKey, strParentKey & "." & Property.Name, Property.Name & ":" & Property.Value, "Property"
        End If
    Next
End Function
