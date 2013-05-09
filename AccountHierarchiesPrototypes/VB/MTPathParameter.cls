VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MTPathParameter"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Private mStringPath As String
Private mWildCard As WildCard_

Public Property Let Path(vData As String)
  mStringPath = vData
End Property

Public Property Get Path() As String
  Path = mStringPath
End Property

Public Property Let WildCard(ByVal vData As WildCard_)
  mWildCard = vData
End Property


Public Property Get WildCard() As WildCard_
  WildCard = mWildCard
End Property

