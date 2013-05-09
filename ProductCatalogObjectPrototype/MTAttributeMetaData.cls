VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MTAttributeMetaData"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Attribute VB_Ext_KEY = "SavedWithClassBuilder6" ,"Yes"
Attribute VB_Ext_KEY = "Top_Level" ,"Yes"
'// ----------------------------------------------------------------
'// Object:      MTAttributeMetaData
'// Description: describes an MTAttribute
'// ----------------------------------------------------------------

Option Explicit

'=== public properties ======================================================

'// ----------------------------------------------------------------
'// Property:    Name
'// Description: Name of Attribute
Public Name As String

'// ----------------------------------------------------------------
'// Property:    DefaultValue
'// Description: default value to be used if attribute does not exist
'//              or is NULL
Public DefaultValue As Variant

