VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MTProductCatalog"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Attribute VB_Ext_KEY = "SavedWithClassBuilder6" ,"Yes"
Attribute VB_Ext_KEY = "Top_Level" ,"Yes"
'// ----------------------------------------------------------------
'// Object: MTProductCatalog
'// Description: Top level interface to the product catalog
'// ----------------------------------------------------------------
Option Explicit

Const USEDATABASE As Boolean = False

'=== public properties ======================================================

'// ----------------------------------------------------------------
'// Property:    ChainSubscriptionToProductOffering
'// Description: if true, subscription/ICB pricelists should chain to product
'//              offering pricelists
Public ChainSubscriptionToProductOffering As Boolean

'// ----------------------------------------------------------------
'// Property:    ChainProductOfferingToDefault
'// Description: if true, product offering pricelists should chain to default
'//              account pricelists
Public ChainProductOfferingToDefault As Boolean

'=== internal properties ====================================================

'=== public methods =========================================================

'// ----------------------------------------------------------------
'// Method:      GetUsageChargeMetaData
'// Description: returns the meta data for core and extended properties of
'//              a UsageCharge
'// Returns:     Collection of MTPropertyMetaData
Public Function GetUsageChargeMetaData() As Collection
    Set GetUsageChargeMetaData = Globals.UsageMetaDataCollection
End Function

'// ----------------------------------------------------------------
'// Method:      GetRecurringChargeMetaData
'// Description: returns the meta data for core and extended properties of
'//              a RecurringCharge
'// Returns:     Collection of MTPropertyMetaData
Public Function GetRecurringChargeMetaData() As Collection
    Set GetRecurringChargeMetaData = Globals.RecurringChargeMetaDataCollection
End Function

'// ----------------------------------------------------------------
'// Method:      GetNonRecurringChargeMetaData
'// Description: returns the meta data for core and extended properties of
'//              a NonRecurringCharge
'// Returns:     Collection of MTPropertyMetaData
Public Function GetNonRecurringChargeMetaData() As Collection
    Set GetNonRecurringChargeMetaData = Globals.NonRecurringChargeMetaDataCollection
End Function

'// ----------------------------------------------------------------
'// Method:      GetDiscountMetaData
'// Description: returns the meta data for core and extended properties of
'//              a Discount
'// Returns:     Collection of MTPropertyMetaData
Public Function GetDiscountMetaData() As Collection
    Set GetDiscountMetaData = Globals.DiscountMetaDataCollection
End Function

'// ----------------------------------------------------------------
'// Method:      GetProductOfferingMetaData
'// Description: returns the meta data for core and extended properties of
'//              a ProductOffering
'// Returns:     Collection of MTPropertyMetaData
Public Function GetProductOfferingMetaData() As Collection
    Set GetProductOfferingMetaData = Globals.ProductOfferingMetaDataCollection
End Function

'// ----------------------------------------------------------------
'// Method:      GetPriceListMetaData
'// Description: returns the meta data for core and extended properties of
'//              a PriceList
'// Returns:     Collection of MTPropertyMetaData
Public Function GetPriceListMetaData() As Collection
    Set GetPriceListMetaData = Globals.PriceListMetaDataCollection
End Function

'// ----------------------------------------------------------------
'// Method:      GetAttributeMetaData
'// Description: returns the meta data for the (core) Attributes
'// Returns:     Collection of MTAttributeMetaData
Public Function GetAttributeMetaData() As Collection
    Set GetAttributeMetaData = Globals.AttributeMetaDataCollection
End Function

'// ----------------------------------------------------------------
'// Method:      CreateUsageCharge
'// Description: creates a new UsageCharge template. A subsequent
'//              UsageCharge::Save() will insert it into the database.
'// Returns:     the new UsageCharge
Public Function CreateUsageCharge() As MTUsageCharge
    Dim pi As New MTUsageCharge
    pi.Kind = PI_TYPE_USAGE
    pi.ID = NextID()
    pi.ProdCat_ = Me
        
    PriceableItems_.Add pi
    Set CreateUsageCharge = pi
End Function

'// ----------------------------------------------------------------
'// Method:      CreateRecurringCharge
'// Description: creates a new RecurringCharge template. A subsequent
'//              RecurringCharge::Save() will insert it into the database.
'// Returns:     the new RecurringCharge
Public Function CreateRecurringCharge() As MTRecurringCharge
    Dim rc As New MTRecurringCharge
    rc.Kind = PI_TYPE_RECURRING
    rc.ID = NextID()
    rc.ProdCat_ = Me
        
    PriceableItems_.Add rc
    Set CreateRecurringCharge = rc
End Function

'// ----------------------------------------------------------------
'// Method:      CreateNonRecurringCharge
'// Description: creates a new NonRecurringCharge template. A subsequent
'//              MTNonRecurringCharge::Save() will insert it into the database.
'// Returns:     the new NonRecurringCharge
Public Function CreateNonRecurringCharge() As MTNonRecurringCharge
    Dim pi As New MTNonRecurringCharge
    pi.Kind = PI_TYPE_NON_RECURRING
    pi.ID = NextID()
    pi.ProdCat_ = Me
        
    PriceableItems_.Add pi
    Set CreateNonRecurringCharge = pi
End Function

'// ----------------------------------------------------------------
'// Method:      CreateDiscount
'// Description: creates a new Discount template. A subsequent
'//              MTDiscount::Save() will insert it into the database.
'// Returns:     the new Discount
Public Function CreateDiscount() As MTDiscount
    Dim pi As New MTDiscount
    pi.Kind = PI_TYPE_DISCOUNT
    pi.ID = NextID()
    pi.ProdCat_ = Me
        
    PriceableItems_.Add pi
    Set CreateDiscount = pi
End Function

'// ----------------------------------------------------------------
'// Method:      CreateProductOffering
'// Description: creates a new ProductOffering. A subsequent
'//              MTProductOffering::Save() will insert it into the database.
'// Returns:     the new ProductOffering
Public Function CreateProductOffering() As MTProductOffering
    Dim po As New MTProductOffering
    po.ID = NextID()
    Set po.ProdCat_ = Me
    
    ProductOfferings_.Add po
    Set CreateProductOffering = po
End Function

'// ----------------------------------------------------------------
'// Method:      CreatePriceList
'// Description: creates a new PriceList. A subsequent
'//              MTPriceList::Save() will insert it into the database.
'// Returns:     the new PriceList
Public Function CreatePriceList() As MTPriceList
    Dim pl As New MTPriceList
    pl.ID = NextID()
    
    PriceLists_.Add pl
    Set CreatePriceList = pl
End Function

'// ----------------------------------------------------------------
'// Method:      CreateParamTableDefinition
'// Description: creates a new ParamTableDefinition. A subsequent
'//              MTParamTableDefinition::Save() will insert it into the
'//              database.
'// Returns:     the new ParamTableDefinition
Public Function CreateParamTableDefinition() As MTParamTableDefinition
    Dim ptd As New MTParamTableDefinition
    ptd.ID = NextID()
    
    ParamTableDefinitions_.Add ptd
    Set CreateParamTableDefinition = ptd
End Function

'// ----------------------------------------------------------------
'// Method:      CreateAccountReference
'// Description: creates a new AccountReference. A subsequent
'//              MTAccountReference::Save() will insert it into the database.
'// Arguments:   acctID – ID of account this reference refers to.
'// Returns:     the new AccountReference
Public Function CreateAccountReference(ByVal acctID As Long) As MTAccountReference
    Dim acct As New MTAccountReference
    acct.AccountID = acctID
    Set acct.ProdCat_ = Me
    
    AccountReferences_.Add acct
    Set CreateAccountReference = acct
End Function

'// ----------------------------------------------------------------
'// Method:      RemovePriceableItem
'// Description: remove a PriceableItem (of any kind) from the database.
'// Arguments:   ID – ID of the priceableItem
Public Sub RemovePriceableItem(ByVal ID As Long)
    Dim i As Integer
    For i = 1 To PriceableItems_.Count()
        If PriceableItems_.Item(i).ID = ID Then
           PriceableItems_.Remove i
           Exit For
        End If
    Next
End Sub

'// ----------------------------------------------------------------
'// Method:      RemoveProductOffering
'// Description: remove a ProductOffering from the database.
'// Arguments:   ID – ID of the ProductOffering
Public Sub RemoveProductOffering(ByVal ID As Long)
'TODO
End Sub

'// ----------------------------------------------------------------
'// Method:      RemovePriceList
'// Description: remove a PriceList from the database.
'// Arguments:   ID – ID of the PriceList
Public Sub RemovePriceList(ByVal ID As Long)
'TODO
End Sub

'// ----------------------------------------------------------------
'// Method:      RemoveParamTableDefinition
'// Description: remove a ParamTableDefinition from the database.
'// Arguments:   ID – ID of the ParamTableDefinition
Public Sub RemoveParamTableDefinition(ByVal ID As Long)
'TODO
End Sub

'// ----------------------------------------------------------------
'// Method:      RemoveAccountReference
'// Description: remove a AccountReference from the database.
'// Arguments:   ID – ID of the AccountReference
Public Sub RemoveAccountReference(ByVal ID As Long)
'TODO
End Sub

'// ----------------------------------------------------------------
'// Method:      GetPriceableItem
'// Description: finds a PriceableItem (of any kind) by its ID
'// Arguments:   ID – ID of the PriceableItem
'// Returns:     the PriceableItem or NULL if not found
Public Function GetPriceableItem(ByVal ID As Long) As Object
    Dim foundPI As Object
    Dim pi As Object
    For Each pi In PriceableItems_
    
        If pi.ID = ID Then
            Set foundPI = pi
            Exit For
        Else
            Set foundPI = GetNestedPriceableItem(pi, ID)
            If Not foundPI Is Nothing Then
                Exit For
            End If
        End If
    Next
    
    If foundPI Is Nothing Then
        Set foundPI = GetPriceableItemInstance(ID)
    End If
    
    Set GetPriceableItem = foundPI
End Function

Public Function GetNestedPriceableItem(ByVal parent As Object, ByVal ID As Long) As Object
    Dim pi As Object
    
    Set pi = parent.GetChild(ID)
    
    If pi Is Nothing Then
        Dim child As Object
        For Each child In parent.GetChildren
            Set pi = GetNestedPriceableItem(child, ID)
            If Not pi Is Nothing Then
                Exit For
            End If
        Next
    End If
    
    Set GetNestedPriceableItem = pi
End Function


Public Function GetPriceableItemInstance(ByVal ID As Long) As Object
    'look through all po's
    Dim foundPI As Object
    Dim po As MTProductOffering
    For Each po In ProductOfferings_
        Dim pi As Object
        For Each pi In po.GetPriceableItems
            If pi.ID = ID Then
                Set foundPI = pi
                Exit For
            Else
                Set foundPI = GetNestedPriceableItem(pi, ID)
                If Not foundPI Is Nothing Then
                    Exit For
                End If
            End If
        Next
        If Not foundPI Is Nothing Then
            Exit For
        End If
    Next

    Set GetPriceableItemInstance = foundPI
End Function


'// ----------------------------------------------------------------
'// Method:      GetPriceableItemByName
'// Description: finds a PriceableItem (of any kind) by its Name
'// Arguments:   Name – Name of the PriceableItem
'// Returns:     the PriceableItem or NULL if not found
Public Function GetPriceableItemByName(ByVal Name As String) As Object
    Dim pi As Object
    For Each pi In PriceableItems_
        If pi.Name = Name Then
            Set GetPriceableItemByName = pi
            Exit For
        End If
    Next
End Function

'// ----------------------------------------------------------------
'// Method:      GetProductOffering
'// Description: finds a ProductOffering by its ID
'// Arguments:   ID – ID of the ProductOffering
'// Returns:     the ProductOfferingor NULL if not found
Public Function GetProductOffering(ByVal ID As Long) As MTProductOffering
    Dim po As MTProductOffering
    For Each po In ProductOfferings_
        If po.ID = ID Then
            Set GetProductOffering = po
            Exit For
        End If
    Next
End Function

'// ----------------------------------------------------------------
'// Method:      GetProductOfferingByName
'// Description: finds a ProductOffering by its Name
'// Arguments:   Name – Name of the ProductOffering
'// Returns:     the ProductOffering or NULL if not found
Public Function GetProductOfferingByName(ByVal Name As String) As MTProductOffering
    Dim po As MTProductOffering
    For Each po In ProductOfferings_
        If po.Name = Name Then
            Set GetProductOfferingByName = po
            Exit For
        End If
    Next
End Function

'// ----------------------------------------------------------------
'// Method:      GetPriceList
'// Description: finds a PriceList by its ID
'// Arguments:   ID – ID of the PriceList
'// Returns:     the PriceList NULL if not found
Public Function GetPriceList(ByVal ID As Long) As MTPriceList
    Dim pl As MTPriceList
    For Each pl In PriceLists_
        If pl.ID = ID Then
            Set GetPriceList = pl
            Exit For
        End If
    Next
End Function

'// ----------------------------------------------------------------
'// Method:      GetPriceListByName
'// Description: finds a PriceList by its Name
'// Arguments:   Name – Name of the PriceList
'// Returns:     the PriceList or NULL if not found
Public Function GetPriceListByName(ByVal Name As String) As MTPriceList
    Dim pl As MTPriceList
    For Each pl In PriceLists_
        If pl.Name = Name Then
            Set GetPriceListByName = pl
            Exit For
        End If
    Next
End Function

'// ----------------------------------------------------------------
'// Method:      GetParamTableDefinition
'// Description: finds a ParamTableDefinition by its ID
'// Arguments:   ID – ID of the ParamTableDefinition
'// Returns:     the ParamTableDefinition or NULL if not found
Public Function GetParamTableDefinition(ByVal ID As Long) As MTParamTableDefinition
    Dim ptd As MTParamTableDefinition
    For Each ptd In ParamTableDefinitions_
        If ptd.ID = ID Then
            Set GetParamTableDefinition = ptd
            Exit For
        End If
    Next
End Function

'// ----------------------------------------------------------------
'// Method:      GetParamTableDefinitionByName
'// Description: finds a ParamTableDefinition by its Name
'// Arguments:   Name – Name of the ParamTableDefinition
'// Returns:     the ParamTableDefinition or NULL if not found
Public Function GetParamTableDefinitionByName(ByVal Name As String) As MTParamTableDefinition
    Dim ptd As MTParamTableDefinition
    For Each ptd In ParamTableDefinitions_
        If ptd.Name = Name Then
            Set GetParamTableDefinitionByName = ptd
            Exit For
        End If
    Next
End Function

'// ----------------------------------------------------------------
'// Method:      GetAccountReference
'// Description: finds an AccountReference by its ID
'// Arguments:   ID – ID of the Account
'// Returns:     the AccountReference or NULL if not found
Public Function GetAccountReference(ByVal acctID As Long) As MTAccountReference
    Dim acct As MTAccountReference
    For Each acct In AccountReferences_
        If acct.AccountID = acctID Then
            Set GetAccountReference = acct
            Exit For
        End If
    Next
End Function

'// ----------------------------------------------------------------
'// Method:      FindPriceableItemsAsRowset
'// Description: return a rowset of priceable item templates
'// Arguments:   Filter – a filter applied to the search
'// Returns:     an IMTSQLRowset
Public Function FindPriceableItemsAsRowset(Optional ByVal filter As MTFilter) As IMTSQLRowset
    
    ' check filter by kind but ignore the other's in the prototype
    ' extract kind from filter
'    Dim kindFilter As MTPriceableItemType
'    If Not filter Is Nothing Then
'        Dim Item As MTFilterItem
'        For Each Item In filter
'            If UCase$(Item.PropertyName) = "KIND" Then
'                kindFilter = Item.Value
'                Exit For
'            End If
'        Next
'    End If
    
    
    Dim rowset      As IMTSQLRowset
    Dim pi          As Object
    Dim booSkip     As Boolean
    
    Set rowset = CreateObject("MTSQLRowset.MTSQLRowset.1")
    rowset.InitDisconnected

    ' add meta data for all fields
    Dim meta As MTPropertyMetaData
    For Each meta In GetUsageChargeMetaData
        rowset.AddColumnDefinition meta.DBColumnName, meta.DataType, meta.Length
    Next

    ' fill rowset
    rowset.OpenDisconnected

    
    For Each pi In PriceableItems_
                
        
        booSkip = False
        If Not filter Is Nothing Then
        
            Select Case filter.Item(1).Operator
                Case OPERATOR_TYPE_EQUAL
                    booSkip = Not (pi.Properties(filter.Item(1).PropertyName).Value = filter.Item(1).Value)
                Case OPERATOR_TYPE_NOT_EQUAL
                    booSkip = Not (pi.Properties(filter.Item(1).PropertyName).Value <> filter.Item(1).Value)
            End Select
        End If
        
        If Not booSkip Then
                
             rowset.AddRow
             For Each meta In GetUsageChargeMetaData
             
                 On Error Resume Next
                 rowset.AddColumnData meta.DBColumnName, pi.Properties.Item(meta.Name).Value
                 On Error GoTo 0
             Next
        End If
    Next
    Set FindPriceableItemsAsRowset = rowset
End Function


'// ----------------------------------------------------------------
'// Method:      FindProductOfferingsAsRowset
'// Description: return a rowset of ProductOfferings
'// Arguments:   Filter – a filter applied to the search
'// Returns:     an IMTSQLRowset
Public Function FindProductOfferingsAsRowset(Optional ByVal filter As MTFilter) As IMTSQLRowset
    Dim rowset As IMTSQLRowset
    Set rowset = CreateObject("MTSQLRowset.MTSQLRowset.1")
    rowset.InitDisconnected
    

    ' add meta data for all fields
    Dim meta As MTPropertyMetaData
    For Each meta In GetProductOfferingMetaData
    
        If (Not meta.IsObject()) Then ' Sub Componant properties do not go into the rowset
        
            rowset.AddColumnDefinition meta.DBColumnName, meta.DataType, meta.Length
        End If
    Next

    ' fill rowset
    rowset.OpenDisconnected

    Dim po As MTProductOffering
    For Each po In ProductOfferings_
        rowset.AddRow
        For Each meta In GetProductOfferingMetaData
        
            If (Not meta.IsObject()) Then ' Sub Componant properties do not go into the rowset
            
                rowset.AddColumnData meta.DBColumnName, po.Properties.Item(meta.Name).Value
            End If
        Next
    Next

    Set FindProductOfferingsAsRowset = rowset
End Function


'// ----------------------------------------------------------------
'// Method:      FindPriceListsAsRowset
'// Description: return a rowset of PriceLists
'// Arguments:   Filter – a filter applied to the search
'// Returns:     an IMTSQLRowset
Public Function FindPriceListsAsRowset() As IMTSQLRowset
    Dim rowset As IMTSQLRowset
    Set rowset = CreateObject("MTSQLRowset.MTSQLRowset.1")
    rowset.InitDisconnected

    ' add meta data for all fields
    Dim meta As MTPropertyMetaData
    For Each meta In GetPriceListMetaData
        rowset.AddColumnDefinition meta.DBColumnName, meta.DataType, meta.Length
    Next

    ' fill rowset
    rowset.OpenDisconnected

    Dim pl As MTPriceList
    For Each pl In PriceLists_
        
        ' In the real find pricelist as rowset we do not want the ICBs
        If InStr(pl.Name, "#ICB") = 0 Then
            rowset.AddRow
            For Each meta In GetPriceListMetaData
                rowset.AddColumnData meta.DBColumnName, pl.Properties.Item(meta.Name).Value
            Next
        End If
        
    Next

    Set FindPriceListsAsRowset = rowset
End Function


'=== Counter related public methods =========================================================


'// ----------------------------------------------------------------
'// Method:      GetCounterTypes
'// Description: returns all counter types that are currently in DB
'// Arguments:
'// Returns:     Collection

Public Function GetCounterTypes() As Collection
 Set GetCounterTypes = CounterTypes_
End Function

'// ----------------------------------------------------------------
'// Method:      GetCounterType
'// Description: returns all counter types that are currently in DB
'// Arguments:
'// Returns:

Public Function GetCounterType(ByVal aTypeID As Long) As MTCounterType
  Set GetCounterType = CounterTypes_.Item(1)
End Function

'// ----------------------------------------------------------------
'// Method:      GetCounterTypeByName
'// Description: returns all counter types that are currently in DB
'// Arguments:
'// Returns:

Public Function GetCounterTypeByName(ByVal aTypeName As String) As MTCounterType
  Set GetCounterTypeByName = CounterTypes_.Item(1)
End Function

'// ----------------------------------------------------------------
'// Method:      FindCounterAsRowset
'// Description: Get all counter instances from database
'// Arguments:
'// Returns:

Public Function FindCountersAsRowset(Optional ByVal filter As MTFilter) As IMTSQLRowset
  Dim rowset      As IMTSQLRowset
  Dim meta As New MTPropertyMetaData
  
  Dim counter          As MTCounter
  Dim booSkip     As Boolean
    
  Set rowset = CreateObject("MTSQLRowset.MTSQLRowset.1")
  rowset.InitDisconnected
  
  rowset.AddColumnDefinition "Name", "STRING", 256
  rowset.AddColumnDefinition "id_prop", "int32", 256
  rowset.AddColumnDefinition "Description", "STRING", 256
  rowset.AddColumnDefinition "Formula", "STRING", 256
  
    rowset.OpenDisconnected
  
  For Each counter In Counters_
    rowset.AddRow
    
   
    rowset.AddColumnData "Name", counter.Name
    rowset.AddColumnData "Description", counter.Description
    rowset.AddColumnData "id_prop", counter.ID
    rowset.AddColumnData "Formula", counter.Formula
    
  Next
If Not CBool(rowset.EOF) Then
    rowset.MoveFirst
  End If
  Set FindCountersAsRowset = rowset
  
End Function
    
'// ----------------------------------------------------------------
'// Method:      GetCounter_
'// Description: get counter object by id
'// Arguments:
'// Returns:

Public Function GetCounter_(ByVal aCounterID As Long) As MTCounter
    Dim c As MTCounter
    For Each c In Counters_
        If c.ID = aCounterID Then
            Set GetCounter_ = c
            Exit For
        End If
    Next
End Function

'=== internal methods =======================================================

Private Sub Class_Initialize()

End Sub
