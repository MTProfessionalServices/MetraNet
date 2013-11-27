VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MTProductOffering"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Attribute VB_Ext_KEY = "SavedWithClassBuilder6" ,"Yes"
Attribute VB_Ext_KEY = "Top_Level" ,"Yes"
'// ----------------------------------------------------------------
'//Object: MTProductOffering
'// Description: Subscribable grouping of Priceable items.
'// ----------------------------------------------------------------

Option Explicit

'=== public properties ======================================================

'// ----------------------------------------------------------------
'// Property:    EffectiveDate
'// Description: time span during which this product offering is effective
Public EffectiveDate As New MTTimeSpan

'// ----------------------------------------------------------------
'// Property:    AvailabilityDate
'// Description: time span durng which this product offering is available for
'//              subscription
Public AvailabilityDate As New MTTimeSpan

'// ----------------------------------------------------------------
'// Method:      <<accessor>> Properties
'// Description: Interface to get all (core and extended) properties of this PI
'//              by name or collection.
'// Returns:     MTProperties
Public Properties As New MTProperties


'=== internal properties ====================================================

'// ----------------------------------------------------------------
'// Property:    PreviousProductOffering
'// Description: product offering that this one is a version of
'//              (basically a linked list of product offerings)
Private mPreviousProductOfferingID As Long


' priceable items contained in this product offering
Private mPriceableItems As New Collection

Public ProdCat_ As MTProductCatalog

'=== public methods =========================================================

'// ----------------------------------------------------------------
'// Property:    ID
'// Description: unique ID of this product offering
Public Property Get ID() As Long
    ID = Properties.Item("ID").Value
End Property
Public Property Let ID(ByVal val As Long)
    Properties.Item("ID").Value = val
End Property

'// ----------------------------------------------------------------
'// Property:    Name
'// Description: name as referenced inside of the Product Catalog
Public Property Get Name() As String
    Name = Properties.Item("Name").Value
End Property
Public Property Let Name(ByVal val As String)
    Properties.Item("Name").Value = val
End Property

'// ----------------------------------------------------------------
'// Property:    DisplayName
'// Description: name as shown to the user in other applications
Public Property Get DisplayName() As String
    DisplayName = Properties.Item("DisplayName").Value
End Property
Public Property Let DisplayName(ByVal val As String)
    Properties.Item("DisplayName").Value = val
End Property

'// ----------------------------------------------------------------
'// Property:    Description
Public Property Get Description() As String
    Description = Properties.Item("Description").Value
End Property
Public Property Let Description(ByVal val As String)
    Properties.Item("Description").Value = val
End Property

'// ----------------------------------------------------------------
'// Property:    SelfSubscribable
'// Description: if true, users can self subscribe to this product offering.
Public Property Get SelfSubscribable() As Boolean
    SelfSubscribable = Properties.Item("SelfSubscribable").Value
End Property
Public Property Let SelfSubscribable(ByVal val As Boolean)
    Properties.Item("SelfSubscribable").Value = val
End Property

'// ----------------------------------------------------------------
'// Property:    SelfUnsubscribable
'// Description: if true, users can self unsubscribe to this product offering.
Public Property Get SelfUnsubscribable() As Boolean
    SelfUnsubscribable = Properties.Item("SelfUnsubscribable").Value
End Property
Public Property Let SelfUnsubscribable(ByVal val As Boolean)
    Properties.Item("SelfUnsubscribable").Value = val
End Property


'// ----------------------------------------------------------------
'// Method:      Save
'// Description: Saves modification to this PO to database.
Public Sub Save()
End Sub

'// ----------------------------------------------------------------
'// Method:      CreateNewVersion
'// Description: Create a new product offering with the values of this PO.
'// Returns:     the new ProductOffering
Public Function CreateNewVersion() As MTProductOffering
    Dim newProdOff As MTProductOffering
    Set newProdOff = ProdCat_.CreateProductOffering
    newProdOff.CopyFrom_ Me
    Set CreateNewVersion = newProdOff
End Function

'// ----------------------------------------------------------------
'// Method:      AddPriceableItem
'// Description: add a PriceableItem template (of any kind) to this PO.
'//              NOTE: only in memory.  Use Save to save changes.
'//              The priceable item is a "clone" of the template passed in.
'//              All properties are initially the same.
'// Arguments:   templatePrcItemID – ID of original (template) PriceableItem
'// Returns:     the new instance PriceableItem
Public Function AddPriceableItem(ByVal templatePrcItemID As Long) As Object
    Dim pi As Object

    Set pi = ProdCat_.GetPriceableItem(templatePrcItemID).Clone_
    
    'prod off is the owner
    pi.ProdOff_ = Me
    ProdCat_.RemovePriceableItem (pi.ID)
    mPriceableItems.Add pi
    
    Set AddPriceableItem = pi
End Function


'// ----------------------------------------------------------------
'// Method:      RemovePriceableItem
'// Description: remove a PriceableItem instance (of any kind) from this PO
'// Arguments:   ID – ID of the priceableItem
Public Sub RemovePriceableItem(ByVal ID As Long)
    Dim i As Integer
    For i = 1 To mPriceableItems.Count()
        If mPriceableItems.Item(i).ID = ID Then
            mPriceableItems.Remove i
            Exit For
        End If
    Next
End Sub

'// ----------------------------------------------------------------
'// Method:      GetPriceableItem
'// Description: get a PriceableItem of this PO by its ID
'// Arguments:   ID – ID of the PriceableItem
'// Returns:     the PriceableItem or NULL if not found
Public Function GetPriceableItem(ByVal ID As Long) As Object
    Dim pi As Object
    For Each pi In mPriceableItems
        If pi.ID = ID Then
            Set GetPriceableItem = pi
            Exit For
        End If
    Next
End Function

'// ----------------------------------------------------------------
'// Method:      GetPriceableItemByName
'// Description: get a PriceableItem of this PO by its Name
'// Arguments:   Name – Name of the PriceableItem
'// Returns:     the PriceableItem or NULL if not found
Public Function GetPriceableItemByName(ByVal Name As String) As Object
    'Dim pi As Object
    'For Each pi In mPriceableItems
    '    If pi.Name = Name Then
    '        Set GetPriceableItemByName = pi
    '        Exit For
    '    End If
    'Next
    
    
    Dim foundPI As Object
    Dim pi As Object
    For Each pi In mPriceableItems
    
        If pi.Name = Name Then
            Set foundPI = pi
            Exit For
        Else
            Set foundPI = GetNestedPriceableItemByName(pi, Name)
            If Not foundPI Is Nothing Then
                Exit For
            End If
        End If
    Next
    
    'If foundPI Is Nothing Then
    '    Set foundPI = GetPriceableItemInstance(ID)
    'End If
    
    Set GetPriceableItemByName = foundPI

End Function

Public Function GetNestedPriceableItemByName(ByVal parent As Object, ByVal Name As String) As Object
    Dim pi As Object
    
    Set pi = parent.GetChildByName(Name)
    
    If pi Is Nothing Then
        Dim child As Object
        For Each child In parent.GetChildren
            Set pi = GetNestedPriceableItemByName(child, Name)
            If Not pi Is Nothing Then
                Exit For
            End If
        Next
    End If
    
    Set GetNestedPriceableItemByName = pi
End Function

'// ----------------------------------------------------------------
'// Method:      GetPriceableItems
'// Description: get all PriceableItems of this PO
'// Returns:     Collection of PriceableItems
Public Function GetPriceableItems() As Collection
    Set GetPriceableItems = mPriceableItems
End Function

'// ----------------------------------------------------------------
'// Method:      GetPriceableItemsAsRowset
'// Description: return a rowset of priceable items
'// Returns:     an IMTSQLRowset
Public Function GetPriceableItemsAsRowset() As IMTSQLRowset
    
    Dim rowset As IMTSQLRowset
    Set rowset = CreateObject("MTSQLRowset.MTSQLRowset.1")
    rowset.InitDisconnected

    ' add meta data for all fields
    Dim meta As MTPropertyMetaData
    For Each meta In ProdCat_.GetUsageChargeMetaData
        rowset.AddColumnDefinition meta.DBColumnName, meta.DataType, meta.Length
    Next

    ' fill rowset
    rowset.OpenDisconnected

    Dim pi As Object
    For Each pi In GetPriceableItems
        rowset.AddRow
        For Each meta In ProdCat_.GetUsageChargeMetaData
            On Error Resume Next
            rowset.AddColumnData meta.DBColumnName, pi.Properties.Item(meta.Name).Value
            On Error GoTo 0
        Next
    Next
    Set GetPriceableItemsAsRowset = rowset
End Function


'=== internal methods =======================================================
Private Sub Class_Initialize()
    
    'add properties
    Dim propMeta    As MTPropertyMetaData
    Dim attrMeta    As MTAttributeMetaData
    Dim prop        As MTProperty
    Dim attr        As MTAttribute
   
    ' create a property for each property meta data
    For Each propMeta In ProductOfferingMetaDataCollection
    
        Set prop = Properties.Add(propMeta)
            
        'create an attribute for each attribute meta data
        For Each attrMeta In AttributeMetaDataCollection
        
            Set attr = prop.Attributes.Add(attrMeta)
        Next
    Next
    
    Set Properties.Item("EffectiveDate").Value = Me.EffectiveDate
    Set Properties.Item("AvailabilityDate").Value = Me.AvailabilityDate
End Sub

Public Sub CopyFrom_(po As MTProductOffering)
    ' copy all properties, pis, pl mappings, ...
    Name = po.Name

    ' update linked list
    mPreviousProductOfferingID = po.ID
End Sub

