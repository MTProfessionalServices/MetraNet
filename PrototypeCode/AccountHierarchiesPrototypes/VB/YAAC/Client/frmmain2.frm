VERSION 5.00
Begin VB.Form Form1 
   Caption         =   "Form1"
   ClientHeight    =   3195
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   4680
   LinkTopic       =   "Form1"
   ScaleHeight     =   3195
   ScaleWidth      =   4680
   StartUpPosition =   3  'Windows Default
   Begin VB.CommandButton Command2 
      Caption         =   "BUG"
      Height          =   735
      Left            =   0
      TabIndex        =   0
      Top             =   0
      Width           =   2775
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private Sub Command2_Click()
    
    
    Dim objAccountTemplateProperties As New merde.MTAccountTemplateProperties
    Dim objAccountTemplateProperty As merde.MTAccountTemplateProperty
    
    Dim m_objAccountTemplateProperties As New MTYAAC.MTAccountTemplateProperties
    Dim m_objAccountTemplateProperty As MTYAAC.MTAccountTemplateProperty
    
    Debug.Assert 0
    Set objAccountTemplateProperty = objAccountTemplateProperties.Add("NAME", "VALUE")
    
    Set m_objAccountTemplateProperty = m_objAccountTemplateProperties.Add("NAME", "VALUE")
End Sub
