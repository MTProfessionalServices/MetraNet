VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MTAccountTemplateProperty"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Public Class As String
Public Name As String
Public Value As String

Public Sub Initialize(aClass As String, aName As String, aValue As String)
  Class = aClass
  Name = aName
  Value = aValue
End Sub

Public Function ToString() As String
    ToString = "name=" & Name & "; value=" & Value & "; class=" & Class & ";"
End Function
