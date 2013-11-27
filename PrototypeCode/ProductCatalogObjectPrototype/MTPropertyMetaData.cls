VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MTPropertyMetaData"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
'// ----------------------------------------------------------------
'// Object:      MTPropertyMetaData
'// Description: describes a MTProperty
'// ----------------------------------------------------------------

Option Explicit

'=== public properties ======================================================

'// ----------------------------------------------------------------
'// Property:    Name
'// Description: Property name, aka distinguished name, the name
'//              used in business object (eg. "Description")
Public Name As String

'// ----------------------------------------------------------------
'// Property:    DataType
'// Description: MSIX type. Values are:
'//              int32, string, unistring, timestamp, float, double,
'//              boolean, enum, decimal
Public DataType As String

'// ----------------------------------------------------------------
'// Property:    Length
'// Description: further specifies DataType, for string: max length in chars
Public Length As Integer

'// ----------------------------------------------------------------
'// Property:    Required
'// Description: if true, value must not be NULL
Public Required As Boolean

'// ----------------------------------------------------------------
'// Property:    DefaultValue
'// Description: default value of property
Public DefaultValue As Variant

'// ----------------------------------------------------------------
'// Property:    Extended
'// Description: false for a core property, true for extended
Public Extended As Boolean

'// ----------------------------------------------------------------
'// Property:    PropertyGroup
'// Description: group that this property belongs to, allows grouping
'//              of properties
Public PropertyGroup As String

'// ----------------------------------------------------------------
'// Property:    DBColumnName
'// Description: Name used in database (eg. "m_desc")
Public DBColumnName As String

'// ----------------------------------------------------------------
'// Property:    DBTableName
'// Description: Database table that stores this property
Public DBTableName As String

'// ----------------------------------------------------------------
'// Property:    DBDataType
'// Description: Data type in database. Values are:
'//              int, varchar, ...
Public Property Get DBDataType() As String
    
    ' TODO review mappings
    Select Case DataType
        Case "int32"
            DBDataType = "int"
        Case "string"
            DBDataType = "varchar"
        Case "unistring"
            DBDataType = "varchar"
        Case "timestamp"
            DBDataType = "datetime"
        Case "float"
            DBDataType = "float"
        Case "double"
            DBDataType = "float"
        Case "boolean"
            DBDataType = "char"
        Case "enum"
            DBDataType = "int"
        Case "decimal"
            DBDataType = "decimal"
        Case "object"
            DBDataType = "object" ' // Not Supported
    End Select
End Property


Public Function IsObject() As Boolean
    IsObject = CBool(LCase$(Me.DataType) = "object")
End Function
