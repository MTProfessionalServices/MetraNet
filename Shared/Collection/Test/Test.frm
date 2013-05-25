VERSION 5.00
Begin VB.Form Form1 
   Caption         =   "Form1"
   ClientHeight    =   2556
   ClientLeft      =   48
   ClientTop       =   276
   ClientWidth     =   3744
   LinkTopic       =   "Form1"
   ScaleHeight     =   2556
   ScaleWidth      =   3744
   StartUpPosition =   3  'Windows Default
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private Sub Form_Load()

  Dim o As New StdFont
  Dim o1 As New StdFont
  Dim obj
  
  Dim coll As New MTCollection
  Dim str As String
  
  
  'o.Name = "Test Counter"
  'o.Description = "Testing Counter in generic MTCollectionOnVector"
  
  o.Name = "losfmpvfp"
  
  coll.Add o
  
  
  o1.Name = "Arial"
  o1.Weight = 33
  
  coll.Add o1
  
  For Each obj In coll
    str = obj.Name
  Next
  
  Set obj = coll.Item(1)
  
  str = obj.Name
  
End Sub
