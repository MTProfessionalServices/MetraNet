VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MTProperty"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Attribute VB_Ext_KEY = "SavedWithClassBuilder6" ,"Yes"
Attribute VB_Ext_KEY = "Top_Level" ,"Yes"
'// ----------------------------------------------------------------
'// Object:      MTProperty
'// Description: generic holder of a single property (core or extended).
'//              A property is a the one data fiels of an entity such as
'//              priceable item, or product offering.
'//              A property can have many attributes.
'// ----------------------------------------------------------------

Option Explicit

'=== public properties ======================================================

'// ----------------------------------------------------------------
'// Property:    Value
'// Description: the property value
Public Value       As Variant

'// ----------------------------------------------------------------
'// Property:    Attributes
'// Description: the attributes for this property
Public Attributes  As New MTAttributes

'=== internal properties ====================================================
Public MetaData_ As MTPropertyMetaData

'=== public methods =========================================================

'// ----------------------------------------------------------------
'// Method:      GetMetaData
'// Returns:     MTPropertyMetaData
Public Function GetMetaData() As MTPropertyMetaData
    Set GetMetaData = MetaData_
End Function


Public Property Get Name() As String
    Name = MetaData_.Name
    
End Property

Public Property Get PropertyType() As String
    PropertyType = MetaData_.DataType
    'PropertyType = "STRING"
End Property


Public Property Get Required() As Boolean
    Required = MetaData_.Required
End Property

Public Property Get Length() As Long
    Length = MetaData_.Length
End Property

Public Property Get DefaultValue() As Variant
    DefaultValue = MetaData_.DefaultValue
End Property


Public Property Get Extended() As Boolean
    Extended = MetaData_.Extended
End Property

Public Property Get PropertyGroup() As Boolean
    PropertyGroup = MetaData_.PropertyGroup
End Property


'=== internal methods =======================================================

Public Function ToString() As String
    ToString = "name=" & Name & "; Value=" & Value & "; Type=" & PropertyType & "; Required=" & Required & "; Length=" & Length & ";"
End Function

