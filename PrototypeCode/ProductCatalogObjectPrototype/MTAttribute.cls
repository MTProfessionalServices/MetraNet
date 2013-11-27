VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MTAttribute"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Attribute VB_Ext_KEY = "SavedWithClassBuilder6" ,"Yes"
Attribute VB_Ext_KEY = "Top_Level" ,"Yes"
'// ----------------------------------------------------------------
'// Object:      MTAttribute
'// Description: value of an attribute (one property can have many attributes).
'//              An attribute corresponds to a name/value pair with a default
'//              value. The name and default value are system wide and
'//              therefore stored in MTAttributeMetaData
'// ----------------------------------------------------------------

Option Explicit

'=== public properties ======================================================

'// ----------------------------------------------------------------
'// Property:    Value
'// Description: value of the name/value pair
Public Value As Variant

'=== internal properties ====================================================
Public MetaData_ As MTAttributeMetaData

'=== public methods =========================================================

'// ----------------------------------------------------------------
'// Method:      GetMetaData
'// Returns:     MTAttributeMetaData
Public Function GetMetaData() As MTAttributeMetaData
    Set GetMetaData = MetaData_
End Function

Public Property Get Name() As String
    Name = Me.MetaData_.Name
End Property
