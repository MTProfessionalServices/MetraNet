VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MTSubscription"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Attribute VB_Ext_KEY = "SavedWithClassBuilder6" ,"Yes"
Attribute VB_Ext_KEY = "Member0" ,"ProductOffering"
Attribute VB_Ext_KEY = "Top_Level" ,"Yes"
'// ----------------------------------------------------------------
'// Object:      MTSubscription
'// Description: One ProductOffering subscribed to an account.
'// ----------------------------------------------------------------

Option Explicit

'=== public properties ======================================================

'// ----------------------------------------------------------------
'// Method:      <<accessor>> Properties
'// Description: Interface to get all (core and extended) properties of this Subscription
'//              by name or collection.
'// Returns:     MTProperties
Public Properties As New MTProperties

Public EffectiveDate As New MTTimeSpan


'=== internal properties ====================================================

Private mProductOfferingID As Long

' list of all ICB mappings between priceable item parameter tables and pricelists.
Private mPriceListMappings As New Collection

Public ProdCat_ As MTProductCatalog

'=== public methods =========================================================

'// ----------------------------------------------------------------
'// Property:    ProductOffering
'// Description: product offering that the account is subscribed to
Public Function GetProductOffering() As MTProductOffering
    Set GetProductOffering = ProdCat_.GetProductOffering(mProductOfferingID)
End Function
Public Sub SetProductOffering(ByVal prodOffID As Long)
    mProductOfferingID = prodOffID
End Sub

'// ----------------------------------------------------------------
'// Method:      Save
'// Description: Saves modification to this subscription
Public Sub Save()

End Sub

'// ----------------------------------------------------------------
'// Method:      GetICBPriceListMapping
'// Description: return the price list for the given priceable item
'//              and parameter table.
'// Arguments:   prcItemID – ID of PriceableItem
'//              paramTblID – ID of ParamTableDefinition
'// Returns:     PriceListMapping or NULL if there is no mapping on
'//              this subscription
Public Function GetICBPriceListMapping(ByVal prcItemID As Long, ByVal paramTblID As Long) As MTPriceListMapping
    Dim plm As MTPriceListMapping
    For Each plm In mPriceListMappings
        If plm.PriceableItemID = prcItemID And plm.ParamTableDefinitionID = paramTblID Then
            Set GetICBPriceListMapping = plm
        End If
    Next
End Function

'// ----------------------------------------------------------------
'// Method:      SetICBPriceListMapping
'// Description: override the price list for a priceable item parameter table.
'//              Creates a new mapping entry if none exists
'//              BUSINESS RULE: this function must verify the currency of the
'//              pricelist added.  The currency of the pricelist being
'//              overridden must match the currency of the price list passed in.
'// Arguments:   prcItemID – ID of PriceableItem
'//              paramTblID – ID of ParamTableDefinition
'//              prcLstID – ID of PriceList
Public Sub SetICBPriceListMapping(ByVal prcItemID As Long, ByVal paramTblID As Long, ByVal prcLstID As Long)
    Dim plm As MTPriceListMapping
    Set plm = GetICBPriceListMapping(prcItemID, paramTblID)
    If plm Is Nothing Then
        Set plm = New MTPriceListMapping
        plm.PriceableItemID = prcItemID
        plm.ParamTableDefinitionID = paramTblID
        mPriceListMappings.Add plm
    End If
    
    'create a rate schedule if doesnot exist
    Dim rs As MTRateSchedule
    Dim exists As Boolean
    exists = False
    
    For Each rs In plm.GetRateSchedules()
      If rs.PriceListID = prcLstID Then
        exists = True
        Exit For
      End If
    Next
    
    If Not exists Then
        plm.CreateRateSchedule
    End If
    
    plm.PriceListID = prcLstID
End Sub

'// ----------------------------------------------------------------
'// Method:      RemoveICBPriceListMapping
'// Description: removes the price list override for a priceable item parameter
'//              table.
'// Arguments:   prcItemID – ID of PriceableItem
'//              paramTblID – ID of ParamTableDefinition
Public Sub RemoveICBPriceListMapping(ByVal piID As Long, ByVal ptdID As Long)
    'TODO
End Sub

'// ----------------------------------------------------------------
'// Method:      GetICBPriceListMappings
'// Description: return all subscription specific pricelist mapping
'// Returns:     Collection of PriceListMappings
Public Function GetICBPriceListMappings() As Collection
    Set GetICBPriceListMappings = mPriceListMappings
End Function

'=== internal methods =======================================================


'// ----------------------------------------------------------------
'// Property:    ID
'// Description: unique ID of this Subscription
Public Property Get ID() As Long
    ID = Properties.Item("ID").Value
End Property
Public Property Let ID(ByVal val As Long)
    Properties.Item("ID").Value = val
End Property

'// ----------------------------------------------------------------
'// Property:    Active
'// Description: Active
Public Property Get Active() As Boolean
    Active = Properties.Item("Active").Value
End Property
Public Property Let Active(ByVal val As Boolean)
    Properties.Item("Active").Value = val
End Property

'// ----------------------------------------------------------------
'// Property:    UseEffectiveDate
'// Description: UseEffectiveDate
Public Property Get UseEffectiveDate() As Boolean
    UseEffectiveDate = Properties.Item("UseEffectiveDate").Value
End Property
Public Property Let UseEffectiveDate(ByVal val As Boolean)
    Properties.Item("UseEffectiveDate").Value = val
End Property


Private Sub Class_Initialize()

    'add extended properties
    Dim propMeta As MTPropertyMetaData
    Dim attrMeta    As MTAttributeMetaData
    Dim prop        As MTProperty
    Dim attr        As MTAttribute
   
    ' create a property for each property meta data
    For Each propMeta In SubscriptionMetaDataCollection
        Set prop = Properties.Add(propMeta)
    Next
   
    Set Properties.Item("EffectiveDate").Value = Me.EffectiveDate

    ID = NextID()
   
End Sub
