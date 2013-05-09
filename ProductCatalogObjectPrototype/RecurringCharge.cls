VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MTRecurringCharge"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Attribute VB_Ext_KEY = "SavedWithClassBuilder6" ,"Yes"
Attribute VB_Ext_KEY = "Member0" ,"MTPropertyCollection"
Attribute VB_Ext_KEY = "Member1" ,"NonRecurringConfiguration"
Attribute VB_Ext_KEY = "Member2" ,"ParameterTable"
Attribute VB_Ext_KEY = "Member3" ,"PriceableItem"
Attribute VB_Ext_KEY = "Member4" ,"PriceableItem"
Attribute VB_Ext_KEY = "Member5" ,"PriceableItem"
Attribute VB_Ext_KEY = "Member6" ,"ProductCatalog"
Attribute VB_Ext_KEY = "Member7" ,"ProductOffering"
Attribute VB_Ext_KEY = "Member8" ,"RecurringConfiguration"
Attribute VB_Ext_KEY = "Top_Level" ,"Yes"
Attribute VB_Ext_KEY = "Member9" ,"RecurringChargeCycle"
'// ----------------------------------------------------------------
'// Object:      MTRecurringCharge
'// Description: a PriceableItem of kind RecurringCharge.
'//              Inherits all properties and methods from PriceableItem.
'//              A Recurring Charge is a charge that occurs more than once.
'// ----------------------------------------------------------------
Option Explicit

'=== public properties ======================================================
Public Enum MTProrationType
    PRORATION_TYPE_NONE = 0
    PRORATION_TYPE_TRUE_MONTH = 1
    PRORATION_TYPE_MONTH_30_DAYS = 2
    PRORATION_TYPE_MONTH_31_DAYS = 3
End Enum

'// ----------------------------------------------------------------
'// Property:    Cycle
'// Description: cycle of this recurring charge
Public Cycle As New MTCycle

Public CycleID As Integer

'// ----------------------------------------------------------------
'// Property:    ChargeInAdvance
'// Description: if true, charge in advance, otherwise in arrears
'//Public ChargeInAdvance As Boolean

'// ----------------------------------------------------------------
'// Property:    ProrateOnActivation
'// Description: if true, prorate when a subscriber subscribes to the
'//              product offering
'Public ProrateOnActivation As Boolean ' Now a Property GET/LET

'// ----------------------------------------------------------------
'// Property:    ProrateOnDeactivation
'// Description: if true, prorate when a subscriber unsubscribes from the
'//              product offering
'Public ProrateOnDeactivation As Boolean ' Now a property GET/LET

'// ----------------------------------------------------------------
'// Property:    ProrationType
'// Description: type of proration that should be done
'//              { NONE, TRUE_MONTH, MONTH_30_DAYS, MONTH_31_DAYS, ...}
'//Public ProrationType As MTProrationType


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
Public Sub SetParent_(ByVal val As Object)
    pi.SetParent_ val
End Sub

Public Function GetBasedOn() As Object
    Set GetBasedOn = pi.GetBasedOn
End Function
Public Sub SetBasedOn(ByVal val As Object)
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


'=== recurring charge specific methods  ========================================================
Private Sub Class_Initialize()

    'add extended properties
    Dim propMeta As MTPropertyMetaData
    Dim attrMeta As MTAttributeMetaData
    Dim prop As MTProperty
    Dim attr As MTAttribute
   
    ' create a property for each property meta data
    For Each propMeta In RecurringChargeMetaDataCollection
        Set prop = pi.Properties.Add(propMeta)
            
        'create an attribute for each attribute meta data
        For Each attrMeta In AttributeMetaDataCollection
            Set attr = prop.Attributes.Add(attrMeta)
        Next
    Next
   
    Set Properties.Item("Cycle").Value = Me.Cycle
    
End Sub


Public Property Get ProrateOnActivation() As Boolean

    ProrateOnActivation = Me.Properties("ProrateOnActivation").Value
End Property

Public Property Let ProrateOnActivation(ByVal vNewValue As Boolean)
    Me.Properties("ProrateOnActivation").Value = vNewValue
End Property


Public Property Get ProrateOnDeactivation() As Boolean

    ProrateOnDeactivation = Me.Properties("ProrateOnDeactivation").Value
End Property

Public Property Let ProrateOnDeactivation(ByVal vNewValue As Boolean)
    Me.Properties("ProrateOnDeactivation").Value = vNewValue
End Property


Public Property Get ChargeInAdvance() As Boolean

    ChargeInAdvance = Me.Properties("ChargeInAdvance").Value
End Property

Public Property Let ChargeInAdvance(ByVal vNewValue As Boolean)
    Me.Properties("ChargeInAdvance").Value = vNewValue
End Property

Public Property Get ProrationType() As MTProrationType

    ProrationType = Me.Properties("ProrationType").Value
End Property

Public Property Let ProrationType(ByVal vNewValue As MTProrationType)
    Me.Properties("ProrationType").Value = vNewValue
End Property
