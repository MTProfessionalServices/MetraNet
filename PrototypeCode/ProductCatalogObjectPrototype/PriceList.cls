VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MTPriceList"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Attribute VB_Ext_KEY = "SavedWithClassBuilder6" ,"Yes"
Attribute VB_Ext_KEY = "Top_Level" ,"Yes"
'// ----------------------------------------------------------------
'// Object:      MTPriceList
'// Description: identifier used to select one set of rating parameters
'// ----------------------------------------------------------------

Option Explicit

'=== public properties ======================================================

'// ----------------------------------------------------------------
'// Method:      <<accessor>> Properties
'// Description: Interface to get all (core and extended) properties of this PI
'//              by name or collection.
'// Returns:     MTProperties
Public Properties As New MTProperties

'=== internal properties ====================================================

'=== public methods =========================================================
'// ----------------------------------------------------------------
'// Property:    ID
'// Description: unique ID
Public Property Get ID() As Long
    ID = Properties.Item("ID").Value
End Property
Public Property Let ID(ByVal val As Long)
    Properties.Item("ID").Value = val
End Property

'// ----------------------------------------------------------------
'// Property:    Name
'// Description: name as shown to the user
Public Property Get Name() As String
    Name = Properties.Item("Name").Value
End Property
Public Property Let Name(ByVal val As String)
    Properties.Item("Name").Value = val
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
'// Property:    HasRates
'// Note that this property is actually derived from a PricelistMapping
'// For now, we will put it here just so we have something to display
Public Property Get HasRates() As String
    HasRates = Properties.Item("HasRates").Value
End Property
Public Property Let HasRates(ByVal val As String)
    Properties.Item("HasRates").Value = val
End Property

'// ----------------------------------------------------------------
'// Property:    CurrencyCode
'// Description: currency code for all rates on this pricelist
Public Property Get CurrencyCode() As String
    CurrencyCode = Properties.Item("CurrencyCode").Value
End Property
Public Property Let CurrencyCode(ByVal val As String)
    Properties.Item("CurrencyCode").Value = val
End Property



'// ----------------------------------------------------------------
'// Method:      Save
'// Description: Saves modification to this pricelist to database.
Public Sub Save()

End Sub

'=== internal methods =======================================================

Private Sub Class_Initialize()
    
    'add properties
    Dim propMeta As MTPropertyMetaData
    Dim attrMeta As MTAttributeMetaData
    Dim prop As MTProperty
    Dim attr As MTAttribute
   
    ' create a property for each property meta data
    For Each propMeta In PriceListMetaDataCollection
        Set prop = Properties.Add(propMeta)
            
        'create an attribute for each attribute meta data
        For Each attrMeta In AttributeMetaDataCollection
            Set attr = prop.Attributes.Add(attrMeta)
        Next
    Next
End Sub

