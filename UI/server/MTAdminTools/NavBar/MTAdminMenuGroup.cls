VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MTAdminMenuGroup"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Private marrMenuGroups  As Collection
Private marrMenuItems   As Collection
Private marrAllItems    As Collection

Private mstrName             As String





Private Sub Class_Initialize()
    Set marrAllItems = New Collection
    Set marrMenuGroups = New Collection
    Set marrMenuItems = New Collection
End Sub


Private Sub Class_Terminate()
    Set marrAllItems = Nothing
    Set marrMenuGroups = Nothing
    Set marrMenuItems = Nothing
End Sub

Public Property Get All() As Collection
    Set All = marrAllItems
End Property


Public Property Get name() As String
    name = mstrName
End Property


Public Property Let name(vNewValue As String)
    mstrName = vNewValue
End Property


Public Property Get Groups() As Collection
    Set Groups = marrMenuGroups
End Property

Public Property Get Items() As Collection
    Set Items = marrMenuItems
End Property


Public Sub addGroup(ByRef iMenuGroup As MTAdminMenuGroup)
    Call marrMenuGroups.Add(iMenuGroup)
    Call marrAllItems.Add(iMenuGroup)
End Sub


Public Sub addItem(ByRef iMenuItem As MTAdminMenuItem)
    Call marrMenuItems.Add(iMenuItem)
    Call marrAllItems.Add(iMenuItem)
End Sub

