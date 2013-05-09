VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MTNonRecurringCharge"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Attribute VB_Ext_KEY = "SavedWithClassBuilder6" ,"Yes"
Attribute VB_Ext_KEY = "Top_Level" ,"Yes"
'// ----------------------------------------------------------------
'// Object: MTNonRecurringCharge
'// Description: a PriceableItem of kind NonRecurringCharge.
'//              Inherits all properties and methods from PriceableItem.
'//              A Non-Recurring Charge is a one time charge not based on usage.
'// ----------------------------------------------------------------

Option Explicit

'=== public properties ======================================================

'// ----------------------------------------------------------------
'// Enum:        MTPriceableItemType
'// Description: the kind of priceable item
'//              The values have to be unique for all kinds of
'//              product catalog entities.
'//              The reserved value range for MTPriceableItemType is 1-99
Public Enum MTNonRecurringEventType
    NREVENT_TYPE_UNKNOWN = 0
    NREVENT_TYPE_SUBSCRIBE = 1
    NREVENT_TYPE_UNSUBSCRIBE = 2
    NREVENT_TYPE_CHANGE_SUBSCRIPTION = 3
End Enum

'// ----------------------------------------------------------------
'// Property:    Event
'// Description: event at which this charge is made
'//Public RecurringChargeEvent As Integer


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

Public Function GetPriceListMapping(ByVal ptdID As Long) As MTPriceListMapping
    Set GetPriceListMapping = pi.GetPriceListMapping(ptdID)
End Function

Public Function GetPriceListMappingsAsRowset() As IMTSQLRowset
    Set GetPriceListMappingsAsRowset = pi.GetPriceListMappingsAsRowset
End Function

Public Sub SetPriceListMapping(ByVal ptdID As Long, ByVal plID As Long)
    pi.SetPriceListMapping ptdID, plID
End Sub

Public Function Clone_() As Object
    Set Clone_ = pi.Clone_
End Function


'=== non recurring charge specific methods  ========================================================
Private Sub Class_Initialize()

    'add extended properties
    Dim propMeta As MTPropertyMetaData
    Dim attrMeta As MTAttributeMetaData
    Dim prop As MTProperty
    Dim attr As MTAttribute
   
    ' create a property for each property meta data
    For Each propMeta In NonRecurringChargeMetaDataCollection
        Set prop = pi.Properties.Add(propMeta)
            
        'create an attribute for each attribute meta data
        For Each attrMeta In AttributeMetaDataCollection
            Set attr = prop.Attributes.Add(attrMeta)
        Next
    Next
   
End Sub

Public Property Get RecurringChargeEvent() As MTNonRecurringEventType

    RecurringChargeEvent = Me.Properties("RecurringChargeEvent").Value
End Property

Public Property Let RecurringChargeEvent(ByVal vNewValue As MTNonRecurringEventType)
    Me.Properties("RecurringChargeEvent").Value = vNewValue
End Property

