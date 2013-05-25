VERSION 5.00
Object = "{831FDD16-0C5C-11D2-A9FC-0000F8754DA1}#2.0#0"; "mscomctl.ocx"
Begin VB.Form frmView 
   Caption         =   "Product Catalog View"
   ClientHeight    =   5265
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   10200
   LinkTopic       =   "Form1"
   ScaleHeight     =   5265
   ScaleWidth      =   10200
   StartUpPosition =   3  'Windows Default
   Begin MSComctlLib.ImageList ImageList1 
      Left            =   6240
      Top             =   3960
      _ExtentX        =   1005
      _ExtentY        =   1005
      BackColor       =   -2147483643
      ImageWidth      =   16
      ImageHeight     =   16
      MaskColor       =   12632256
      _Version        =   393216
      BeginProperty Images {2C247F25-8591-11D1-B16A-00C0F0283628} 
         NumListImages   =   2
         BeginProperty ListImage1 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmView.frx":0000
            Key             =   "PO"
         EndProperty
         BeginProperty ListImage2 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmView.frx":0452
            Key             =   "Property"
         EndProperty
      EndProperty
   End
   Begin MSComctlLib.TreeView PCTree 
      Height          =   4575
      Left            =   120
      TabIndex        =   0
      Top             =   240
      Width           =   8775
      _ExtentX        =   15478
      _ExtentY        =   8070
      _Version        =   393217
      Indentation     =   450
      LabelEdit       =   1
      LineStyle       =   1
      Style           =   7
      ImageList       =   "ImageList1"
      Appearance      =   1
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   9.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
   End
End
Attribute VB_Name = "frmView"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private PCViewManager As New CPCViewManager

Private Sub Form_Load()
    g_objIniFile.FormSaveRestore Me, False, True
    PCViewManager.Initialize Me.PCTree
    PCViewManager.Load
End Sub

Private Sub Form_Resize()
    PCTree.Left = 0
    PCTree.Top = 0
    PCTree.Width = Me.Width - (10 * Screen.TwipsPerPixelX)
    PCTree.Height = Me.Height - (32 * Screen.TwipsPerPixelX)
End Sub

Private Sub Form_Unload(Cancel As Integer)
    g_objIniFile.FormSaveRestore Me, True, True
End Sub
