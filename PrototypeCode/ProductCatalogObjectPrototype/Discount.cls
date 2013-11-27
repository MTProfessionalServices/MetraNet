VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MTDiscount"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Attribute VB_Ext_KEY = "SavedWithClassBuilder6" ,"Yes"
Attribute VB_Ext_KEY = "Top_Level" ,"Yes"
'// ----------------------------------------------------------------
'// Object:      MTDiscount
'// Description: a PriceableItem of kind Discount.
'//              A Line item on a bill that reduces the total amount.
'//              Modeled as a derived PriceableItem and therefore inherits all '//              properties and methods from PriceableItem.
'//              TODO: needs to be further defined
'// ----------------------------------------------------------------
Option Explicit

'=== public properties ======================================================
'TODO



Public Enum MTCounterKind
    COUNTER_QUALIFIER = 10
    COUNTER_TARGET = 20
End Enum

Public Enum MTDiscountValueType
    DISCOUNT_VALUE_TYPE_UNKNOWN = 0
    DISCOUNT_VALUE_TYPE_FLAT = 1
    DISCOUNT_VALUE_TYPE_PERCENTAGE = 2
End Enum



'// ----------------------------------------------------------------
'// Property:    Cycle
'// Description: cycle of this recurring charge
Public Cycle As New MTCycle

Public CycleID As Integer

Public TargetValueType As MTDiscountValueType

' list of counters
Public mCounters_ As New Collection

'=== internal properties ====================================================
Private pi As New MTPriceableItem ' simulate inheritance by aggregation



'==== properties and methods inherited from Priceable Item ================
Public Property Let ID(ByVal vData As Long)
    pi.ID = vData
End Property
Public Property Get ID() As Long
    ID = pi.ID
End Property

Public Property Let Kind(ByVal vData As Integer)
    pi.Kind = vData
End Property
Public Property Get Kind() As Integer
    Kind = pi.Kind
End Property

Public Property Let Name(ByVal vData As String)
    pi.Name = vData
End Property
Public Property Get Name() As String
    Name = pi.Name
End Property

Public Property Let DisplayName(ByVal vData As String)
    pi.DisplayName = vData
End Property
Public Property Get DisplayName() As String
    DisplayName = pi.DisplayName
End Property

Public Property Let Description(ByVal vData As String)
    pi.Description = vData
End Property
Public Property Get Description() As String
    Description = pi.Description
End Property

Public Property Let ServiceDefinition(ByVal vData As String)
    pi.ServiceDefinition = vData
End Property
Public Property Get ServiceDefinition() As String
    ServiceDefinition = pi.ServiceDefinition
End Property

Public Property Get Properties() As MTProperties
    Set Properties = pi.Properties
End Property

Public Function GetParent() As Object
    Set GetParent = pi.GetParent
End Function
Public Sub SetParent_(val As Object)
    pi.SetParent_ val
End Sub

Public Function GetBasedOn() As Object
    Set GetBasedOn = pi.GetBasedOn
End Function
Public Sub SetBasedOn(val As Object)
    pi.SetBasedOn val
End Sub

Public Property Get mPriceListMappings_() As Collection
    Set mPriceListMappings_ = pi.mPriceListMappings_
End Property

Public Property Let ProdCat_(ByVal vData As MTProductCatalog)
    Set pi.ProdCat_ = vData
End Property
Public Property Get ProdCat_() As MTProductCatalog
    ProdCat_ = pi.ProdCat_
End Property

Public Property Let ProdOff_(ByVal vData As MTProductOffering)
    Set pi.ProdOff_ = vData
End Property
Public Property Get ProdOff_() As MTProductOffering
    ProdOff_ = pi.ProdOff_
End Property

Public Sub Save()
    pi.Save
End Sub

Public Function CreateUsageChargeChild() As MTUsageCharge
    Set CreateUsageChargeChild = pi.CreateUsageChargeChild
End Function

Public Function GetChildren() As Collection
    Set GetChildren = pi.GetChildren()
End Function

Public Function GetChild(ByVal ID As Long) As Object
    Set GetChild = pi.GetChild(ID)
End Function

Public Function GetChildByName(ByVal Name As String) As Object
    Set GetChildByName = pi.GetChildByName(Name)
End Function

Public Function AddParamTableDefinition(ByVal ptdID As Long)
    pi.AddParamTableDefinition (ptdID)
End Function

Public Function RemoveParamTableDefinition(ByVal ptdID As Long)
    pi.RemoveParamTableDefinition (ptdID)
End Function

Public Function GetParamTableDefinition(ByVal ptdID As Long) As MTParamTableDefinition
    Set GetParamTableDefinition = pi.GetParamTableDefinition(ptdID)
End Function

Public Function GetParamTableDefinitions() As Collection
    Set GetParamTableDefinitions = pi.GetParamTableDefinitions
End Function

Public Function GetParameterTablesAsRowset() As IMTSQLRowset
    Set GetParameterTablesAsRowset = pi.GetParameterTablesAsRowset
End Function

Public Function GetPriceListMappingsAsRowset() As IMTSQLRowset
    Set GetPriceListMappingsAsRowset = pi.GetPriceListMappingsAsRowset
End Function

Public Function GetPriceListMapping(ByVal ptdID As Long) As MTPriceListMapping
    Set GetPriceListMapping = pi.GetPriceListMapping(ptdID)
End Function

Public Sub SetPriceListMapping(ByVal ptdID As Long, ByVal plID As Long)
    pi.SetPriceListMapping ptdID, plID
End Sub

Public Function Clone_() As Object
    Set Clone_ = pi.Clone_
End Function

'// ----------------------------------------------------------------
'// Method:      AddCounter
'// Description: adds a qualifier-counter to this discount
'// Arguments:   DB ID for the counter

Public Sub AddCounter(ByVal aID As Long, ByVal aCounterKind As MTCounterKind)
    Dim c As MTCounter
    Set c = ProdCat_.GetCounter_(aID)
    mCounters_.Add c
End Sub


'// ----------------------------------------------------------------
'// Method:      RemoveCounter
'// Description: removes a counter from this discount
'// Arguments:   DB ID for the counter

Public Sub RemoveCounter(ByVal aID As Long, ByVal aCounterKind As MTCounterKind)
    
End Sub

'// ----------------------------------------------------------------
'// Method:      GetCounters
'// Description: returns counters mapped to this this priceable item
'// Arguments:
Public Function GetCounters(ByVal aCounterKind As MTCounterKind) As Collection
    Set GetCounters = mCounters_
End Function




'=== discount specific methods  ========================================================
Private Sub Class_Initialize()

    'add extended properties
    Dim propMeta As MTPropertyMetaData
    Dim attrMeta As MTAttributeMetaData
    Dim prop As MTProperty
    Dim attr As MTAttribute
   
    ' create a property for each property meta data
    For Each propMeta In DiscountMetaDataCollection
        Set prop = pi.Properties.Add(propMeta)
            
        'create an attribute for each attribute meta data
        For Each attrMeta In AttributeMetaDataCollection
            Set attr = prop.Attributes.Add(attrMeta)
        Next
    Next
    
    Set Properties.Item("Cycle").Value = Me.Cycle
   
End Sub


