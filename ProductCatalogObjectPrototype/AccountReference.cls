VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MTAccountReference"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Attribute VB_Ext_KEY = "SavedWithClassBuilder6" ,"Yes"
Attribute VB_Ext_KEY = "Top_Level" ,"Yes"
'// ----------------------------------------------------------------
'// Object: MTAccountReference
'// Description: product catalog view of an account.
'// ----------------------------------------------------------------

Option Explicit

'=== public properties ======================================================

'// ----------------------------------------------------------------
'// Property:    AccountID
'// Description: ID of original account
Public AccountID As Long

'=== internal properties ====================================================

'default account pricelist
Private mDefaultPriceListID As Long

' all subscriptions assigned to an account
Private mSubscriptions As New Collection

Private mICBPriceList As MTPriceList

Public ProdCat_ As MTProductCatalog

'=== public methods =========================================================

'// ----------------------------------------------------------------
'// Method:      Get/SetDefaultPriceList
'// Description: default account pricelist
Public Function GetDefaultPriceList() As MTPriceList
    Set GetDefaultPriceList = ProdCat_.GetPriceList(mDefaultPriceListID)
End Function

Public Sub SetDefaultPriceList(ByVal prcListID As Long)
    mDefaultPriceListID = prcListID
End Sub

'// ----------------------------------------------------------------
'// Method:      Save
'// Description: Saves modification to this object and all dependents
'//              to database.
Public Sub Save()
End Sub

'// ----------------------------------------------------------------
'// Method:      GetICBPriceList
'// Description: returns the ICB pricelist for this account
'//              creates one if none exists
Public Function GetICBPriceList() As MTPriceList
    If mICBPriceList Is Nothing Then
        Set mICBPriceList = ProdCat_.CreatePriceList
        mICBPriceList.Name = "#ICB" & AccountID
    End If
    Set GetICBPriceList = mICBPriceList
End Function

'// ----------------------------------------------------------------
'// Method:      Subscribe
'// Description: subscribe to a product offering
'// Arguments:   prodOffID – ID of ProductOffering
'//              date – [optional] date subscription becomes effective
'//                     if omitted, immediately
'// Returns:     the new Subscription
Public Function Subscribe(ByVal prodOffID As Long, Optional ByVal effDate As MTTimeSpan) As MTSubscription
    
    Dim subscr As New MTSubscription
    

    
    Set subscr.ProdCat_ = ProdCat_
    subscr.SetProductOffering prodOffID
    subscr.Active = True
    If Not effDate Is Nothing Then
        Set subscr.EffectiveDate = effDate
    End If
    
    mSubscriptions.Add subscr
    Set Subscribe = subscr

End Function

'// ----------------------------------------------------------------
'// Method:      Unsubscribe
'// Description: unsubscribe from a product offering
'// Arguments:   subscrID – ID of Subscription to unsubscribe
'//              date – [optional] date subscription becomes ineffective,
'//                     if omitted, immediately
Public Sub Unsubscribe(ByVal subscrID As Long, Optional ByVal effective As Date)
    GetSubscription(subscrID).Active = False
End Sub

'// ----------------------------------------------------------------
'// Method:      RemoveSubscription
'// Description: deletes a subscription
'// Arguments:   subscrID – ID of the Subscription
Public Sub RemoveSubscription(ByVal subscrID As Long)
    'TODO
End Sub

'// ----------------------------------------------------------------
'// Method:      GetSubscribableProductOfferings
'// Description: get all product offering the customer can subscribe to
'// Returns:     Collection of ProductOfferings
Public Function GetSubscribableProductOfferings() As Collection
    'fake it by returning all
    Set GetSubscribableProductOfferings = ProductOfferings_
End Function

'// ----------------------------------------------------------------
'// Method:      FindSubscribableProductOfferingsAsRowset
'// Description: find all product offering the customer can subscribe to
'// Arguments:   filter – filter applied when retrieving the rowset
'// Returns:     IMTSQLRowSet
Public Function FindSubscribableProductOfferingsAsRowset(Optional ByVal filter As MTFilter) As IMTSQLRowset
    Dim rowset As IMTSQLRowset
    Set rowset = CreateObject("MTSQLRowset.MTSQLRowset.1")
    rowset.InitDisconnected

    ' add meta data for all fields
    Dim meta As MTPropertyMetaData
    For Each meta In ProdCat_.GetProductOfferingMetaData
        If (Not meta.IsObject()) Then
            rowset.AddColumnDefinition meta.DBColumnName, meta.DataType, meta.Length
        End If
    Next

    ' fill rowset
    rowset.OpenDisconnected

    Dim po As MTProductOffering
    For Each po In GetSubscribableProductOfferings
        rowset.AddRow
        For Each meta In ProdCat_.GetProductOfferingMetaData
            If (Not meta.IsObject()) Then
                rowset.AddColumnData meta.DBColumnName, po.Properties.Item(meta.Name).Value
            End If
        Next

    Next

    Set FindSubscribableProductOfferingsAsRowset = rowset
End Function

'// ----------------------------------------------------------------
'// Method:      GetActiveSubscriptions
'// Description: Find active subscriptions for an account, current and future
'//              ones.
'// Returns:     Collection of Subscriptions
Public Function GetActiveSubscriptions() As Collection
    Dim activeSubscribtions As New Collection
    Dim subscr As MTSubscription
    For Each subscr In mSubscriptions
        If subscr.Active Then
            activeSubscribtions.Add subscr
        End If
    Next
    Set GetActiveSubscriptions = activeSubscribtions
End Function

'// ----------------------------------------------------------------
'// Method:      GetActiveSubscriptionsAsRowset
'// Description: Find active subscriptions for an account, current and future
'//              ones.
'// Returns:     Collection of Subscriptions
Public Function GetActiveSubscriptionsAsRowset() As IMTSQLRowset
   
    Dim rowset As IMTSQLRowset
    Set rowset = CreateObject("MTSQLRowset.MTSQLRowset.1")
    rowset.InitDisconnected

    ' add meta data for all fields
    rowset.AddColumnDefinition "id_prop", "int32", 10
    rowset.AddColumnDefinition "nm_name", "string", 256
    rowset.AddColumnDefinition "b_Active", "string", 10
    rowset.AddColumnDefinition "b_UseEffectiveDate", "string", 10
    rowset.AddColumnDefinition "nm_EffectiveStartDate", "string", 256
    rowset.AddColumnDefinition "nm_EffectiveEndDate", "string", 256
    
    '''''''''''
    'If you are implementing this for real, we need some magic that will tell us
    'if this subscription has a recurring charge associated with it and if
    'It has been ICBed...  Also, you need to grab the Help URL that should be
    'stored with the the product offerring
    '
    'In other words, we are massaging the rowset....
    '''''''''''
    rowset.AddColumnDefinition "b_RecurringCharge", "string", 10
    rowset.AddColumnDefinition "b_PersonalRate", "string", 10
    rowset.AddColumnDefinition "nm_InternalInformationURL", "string", 256
    rowset.AddColumnDefinition "nm_ExternalInformationURL", "string", 256
    
    ' fill rowset
    rowset.OpenDisconnected

    Dim subscr As MTSubscription
    For Each subscr In GetActiveSubscriptions
        rowset.AddRow
        rowset.AddColumnData "id_prop", subscr.ID
        rowset.AddColumnData "nm_name", subscr.GetProductOffering().Name
        rowset.AddColumnData "b_Active", subscr.Active
        rowset.AddColumnData "b_UseEffectiveDate", subscr.UseEffectiveDate
        rowset.AddColumnData "nm_EffectiveStartDate", subscr.EffectiveDate.StartDate
        rowset.AddColumnData "nm_EffectiveEndDate", subscr.EffectiveDate.EndDate
        rowset.AddColumnData "b_RecurringCharge", True
        rowset.AddColumnData "b_PersonalRate", True
        ' These are extended properties on the Product Offering... eventually the code should return all extended
        ' properties of the product offering with the correct attribute
        rowset.AddColumnData "nm_InternalInformationURL", subscr.GetProductOffering().Properties.Item("InternalInformationURL").Value '  "http://www.metratech.com"
        rowset.AddColumnData "nm_ExternalInformationURL", subscr.GetProductOffering().Properties.Item("ExternalInformationURL").Value '  "http://www.metratech.com"
        
    Next
    Set GetActiveSubscriptionsAsRowset = rowset
End Function




'// ----------------------------------------------------------------
'// Method:      GetInactivateSubscriptions
'// Description: Find inactivate subscriptions for an account
'// Returns:     Collection of Subscriptions
Public Function GetInactivateSubscriptions() As Collection
    Dim inactiveSubscribtions As New Collection
    Dim subscr As MTSubscription
    For Each subscr In mSubscriptions
        If Not subscr.Active Then
            inactiveSubscribtions.Add subscr
        End If
    Next
    Set GetInactivateSubscriptions = inactiveSubscribtions
End Function


'// ----------------------------------------------------------------
'// Method:      GetInactiveSubscriptionsAsRowset
'// Description: Find inactive subscriptions for an account, current and future
'//              ones.
'// Returns:     Collection of Subscriptions
Public Function GetInactiveSubscriptionsAsRowset() As IMTSQLRowset
   
    Dim rowset As IMTSQLRowset
    Set rowset = CreateObject("MTSQLRowset.MTSQLRowset.1")
    rowset.InitDisconnected

    ' add meta data for all fields
    rowset.AddColumnDefinition "id_prop", "int32", 10
    rowset.AddColumnDefinition "nm_name", "string", 256
    rowset.AddColumnDefinition "b_Active", "string", 10
    rowset.AddColumnDefinition "b_UseEffectiveDate", "string", 10
    rowset.AddColumnDefinition "nm_EffectiveStartDate", "string", 256
    rowset.AddColumnDefinition "nm_EffectiveEndDate", "string", 256
    
    '''''''''''
    'If you are implementing this for real, we need some magic that will tell us
    'if this subscription has a recurring charge associated with it and if
    'It has been ICBed...  Also, you need to grab the Help URL that should be
    'stored with the the product offerring
    '
    'In other words, we are massaging the rowset....
    '''''''''''
    rowset.AddColumnDefinition "b_RecurringCharge", "string", 10
    rowset.AddColumnDefinition "b_PersonalRate", "string", 10
    rowset.AddColumnDefinition "nm_InternalInformationURL", "string", 256
    rowset.AddColumnDefinition "nm_ExternalInformationURL", "string", 256
    
    ' fill rowset
    rowset.OpenDisconnected

    Dim subscr As MTSubscription
    For Each subscr In GetInactivateSubscriptions
        rowset.AddRow
        rowset.AddColumnData "id_prop", subscr.ID
        rowset.AddColumnData "nm_name", subscr.GetProductOffering().Name
        rowset.AddColumnData "b_Active", subscr.Active
        rowset.AddColumnData "b_UseEffectiveDate", subscr.UseEffectiveDate
        rowset.AddColumnData "nm_EffectiveStartDate", subscr.EffectiveDate.StartDate
        rowset.AddColumnData "nm_EffectiveEndDate", subscr.EffectiveDate.EndDate
        rowset.AddColumnData "b_RecurringCharge", True
        rowset.AddColumnData "b_PersonalRate", True
        ' These are extended properties on the Product Offering... eventually the code should return all extended
        ' properties of the product offering with the correct attribute
        rowset.AddColumnData "nm_InternalInformationURL", subscr.GetProductOffering().Properties.Item("InternalInformationURL").Value '  "http://www.metratech.com"
        rowset.AddColumnData "nm_ExternalInformationURL", subscr.GetProductOffering().Properties.Item("ExternalInformationURL").Value '  "http://www.metratech.com"
        
    Next
    Set GetInactiveSubscriptionsAsRowset = rowset
End Function

'TODO: possible methods
' return an ordered list of all possible pricelists for a param table
Public Function GetPossiblePriceLists(ByVal prcItemID As Long, ByVal paramTblID As Long) As Collection
End Function

' get the subscription for a product offering
Public Function GetSubscriptionByProductOffering(ByVal prodOffID As Long) As MTSubscription
End Function

' get the subscription for a priceable item
Public Function GetSubscriptionByPriceableItem(ByVal prcItemID As Long) As MTSubscription
End Function
Public Function GetSubscription(ByVal subscrID As Long) As MTSubscription
    Dim subscr As MTSubscription
    For Each subscr In mSubscriptions
        If subscr.ID = subscrID Then
            Set GetSubscription = subscr
            Exit For
        End If
    Next
End Function

'// ----------------------------------------------------------------
'// Method:      GetParamTablesAsRowset
'// Description:
'// Returns:     Rowset containing all active Parameter Tables for account
Public Function GetParamTablesAsRowset() As IMTSQLRowset
    Dim rowset As IMTSQLRowset
    Dim po As MTProductOffering
    Dim pi As Object
    
    Set rowset = CreateObject("MTSQLRowset.MTSQLRowset.1")
    rowset.InitDisconnected

    ' Setup fields to be returned in rowset
    rowset.AddColumnDefinition "n_poName", "string", 256
    rowset.AddColumnDefinition "n_piName", "string", 256
    rowset.AddColumnDefinition "n_ptdName", "string", 256
        
    rowset.AddColumnDefinition "id_po", "int32", 10
    rowset.AddColumnDefinition "id_pi", "int32", 10
    rowset.AddColumnDefinition "id_prop", "int32", 10
    rowset.AddColumnDefinition "id_Sub", "int32", 10

  
   ' fill rowset
    rowset.OpenDisconnected

    Dim subscr As MTSubscription
    For Each subscr In GetActiveSubscriptions()
    
        Set po = subscr.GetProductOffering()
        For Each pi In po.GetPriceableItems()
         
          Dim ptd As MTParamTableDefinition
          For Each ptd In pi.GetParamTableDefinitions()
            rowset.AddRow
            
            rowset.AddColumnData "n_poName", po.Name    'Probably want display name here
            rowset.AddColumnData "n_piName", pi.Name    'Probably want display name here
            rowset.AddColumnData "n_ptdName", ptd.Name
            
            rowset.AddColumnData "id_po", po.ID
            rowset.AddColumnData "id_pi", pi.ID
            rowset.AddColumnData "id_prop", ptd.ID
            rowset.AddColumnData "id_Sub", subscr.ID
            
          Next
    
        Next
        
    Next
    
    Set GetParamTablesAsRowset = rowset
End Function
   
   



' --- internal methods ----------------------------------------------------

