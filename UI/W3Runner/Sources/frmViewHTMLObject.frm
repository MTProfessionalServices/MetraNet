VERSION 5.00
Object = "{831FDD16-0C5C-11D2-A9FC-0000F8754DA1}#2.0#0"; "Mscomctl.ocx"
Begin VB.Form frmViewHTMLObject 
   Caption         =   "Watch Window"
   ClientHeight    =   7065
   ClientLeft      =   165
   ClientTop       =   855
   ClientWidth     =   10350
   Icon            =   "frmViewHTMLObject.frx":0000
   KeyPreview      =   -1  'True
   LinkTopic       =   "Form1"
   ScaleHeight     =   7065
   ScaleWidth      =   10350
   StartUpPosition =   3  'Windows Default
   Begin VB.PictureBox picSplitter 
      BackColor       =   &H00808080&
      BorderStyle     =   0  'None
      FillColor       =   &H00808080&
      Height          =   3540
      Left            =   4860
      ScaleHeight     =   1541.468
      ScaleMode       =   0  'User
      ScaleWidth      =   780
      TabIndex        =   3
      Top             =   0
      Visible         =   0   'False
      Width           =   72
   End
   Begin VB.TextBox txtGenerated 
      Height          =   1095
      Left            =   840
      MultiLine       =   -1  'True
      ScrollBars      =   2  'Vertical
      TabIndex        =   2
      Top             =   3900
      Width           =   2295
   End
   Begin MSComctlLib.StatusBar StatusBar1 
      Align           =   2  'Align Bottom
      Height          =   375
      Left            =   0
      TabIndex        =   1
      Top             =   6690
      Width           =   10350
      _ExtentX        =   18256
      _ExtentY        =   661
      _Version        =   393216
      BeginProperty Panels {8E3867A5-8586-11D1-B16A-00C0F0283628} 
         NumPanels       =   2
         BeginProperty Panel1 {8E3867AB-8586-11D1-B16A-00C0F0283628} 
            AutoSize        =   1
            Object.Width           =   8837
         EndProperty
         BeginProperty Panel2 {8E3867AB-8586-11D1-B16A-00C0F0283628} 
            AutoSize        =   1
            Object.Width           =   8837
         EndProperty
      EndProperty
   End
   Begin MSComctlLib.ListView lvWatchMode 
      Height          =   3135
      Left            =   960
      TabIndex        =   0
      Top             =   300
      Width           =   6495
      _ExtentX        =   11456
      _ExtentY        =   5530
      View            =   3
      LabelEdit       =   1
      LabelWrap       =   -1  'True
      HideSelection   =   -1  'True
      FullRowSelect   =   -1  'True
      GridLines       =   -1  'True
      _Version        =   393217
      SmallIcons      =   "ImageList1"
      ForeColor       =   -2147483640
      BackColor       =   -2147483643
      BorderStyle     =   1
      Appearance      =   1
      NumItems        =   0
   End
   Begin MSComctlLib.ImageList ImageList1 
      Left            =   5040
      Top             =   3900
      _ExtentX        =   1005
      _ExtentY        =   1005
      BackColor       =   -2147483643
      ImageWidth      =   16
      ImageHeight     =   16
      MaskColor       =   12632256
      _Version        =   393216
      BeginProperty Images {2C247F25-8591-11D1-B16A-00C0F0283628} 
         NumListImages   =   1
         BeginProperty ListImage1 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmViewHTMLObject.frx":0E42
            Key             =   "Object"
         EndProperty
      EndProperty
   End
   Begin VB.Image imgSplitterDown 
      Height          =   165
      Left            =   0
      MousePointer    =   7  'Size N S
      Top             =   3480
      Visible         =   0   'False
      Width           =   9390
   End
   Begin VB.Menu mnuMouseRightClick 
      Caption         =   "MouseRightClick"
      Begin VB.Menu mnuCopyName 
         Caption         =   "Copy Name"
      End
      Begin VB.Menu mnuRefresh 
         Caption         =   "Refresh"
         Shortcut        =   {F5}
      End
   End
End
Attribute VB_Name = "frmViewHTMLObject"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Const sglSplitLimit = 1000
Private mbMoving                        As Boolean
Private m_lngTxtGeneratedHeightSize     As Long

Private m_objFrm As frmMain

Private m_booCancelReadingObjectDefinition As Boolean
Private m_lngObjectCounter As Long

Const MAX_IE_OBJECTS = 128

Private WithEvents ieObj_HTMLTextAreaElement0  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement0.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement0     As HTMLInputElement
Attribute ieObj_HTMLInputElement0.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement0    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement0.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement0    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement0.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement0    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement0.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg0              As HTMLImg
Attribute ieObj_HTMLImg0.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell0        As HTMLTableCell
Attribute ieObj_HTMLTableCell0.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement0       As HTMLDivElement
Attribute ieObj_HTMLDivElement0.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement1  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement1.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement1     As HTMLInputElement
Attribute ieObj_HTMLInputElement1.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement1    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement1.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement1    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement1.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement1    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement1.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg1              As HTMLImg
Attribute ieObj_HTMLImg1.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell1        As HTMLTableCell
Attribute ieObj_HTMLTableCell1.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement1       As HTMLDivElement
Attribute ieObj_HTMLDivElement1.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement2  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement2.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement2     As HTMLInputElement
Attribute ieObj_HTMLInputElement2.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement2    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement2.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement2    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement2.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement2    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement2.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg2              As HTMLImg
Attribute ieObj_HTMLImg2.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell2        As HTMLTableCell
Attribute ieObj_HTMLTableCell2.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement2       As HTMLDivElement
Attribute ieObj_HTMLDivElement2.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement3  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement3.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement3     As HTMLInputElement
Attribute ieObj_HTMLInputElement3.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement3    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement3.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement3    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement3.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement3    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement3.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg3              As HTMLImg
Attribute ieObj_HTMLImg3.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell3        As HTMLTableCell
Attribute ieObj_HTMLTableCell3.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement3       As HTMLDivElement
Attribute ieObj_HTMLDivElement3.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement4  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement4.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement4     As HTMLInputElement
Attribute ieObj_HTMLInputElement4.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement4    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement4.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement4    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement4.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement4    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement4.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg4              As HTMLImg
Attribute ieObj_HTMLImg4.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell4        As HTMLTableCell
Attribute ieObj_HTMLTableCell4.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement4       As HTMLDivElement
Attribute ieObj_HTMLDivElement4.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement5  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement5.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement5     As HTMLInputElement
Attribute ieObj_HTMLInputElement5.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement5    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement5.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement5    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement5.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement5    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement5.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg5              As HTMLImg
Attribute ieObj_HTMLImg5.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell5        As HTMLTableCell
Attribute ieObj_HTMLTableCell5.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement5       As HTMLDivElement
Attribute ieObj_HTMLDivElement5.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement6  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement6.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement6     As HTMLInputElement
Attribute ieObj_HTMLInputElement6.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement6    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement6.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement6    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement6.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement6    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement6.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg6              As HTMLImg
Attribute ieObj_HTMLImg6.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell6        As HTMLTableCell
Attribute ieObj_HTMLTableCell6.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement6       As HTMLDivElement
Attribute ieObj_HTMLDivElement6.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement7  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement7.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement7     As HTMLInputElement
Attribute ieObj_HTMLInputElement7.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement7    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement7.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement7    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement7.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement7    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement7.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg7              As HTMLImg
Attribute ieObj_HTMLImg7.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell7        As HTMLTableCell
Attribute ieObj_HTMLTableCell7.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement7       As HTMLDivElement
Attribute ieObj_HTMLDivElement7.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement8  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement8.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement8     As HTMLInputElement
Attribute ieObj_HTMLInputElement8.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement8    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement8.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement8    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement8.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement8    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement8.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg8              As HTMLImg
Attribute ieObj_HTMLImg8.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell8        As HTMLTableCell
Attribute ieObj_HTMLTableCell8.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement8       As HTMLDivElement
Attribute ieObj_HTMLDivElement8.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement9  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement9.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement9     As HTMLInputElement
Attribute ieObj_HTMLInputElement9.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement9    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement9.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement9    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement9.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement9    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement9.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg9              As HTMLImg
Attribute ieObj_HTMLImg9.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell9        As HTMLTableCell
Attribute ieObj_HTMLTableCell9.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement9       As HTMLDivElement
Attribute ieObj_HTMLDivElement9.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement10  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement10.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement10     As HTMLInputElement
Attribute ieObj_HTMLInputElement10.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement10    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement10.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement10    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement10.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement10    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement10.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg10              As HTMLImg
Attribute ieObj_HTMLImg10.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell10        As HTMLTableCell
Attribute ieObj_HTMLTableCell10.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement10       As HTMLDivElement
Attribute ieObj_HTMLDivElement10.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement11  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement11.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement11     As HTMLInputElement
Attribute ieObj_HTMLInputElement11.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement11    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement11.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement11    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement11.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement11    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement11.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg11              As HTMLImg
Attribute ieObj_HTMLImg11.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell11        As HTMLTableCell
Attribute ieObj_HTMLTableCell11.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement11       As HTMLDivElement
Attribute ieObj_HTMLDivElement11.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement12  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement12.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement12     As HTMLInputElement
Attribute ieObj_HTMLInputElement12.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement12    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement12.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement12    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement12.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement12    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement12.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg12              As HTMLImg
Attribute ieObj_HTMLImg12.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell12        As HTMLTableCell
Attribute ieObj_HTMLTableCell12.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement12       As HTMLDivElement
Attribute ieObj_HTMLDivElement12.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement13  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement13.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement13     As HTMLInputElement
Attribute ieObj_HTMLInputElement13.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement13    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement13.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement13    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement13.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement13    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement13.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg13              As HTMLImg
Attribute ieObj_HTMLImg13.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell13        As HTMLTableCell
Attribute ieObj_HTMLTableCell13.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement13       As HTMLDivElement
Attribute ieObj_HTMLDivElement13.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement14  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement14.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement14     As HTMLInputElement
Attribute ieObj_HTMLInputElement14.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement14    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement14.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement14    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement14.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement14    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement14.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg14              As HTMLImg
Attribute ieObj_HTMLImg14.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell14        As HTMLTableCell
Attribute ieObj_HTMLTableCell14.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement14       As HTMLDivElement
Attribute ieObj_HTMLDivElement14.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement15  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement15.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement15     As HTMLInputElement
Attribute ieObj_HTMLInputElement15.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement15    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement15.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement15    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement15.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement15    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement15.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg15              As HTMLImg
Attribute ieObj_HTMLImg15.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell15        As HTMLTableCell
Attribute ieObj_HTMLTableCell15.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement15       As HTMLDivElement
Attribute ieObj_HTMLDivElement15.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement16  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement16.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement16     As HTMLInputElement
Attribute ieObj_HTMLInputElement16.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement16    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement16.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement16    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement16.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement16    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement16.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg16              As HTMLImg
Attribute ieObj_HTMLImg16.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell16        As HTMLTableCell
Attribute ieObj_HTMLTableCell16.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement16       As HTMLDivElement
Attribute ieObj_HTMLDivElement16.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement17  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement17.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement17     As HTMLInputElement
Attribute ieObj_HTMLInputElement17.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement17    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement17.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement17    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement17.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement17    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement17.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg17              As HTMLImg
Attribute ieObj_HTMLImg17.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell17        As HTMLTableCell
Attribute ieObj_HTMLTableCell17.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement17       As HTMLDivElement
Attribute ieObj_HTMLDivElement17.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement18  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement18.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement18     As HTMLInputElement
Attribute ieObj_HTMLInputElement18.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement18    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement18.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement18    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement18.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement18    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement18.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg18              As HTMLImg
Attribute ieObj_HTMLImg18.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell18        As HTMLTableCell
Attribute ieObj_HTMLTableCell18.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement18       As HTMLDivElement
Attribute ieObj_HTMLDivElement18.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement19  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement19.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement19     As HTMLInputElement
Attribute ieObj_HTMLInputElement19.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement19    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement19.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement19    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement19.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement19    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement19.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg19              As HTMLImg
Attribute ieObj_HTMLImg19.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell19        As HTMLTableCell
Attribute ieObj_HTMLTableCell19.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement19       As HTMLDivElement
Attribute ieObj_HTMLDivElement19.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement20  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement20.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement20     As HTMLInputElement
Attribute ieObj_HTMLInputElement20.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement20    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement20.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement20    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement20.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement20    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement20.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg20              As HTMLImg
Attribute ieObj_HTMLImg20.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell20        As HTMLTableCell
Attribute ieObj_HTMLTableCell20.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement20       As HTMLDivElement
Attribute ieObj_HTMLDivElement20.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement21  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement21.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement21     As HTMLInputElement
Attribute ieObj_HTMLInputElement21.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement21    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement21.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement21    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement21.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement21    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement21.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg21              As HTMLImg
Attribute ieObj_HTMLImg21.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell21        As HTMLTableCell
Attribute ieObj_HTMLTableCell21.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement21       As HTMLDivElement
Attribute ieObj_HTMLDivElement21.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement22  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement22.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement22     As HTMLInputElement
Attribute ieObj_HTMLInputElement22.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement22    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement22.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement22    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement22.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement22    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement22.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg22              As HTMLImg
Attribute ieObj_HTMLImg22.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell22        As HTMLTableCell
Attribute ieObj_HTMLTableCell22.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement22       As HTMLDivElement
Attribute ieObj_HTMLDivElement22.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement23  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement23.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement23     As HTMLInputElement
Attribute ieObj_HTMLInputElement23.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement23    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement23.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement23    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement23.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement23    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement23.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg23              As HTMLImg
Attribute ieObj_HTMLImg23.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell23        As HTMLTableCell
Attribute ieObj_HTMLTableCell23.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement23       As HTMLDivElement
Attribute ieObj_HTMLDivElement23.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement24  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement24.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement24     As HTMLInputElement
Attribute ieObj_HTMLInputElement24.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement24    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement24.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement24    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement24.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement24    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement24.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg24              As HTMLImg
Attribute ieObj_HTMLImg24.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell24        As HTMLTableCell
Attribute ieObj_HTMLTableCell24.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement24       As HTMLDivElement
Attribute ieObj_HTMLDivElement24.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement25  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement25.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement25     As HTMLInputElement
Attribute ieObj_HTMLInputElement25.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement25    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement25.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement25    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement25.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement25    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement25.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg25              As HTMLImg
Attribute ieObj_HTMLImg25.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell25        As HTMLTableCell
Attribute ieObj_HTMLTableCell25.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement25       As HTMLDivElement
Attribute ieObj_HTMLDivElement25.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement26  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement26.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement26     As HTMLInputElement
Attribute ieObj_HTMLInputElement26.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement26    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement26.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement26    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement26.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement26    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement26.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg26              As HTMLImg
Attribute ieObj_HTMLImg26.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell26        As HTMLTableCell
Attribute ieObj_HTMLTableCell26.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement26       As HTMLDivElement
Attribute ieObj_HTMLDivElement26.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement27  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement27.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement27     As HTMLInputElement
Attribute ieObj_HTMLInputElement27.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement27    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement27.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement27    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement27.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement27    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement27.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg27              As HTMLImg
Attribute ieObj_HTMLImg27.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell27        As HTMLTableCell
Attribute ieObj_HTMLTableCell27.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement27       As HTMLDivElement
Attribute ieObj_HTMLDivElement27.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement28  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement28.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement28     As HTMLInputElement
Attribute ieObj_HTMLInputElement28.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement28    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement28.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement28    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement28.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement28    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement28.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg28              As HTMLImg
Attribute ieObj_HTMLImg28.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell28        As HTMLTableCell
Attribute ieObj_HTMLTableCell28.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement28       As HTMLDivElement
Attribute ieObj_HTMLDivElement28.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement29  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement29.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement29     As HTMLInputElement
Attribute ieObj_HTMLInputElement29.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement29    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement29.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement29    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement29.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement29    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement29.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg29              As HTMLImg
Attribute ieObj_HTMLImg29.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell29        As HTMLTableCell
Attribute ieObj_HTMLTableCell29.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement29       As HTMLDivElement
Attribute ieObj_HTMLDivElement29.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement30  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement30.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement30     As HTMLInputElement
Attribute ieObj_HTMLInputElement30.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement30    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement30.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement30    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement30.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement30    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement30.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg30              As HTMLImg
Attribute ieObj_HTMLImg30.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell30        As HTMLTableCell
Attribute ieObj_HTMLTableCell30.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement30       As HTMLDivElement
Attribute ieObj_HTMLDivElement30.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement31  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement31.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement31     As HTMLInputElement
Attribute ieObj_HTMLInputElement31.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement31    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement31.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement31    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement31.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement31    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement31.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg31              As HTMLImg
Attribute ieObj_HTMLImg31.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell31        As HTMLTableCell
Attribute ieObj_HTMLTableCell31.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement31       As HTMLDivElement
Attribute ieObj_HTMLDivElement31.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement32  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement32.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement32     As HTMLInputElement
Attribute ieObj_HTMLInputElement32.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement32    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement32.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement32    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement32.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement32    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement32.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg32              As HTMLImg
Attribute ieObj_HTMLImg32.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell32        As HTMLTableCell
Attribute ieObj_HTMLTableCell32.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement32       As HTMLDivElement
Attribute ieObj_HTMLDivElement32.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement33  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement33.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement33     As HTMLInputElement
Attribute ieObj_HTMLInputElement33.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement33    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement33.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement33    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement33.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement33    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement33.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg33              As HTMLImg
Attribute ieObj_HTMLImg33.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell33        As HTMLTableCell
Attribute ieObj_HTMLTableCell33.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement33       As HTMLDivElement
Attribute ieObj_HTMLDivElement33.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement34  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement34.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement34     As HTMLInputElement
Attribute ieObj_HTMLInputElement34.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement34    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement34.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement34    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement34.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement34    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement34.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg34              As HTMLImg
Attribute ieObj_HTMLImg34.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell34        As HTMLTableCell
Attribute ieObj_HTMLTableCell34.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement34       As HTMLDivElement
Attribute ieObj_HTMLDivElement34.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement35  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement35.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement35     As HTMLInputElement
Attribute ieObj_HTMLInputElement35.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement35    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement35.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement35    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement35.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement35    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement35.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg35              As HTMLImg
Attribute ieObj_HTMLImg35.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell35        As HTMLTableCell
Attribute ieObj_HTMLTableCell35.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement35       As HTMLDivElement
Attribute ieObj_HTMLDivElement35.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement36  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement36.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement36     As HTMLInputElement
Attribute ieObj_HTMLInputElement36.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement36    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement36.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement36    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement36.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement36    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement36.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg36              As HTMLImg
Attribute ieObj_HTMLImg36.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell36        As HTMLTableCell
Attribute ieObj_HTMLTableCell36.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement36       As HTMLDivElement
Attribute ieObj_HTMLDivElement36.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement37  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement37.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement37     As HTMLInputElement
Attribute ieObj_HTMLInputElement37.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement37    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement37.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement37    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement37.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement37    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement37.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg37              As HTMLImg
Attribute ieObj_HTMLImg37.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell37        As HTMLTableCell
Attribute ieObj_HTMLTableCell37.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement37       As HTMLDivElement
Attribute ieObj_HTMLDivElement37.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement38  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement38.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement38     As HTMLInputElement
Attribute ieObj_HTMLInputElement38.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement38    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement38.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement38    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement38.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement38    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement38.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg38              As HTMLImg
Attribute ieObj_HTMLImg38.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell38        As HTMLTableCell
Attribute ieObj_HTMLTableCell38.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement38       As HTMLDivElement
Attribute ieObj_HTMLDivElement38.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement39  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement39.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement39     As HTMLInputElement
Attribute ieObj_HTMLInputElement39.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement39    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement39.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement39    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement39.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement39    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement39.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg39              As HTMLImg
Attribute ieObj_HTMLImg39.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell39        As HTMLTableCell
Attribute ieObj_HTMLTableCell39.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement39       As HTMLDivElement
Attribute ieObj_HTMLDivElement39.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement40  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement40.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement40     As HTMLInputElement
Attribute ieObj_HTMLInputElement40.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement40    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement40.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement40    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement40.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement40    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement40.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg40              As HTMLImg
Attribute ieObj_HTMLImg40.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell40        As HTMLTableCell
Attribute ieObj_HTMLTableCell40.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement40       As HTMLDivElement
Attribute ieObj_HTMLDivElement40.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement41  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement41.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement41     As HTMLInputElement
Attribute ieObj_HTMLInputElement41.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement41    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement41.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement41    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement41.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement41    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement41.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg41              As HTMLImg
Attribute ieObj_HTMLImg41.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell41        As HTMLTableCell
Attribute ieObj_HTMLTableCell41.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement41       As HTMLDivElement
Attribute ieObj_HTMLDivElement41.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement42  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement42.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement42     As HTMLInputElement
Attribute ieObj_HTMLInputElement42.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement42    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement42.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement42    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement42.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement42    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement42.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg42              As HTMLImg
Attribute ieObj_HTMLImg42.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell42        As HTMLTableCell
Attribute ieObj_HTMLTableCell42.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement42       As HTMLDivElement
Attribute ieObj_HTMLDivElement42.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement43  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement43.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement43     As HTMLInputElement
Attribute ieObj_HTMLInputElement43.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement43    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement43.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement43    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement43.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement43    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement43.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg43              As HTMLImg
Attribute ieObj_HTMLImg43.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell43        As HTMLTableCell
Attribute ieObj_HTMLTableCell43.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement43       As HTMLDivElement
Attribute ieObj_HTMLDivElement43.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement44  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement44.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement44     As HTMLInputElement
Attribute ieObj_HTMLInputElement44.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement44    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement44.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement44    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement44.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement44    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement44.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg44              As HTMLImg
Attribute ieObj_HTMLImg44.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell44        As HTMLTableCell
Attribute ieObj_HTMLTableCell44.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement44       As HTMLDivElement
Attribute ieObj_HTMLDivElement44.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement45  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement45.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement45     As HTMLInputElement
Attribute ieObj_HTMLInputElement45.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement45    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement45.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement45    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement45.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement45    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement45.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg45              As HTMLImg
Attribute ieObj_HTMLImg45.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell45        As HTMLTableCell
Attribute ieObj_HTMLTableCell45.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement45       As HTMLDivElement
Attribute ieObj_HTMLDivElement45.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement46  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement46.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement46     As HTMLInputElement
Attribute ieObj_HTMLInputElement46.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement46    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement46.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement46    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement46.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement46    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement46.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg46              As HTMLImg
Attribute ieObj_HTMLImg46.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell46        As HTMLTableCell
Attribute ieObj_HTMLTableCell46.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement46       As HTMLDivElement
Attribute ieObj_HTMLDivElement46.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement47  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement47.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement47     As HTMLInputElement
Attribute ieObj_HTMLInputElement47.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement47    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement47.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement47    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement47.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement47    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement47.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg47              As HTMLImg
Attribute ieObj_HTMLImg47.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell47        As HTMLTableCell
Attribute ieObj_HTMLTableCell47.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement47       As HTMLDivElement
Attribute ieObj_HTMLDivElement47.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement48  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement48.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement48     As HTMLInputElement
Attribute ieObj_HTMLInputElement48.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement48    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement48.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement48    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement48.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement48    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement48.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg48              As HTMLImg
Attribute ieObj_HTMLImg48.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell48        As HTMLTableCell
Attribute ieObj_HTMLTableCell48.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement48       As HTMLDivElement
Attribute ieObj_HTMLDivElement48.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement49  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement49.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement49     As HTMLInputElement
Attribute ieObj_HTMLInputElement49.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement49    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement49.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement49    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement49.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement49    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement49.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg49              As HTMLImg
Attribute ieObj_HTMLImg49.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell49        As HTMLTableCell
Attribute ieObj_HTMLTableCell49.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement49       As HTMLDivElement
Attribute ieObj_HTMLDivElement49.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement50  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement50.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement50     As HTMLInputElement
Attribute ieObj_HTMLInputElement50.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement50    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement50.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement50    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement50.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement50    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement50.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg50              As HTMLImg
Attribute ieObj_HTMLImg50.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell50        As HTMLTableCell
Attribute ieObj_HTMLTableCell50.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement50       As HTMLDivElement
Attribute ieObj_HTMLDivElement50.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement51  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement51.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement51     As HTMLInputElement
Attribute ieObj_HTMLInputElement51.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement51    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement51.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement51    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement51.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement51    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement51.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg51              As HTMLImg
Attribute ieObj_HTMLImg51.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell51        As HTMLTableCell
Attribute ieObj_HTMLTableCell51.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement51       As HTMLDivElement
Attribute ieObj_HTMLDivElement51.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement52  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement52.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement52     As HTMLInputElement
Attribute ieObj_HTMLInputElement52.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement52    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement52.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement52    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement52.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement52    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement52.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg52              As HTMLImg
Attribute ieObj_HTMLImg52.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell52        As HTMLTableCell
Attribute ieObj_HTMLTableCell52.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement52       As HTMLDivElement
Attribute ieObj_HTMLDivElement52.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement53  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement53.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement53     As HTMLInputElement
Attribute ieObj_HTMLInputElement53.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement53    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement53.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement53    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement53.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement53    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement53.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg53              As HTMLImg
Attribute ieObj_HTMLImg53.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell53        As HTMLTableCell
Attribute ieObj_HTMLTableCell53.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement53       As HTMLDivElement
Attribute ieObj_HTMLDivElement53.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement54  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement54.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement54     As HTMLInputElement
Attribute ieObj_HTMLInputElement54.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement54    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement54.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement54    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement54.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement54    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement54.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg54              As HTMLImg
Attribute ieObj_HTMLImg54.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell54        As HTMLTableCell
Attribute ieObj_HTMLTableCell54.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement54       As HTMLDivElement
Attribute ieObj_HTMLDivElement54.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement55  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement55.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement55     As HTMLInputElement
Attribute ieObj_HTMLInputElement55.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement55    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement55.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement55    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement55.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement55    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement55.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg55              As HTMLImg
Attribute ieObj_HTMLImg55.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell55        As HTMLTableCell
Attribute ieObj_HTMLTableCell55.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement55       As HTMLDivElement
Attribute ieObj_HTMLDivElement55.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement56  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement56.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement56     As HTMLInputElement
Attribute ieObj_HTMLInputElement56.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement56    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement56.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement56    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement56.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement56    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement56.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg56              As HTMLImg
Attribute ieObj_HTMLImg56.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell56        As HTMLTableCell
Attribute ieObj_HTMLTableCell56.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement56       As HTMLDivElement
Attribute ieObj_HTMLDivElement56.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement57  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement57.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement57     As HTMLInputElement
Attribute ieObj_HTMLInputElement57.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement57    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement57.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement57    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement57.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement57    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement57.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg57              As HTMLImg
Attribute ieObj_HTMLImg57.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell57        As HTMLTableCell
Attribute ieObj_HTMLTableCell57.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement57       As HTMLDivElement
Attribute ieObj_HTMLDivElement57.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement58  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement58.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement58     As HTMLInputElement
Attribute ieObj_HTMLInputElement58.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement58    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement58.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement58    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement58.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement58    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement58.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg58              As HTMLImg
Attribute ieObj_HTMLImg58.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell58        As HTMLTableCell
Attribute ieObj_HTMLTableCell58.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement58       As HTMLDivElement
Attribute ieObj_HTMLDivElement58.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement59  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement59.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement59     As HTMLInputElement
Attribute ieObj_HTMLInputElement59.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement59    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement59.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement59    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement59.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement59    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement59.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg59              As HTMLImg
Attribute ieObj_HTMLImg59.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell59        As HTMLTableCell
Attribute ieObj_HTMLTableCell59.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement59       As HTMLDivElement
Attribute ieObj_HTMLDivElement59.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement60  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement60.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement60     As HTMLInputElement
Attribute ieObj_HTMLInputElement60.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement60    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement60.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement60    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement60.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement60    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement60.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg60              As HTMLImg
Attribute ieObj_HTMLImg60.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell60        As HTMLTableCell
Attribute ieObj_HTMLTableCell60.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement60       As HTMLDivElement
Attribute ieObj_HTMLDivElement60.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement61  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement61.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement61     As HTMLInputElement
Attribute ieObj_HTMLInputElement61.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement61    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement61.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement61    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement61.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement61    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement61.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg61              As HTMLImg
Attribute ieObj_HTMLImg61.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell61        As HTMLTableCell
Attribute ieObj_HTMLTableCell61.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement61       As HTMLDivElement
Attribute ieObj_HTMLDivElement61.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement62  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement62.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement62     As HTMLInputElement
Attribute ieObj_HTMLInputElement62.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement62    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement62.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement62    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement62.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement62    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement62.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg62              As HTMLImg
Attribute ieObj_HTMLImg62.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell62        As HTMLTableCell
Attribute ieObj_HTMLTableCell62.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement62       As HTMLDivElement
Attribute ieObj_HTMLDivElement62.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement63  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement63.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement63     As HTMLInputElement
Attribute ieObj_HTMLInputElement63.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement63    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement63.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement63    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement63.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement63    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement63.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg63              As HTMLImg
Attribute ieObj_HTMLImg63.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell63        As HTMLTableCell
Attribute ieObj_HTMLTableCell63.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement63       As HTMLDivElement
Attribute ieObj_HTMLDivElement63.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement64  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement64.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement64     As HTMLInputElement
Attribute ieObj_HTMLInputElement64.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement64    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement64.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement64    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement64.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement64    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement64.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg64              As HTMLImg
Attribute ieObj_HTMLImg64.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell64        As HTMLTableCell
Attribute ieObj_HTMLTableCell64.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement64       As HTMLDivElement
Attribute ieObj_HTMLDivElement64.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement65  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement65.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement65     As HTMLInputElement
Attribute ieObj_HTMLInputElement65.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement65    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement65.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement65    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement65.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement65    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement65.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg65              As HTMLImg
Attribute ieObj_HTMLImg65.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell65        As HTMLTableCell
Attribute ieObj_HTMLTableCell65.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement65       As HTMLDivElement
Attribute ieObj_HTMLDivElement65.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement66  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement66.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement66     As HTMLInputElement
Attribute ieObj_HTMLInputElement66.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement66    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement66.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement66    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement66.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement66    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement66.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg66              As HTMLImg
Attribute ieObj_HTMLImg66.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell66        As HTMLTableCell
Attribute ieObj_HTMLTableCell66.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement66       As HTMLDivElement
Attribute ieObj_HTMLDivElement66.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement67  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement67.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement67     As HTMLInputElement
Attribute ieObj_HTMLInputElement67.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement67    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement67.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement67    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement67.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement67    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement67.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg67              As HTMLImg
Attribute ieObj_HTMLImg67.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell67        As HTMLTableCell
Attribute ieObj_HTMLTableCell67.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement67       As HTMLDivElement
Attribute ieObj_HTMLDivElement67.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement68  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement68.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement68     As HTMLInputElement
Attribute ieObj_HTMLInputElement68.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement68    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement68.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement68    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement68.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement68    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement68.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg68              As HTMLImg
Attribute ieObj_HTMLImg68.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell68        As HTMLTableCell
Attribute ieObj_HTMLTableCell68.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement68       As HTMLDivElement
Attribute ieObj_HTMLDivElement68.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement69  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement69.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement69     As HTMLInputElement
Attribute ieObj_HTMLInputElement69.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement69    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement69.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement69    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement69.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement69    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement69.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg69              As HTMLImg
Attribute ieObj_HTMLImg69.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell69        As HTMLTableCell
Attribute ieObj_HTMLTableCell69.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement69       As HTMLDivElement
Attribute ieObj_HTMLDivElement69.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement70  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement70.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement70     As HTMLInputElement
Attribute ieObj_HTMLInputElement70.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement70    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement70.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement70    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement70.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement70    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement70.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg70              As HTMLImg
Attribute ieObj_HTMLImg70.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell70        As HTMLTableCell
Attribute ieObj_HTMLTableCell70.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement70       As HTMLDivElement
Attribute ieObj_HTMLDivElement70.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement71  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement71.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement71     As HTMLInputElement
Attribute ieObj_HTMLInputElement71.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement71    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement71.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement71    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement71.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement71    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement71.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg71              As HTMLImg
Attribute ieObj_HTMLImg71.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell71        As HTMLTableCell
Attribute ieObj_HTMLTableCell71.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement71       As HTMLDivElement
Attribute ieObj_HTMLDivElement71.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement72  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement72.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement72     As HTMLInputElement
Attribute ieObj_HTMLInputElement72.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement72    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement72.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement72    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement72.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement72    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement72.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg72              As HTMLImg
Attribute ieObj_HTMLImg72.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell72        As HTMLTableCell
Attribute ieObj_HTMLTableCell72.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement72       As HTMLDivElement
Attribute ieObj_HTMLDivElement72.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement73  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement73.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement73     As HTMLInputElement
Attribute ieObj_HTMLInputElement73.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement73    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement73.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement73    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement73.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement73    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement73.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg73              As HTMLImg
Attribute ieObj_HTMLImg73.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell73        As HTMLTableCell
Attribute ieObj_HTMLTableCell73.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement73       As HTMLDivElement
Attribute ieObj_HTMLDivElement73.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement74  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement74.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement74     As HTMLInputElement
Attribute ieObj_HTMLInputElement74.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement74    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement74.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement74    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement74.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement74    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement74.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg74              As HTMLImg
Attribute ieObj_HTMLImg74.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell74        As HTMLTableCell
Attribute ieObj_HTMLTableCell74.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement74       As HTMLDivElement
Attribute ieObj_HTMLDivElement74.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement75  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement75.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement75     As HTMLInputElement
Attribute ieObj_HTMLInputElement75.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement75    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement75.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement75    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement75.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement75    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement75.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg75              As HTMLImg
Attribute ieObj_HTMLImg75.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell75        As HTMLTableCell
Attribute ieObj_HTMLTableCell75.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement75       As HTMLDivElement
Attribute ieObj_HTMLDivElement75.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement76  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement76.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement76     As HTMLInputElement
Attribute ieObj_HTMLInputElement76.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement76    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement76.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement76    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement76.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement76    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement76.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg76              As HTMLImg
Attribute ieObj_HTMLImg76.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell76        As HTMLTableCell
Attribute ieObj_HTMLTableCell76.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement76       As HTMLDivElement
Attribute ieObj_HTMLDivElement76.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement77  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement77.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement77     As HTMLInputElement
Attribute ieObj_HTMLInputElement77.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement77    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement77.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement77    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement77.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement77    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement77.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg77              As HTMLImg
Attribute ieObj_HTMLImg77.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell77        As HTMLTableCell
Attribute ieObj_HTMLTableCell77.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement77       As HTMLDivElement
Attribute ieObj_HTMLDivElement77.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement78  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement78.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement78     As HTMLInputElement
Attribute ieObj_HTMLInputElement78.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement78    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement78.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement78    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement78.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement78    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement78.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg78              As HTMLImg
Attribute ieObj_HTMLImg78.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell78        As HTMLTableCell
Attribute ieObj_HTMLTableCell78.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement78       As HTMLDivElement
Attribute ieObj_HTMLDivElement78.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement79  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement79.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement79     As HTMLInputElement
Attribute ieObj_HTMLInputElement79.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement79    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement79.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement79    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement79.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement79    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement79.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg79              As HTMLImg
Attribute ieObj_HTMLImg79.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell79        As HTMLTableCell
Attribute ieObj_HTMLTableCell79.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement79       As HTMLDivElement
Attribute ieObj_HTMLDivElement79.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement80  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement80.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement80     As HTMLInputElement
Attribute ieObj_HTMLInputElement80.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement80    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement80.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement80    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement80.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement80    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement80.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg80              As HTMLImg
Attribute ieObj_HTMLImg80.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell80        As HTMLTableCell
Attribute ieObj_HTMLTableCell80.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement80       As HTMLDivElement
Attribute ieObj_HTMLDivElement80.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement81  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement81.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement81     As HTMLInputElement
Attribute ieObj_HTMLInputElement81.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement81    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement81.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement81    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement81.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement81    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement81.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg81              As HTMLImg
Attribute ieObj_HTMLImg81.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell81        As HTMLTableCell
Attribute ieObj_HTMLTableCell81.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement81       As HTMLDivElement
Attribute ieObj_HTMLDivElement81.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement82  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement82.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement82     As HTMLInputElement
Attribute ieObj_HTMLInputElement82.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement82    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement82.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement82    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement82.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement82    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement82.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg82              As HTMLImg
Attribute ieObj_HTMLImg82.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell82        As HTMLTableCell
Attribute ieObj_HTMLTableCell82.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement82       As HTMLDivElement
Attribute ieObj_HTMLDivElement82.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement83  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement83.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement83     As HTMLInputElement
Attribute ieObj_HTMLInputElement83.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement83    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement83.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement83    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement83.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement83    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement83.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg83              As HTMLImg
Attribute ieObj_HTMLImg83.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell83        As HTMLTableCell
Attribute ieObj_HTMLTableCell83.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement83       As HTMLDivElement
Attribute ieObj_HTMLDivElement83.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement84  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement84.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement84     As HTMLInputElement
Attribute ieObj_HTMLInputElement84.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement84    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement84.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement84    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement84.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement84    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement84.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg84              As HTMLImg
Attribute ieObj_HTMLImg84.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell84        As HTMLTableCell
Attribute ieObj_HTMLTableCell84.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement84       As HTMLDivElement
Attribute ieObj_HTMLDivElement84.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement85  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement85.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement85     As HTMLInputElement
Attribute ieObj_HTMLInputElement85.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement85    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement85.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement85    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement85.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement85    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement85.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg85              As HTMLImg
Attribute ieObj_HTMLImg85.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell85        As HTMLTableCell
Attribute ieObj_HTMLTableCell85.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement85       As HTMLDivElement
Attribute ieObj_HTMLDivElement85.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement86  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement86.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement86     As HTMLInputElement
Attribute ieObj_HTMLInputElement86.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement86    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement86.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement86    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement86.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement86    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement86.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg86              As HTMLImg
Attribute ieObj_HTMLImg86.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell86        As HTMLTableCell
Attribute ieObj_HTMLTableCell86.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement86       As HTMLDivElement
Attribute ieObj_HTMLDivElement86.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement87  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement87.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement87     As HTMLInputElement
Attribute ieObj_HTMLInputElement87.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement87    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement87.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement87    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement87.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement87    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement87.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg87              As HTMLImg
Attribute ieObj_HTMLImg87.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell87        As HTMLTableCell
Attribute ieObj_HTMLTableCell87.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement87       As HTMLDivElement
Attribute ieObj_HTMLDivElement87.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement88  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement88.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement88     As HTMLInputElement
Attribute ieObj_HTMLInputElement88.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement88    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement88.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement88    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement88.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement88    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement88.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg88              As HTMLImg
Attribute ieObj_HTMLImg88.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell88        As HTMLTableCell
Attribute ieObj_HTMLTableCell88.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement88       As HTMLDivElement
Attribute ieObj_HTMLDivElement88.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement89  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement89.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement89     As HTMLInputElement
Attribute ieObj_HTMLInputElement89.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement89    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement89.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement89    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement89.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement89    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement89.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg89              As HTMLImg
Attribute ieObj_HTMLImg89.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell89        As HTMLTableCell
Attribute ieObj_HTMLTableCell89.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement89       As HTMLDivElement
Attribute ieObj_HTMLDivElement89.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement90  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement90.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement90     As HTMLInputElement
Attribute ieObj_HTMLInputElement90.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement90    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement90.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement90    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement90.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement90    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement90.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg90              As HTMLImg
Attribute ieObj_HTMLImg90.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell90        As HTMLTableCell
Attribute ieObj_HTMLTableCell90.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement90       As HTMLDivElement
Attribute ieObj_HTMLDivElement90.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement91  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement91.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement91     As HTMLInputElement
Attribute ieObj_HTMLInputElement91.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement91    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement91.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement91    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement91.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement91    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement91.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg91              As HTMLImg
Attribute ieObj_HTMLImg91.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell91        As HTMLTableCell
Attribute ieObj_HTMLTableCell91.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement91       As HTMLDivElement
Attribute ieObj_HTMLDivElement91.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement92  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement92.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement92     As HTMLInputElement
Attribute ieObj_HTMLInputElement92.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement92    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement92.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement92    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement92.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement92    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement92.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg92              As HTMLImg
Attribute ieObj_HTMLImg92.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell92        As HTMLTableCell
Attribute ieObj_HTMLTableCell92.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement92       As HTMLDivElement
Attribute ieObj_HTMLDivElement92.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement93  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement93.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement93     As HTMLInputElement
Attribute ieObj_HTMLInputElement93.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement93    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement93.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement93    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement93.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement93    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement93.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg93              As HTMLImg
Attribute ieObj_HTMLImg93.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell93        As HTMLTableCell
Attribute ieObj_HTMLTableCell93.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement93       As HTMLDivElement
Attribute ieObj_HTMLDivElement93.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement94  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement94.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement94     As HTMLInputElement
Attribute ieObj_HTMLInputElement94.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement94    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement94.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement94    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement94.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement94    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement94.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg94              As HTMLImg
Attribute ieObj_HTMLImg94.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell94        As HTMLTableCell
Attribute ieObj_HTMLTableCell94.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement94       As HTMLDivElement
Attribute ieObj_HTMLDivElement94.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement95  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement95.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement95     As HTMLInputElement
Attribute ieObj_HTMLInputElement95.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement95    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement95.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement95    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement95.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement95    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement95.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg95              As HTMLImg
Attribute ieObj_HTMLImg95.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell95        As HTMLTableCell
Attribute ieObj_HTMLTableCell95.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement95       As HTMLDivElement
Attribute ieObj_HTMLDivElement95.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement96  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement96.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement96     As HTMLInputElement
Attribute ieObj_HTMLInputElement96.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement96    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement96.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement96    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement96.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement96    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement96.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg96              As HTMLImg
Attribute ieObj_HTMLImg96.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell96        As HTMLTableCell
Attribute ieObj_HTMLTableCell96.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement96       As HTMLDivElement
Attribute ieObj_HTMLDivElement96.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement97  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement97.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement97     As HTMLInputElement
Attribute ieObj_HTMLInputElement97.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement97    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement97.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement97    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement97.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement97    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement97.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg97              As HTMLImg
Attribute ieObj_HTMLImg97.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell97        As HTMLTableCell
Attribute ieObj_HTMLTableCell97.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement97       As HTMLDivElement
Attribute ieObj_HTMLDivElement97.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement98  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement98.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement98     As HTMLInputElement
Attribute ieObj_HTMLInputElement98.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement98    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement98.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement98    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement98.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement98    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement98.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg98              As HTMLImg
Attribute ieObj_HTMLImg98.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell98        As HTMLTableCell
Attribute ieObj_HTMLTableCell98.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement98       As HTMLDivElement
Attribute ieObj_HTMLDivElement98.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement99  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement99.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement99     As HTMLInputElement
Attribute ieObj_HTMLInputElement99.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement99    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement99.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement99    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement99.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement99    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement99.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg99              As HTMLImg
Attribute ieObj_HTMLImg99.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell99        As HTMLTableCell
Attribute ieObj_HTMLTableCell99.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement99       As HTMLDivElement
Attribute ieObj_HTMLDivElement99.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement100  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement100.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement100     As HTMLInputElement
Attribute ieObj_HTMLInputElement100.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement100    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement100.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement100    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement100.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement100    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement100.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg100              As HTMLImg
Attribute ieObj_HTMLImg100.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell100        As HTMLTableCell
Attribute ieObj_HTMLTableCell100.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement100       As HTMLDivElement
Attribute ieObj_HTMLDivElement100.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement101  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement101.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement101     As HTMLInputElement
Attribute ieObj_HTMLInputElement101.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement101    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement101.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement101    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement101.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement101    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement101.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg101              As HTMLImg
Attribute ieObj_HTMLImg101.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell101        As HTMLTableCell
Attribute ieObj_HTMLTableCell101.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement101       As HTMLDivElement
Attribute ieObj_HTMLDivElement101.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement102  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement102.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement102     As HTMLInputElement
Attribute ieObj_HTMLInputElement102.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement102    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement102.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement102    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement102.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement102    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement102.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg102              As HTMLImg
Attribute ieObj_HTMLImg102.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell102        As HTMLTableCell
Attribute ieObj_HTMLTableCell102.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement102       As HTMLDivElement
Attribute ieObj_HTMLDivElement102.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement103  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement103.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement103     As HTMLInputElement
Attribute ieObj_HTMLInputElement103.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement103    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement103.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement103    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement103.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement103    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement103.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg103              As HTMLImg
Attribute ieObj_HTMLImg103.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell103        As HTMLTableCell
Attribute ieObj_HTMLTableCell103.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement103       As HTMLDivElement
Attribute ieObj_HTMLDivElement103.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement104  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement104.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement104     As HTMLInputElement
Attribute ieObj_HTMLInputElement104.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement104    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement104.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement104    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement104.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement104    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement104.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg104              As HTMLImg
Attribute ieObj_HTMLImg104.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell104        As HTMLTableCell
Attribute ieObj_HTMLTableCell104.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement104       As HTMLDivElement
Attribute ieObj_HTMLDivElement104.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement105  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement105.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement105     As HTMLInputElement
Attribute ieObj_HTMLInputElement105.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement105    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement105.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement105    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement105.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement105    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement105.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg105              As HTMLImg
Attribute ieObj_HTMLImg105.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell105        As HTMLTableCell
Attribute ieObj_HTMLTableCell105.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement105       As HTMLDivElement
Attribute ieObj_HTMLDivElement105.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement106  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement106.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement106     As HTMLInputElement
Attribute ieObj_HTMLInputElement106.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement106    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement106.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement106    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement106.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement106    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement106.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg106              As HTMLImg
Attribute ieObj_HTMLImg106.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell106        As HTMLTableCell
Attribute ieObj_HTMLTableCell106.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement106       As HTMLDivElement
Attribute ieObj_HTMLDivElement106.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement107  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement107.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement107     As HTMLInputElement
Attribute ieObj_HTMLInputElement107.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement107    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement107.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement107    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement107.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement107    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement107.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg107              As HTMLImg
Attribute ieObj_HTMLImg107.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell107        As HTMLTableCell
Attribute ieObj_HTMLTableCell107.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement107       As HTMLDivElement
Attribute ieObj_HTMLDivElement107.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement108  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement108.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement108     As HTMLInputElement
Attribute ieObj_HTMLInputElement108.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement108    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement108.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement108    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement108.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement108    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement108.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg108              As HTMLImg
Attribute ieObj_HTMLImg108.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell108        As HTMLTableCell
Attribute ieObj_HTMLTableCell108.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement108       As HTMLDivElement
Attribute ieObj_HTMLDivElement108.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement109  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement109.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement109     As HTMLInputElement
Attribute ieObj_HTMLInputElement109.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement109    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement109.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement109    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement109.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement109    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement109.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg109              As HTMLImg
Attribute ieObj_HTMLImg109.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell109        As HTMLTableCell
Attribute ieObj_HTMLTableCell109.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement109       As HTMLDivElement
Attribute ieObj_HTMLDivElement109.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement110  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement110.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement110     As HTMLInputElement
Attribute ieObj_HTMLInputElement110.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement110    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement110.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement110    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement110.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement110    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement110.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg110              As HTMLImg
Attribute ieObj_HTMLImg110.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell110        As HTMLTableCell
Attribute ieObj_HTMLTableCell110.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement110       As HTMLDivElement
Attribute ieObj_HTMLDivElement110.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement111  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement111.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement111     As HTMLInputElement
Attribute ieObj_HTMLInputElement111.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement111    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement111.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement111    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement111.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement111    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement111.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg111              As HTMLImg
Attribute ieObj_HTMLImg111.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell111        As HTMLTableCell
Attribute ieObj_HTMLTableCell111.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement111       As HTMLDivElement
Attribute ieObj_HTMLDivElement111.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement112  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement112.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement112     As HTMLInputElement
Attribute ieObj_HTMLInputElement112.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement112    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement112.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement112    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement112.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement112    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement112.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg112              As HTMLImg
Attribute ieObj_HTMLImg112.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell112        As HTMLTableCell
Attribute ieObj_HTMLTableCell112.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement112       As HTMLDivElement
Attribute ieObj_HTMLDivElement112.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement113  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement113.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement113     As HTMLInputElement
Attribute ieObj_HTMLInputElement113.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement113    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement113.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement113    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement113.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement113    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement113.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg113              As HTMLImg
Attribute ieObj_HTMLImg113.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell113        As HTMLTableCell
Attribute ieObj_HTMLTableCell113.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement113       As HTMLDivElement
Attribute ieObj_HTMLDivElement113.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement114  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement114.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement114     As HTMLInputElement
Attribute ieObj_HTMLInputElement114.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement114    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement114.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement114    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement114.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement114    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement114.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg114              As HTMLImg
Attribute ieObj_HTMLImg114.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell114        As HTMLTableCell
Attribute ieObj_HTMLTableCell114.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement114       As HTMLDivElement
Attribute ieObj_HTMLDivElement114.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement115  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement115.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement115     As HTMLInputElement
Attribute ieObj_HTMLInputElement115.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement115    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement115.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement115    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement115.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement115    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement115.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg115              As HTMLImg
Attribute ieObj_HTMLImg115.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell115        As HTMLTableCell
Attribute ieObj_HTMLTableCell115.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement115       As HTMLDivElement
Attribute ieObj_HTMLDivElement115.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement116  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement116.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement116     As HTMLInputElement
Attribute ieObj_HTMLInputElement116.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement116    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement116.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement116    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement116.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement116    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement116.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg116              As HTMLImg
Attribute ieObj_HTMLImg116.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell116        As HTMLTableCell
Attribute ieObj_HTMLTableCell116.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement116       As HTMLDivElement
Attribute ieObj_HTMLDivElement116.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement117  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement117.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement117     As HTMLInputElement
Attribute ieObj_HTMLInputElement117.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement117    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement117.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement117    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement117.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement117    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement117.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg117              As HTMLImg
Attribute ieObj_HTMLImg117.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell117        As HTMLTableCell
Attribute ieObj_HTMLTableCell117.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement117       As HTMLDivElement
Attribute ieObj_HTMLDivElement117.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement118  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement118.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement118     As HTMLInputElement
Attribute ieObj_HTMLInputElement118.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement118    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement118.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement118    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement118.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement118    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement118.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg118              As HTMLImg
Attribute ieObj_HTMLImg118.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell118        As HTMLTableCell
Attribute ieObj_HTMLTableCell118.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement118       As HTMLDivElement
Attribute ieObj_HTMLDivElement118.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement119  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement119.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement119     As HTMLInputElement
Attribute ieObj_HTMLInputElement119.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement119    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement119.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement119    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement119.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement119    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement119.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg119              As HTMLImg
Attribute ieObj_HTMLImg119.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell119        As HTMLTableCell
Attribute ieObj_HTMLTableCell119.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement119       As HTMLDivElement
Attribute ieObj_HTMLDivElement119.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement120  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement120.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement120     As HTMLInputElement
Attribute ieObj_HTMLInputElement120.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement120    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement120.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement120    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement120.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement120    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement120.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg120              As HTMLImg
Attribute ieObj_HTMLImg120.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell120        As HTMLTableCell
Attribute ieObj_HTMLTableCell120.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement120       As HTMLDivElement
Attribute ieObj_HTMLDivElement120.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement121  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement121.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement121     As HTMLInputElement
Attribute ieObj_HTMLInputElement121.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement121    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement121.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement121    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement121.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement121    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement121.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg121              As HTMLImg
Attribute ieObj_HTMLImg121.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell121        As HTMLTableCell
Attribute ieObj_HTMLTableCell121.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement121       As HTMLDivElement
Attribute ieObj_HTMLDivElement121.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement122  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement122.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement122     As HTMLInputElement
Attribute ieObj_HTMLInputElement122.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement122    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement122.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement122    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement122.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement122    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement122.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg122              As HTMLImg
Attribute ieObj_HTMLImg122.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell122        As HTMLTableCell
Attribute ieObj_HTMLTableCell122.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement122       As HTMLDivElement
Attribute ieObj_HTMLDivElement122.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement123  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement123.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement123     As HTMLInputElement
Attribute ieObj_HTMLInputElement123.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement123    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement123.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement123    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement123.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement123    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement123.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg123              As HTMLImg
Attribute ieObj_HTMLImg123.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell123        As HTMLTableCell
Attribute ieObj_HTMLTableCell123.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement123       As HTMLDivElement
Attribute ieObj_HTMLDivElement123.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement124  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement124.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement124     As HTMLInputElement
Attribute ieObj_HTMLInputElement124.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement124    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement124.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement124    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement124.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement124    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement124.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg124              As HTMLImg
Attribute ieObj_HTMLImg124.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell124        As HTMLTableCell
Attribute ieObj_HTMLTableCell124.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement124       As HTMLDivElement
Attribute ieObj_HTMLDivElement124.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement125  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement125.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement125     As HTMLInputElement
Attribute ieObj_HTMLInputElement125.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement125    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement125.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement125    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement125.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement125    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement125.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg125              As HTMLImg
Attribute ieObj_HTMLImg125.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell125        As HTMLTableCell
Attribute ieObj_HTMLTableCell125.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement125       As HTMLDivElement
Attribute ieObj_HTMLDivElement125.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement126  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement126.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement126     As HTMLInputElement
Attribute ieObj_HTMLInputElement126.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement126    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement126.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement126    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement126.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement126    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement126.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg126              As HTMLImg
Attribute ieObj_HTMLImg126.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell126        As HTMLTableCell
Attribute ieObj_HTMLTableCell126.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement126       As HTMLDivElement
Attribute ieObj_HTMLDivElement126.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTextAreaElement127  As HTMLTextAreaElement
Attribute ieObj_HTMLTextAreaElement127.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLInputElement127     As HTMLInputElement
Attribute ieObj_HTMLInputElement127.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLSelectElement127    As HTMLSelectElement
Attribute ieObj_HTMLSelectElement127.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLButtonElement127    As HTMLButtonElement
Attribute ieObj_HTMLButtonElement127.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLAnchorElement127    As HTMLAnchorElement
Attribute ieObj_HTMLAnchorElement127.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLImg127              As HTMLImg
Attribute ieObj_HTMLImg127.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLTableCell127        As HTMLTableCell
Attribute ieObj_HTMLTableCell127.VB_VarHelpID = -1
Private WithEvents ieObj_HTMLDivElement127       As HTMLDivElement
Attribute ieObj_HTMLDivElement127.VB_VarHelpID = -1


Private IsChildWindow  As Long

Private ieObj_HTMLInputElementIndex As Long
Private ieObj_HTMLInputElementInfo(0 To MAX_IE_OBJECTS - 1) As String

Private ieObj_HTMLTextAreaElementIndex As Long
Private ieObj_HTMLTextAreaElementInfo(0 To MAX_IE_OBJECTS - 1) As String

Private ieObj_HTMLSelectElementIndex As Long
Private ieObj_HTMLSelectElementInfo(0 To MAX_IE_OBJECTS - 1) As String

Private ieObj_HTMLButtonElementIndex As Long
Private ieObj_HTMLButtonElementInfo(0 To MAX_IE_OBJECTS - 1) As String

Private ieObj_HTMLAnchorElementIndex As Long
Private ieObj_HTMLAnchorElementInfo(0 To MAX_IE_OBJECTS - 1) As String

Private ieObj_HTMLImgIndex As Long
Private ieObj_HTMLImgInfo(0 To MAX_IE_OBJECTS - 1) As String

Private ieObj_HTMLTableCellIndex As Long
Private ieObj_HTMLTableCellInfo(0 To MAX_IE_OBJECTS - 1) As String

Private ieObj_HTMLDivElementIndex As Long
Private ieObj_HTMLDivElementInfo(0 To MAX_IE_OBJECTS - 1) As String



Const LV_FRAME_INDEX = 1
Const LV_TYPE_INDEX = 2
Const LV_ATTR_TYPE_INDEX = 3
Const LV_VALUE_INDEX = 4
Const LV_CHECKED_INDEX = 5
Const LV_TEXT_INDEX = 6
Const LV_HREF_INDEX = 7
Const LV_SRC_INDEX = 8



Private Function SetEIObject(o As Object, strIEType As String, lngIndex As Long, Optional strFrameName As String, Optional ByVal strName As String) As Boolean
        
    If lngIndex >= MAX_IE_OBJECTS Then Exit Function
    
    If IsValidObject(o) Then
        LOG_DEBUG_STRING "SetEIObject() Name=" & strName & " IEType=" & strIEType & " Index=" & lngIndex & " " & strFrameName
    End If

    Select Case UCase(strIEType)
    
        Case "HTMLTEXTAREAELEMENT"
        
            ieObj_HTMLTextAreaElementInfo(lngIndex) = strFrameName
            
            Select Case lngIndex
            
                    Case 0: Set ieObj_HTMLTextAreaElement0 = o
                    Case 1: Set ieObj_HTMLTextAreaElement1 = o
                    Case 2: Set ieObj_HTMLTextAreaElement2 = o
                    Case 3: Set ieObj_HTMLTextAreaElement3 = o
                    Case 4: Set ieObj_HTMLTextAreaElement4 = o
                    Case 5: Set ieObj_HTMLTextAreaElement5 = o
                    Case 6: Set ieObj_HTMLTextAreaElement6 = o
                    Case 7: Set ieObj_HTMLTextAreaElement7 = o
                    Case 8: Set ieObj_HTMLTextAreaElement8 = o
                    Case 9: Set ieObj_HTMLTextAreaElement9 = o
                    Case 10: Set ieObj_HTMLTextAreaElement10 = o
                    Case 11: Set ieObj_HTMLTextAreaElement11 = o
                    Case 12: Set ieObj_HTMLTextAreaElement12 = o
                    Case 13: Set ieObj_HTMLTextAreaElement13 = o
                    Case 14: Set ieObj_HTMLTextAreaElement14 = o
                    Case 15: Set ieObj_HTMLTextAreaElement15 = o
                    Case 16: Set ieObj_HTMLTextAreaElement16 = o
                    Case 17: Set ieObj_HTMLTextAreaElement17 = o
                    Case 18: Set ieObj_HTMLTextAreaElement18 = o
                    Case 19: Set ieObj_HTMLTextAreaElement19 = o
                    Case 20: Set ieObj_HTMLTextAreaElement20 = o
                    
                    Case 21: Set ieObj_HTMLTextAreaElement21 = o
                    Case 22: Set ieObj_HTMLTextAreaElement22 = o
                    Case 23: Set ieObj_HTMLTextAreaElement23 = o
                    Case 24: Set ieObj_HTMLTextAreaElement24 = o
                    Case 25: Set ieObj_HTMLTextAreaElement25 = o
                    Case 26: Set ieObj_HTMLTextAreaElement26 = o
                    Case 27: Set ieObj_HTMLTextAreaElement27 = o
                    Case 28: Set ieObj_HTMLTextAreaElement28 = o
                    Case 29: Set ieObj_HTMLTextAreaElement29 = o
                    Case 30: Set ieObj_HTMLTextAreaElement30 = o
                    Case 31: Set ieObj_HTMLTextAreaElement31 = o
                    Case 32: Set ieObj_HTMLTextAreaElement32 = o
                    Case 33: Set ieObj_HTMLTextAreaElement33 = o
                    Case 34: Set ieObj_HTMLTextAreaElement34 = o
                    Case 35: Set ieObj_HTMLTextAreaElement35 = o
                    Case 36: Set ieObj_HTMLTextAreaElement36 = o
                    Case 37: Set ieObj_HTMLTextAreaElement37 = o
                    Case 38: Set ieObj_HTMLTextAreaElement38 = o
                    Case 39: Set ieObj_HTMLTextAreaElement39 = o
                    Case 40: Set ieObj_HTMLTextAreaElement40 = o
                    Case 41: Set ieObj_HTMLTextAreaElement41 = o
                    Case 42: Set ieObj_HTMLTextAreaElement42 = o
                    Case 43: Set ieObj_HTMLTextAreaElement43 = o
                    Case 44: Set ieObj_HTMLTextAreaElement44 = o
                    Case 45: Set ieObj_HTMLTextAreaElement45 = o
                    Case 46: Set ieObj_HTMLTextAreaElement46 = o
                    Case 47: Set ieObj_HTMLTextAreaElement47 = o
                    Case 48: Set ieObj_HTMLTextAreaElement48 = o
                    Case 49: Set ieObj_HTMLTextAreaElement49 = o
                    Case 50: Set ieObj_HTMLTextAreaElement50 = o
                    Case 51: Set ieObj_HTMLTextAreaElement51 = o
                    Case 52: Set ieObj_HTMLTextAreaElement52 = o
                    Case 53: Set ieObj_HTMLTextAreaElement53 = o
                    Case 54: Set ieObj_HTMLTextAreaElement54 = o
                    Case 55: Set ieObj_HTMLTextAreaElement55 = o
                    Case 56: Set ieObj_HTMLTextAreaElement56 = o
                    Case 57: Set ieObj_HTMLTextAreaElement57 = o
                    Case 58: Set ieObj_HTMLTextAreaElement58 = o
                    Case 59: Set ieObj_HTMLTextAreaElement59 = o
                    Case 60: Set ieObj_HTMLTextAreaElement60 = o
                    Case 61: Set ieObj_HTMLTextAreaElement61 = o
                    Case 62: Set ieObj_HTMLTextAreaElement62 = o
                    Case 63: Set ieObj_HTMLTextAreaElement63 = o
                    Case 64: Set ieObj_HTMLTextAreaElement64 = o
                    Case 65: Set ieObj_HTMLTextAreaElement65 = o
                    Case 66: Set ieObj_HTMLTextAreaElement66 = o
                    Case 67: Set ieObj_HTMLTextAreaElement67 = o
                    Case 68: Set ieObj_HTMLTextAreaElement68 = o
                    Case 69: Set ieObj_HTMLTextAreaElement69 = o
                    Case 70: Set ieObj_HTMLTextAreaElement70 = o
                    Case 71: Set ieObj_HTMLTextAreaElement71 = o
                    Case 72: Set ieObj_HTMLTextAreaElement72 = o
                    Case 73: Set ieObj_HTMLTextAreaElement73 = o
                    Case 74: Set ieObj_HTMLTextAreaElement74 = o
                    Case 75: Set ieObj_HTMLTextAreaElement75 = o
                    Case 76: Set ieObj_HTMLTextAreaElement76 = o
                    Case 77: Set ieObj_HTMLTextAreaElement77 = o
                    Case 78: Set ieObj_HTMLTextAreaElement78 = o
                    Case 79: Set ieObj_HTMLTextAreaElement79 = o
                    Case 80: Set ieObj_HTMLTextAreaElement80 = o
                    Case 81: Set ieObj_HTMLTextAreaElement81 = o
                    Case 82: Set ieObj_HTMLTextAreaElement82 = o
                    Case 83: Set ieObj_HTMLTextAreaElement83 = o
                    Case 84: Set ieObj_HTMLTextAreaElement84 = o
                    Case 85: Set ieObj_HTMLTextAreaElement85 = o
                    Case 86: Set ieObj_HTMLTextAreaElement86 = o
                    Case 87: Set ieObj_HTMLTextAreaElement87 = o
                    Case 88: Set ieObj_HTMLTextAreaElement88 = o
                    Case 89: Set ieObj_HTMLTextAreaElement89 = o
                    Case 90: Set ieObj_HTMLTextAreaElement90 = o
                    Case 91: Set ieObj_HTMLTextAreaElement91 = o
                    Case 92: Set ieObj_HTMLTextAreaElement92 = o
                    Case 93: Set ieObj_HTMLTextAreaElement93 = o
                    Case 94: Set ieObj_HTMLTextAreaElement94 = o
                    Case 95: Set ieObj_HTMLTextAreaElement95 = o
                    Case 96: Set ieObj_HTMLTextAreaElement96 = o
                    Case 97: Set ieObj_HTMLTextAreaElement97 = o
                    Case 98: Set ieObj_HTMLTextAreaElement98 = o
                    Case 99: Set ieObj_HTMLTextAreaElement99 = o
                    Case 100: Set ieObj_HTMLTextAreaElement100 = o
                    Case 101: Set ieObj_HTMLTextAreaElement101 = o
                    Case 102: Set ieObj_HTMLTextAreaElement102 = o
                    Case 103: Set ieObj_HTMLTextAreaElement103 = o
                    Case 104: Set ieObj_HTMLTextAreaElement104 = o
                    Case 105: Set ieObj_HTMLTextAreaElement105 = o
                    Case 106: Set ieObj_HTMLTextAreaElement106 = o
                    Case 107: Set ieObj_HTMLTextAreaElement107 = o
                    Case 108: Set ieObj_HTMLTextAreaElement108 = o
                    Case 109: Set ieObj_HTMLTextAreaElement109 = o
                    Case 110: Set ieObj_HTMLTextAreaElement110 = o
                    Case 111: Set ieObj_HTMLTextAreaElement111 = o
                    Case 112: Set ieObj_HTMLTextAreaElement112 = o
                    Case 113: Set ieObj_HTMLTextAreaElement113 = o
                    Case 114: Set ieObj_HTMLTextAreaElement114 = o
                    Case 115: Set ieObj_HTMLTextAreaElement115 = o
                    Case 116: Set ieObj_HTMLTextAreaElement116 = o
                    Case 117: Set ieObj_HTMLTextAreaElement117 = o
                    Case 118: Set ieObj_HTMLTextAreaElement118 = o
                    Case 119: Set ieObj_HTMLTextAreaElement119 = o
                    Case 120: Set ieObj_HTMLTextAreaElement120 = o
                    Case 121: Set ieObj_HTMLTextAreaElement121 = o
                    Case 122: Set ieObj_HTMLTextAreaElement122 = o
                    Case 123: Set ieObj_HTMLTextAreaElement123 = o
                    Case 124: Set ieObj_HTMLTextAreaElement124 = o
                    Case 125: Set ieObj_HTMLTextAreaElement125 = o
                    Case 126: Set ieObj_HTMLTextAreaElement126 = o
                    Case 127: Set ieObj_HTMLTextAreaElement127 = o
                    
                    
            End Select
                
    
        Case "HTMLINPUTELEMENT"
        
            ieObj_HTMLInputElementInfo(lngIndex) = strFrameName
            
            Select Case lngIndex
            
                    Case 0: Set ieObj_HTMLInputElement0 = o
                    Case 1: Set ieObj_HTMLInputElement1 = o
                    Case 2: Set ieObj_HTMLInputElement2 = o
                    Case 3: Set ieObj_HTMLInputElement3 = o
                    Case 4: Set ieObj_HTMLInputElement4 = o
                    Case 5: Set ieObj_HTMLInputElement5 = o
                    Case 6: Set ieObj_HTMLInputElement6 = o
                    Case 7: Set ieObj_HTMLInputElement7 = o
                    Case 8: Set ieObj_HTMLInputElement8 = o
                    Case 9: Set ieObj_HTMLInputElement9 = o
                    Case 10: Set ieObj_HTMLInputElement10 = o
                    Case 11: Set ieObj_HTMLInputElement11 = o
                    Case 12: Set ieObj_HTMLInputElement12 = o
                    Case 13: Set ieObj_HTMLInputElement13 = o
                    Case 14: Set ieObj_HTMLInputElement14 = o
                    Case 15: Set ieObj_HTMLInputElement15 = o
                    Case 16: Set ieObj_HTMLInputElement16 = o
                    Case 17: Set ieObj_HTMLInputElement17 = o
                    Case 18: Set ieObj_HTMLInputElement18 = o
                    Case 19: Set ieObj_HTMLInputElement19 = o
                    Case 20: Set ieObj_HTMLInputElement20 = o
                    
                    Case 21: Set ieObj_HTMLInputElement21 = o
                    Case 22: Set ieObj_HTMLInputElement22 = o
                    Case 23: Set ieObj_HTMLInputElement23 = o
                    Case 24: Set ieObj_HTMLInputElement24 = o
                    Case 25: Set ieObj_HTMLInputElement25 = o
                    Case 26: Set ieObj_HTMLInputElement26 = o
                    Case 27: Set ieObj_HTMLInputElement27 = o
                    Case 28: Set ieObj_HTMLInputElement28 = o
                    Case 29: Set ieObj_HTMLInputElement29 = o
                    Case 30: Set ieObj_HTMLInputElement30 = o
                    Case 31: Set ieObj_HTMLInputElement31 = o
                    Case 32: Set ieObj_HTMLInputElement32 = o
                    Case 33: Set ieObj_HTMLInputElement33 = o
                    Case 34: Set ieObj_HTMLInputElement34 = o
                    Case 35: Set ieObj_HTMLInputElement35 = o
                    Case 36: Set ieObj_HTMLInputElement36 = o
                    Case 37: Set ieObj_HTMLInputElement37 = o
                    Case 38: Set ieObj_HTMLInputElement38 = o
                    Case 39: Set ieObj_HTMLInputElement39 = o
                    Case 40: Set ieObj_HTMLInputElement40 = o
                    Case 41: Set ieObj_HTMLInputElement41 = o
                    Case 42: Set ieObj_HTMLInputElement42 = o
                    Case 43: Set ieObj_HTMLInputElement43 = o
                    Case 44: Set ieObj_HTMLInputElement44 = o
                    Case 45: Set ieObj_HTMLInputElement45 = o
                    Case 46: Set ieObj_HTMLInputElement46 = o
                    Case 47: Set ieObj_HTMLInputElement47 = o
                    Case 48: Set ieObj_HTMLInputElement48 = o
                    Case 49: Set ieObj_HTMLInputElement49 = o
                    Case 50: Set ieObj_HTMLInputElement50 = o
                    Case 51: Set ieObj_HTMLInputElement51 = o
                    Case 52: Set ieObj_HTMLInputElement52 = o
                    Case 53: Set ieObj_HTMLInputElement53 = o
                    Case 54: Set ieObj_HTMLInputElement54 = o
                    Case 55: Set ieObj_HTMLInputElement55 = o
                    Case 56: Set ieObj_HTMLInputElement56 = o
                    Case 57: Set ieObj_HTMLInputElement57 = o
                    Case 58: Set ieObj_HTMLInputElement58 = o
                    Case 59: Set ieObj_HTMLInputElement59 = o
                    Case 60: Set ieObj_HTMLInputElement60 = o
                    Case 61: Set ieObj_HTMLInputElement61 = o
                    Case 62: Set ieObj_HTMLInputElement62 = o
                    Case 63: Set ieObj_HTMLInputElement63 = o
                    Case 64: Set ieObj_HTMLInputElement64 = o
                    Case 65: Set ieObj_HTMLInputElement65 = o
                    Case 66: Set ieObj_HTMLInputElement66 = o
                    Case 67: Set ieObj_HTMLInputElement67 = o
                    Case 68: Set ieObj_HTMLInputElement68 = o
                    Case 69: Set ieObj_HTMLInputElement69 = o
                    Case 70: Set ieObj_HTMLInputElement70 = o
                    Case 71: Set ieObj_HTMLInputElement71 = o
                    Case 72: Set ieObj_HTMLInputElement72 = o
                    Case 73: Set ieObj_HTMLInputElement73 = o
                    Case 74: Set ieObj_HTMLInputElement74 = o
                    Case 75: Set ieObj_HTMLInputElement75 = o
                    Case 76: Set ieObj_HTMLInputElement76 = o
                    Case 77: Set ieObj_HTMLInputElement77 = o
                    Case 78: Set ieObj_HTMLInputElement78 = o
                    Case 79: Set ieObj_HTMLInputElement79 = o
                    Case 80: Set ieObj_HTMLInputElement80 = o
                    Case 81: Set ieObj_HTMLInputElement81 = o
                    Case 82: Set ieObj_HTMLInputElement82 = o
                    Case 83: Set ieObj_HTMLInputElement83 = o
                    Case 84: Set ieObj_HTMLInputElement84 = o
                    Case 85: Set ieObj_HTMLInputElement85 = o
                    Case 86: Set ieObj_HTMLInputElement86 = o
                    Case 87: Set ieObj_HTMLInputElement87 = o
                    Case 88: Set ieObj_HTMLInputElement88 = o
                    Case 89: Set ieObj_HTMLInputElement89 = o
                    Case 90: Set ieObj_HTMLInputElement90 = o
                    Case 91: Set ieObj_HTMLInputElement91 = o
                    Case 92: Set ieObj_HTMLInputElement92 = o
                    Case 93: Set ieObj_HTMLInputElement93 = o
                    Case 94: Set ieObj_HTMLInputElement94 = o
                    Case 95: Set ieObj_HTMLInputElement95 = o
                    Case 96: Set ieObj_HTMLInputElement96 = o
                    Case 97: Set ieObj_HTMLInputElement97 = o
                    Case 98: Set ieObj_HTMLInputElement98 = o
                    Case 99: Set ieObj_HTMLInputElement99 = o
                    Case 100: Set ieObj_HTMLInputElement100 = o
                    Case 101: Set ieObj_HTMLInputElement101 = o
                    Case 102: Set ieObj_HTMLInputElement102 = o
                    Case 103: Set ieObj_HTMLInputElement103 = o
                    Case 104: Set ieObj_HTMLInputElement104 = o
                    Case 105: Set ieObj_HTMLInputElement105 = o
                    Case 106: Set ieObj_HTMLInputElement106 = o
                    Case 107: Set ieObj_HTMLInputElement107 = o
                    Case 108: Set ieObj_HTMLInputElement108 = o
                    Case 109: Set ieObj_HTMLInputElement109 = o
                    Case 110: Set ieObj_HTMLInputElement110 = o
                    Case 111: Set ieObj_HTMLInputElement111 = o
                    Case 112: Set ieObj_HTMLInputElement112 = o
                    Case 113: Set ieObj_HTMLInputElement113 = o
                    Case 114: Set ieObj_HTMLInputElement114 = o
                    Case 115: Set ieObj_HTMLInputElement115 = o
                    Case 116: Set ieObj_HTMLInputElement116 = o
                    Case 117: Set ieObj_HTMLInputElement117 = o
                    Case 118: Set ieObj_HTMLInputElement118 = o
                    Case 119: Set ieObj_HTMLInputElement119 = o
                    Case 120: Set ieObj_HTMLInputElement120 = o
                    Case 121: Set ieObj_HTMLInputElement121 = o
                    Case 122: Set ieObj_HTMLInputElement122 = o
                    Case 123: Set ieObj_HTMLInputElement123 = o
                    Case 124: Set ieObj_HTMLInputElement124 = o
                    Case 125: Set ieObj_HTMLInputElement125 = o
                    Case 126: Set ieObj_HTMLInputElement126 = o
                    Case 127: Set ieObj_HTMLInputElement127 = o
                    
                    
            End Select
            
        Case "HTMLSELECTELEMENT"

            ieObj_HTMLSelectElementInfo(lngIndex) = strFrameName
            Select Case lngIndex
                
                Case 0: Set ieObj_HTMLSelectElement0 = o
                Case 1: Set ieObj_HTMLSelectElement1 = o
                Case 2: Set ieObj_HTMLSelectElement2 = o
                Case 3: Set ieObj_HTMLSelectElement3 = o
                Case 4: Set ieObj_HTMLSelectElement4 = o
                Case 5: Set ieObj_HTMLSelectElement5 = o
                Case 6: Set ieObj_HTMLSelectElement6 = o
                Case 7: Set ieObj_HTMLSelectElement7 = o
                Case 8: Set ieObj_HTMLSelectElement8 = o
                Case 9: Set ieObj_HTMLSelectElement9 = o
                Case 10: Set ieObj_HTMLSelectElement10 = o
                Case 11: Set ieObj_HTMLSelectElement11 = o
                Case 12: Set ieObj_HTMLSelectElement12 = o
                Case 13: Set ieObj_HTMLSelectElement13 = o
                Case 14: Set ieObj_HTMLSelectElement14 = o
                Case 15: Set ieObj_HTMLSelectElement15 = o
                Case 16: Set ieObj_HTMLSelectElement16 = o
                Case 17: Set ieObj_HTMLSelectElement17 = o
                Case 18: Set ieObj_HTMLSelectElement18 = o
                Case 19: Set ieObj_HTMLSelectElement19 = o
                Case 20: Set ieObj_HTMLSelectElement20 = o
                
                Case 21: Set ieObj_HTMLSelectElement21 = o
                Case 22: Set ieObj_HTMLSelectElement22 = o
                Case 23: Set ieObj_HTMLSelectElement23 = o
                Case 24: Set ieObj_HTMLSelectElement24 = o
                Case 25: Set ieObj_HTMLSelectElement25 = o
                Case 26: Set ieObj_HTMLSelectElement26 = o
                Case 27: Set ieObj_HTMLSelectElement27 = o
                Case 28: Set ieObj_HTMLSelectElement28 = o
                Case 29: Set ieObj_HTMLSelectElement29 = o
                Case 30: Set ieObj_HTMLSelectElement30 = o
                Case 31: Set ieObj_HTMLSelectElement31 = o
                Case 32: Set ieObj_HTMLSelectElement32 = o
                Case 33: Set ieObj_HTMLSelectElement33 = o
                Case 34: Set ieObj_HTMLSelectElement34 = o
                Case 35: Set ieObj_HTMLSelectElement35 = o
                Case 36: Set ieObj_HTMLSelectElement36 = o
                Case 37: Set ieObj_HTMLSelectElement37 = o
                Case 38: Set ieObj_HTMLSelectElement38 = o
                Case 39: Set ieObj_HTMLSelectElement39 = o
                Case 40: Set ieObj_HTMLSelectElement40 = o
                Case 41: Set ieObj_HTMLSelectElement41 = o
                Case 42: Set ieObj_HTMLSelectElement42 = o
                Case 43: Set ieObj_HTMLSelectElement43 = o
                Case 44: Set ieObj_HTMLSelectElement44 = o
                Case 45: Set ieObj_HTMLSelectElement45 = o
                Case 46: Set ieObj_HTMLSelectElement46 = o
                Case 47: Set ieObj_HTMLSelectElement47 = o
                Case 48: Set ieObj_HTMLSelectElement48 = o
                Case 49: Set ieObj_HTMLSelectElement49 = o
                Case 50: Set ieObj_HTMLSelectElement50 = o
                Case 51: Set ieObj_HTMLSelectElement51 = o
                Case 52: Set ieObj_HTMLSelectElement52 = o
                Case 53: Set ieObj_HTMLSelectElement53 = o
                Case 54: Set ieObj_HTMLSelectElement54 = o
                Case 55: Set ieObj_HTMLSelectElement55 = o
                Case 56: Set ieObj_HTMLSelectElement56 = o
                Case 57: Set ieObj_HTMLSelectElement57 = o
                Case 58: Set ieObj_HTMLSelectElement58 = o
                Case 59: Set ieObj_HTMLSelectElement59 = o
                Case 60: Set ieObj_HTMLSelectElement60 = o
                Case 61: Set ieObj_HTMLSelectElement61 = o
                Case 62: Set ieObj_HTMLSelectElement62 = o
                Case 63: Set ieObj_HTMLSelectElement63 = o
                Case 64: Set ieObj_HTMLSelectElement64 = o
                Case 65: Set ieObj_HTMLSelectElement65 = o
                Case 66: Set ieObj_HTMLSelectElement66 = o
                Case 67: Set ieObj_HTMLSelectElement67 = o
                Case 68: Set ieObj_HTMLSelectElement68 = o
                Case 69: Set ieObj_HTMLSelectElement69 = o
                Case 70: Set ieObj_HTMLSelectElement70 = o
                Case 71: Set ieObj_HTMLSelectElement71 = o
                Case 72: Set ieObj_HTMLSelectElement72 = o
                Case 73: Set ieObj_HTMLSelectElement73 = o
                Case 74: Set ieObj_HTMLSelectElement74 = o
                Case 75: Set ieObj_HTMLSelectElement75 = o
                Case 76: Set ieObj_HTMLSelectElement76 = o
                Case 77: Set ieObj_HTMLSelectElement77 = o
                Case 78: Set ieObj_HTMLSelectElement78 = o
                Case 79: Set ieObj_HTMLSelectElement79 = o
                Case 80: Set ieObj_HTMLSelectElement80 = o
                Case 81: Set ieObj_HTMLSelectElement81 = o
                Case 82: Set ieObj_HTMLSelectElement82 = o
                Case 83: Set ieObj_HTMLSelectElement83 = o
                Case 84: Set ieObj_HTMLSelectElement84 = o
                Case 85: Set ieObj_HTMLSelectElement85 = o
                Case 86: Set ieObj_HTMLSelectElement86 = o
                Case 87: Set ieObj_HTMLSelectElement87 = o
                Case 88: Set ieObj_HTMLSelectElement88 = o
                Case 89: Set ieObj_HTMLSelectElement89 = o
                Case 90: Set ieObj_HTMLSelectElement90 = o
                Case 91: Set ieObj_HTMLSelectElement91 = o
                Case 92: Set ieObj_HTMLSelectElement92 = o
                Case 93: Set ieObj_HTMLSelectElement93 = o
                Case 94: Set ieObj_HTMLSelectElement94 = o
                Case 95: Set ieObj_HTMLSelectElement95 = o
                Case 96: Set ieObj_HTMLSelectElement96 = o
                Case 97: Set ieObj_HTMLSelectElement97 = o
                Case 98: Set ieObj_HTMLSelectElement98 = o
                Case 99: Set ieObj_HTMLSelectElement99 = o
                Case 100: Set ieObj_HTMLSelectElement100 = o
                Case 101: Set ieObj_HTMLSelectElement101 = o
                Case 102: Set ieObj_HTMLSelectElement102 = o
                Case 103: Set ieObj_HTMLSelectElement103 = o
                Case 104: Set ieObj_HTMLSelectElement104 = o
                Case 105: Set ieObj_HTMLSelectElement105 = o
                Case 106: Set ieObj_HTMLSelectElement106 = o
                Case 107: Set ieObj_HTMLSelectElement107 = o
                Case 108: Set ieObj_HTMLSelectElement108 = o
                Case 109: Set ieObj_HTMLSelectElement109 = o
                Case 110: Set ieObj_HTMLSelectElement110 = o
                Case 111: Set ieObj_HTMLSelectElement111 = o
                Case 112: Set ieObj_HTMLSelectElement112 = o
                Case 113: Set ieObj_HTMLSelectElement113 = o
                Case 114: Set ieObj_HTMLSelectElement114 = o
                Case 115: Set ieObj_HTMLSelectElement115 = o
                Case 116: Set ieObj_HTMLSelectElement116 = o
                Case 117: Set ieObj_HTMLSelectElement117 = o
                Case 118: Set ieObj_HTMLSelectElement118 = o
                Case 119: Set ieObj_HTMLSelectElement119 = o
                Case 120: Set ieObj_HTMLSelectElement120 = o
                Case 121: Set ieObj_HTMLSelectElement121 = o
                Case 122: Set ieObj_HTMLSelectElement122 = o
                Case 123: Set ieObj_HTMLSelectElement123 = o
                Case 124: Set ieObj_HTMLSelectElement124 = o
                Case 125: Set ieObj_HTMLSelectElement125 = o
                Case 126: Set ieObj_HTMLSelectElement126 = o
                Case 127: Set ieObj_HTMLSelectElement127 = o
                
            End Select
            
        Case "HTMLBUTTONELEMENT"

            ieObj_HTMLButtonElementInfo(lngIndex) = strFrameName
            Select Case lngIndex
                
                Case 0: Set ieObj_HTMLButtonElement0 = o
                Case 1: Set ieObj_HTMLButtonElement1 = o
                Case 2: Set ieObj_HTMLButtonElement2 = o
                Case 3: Set ieObj_HTMLButtonElement3 = o
                Case 4: Set ieObj_HTMLButtonElement4 = o
                Case 5: Set ieObj_HTMLButtonElement5 = o
                Case 6: Set ieObj_HTMLButtonElement6 = o
                Case 7: Set ieObj_HTMLButtonElement7 = o
                Case 8: Set ieObj_HTMLButtonElement8 = o
                Case 9: Set ieObj_HTMLButtonElement9 = o
                Case 10: Set ieObj_HTMLButtonElement10 = o
                Case 11: Set ieObj_HTMLButtonElement11 = o
                Case 12: Set ieObj_HTMLButtonElement12 = o
                Case 13: Set ieObj_HTMLButtonElement13 = o
                Case 14: Set ieObj_HTMLButtonElement14 = o
                Case 15: Set ieObj_HTMLButtonElement15 = o
                Case 16: Set ieObj_HTMLButtonElement16 = o
                Case 17: Set ieObj_HTMLButtonElement17 = o
                Case 18: Set ieObj_HTMLButtonElement18 = o
                Case 19: Set ieObj_HTMLButtonElement19 = o
                Case 20: Set ieObj_HTMLButtonElement20 = o
                
                Case 21: Set ieObj_HTMLButtonElement21 = o
                Case 22: Set ieObj_HTMLButtonElement22 = o
                Case 23: Set ieObj_HTMLButtonElement23 = o
                Case 24: Set ieObj_HTMLButtonElement24 = o
                Case 25: Set ieObj_HTMLButtonElement25 = o
                Case 26: Set ieObj_HTMLButtonElement26 = o
                Case 27: Set ieObj_HTMLButtonElement27 = o
                Case 28: Set ieObj_HTMLButtonElement28 = o
                Case 29: Set ieObj_HTMLButtonElement29 = o
                Case 30: Set ieObj_HTMLButtonElement30 = o
                Case 31: Set ieObj_HTMLButtonElement31 = o
                Case 32: Set ieObj_HTMLButtonElement32 = o
                Case 33: Set ieObj_HTMLButtonElement33 = o
                Case 34: Set ieObj_HTMLButtonElement34 = o
                Case 35: Set ieObj_HTMLButtonElement35 = o
                Case 36: Set ieObj_HTMLButtonElement36 = o
                Case 37: Set ieObj_HTMLButtonElement37 = o
                Case 38: Set ieObj_HTMLButtonElement38 = o
                Case 39: Set ieObj_HTMLButtonElement39 = o
                Case 40: Set ieObj_HTMLButtonElement40 = o
                Case 41: Set ieObj_HTMLButtonElement41 = o
                Case 42: Set ieObj_HTMLButtonElement42 = o
                Case 43: Set ieObj_HTMLButtonElement43 = o
                Case 44: Set ieObj_HTMLButtonElement44 = o
                Case 45: Set ieObj_HTMLButtonElement45 = o
                Case 46: Set ieObj_HTMLButtonElement46 = o
                Case 47: Set ieObj_HTMLButtonElement47 = o
                Case 48: Set ieObj_HTMLButtonElement48 = o
                Case 49: Set ieObj_HTMLButtonElement49 = o
                Case 50: Set ieObj_HTMLButtonElement50 = o
                Case 51: Set ieObj_HTMLButtonElement51 = o
                Case 52: Set ieObj_HTMLButtonElement52 = o
                Case 53: Set ieObj_HTMLButtonElement53 = o
                Case 54: Set ieObj_HTMLButtonElement54 = o
                Case 55: Set ieObj_HTMLButtonElement55 = o
                Case 56: Set ieObj_HTMLButtonElement56 = o
                Case 57: Set ieObj_HTMLButtonElement57 = o
                Case 58: Set ieObj_HTMLButtonElement58 = o
                Case 59: Set ieObj_HTMLButtonElement59 = o
                Case 60: Set ieObj_HTMLButtonElement60 = o
                Case 61: Set ieObj_HTMLButtonElement61 = o
                Case 62: Set ieObj_HTMLButtonElement62 = o
                Case 63: Set ieObj_HTMLButtonElement63 = o
                Case 64: Set ieObj_HTMLButtonElement64 = o
                Case 65: Set ieObj_HTMLButtonElement65 = o
                Case 66: Set ieObj_HTMLButtonElement66 = o
                Case 67: Set ieObj_HTMLButtonElement67 = o
                Case 68: Set ieObj_HTMLButtonElement68 = o
                Case 69: Set ieObj_HTMLButtonElement69 = o
                Case 70: Set ieObj_HTMLButtonElement70 = o
                Case 71: Set ieObj_HTMLButtonElement71 = o
                Case 72: Set ieObj_HTMLButtonElement72 = o
                Case 73: Set ieObj_HTMLButtonElement73 = o
                Case 74: Set ieObj_HTMLButtonElement74 = o
                Case 75: Set ieObj_HTMLButtonElement75 = o
                Case 76: Set ieObj_HTMLButtonElement76 = o
                Case 77: Set ieObj_HTMLButtonElement77 = o
                Case 78: Set ieObj_HTMLButtonElement78 = o
                Case 79: Set ieObj_HTMLButtonElement79 = o
                Case 80: Set ieObj_HTMLButtonElement80 = o
                Case 81: Set ieObj_HTMLButtonElement81 = o
                Case 82: Set ieObj_HTMLButtonElement82 = o
                Case 83: Set ieObj_HTMLButtonElement83 = o
                Case 84: Set ieObj_HTMLButtonElement84 = o
                Case 85: Set ieObj_HTMLButtonElement85 = o
                Case 86: Set ieObj_HTMLButtonElement86 = o
                Case 87: Set ieObj_HTMLButtonElement87 = o
                Case 88: Set ieObj_HTMLButtonElement88 = o
                Case 89: Set ieObj_HTMLButtonElement89 = o
                Case 90: Set ieObj_HTMLButtonElement90 = o
                Case 91: Set ieObj_HTMLButtonElement91 = o
                Case 92: Set ieObj_HTMLButtonElement92 = o
                Case 93: Set ieObj_HTMLButtonElement93 = o
                Case 94: Set ieObj_HTMLButtonElement94 = o
                Case 95: Set ieObj_HTMLButtonElement95 = o
                Case 96: Set ieObj_HTMLButtonElement96 = o
                Case 97: Set ieObj_HTMLButtonElement97 = o
                Case 98: Set ieObj_HTMLButtonElement98 = o
                Case 99: Set ieObj_HTMLButtonElement99 = o
                Case 100: Set ieObj_HTMLButtonElement100 = o
                Case 101: Set ieObj_HTMLButtonElement101 = o
                Case 102: Set ieObj_HTMLButtonElement102 = o
                Case 103: Set ieObj_HTMLButtonElement103 = o
                Case 104: Set ieObj_HTMLButtonElement104 = o
                Case 105: Set ieObj_HTMLButtonElement105 = o
                Case 106: Set ieObj_HTMLButtonElement106 = o
                Case 107: Set ieObj_HTMLButtonElement107 = o
                Case 108: Set ieObj_HTMLButtonElement108 = o
                Case 109: Set ieObj_HTMLButtonElement109 = o
                Case 110: Set ieObj_HTMLButtonElement110 = o
                Case 111: Set ieObj_HTMLButtonElement111 = o
                Case 112: Set ieObj_HTMLButtonElement112 = o
                Case 113: Set ieObj_HTMLButtonElement113 = o
                Case 114: Set ieObj_HTMLButtonElement114 = o
                Case 115: Set ieObj_HTMLButtonElement115 = o
                Case 116: Set ieObj_HTMLButtonElement116 = o
                Case 117: Set ieObj_HTMLButtonElement117 = o
                Case 118: Set ieObj_HTMLButtonElement118 = o
                Case 119: Set ieObj_HTMLButtonElement119 = o
                Case 120: Set ieObj_HTMLButtonElement120 = o
                Case 121: Set ieObj_HTMLButtonElement121 = o
                Case 122: Set ieObj_HTMLButtonElement122 = o
                Case 123: Set ieObj_HTMLButtonElement123 = o
                Case 124: Set ieObj_HTMLButtonElement124 = o
                Case 125: Set ieObj_HTMLButtonElement125 = o
                Case 126: Set ieObj_HTMLButtonElement126 = o
                Case 127: Set ieObj_HTMLButtonElement127 = o
                
            End Select
            
        Case "HTMLANCHORELEMENT"

            ieObj_HTMLAnchorElementInfo(lngIndex) = strFrameName
            Select Case lngIndex
            
                Case 0: Set ieObj_HTMLAnchorElement0 = o
                Case 1: Set ieObj_HTMLAnchorElement1 = o
                Case 2: Set ieObj_HTMLAnchorElement2 = o
                Case 3: Set ieObj_HTMLAnchorElement3 = o
                Case 4: Set ieObj_HTMLAnchorElement4 = o
                Case 5: Set ieObj_HTMLAnchorElement5 = o
                Case 6: Set ieObj_HTMLAnchorElement6 = o
                Case 7: Set ieObj_HTMLAnchorElement7 = o
                Case 8: Set ieObj_HTMLAnchorElement8 = o
                Case 9: Set ieObj_HTMLAnchorElement9 = o
                Case 10: Set ieObj_HTMLAnchorElement10 = o
                Case 11: Set ieObj_HTMLAnchorElement11 = o
                Case 12: Set ieObj_HTMLAnchorElement12 = o
                Case 13: Set ieObj_HTMLAnchorElement13 = o
                Case 14: Set ieObj_HTMLAnchorElement14 = o
                Case 15: Set ieObj_HTMLAnchorElement15 = o
                Case 16: Set ieObj_HTMLAnchorElement16 = o
                Case 17: Set ieObj_HTMLAnchorElement17 = o
                Case 18: Set ieObj_HTMLAnchorElement18 = o
                Case 19: Set ieObj_HTMLAnchorElement19 = o
                Case 20: Set ieObj_HTMLAnchorElement20 = o
                
                Case 21: Set ieObj_HTMLAnchorElement21 = o
                Case 22: Set ieObj_HTMLAnchorElement22 = o
                Case 23: Set ieObj_HTMLAnchorElement23 = o
                Case 24: Set ieObj_HTMLAnchorElement24 = o
                Case 25: Set ieObj_HTMLAnchorElement25 = o
                Case 26: Set ieObj_HTMLAnchorElement26 = o
                Case 27: Set ieObj_HTMLAnchorElement27 = o
                Case 28: Set ieObj_HTMLAnchorElement28 = o
                Case 29: Set ieObj_HTMLAnchorElement29 = o
                Case 30: Set ieObj_HTMLAnchorElement30 = o
                Case 31: Set ieObj_HTMLAnchorElement31 = o
                Case 32: Set ieObj_HTMLAnchorElement32 = o
                Case 33: Set ieObj_HTMLAnchorElement33 = o
                Case 34: Set ieObj_HTMLAnchorElement34 = o
                Case 35: Set ieObj_HTMLAnchorElement35 = o
                Case 36: Set ieObj_HTMLAnchorElement36 = o
                Case 37: Set ieObj_HTMLAnchorElement37 = o
                Case 38: Set ieObj_HTMLAnchorElement38 = o
                Case 39: Set ieObj_HTMLAnchorElement39 = o
                Case 40: Set ieObj_HTMLAnchorElement40 = o
                Case 41: Set ieObj_HTMLAnchorElement41 = o
                Case 42: Set ieObj_HTMLAnchorElement42 = o
                Case 43: Set ieObj_HTMLAnchorElement43 = o
                Case 44: Set ieObj_HTMLAnchorElement44 = o
                Case 45: Set ieObj_HTMLAnchorElement45 = o
                Case 46: Set ieObj_HTMLAnchorElement46 = o
                Case 47: Set ieObj_HTMLAnchorElement47 = o
                Case 48: Set ieObj_HTMLAnchorElement48 = o
                Case 49: Set ieObj_HTMLAnchorElement49 = o
                Case 50: Set ieObj_HTMLAnchorElement50 = o
                Case 51: Set ieObj_HTMLAnchorElement51 = o
                Case 52: Set ieObj_HTMLAnchorElement52 = o
                Case 53: Set ieObj_HTMLAnchorElement53 = o
                Case 54: Set ieObj_HTMLAnchorElement54 = o
                Case 55: Set ieObj_HTMLAnchorElement55 = o
                Case 56: Set ieObj_HTMLAnchorElement56 = o
                Case 57: Set ieObj_HTMLAnchorElement57 = o
                Case 58: Set ieObj_HTMLAnchorElement58 = o
                Case 59: Set ieObj_HTMLAnchorElement59 = o
                Case 60: Set ieObj_HTMLAnchorElement60 = o
                Case 61: Set ieObj_HTMLAnchorElement61 = o
                Case 62: Set ieObj_HTMLAnchorElement62 = o
                Case 63: Set ieObj_HTMLAnchorElement63 = o
                Case 64: Set ieObj_HTMLAnchorElement64 = o
                Case 65: Set ieObj_HTMLAnchorElement65 = o
                Case 66: Set ieObj_HTMLAnchorElement66 = o
                Case 67: Set ieObj_HTMLAnchorElement67 = o
                Case 68: Set ieObj_HTMLAnchorElement68 = o
                Case 69: Set ieObj_HTMLAnchorElement69 = o
                Case 70: Set ieObj_HTMLAnchorElement70 = o
                Case 71: Set ieObj_HTMLAnchorElement71 = o
                Case 72: Set ieObj_HTMLAnchorElement72 = o
                Case 73: Set ieObj_HTMLAnchorElement73 = o
                Case 74: Set ieObj_HTMLAnchorElement74 = o
                Case 75: Set ieObj_HTMLAnchorElement75 = o
                Case 76: Set ieObj_HTMLAnchorElement76 = o
                Case 77: Set ieObj_HTMLAnchorElement77 = o
                Case 78: Set ieObj_HTMLAnchorElement78 = o
                Case 79: Set ieObj_HTMLAnchorElement79 = o
                Case 80: Set ieObj_HTMLAnchorElement80 = o
                Case 81: Set ieObj_HTMLAnchorElement81 = o
                Case 82: Set ieObj_HTMLAnchorElement82 = o
                Case 83: Set ieObj_HTMLAnchorElement83 = o
                Case 84: Set ieObj_HTMLAnchorElement84 = o
                Case 85: Set ieObj_HTMLAnchorElement85 = o
                Case 86: Set ieObj_HTMLAnchorElement86 = o
                Case 87: Set ieObj_HTMLAnchorElement87 = o
                Case 88: Set ieObj_HTMLAnchorElement88 = o
                Case 89: Set ieObj_HTMLAnchorElement89 = o
                Case 90: Set ieObj_HTMLAnchorElement90 = o
                Case 91: Set ieObj_HTMLAnchorElement91 = o
                Case 92: Set ieObj_HTMLAnchorElement92 = o
                Case 93: Set ieObj_HTMLAnchorElement93 = o
                Case 94: Set ieObj_HTMLAnchorElement94 = o
                Case 95: Set ieObj_HTMLAnchorElement95 = o
                Case 96: Set ieObj_HTMLAnchorElement96 = o
                Case 97: Set ieObj_HTMLAnchorElement97 = o
                Case 98: Set ieObj_HTMLAnchorElement98 = o
                Case 99: Set ieObj_HTMLAnchorElement99 = o
                Case 100: Set ieObj_HTMLAnchorElement100 = o
                Case 101: Set ieObj_HTMLAnchorElement101 = o
                Case 102: Set ieObj_HTMLAnchorElement102 = o
                Case 103: Set ieObj_HTMLAnchorElement103 = o
                Case 104: Set ieObj_HTMLAnchorElement104 = o
                Case 105: Set ieObj_HTMLAnchorElement105 = o
                Case 106: Set ieObj_HTMLAnchorElement106 = o
                Case 107: Set ieObj_HTMLAnchorElement107 = o
                Case 108: Set ieObj_HTMLAnchorElement108 = o
                Case 109: Set ieObj_HTMLAnchorElement109 = o
                Case 110: Set ieObj_HTMLAnchorElement110 = o
                Case 111: Set ieObj_HTMLAnchorElement111 = o
                Case 112: Set ieObj_HTMLAnchorElement112 = o
                Case 113: Set ieObj_HTMLAnchorElement113 = o
                Case 114: Set ieObj_HTMLAnchorElement114 = o
                Case 115: Set ieObj_HTMLAnchorElement115 = o
                Case 116: Set ieObj_HTMLAnchorElement116 = o
                Case 117: Set ieObj_HTMLAnchorElement117 = o
                Case 118: Set ieObj_HTMLAnchorElement118 = o
                Case 119: Set ieObj_HTMLAnchorElement119 = o
                Case 120: Set ieObj_HTMLAnchorElement120 = o
                Case 121: Set ieObj_HTMLAnchorElement121 = o
                Case 122: Set ieObj_HTMLAnchorElement122 = o
                Case 123: Set ieObj_HTMLAnchorElement123 = o
                Case 124: Set ieObj_HTMLAnchorElement124 = o
                Case 125: Set ieObj_HTMLAnchorElement125 = o
                Case 126: Set ieObj_HTMLAnchorElement126 = o
                Case 127: Set ieObj_HTMLAnchorElement127 = o
                
            End Select
                
        Case "HTMLIMG"

            ieObj_HTMLImgInfo(lngIndex) = strFrameName
            Select Case lngIndex
            
                Case 0: Set ieObj_HTMLImg0 = o
                Case 1: Set ieObj_HTMLImg1 = o
                Case 2: Set ieObj_HTMLImg2 = o
                Case 3: Set ieObj_HTMLImg3 = o
                Case 4: Set ieObj_HTMLImg4 = o
                Case 5: Set ieObj_HTMLImg5 = o
                Case 6: Set ieObj_HTMLImg6 = o
                Case 7: Set ieObj_HTMLImg7 = o
                Case 8: Set ieObj_HTMLImg8 = o
                Case 9: Set ieObj_HTMLImg9 = o
                Case 10: Set ieObj_HTMLImg10 = o
                Case 11: Set ieObj_HTMLImg11 = o
                Case 12: Set ieObj_HTMLImg12 = o
                Case 13: Set ieObj_HTMLImg13 = o
                Case 14: Set ieObj_HTMLImg14 = o
                Case 15: Set ieObj_HTMLImg15 = o
                Case 16: Set ieObj_HTMLImg16 = o
                Case 17: Set ieObj_HTMLImg17 = o
                Case 18: Set ieObj_HTMLImg18 = o
                Case 19: Set ieObj_HTMLImg19 = o
                Case 20: Set ieObj_HTMLImg20 = o
                
                Case 21: Set ieObj_HTMLImg21 = o
                Case 22: Set ieObj_HTMLImg22 = o
                Case 23: Set ieObj_HTMLImg23 = o
                Case 24: Set ieObj_HTMLImg24 = o
                Case 25: Set ieObj_HTMLImg25 = o
                Case 26: Set ieObj_HTMLImg26 = o
                Case 27: Set ieObj_HTMLImg27 = o
                Case 28: Set ieObj_HTMLImg28 = o
                Case 29: Set ieObj_HTMLImg29 = o
                Case 30: Set ieObj_HTMLImg30 = o
                Case 31: Set ieObj_HTMLImg31 = o
                Case 32: Set ieObj_HTMLImg32 = o
                Case 33: Set ieObj_HTMLImg33 = o
                Case 34: Set ieObj_HTMLImg34 = o
                Case 35: Set ieObj_HTMLImg35 = o
                Case 36: Set ieObj_HTMLImg36 = o
                Case 37: Set ieObj_HTMLImg37 = o
                Case 38: Set ieObj_HTMLImg38 = o
                Case 39: Set ieObj_HTMLImg39 = o
                Case 40: Set ieObj_HTMLImg40 = o
                Case 41: Set ieObj_HTMLImg41 = o
                Case 42: Set ieObj_HTMLImg42 = o
                Case 43: Set ieObj_HTMLImg43 = o
                Case 44: Set ieObj_HTMLImg44 = o
                Case 45: Set ieObj_HTMLImg45 = o
                Case 46: Set ieObj_HTMLImg46 = o
                Case 47: Set ieObj_HTMLImg47 = o
                Case 48: Set ieObj_HTMLImg48 = o
                Case 49: Set ieObj_HTMLImg49 = o
                Case 50: Set ieObj_HTMLImg50 = o
                Case 51: Set ieObj_HTMLImg51 = o
                Case 52: Set ieObj_HTMLImg52 = o
                Case 53: Set ieObj_HTMLImg53 = o
                Case 54: Set ieObj_HTMLImg54 = o
                Case 55: Set ieObj_HTMLImg55 = o
                Case 56: Set ieObj_HTMLImg56 = o
                Case 57: Set ieObj_HTMLImg57 = o
                Case 58: Set ieObj_HTMLImg58 = o
                Case 59: Set ieObj_HTMLImg59 = o
                Case 60: Set ieObj_HTMLImg60 = o
                Case 61: Set ieObj_HTMLImg61 = o
                Case 62: Set ieObj_HTMLImg62 = o
                Case 63: Set ieObj_HTMLImg63 = o
                Case 64: Set ieObj_HTMLImg64 = o
                Case 65: Set ieObj_HTMLImg65 = o
                Case 66: Set ieObj_HTMLImg66 = o
                Case 67: Set ieObj_HTMLImg67 = o
                Case 68: Set ieObj_HTMLImg68 = o
                Case 69: Set ieObj_HTMLImg69 = o
                Case 70: Set ieObj_HTMLImg70 = o
                Case 71: Set ieObj_HTMLImg71 = o
                Case 72: Set ieObj_HTMLImg72 = o
                Case 73: Set ieObj_HTMLImg73 = o
                Case 74: Set ieObj_HTMLImg74 = o
                Case 75: Set ieObj_HTMLImg75 = o
                Case 76: Set ieObj_HTMLImg76 = o
                Case 77: Set ieObj_HTMLImg77 = o
                Case 78: Set ieObj_HTMLImg78 = o
                Case 79: Set ieObj_HTMLImg79 = o
                Case 80: Set ieObj_HTMLImg80 = o
                Case 81: Set ieObj_HTMLImg81 = o
                Case 82: Set ieObj_HTMLImg82 = o
                Case 83: Set ieObj_HTMLImg83 = o
                Case 84: Set ieObj_HTMLImg84 = o
                Case 85: Set ieObj_HTMLImg85 = o
                Case 86: Set ieObj_HTMLImg86 = o
                Case 87: Set ieObj_HTMLImg87 = o
                Case 88: Set ieObj_HTMLImg88 = o
                Case 89: Set ieObj_HTMLImg89 = o
                Case 90: Set ieObj_HTMLImg90 = o
                Case 91: Set ieObj_HTMLImg91 = o
                Case 92: Set ieObj_HTMLImg92 = o
                Case 93: Set ieObj_HTMLImg93 = o
                Case 94: Set ieObj_HTMLImg94 = o
                Case 95: Set ieObj_HTMLImg95 = o
                Case 96: Set ieObj_HTMLImg96 = o
                Case 97: Set ieObj_HTMLImg97 = o
                Case 98: Set ieObj_HTMLImg98 = o
                Case 99: Set ieObj_HTMLImg99 = o
                Case 100: Set ieObj_HTMLImg100 = o
                Case 101: Set ieObj_HTMLImg101 = o
                Case 102: Set ieObj_HTMLImg102 = o
                Case 103: Set ieObj_HTMLImg103 = o
                Case 104: Set ieObj_HTMLImg104 = o
                Case 105: Set ieObj_HTMLImg105 = o
                Case 106: Set ieObj_HTMLImg106 = o
                Case 107: Set ieObj_HTMLImg107 = o
                Case 108: Set ieObj_HTMLImg108 = o
                Case 109: Set ieObj_HTMLImg109 = o
                Case 110: Set ieObj_HTMLImg110 = o
                Case 111: Set ieObj_HTMLImg111 = o
                Case 112: Set ieObj_HTMLImg112 = o
                Case 113: Set ieObj_HTMLImg113 = o
                Case 114: Set ieObj_HTMLImg114 = o
                Case 115: Set ieObj_HTMLImg115 = o
                Case 116: Set ieObj_HTMLImg116 = o
                Case 117: Set ieObj_HTMLImg117 = o
                Case 118: Set ieObj_HTMLImg118 = o
                Case 119: Set ieObj_HTMLImg119 = o
                Case 120: Set ieObj_HTMLImg120 = o
                Case 121: Set ieObj_HTMLImg121 = o
                Case 122: Set ieObj_HTMLImg122 = o
                Case 123: Set ieObj_HTMLImg123 = o
                Case 124: Set ieObj_HTMLImg124 = o
                Case 125: Set ieObj_HTMLImg125 = o
                Case 126: Set ieObj_HTMLImg126 = o
                Case 127: Set ieObj_HTMLImg127 = o
                
            End Select
            
        Case "HTMLTABLECELL"

            ieObj_HTMLTableCellInfo(lngIndex) = strFrameName
            Select Case lngIndex
            
                Case 0: Set ieObj_HTMLTableCell0 = o
                Case 1: Set ieObj_HTMLTableCell1 = o
                Case 2: Set ieObj_HTMLTableCell2 = o
                Case 3: Set ieObj_HTMLTableCell3 = o
                Case 4: Set ieObj_HTMLTableCell4 = o
                Case 5: Set ieObj_HTMLTableCell5 = o
                Case 6: Set ieObj_HTMLTableCell6 = o
                Case 7: Set ieObj_HTMLTableCell7 = o
                Case 8: Set ieObj_HTMLTableCell8 = o
                Case 9: Set ieObj_HTMLTableCell9 = o
                Case 10: Set ieObj_HTMLTableCell10 = o
                Case 11: Set ieObj_HTMLTableCell11 = o
                Case 12: Set ieObj_HTMLTableCell12 = o
                Case 13: Set ieObj_HTMLTableCell13 = o
                Case 14: Set ieObj_HTMLTableCell14 = o
                Case 15: Set ieObj_HTMLTableCell15 = o
                Case 16: Set ieObj_HTMLTableCell16 = o
                Case 17: Set ieObj_HTMLTableCell17 = o
                Case 18: Set ieObj_HTMLTableCell18 = o
                Case 19: Set ieObj_HTMLTableCell19 = o
                Case 20: Set ieObj_HTMLTableCell20 = o
                
                Case 21: Set ieObj_HTMLTableCell21 = o
                Case 22: Set ieObj_HTMLTableCell22 = o
                Case 23: Set ieObj_HTMLTableCell23 = o
                Case 24: Set ieObj_HTMLTableCell24 = o
                Case 25: Set ieObj_HTMLTableCell25 = o
                Case 26: Set ieObj_HTMLTableCell26 = o
                Case 27: Set ieObj_HTMLTableCell27 = o
                Case 28: Set ieObj_HTMLTableCell28 = o
                Case 29: Set ieObj_HTMLTableCell29 = o
                Case 30: Set ieObj_HTMLTableCell30 = o
                Case 31: Set ieObj_HTMLTableCell31 = o
                Case 32: Set ieObj_HTMLTableCell32 = o
                Case 33: Set ieObj_HTMLTableCell33 = o
                Case 34: Set ieObj_HTMLTableCell34 = o
                Case 35: Set ieObj_HTMLTableCell35 = o
                Case 36: Set ieObj_HTMLTableCell36 = o
                Case 37: Set ieObj_HTMLTableCell37 = o
                Case 38: Set ieObj_HTMLTableCell38 = o
                Case 39: Set ieObj_HTMLTableCell39 = o
                Case 40: Set ieObj_HTMLTableCell40 = o
                Case 41: Set ieObj_HTMLTableCell41 = o
                Case 42: Set ieObj_HTMLTableCell42 = o
                Case 43: Set ieObj_HTMLTableCell43 = o
                Case 44: Set ieObj_HTMLTableCell44 = o
                Case 45: Set ieObj_HTMLTableCell45 = o
                Case 46: Set ieObj_HTMLTableCell46 = o
                Case 47: Set ieObj_HTMLTableCell47 = o
                Case 48: Set ieObj_HTMLTableCell48 = o
                Case 49: Set ieObj_HTMLTableCell49 = o
                Case 50: Set ieObj_HTMLTableCell50 = o
                Case 51: Set ieObj_HTMLTableCell51 = o
                Case 52: Set ieObj_HTMLTableCell52 = o
                Case 53: Set ieObj_HTMLTableCell53 = o
                Case 54: Set ieObj_HTMLTableCell54 = o
                Case 55: Set ieObj_HTMLTableCell55 = o
                Case 56: Set ieObj_HTMLTableCell56 = o
                Case 57: Set ieObj_HTMLTableCell57 = o
                Case 58: Set ieObj_HTMLTableCell58 = o
                Case 59: Set ieObj_HTMLTableCell59 = o
                Case 60: Set ieObj_HTMLTableCell60 = o
                Case 61: Set ieObj_HTMLTableCell61 = o
                Case 62: Set ieObj_HTMLTableCell62 = o
                Case 63: Set ieObj_HTMLTableCell63 = o
                Case 64: Set ieObj_HTMLTableCell64 = o
                Case 65: Set ieObj_HTMLTableCell65 = o
                Case 66: Set ieObj_HTMLTableCell66 = o
                Case 67: Set ieObj_HTMLTableCell67 = o
                Case 68: Set ieObj_HTMLTableCell68 = o
                Case 69: Set ieObj_HTMLTableCell69 = o
                Case 70: Set ieObj_HTMLTableCell70 = o
                Case 71: Set ieObj_HTMLTableCell71 = o
                Case 72: Set ieObj_HTMLTableCell72 = o
                Case 73: Set ieObj_HTMLTableCell73 = o
                Case 74: Set ieObj_HTMLTableCell74 = o
                Case 75: Set ieObj_HTMLTableCell75 = o
                Case 76: Set ieObj_HTMLTableCell76 = o
                Case 77: Set ieObj_HTMLTableCell77 = o
                Case 78: Set ieObj_HTMLTableCell78 = o
                Case 79: Set ieObj_HTMLTableCell79 = o
                Case 80: Set ieObj_HTMLTableCell80 = o
                Case 81: Set ieObj_HTMLTableCell81 = o
                Case 82: Set ieObj_HTMLTableCell82 = o
                Case 83: Set ieObj_HTMLTableCell83 = o
                Case 84: Set ieObj_HTMLTableCell84 = o
                Case 85: Set ieObj_HTMLTableCell85 = o
                Case 86: Set ieObj_HTMLTableCell86 = o
                Case 87: Set ieObj_HTMLTableCell87 = o
                Case 88: Set ieObj_HTMLTableCell88 = o
                Case 89: Set ieObj_HTMLTableCell89 = o
                Case 90: Set ieObj_HTMLTableCell90 = o
                Case 91: Set ieObj_HTMLTableCell91 = o
                Case 92: Set ieObj_HTMLTableCell92 = o
                Case 93: Set ieObj_HTMLTableCell93 = o
                Case 94: Set ieObj_HTMLTableCell94 = o
                Case 95: Set ieObj_HTMLTableCell95 = o
                Case 96: Set ieObj_HTMLTableCell96 = o
                Case 97: Set ieObj_HTMLTableCell97 = o
                Case 98: Set ieObj_HTMLTableCell98 = o
                Case 99: Set ieObj_HTMLTableCell99 = o
                Case 100: Set ieObj_HTMLTableCell100 = o
                Case 101: Set ieObj_HTMLTableCell101 = o
                Case 102: Set ieObj_HTMLTableCell102 = o
                Case 103: Set ieObj_HTMLTableCell103 = o
                Case 104: Set ieObj_HTMLTableCell104 = o
                Case 105: Set ieObj_HTMLTableCell105 = o
                Case 106: Set ieObj_HTMLTableCell106 = o
                Case 107: Set ieObj_HTMLTableCell107 = o
                Case 108: Set ieObj_HTMLTableCell108 = o
                Case 109: Set ieObj_HTMLTableCell109 = o
                Case 110: Set ieObj_HTMLTableCell110 = o
                Case 111: Set ieObj_HTMLTableCell111 = o
                Case 112: Set ieObj_HTMLTableCell112 = o
                Case 113: Set ieObj_HTMLTableCell113 = o
                Case 114: Set ieObj_HTMLTableCell114 = o
                Case 115: Set ieObj_HTMLTableCell115 = o
                Case 116: Set ieObj_HTMLTableCell116 = o
                Case 117: Set ieObj_HTMLTableCell117 = o
                Case 118: Set ieObj_HTMLTableCell118 = o
                Case 119: Set ieObj_HTMLTableCell119 = o
                Case 120: Set ieObj_HTMLTableCell120 = o
                Case 121: Set ieObj_HTMLTableCell121 = o
                Case 122: Set ieObj_HTMLTableCell122 = o
                Case 123: Set ieObj_HTMLTableCell123 = o
                Case 124: Set ieObj_HTMLTableCell124 = o
                Case 125: Set ieObj_HTMLTableCell125 = o
                Case 126: Set ieObj_HTMLTableCell126 = o
                Case 127: Set ieObj_HTMLTableCell127 = o
                
            End Select
            
        Case "HTMLDIVELEMENT"

            ieObj_HTMLDivElementInfo(lngIndex) = strFrameName
            Select Case lngIndex
            
                Case 0: Set ieObj_HTMLDivElement0 = o
                Case 1: Set ieObj_HTMLDivElement1 = o
                Case 2: Set ieObj_HTMLDivElement2 = o
                Case 3: Set ieObj_HTMLDivElement3 = o
                Case 4: Set ieObj_HTMLDivElement4 = o
                Case 5: Set ieObj_HTMLDivElement5 = o
                Case 6: Set ieObj_HTMLDivElement6 = o
                Case 7: Set ieObj_HTMLDivElement7 = o
                Case 8: Set ieObj_HTMLDivElement8 = o
                Case 9: Set ieObj_HTMLDivElement9 = o
                Case 10: Set ieObj_HTMLDivElement10 = o
                Case 11: Set ieObj_HTMLDivElement11 = o
                Case 12: Set ieObj_HTMLDivElement12 = o
                Case 13: Set ieObj_HTMLDivElement13 = o
                Case 14: Set ieObj_HTMLDivElement14 = o
                Case 15: Set ieObj_HTMLDivElement15 = o
                Case 16: Set ieObj_HTMLDivElement16 = o
                Case 17: Set ieObj_HTMLDivElement17 = o
                Case 18: Set ieObj_HTMLDivElement18 = o
                Case 19: Set ieObj_HTMLDivElement19 = o
                Case 20: Set ieObj_HTMLDivElement20 = o
                
                Case 21: Set ieObj_HTMLDivElement21 = o
                Case 22: Set ieObj_HTMLDivElement22 = o
                Case 23: Set ieObj_HTMLDivElement23 = o
                Case 24: Set ieObj_HTMLDivElement24 = o
                Case 25: Set ieObj_HTMLDivElement25 = o
                Case 26: Set ieObj_HTMLDivElement26 = o
                Case 27: Set ieObj_HTMLDivElement27 = o
                Case 28: Set ieObj_HTMLDivElement28 = o
                Case 29: Set ieObj_HTMLDivElement29 = o
                Case 30: Set ieObj_HTMLDivElement30 = o
                Case 31: Set ieObj_HTMLDivElement31 = o
                Case 32: Set ieObj_HTMLDivElement32 = o
                Case 33: Set ieObj_HTMLDivElement33 = o
                Case 34: Set ieObj_HTMLDivElement34 = o
                Case 35: Set ieObj_HTMLDivElement35 = o
                Case 36: Set ieObj_HTMLDivElement36 = o
                Case 37: Set ieObj_HTMLDivElement37 = o
                Case 38: Set ieObj_HTMLDivElement38 = o
                Case 39: Set ieObj_HTMLDivElement39 = o
                Case 40: Set ieObj_HTMLDivElement40 = o
                Case 41: Set ieObj_HTMLDivElement41 = o
                Case 42: Set ieObj_HTMLDivElement42 = o
                Case 43: Set ieObj_HTMLDivElement43 = o
                Case 44: Set ieObj_HTMLDivElement44 = o
                Case 45: Set ieObj_HTMLDivElement45 = o
                Case 46: Set ieObj_HTMLDivElement46 = o
                Case 47: Set ieObj_HTMLDivElement47 = o
                Case 48: Set ieObj_HTMLDivElement48 = o
                Case 49: Set ieObj_HTMLDivElement49 = o
                Case 50: Set ieObj_HTMLDivElement50 = o
                Case 51: Set ieObj_HTMLDivElement51 = o
                Case 52: Set ieObj_HTMLDivElement52 = o
                Case 53: Set ieObj_HTMLDivElement53 = o
                Case 54: Set ieObj_HTMLDivElement54 = o
                Case 55: Set ieObj_HTMLDivElement55 = o
                Case 56: Set ieObj_HTMLDivElement56 = o
                Case 57: Set ieObj_HTMLDivElement57 = o
                Case 58: Set ieObj_HTMLDivElement58 = o
                Case 59: Set ieObj_HTMLDivElement59 = o
                Case 60: Set ieObj_HTMLDivElement60 = o
                Case 61: Set ieObj_HTMLDivElement61 = o
                Case 62: Set ieObj_HTMLDivElement62 = o
                Case 63: Set ieObj_HTMLDivElement63 = o
                Case 64: Set ieObj_HTMLDivElement64 = o
                Case 65: Set ieObj_HTMLDivElement65 = o
                Case 66: Set ieObj_HTMLDivElement66 = o
                Case 67: Set ieObj_HTMLDivElement67 = o
                Case 68: Set ieObj_HTMLDivElement68 = o
                Case 69: Set ieObj_HTMLDivElement69 = o
                Case 70: Set ieObj_HTMLDivElement70 = o
                Case 71: Set ieObj_HTMLDivElement71 = o
                Case 72: Set ieObj_HTMLDivElement72 = o
                Case 73: Set ieObj_HTMLDivElement73 = o
                Case 74: Set ieObj_HTMLDivElement74 = o
                Case 75: Set ieObj_HTMLDivElement75 = o
                Case 76: Set ieObj_HTMLDivElement76 = o
                Case 77: Set ieObj_HTMLDivElement77 = o
                Case 78: Set ieObj_HTMLDivElement78 = o
                Case 79: Set ieObj_HTMLDivElement79 = o
                Case 80: Set ieObj_HTMLDivElement80 = o
                Case 81: Set ieObj_HTMLDivElement81 = o
                Case 82: Set ieObj_HTMLDivElement82 = o
                Case 83: Set ieObj_HTMLDivElement83 = o
                Case 84: Set ieObj_HTMLDivElement84 = o
                Case 85: Set ieObj_HTMLDivElement85 = o
                Case 86: Set ieObj_HTMLDivElement86 = o
                Case 87: Set ieObj_HTMLDivElement87 = o
                Case 88: Set ieObj_HTMLDivElement88 = o
                Case 89: Set ieObj_HTMLDivElement89 = o
                Case 90: Set ieObj_HTMLDivElement90 = o
                Case 91: Set ieObj_HTMLDivElement91 = o
                Case 92: Set ieObj_HTMLDivElement92 = o
                Case 93: Set ieObj_HTMLDivElement93 = o
                Case 94: Set ieObj_HTMLDivElement94 = o
                Case 95: Set ieObj_HTMLDivElement95 = o
                Case 96: Set ieObj_HTMLDivElement96 = o
                Case 97: Set ieObj_HTMLDivElement97 = o
                Case 98: Set ieObj_HTMLDivElement98 = o
                Case 99: Set ieObj_HTMLDivElement99 = o
                Case 100: Set ieObj_HTMLDivElement100 = o
                Case 101: Set ieObj_HTMLDivElement101 = o
                Case 102: Set ieObj_HTMLDivElement102 = o
                Case 103: Set ieObj_HTMLDivElement103 = o
                Case 104: Set ieObj_HTMLDivElement104 = o
                Case 105: Set ieObj_HTMLDivElement105 = o
                Case 106: Set ieObj_HTMLDivElement106 = o
                Case 107: Set ieObj_HTMLDivElement107 = o
                Case 108: Set ieObj_HTMLDivElement108 = o
                Case 109: Set ieObj_HTMLDivElement109 = o
                Case 110: Set ieObj_HTMLDivElement110 = o
                Case 111: Set ieObj_HTMLDivElement111 = o
                Case 112: Set ieObj_HTMLDivElement112 = o
                Case 113: Set ieObj_HTMLDivElement113 = o
                Case 114: Set ieObj_HTMLDivElement114 = o
                Case 115: Set ieObj_HTMLDivElement115 = o
                Case 116: Set ieObj_HTMLDivElement116 = o
                Case 117: Set ieObj_HTMLDivElement117 = o
                Case 118: Set ieObj_HTMLDivElement118 = o
                Case 119: Set ieObj_HTMLDivElement119 = o
                Case 120: Set ieObj_HTMLDivElement120 = o
                Case 121: Set ieObj_HTMLDivElement121 = o
                Case 122: Set ieObj_HTMLDivElement122 = o
                Case 123: Set ieObj_HTMLDivElement123 = o
                Case 124: Set ieObj_HTMLDivElement124 = o
                Case 125: Set ieObj_HTMLDivElement125 = o
                Case 126: Set ieObj_HTMLDivElement126 = o
                Case 127: Set ieObj_HTMLDivElement127 = o
                
            End Select
    End Select
End Function

Private Sub Form_KeyPress(KeyAscii As Integer)
    Select Case KeyAscii
        Case vbKeyEscape
            m_booCancelReadingObjectDefinition = True
    End Select
End Sub


Private Function ieObj_HTMLInputElement0_onclick() As Boolean
  ieObj_HTMLInputElement0_onclick = ieObj_EventManager(0, ieObj_HTMLInputElement0, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement0_onclick() As Boolean
  ieObj_HTMLSelectElement0_onclick = ieObj_EventManager(0, ieObj_HTMLSelectElement0, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement0_onclick() As Boolean
  ieObj_HTMLButtonElement0_onclick = ieObj_EventManager(0, ieObj_HTMLButtonElement0, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement0_onclick() As Boolean
  ieObj_HTMLAnchorElement0_onclick = ieObj_EventManager(0, ieObj_HTMLAnchorElement0, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement0_onclick() As Boolean
  ieObj_HTMLTextAreaElement0_onclick = ieObj_EventManager(0, ieObj_HTMLTextAreaElement0, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg0_onclick() As Boolean
  ieObj_HTMLImg0_onclick = ieObj_EventManager(0, ieObj_HTMLImg0, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell0_onclick() As Boolean
  ieObj_HTMLTableCell0_onclick = ieObj_EventManager(0, ieObj_HTMLTableCell0, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement0_onclick() As Boolean
  ieObj_HTMLDivElement0_onclick = ieObj_EventManager(0, ieObj_HTMLDivElement0, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement1_onclick() As Boolean
  ieObj_HTMLInputElement1_onclick = ieObj_EventManager(1, ieObj_HTMLInputElement1, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement1_onclick() As Boolean
  ieObj_HTMLSelectElement1_onclick = ieObj_EventManager(1, ieObj_HTMLSelectElement1, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement1_onclick() As Boolean
  ieObj_HTMLButtonElement1_onclick = ieObj_EventManager(1, ieObj_HTMLButtonElement1, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement1_onclick() As Boolean
  ieObj_HTMLAnchorElement1_onclick = ieObj_EventManager(1, ieObj_HTMLAnchorElement1, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement1_onclick() As Boolean
  ieObj_HTMLTextAreaElement1_onclick = ieObj_EventManager(1, ieObj_HTMLTextAreaElement1, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg1_onclick() As Boolean
  ieObj_HTMLImg1_onclick = ieObj_EventManager(1, ieObj_HTMLImg1, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell1_onclick() As Boolean
  ieObj_HTMLTableCell1_onclick = ieObj_EventManager(1, ieObj_HTMLTableCell1, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement1_onclick() As Boolean
  ieObj_HTMLDivElement1_onclick = ieObj_EventManager(1, ieObj_HTMLDivElement1, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement2_onclick() As Boolean
  ieObj_HTMLInputElement2_onclick = ieObj_EventManager(2, ieObj_HTMLInputElement2, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement2_onclick() As Boolean
  ieObj_HTMLSelectElement2_onclick = ieObj_EventManager(2, ieObj_HTMLSelectElement2, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement2_onclick() As Boolean
  ieObj_HTMLButtonElement2_onclick = ieObj_EventManager(2, ieObj_HTMLButtonElement2, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement2_onclick() As Boolean
  ieObj_HTMLAnchorElement2_onclick = ieObj_EventManager(2, ieObj_HTMLAnchorElement2, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement2_onclick() As Boolean
  ieObj_HTMLTextAreaElement2_onclick = ieObj_EventManager(2, ieObj_HTMLTextAreaElement2, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg2_onclick() As Boolean
  ieObj_HTMLImg2_onclick = ieObj_EventManager(2, ieObj_HTMLImg2, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell2_onclick() As Boolean
  ieObj_HTMLTableCell2_onclick = ieObj_EventManager(2, ieObj_HTMLTableCell2, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement2_onclick() As Boolean
  ieObj_HTMLDivElement2_onclick = ieObj_EventManager(2, ieObj_HTMLDivElement2, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement3_onclick() As Boolean
  ieObj_HTMLInputElement3_onclick = ieObj_EventManager(3, ieObj_HTMLInputElement3, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement3_onclick() As Boolean
  ieObj_HTMLSelectElement3_onclick = ieObj_EventManager(3, ieObj_HTMLSelectElement3, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement3_onclick() As Boolean
  ieObj_HTMLButtonElement3_onclick = ieObj_EventManager(3, ieObj_HTMLButtonElement3, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement3_onclick() As Boolean
  ieObj_HTMLAnchorElement3_onclick = ieObj_EventManager(3, ieObj_HTMLAnchorElement3, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement3_onclick() As Boolean
  ieObj_HTMLTextAreaElement3_onclick = ieObj_EventManager(3, ieObj_HTMLTextAreaElement3, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg3_onclick() As Boolean
  ieObj_HTMLImg3_onclick = ieObj_EventManager(3, ieObj_HTMLImg3, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell3_onclick() As Boolean
  ieObj_HTMLTableCell3_onclick = ieObj_EventManager(3, ieObj_HTMLTableCell3, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement3_onclick() As Boolean
  ieObj_HTMLDivElement3_onclick = ieObj_EventManager(3, ieObj_HTMLDivElement3, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement4_onclick() As Boolean
  ieObj_HTMLInputElement4_onclick = ieObj_EventManager(4, ieObj_HTMLInputElement4, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement4_onclick() As Boolean
  ieObj_HTMLSelectElement4_onclick = ieObj_EventManager(4, ieObj_HTMLSelectElement4, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement4_onclick() As Boolean
  ieObj_HTMLButtonElement4_onclick = ieObj_EventManager(4, ieObj_HTMLButtonElement4, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement4_onclick() As Boolean
  ieObj_HTMLAnchorElement4_onclick = ieObj_EventManager(4, ieObj_HTMLAnchorElement4, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement4_onclick() As Boolean
  ieObj_HTMLTextAreaElement4_onclick = ieObj_EventManager(4, ieObj_HTMLTextAreaElement4, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg4_onclick() As Boolean
  ieObj_HTMLImg4_onclick = ieObj_EventManager(4, ieObj_HTMLImg4, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell4_onclick() As Boolean
  ieObj_HTMLTableCell4_onclick = ieObj_EventManager(4, ieObj_HTMLTableCell4, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement4_onclick() As Boolean
  ieObj_HTMLDivElement4_onclick = ieObj_EventManager(4, ieObj_HTMLDivElement4, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement5_onclick() As Boolean
  ieObj_HTMLInputElement5_onclick = ieObj_EventManager(5, ieObj_HTMLInputElement5, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement5_onclick() As Boolean
  ieObj_HTMLSelectElement5_onclick = ieObj_EventManager(5, ieObj_HTMLSelectElement5, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement5_onclick() As Boolean
  ieObj_HTMLButtonElement5_onclick = ieObj_EventManager(5, ieObj_HTMLButtonElement5, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement5_onclick() As Boolean
  ieObj_HTMLAnchorElement5_onclick = ieObj_EventManager(5, ieObj_HTMLAnchorElement5, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement5_onclick() As Boolean
  ieObj_HTMLTextAreaElement5_onclick = ieObj_EventManager(5, ieObj_HTMLTextAreaElement5, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg5_onclick() As Boolean
  ieObj_HTMLImg5_onclick = ieObj_EventManager(5, ieObj_HTMLImg5, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell5_onclick() As Boolean
  ieObj_HTMLTableCell5_onclick = ieObj_EventManager(5, ieObj_HTMLTableCell5, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement5_onclick() As Boolean
  ieObj_HTMLDivElement5_onclick = ieObj_EventManager(5, ieObj_HTMLDivElement5, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement6_onclick() As Boolean
  ieObj_HTMLInputElement6_onclick = ieObj_EventManager(6, ieObj_HTMLInputElement6, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement6_onclick() As Boolean
  ieObj_HTMLSelectElement6_onclick = ieObj_EventManager(6, ieObj_HTMLSelectElement6, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement6_onclick() As Boolean
  ieObj_HTMLButtonElement6_onclick = ieObj_EventManager(6, ieObj_HTMLButtonElement6, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement6_onclick() As Boolean
  ieObj_HTMLAnchorElement6_onclick = ieObj_EventManager(6, ieObj_HTMLAnchorElement6, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement6_onclick() As Boolean
  ieObj_HTMLTextAreaElement6_onclick = ieObj_EventManager(6, ieObj_HTMLTextAreaElement6, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg6_onclick() As Boolean
  ieObj_HTMLImg6_onclick = ieObj_EventManager(6, ieObj_HTMLImg6, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell6_onclick() As Boolean
  ieObj_HTMLTableCell6_onclick = ieObj_EventManager(6, ieObj_HTMLTableCell6, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement6_onclick() As Boolean
  ieObj_HTMLDivElement6_onclick = ieObj_EventManager(6, ieObj_HTMLDivElement6, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement7_onclick() As Boolean
  ieObj_HTMLInputElement7_onclick = ieObj_EventManager(7, ieObj_HTMLInputElement7, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement7_onclick() As Boolean
  ieObj_HTMLSelectElement7_onclick = ieObj_EventManager(7, ieObj_HTMLSelectElement7, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement7_onclick() As Boolean
  ieObj_HTMLButtonElement7_onclick = ieObj_EventManager(7, ieObj_HTMLButtonElement7, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement7_onclick() As Boolean
  ieObj_HTMLAnchorElement7_onclick = ieObj_EventManager(7, ieObj_HTMLAnchorElement7, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement7_onclick() As Boolean
  ieObj_HTMLTextAreaElement7_onclick = ieObj_EventManager(7, ieObj_HTMLTextAreaElement7, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg7_onclick() As Boolean
  ieObj_HTMLImg7_onclick = ieObj_EventManager(7, ieObj_HTMLImg7, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell7_onclick() As Boolean
  ieObj_HTMLTableCell7_onclick = ieObj_EventManager(7, ieObj_HTMLTableCell7, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement7_onclick() As Boolean
  ieObj_HTMLDivElement7_onclick = ieObj_EventManager(7, ieObj_HTMLDivElement7, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement8_onclick() As Boolean
  ieObj_HTMLInputElement8_onclick = ieObj_EventManager(8, ieObj_HTMLInputElement8, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement8_onclick() As Boolean
  ieObj_HTMLSelectElement8_onclick = ieObj_EventManager(8, ieObj_HTMLSelectElement8, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement8_onclick() As Boolean
  ieObj_HTMLButtonElement8_onclick = ieObj_EventManager(8, ieObj_HTMLButtonElement8, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement8_onclick() As Boolean
  ieObj_HTMLAnchorElement8_onclick = ieObj_EventManager(8, ieObj_HTMLAnchorElement8, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement8_onclick() As Boolean
  ieObj_HTMLTextAreaElement8_onclick = ieObj_EventManager(8, ieObj_HTMLTextAreaElement8, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg8_onclick() As Boolean
  ieObj_HTMLImg8_onclick = ieObj_EventManager(8, ieObj_HTMLImg8, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell8_onclick() As Boolean
  ieObj_HTMLTableCell8_onclick = ieObj_EventManager(8, ieObj_HTMLTableCell8, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement8_onclick() As Boolean
  ieObj_HTMLDivElement8_onclick = ieObj_EventManager(8, ieObj_HTMLDivElement8, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement9_onclick() As Boolean
  ieObj_HTMLInputElement9_onclick = ieObj_EventManager(9, ieObj_HTMLInputElement9, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement9_onclick() As Boolean
  ieObj_HTMLSelectElement9_onclick = ieObj_EventManager(9, ieObj_HTMLSelectElement9, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement9_onclick() As Boolean
  ieObj_HTMLButtonElement9_onclick = ieObj_EventManager(9, ieObj_HTMLButtonElement9, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement9_onclick() As Boolean
  ieObj_HTMLAnchorElement9_onclick = ieObj_EventManager(9, ieObj_HTMLAnchorElement9, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement9_onclick() As Boolean
  ieObj_HTMLTextAreaElement9_onclick = ieObj_EventManager(9, ieObj_HTMLTextAreaElement9, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg9_onclick() As Boolean
  ieObj_HTMLImg9_onclick = ieObj_EventManager(9, ieObj_HTMLImg9, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell9_onclick() As Boolean
  ieObj_HTMLTableCell9_onclick = ieObj_EventManager(9, ieObj_HTMLTableCell9, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement9_onclick() As Boolean
  ieObj_HTMLDivElement9_onclick = ieObj_EventManager(9, ieObj_HTMLDivElement9, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement10_onclick() As Boolean
  ieObj_HTMLInputElement10_onclick = ieObj_EventManager(10, ieObj_HTMLInputElement10, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement10_onclick() As Boolean
  ieObj_HTMLSelectElement10_onclick = ieObj_EventManager(10, ieObj_HTMLSelectElement10, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement10_onclick() As Boolean
  ieObj_HTMLButtonElement10_onclick = ieObj_EventManager(10, ieObj_HTMLButtonElement10, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement10_onclick() As Boolean
  ieObj_HTMLAnchorElement10_onclick = ieObj_EventManager(10, ieObj_HTMLAnchorElement10, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement10_onclick() As Boolean
  ieObj_HTMLTextAreaElement10_onclick = ieObj_EventManager(10, ieObj_HTMLTextAreaElement10, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg10_onclick() As Boolean
  ieObj_HTMLImg10_onclick = ieObj_EventManager(10, ieObj_HTMLImg10, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell10_onclick() As Boolean
  ieObj_HTMLTableCell10_onclick = ieObj_EventManager(10, ieObj_HTMLTableCell10, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement10_onclick() As Boolean
  ieObj_HTMLDivElement10_onclick = ieObj_EventManager(10, ieObj_HTMLDivElement10, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement11_onclick() As Boolean
  ieObj_HTMLInputElement11_onclick = ieObj_EventManager(11, ieObj_HTMLInputElement11, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement11_onclick() As Boolean
  ieObj_HTMLSelectElement11_onclick = ieObj_EventManager(11, ieObj_HTMLSelectElement11, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement11_onclick() As Boolean
  ieObj_HTMLButtonElement11_onclick = ieObj_EventManager(11, ieObj_HTMLButtonElement11, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement11_onclick() As Boolean
  ieObj_HTMLAnchorElement11_onclick = ieObj_EventManager(11, ieObj_HTMLAnchorElement11, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement11_onclick() As Boolean
  ieObj_HTMLTextAreaElement11_onclick = ieObj_EventManager(11, ieObj_HTMLTextAreaElement11, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg11_onclick() As Boolean
  ieObj_HTMLImg11_onclick = ieObj_EventManager(11, ieObj_HTMLImg11, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell11_onclick() As Boolean
  ieObj_HTMLTableCell11_onclick = ieObj_EventManager(11, ieObj_HTMLTableCell11, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement11_onclick() As Boolean
  ieObj_HTMLDivElement11_onclick = ieObj_EventManager(11, ieObj_HTMLDivElement11, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement12_onclick() As Boolean
  ieObj_HTMLInputElement12_onclick = ieObj_EventManager(12, ieObj_HTMLInputElement12, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement12_onclick() As Boolean
  ieObj_HTMLSelectElement12_onclick = ieObj_EventManager(12, ieObj_HTMLSelectElement12, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement12_onclick() As Boolean
  ieObj_HTMLButtonElement12_onclick = ieObj_EventManager(12, ieObj_HTMLButtonElement12, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement12_onclick() As Boolean
  ieObj_HTMLAnchorElement12_onclick = ieObj_EventManager(12, ieObj_HTMLAnchorElement12, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement12_onclick() As Boolean
  ieObj_HTMLTextAreaElement12_onclick = ieObj_EventManager(12, ieObj_HTMLTextAreaElement12, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg12_onclick() As Boolean
  ieObj_HTMLImg12_onclick = ieObj_EventManager(12, ieObj_HTMLImg12, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell12_onclick() As Boolean
  ieObj_HTMLTableCell12_onclick = ieObj_EventManager(12, ieObj_HTMLTableCell12, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement12_onclick() As Boolean
  ieObj_HTMLDivElement12_onclick = ieObj_EventManager(12, ieObj_HTMLDivElement12, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement13_onclick() As Boolean
  ieObj_HTMLInputElement13_onclick = ieObj_EventManager(13, ieObj_HTMLInputElement13, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement13_onclick() As Boolean
  ieObj_HTMLSelectElement13_onclick = ieObj_EventManager(13, ieObj_HTMLSelectElement13, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement13_onclick() As Boolean
  ieObj_HTMLButtonElement13_onclick = ieObj_EventManager(13, ieObj_HTMLButtonElement13, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement13_onclick() As Boolean
  ieObj_HTMLAnchorElement13_onclick = ieObj_EventManager(13, ieObj_HTMLAnchorElement13, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement13_onclick() As Boolean
  ieObj_HTMLTextAreaElement13_onclick = ieObj_EventManager(13, ieObj_HTMLTextAreaElement13, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg13_onclick() As Boolean
  ieObj_HTMLImg13_onclick = ieObj_EventManager(13, ieObj_HTMLImg13, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell13_onclick() As Boolean
  ieObj_HTMLTableCell13_onclick = ieObj_EventManager(13, ieObj_HTMLTableCell13, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement13_onclick() As Boolean
  ieObj_HTMLDivElement13_onclick = ieObj_EventManager(13, ieObj_HTMLDivElement13, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement14_onclick() As Boolean
  ieObj_HTMLInputElement14_onclick = ieObj_EventManager(14, ieObj_HTMLInputElement14, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement14_onclick() As Boolean
  ieObj_HTMLSelectElement14_onclick = ieObj_EventManager(14, ieObj_HTMLSelectElement14, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement14_onclick() As Boolean
  ieObj_HTMLButtonElement14_onclick = ieObj_EventManager(14, ieObj_HTMLButtonElement14, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement14_onclick() As Boolean
  ieObj_HTMLAnchorElement14_onclick = ieObj_EventManager(14, ieObj_HTMLAnchorElement14, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement14_onclick() As Boolean
  ieObj_HTMLTextAreaElement14_onclick = ieObj_EventManager(14, ieObj_HTMLTextAreaElement14, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg14_onclick() As Boolean
  ieObj_HTMLImg14_onclick = ieObj_EventManager(14, ieObj_HTMLImg14, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell14_onclick() As Boolean
  ieObj_HTMLTableCell14_onclick = ieObj_EventManager(14, ieObj_HTMLTableCell14, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement14_onclick() As Boolean
  ieObj_HTMLDivElement14_onclick = ieObj_EventManager(14, ieObj_HTMLDivElement14, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement15_onclick() As Boolean
  ieObj_HTMLInputElement15_onclick = ieObj_EventManager(15, ieObj_HTMLInputElement15, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement15_onclick() As Boolean
  ieObj_HTMLSelectElement15_onclick = ieObj_EventManager(15, ieObj_HTMLSelectElement15, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement15_onclick() As Boolean
  ieObj_HTMLButtonElement15_onclick = ieObj_EventManager(15, ieObj_HTMLButtonElement15, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement15_onclick() As Boolean
  ieObj_HTMLAnchorElement15_onclick = ieObj_EventManager(15, ieObj_HTMLAnchorElement15, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement15_onclick() As Boolean
  ieObj_HTMLTextAreaElement15_onclick = ieObj_EventManager(15, ieObj_HTMLTextAreaElement15, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg15_onclick() As Boolean
  ieObj_HTMLImg15_onclick = ieObj_EventManager(15, ieObj_HTMLImg15, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell15_onclick() As Boolean
  ieObj_HTMLTableCell15_onclick = ieObj_EventManager(15, ieObj_HTMLTableCell15, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement15_onclick() As Boolean
  ieObj_HTMLDivElement15_onclick = ieObj_EventManager(15, ieObj_HTMLDivElement15, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement16_onclick() As Boolean
  ieObj_HTMLInputElement16_onclick = ieObj_EventManager(16, ieObj_HTMLInputElement16, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement16_onclick() As Boolean
  ieObj_HTMLSelectElement16_onclick = ieObj_EventManager(16, ieObj_HTMLSelectElement16, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement16_onclick() As Boolean
  ieObj_HTMLButtonElement16_onclick = ieObj_EventManager(16, ieObj_HTMLButtonElement16, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement16_onclick() As Boolean
  ieObj_HTMLAnchorElement16_onclick = ieObj_EventManager(16, ieObj_HTMLAnchorElement16, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement16_onclick() As Boolean
  ieObj_HTMLTextAreaElement16_onclick = ieObj_EventManager(16, ieObj_HTMLTextAreaElement16, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg16_onclick() As Boolean
  ieObj_HTMLImg16_onclick = ieObj_EventManager(16, ieObj_HTMLImg16, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell16_onclick() As Boolean
  ieObj_HTMLTableCell16_onclick = ieObj_EventManager(16, ieObj_HTMLTableCell16, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement16_onclick() As Boolean
  ieObj_HTMLDivElement16_onclick = ieObj_EventManager(16, ieObj_HTMLDivElement16, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement17_onclick() As Boolean
  ieObj_HTMLInputElement17_onclick = ieObj_EventManager(17, ieObj_HTMLInputElement17, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement17_onclick() As Boolean
  ieObj_HTMLSelectElement17_onclick = ieObj_EventManager(17, ieObj_HTMLSelectElement17, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement17_onclick() As Boolean
  ieObj_HTMLButtonElement17_onclick = ieObj_EventManager(17, ieObj_HTMLButtonElement17, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement17_onclick() As Boolean
  ieObj_HTMLAnchorElement17_onclick = ieObj_EventManager(17, ieObj_HTMLAnchorElement17, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement17_onclick() As Boolean
  ieObj_HTMLTextAreaElement17_onclick = ieObj_EventManager(17, ieObj_HTMLTextAreaElement17, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg17_onclick() As Boolean
  ieObj_HTMLImg17_onclick = ieObj_EventManager(17, ieObj_HTMLImg17, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell17_onclick() As Boolean
  ieObj_HTMLTableCell17_onclick = ieObj_EventManager(17, ieObj_HTMLTableCell17, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement17_onclick() As Boolean
  ieObj_HTMLDivElement17_onclick = ieObj_EventManager(17, ieObj_HTMLDivElement17, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement18_onclick() As Boolean
  ieObj_HTMLInputElement18_onclick = ieObj_EventManager(18, ieObj_HTMLInputElement18, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement18_onclick() As Boolean
  ieObj_HTMLSelectElement18_onclick = ieObj_EventManager(18, ieObj_HTMLSelectElement18, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement18_onclick() As Boolean
  ieObj_HTMLButtonElement18_onclick = ieObj_EventManager(18, ieObj_HTMLButtonElement18, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement18_onclick() As Boolean
  ieObj_HTMLAnchorElement18_onclick = ieObj_EventManager(18, ieObj_HTMLAnchorElement18, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement18_onclick() As Boolean
  ieObj_HTMLTextAreaElement18_onclick = ieObj_EventManager(18, ieObj_HTMLTextAreaElement18, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg18_onclick() As Boolean
  ieObj_HTMLImg18_onclick = ieObj_EventManager(18, ieObj_HTMLImg18, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell18_onclick() As Boolean
  ieObj_HTMLTableCell18_onclick = ieObj_EventManager(18, ieObj_HTMLTableCell18, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement18_onclick() As Boolean
  ieObj_HTMLDivElement18_onclick = ieObj_EventManager(18, ieObj_HTMLDivElement18, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement19_onclick() As Boolean
  ieObj_HTMLInputElement19_onclick = ieObj_EventManager(19, ieObj_HTMLInputElement19, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement19_onclick() As Boolean
  ieObj_HTMLSelectElement19_onclick = ieObj_EventManager(19, ieObj_HTMLSelectElement19, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement19_onclick() As Boolean
  ieObj_HTMLButtonElement19_onclick = ieObj_EventManager(19, ieObj_HTMLButtonElement19, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement19_onclick() As Boolean
  ieObj_HTMLAnchorElement19_onclick = ieObj_EventManager(19, ieObj_HTMLAnchorElement19, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement19_onclick() As Boolean
  ieObj_HTMLTextAreaElement19_onclick = ieObj_EventManager(19, ieObj_HTMLTextAreaElement19, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg19_onclick() As Boolean
  ieObj_HTMLImg19_onclick = ieObj_EventManager(19, ieObj_HTMLImg19, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell19_onclick() As Boolean
  ieObj_HTMLTableCell19_onclick = ieObj_EventManager(19, ieObj_HTMLTableCell19, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement19_onclick() As Boolean
  ieObj_HTMLDivElement19_onclick = ieObj_EventManager(19, ieObj_HTMLDivElement19, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement20_onclick() As Boolean
  ieObj_HTMLInputElement20_onclick = ieObj_EventManager(20, ieObj_HTMLInputElement20, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement20_onclick() As Boolean
  ieObj_HTMLSelectElement20_onclick = ieObj_EventManager(20, ieObj_HTMLSelectElement20, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement20_onclick() As Boolean
  ieObj_HTMLButtonElement20_onclick = ieObj_EventManager(20, ieObj_HTMLButtonElement20, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement20_onclick() As Boolean
  ieObj_HTMLAnchorElement20_onclick = ieObj_EventManager(20, ieObj_HTMLAnchorElement20, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement20_onclick() As Boolean
  ieObj_HTMLTextAreaElement20_onclick = ieObj_EventManager(20, ieObj_HTMLTextAreaElement20, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg20_onclick() As Boolean
  ieObj_HTMLImg20_onclick = ieObj_EventManager(20, ieObj_HTMLImg20, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell20_onclick() As Boolean
  ieObj_HTMLTableCell20_onclick = ieObj_EventManager(20, ieObj_HTMLTableCell20, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement20_onclick() As Boolean
  ieObj_HTMLDivElement20_onclick = ieObj_EventManager(20, ieObj_HTMLDivElement20, "HTMLDivElement", "OnClick")
End Function


Private Function ieObj_HTMLInputElement21_onclick() As Boolean
  ieObj_HTMLInputElement21_onclick = ieObj_EventManager(21, ieObj_HTMLInputElement21, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement21_onclick() As Boolean
  ieObj_HTMLSelectElement21_onclick = ieObj_EventManager(21, ieObj_HTMLSelectElement21, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement21_onclick() As Boolean
  ieObj_HTMLButtonElement21_onclick = ieObj_EventManager(21, ieObj_HTMLButtonElement21, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement21_onclick() As Boolean
  ieObj_HTMLAnchorElement21_onclick = ieObj_EventManager(21, ieObj_HTMLAnchorElement21, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement21_onclick() As Boolean
  ieObj_HTMLTextAreaElement21_onclick = ieObj_EventManager(21, ieObj_HTMLTextAreaElement21, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg21_onclick() As Boolean
  ieObj_HTMLImg21_onclick = ieObj_EventManager(21, ieObj_HTMLImg21, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell21_onclick() As Boolean
  ieObj_HTMLTableCell21_onclick = ieObj_EventManager(21, ieObj_HTMLTableCell21, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement21_onclick() As Boolean
  ieObj_HTMLDivElement21_onclick = ieObj_EventManager(21, ieObj_HTMLDivElement21, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement22_onclick() As Boolean
  ieObj_HTMLInputElement22_onclick = ieObj_EventManager(22, ieObj_HTMLInputElement22, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement22_onclick() As Boolean
  ieObj_HTMLSelectElement22_onclick = ieObj_EventManager(22, ieObj_HTMLSelectElement22, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement22_onclick() As Boolean
  ieObj_HTMLButtonElement22_onclick = ieObj_EventManager(22, ieObj_HTMLButtonElement22, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement22_onclick() As Boolean
  ieObj_HTMLAnchorElement22_onclick = ieObj_EventManager(22, ieObj_HTMLAnchorElement22, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement22_onclick() As Boolean
  ieObj_HTMLTextAreaElement22_onclick = ieObj_EventManager(22, ieObj_HTMLTextAreaElement22, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg22_onclick() As Boolean
  ieObj_HTMLImg22_onclick = ieObj_EventManager(22, ieObj_HTMLImg22, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell22_onclick() As Boolean
  ieObj_HTMLTableCell22_onclick = ieObj_EventManager(22, ieObj_HTMLTableCell22, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement22_onclick() As Boolean
  ieObj_HTMLDivElement22_onclick = ieObj_EventManager(22, ieObj_HTMLDivElement22, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement23_onclick() As Boolean
  ieObj_HTMLInputElement23_onclick = ieObj_EventManager(23, ieObj_HTMLInputElement23, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement23_onclick() As Boolean
  ieObj_HTMLSelectElement23_onclick = ieObj_EventManager(23, ieObj_HTMLSelectElement23, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement23_onclick() As Boolean
  ieObj_HTMLButtonElement23_onclick = ieObj_EventManager(23, ieObj_HTMLButtonElement23, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement23_onclick() As Boolean
  ieObj_HTMLAnchorElement23_onclick = ieObj_EventManager(23, ieObj_HTMLAnchorElement23, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement23_onclick() As Boolean
  ieObj_HTMLTextAreaElement23_onclick = ieObj_EventManager(23, ieObj_HTMLTextAreaElement23, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg23_onclick() As Boolean
  ieObj_HTMLImg23_onclick = ieObj_EventManager(23, ieObj_HTMLImg23, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell23_onclick() As Boolean
  ieObj_HTMLTableCell23_onclick = ieObj_EventManager(23, ieObj_HTMLTableCell23, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement23_onclick() As Boolean
  ieObj_HTMLDivElement23_onclick = ieObj_EventManager(23, ieObj_HTMLDivElement23, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement24_onclick() As Boolean
  ieObj_HTMLInputElement24_onclick = ieObj_EventManager(24, ieObj_HTMLInputElement24, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement24_onclick() As Boolean
  ieObj_HTMLSelectElement24_onclick = ieObj_EventManager(24, ieObj_HTMLSelectElement24, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement24_onclick() As Boolean
  ieObj_HTMLButtonElement24_onclick = ieObj_EventManager(24, ieObj_HTMLButtonElement24, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement24_onclick() As Boolean
  ieObj_HTMLAnchorElement24_onclick = ieObj_EventManager(24, ieObj_HTMLAnchorElement24, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement24_onclick() As Boolean
  ieObj_HTMLTextAreaElement24_onclick = ieObj_EventManager(24, ieObj_HTMLTextAreaElement24, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg24_onclick() As Boolean
  ieObj_HTMLImg24_onclick = ieObj_EventManager(24, ieObj_HTMLImg24, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell24_onclick() As Boolean
  ieObj_HTMLTableCell24_onclick = ieObj_EventManager(24, ieObj_HTMLTableCell24, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement24_onclick() As Boolean
  ieObj_HTMLDivElement24_onclick = ieObj_EventManager(24, ieObj_HTMLDivElement24, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement25_onclick() As Boolean
  ieObj_HTMLInputElement25_onclick = ieObj_EventManager(25, ieObj_HTMLInputElement25, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement25_onclick() As Boolean
  ieObj_HTMLSelectElement25_onclick = ieObj_EventManager(25, ieObj_HTMLSelectElement25, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement25_onclick() As Boolean
  ieObj_HTMLButtonElement25_onclick = ieObj_EventManager(25, ieObj_HTMLButtonElement25, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement25_onclick() As Boolean
  ieObj_HTMLAnchorElement25_onclick = ieObj_EventManager(25, ieObj_HTMLAnchorElement25, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement25_onclick() As Boolean
  ieObj_HTMLTextAreaElement25_onclick = ieObj_EventManager(25, ieObj_HTMLTextAreaElement25, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg25_onclick() As Boolean
  ieObj_HTMLImg25_onclick = ieObj_EventManager(25, ieObj_HTMLImg25, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell25_onclick() As Boolean
  ieObj_HTMLTableCell25_onclick = ieObj_EventManager(25, ieObj_HTMLTableCell25, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement25_onclick() As Boolean
  ieObj_HTMLDivElement25_onclick = ieObj_EventManager(25, ieObj_HTMLDivElement25, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement26_onclick() As Boolean
  ieObj_HTMLInputElement26_onclick = ieObj_EventManager(26, ieObj_HTMLInputElement26, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement26_onclick() As Boolean
  ieObj_HTMLSelectElement26_onclick = ieObj_EventManager(26, ieObj_HTMLSelectElement26, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement26_onclick() As Boolean
  ieObj_HTMLButtonElement26_onclick = ieObj_EventManager(26, ieObj_HTMLButtonElement26, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement26_onclick() As Boolean
  ieObj_HTMLAnchorElement26_onclick = ieObj_EventManager(26, ieObj_HTMLAnchorElement26, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement26_onclick() As Boolean
  ieObj_HTMLTextAreaElement26_onclick = ieObj_EventManager(26, ieObj_HTMLTextAreaElement26, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg26_onclick() As Boolean
  ieObj_HTMLImg26_onclick = ieObj_EventManager(26, ieObj_HTMLImg26, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell26_onclick() As Boolean
  ieObj_HTMLTableCell26_onclick = ieObj_EventManager(26, ieObj_HTMLTableCell26, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement26_onclick() As Boolean
  ieObj_HTMLDivElement26_onclick = ieObj_EventManager(26, ieObj_HTMLDivElement26, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement27_onclick() As Boolean
  ieObj_HTMLInputElement27_onclick = ieObj_EventManager(27, ieObj_HTMLInputElement27, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement27_onclick() As Boolean
  ieObj_HTMLSelectElement27_onclick = ieObj_EventManager(27, ieObj_HTMLSelectElement27, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement27_onclick() As Boolean
  ieObj_HTMLButtonElement27_onclick = ieObj_EventManager(27, ieObj_HTMLButtonElement27, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement27_onclick() As Boolean
  ieObj_HTMLAnchorElement27_onclick = ieObj_EventManager(27, ieObj_HTMLAnchorElement27, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement27_onclick() As Boolean
  ieObj_HTMLTextAreaElement27_onclick = ieObj_EventManager(27, ieObj_HTMLTextAreaElement27, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg27_onclick() As Boolean
  ieObj_HTMLImg27_onclick = ieObj_EventManager(27, ieObj_HTMLImg27, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell27_onclick() As Boolean
  ieObj_HTMLTableCell27_onclick = ieObj_EventManager(27, ieObj_HTMLTableCell27, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement27_onclick() As Boolean
  ieObj_HTMLDivElement27_onclick = ieObj_EventManager(27, ieObj_HTMLDivElement27, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement28_onclick() As Boolean
  ieObj_HTMLInputElement28_onclick = ieObj_EventManager(28, ieObj_HTMLInputElement28, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement28_onclick() As Boolean
  ieObj_HTMLSelectElement28_onclick = ieObj_EventManager(28, ieObj_HTMLSelectElement28, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement28_onclick() As Boolean
  ieObj_HTMLButtonElement28_onclick = ieObj_EventManager(28, ieObj_HTMLButtonElement28, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement28_onclick() As Boolean
  ieObj_HTMLAnchorElement28_onclick = ieObj_EventManager(28, ieObj_HTMLAnchorElement28, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement28_onclick() As Boolean
  ieObj_HTMLTextAreaElement28_onclick = ieObj_EventManager(28, ieObj_HTMLTextAreaElement28, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg28_onclick() As Boolean
  ieObj_HTMLImg28_onclick = ieObj_EventManager(28, ieObj_HTMLImg28, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell28_onclick() As Boolean
  ieObj_HTMLTableCell28_onclick = ieObj_EventManager(28, ieObj_HTMLTableCell28, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement28_onclick() As Boolean
  ieObj_HTMLDivElement28_onclick = ieObj_EventManager(28, ieObj_HTMLDivElement28, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement29_onclick() As Boolean
  ieObj_HTMLInputElement29_onclick = ieObj_EventManager(29, ieObj_HTMLInputElement29, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement29_onclick() As Boolean
  ieObj_HTMLSelectElement29_onclick = ieObj_EventManager(29, ieObj_HTMLSelectElement29, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement29_onclick() As Boolean
  ieObj_HTMLButtonElement29_onclick = ieObj_EventManager(29, ieObj_HTMLButtonElement29, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement29_onclick() As Boolean
  ieObj_HTMLAnchorElement29_onclick = ieObj_EventManager(29, ieObj_HTMLAnchorElement29, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement29_onclick() As Boolean
  ieObj_HTMLTextAreaElement29_onclick = ieObj_EventManager(29, ieObj_HTMLTextAreaElement29, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg29_onclick() As Boolean
  ieObj_HTMLImg29_onclick = ieObj_EventManager(29, ieObj_HTMLImg29, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell29_onclick() As Boolean
  ieObj_HTMLTableCell29_onclick = ieObj_EventManager(29, ieObj_HTMLTableCell29, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement29_onclick() As Boolean
  ieObj_HTMLDivElement29_onclick = ieObj_EventManager(29, ieObj_HTMLDivElement29, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement30_onclick() As Boolean
  ieObj_HTMLInputElement30_onclick = ieObj_EventManager(30, ieObj_HTMLInputElement30, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement30_onclick() As Boolean
  ieObj_HTMLSelectElement30_onclick = ieObj_EventManager(30, ieObj_HTMLSelectElement30, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement30_onclick() As Boolean
  ieObj_HTMLButtonElement30_onclick = ieObj_EventManager(30, ieObj_HTMLButtonElement30, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement30_onclick() As Boolean
  ieObj_HTMLAnchorElement30_onclick = ieObj_EventManager(30, ieObj_HTMLAnchorElement30, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement30_onclick() As Boolean
  ieObj_HTMLTextAreaElement30_onclick = ieObj_EventManager(30, ieObj_HTMLTextAreaElement30, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg30_onclick() As Boolean
  ieObj_HTMLImg30_onclick = ieObj_EventManager(30, ieObj_HTMLImg30, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell30_onclick() As Boolean
  ieObj_HTMLTableCell30_onclick = ieObj_EventManager(30, ieObj_HTMLTableCell30, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement30_onclick() As Boolean
  ieObj_HTMLDivElement30_onclick = ieObj_EventManager(30, ieObj_HTMLDivElement30, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement31_onclick() As Boolean
  ieObj_HTMLInputElement31_onclick = ieObj_EventManager(31, ieObj_HTMLInputElement31, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement31_onclick() As Boolean
  ieObj_HTMLSelectElement31_onclick = ieObj_EventManager(31, ieObj_HTMLSelectElement31, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement31_onclick() As Boolean
  ieObj_HTMLButtonElement31_onclick = ieObj_EventManager(31, ieObj_HTMLButtonElement31, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement31_onclick() As Boolean
  ieObj_HTMLAnchorElement31_onclick = ieObj_EventManager(31, ieObj_HTMLAnchorElement31, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement31_onclick() As Boolean
  ieObj_HTMLTextAreaElement31_onclick = ieObj_EventManager(31, ieObj_HTMLTextAreaElement31, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg31_onclick() As Boolean
  ieObj_HTMLImg31_onclick = ieObj_EventManager(31, ieObj_HTMLImg31, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell31_onclick() As Boolean
  ieObj_HTMLTableCell31_onclick = ieObj_EventManager(31, ieObj_HTMLTableCell31, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement31_onclick() As Boolean
  ieObj_HTMLDivElement31_onclick = ieObj_EventManager(31, ieObj_HTMLDivElement31, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement32_onclick() As Boolean
  ieObj_HTMLInputElement32_onclick = ieObj_EventManager(32, ieObj_HTMLInputElement32, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement32_onclick() As Boolean
  ieObj_HTMLSelectElement32_onclick = ieObj_EventManager(32, ieObj_HTMLSelectElement32, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement32_onclick() As Boolean
  ieObj_HTMLButtonElement32_onclick = ieObj_EventManager(32, ieObj_HTMLButtonElement32, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement32_onclick() As Boolean
  ieObj_HTMLAnchorElement32_onclick = ieObj_EventManager(32, ieObj_HTMLAnchorElement32, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement32_onclick() As Boolean
  ieObj_HTMLTextAreaElement32_onclick = ieObj_EventManager(32, ieObj_HTMLTextAreaElement32, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg32_onclick() As Boolean
  ieObj_HTMLImg32_onclick = ieObj_EventManager(32, ieObj_HTMLImg32, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell32_onclick() As Boolean
  ieObj_HTMLTableCell32_onclick = ieObj_EventManager(32, ieObj_HTMLTableCell32, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement32_onclick() As Boolean
  ieObj_HTMLDivElement32_onclick = ieObj_EventManager(32, ieObj_HTMLDivElement32, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement33_onclick() As Boolean
  ieObj_HTMLInputElement33_onclick = ieObj_EventManager(33, ieObj_HTMLInputElement33, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement33_onclick() As Boolean
  ieObj_HTMLSelectElement33_onclick = ieObj_EventManager(33, ieObj_HTMLSelectElement33, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement33_onclick() As Boolean
  ieObj_HTMLButtonElement33_onclick = ieObj_EventManager(33, ieObj_HTMLButtonElement33, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement33_onclick() As Boolean
  ieObj_HTMLAnchorElement33_onclick = ieObj_EventManager(33, ieObj_HTMLAnchorElement33, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement33_onclick() As Boolean
  ieObj_HTMLTextAreaElement33_onclick = ieObj_EventManager(33, ieObj_HTMLTextAreaElement33, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg33_onclick() As Boolean
  ieObj_HTMLImg33_onclick = ieObj_EventManager(33, ieObj_HTMLImg33, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell33_onclick() As Boolean
  ieObj_HTMLTableCell33_onclick = ieObj_EventManager(33, ieObj_HTMLTableCell33, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement33_onclick() As Boolean
  ieObj_HTMLDivElement33_onclick = ieObj_EventManager(33, ieObj_HTMLDivElement33, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement34_onclick() As Boolean
  ieObj_HTMLInputElement34_onclick = ieObj_EventManager(34, ieObj_HTMLInputElement34, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement34_onclick() As Boolean
  ieObj_HTMLSelectElement34_onclick = ieObj_EventManager(34, ieObj_HTMLSelectElement34, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement34_onclick() As Boolean
  ieObj_HTMLButtonElement34_onclick = ieObj_EventManager(34, ieObj_HTMLButtonElement34, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement34_onclick() As Boolean
  ieObj_HTMLAnchorElement34_onclick = ieObj_EventManager(34, ieObj_HTMLAnchorElement34, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement34_onclick() As Boolean
  ieObj_HTMLTextAreaElement34_onclick = ieObj_EventManager(34, ieObj_HTMLTextAreaElement34, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg34_onclick() As Boolean
  ieObj_HTMLImg34_onclick = ieObj_EventManager(34, ieObj_HTMLImg34, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell34_onclick() As Boolean
  ieObj_HTMLTableCell34_onclick = ieObj_EventManager(34, ieObj_HTMLTableCell34, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement34_onclick() As Boolean
  ieObj_HTMLDivElement34_onclick = ieObj_EventManager(34, ieObj_HTMLDivElement34, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement35_onclick() As Boolean
  ieObj_HTMLInputElement35_onclick = ieObj_EventManager(35, ieObj_HTMLInputElement35, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement35_onclick() As Boolean
  ieObj_HTMLSelectElement35_onclick = ieObj_EventManager(35, ieObj_HTMLSelectElement35, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement35_onclick() As Boolean
  ieObj_HTMLButtonElement35_onclick = ieObj_EventManager(35, ieObj_HTMLButtonElement35, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement35_onclick() As Boolean
  ieObj_HTMLAnchorElement35_onclick = ieObj_EventManager(35, ieObj_HTMLAnchorElement35, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement35_onclick() As Boolean
  ieObj_HTMLTextAreaElement35_onclick = ieObj_EventManager(35, ieObj_HTMLTextAreaElement35, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg35_onclick() As Boolean
  ieObj_HTMLImg35_onclick = ieObj_EventManager(35, ieObj_HTMLImg35, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell35_onclick() As Boolean
  ieObj_HTMLTableCell35_onclick = ieObj_EventManager(35, ieObj_HTMLTableCell35, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement35_onclick() As Boolean
  ieObj_HTMLDivElement35_onclick = ieObj_EventManager(35, ieObj_HTMLDivElement35, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement36_onclick() As Boolean
  ieObj_HTMLInputElement36_onclick = ieObj_EventManager(36, ieObj_HTMLInputElement36, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement36_onclick() As Boolean
  ieObj_HTMLSelectElement36_onclick = ieObj_EventManager(36, ieObj_HTMLSelectElement36, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement36_onclick() As Boolean
  ieObj_HTMLButtonElement36_onclick = ieObj_EventManager(36, ieObj_HTMLButtonElement36, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement36_onclick() As Boolean
  ieObj_HTMLAnchorElement36_onclick = ieObj_EventManager(36, ieObj_HTMLAnchorElement36, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement36_onclick() As Boolean
  ieObj_HTMLTextAreaElement36_onclick = ieObj_EventManager(36, ieObj_HTMLTextAreaElement36, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg36_onclick() As Boolean
  ieObj_HTMLImg36_onclick = ieObj_EventManager(36, ieObj_HTMLImg36, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell36_onclick() As Boolean
  ieObj_HTMLTableCell36_onclick = ieObj_EventManager(36, ieObj_HTMLTableCell36, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement36_onclick() As Boolean
  ieObj_HTMLDivElement36_onclick = ieObj_EventManager(36, ieObj_HTMLDivElement36, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement37_onclick() As Boolean
  ieObj_HTMLInputElement37_onclick = ieObj_EventManager(37, ieObj_HTMLInputElement37, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement37_onclick() As Boolean
  ieObj_HTMLSelectElement37_onclick = ieObj_EventManager(37, ieObj_HTMLSelectElement37, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement37_onclick() As Boolean
  ieObj_HTMLButtonElement37_onclick = ieObj_EventManager(37, ieObj_HTMLButtonElement37, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement37_onclick() As Boolean
  ieObj_HTMLAnchorElement37_onclick = ieObj_EventManager(37, ieObj_HTMLAnchorElement37, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement37_onclick() As Boolean
  ieObj_HTMLTextAreaElement37_onclick = ieObj_EventManager(37, ieObj_HTMLTextAreaElement37, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg37_onclick() As Boolean
  ieObj_HTMLImg37_onclick = ieObj_EventManager(37, ieObj_HTMLImg37, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell37_onclick() As Boolean
  ieObj_HTMLTableCell37_onclick = ieObj_EventManager(37, ieObj_HTMLTableCell37, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement37_onclick() As Boolean
  ieObj_HTMLDivElement37_onclick = ieObj_EventManager(37, ieObj_HTMLDivElement37, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement38_onclick() As Boolean
  ieObj_HTMLInputElement38_onclick = ieObj_EventManager(38, ieObj_HTMLInputElement38, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement38_onclick() As Boolean
  ieObj_HTMLSelectElement38_onclick = ieObj_EventManager(38, ieObj_HTMLSelectElement38, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement38_onclick() As Boolean
  ieObj_HTMLButtonElement38_onclick = ieObj_EventManager(38, ieObj_HTMLButtonElement38, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement38_onclick() As Boolean
  ieObj_HTMLAnchorElement38_onclick = ieObj_EventManager(38, ieObj_HTMLAnchorElement38, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement38_onclick() As Boolean
  ieObj_HTMLTextAreaElement38_onclick = ieObj_EventManager(38, ieObj_HTMLTextAreaElement38, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg38_onclick() As Boolean
  ieObj_HTMLImg38_onclick = ieObj_EventManager(38, ieObj_HTMLImg38, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell38_onclick() As Boolean
  ieObj_HTMLTableCell38_onclick = ieObj_EventManager(38, ieObj_HTMLTableCell38, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement38_onclick() As Boolean
  ieObj_HTMLDivElement38_onclick = ieObj_EventManager(38, ieObj_HTMLDivElement38, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement39_onclick() As Boolean
  ieObj_HTMLInputElement39_onclick = ieObj_EventManager(39, ieObj_HTMLInputElement39, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement39_onclick() As Boolean
  ieObj_HTMLSelectElement39_onclick = ieObj_EventManager(39, ieObj_HTMLSelectElement39, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement39_onclick() As Boolean
  ieObj_HTMLButtonElement39_onclick = ieObj_EventManager(39, ieObj_HTMLButtonElement39, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement39_onclick() As Boolean
  ieObj_HTMLAnchorElement39_onclick = ieObj_EventManager(39, ieObj_HTMLAnchorElement39, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement39_onclick() As Boolean
  ieObj_HTMLTextAreaElement39_onclick = ieObj_EventManager(39, ieObj_HTMLTextAreaElement39, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg39_onclick() As Boolean
  ieObj_HTMLImg39_onclick = ieObj_EventManager(39, ieObj_HTMLImg39, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell39_onclick() As Boolean
  ieObj_HTMLTableCell39_onclick = ieObj_EventManager(39, ieObj_HTMLTableCell39, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement39_onclick() As Boolean
  ieObj_HTMLDivElement39_onclick = ieObj_EventManager(39, ieObj_HTMLDivElement39, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement40_onclick() As Boolean
  ieObj_HTMLInputElement40_onclick = ieObj_EventManager(40, ieObj_HTMLInputElement40, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement40_onclick() As Boolean
  ieObj_HTMLSelectElement40_onclick = ieObj_EventManager(40, ieObj_HTMLSelectElement40, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement40_onclick() As Boolean
  ieObj_HTMLButtonElement40_onclick = ieObj_EventManager(40, ieObj_HTMLButtonElement40, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement40_onclick() As Boolean
  ieObj_HTMLAnchorElement40_onclick = ieObj_EventManager(40, ieObj_HTMLAnchorElement40, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement40_onclick() As Boolean
  ieObj_HTMLTextAreaElement40_onclick = ieObj_EventManager(40, ieObj_HTMLTextAreaElement40, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg40_onclick() As Boolean
  ieObj_HTMLImg40_onclick = ieObj_EventManager(40, ieObj_HTMLImg40, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell40_onclick() As Boolean
  ieObj_HTMLTableCell40_onclick = ieObj_EventManager(40, ieObj_HTMLTableCell40, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement40_onclick() As Boolean
  ieObj_HTMLDivElement40_onclick = ieObj_EventManager(40, ieObj_HTMLDivElement40, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement41_onclick() As Boolean
  ieObj_HTMLInputElement41_onclick = ieObj_EventManager(41, ieObj_HTMLInputElement41, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement41_onclick() As Boolean
  ieObj_HTMLSelectElement41_onclick = ieObj_EventManager(41, ieObj_HTMLSelectElement41, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement41_onclick() As Boolean
  ieObj_HTMLButtonElement41_onclick = ieObj_EventManager(41, ieObj_HTMLButtonElement41, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement41_onclick() As Boolean
  ieObj_HTMLAnchorElement41_onclick = ieObj_EventManager(41, ieObj_HTMLAnchorElement41, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement41_onclick() As Boolean
  ieObj_HTMLTextAreaElement41_onclick = ieObj_EventManager(41, ieObj_HTMLTextAreaElement41, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg41_onclick() As Boolean
  ieObj_HTMLImg41_onclick = ieObj_EventManager(41, ieObj_HTMLImg41, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell41_onclick() As Boolean
  ieObj_HTMLTableCell41_onclick = ieObj_EventManager(41, ieObj_HTMLTableCell41, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement41_onclick() As Boolean
  ieObj_HTMLDivElement41_onclick = ieObj_EventManager(41, ieObj_HTMLDivElement41, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement42_onclick() As Boolean
  ieObj_HTMLInputElement42_onclick = ieObj_EventManager(42, ieObj_HTMLInputElement42, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement42_onclick() As Boolean
  ieObj_HTMLSelectElement42_onclick = ieObj_EventManager(42, ieObj_HTMLSelectElement42, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement42_onclick() As Boolean
  ieObj_HTMLButtonElement42_onclick = ieObj_EventManager(42, ieObj_HTMLButtonElement42, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement42_onclick() As Boolean
  ieObj_HTMLAnchorElement42_onclick = ieObj_EventManager(42, ieObj_HTMLAnchorElement42, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement42_onclick() As Boolean
  ieObj_HTMLTextAreaElement42_onclick = ieObj_EventManager(42, ieObj_HTMLTextAreaElement42, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg42_onclick() As Boolean
  ieObj_HTMLImg42_onclick = ieObj_EventManager(42, ieObj_HTMLImg42, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell42_onclick() As Boolean
  ieObj_HTMLTableCell42_onclick = ieObj_EventManager(42, ieObj_HTMLTableCell42, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement42_onclick() As Boolean
  ieObj_HTMLDivElement42_onclick = ieObj_EventManager(42, ieObj_HTMLDivElement42, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement43_onclick() As Boolean
  ieObj_HTMLInputElement43_onclick = ieObj_EventManager(43, ieObj_HTMLInputElement43, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement43_onclick() As Boolean
  ieObj_HTMLSelectElement43_onclick = ieObj_EventManager(43, ieObj_HTMLSelectElement43, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement43_onclick() As Boolean
  ieObj_HTMLButtonElement43_onclick = ieObj_EventManager(43, ieObj_HTMLButtonElement43, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement43_onclick() As Boolean
  ieObj_HTMLAnchorElement43_onclick = ieObj_EventManager(43, ieObj_HTMLAnchorElement43, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement43_onclick() As Boolean
  ieObj_HTMLTextAreaElement43_onclick = ieObj_EventManager(43, ieObj_HTMLTextAreaElement43, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg43_onclick() As Boolean
  ieObj_HTMLImg43_onclick = ieObj_EventManager(43, ieObj_HTMLImg43, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell43_onclick() As Boolean
  ieObj_HTMLTableCell43_onclick = ieObj_EventManager(43, ieObj_HTMLTableCell43, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement43_onclick() As Boolean
  ieObj_HTMLDivElement43_onclick = ieObj_EventManager(43, ieObj_HTMLDivElement43, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement44_onclick() As Boolean
  ieObj_HTMLInputElement44_onclick = ieObj_EventManager(44, ieObj_HTMLInputElement44, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement44_onclick() As Boolean
  ieObj_HTMLSelectElement44_onclick = ieObj_EventManager(44, ieObj_HTMLSelectElement44, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement44_onclick() As Boolean
  ieObj_HTMLButtonElement44_onclick = ieObj_EventManager(44, ieObj_HTMLButtonElement44, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement44_onclick() As Boolean
  ieObj_HTMLAnchorElement44_onclick = ieObj_EventManager(44, ieObj_HTMLAnchorElement44, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement44_onclick() As Boolean
  ieObj_HTMLTextAreaElement44_onclick = ieObj_EventManager(44, ieObj_HTMLTextAreaElement44, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg44_onclick() As Boolean
  ieObj_HTMLImg44_onclick = ieObj_EventManager(44, ieObj_HTMLImg44, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell44_onclick() As Boolean
  ieObj_HTMLTableCell44_onclick = ieObj_EventManager(44, ieObj_HTMLTableCell44, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement44_onclick() As Boolean
  ieObj_HTMLDivElement44_onclick = ieObj_EventManager(44, ieObj_HTMLDivElement44, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement45_onclick() As Boolean
  ieObj_HTMLInputElement45_onclick = ieObj_EventManager(45, ieObj_HTMLInputElement45, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement45_onclick() As Boolean
  ieObj_HTMLSelectElement45_onclick = ieObj_EventManager(45, ieObj_HTMLSelectElement45, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement45_onclick() As Boolean
  ieObj_HTMLButtonElement45_onclick = ieObj_EventManager(45, ieObj_HTMLButtonElement45, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement45_onclick() As Boolean
  ieObj_HTMLAnchorElement45_onclick = ieObj_EventManager(45, ieObj_HTMLAnchorElement45, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement45_onclick() As Boolean
  ieObj_HTMLTextAreaElement45_onclick = ieObj_EventManager(45, ieObj_HTMLTextAreaElement45, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg45_onclick() As Boolean
  ieObj_HTMLImg45_onclick = ieObj_EventManager(45, ieObj_HTMLImg45, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell45_onclick() As Boolean
  ieObj_HTMLTableCell45_onclick = ieObj_EventManager(45, ieObj_HTMLTableCell45, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement45_onclick() As Boolean
  ieObj_HTMLDivElement45_onclick = ieObj_EventManager(45, ieObj_HTMLDivElement45, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement46_onclick() As Boolean
  ieObj_HTMLInputElement46_onclick = ieObj_EventManager(46, ieObj_HTMLInputElement46, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement46_onclick() As Boolean
  ieObj_HTMLSelectElement46_onclick = ieObj_EventManager(46, ieObj_HTMLSelectElement46, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement46_onclick() As Boolean
  ieObj_HTMLButtonElement46_onclick = ieObj_EventManager(46, ieObj_HTMLButtonElement46, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement46_onclick() As Boolean
  ieObj_HTMLAnchorElement46_onclick = ieObj_EventManager(46, ieObj_HTMLAnchorElement46, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement46_onclick() As Boolean
  ieObj_HTMLTextAreaElement46_onclick = ieObj_EventManager(46, ieObj_HTMLTextAreaElement46, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg46_onclick() As Boolean
  ieObj_HTMLImg46_onclick = ieObj_EventManager(46, ieObj_HTMLImg46, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell46_onclick() As Boolean
  ieObj_HTMLTableCell46_onclick = ieObj_EventManager(46, ieObj_HTMLTableCell46, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement46_onclick() As Boolean
  ieObj_HTMLDivElement46_onclick = ieObj_EventManager(46, ieObj_HTMLDivElement46, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement47_onclick() As Boolean
  ieObj_HTMLInputElement47_onclick = ieObj_EventManager(47, ieObj_HTMLInputElement47, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement47_onclick() As Boolean
  ieObj_HTMLSelectElement47_onclick = ieObj_EventManager(47, ieObj_HTMLSelectElement47, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement47_onclick() As Boolean
  ieObj_HTMLButtonElement47_onclick = ieObj_EventManager(47, ieObj_HTMLButtonElement47, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement47_onclick() As Boolean
  ieObj_HTMLAnchorElement47_onclick = ieObj_EventManager(47, ieObj_HTMLAnchorElement47, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement47_onclick() As Boolean
  ieObj_HTMLTextAreaElement47_onclick = ieObj_EventManager(47, ieObj_HTMLTextAreaElement47, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg47_onclick() As Boolean
  ieObj_HTMLImg47_onclick = ieObj_EventManager(47, ieObj_HTMLImg47, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell47_onclick() As Boolean
  ieObj_HTMLTableCell47_onclick = ieObj_EventManager(47, ieObj_HTMLTableCell47, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement47_onclick() As Boolean
  ieObj_HTMLDivElement47_onclick = ieObj_EventManager(47, ieObj_HTMLDivElement47, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement48_onclick() As Boolean
  ieObj_HTMLInputElement48_onclick = ieObj_EventManager(48, ieObj_HTMLInputElement48, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement48_onclick() As Boolean
  ieObj_HTMLSelectElement48_onclick = ieObj_EventManager(48, ieObj_HTMLSelectElement48, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement48_onclick() As Boolean
  ieObj_HTMLButtonElement48_onclick = ieObj_EventManager(48, ieObj_HTMLButtonElement48, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement48_onclick() As Boolean
  ieObj_HTMLAnchorElement48_onclick = ieObj_EventManager(48, ieObj_HTMLAnchorElement48, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement48_onclick() As Boolean
  ieObj_HTMLTextAreaElement48_onclick = ieObj_EventManager(48, ieObj_HTMLTextAreaElement48, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg48_onclick() As Boolean
  ieObj_HTMLImg48_onclick = ieObj_EventManager(48, ieObj_HTMLImg48, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell48_onclick() As Boolean
  ieObj_HTMLTableCell48_onclick = ieObj_EventManager(48, ieObj_HTMLTableCell48, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement48_onclick() As Boolean
  ieObj_HTMLDivElement48_onclick = ieObj_EventManager(48, ieObj_HTMLDivElement48, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement49_onclick() As Boolean
  ieObj_HTMLInputElement49_onclick = ieObj_EventManager(49, ieObj_HTMLInputElement49, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement49_onclick() As Boolean
  ieObj_HTMLSelectElement49_onclick = ieObj_EventManager(49, ieObj_HTMLSelectElement49, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement49_onclick() As Boolean
  ieObj_HTMLButtonElement49_onclick = ieObj_EventManager(49, ieObj_HTMLButtonElement49, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement49_onclick() As Boolean
  ieObj_HTMLAnchorElement49_onclick = ieObj_EventManager(49, ieObj_HTMLAnchorElement49, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement49_onclick() As Boolean
  ieObj_HTMLTextAreaElement49_onclick = ieObj_EventManager(49, ieObj_HTMLTextAreaElement49, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg49_onclick() As Boolean
  ieObj_HTMLImg49_onclick = ieObj_EventManager(49, ieObj_HTMLImg49, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell49_onclick() As Boolean
  ieObj_HTMLTableCell49_onclick = ieObj_EventManager(49, ieObj_HTMLTableCell49, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement49_onclick() As Boolean
  ieObj_HTMLDivElement49_onclick = ieObj_EventManager(49, ieObj_HTMLDivElement49, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement50_onclick() As Boolean
  ieObj_HTMLInputElement50_onclick = ieObj_EventManager(50, ieObj_HTMLInputElement50, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement50_onclick() As Boolean
  ieObj_HTMLSelectElement50_onclick = ieObj_EventManager(50, ieObj_HTMLSelectElement50, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement50_onclick() As Boolean
  ieObj_HTMLButtonElement50_onclick = ieObj_EventManager(50, ieObj_HTMLButtonElement50, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement50_onclick() As Boolean
  ieObj_HTMLAnchorElement50_onclick = ieObj_EventManager(50, ieObj_HTMLAnchorElement50, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement50_onclick() As Boolean
  ieObj_HTMLTextAreaElement50_onclick = ieObj_EventManager(50, ieObj_HTMLTextAreaElement50, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg50_onclick() As Boolean
  ieObj_HTMLImg50_onclick = ieObj_EventManager(50, ieObj_HTMLImg50, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell50_onclick() As Boolean
  ieObj_HTMLTableCell50_onclick = ieObj_EventManager(50, ieObj_HTMLTableCell50, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement50_onclick() As Boolean
  ieObj_HTMLDivElement50_onclick = ieObj_EventManager(50, ieObj_HTMLDivElement50, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement51_onclick() As Boolean
  ieObj_HTMLInputElement51_onclick = ieObj_EventManager(51, ieObj_HTMLInputElement51, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement51_onclick() As Boolean
  ieObj_HTMLSelectElement51_onclick = ieObj_EventManager(51, ieObj_HTMLSelectElement51, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement51_onclick() As Boolean
  ieObj_HTMLButtonElement51_onclick = ieObj_EventManager(51, ieObj_HTMLButtonElement51, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement51_onclick() As Boolean
  ieObj_HTMLAnchorElement51_onclick = ieObj_EventManager(51, ieObj_HTMLAnchorElement51, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement51_onclick() As Boolean
  ieObj_HTMLTextAreaElement51_onclick = ieObj_EventManager(51, ieObj_HTMLTextAreaElement51, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg51_onclick() As Boolean
  ieObj_HTMLImg51_onclick = ieObj_EventManager(51, ieObj_HTMLImg51, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell51_onclick() As Boolean
  ieObj_HTMLTableCell51_onclick = ieObj_EventManager(51, ieObj_HTMLTableCell51, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement51_onclick() As Boolean
  ieObj_HTMLDivElement51_onclick = ieObj_EventManager(51, ieObj_HTMLDivElement51, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement52_onclick() As Boolean
  ieObj_HTMLInputElement52_onclick = ieObj_EventManager(52, ieObj_HTMLInputElement52, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement52_onclick() As Boolean
  ieObj_HTMLSelectElement52_onclick = ieObj_EventManager(52, ieObj_HTMLSelectElement52, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement52_onclick() As Boolean
  ieObj_HTMLButtonElement52_onclick = ieObj_EventManager(52, ieObj_HTMLButtonElement52, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement52_onclick() As Boolean
  ieObj_HTMLAnchorElement52_onclick = ieObj_EventManager(52, ieObj_HTMLAnchorElement52, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement52_onclick() As Boolean
  ieObj_HTMLTextAreaElement52_onclick = ieObj_EventManager(52, ieObj_HTMLTextAreaElement52, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg52_onclick() As Boolean
  ieObj_HTMLImg52_onclick = ieObj_EventManager(52, ieObj_HTMLImg52, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell52_onclick() As Boolean
  ieObj_HTMLTableCell52_onclick = ieObj_EventManager(52, ieObj_HTMLTableCell52, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement52_onclick() As Boolean
  ieObj_HTMLDivElement52_onclick = ieObj_EventManager(52, ieObj_HTMLDivElement52, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement53_onclick() As Boolean
  ieObj_HTMLInputElement53_onclick = ieObj_EventManager(53, ieObj_HTMLInputElement53, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement53_onclick() As Boolean
  ieObj_HTMLSelectElement53_onclick = ieObj_EventManager(53, ieObj_HTMLSelectElement53, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement53_onclick() As Boolean
  ieObj_HTMLButtonElement53_onclick = ieObj_EventManager(53, ieObj_HTMLButtonElement53, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement53_onclick() As Boolean
  ieObj_HTMLAnchorElement53_onclick = ieObj_EventManager(53, ieObj_HTMLAnchorElement53, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement53_onclick() As Boolean
  ieObj_HTMLTextAreaElement53_onclick = ieObj_EventManager(53, ieObj_HTMLTextAreaElement53, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg53_onclick() As Boolean
  ieObj_HTMLImg53_onclick = ieObj_EventManager(53, ieObj_HTMLImg53, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell53_onclick() As Boolean
  ieObj_HTMLTableCell53_onclick = ieObj_EventManager(53, ieObj_HTMLTableCell53, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement53_onclick() As Boolean
  ieObj_HTMLDivElement53_onclick = ieObj_EventManager(53, ieObj_HTMLDivElement53, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement54_onclick() As Boolean
  ieObj_HTMLInputElement54_onclick = ieObj_EventManager(54, ieObj_HTMLInputElement54, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement54_onclick() As Boolean
  ieObj_HTMLSelectElement54_onclick = ieObj_EventManager(54, ieObj_HTMLSelectElement54, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement54_onclick() As Boolean
  ieObj_HTMLButtonElement54_onclick = ieObj_EventManager(54, ieObj_HTMLButtonElement54, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement54_onclick() As Boolean
  ieObj_HTMLAnchorElement54_onclick = ieObj_EventManager(54, ieObj_HTMLAnchorElement54, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement54_onclick() As Boolean
  ieObj_HTMLTextAreaElement54_onclick = ieObj_EventManager(54, ieObj_HTMLTextAreaElement54, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg54_onclick() As Boolean
  ieObj_HTMLImg54_onclick = ieObj_EventManager(54, ieObj_HTMLImg54, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell54_onclick() As Boolean
  ieObj_HTMLTableCell54_onclick = ieObj_EventManager(54, ieObj_HTMLTableCell54, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement54_onclick() As Boolean
  ieObj_HTMLDivElement54_onclick = ieObj_EventManager(54, ieObj_HTMLDivElement54, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement55_onclick() As Boolean
  ieObj_HTMLInputElement55_onclick = ieObj_EventManager(55, ieObj_HTMLInputElement55, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement55_onclick() As Boolean
  ieObj_HTMLSelectElement55_onclick = ieObj_EventManager(55, ieObj_HTMLSelectElement55, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement55_onclick() As Boolean
  ieObj_HTMLButtonElement55_onclick = ieObj_EventManager(55, ieObj_HTMLButtonElement55, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement55_onclick() As Boolean
  ieObj_HTMLAnchorElement55_onclick = ieObj_EventManager(55, ieObj_HTMLAnchorElement55, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement55_onclick() As Boolean
  ieObj_HTMLTextAreaElement55_onclick = ieObj_EventManager(55, ieObj_HTMLTextAreaElement55, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg55_onclick() As Boolean
  ieObj_HTMLImg55_onclick = ieObj_EventManager(55, ieObj_HTMLImg55, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell55_onclick() As Boolean
  ieObj_HTMLTableCell55_onclick = ieObj_EventManager(55, ieObj_HTMLTableCell55, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement55_onclick() As Boolean
  ieObj_HTMLDivElement55_onclick = ieObj_EventManager(55, ieObj_HTMLDivElement55, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement56_onclick() As Boolean
  ieObj_HTMLInputElement56_onclick = ieObj_EventManager(56, ieObj_HTMLInputElement56, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement56_onclick() As Boolean
  ieObj_HTMLSelectElement56_onclick = ieObj_EventManager(56, ieObj_HTMLSelectElement56, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement56_onclick() As Boolean
  ieObj_HTMLButtonElement56_onclick = ieObj_EventManager(56, ieObj_HTMLButtonElement56, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement56_onclick() As Boolean
  ieObj_HTMLAnchorElement56_onclick = ieObj_EventManager(56, ieObj_HTMLAnchorElement56, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement56_onclick() As Boolean
  ieObj_HTMLTextAreaElement56_onclick = ieObj_EventManager(56, ieObj_HTMLTextAreaElement56, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg56_onclick() As Boolean
  ieObj_HTMLImg56_onclick = ieObj_EventManager(56, ieObj_HTMLImg56, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell56_onclick() As Boolean
  ieObj_HTMLTableCell56_onclick = ieObj_EventManager(56, ieObj_HTMLTableCell56, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement56_onclick() As Boolean
  ieObj_HTMLDivElement56_onclick = ieObj_EventManager(56, ieObj_HTMLDivElement56, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement57_onclick() As Boolean
  ieObj_HTMLInputElement57_onclick = ieObj_EventManager(57, ieObj_HTMLInputElement57, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement57_onclick() As Boolean
  ieObj_HTMLSelectElement57_onclick = ieObj_EventManager(57, ieObj_HTMLSelectElement57, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement57_onclick() As Boolean
  ieObj_HTMLButtonElement57_onclick = ieObj_EventManager(57, ieObj_HTMLButtonElement57, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement57_onclick() As Boolean
  ieObj_HTMLAnchorElement57_onclick = ieObj_EventManager(57, ieObj_HTMLAnchorElement57, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement57_onclick() As Boolean
  ieObj_HTMLTextAreaElement57_onclick = ieObj_EventManager(57, ieObj_HTMLTextAreaElement57, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg57_onclick() As Boolean
  ieObj_HTMLImg57_onclick = ieObj_EventManager(57, ieObj_HTMLImg57, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell57_onclick() As Boolean
  ieObj_HTMLTableCell57_onclick = ieObj_EventManager(57, ieObj_HTMLTableCell57, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement57_onclick() As Boolean
  ieObj_HTMLDivElement57_onclick = ieObj_EventManager(57, ieObj_HTMLDivElement57, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement58_onclick() As Boolean
  ieObj_HTMLInputElement58_onclick = ieObj_EventManager(58, ieObj_HTMLInputElement58, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement58_onclick() As Boolean
  ieObj_HTMLSelectElement58_onclick = ieObj_EventManager(58, ieObj_HTMLSelectElement58, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement58_onclick() As Boolean
  ieObj_HTMLButtonElement58_onclick = ieObj_EventManager(58, ieObj_HTMLButtonElement58, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement58_onclick() As Boolean
  ieObj_HTMLAnchorElement58_onclick = ieObj_EventManager(58, ieObj_HTMLAnchorElement58, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement58_onclick() As Boolean
  ieObj_HTMLTextAreaElement58_onclick = ieObj_EventManager(58, ieObj_HTMLTextAreaElement58, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg58_onclick() As Boolean
  ieObj_HTMLImg58_onclick = ieObj_EventManager(58, ieObj_HTMLImg58, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell58_onclick() As Boolean
  ieObj_HTMLTableCell58_onclick = ieObj_EventManager(58, ieObj_HTMLTableCell58, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement58_onclick() As Boolean
  ieObj_HTMLDivElement58_onclick = ieObj_EventManager(58, ieObj_HTMLDivElement58, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement59_onclick() As Boolean
  ieObj_HTMLInputElement59_onclick = ieObj_EventManager(59, ieObj_HTMLInputElement59, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement59_onclick() As Boolean
  ieObj_HTMLSelectElement59_onclick = ieObj_EventManager(59, ieObj_HTMLSelectElement59, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement59_onclick() As Boolean
  ieObj_HTMLButtonElement59_onclick = ieObj_EventManager(59, ieObj_HTMLButtonElement59, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement59_onclick() As Boolean
  ieObj_HTMLAnchorElement59_onclick = ieObj_EventManager(59, ieObj_HTMLAnchorElement59, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement59_onclick() As Boolean
  ieObj_HTMLTextAreaElement59_onclick = ieObj_EventManager(59, ieObj_HTMLTextAreaElement59, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg59_onclick() As Boolean
  ieObj_HTMLImg59_onclick = ieObj_EventManager(59, ieObj_HTMLImg59, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell59_onclick() As Boolean
  ieObj_HTMLTableCell59_onclick = ieObj_EventManager(59, ieObj_HTMLTableCell59, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement59_onclick() As Boolean
  ieObj_HTMLDivElement59_onclick = ieObj_EventManager(59, ieObj_HTMLDivElement59, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement60_onclick() As Boolean
  ieObj_HTMLInputElement60_onclick = ieObj_EventManager(60, ieObj_HTMLInputElement60, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement60_onclick() As Boolean
  ieObj_HTMLSelectElement60_onclick = ieObj_EventManager(60, ieObj_HTMLSelectElement60, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement60_onclick() As Boolean
  ieObj_HTMLButtonElement60_onclick = ieObj_EventManager(60, ieObj_HTMLButtonElement60, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement60_onclick() As Boolean
  ieObj_HTMLAnchorElement60_onclick = ieObj_EventManager(60, ieObj_HTMLAnchorElement60, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement60_onclick() As Boolean
  ieObj_HTMLTextAreaElement60_onclick = ieObj_EventManager(60, ieObj_HTMLTextAreaElement60, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg60_onclick() As Boolean
  ieObj_HTMLImg60_onclick = ieObj_EventManager(60, ieObj_HTMLImg60, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell60_onclick() As Boolean
  ieObj_HTMLTableCell60_onclick = ieObj_EventManager(60, ieObj_HTMLTableCell60, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement60_onclick() As Boolean
  ieObj_HTMLDivElement60_onclick = ieObj_EventManager(60, ieObj_HTMLDivElement60, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement61_onclick() As Boolean
  ieObj_HTMLInputElement61_onclick = ieObj_EventManager(61, ieObj_HTMLInputElement61, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement61_onclick() As Boolean
  ieObj_HTMLSelectElement61_onclick = ieObj_EventManager(61, ieObj_HTMLSelectElement61, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement61_onclick() As Boolean
  ieObj_HTMLButtonElement61_onclick = ieObj_EventManager(61, ieObj_HTMLButtonElement61, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement61_onclick() As Boolean
  ieObj_HTMLAnchorElement61_onclick = ieObj_EventManager(61, ieObj_HTMLAnchorElement61, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement61_onclick() As Boolean
  ieObj_HTMLTextAreaElement61_onclick = ieObj_EventManager(61, ieObj_HTMLTextAreaElement61, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg61_onclick() As Boolean
  ieObj_HTMLImg61_onclick = ieObj_EventManager(61, ieObj_HTMLImg61, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell61_onclick() As Boolean
  ieObj_HTMLTableCell61_onclick = ieObj_EventManager(61, ieObj_HTMLTableCell61, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement61_onclick() As Boolean
  ieObj_HTMLDivElement61_onclick = ieObj_EventManager(61, ieObj_HTMLDivElement61, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement62_onclick() As Boolean
  ieObj_HTMLInputElement62_onclick = ieObj_EventManager(62, ieObj_HTMLInputElement62, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement62_onclick() As Boolean
  ieObj_HTMLSelectElement62_onclick = ieObj_EventManager(62, ieObj_HTMLSelectElement62, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement62_onclick() As Boolean
  ieObj_HTMLButtonElement62_onclick = ieObj_EventManager(62, ieObj_HTMLButtonElement62, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement62_onclick() As Boolean
  ieObj_HTMLAnchorElement62_onclick = ieObj_EventManager(62, ieObj_HTMLAnchorElement62, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement62_onclick() As Boolean
  ieObj_HTMLTextAreaElement62_onclick = ieObj_EventManager(62, ieObj_HTMLTextAreaElement62, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg62_onclick() As Boolean
  ieObj_HTMLImg62_onclick = ieObj_EventManager(62, ieObj_HTMLImg62, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell62_onclick() As Boolean
  ieObj_HTMLTableCell62_onclick = ieObj_EventManager(62, ieObj_HTMLTableCell62, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement62_onclick() As Boolean
  ieObj_HTMLDivElement62_onclick = ieObj_EventManager(62, ieObj_HTMLDivElement62, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement63_onclick() As Boolean
  ieObj_HTMLInputElement63_onclick = ieObj_EventManager(63, ieObj_HTMLInputElement63, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement63_onclick() As Boolean
  ieObj_HTMLSelectElement63_onclick = ieObj_EventManager(63, ieObj_HTMLSelectElement63, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement63_onclick() As Boolean
  ieObj_HTMLButtonElement63_onclick = ieObj_EventManager(63, ieObj_HTMLButtonElement63, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement63_onclick() As Boolean
  ieObj_HTMLAnchorElement63_onclick = ieObj_EventManager(63, ieObj_HTMLAnchorElement63, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement63_onclick() As Boolean
  ieObj_HTMLTextAreaElement63_onclick = ieObj_EventManager(63, ieObj_HTMLTextAreaElement63, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg63_onclick() As Boolean
  ieObj_HTMLImg63_onclick = ieObj_EventManager(63, ieObj_HTMLImg63, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell63_onclick() As Boolean
  ieObj_HTMLTableCell63_onclick = ieObj_EventManager(63, ieObj_HTMLTableCell63, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement63_onclick() As Boolean
  ieObj_HTMLDivElement63_onclick = ieObj_EventManager(63, ieObj_HTMLDivElement63, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement64_onclick() As Boolean
  ieObj_HTMLInputElement64_onclick = ieObj_EventManager(64, ieObj_HTMLInputElement64, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement64_onclick() As Boolean
  ieObj_HTMLSelectElement64_onclick = ieObj_EventManager(64, ieObj_HTMLSelectElement64, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement64_onclick() As Boolean
  ieObj_HTMLButtonElement64_onclick = ieObj_EventManager(64, ieObj_HTMLButtonElement64, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement64_onclick() As Boolean
  ieObj_HTMLAnchorElement64_onclick = ieObj_EventManager(64, ieObj_HTMLAnchorElement64, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement64_onclick() As Boolean
  ieObj_HTMLTextAreaElement64_onclick = ieObj_EventManager(64, ieObj_HTMLTextAreaElement64, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg64_onclick() As Boolean
  ieObj_HTMLImg64_onclick = ieObj_EventManager(64, ieObj_HTMLImg64, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell64_onclick() As Boolean
  ieObj_HTMLTableCell64_onclick = ieObj_EventManager(64, ieObj_HTMLTableCell64, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement64_onclick() As Boolean
  ieObj_HTMLDivElement64_onclick = ieObj_EventManager(64, ieObj_HTMLDivElement64, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement65_onclick() As Boolean
  ieObj_HTMLInputElement65_onclick = ieObj_EventManager(65, ieObj_HTMLInputElement65, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement65_onclick() As Boolean
  ieObj_HTMLSelectElement65_onclick = ieObj_EventManager(65, ieObj_HTMLSelectElement65, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement65_onclick() As Boolean
  ieObj_HTMLButtonElement65_onclick = ieObj_EventManager(65, ieObj_HTMLButtonElement65, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement65_onclick() As Boolean
  ieObj_HTMLAnchorElement65_onclick = ieObj_EventManager(65, ieObj_HTMLAnchorElement65, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement65_onclick() As Boolean
  ieObj_HTMLTextAreaElement65_onclick = ieObj_EventManager(65, ieObj_HTMLTextAreaElement65, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg65_onclick() As Boolean
  ieObj_HTMLImg65_onclick = ieObj_EventManager(65, ieObj_HTMLImg65, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell65_onclick() As Boolean
  ieObj_HTMLTableCell65_onclick = ieObj_EventManager(65, ieObj_HTMLTableCell65, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement65_onclick() As Boolean
  ieObj_HTMLDivElement65_onclick = ieObj_EventManager(65, ieObj_HTMLDivElement65, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement66_onclick() As Boolean
  ieObj_HTMLInputElement66_onclick = ieObj_EventManager(66, ieObj_HTMLInputElement66, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement66_onclick() As Boolean
  ieObj_HTMLSelectElement66_onclick = ieObj_EventManager(66, ieObj_HTMLSelectElement66, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement66_onclick() As Boolean
  ieObj_HTMLButtonElement66_onclick = ieObj_EventManager(66, ieObj_HTMLButtonElement66, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement66_onclick() As Boolean
  ieObj_HTMLAnchorElement66_onclick = ieObj_EventManager(66, ieObj_HTMLAnchorElement66, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement66_onclick() As Boolean
  ieObj_HTMLTextAreaElement66_onclick = ieObj_EventManager(66, ieObj_HTMLTextAreaElement66, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg66_onclick() As Boolean
  ieObj_HTMLImg66_onclick = ieObj_EventManager(66, ieObj_HTMLImg66, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell66_onclick() As Boolean
  ieObj_HTMLTableCell66_onclick = ieObj_EventManager(66, ieObj_HTMLTableCell66, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement66_onclick() As Boolean
  ieObj_HTMLDivElement66_onclick = ieObj_EventManager(66, ieObj_HTMLDivElement66, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement67_onclick() As Boolean
  ieObj_HTMLInputElement67_onclick = ieObj_EventManager(67, ieObj_HTMLInputElement67, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement67_onclick() As Boolean
  ieObj_HTMLSelectElement67_onclick = ieObj_EventManager(67, ieObj_HTMLSelectElement67, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement67_onclick() As Boolean
  ieObj_HTMLButtonElement67_onclick = ieObj_EventManager(67, ieObj_HTMLButtonElement67, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement67_onclick() As Boolean
  ieObj_HTMLAnchorElement67_onclick = ieObj_EventManager(67, ieObj_HTMLAnchorElement67, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement67_onclick() As Boolean
  ieObj_HTMLTextAreaElement67_onclick = ieObj_EventManager(67, ieObj_HTMLTextAreaElement67, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg67_onclick() As Boolean
  ieObj_HTMLImg67_onclick = ieObj_EventManager(67, ieObj_HTMLImg67, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell67_onclick() As Boolean
  ieObj_HTMLTableCell67_onclick = ieObj_EventManager(67, ieObj_HTMLTableCell67, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement67_onclick() As Boolean
  ieObj_HTMLDivElement67_onclick = ieObj_EventManager(67, ieObj_HTMLDivElement67, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement68_onclick() As Boolean
  ieObj_HTMLInputElement68_onclick = ieObj_EventManager(68, ieObj_HTMLInputElement68, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement68_onclick() As Boolean
  ieObj_HTMLSelectElement68_onclick = ieObj_EventManager(68, ieObj_HTMLSelectElement68, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement68_onclick() As Boolean
  ieObj_HTMLButtonElement68_onclick = ieObj_EventManager(68, ieObj_HTMLButtonElement68, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement68_onclick() As Boolean
  ieObj_HTMLAnchorElement68_onclick = ieObj_EventManager(68, ieObj_HTMLAnchorElement68, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement68_onclick() As Boolean
  ieObj_HTMLTextAreaElement68_onclick = ieObj_EventManager(68, ieObj_HTMLTextAreaElement68, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg68_onclick() As Boolean
  ieObj_HTMLImg68_onclick = ieObj_EventManager(68, ieObj_HTMLImg68, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell68_onclick() As Boolean
  ieObj_HTMLTableCell68_onclick = ieObj_EventManager(68, ieObj_HTMLTableCell68, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement68_onclick() As Boolean
  ieObj_HTMLDivElement68_onclick = ieObj_EventManager(68, ieObj_HTMLDivElement68, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement69_onclick() As Boolean
  ieObj_HTMLInputElement69_onclick = ieObj_EventManager(69, ieObj_HTMLInputElement69, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement69_onclick() As Boolean
  ieObj_HTMLSelectElement69_onclick = ieObj_EventManager(69, ieObj_HTMLSelectElement69, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement69_onclick() As Boolean
  ieObj_HTMLButtonElement69_onclick = ieObj_EventManager(69, ieObj_HTMLButtonElement69, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement69_onclick() As Boolean
  ieObj_HTMLAnchorElement69_onclick = ieObj_EventManager(69, ieObj_HTMLAnchorElement69, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement69_onclick() As Boolean
  ieObj_HTMLTextAreaElement69_onclick = ieObj_EventManager(69, ieObj_HTMLTextAreaElement69, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg69_onclick() As Boolean
  ieObj_HTMLImg69_onclick = ieObj_EventManager(69, ieObj_HTMLImg69, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell69_onclick() As Boolean
  ieObj_HTMLTableCell69_onclick = ieObj_EventManager(69, ieObj_HTMLTableCell69, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement69_onclick() As Boolean
  ieObj_HTMLDivElement69_onclick = ieObj_EventManager(69, ieObj_HTMLDivElement69, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement70_onclick() As Boolean
  ieObj_HTMLInputElement70_onclick = ieObj_EventManager(70, ieObj_HTMLInputElement70, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement70_onclick() As Boolean
  ieObj_HTMLSelectElement70_onclick = ieObj_EventManager(70, ieObj_HTMLSelectElement70, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement70_onclick() As Boolean
  ieObj_HTMLButtonElement70_onclick = ieObj_EventManager(70, ieObj_HTMLButtonElement70, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement70_onclick() As Boolean
  ieObj_HTMLAnchorElement70_onclick = ieObj_EventManager(70, ieObj_HTMLAnchorElement70, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement70_onclick() As Boolean
  ieObj_HTMLTextAreaElement70_onclick = ieObj_EventManager(70, ieObj_HTMLTextAreaElement70, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg70_onclick() As Boolean
  ieObj_HTMLImg70_onclick = ieObj_EventManager(70, ieObj_HTMLImg70, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell70_onclick() As Boolean
  ieObj_HTMLTableCell70_onclick = ieObj_EventManager(70, ieObj_HTMLTableCell70, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement70_onclick() As Boolean
  ieObj_HTMLDivElement70_onclick = ieObj_EventManager(70, ieObj_HTMLDivElement70, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement71_onclick() As Boolean
  ieObj_HTMLInputElement71_onclick = ieObj_EventManager(71, ieObj_HTMLInputElement71, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement71_onclick() As Boolean
  ieObj_HTMLSelectElement71_onclick = ieObj_EventManager(71, ieObj_HTMLSelectElement71, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement71_onclick() As Boolean
  ieObj_HTMLButtonElement71_onclick = ieObj_EventManager(71, ieObj_HTMLButtonElement71, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement71_onclick() As Boolean
  ieObj_HTMLAnchorElement71_onclick = ieObj_EventManager(71, ieObj_HTMLAnchorElement71, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement71_onclick() As Boolean
  ieObj_HTMLTextAreaElement71_onclick = ieObj_EventManager(71, ieObj_HTMLTextAreaElement71, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg71_onclick() As Boolean
  ieObj_HTMLImg71_onclick = ieObj_EventManager(71, ieObj_HTMLImg71, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell71_onclick() As Boolean
  ieObj_HTMLTableCell71_onclick = ieObj_EventManager(71, ieObj_HTMLTableCell71, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement71_onclick() As Boolean
  ieObj_HTMLDivElement71_onclick = ieObj_EventManager(71, ieObj_HTMLDivElement71, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement72_onclick() As Boolean
  ieObj_HTMLInputElement72_onclick = ieObj_EventManager(72, ieObj_HTMLInputElement72, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement72_onclick() As Boolean
  ieObj_HTMLSelectElement72_onclick = ieObj_EventManager(72, ieObj_HTMLSelectElement72, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement72_onclick() As Boolean
  ieObj_HTMLButtonElement72_onclick = ieObj_EventManager(72, ieObj_HTMLButtonElement72, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement72_onclick() As Boolean
  ieObj_HTMLAnchorElement72_onclick = ieObj_EventManager(72, ieObj_HTMLAnchorElement72, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement72_onclick() As Boolean
  ieObj_HTMLTextAreaElement72_onclick = ieObj_EventManager(72, ieObj_HTMLTextAreaElement72, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg72_onclick() As Boolean
  ieObj_HTMLImg72_onclick = ieObj_EventManager(72, ieObj_HTMLImg72, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell72_onclick() As Boolean
  ieObj_HTMLTableCell72_onclick = ieObj_EventManager(72, ieObj_HTMLTableCell72, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement72_onclick() As Boolean
  ieObj_HTMLDivElement72_onclick = ieObj_EventManager(72, ieObj_HTMLDivElement72, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement73_onclick() As Boolean
  ieObj_HTMLInputElement73_onclick = ieObj_EventManager(73, ieObj_HTMLInputElement73, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement73_onclick() As Boolean
  ieObj_HTMLSelectElement73_onclick = ieObj_EventManager(73, ieObj_HTMLSelectElement73, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement73_onclick() As Boolean
  ieObj_HTMLButtonElement73_onclick = ieObj_EventManager(73, ieObj_HTMLButtonElement73, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement73_onclick() As Boolean
  ieObj_HTMLAnchorElement73_onclick = ieObj_EventManager(73, ieObj_HTMLAnchorElement73, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement73_onclick() As Boolean
  ieObj_HTMLTextAreaElement73_onclick = ieObj_EventManager(73, ieObj_HTMLTextAreaElement73, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg73_onclick() As Boolean
  ieObj_HTMLImg73_onclick = ieObj_EventManager(73, ieObj_HTMLImg73, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell73_onclick() As Boolean
  ieObj_HTMLTableCell73_onclick = ieObj_EventManager(73, ieObj_HTMLTableCell73, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement73_onclick() As Boolean
  ieObj_HTMLDivElement73_onclick = ieObj_EventManager(73, ieObj_HTMLDivElement73, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement74_onclick() As Boolean
  ieObj_HTMLInputElement74_onclick = ieObj_EventManager(74, ieObj_HTMLInputElement74, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement74_onclick() As Boolean
  ieObj_HTMLSelectElement74_onclick = ieObj_EventManager(74, ieObj_HTMLSelectElement74, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement74_onclick() As Boolean
  ieObj_HTMLButtonElement74_onclick = ieObj_EventManager(74, ieObj_HTMLButtonElement74, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement74_onclick() As Boolean
  ieObj_HTMLAnchorElement74_onclick = ieObj_EventManager(74, ieObj_HTMLAnchorElement74, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement74_onclick() As Boolean
  ieObj_HTMLTextAreaElement74_onclick = ieObj_EventManager(74, ieObj_HTMLTextAreaElement74, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg74_onclick() As Boolean
  ieObj_HTMLImg74_onclick = ieObj_EventManager(74, ieObj_HTMLImg74, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell74_onclick() As Boolean
  ieObj_HTMLTableCell74_onclick = ieObj_EventManager(74, ieObj_HTMLTableCell74, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement74_onclick() As Boolean
  ieObj_HTMLDivElement74_onclick = ieObj_EventManager(74, ieObj_HTMLDivElement74, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement75_onclick() As Boolean
  ieObj_HTMLInputElement75_onclick = ieObj_EventManager(75, ieObj_HTMLInputElement75, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement75_onclick() As Boolean
  ieObj_HTMLSelectElement75_onclick = ieObj_EventManager(75, ieObj_HTMLSelectElement75, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement75_onclick() As Boolean
  ieObj_HTMLButtonElement75_onclick = ieObj_EventManager(75, ieObj_HTMLButtonElement75, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement75_onclick() As Boolean
  ieObj_HTMLAnchorElement75_onclick = ieObj_EventManager(75, ieObj_HTMLAnchorElement75, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement75_onclick() As Boolean
  ieObj_HTMLTextAreaElement75_onclick = ieObj_EventManager(75, ieObj_HTMLTextAreaElement75, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg75_onclick() As Boolean
  ieObj_HTMLImg75_onclick = ieObj_EventManager(75, ieObj_HTMLImg75, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell75_onclick() As Boolean
  ieObj_HTMLTableCell75_onclick = ieObj_EventManager(75, ieObj_HTMLTableCell75, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement75_onclick() As Boolean
  ieObj_HTMLDivElement75_onclick = ieObj_EventManager(75, ieObj_HTMLDivElement75, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement76_onclick() As Boolean
  ieObj_HTMLInputElement76_onclick = ieObj_EventManager(76, ieObj_HTMLInputElement76, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement76_onclick() As Boolean
  ieObj_HTMLSelectElement76_onclick = ieObj_EventManager(76, ieObj_HTMLSelectElement76, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement76_onclick() As Boolean
  ieObj_HTMLButtonElement76_onclick = ieObj_EventManager(76, ieObj_HTMLButtonElement76, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement76_onclick() As Boolean
  ieObj_HTMLAnchorElement76_onclick = ieObj_EventManager(76, ieObj_HTMLAnchorElement76, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement76_onclick() As Boolean
  ieObj_HTMLTextAreaElement76_onclick = ieObj_EventManager(76, ieObj_HTMLTextAreaElement76, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg76_onclick() As Boolean
  ieObj_HTMLImg76_onclick = ieObj_EventManager(76, ieObj_HTMLImg76, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell76_onclick() As Boolean
  ieObj_HTMLTableCell76_onclick = ieObj_EventManager(76, ieObj_HTMLTableCell76, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement76_onclick() As Boolean
  ieObj_HTMLDivElement76_onclick = ieObj_EventManager(76, ieObj_HTMLDivElement76, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement77_onclick() As Boolean
  ieObj_HTMLInputElement77_onclick = ieObj_EventManager(77, ieObj_HTMLInputElement77, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement77_onclick() As Boolean
  ieObj_HTMLSelectElement77_onclick = ieObj_EventManager(77, ieObj_HTMLSelectElement77, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement77_onclick() As Boolean
  ieObj_HTMLButtonElement77_onclick = ieObj_EventManager(77, ieObj_HTMLButtonElement77, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement77_onclick() As Boolean
  ieObj_HTMLAnchorElement77_onclick = ieObj_EventManager(77, ieObj_HTMLAnchorElement77, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement77_onclick() As Boolean
  ieObj_HTMLTextAreaElement77_onclick = ieObj_EventManager(77, ieObj_HTMLTextAreaElement77, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg77_onclick() As Boolean
  ieObj_HTMLImg77_onclick = ieObj_EventManager(77, ieObj_HTMLImg77, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell77_onclick() As Boolean
  ieObj_HTMLTableCell77_onclick = ieObj_EventManager(77, ieObj_HTMLTableCell77, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement77_onclick() As Boolean
  ieObj_HTMLDivElement77_onclick = ieObj_EventManager(77, ieObj_HTMLDivElement77, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement78_onclick() As Boolean
  ieObj_HTMLInputElement78_onclick = ieObj_EventManager(78, ieObj_HTMLInputElement78, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement78_onclick() As Boolean
  ieObj_HTMLSelectElement78_onclick = ieObj_EventManager(78, ieObj_HTMLSelectElement78, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement78_onclick() As Boolean
  ieObj_HTMLButtonElement78_onclick = ieObj_EventManager(78, ieObj_HTMLButtonElement78, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement78_onclick() As Boolean
  ieObj_HTMLAnchorElement78_onclick = ieObj_EventManager(78, ieObj_HTMLAnchorElement78, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement78_onclick() As Boolean
  ieObj_HTMLTextAreaElement78_onclick = ieObj_EventManager(78, ieObj_HTMLTextAreaElement78, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg78_onclick() As Boolean
  ieObj_HTMLImg78_onclick = ieObj_EventManager(78, ieObj_HTMLImg78, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell78_onclick() As Boolean
  ieObj_HTMLTableCell78_onclick = ieObj_EventManager(78, ieObj_HTMLTableCell78, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement78_onclick() As Boolean
  ieObj_HTMLDivElement78_onclick = ieObj_EventManager(78, ieObj_HTMLDivElement78, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement79_onclick() As Boolean
  ieObj_HTMLInputElement79_onclick = ieObj_EventManager(79, ieObj_HTMLInputElement79, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement79_onclick() As Boolean
  ieObj_HTMLSelectElement79_onclick = ieObj_EventManager(79, ieObj_HTMLSelectElement79, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement79_onclick() As Boolean
  ieObj_HTMLButtonElement79_onclick = ieObj_EventManager(79, ieObj_HTMLButtonElement79, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement79_onclick() As Boolean
  ieObj_HTMLAnchorElement79_onclick = ieObj_EventManager(79, ieObj_HTMLAnchorElement79, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement79_onclick() As Boolean
  ieObj_HTMLTextAreaElement79_onclick = ieObj_EventManager(79, ieObj_HTMLTextAreaElement79, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg79_onclick() As Boolean
  ieObj_HTMLImg79_onclick = ieObj_EventManager(79, ieObj_HTMLImg79, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell79_onclick() As Boolean
  ieObj_HTMLTableCell79_onclick = ieObj_EventManager(79, ieObj_HTMLTableCell79, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement79_onclick() As Boolean
  ieObj_HTMLDivElement79_onclick = ieObj_EventManager(79, ieObj_HTMLDivElement79, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement80_onclick() As Boolean
  ieObj_HTMLInputElement80_onclick = ieObj_EventManager(80, ieObj_HTMLInputElement80, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement80_onclick() As Boolean
  ieObj_HTMLSelectElement80_onclick = ieObj_EventManager(80, ieObj_HTMLSelectElement80, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement80_onclick() As Boolean
  ieObj_HTMLButtonElement80_onclick = ieObj_EventManager(80, ieObj_HTMLButtonElement80, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement80_onclick() As Boolean
  ieObj_HTMLAnchorElement80_onclick = ieObj_EventManager(80, ieObj_HTMLAnchorElement80, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement80_onclick() As Boolean
  ieObj_HTMLTextAreaElement80_onclick = ieObj_EventManager(80, ieObj_HTMLTextAreaElement80, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg80_onclick() As Boolean
  ieObj_HTMLImg80_onclick = ieObj_EventManager(80, ieObj_HTMLImg80, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell80_onclick() As Boolean
  ieObj_HTMLTableCell80_onclick = ieObj_EventManager(80, ieObj_HTMLTableCell80, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement80_onclick() As Boolean
  ieObj_HTMLDivElement80_onclick = ieObj_EventManager(80, ieObj_HTMLDivElement80, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement81_onclick() As Boolean
  ieObj_HTMLInputElement81_onclick = ieObj_EventManager(81, ieObj_HTMLInputElement81, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement81_onclick() As Boolean
  ieObj_HTMLSelectElement81_onclick = ieObj_EventManager(81, ieObj_HTMLSelectElement81, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement81_onclick() As Boolean
  ieObj_HTMLButtonElement81_onclick = ieObj_EventManager(81, ieObj_HTMLButtonElement81, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement81_onclick() As Boolean
  ieObj_HTMLAnchorElement81_onclick = ieObj_EventManager(81, ieObj_HTMLAnchorElement81, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement81_onclick() As Boolean
  ieObj_HTMLTextAreaElement81_onclick = ieObj_EventManager(81, ieObj_HTMLTextAreaElement81, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg81_onclick() As Boolean
  ieObj_HTMLImg81_onclick = ieObj_EventManager(81, ieObj_HTMLImg81, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell81_onclick() As Boolean
  ieObj_HTMLTableCell81_onclick = ieObj_EventManager(81, ieObj_HTMLTableCell81, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement81_onclick() As Boolean
  ieObj_HTMLDivElement81_onclick = ieObj_EventManager(81, ieObj_HTMLDivElement81, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement82_onclick() As Boolean
  ieObj_HTMLInputElement82_onclick = ieObj_EventManager(82, ieObj_HTMLInputElement82, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement82_onclick() As Boolean
  ieObj_HTMLSelectElement82_onclick = ieObj_EventManager(82, ieObj_HTMLSelectElement82, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement82_onclick() As Boolean
  ieObj_HTMLButtonElement82_onclick = ieObj_EventManager(82, ieObj_HTMLButtonElement82, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement82_onclick() As Boolean
  ieObj_HTMLAnchorElement82_onclick = ieObj_EventManager(82, ieObj_HTMLAnchorElement82, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement82_onclick() As Boolean
  ieObj_HTMLTextAreaElement82_onclick = ieObj_EventManager(82, ieObj_HTMLTextAreaElement82, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg82_onclick() As Boolean
  ieObj_HTMLImg82_onclick = ieObj_EventManager(82, ieObj_HTMLImg82, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell82_onclick() As Boolean
  ieObj_HTMLTableCell82_onclick = ieObj_EventManager(82, ieObj_HTMLTableCell82, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement82_onclick() As Boolean
  ieObj_HTMLDivElement82_onclick = ieObj_EventManager(82, ieObj_HTMLDivElement82, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement83_onclick() As Boolean
  ieObj_HTMLInputElement83_onclick = ieObj_EventManager(83, ieObj_HTMLInputElement83, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement83_onclick() As Boolean
  ieObj_HTMLSelectElement83_onclick = ieObj_EventManager(83, ieObj_HTMLSelectElement83, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement83_onclick() As Boolean
  ieObj_HTMLButtonElement83_onclick = ieObj_EventManager(83, ieObj_HTMLButtonElement83, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement83_onclick() As Boolean
  ieObj_HTMLAnchorElement83_onclick = ieObj_EventManager(83, ieObj_HTMLAnchorElement83, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement83_onclick() As Boolean
  ieObj_HTMLTextAreaElement83_onclick = ieObj_EventManager(83, ieObj_HTMLTextAreaElement83, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg83_onclick() As Boolean
  ieObj_HTMLImg83_onclick = ieObj_EventManager(83, ieObj_HTMLImg83, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell83_onclick() As Boolean
  ieObj_HTMLTableCell83_onclick = ieObj_EventManager(83, ieObj_HTMLTableCell83, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement83_onclick() As Boolean
  ieObj_HTMLDivElement83_onclick = ieObj_EventManager(83, ieObj_HTMLDivElement83, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement84_onclick() As Boolean
  ieObj_HTMLInputElement84_onclick = ieObj_EventManager(84, ieObj_HTMLInputElement84, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement84_onclick() As Boolean
  ieObj_HTMLSelectElement84_onclick = ieObj_EventManager(84, ieObj_HTMLSelectElement84, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement84_onclick() As Boolean
  ieObj_HTMLButtonElement84_onclick = ieObj_EventManager(84, ieObj_HTMLButtonElement84, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement84_onclick() As Boolean
  ieObj_HTMLAnchorElement84_onclick = ieObj_EventManager(84, ieObj_HTMLAnchorElement84, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement84_onclick() As Boolean
  ieObj_HTMLTextAreaElement84_onclick = ieObj_EventManager(84, ieObj_HTMLTextAreaElement84, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg84_onclick() As Boolean
  ieObj_HTMLImg84_onclick = ieObj_EventManager(84, ieObj_HTMLImg84, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell84_onclick() As Boolean
  ieObj_HTMLTableCell84_onclick = ieObj_EventManager(84, ieObj_HTMLTableCell84, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement84_onclick() As Boolean
  ieObj_HTMLDivElement84_onclick = ieObj_EventManager(84, ieObj_HTMLDivElement84, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement85_onclick() As Boolean
  ieObj_HTMLInputElement85_onclick = ieObj_EventManager(85, ieObj_HTMLInputElement85, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement85_onclick() As Boolean
  ieObj_HTMLSelectElement85_onclick = ieObj_EventManager(85, ieObj_HTMLSelectElement85, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement85_onclick() As Boolean
  ieObj_HTMLButtonElement85_onclick = ieObj_EventManager(85, ieObj_HTMLButtonElement85, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement85_onclick() As Boolean
  ieObj_HTMLAnchorElement85_onclick = ieObj_EventManager(85, ieObj_HTMLAnchorElement85, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement85_onclick() As Boolean
  ieObj_HTMLTextAreaElement85_onclick = ieObj_EventManager(85, ieObj_HTMLTextAreaElement85, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg85_onclick() As Boolean
  ieObj_HTMLImg85_onclick = ieObj_EventManager(85, ieObj_HTMLImg85, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell85_onclick() As Boolean
  ieObj_HTMLTableCell85_onclick = ieObj_EventManager(85, ieObj_HTMLTableCell85, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement85_onclick() As Boolean
  ieObj_HTMLDivElement85_onclick = ieObj_EventManager(85, ieObj_HTMLDivElement85, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement86_onclick() As Boolean
  ieObj_HTMLInputElement86_onclick = ieObj_EventManager(86, ieObj_HTMLInputElement86, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement86_onclick() As Boolean
  ieObj_HTMLSelectElement86_onclick = ieObj_EventManager(86, ieObj_HTMLSelectElement86, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement86_onclick() As Boolean
  ieObj_HTMLButtonElement86_onclick = ieObj_EventManager(86, ieObj_HTMLButtonElement86, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement86_onclick() As Boolean
  ieObj_HTMLAnchorElement86_onclick = ieObj_EventManager(86, ieObj_HTMLAnchorElement86, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement86_onclick() As Boolean
  ieObj_HTMLTextAreaElement86_onclick = ieObj_EventManager(86, ieObj_HTMLTextAreaElement86, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg86_onclick() As Boolean
  ieObj_HTMLImg86_onclick = ieObj_EventManager(86, ieObj_HTMLImg86, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell86_onclick() As Boolean
  ieObj_HTMLTableCell86_onclick = ieObj_EventManager(86, ieObj_HTMLTableCell86, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement86_onclick() As Boolean
  ieObj_HTMLDivElement86_onclick = ieObj_EventManager(86, ieObj_HTMLDivElement86, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement87_onclick() As Boolean
  ieObj_HTMLInputElement87_onclick = ieObj_EventManager(87, ieObj_HTMLInputElement87, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement87_onclick() As Boolean
  ieObj_HTMLSelectElement87_onclick = ieObj_EventManager(87, ieObj_HTMLSelectElement87, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement87_onclick() As Boolean
  ieObj_HTMLButtonElement87_onclick = ieObj_EventManager(87, ieObj_HTMLButtonElement87, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement87_onclick() As Boolean
  ieObj_HTMLAnchorElement87_onclick = ieObj_EventManager(87, ieObj_HTMLAnchorElement87, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement87_onclick() As Boolean
  ieObj_HTMLTextAreaElement87_onclick = ieObj_EventManager(87, ieObj_HTMLTextAreaElement87, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg87_onclick() As Boolean
  ieObj_HTMLImg87_onclick = ieObj_EventManager(87, ieObj_HTMLImg87, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell87_onclick() As Boolean
  ieObj_HTMLTableCell87_onclick = ieObj_EventManager(87, ieObj_HTMLTableCell87, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement87_onclick() As Boolean
  ieObj_HTMLDivElement87_onclick = ieObj_EventManager(87, ieObj_HTMLDivElement87, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement88_onclick() As Boolean
  ieObj_HTMLInputElement88_onclick = ieObj_EventManager(88, ieObj_HTMLInputElement88, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement88_onclick() As Boolean
  ieObj_HTMLSelectElement88_onclick = ieObj_EventManager(88, ieObj_HTMLSelectElement88, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement88_onclick() As Boolean
  ieObj_HTMLButtonElement88_onclick = ieObj_EventManager(88, ieObj_HTMLButtonElement88, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement88_onclick() As Boolean
  ieObj_HTMLAnchorElement88_onclick = ieObj_EventManager(88, ieObj_HTMLAnchorElement88, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement88_onclick() As Boolean
  ieObj_HTMLTextAreaElement88_onclick = ieObj_EventManager(88, ieObj_HTMLTextAreaElement88, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg88_onclick() As Boolean
  ieObj_HTMLImg88_onclick = ieObj_EventManager(88, ieObj_HTMLImg88, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell88_onclick() As Boolean
  ieObj_HTMLTableCell88_onclick = ieObj_EventManager(88, ieObj_HTMLTableCell88, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement88_onclick() As Boolean
  ieObj_HTMLDivElement88_onclick = ieObj_EventManager(88, ieObj_HTMLDivElement88, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement89_onclick() As Boolean
  ieObj_HTMLInputElement89_onclick = ieObj_EventManager(89, ieObj_HTMLInputElement89, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement89_onclick() As Boolean
  ieObj_HTMLSelectElement89_onclick = ieObj_EventManager(89, ieObj_HTMLSelectElement89, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement89_onclick() As Boolean
  ieObj_HTMLButtonElement89_onclick = ieObj_EventManager(89, ieObj_HTMLButtonElement89, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement89_onclick() As Boolean
  ieObj_HTMLAnchorElement89_onclick = ieObj_EventManager(89, ieObj_HTMLAnchorElement89, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement89_onclick() As Boolean
  ieObj_HTMLTextAreaElement89_onclick = ieObj_EventManager(89, ieObj_HTMLTextAreaElement89, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg89_onclick() As Boolean
  ieObj_HTMLImg89_onclick = ieObj_EventManager(89, ieObj_HTMLImg89, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell89_onclick() As Boolean
  ieObj_HTMLTableCell89_onclick = ieObj_EventManager(89, ieObj_HTMLTableCell89, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement89_onclick() As Boolean
  ieObj_HTMLDivElement89_onclick = ieObj_EventManager(89, ieObj_HTMLDivElement89, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement90_onclick() As Boolean
  ieObj_HTMLInputElement90_onclick = ieObj_EventManager(90, ieObj_HTMLInputElement90, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement90_onclick() As Boolean
  ieObj_HTMLSelectElement90_onclick = ieObj_EventManager(90, ieObj_HTMLSelectElement90, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement90_onclick() As Boolean
  ieObj_HTMLButtonElement90_onclick = ieObj_EventManager(90, ieObj_HTMLButtonElement90, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement90_onclick() As Boolean
  ieObj_HTMLAnchorElement90_onclick = ieObj_EventManager(90, ieObj_HTMLAnchorElement90, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement90_onclick() As Boolean
  ieObj_HTMLTextAreaElement90_onclick = ieObj_EventManager(90, ieObj_HTMLTextAreaElement90, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg90_onclick() As Boolean
  ieObj_HTMLImg90_onclick = ieObj_EventManager(90, ieObj_HTMLImg90, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell90_onclick() As Boolean
  ieObj_HTMLTableCell90_onclick = ieObj_EventManager(90, ieObj_HTMLTableCell90, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement90_onclick() As Boolean
  ieObj_HTMLDivElement90_onclick = ieObj_EventManager(90, ieObj_HTMLDivElement90, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement91_onclick() As Boolean
  ieObj_HTMLInputElement91_onclick = ieObj_EventManager(91, ieObj_HTMLInputElement91, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement91_onclick() As Boolean
  ieObj_HTMLSelectElement91_onclick = ieObj_EventManager(91, ieObj_HTMLSelectElement91, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement91_onclick() As Boolean
  ieObj_HTMLButtonElement91_onclick = ieObj_EventManager(91, ieObj_HTMLButtonElement91, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement91_onclick() As Boolean
  ieObj_HTMLAnchorElement91_onclick = ieObj_EventManager(91, ieObj_HTMLAnchorElement91, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement91_onclick() As Boolean
  ieObj_HTMLTextAreaElement91_onclick = ieObj_EventManager(91, ieObj_HTMLTextAreaElement91, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg91_onclick() As Boolean
  ieObj_HTMLImg91_onclick = ieObj_EventManager(91, ieObj_HTMLImg91, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell91_onclick() As Boolean
  ieObj_HTMLTableCell91_onclick = ieObj_EventManager(91, ieObj_HTMLTableCell91, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement91_onclick() As Boolean
  ieObj_HTMLDivElement91_onclick = ieObj_EventManager(91, ieObj_HTMLDivElement91, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement92_onclick() As Boolean
  ieObj_HTMLInputElement92_onclick = ieObj_EventManager(92, ieObj_HTMLInputElement92, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement92_onclick() As Boolean
  ieObj_HTMLSelectElement92_onclick = ieObj_EventManager(92, ieObj_HTMLSelectElement92, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement92_onclick() As Boolean
  ieObj_HTMLButtonElement92_onclick = ieObj_EventManager(92, ieObj_HTMLButtonElement92, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement92_onclick() As Boolean
  ieObj_HTMLAnchorElement92_onclick = ieObj_EventManager(92, ieObj_HTMLAnchorElement92, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement92_onclick() As Boolean
  ieObj_HTMLTextAreaElement92_onclick = ieObj_EventManager(92, ieObj_HTMLTextAreaElement92, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg92_onclick() As Boolean
  ieObj_HTMLImg92_onclick = ieObj_EventManager(92, ieObj_HTMLImg92, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell92_onclick() As Boolean
  ieObj_HTMLTableCell92_onclick = ieObj_EventManager(92, ieObj_HTMLTableCell92, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement92_onclick() As Boolean
  ieObj_HTMLDivElement92_onclick = ieObj_EventManager(92, ieObj_HTMLDivElement92, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement93_onclick() As Boolean
  ieObj_HTMLInputElement93_onclick = ieObj_EventManager(93, ieObj_HTMLInputElement93, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement93_onclick() As Boolean
  ieObj_HTMLSelectElement93_onclick = ieObj_EventManager(93, ieObj_HTMLSelectElement93, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement93_onclick() As Boolean
  ieObj_HTMLButtonElement93_onclick = ieObj_EventManager(93, ieObj_HTMLButtonElement93, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement93_onclick() As Boolean
  ieObj_HTMLAnchorElement93_onclick = ieObj_EventManager(93, ieObj_HTMLAnchorElement93, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement93_onclick() As Boolean
  ieObj_HTMLTextAreaElement93_onclick = ieObj_EventManager(93, ieObj_HTMLTextAreaElement93, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg93_onclick() As Boolean
  ieObj_HTMLImg93_onclick = ieObj_EventManager(93, ieObj_HTMLImg93, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell93_onclick() As Boolean
  ieObj_HTMLTableCell93_onclick = ieObj_EventManager(93, ieObj_HTMLTableCell93, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement93_onclick() As Boolean
  ieObj_HTMLDivElement93_onclick = ieObj_EventManager(93, ieObj_HTMLDivElement93, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement94_onclick() As Boolean
  ieObj_HTMLInputElement94_onclick = ieObj_EventManager(94, ieObj_HTMLInputElement94, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement94_onclick() As Boolean
  ieObj_HTMLSelectElement94_onclick = ieObj_EventManager(94, ieObj_HTMLSelectElement94, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement94_onclick() As Boolean
  ieObj_HTMLButtonElement94_onclick = ieObj_EventManager(94, ieObj_HTMLButtonElement94, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement94_onclick() As Boolean
  ieObj_HTMLAnchorElement94_onclick = ieObj_EventManager(94, ieObj_HTMLAnchorElement94, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement94_onclick() As Boolean
  ieObj_HTMLTextAreaElement94_onclick = ieObj_EventManager(94, ieObj_HTMLTextAreaElement94, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg94_onclick() As Boolean
  ieObj_HTMLImg94_onclick = ieObj_EventManager(94, ieObj_HTMLImg94, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell94_onclick() As Boolean
  ieObj_HTMLTableCell94_onclick = ieObj_EventManager(94, ieObj_HTMLTableCell94, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement94_onclick() As Boolean
  ieObj_HTMLDivElement94_onclick = ieObj_EventManager(94, ieObj_HTMLDivElement94, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement95_onclick() As Boolean
  ieObj_HTMLInputElement95_onclick = ieObj_EventManager(95, ieObj_HTMLInputElement95, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement95_onclick() As Boolean
  ieObj_HTMLSelectElement95_onclick = ieObj_EventManager(95, ieObj_HTMLSelectElement95, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement95_onclick() As Boolean
  ieObj_HTMLButtonElement95_onclick = ieObj_EventManager(95, ieObj_HTMLButtonElement95, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement95_onclick() As Boolean
  ieObj_HTMLAnchorElement95_onclick = ieObj_EventManager(95, ieObj_HTMLAnchorElement95, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement95_onclick() As Boolean
  ieObj_HTMLTextAreaElement95_onclick = ieObj_EventManager(95, ieObj_HTMLTextAreaElement95, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg95_onclick() As Boolean
  ieObj_HTMLImg95_onclick = ieObj_EventManager(95, ieObj_HTMLImg95, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell95_onclick() As Boolean
  ieObj_HTMLTableCell95_onclick = ieObj_EventManager(95, ieObj_HTMLTableCell95, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement95_onclick() As Boolean
  ieObj_HTMLDivElement95_onclick = ieObj_EventManager(95, ieObj_HTMLDivElement95, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement96_onclick() As Boolean
  ieObj_HTMLInputElement96_onclick = ieObj_EventManager(96, ieObj_HTMLInputElement96, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement96_onclick() As Boolean
  ieObj_HTMLSelectElement96_onclick = ieObj_EventManager(96, ieObj_HTMLSelectElement96, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement96_onclick() As Boolean
  ieObj_HTMLButtonElement96_onclick = ieObj_EventManager(96, ieObj_HTMLButtonElement96, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement96_onclick() As Boolean
  ieObj_HTMLAnchorElement96_onclick = ieObj_EventManager(96, ieObj_HTMLAnchorElement96, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement96_onclick() As Boolean
  ieObj_HTMLTextAreaElement96_onclick = ieObj_EventManager(96, ieObj_HTMLTextAreaElement96, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg96_onclick() As Boolean
  ieObj_HTMLImg96_onclick = ieObj_EventManager(96, ieObj_HTMLImg96, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell96_onclick() As Boolean
  ieObj_HTMLTableCell96_onclick = ieObj_EventManager(96, ieObj_HTMLTableCell96, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement96_onclick() As Boolean
  ieObj_HTMLDivElement96_onclick = ieObj_EventManager(96, ieObj_HTMLDivElement96, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement97_onclick() As Boolean
  ieObj_HTMLInputElement97_onclick = ieObj_EventManager(97, ieObj_HTMLInputElement97, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement97_onclick() As Boolean
  ieObj_HTMLSelectElement97_onclick = ieObj_EventManager(97, ieObj_HTMLSelectElement97, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement97_onclick() As Boolean
  ieObj_HTMLButtonElement97_onclick = ieObj_EventManager(97, ieObj_HTMLButtonElement97, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement97_onclick() As Boolean
  ieObj_HTMLAnchorElement97_onclick = ieObj_EventManager(97, ieObj_HTMLAnchorElement97, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement97_onclick() As Boolean
  ieObj_HTMLTextAreaElement97_onclick = ieObj_EventManager(97, ieObj_HTMLTextAreaElement97, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg97_onclick() As Boolean
  ieObj_HTMLImg97_onclick = ieObj_EventManager(97, ieObj_HTMLImg97, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell97_onclick() As Boolean
  ieObj_HTMLTableCell97_onclick = ieObj_EventManager(97, ieObj_HTMLTableCell97, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement97_onclick() As Boolean
  ieObj_HTMLDivElement97_onclick = ieObj_EventManager(97, ieObj_HTMLDivElement97, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement98_onclick() As Boolean
  ieObj_HTMLInputElement98_onclick = ieObj_EventManager(98, ieObj_HTMLInputElement98, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement98_onclick() As Boolean
  ieObj_HTMLSelectElement98_onclick = ieObj_EventManager(98, ieObj_HTMLSelectElement98, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement98_onclick() As Boolean
  ieObj_HTMLButtonElement98_onclick = ieObj_EventManager(98, ieObj_HTMLButtonElement98, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement98_onclick() As Boolean
  ieObj_HTMLAnchorElement98_onclick = ieObj_EventManager(98, ieObj_HTMLAnchorElement98, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement98_onclick() As Boolean
  ieObj_HTMLTextAreaElement98_onclick = ieObj_EventManager(98, ieObj_HTMLTextAreaElement98, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg98_onclick() As Boolean
  ieObj_HTMLImg98_onclick = ieObj_EventManager(98, ieObj_HTMLImg98, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell98_onclick() As Boolean
  ieObj_HTMLTableCell98_onclick = ieObj_EventManager(98, ieObj_HTMLTableCell98, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement98_onclick() As Boolean
  ieObj_HTMLDivElement98_onclick = ieObj_EventManager(98, ieObj_HTMLDivElement98, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement99_onclick() As Boolean
  ieObj_HTMLInputElement99_onclick = ieObj_EventManager(99, ieObj_HTMLInputElement99, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement99_onclick() As Boolean
  ieObj_HTMLSelectElement99_onclick = ieObj_EventManager(99, ieObj_HTMLSelectElement99, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement99_onclick() As Boolean
  ieObj_HTMLButtonElement99_onclick = ieObj_EventManager(99, ieObj_HTMLButtonElement99, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement99_onclick() As Boolean
  ieObj_HTMLAnchorElement99_onclick = ieObj_EventManager(99, ieObj_HTMLAnchorElement99, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement99_onclick() As Boolean
  ieObj_HTMLTextAreaElement99_onclick = ieObj_EventManager(99, ieObj_HTMLTextAreaElement99, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg99_onclick() As Boolean
  ieObj_HTMLImg99_onclick = ieObj_EventManager(99, ieObj_HTMLImg99, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell99_onclick() As Boolean
  ieObj_HTMLTableCell99_onclick = ieObj_EventManager(99, ieObj_HTMLTableCell99, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement99_onclick() As Boolean
  ieObj_HTMLDivElement99_onclick = ieObj_EventManager(99, ieObj_HTMLDivElement99, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement100_onclick() As Boolean
  ieObj_HTMLInputElement100_onclick = ieObj_EventManager(100, ieObj_HTMLInputElement100, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement100_onclick() As Boolean
  ieObj_HTMLSelectElement100_onclick = ieObj_EventManager(100, ieObj_HTMLSelectElement100, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement100_onclick() As Boolean
  ieObj_HTMLButtonElement100_onclick = ieObj_EventManager(100, ieObj_HTMLButtonElement100, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement100_onclick() As Boolean
  ieObj_HTMLAnchorElement100_onclick = ieObj_EventManager(100, ieObj_HTMLAnchorElement100, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement100_onclick() As Boolean
  ieObj_HTMLTextAreaElement100_onclick = ieObj_EventManager(100, ieObj_HTMLTextAreaElement100, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg100_onclick() As Boolean
  ieObj_HTMLImg100_onclick = ieObj_EventManager(100, ieObj_HTMLImg100, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell100_onclick() As Boolean
  ieObj_HTMLTableCell100_onclick = ieObj_EventManager(100, ieObj_HTMLTableCell100, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement100_onclick() As Boolean
  ieObj_HTMLDivElement100_onclick = ieObj_EventManager(100, ieObj_HTMLDivElement100, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement101_onclick() As Boolean
  ieObj_HTMLInputElement101_onclick = ieObj_EventManager(101, ieObj_HTMLInputElement101, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement101_onclick() As Boolean
  ieObj_HTMLSelectElement101_onclick = ieObj_EventManager(101, ieObj_HTMLSelectElement101, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement101_onclick() As Boolean
  ieObj_HTMLButtonElement101_onclick = ieObj_EventManager(101, ieObj_HTMLButtonElement101, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement101_onclick() As Boolean
  ieObj_HTMLAnchorElement101_onclick = ieObj_EventManager(101, ieObj_HTMLAnchorElement101, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement101_onclick() As Boolean
  ieObj_HTMLTextAreaElement101_onclick = ieObj_EventManager(101, ieObj_HTMLTextAreaElement101, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg101_onclick() As Boolean
  ieObj_HTMLImg101_onclick = ieObj_EventManager(101, ieObj_HTMLImg101, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell101_onclick() As Boolean
  ieObj_HTMLTableCell101_onclick = ieObj_EventManager(101, ieObj_HTMLTableCell101, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement101_onclick() As Boolean
  ieObj_HTMLDivElement101_onclick = ieObj_EventManager(101, ieObj_HTMLDivElement101, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement102_onclick() As Boolean
  ieObj_HTMLInputElement102_onclick = ieObj_EventManager(102, ieObj_HTMLInputElement102, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement102_onclick() As Boolean
  ieObj_HTMLSelectElement102_onclick = ieObj_EventManager(102, ieObj_HTMLSelectElement102, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement102_onclick() As Boolean
  ieObj_HTMLButtonElement102_onclick = ieObj_EventManager(102, ieObj_HTMLButtonElement102, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement102_onclick() As Boolean
  ieObj_HTMLAnchorElement102_onclick = ieObj_EventManager(102, ieObj_HTMLAnchorElement102, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement102_onclick() As Boolean
  ieObj_HTMLTextAreaElement102_onclick = ieObj_EventManager(102, ieObj_HTMLTextAreaElement102, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg102_onclick() As Boolean
  ieObj_HTMLImg102_onclick = ieObj_EventManager(102, ieObj_HTMLImg102, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell102_onclick() As Boolean
  ieObj_HTMLTableCell102_onclick = ieObj_EventManager(102, ieObj_HTMLTableCell102, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement102_onclick() As Boolean
  ieObj_HTMLDivElement102_onclick = ieObj_EventManager(102, ieObj_HTMLDivElement102, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement103_onclick() As Boolean
  ieObj_HTMLInputElement103_onclick = ieObj_EventManager(103, ieObj_HTMLInputElement103, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement103_onclick() As Boolean
  ieObj_HTMLSelectElement103_onclick = ieObj_EventManager(103, ieObj_HTMLSelectElement103, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement103_onclick() As Boolean
  ieObj_HTMLButtonElement103_onclick = ieObj_EventManager(103, ieObj_HTMLButtonElement103, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement103_onclick() As Boolean
  ieObj_HTMLAnchorElement103_onclick = ieObj_EventManager(103, ieObj_HTMLAnchorElement103, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement103_onclick() As Boolean
  ieObj_HTMLTextAreaElement103_onclick = ieObj_EventManager(103, ieObj_HTMLTextAreaElement103, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg103_onclick() As Boolean
  ieObj_HTMLImg103_onclick = ieObj_EventManager(103, ieObj_HTMLImg103, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell103_onclick() As Boolean
  ieObj_HTMLTableCell103_onclick = ieObj_EventManager(103, ieObj_HTMLTableCell103, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement103_onclick() As Boolean
  ieObj_HTMLDivElement103_onclick = ieObj_EventManager(103, ieObj_HTMLDivElement103, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement104_onclick() As Boolean
  ieObj_HTMLInputElement104_onclick = ieObj_EventManager(104, ieObj_HTMLInputElement104, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement104_onclick() As Boolean
  ieObj_HTMLSelectElement104_onclick = ieObj_EventManager(104, ieObj_HTMLSelectElement104, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement104_onclick() As Boolean
  ieObj_HTMLButtonElement104_onclick = ieObj_EventManager(104, ieObj_HTMLButtonElement104, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement104_onclick() As Boolean
  ieObj_HTMLAnchorElement104_onclick = ieObj_EventManager(104, ieObj_HTMLAnchorElement104, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement104_onclick() As Boolean
  ieObj_HTMLTextAreaElement104_onclick = ieObj_EventManager(104, ieObj_HTMLTextAreaElement104, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg104_onclick() As Boolean
  ieObj_HTMLImg104_onclick = ieObj_EventManager(104, ieObj_HTMLImg104, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell104_onclick() As Boolean
  ieObj_HTMLTableCell104_onclick = ieObj_EventManager(104, ieObj_HTMLTableCell104, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement104_onclick() As Boolean
  ieObj_HTMLDivElement104_onclick = ieObj_EventManager(104, ieObj_HTMLDivElement104, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement105_onclick() As Boolean
  ieObj_HTMLInputElement105_onclick = ieObj_EventManager(105, ieObj_HTMLInputElement105, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement105_onclick() As Boolean
  ieObj_HTMLSelectElement105_onclick = ieObj_EventManager(105, ieObj_HTMLSelectElement105, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement105_onclick() As Boolean
  ieObj_HTMLButtonElement105_onclick = ieObj_EventManager(105, ieObj_HTMLButtonElement105, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement105_onclick() As Boolean
  ieObj_HTMLAnchorElement105_onclick = ieObj_EventManager(105, ieObj_HTMLAnchorElement105, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement105_onclick() As Boolean
  ieObj_HTMLTextAreaElement105_onclick = ieObj_EventManager(105, ieObj_HTMLTextAreaElement105, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg105_onclick() As Boolean
  ieObj_HTMLImg105_onclick = ieObj_EventManager(105, ieObj_HTMLImg105, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell105_onclick() As Boolean
  ieObj_HTMLTableCell105_onclick = ieObj_EventManager(105, ieObj_HTMLTableCell105, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement105_onclick() As Boolean
  ieObj_HTMLDivElement105_onclick = ieObj_EventManager(105, ieObj_HTMLDivElement105, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement106_onclick() As Boolean
  ieObj_HTMLInputElement106_onclick = ieObj_EventManager(106, ieObj_HTMLInputElement106, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement106_onclick() As Boolean
  ieObj_HTMLSelectElement106_onclick = ieObj_EventManager(106, ieObj_HTMLSelectElement106, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement106_onclick() As Boolean
  ieObj_HTMLButtonElement106_onclick = ieObj_EventManager(106, ieObj_HTMLButtonElement106, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement106_onclick() As Boolean
  ieObj_HTMLAnchorElement106_onclick = ieObj_EventManager(106, ieObj_HTMLAnchorElement106, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement106_onclick() As Boolean
  ieObj_HTMLTextAreaElement106_onclick = ieObj_EventManager(106, ieObj_HTMLTextAreaElement106, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg106_onclick() As Boolean
  ieObj_HTMLImg106_onclick = ieObj_EventManager(106, ieObj_HTMLImg106, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell106_onclick() As Boolean
  ieObj_HTMLTableCell106_onclick = ieObj_EventManager(106, ieObj_HTMLTableCell106, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement106_onclick() As Boolean
  ieObj_HTMLDivElement106_onclick = ieObj_EventManager(106, ieObj_HTMLDivElement106, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement107_onclick() As Boolean
  ieObj_HTMLInputElement107_onclick = ieObj_EventManager(107, ieObj_HTMLInputElement107, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement107_onclick() As Boolean
  ieObj_HTMLSelectElement107_onclick = ieObj_EventManager(107, ieObj_HTMLSelectElement107, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement107_onclick() As Boolean
  ieObj_HTMLButtonElement107_onclick = ieObj_EventManager(107, ieObj_HTMLButtonElement107, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement107_onclick() As Boolean
  ieObj_HTMLAnchorElement107_onclick = ieObj_EventManager(107, ieObj_HTMLAnchorElement107, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement107_onclick() As Boolean
  ieObj_HTMLTextAreaElement107_onclick = ieObj_EventManager(107, ieObj_HTMLTextAreaElement107, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg107_onclick() As Boolean
  ieObj_HTMLImg107_onclick = ieObj_EventManager(107, ieObj_HTMLImg107, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell107_onclick() As Boolean
  ieObj_HTMLTableCell107_onclick = ieObj_EventManager(107, ieObj_HTMLTableCell107, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement107_onclick() As Boolean
  ieObj_HTMLDivElement107_onclick = ieObj_EventManager(107, ieObj_HTMLDivElement107, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement108_onclick() As Boolean
  ieObj_HTMLInputElement108_onclick = ieObj_EventManager(108, ieObj_HTMLInputElement108, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement108_onclick() As Boolean
  ieObj_HTMLSelectElement108_onclick = ieObj_EventManager(108, ieObj_HTMLSelectElement108, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement108_onclick() As Boolean
  ieObj_HTMLButtonElement108_onclick = ieObj_EventManager(108, ieObj_HTMLButtonElement108, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement108_onclick() As Boolean
  ieObj_HTMLAnchorElement108_onclick = ieObj_EventManager(108, ieObj_HTMLAnchorElement108, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement108_onclick() As Boolean
  ieObj_HTMLTextAreaElement108_onclick = ieObj_EventManager(108, ieObj_HTMLTextAreaElement108, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg108_onclick() As Boolean
  ieObj_HTMLImg108_onclick = ieObj_EventManager(108, ieObj_HTMLImg108, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell108_onclick() As Boolean
  ieObj_HTMLTableCell108_onclick = ieObj_EventManager(108, ieObj_HTMLTableCell108, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement108_onclick() As Boolean
  ieObj_HTMLDivElement108_onclick = ieObj_EventManager(108, ieObj_HTMLDivElement108, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement109_onclick() As Boolean
  ieObj_HTMLInputElement109_onclick = ieObj_EventManager(109, ieObj_HTMLInputElement109, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement109_onclick() As Boolean
  ieObj_HTMLSelectElement109_onclick = ieObj_EventManager(109, ieObj_HTMLSelectElement109, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement109_onclick() As Boolean
  ieObj_HTMLButtonElement109_onclick = ieObj_EventManager(109, ieObj_HTMLButtonElement109, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement109_onclick() As Boolean
  ieObj_HTMLAnchorElement109_onclick = ieObj_EventManager(109, ieObj_HTMLAnchorElement109, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement109_onclick() As Boolean
  ieObj_HTMLTextAreaElement109_onclick = ieObj_EventManager(109, ieObj_HTMLTextAreaElement109, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg109_onclick() As Boolean
  ieObj_HTMLImg109_onclick = ieObj_EventManager(109, ieObj_HTMLImg109, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell109_onclick() As Boolean
  ieObj_HTMLTableCell109_onclick = ieObj_EventManager(109, ieObj_HTMLTableCell109, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement109_onclick() As Boolean
  ieObj_HTMLDivElement109_onclick = ieObj_EventManager(109, ieObj_HTMLDivElement109, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement110_onclick() As Boolean
  ieObj_HTMLInputElement110_onclick = ieObj_EventManager(110, ieObj_HTMLInputElement110, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement110_onclick() As Boolean
  ieObj_HTMLSelectElement110_onclick = ieObj_EventManager(110, ieObj_HTMLSelectElement110, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement110_onclick() As Boolean
  ieObj_HTMLButtonElement110_onclick = ieObj_EventManager(110, ieObj_HTMLButtonElement110, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement110_onclick() As Boolean
  ieObj_HTMLAnchorElement110_onclick = ieObj_EventManager(110, ieObj_HTMLAnchorElement110, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement110_onclick() As Boolean
  ieObj_HTMLTextAreaElement110_onclick = ieObj_EventManager(110, ieObj_HTMLTextAreaElement110, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg110_onclick() As Boolean
  ieObj_HTMLImg110_onclick = ieObj_EventManager(110, ieObj_HTMLImg110, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell110_onclick() As Boolean
  ieObj_HTMLTableCell110_onclick = ieObj_EventManager(110, ieObj_HTMLTableCell110, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement110_onclick() As Boolean
  ieObj_HTMLDivElement110_onclick = ieObj_EventManager(110, ieObj_HTMLDivElement110, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement111_onclick() As Boolean
  ieObj_HTMLInputElement111_onclick = ieObj_EventManager(111, ieObj_HTMLInputElement111, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement111_onclick() As Boolean
  ieObj_HTMLSelectElement111_onclick = ieObj_EventManager(111, ieObj_HTMLSelectElement111, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement111_onclick() As Boolean
  ieObj_HTMLButtonElement111_onclick = ieObj_EventManager(111, ieObj_HTMLButtonElement111, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement111_onclick() As Boolean
  ieObj_HTMLAnchorElement111_onclick = ieObj_EventManager(111, ieObj_HTMLAnchorElement111, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement111_onclick() As Boolean
  ieObj_HTMLTextAreaElement111_onclick = ieObj_EventManager(111, ieObj_HTMLTextAreaElement111, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg111_onclick() As Boolean
  ieObj_HTMLImg111_onclick = ieObj_EventManager(111, ieObj_HTMLImg111, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell111_onclick() As Boolean
  ieObj_HTMLTableCell111_onclick = ieObj_EventManager(111, ieObj_HTMLTableCell111, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement111_onclick() As Boolean
  ieObj_HTMLDivElement111_onclick = ieObj_EventManager(111, ieObj_HTMLDivElement111, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement112_onclick() As Boolean
  ieObj_HTMLInputElement112_onclick = ieObj_EventManager(112, ieObj_HTMLInputElement112, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement112_onclick() As Boolean
  ieObj_HTMLSelectElement112_onclick = ieObj_EventManager(112, ieObj_HTMLSelectElement112, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement112_onclick() As Boolean
  ieObj_HTMLButtonElement112_onclick = ieObj_EventManager(112, ieObj_HTMLButtonElement112, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement112_onclick() As Boolean
  ieObj_HTMLAnchorElement112_onclick = ieObj_EventManager(112, ieObj_HTMLAnchorElement112, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement112_onclick() As Boolean
  ieObj_HTMLTextAreaElement112_onclick = ieObj_EventManager(112, ieObj_HTMLTextAreaElement112, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg112_onclick() As Boolean
  ieObj_HTMLImg112_onclick = ieObj_EventManager(112, ieObj_HTMLImg112, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell112_onclick() As Boolean
  ieObj_HTMLTableCell112_onclick = ieObj_EventManager(112, ieObj_HTMLTableCell112, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement112_onclick() As Boolean
  ieObj_HTMLDivElement112_onclick = ieObj_EventManager(112, ieObj_HTMLDivElement112, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement113_onclick() As Boolean
  ieObj_HTMLInputElement113_onclick = ieObj_EventManager(113, ieObj_HTMLInputElement113, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement113_onclick() As Boolean
  ieObj_HTMLSelectElement113_onclick = ieObj_EventManager(113, ieObj_HTMLSelectElement113, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement113_onclick() As Boolean
  ieObj_HTMLButtonElement113_onclick = ieObj_EventManager(113, ieObj_HTMLButtonElement113, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement113_onclick() As Boolean
  ieObj_HTMLAnchorElement113_onclick = ieObj_EventManager(113, ieObj_HTMLAnchorElement113, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement113_onclick() As Boolean
  ieObj_HTMLTextAreaElement113_onclick = ieObj_EventManager(113, ieObj_HTMLTextAreaElement113, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg113_onclick() As Boolean
  ieObj_HTMLImg113_onclick = ieObj_EventManager(113, ieObj_HTMLImg113, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell113_onclick() As Boolean
  ieObj_HTMLTableCell113_onclick = ieObj_EventManager(113, ieObj_HTMLTableCell113, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement113_onclick() As Boolean
  ieObj_HTMLDivElement113_onclick = ieObj_EventManager(113, ieObj_HTMLDivElement113, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement114_onclick() As Boolean
  ieObj_HTMLInputElement114_onclick = ieObj_EventManager(114, ieObj_HTMLInputElement114, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement114_onclick() As Boolean
  ieObj_HTMLSelectElement114_onclick = ieObj_EventManager(114, ieObj_HTMLSelectElement114, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement114_onclick() As Boolean
  ieObj_HTMLButtonElement114_onclick = ieObj_EventManager(114, ieObj_HTMLButtonElement114, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement114_onclick() As Boolean
  ieObj_HTMLAnchorElement114_onclick = ieObj_EventManager(114, ieObj_HTMLAnchorElement114, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement114_onclick() As Boolean
  ieObj_HTMLTextAreaElement114_onclick = ieObj_EventManager(114, ieObj_HTMLTextAreaElement114, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg114_onclick() As Boolean
  ieObj_HTMLImg114_onclick = ieObj_EventManager(114, ieObj_HTMLImg114, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell114_onclick() As Boolean
  ieObj_HTMLTableCell114_onclick = ieObj_EventManager(114, ieObj_HTMLTableCell114, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement114_onclick() As Boolean
  ieObj_HTMLDivElement114_onclick = ieObj_EventManager(114, ieObj_HTMLDivElement114, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement115_onclick() As Boolean
  ieObj_HTMLInputElement115_onclick = ieObj_EventManager(115, ieObj_HTMLInputElement115, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement115_onclick() As Boolean
  ieObj_HTMLSelectElement115_onclick = ieObj_EventManager(115, ieObj_HTMLSelectElement115, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement115_onclick() As Boolean
  ieObj_HTMLButtonElement115_onclick = ieObj_EventManager(115, ieObj_HTMLButtonElement115, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement115_onclick() As Boolean
  ieObj_HTMLAnchorElement115_onclick = ieObj_EventManager(115, ieObj_HTMLAnchorElement115, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement115_onclick() As Boolean
  ieObj_HTMLTextAreaElement115_onclick = ieObj_EventManager(115, ieObj_HTMLTextAreaElement115, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg115_onclick() As Boolean
  ieObj_HTMLImg115_onclick = ieObj_EventManager(115, ieObj_HTMLImg115, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell115_onclick() As Boolean
  ieObj_HTMLTableCell115_onclick = ieObj_EventManager(115, ieObj_HTMLTableCell115, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement115_onclick() As Boolean
  ieObj_HTMLDivElement115_onclick = ieObj_EventManager(115, ieObj_HTMLDivElement115, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement116_onclick() As Boolean
  ieObj_HTMLInputElement116_onclick = ieObj_EventManager(116, ieObj_HTMLInputElement116, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement116_onclick() As Boolean
  ieObj_HTMLSelectElement116_onclick = ieObj_EventManager(116, ieObj_HTMLSelectElement116, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement116_onclick() As Boolean
  ieObj_HTMLButtonElement116_onclick = ieObj_EventManager(116, ieObj_HTMLButtonElement116, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement116_onclick() As Boolean
  ieObj_HTMLAnchorElement116_onclick = ieObj_EventManager(116, ieObj_HTMLAnchorElement116, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement116_onclick() As Boolean
  ieObj_HTMLTextAreaElement116_onclick = ieObj_EventManager(116, ieObj_HTMLTextAreaElement116, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg116_onclick() As Boolean
  ieObj_HTMLImg116_onclick = ieObj_EventManager(116, ieObj_HTMLImg116, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell116_onclick() As Boolean
  ieObj_HTMLTableCell116_onclick = ieObj_EventManager(116, ieObj_HTMLTableCell116, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement116_onclick() As Boolean
  ieObj_HTMLDivElement116_onclick = ieObj_EventManager(116, ieObj_HTMLDivElement116, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement117_onclick() As Boolean
  ieObj_HTMLInputElement117_onclick = ieObj_EventManager(117, ieObj_HTMLInputElement117, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement117_onclick() As Boolean
  ieObj_HTMLSelectElement117_onclick = ieObj_EventManager(117, ieObj_HTMLSelectElement117, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement117_onclick() As Boolean
  ieObj_HTMLButtonElement117_onclick = ieObj_EventManager(117, ieObj_HTMLButtonElement117, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement117_onclick() As Boolean
  ieObj_HTMLAnchorElement117_onclick = ieObj_EventManager(117, ieObj_HTMLAnchorElement117, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement117_onclick() As Boolean
  ieObj_HTMLTextAreaElement117_onclick = ieObj_EventManager(117, ieObj_HTMLTextAreaElement117, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg117_onclick() As Boolean
  ieObj_HTMLImg117_onclick = ieObj_EventManager(117, ieObj_HTMLImg117, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell117_onclick() As Boolean
  ieObj_HTMLTableCell117_onclick = ieObj_EventManager(117, ieObj_HTMLTableCell117, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement117_onclick() As Boolean
  ieObj_HTMLDivElement117_onclick = ieObj_EventManager(117, ieObj_HTMLDivElement117, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement118_onclick() As Boolean
  ieObj_HTMLInputElement118_onclick = ieObj_EventManager(118, ieObj_HTMLInputElement118, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement118_onclick() As Boolean
  ieObj_HTMLSelectElement118_onclick = ieObj_EventManager(118, ieObj_HTMLSelectElement118, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement118_onclick() As Boolean
  ieObj_HTMLButtonElement118_onclick = ieObj_EventManager(118, ieObj_HTMLButtonElement118, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement118_onclick() As Boolean
  ieObj_HTMLAnchorElement118_onclick = ieObj_EventManager(118, ieObj_HTMLAnchorElement118, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement118_onclick() As Boolean
  ieObj_HTMLTextAreaElement118_onclick = ieObj_EventManager(118, ieObj_HTMLTextAreaElement118, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg118_onclick() As Boolean
  ieObj_HTMLImg118_onclick = ieObj_EventManager(118, ieObj_HTMLImg118, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell118_onclick() As Boolean
  ieObj_HTMLTableCell118_onclick = ieObj_EventManager(118, ieObj_HTMLTableCell118, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement118_onclick() As Boolean
  ieObj_HTMLDivElement118_onclick = ieObj_EventManager(118, ieObj_HTMLDivElement118, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement119_onclick() As Boolean
  ieObj_HTMLInputElement119_onclick = ieObj_EventManager(119, ieObj_HTMLInputElement119, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement119_onclick() As Boolean
  ieObj_HTMLSelectElement119_onclick = ieObj_EventManager(119, ieObj_HTMLSelectElement119, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement119_onclick() As Boolean
  ieObj_HTMLButtonElement119_onclick = ieObj_EventManager(119, ieObj_HTMLButtonElement119, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement119_onclick() As Boolean
  ieObj_HTMLAnchorElement119_onclick = ieObj_EventManager(119, ieObj_HTMLAnchorElement119, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement119_onclick() As Boolean
  ieObj_HTMLTextAreaElement119_onclick = ieObj_EventManager(119, ieObj_HTMLTextAreaElement119, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg119_onclick() As Boolean
  ieObj_HTMLImg119_onclick = ieObj_EventManager(119, ieObj_HTMLImg119, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell119_onclick() As Boolean
  ieObj_HTMLTableCell119_onclick = ieObj_EventManager(119, ieObj_HTMLTableCell119, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement119_onclick() As Boolean
  ieObj_HTMLDivElement119_onclick = ieObj_EventManager(119, ieObj_HTMLDivElement119, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement120_onclick() As Boolean
  ieObj_HTMLInputElement120_onclick = ieObj_EventManager(120, ieObj_HTMLInputElement120, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement120_onclick() As Boolean
  ieObj_HTMLSelectElement120_onclick = ieObj_EventManager(120, ieObj_HTMLSelectElement120, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement120_onclick() As Boolean
  ieObj_HTMLButtonElement120_onclick = ieObj_EventManager(120, ieObj_HTMLButtonElement120, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement120_onclick() As Boolean
  ieObj_HTMLAnchorElement120_onclick = ieObj_EventManager(120, ieObj_HTMLAnchorElement120, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement120_onclick() As Boolean
  ieObj_HTMLTextAreaElement120_onclick = ieObj_EventManager(120, ieObj_HTMLTextAreaElement120, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg120_onclick() As Boolean
  ieObj_HTMLImg120_onclick = ieObj_EventManager(120, ieObj_HTMLImg120, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell120_onclick() As Boolean
  ieObj_HTMLTableCell120_onclick = ieObj_EventManager(120, ieObj_HTMLTableCell120, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement120_onclick() As Boolean
  ieObj_HTMLDivElement120_onclick = ieObj_EventManager(120, ieObj_HTMLDivElement120, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement121_onclick() As Boolean
  ieObj_HTMLInputElement121_onclick = ieObj_EventManager(121, ieObj_HTMLInputElement121, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement121_onclick() As Boolean
  ieObj_HTMLSelectElement121_onclick = ieObj_EventManager(121, ieObj_HTMLSelectElement121, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement121_onclick() As Boolean
  ieObj_HTMLButtonElement121_onclick = ieObj_EventManager(121, ieObj_HTMLButtonElement121, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement121_onclick() As Boolean
  ieObj_HTMLAnchorElement121_onclick = ieObj_EventManager(121, ieObj_HTMLAnchorElement121, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement121_onclick() As Boolean
  ieObj_HTMLTextAreaElement121_onclick = ieObj_EventManager(121, ieObj_HTMLTextAreaElement121, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg121_onclick() As Boolean
  ieObj_HTMLImg121_onclick = ieObj_EventManager(121, ieObj_HTMLImg121, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell121_onclick() As Boolean
  ieObj_HTMLTableCell121_onclick = ieObj_EventManager(121, ieObj_HTMLTableCell121, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement121_onclick() As Boolean
  ieObj_HTMLDivElement121_onclick = ieObj_EventManager(121, ieObj_HTMLDivElement121, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement122_onclick() As Boolean
  ieObj_HTMLInputElement122_onclick = ieObj_EventManager(122, ieObj_HTMLInputElement122, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement122_onclick() As Boolean
  ieObj_HTMLSelectElement122_onclick = ieObj_EventManager(122, ieObj_HTMLSelectElement122, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement122_onclick() As Boolean
  ieObj_HTMLButtonElement122_onclick = ieObj_EventManager(122, ieObj_HTMLButtonElement122, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement122_onclick() As Boolean
  ieObj_HTMLAnchorElement122_onclick = ieObj_EventManager(122, ieObj_HTMLAnchorElement122, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement122_onclick() As Boolean
  ieObj_HTMLTextAreaElement122_onclick = ieObj_EventManager(122, ieObj_HTMLTextAreaElement122, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg122_onclick() As Boolean
  ieObj_HTMLImg122_onclick = ieObj_EventManager(122, ieObj_HTMLImg122, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell122_onclick() As Boolean
  ieObj_HTMLTableCell122_onclick = ieObj_EventManager(122, ieObj_HTMLTableCell122, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement122_onclick() As Boolean
  ieObj_HTMLDivElement122_onclick = ieObj_EventManager(122, ieObj_HTMLDivElement122, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement123_onclick() As Boolean
  ieObj_HTMLInputElement123_onclick = ieObj_EventManager(123, ieObj_HTMLInputElement123, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement123_onclick() As Boolean
  ieObj_HTMLSelectElement123_onclick = ieObj_EventManager(123, ieObj_HTMLSelectElement123, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement123_onclick() As Boolean
  ieObj_HTMLButtonElement123_onclick = ieObj_EventManager(123, ieObj_HTMLButtonElement123, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement123_onclick() As Boolean
  ieObj_HTMLAnchorElement123_onclick = ieObj_EventManager(123, ieObj_HTMLAnchorElement123, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement123_onclick() As Boolean
  ieObj_HTMLTextAreaElement123_onclick = ieObj_EventManager(123, ieObj_HTMLTextAreaElement123, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg123_onclick() As Boolean
  ieObj_HTMLImg123_onclick = ieObj_EventManager(123, ieObj_HTMLImg123, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell123_onclick() As Boolean
  ieObj_HTMLTableCell123_onclick = ieObj_EventManager(123, ieObj_HTMLTableCell123, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement123_onclick() As Boolean
  ieObj_HTMLDivElement123_onclick = ieObj_EventManager(123, ieObj_HTMLDivElement123, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement124_onclick() As Boolean
  ieObj_HTMLInputElement124_onclick = ieObj_EventManager(124, ieObj_HTMLInputElement124, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement124_onclick() As Boolean
  ieObj_HTMLSelectElement124_onclick = ieObj_EventManager(124, ieObj_HTMLSelectElement124, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement124_onclick() As Boolean
  ieObj_HTMLButtonElement124_onclick = ieObj_EventManager(124, ieObj_HTMLButtonElement124, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement124_onclick() As Boolean
  ieObj_HTMLAnchorElement124_onclick = ieObj_EventManager(124, ieObj_HTMLAnchorElement124, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement124_onclick() As Boolean
  ieObj_HTMLTextAreaElement124_onclick = ieObj_EventManager(124, ieObj_HTMLTextAreaElement124, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg124_onclick() As Boolean
  ieObj_HTMLImg124_onclick = ieObj_EventManager(124, ieObj_HTMLImg124, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell124_onclick() As Boolean
  ieObj_HTMLTableCell124_onclick = ieObj_EventManager(124, ieObj_HTMLTableCell124, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement124_onclick() As Boolean
  ieObj_HTMLDivElement124_onclick = ieObj_EventManager(124, ieObj_HTMLDivElement124, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement125_onclick() As Boolean
  ieObj_HTMLInputElement125_onclick = ieObj_EventManager(125, ieObj_HTMLInputElement125, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement125_onclick() As Boolean
  ieObj_HTMLSelectElement125_onclick = ieObj_EventManager(125, ieObj_HTMLSelectElement125, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement125_onclick() As Boolean
  ieObj_HTMLButtonElement125_onclick = ieObj_EventManager(125, ieObj_HTMLButtonElement125, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement125_onclick() As Boolean
  ieObj_HTMLAnchorElement125_onclick = ieObj_EventManager(125, ieObj_HTMLAnchorElement125, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement125_onclick() As Boolean
  ieObj_HTMLTextAreaElement125_onclick = ieObj_EventManager(125, ieObj_HTMLTextAreaElement125, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg125_onclick() As Boolean
  ieObj_HTMLImg125_onclick = ieObj_EventManager(125, ieObj_HTMLImg125, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell125_onclick() As Boolean
  ieObj_HTMLTableCell125_onclick = ieObj_EventManager(125, ieObj_HTMLTableCell125, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement125_onclick() As Boolean
  ieObj_HTMLDivElement125_onclick = ieObj_EventManager(125, ieObj_HTMLDivElement125, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement126_onclick() As Boolean
  ieObj_HTMLInputElement126_onclick = ieObj_EventManager(126, ieObj_HTMLInputElement126, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement126_onclick() As Boolean
  ieObj_HTMLSelectElement126_onclick = ieObj_EventManager(126, ieObj_HTMLSelectElement126, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement126_onclick() As Boolean
  ieObj_HTMLButtonElement126_onclick = ieObj_EventManager(126, ieObj_HTMLButtonElement126, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement126_onclick() As Boolean
  ieObj_HTMLAnchorElement126_onclick = ieObj_EventManager(126, ieObj_HTMLAnchorElement126, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement126_onclick() As Boolean
  ieObj_HTMLTextAreaElement126_onclick = ieObj_EventManager(126, ieObj_HTMLTextAreaElement126, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg126_onclick() As Boolean
  ieObj_HTMLImg126_onclick = ieObj_EventManager(126, ieObj_HTMLImg126, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell126_onclick() As Boolean
  ieObj_HTMLTableCell126_onclick = ieObj_EventManager(126, ieObj_HTMLTableCell126, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement126_onclick() As Boolean
  ieObj_HTMLDivElement126_onclick = ieObj_EventManager(126, ieObj_HTMLDivElement126, "HTMLDivElement", "OnClick")
End Function
Private Function ieObj_HTMLInputElement127_onclick() As Boolean
  ieObj_HTMLInputElement127_onclick = ieObj_EventManager(127, ieObj_HTMLInputElement127, "HTMLInputElement", "OnClick")
End Function
Private Function ieObj_HTMLSelectElement127_onclick() As Boolean
  ieObj_HTMLSelectElement127_onclick = ieObj_EventManager(127, ieObj_HTMLSelectElement127, "HTMLSelectElement", "OnClick")
End Function
Private Function ieObj_HTMLButtonElement127_onclick() As Boolean
  ieObj_HTMLButtonElement127_onclick = ieObj_EventManager(127, ieObj_HTMLButtonElement127, "HTMLButtonElement", "OnClick")
End Function
Private Function ieObj_HTMLAnchorElement127_onclick() As Boolean
  ieObj_HTMLAnchorElement127_onclick = ieObj_EventManager(127, ieObj_HTMLAnchorElement127, "HTMLAnchorElement", "OnClick")
End Function
Private Function ieObj_HTMLTextAreaElement127_onclick() As Boolean
  ieObj_HTMLTextAreaElement127_onclick = ieObj_EventManager(127, ieObj_HTMLTextAreaElement127, "HTMLTextAreaElement", "OnClick")
End Function
Private Function ieObj_HTMLImg127_onclick() As Boolean
  ieObj_HTMLImg127_onclick = ieObj_EventManager(127, ieObj_HTMLImg127, "HTMLImg", "OnClick")
End Function
Private Function ieObj_HTMLTableCell127_onclick() As Boolean
  ieObj_HTMLTableCell127_onclick = ieObj_EventManager(127, ieObj_HTMLTableCell127, "HTMLTableCell", "OnClick")
End Function
Private Function ieObj_HTMLDivElement127_onclick() As Boolean
  ieObj_HTMLDivElement127_onclick = ieObj_EventManager(127, ieObj_HTMLDivElement127, "HTMLDivElement", "OnClick")
End Function



Public Function OpenDialog(frm As Form, booChildWindow As Long, HTMLDoc As HTMLDocument, booViewOnlyNamedObject As Boolean, Optional ByVal strFrameName As String, Optional booRecursiveCall As Boolean = False) As Boolean

    On Error GoTo errmgr

    Dim eCollection         As IHTMLElementCollection
    Dim i                   As Long
    Dim a                   As Object
    Dim strPropertyValue    As String
    Dim booFound            As Boolean
    Dim lngIndexCounter     As Long
    Dim strOName            As Variant
    Dim strOType            As String
    Dim strOValue           As String
    Dim strOChecked         As String
    Dim strHREF             As String
    Dim strSRC              As String
    Dim strOAttrType        As String
    Dim h                   As HTMLInputElement
    Dim objWaitCursor       As New CWaitCursor
    Dim strText             As String
    Dim strRecordOnlyFromFrame As String
    Dim a_                   As HTMLObjectElement
    Dim p_                   As HTMLParaElement
    Dim s_                  As HTMLScriptElement
    Dim l_                  As HTMLLinkElement
    Dim lngeCollectionLength As Long
    Dim objFrame            As Object
    
    IsChildWindow = booChildWindow
    
    If booChildWindow Then
        Debug.Print "OpenDialog " & IsChildWindow
    End If
    
    Set m_objFrm = frm
    
    LOG_DEBUG_STRING "frmViewHTMLObject.OpenDialog() booRecursiveCall=" & booRecursiveCall & " strFrameName=" & strFrameName
    
    If Not IsValidObject(HTMLDoc) Then GoTo TheExit
                
    If (Len(strFrameName)) Then
    
        Set objFrame = GetFrame(HTMLDoc, strFrameName)
        If IsValidObject(objFrame) Then
        
            Set eCollection = objFrame.Document.All
        Else
        
            'FShowError PreProcess(W3RUNNER_ERROR_07052, "NAME", strFrameName), Me.Name, "OpenDialog"
            GoTo TheExit
        End If
    Else
        Set eCollection = HTMLDoc.All
    End If
    
    If (Not booRecursiveCall) Then
    
        ResetObjects
        m_lngObjectCounter = 0
        m_booCancelReadingObjectDefinition = False
        
        Me.Show
        DoEvents
        
        Status W3RUNNER_MSG_07015
        
        lvWatchMode.ListItems.Clear
        AddListViewColumns
        lvLoadSaveContext Me.lvWatchMode, False, App
        objWaitCursor.Wait Screen
        DoEvents
    End If
    
    lngeCollectionLength = eCollection.Length - 1
    
    For i = 0 To lngeCollectionLength
        
        m_lngObjectCounter = m_lngObjectCounter + 1
        
        If m_lngObjectCounter Mod 32 = 0 Then Status PreProcess(W3RUNNER_MSG_07051, "COUNTER", m_lngObjectCounter)
        
        If m_booCancelReadingObjectDefinition Then GoTo TheExit
    
        Set a = eCollection.Item(i)
        strOType = TypeName(a)
        strOName = g_objHelper.GetHTMLObjectName(a)
        Debug.Print strOName & " " & strOType
        
        If Len(strOName) Then
            
            Select Case UCase$(strOType)
            
                Case "HTMLINPUTELEMENT"
                    SetEIObject a, "HTMLInputElement", ieObj_HTMLInputElementIndex, strFrameName, strOName
                    ieObj_HTMLInputElementIndex = ieObj_HTMLInputElementIndex + 1
                    
                Case "HTMLTEXTAREAELEMENT"
                    SetEIObject a, "HTMLTextAreaElement", ieObj_HTMLTextAreaElementIndex, strFrameName, strOName
                    ieObj_HTMLTextAreaElementIndex = ieObj_HTMLTextAreaElementIndex + 1
                    
                Case "HTMLSELECTELEMENT"
                    SetEIObject a, "HTMLSelectElement", ieObj_HTMLSelectElementIndex, strFrameName, strOName
                    ieObj_HTMLSelectElementIndex = ieObj_HTMLSelectElementIndex + 1
                    
                Case "HTMLANCHORELEMENT"
                    SetEIObject a, "HTMLAnchorElement", ieObj_HTMLAnchorElementIndex, strFrameName, strOName
                    ieObj_HTMLAnchorElementIndex = ieObj_HTMLAnchorElementIndex + 1
                    
                Case "HTMLBUTTONELEMENT"
                    SetEIObject a, "HTMLButtonElement", ieObj_HTMLButtonElementIndex, strFrameName, strOName
                    ieObj_HTMLButtonElementIndex = ieObj_HTMLButtonElementIndex + 1
                   
                Case "HTMLIMG"
                    SetEIObject a, "HTMLImg", ieObj_HTMLImgIndex, strFrameName, strOName
                    ieObj_HTMLImgIndex = ieObj_HTMLImgIndex + 1
                    
                Case "HTMLTABLECELL"
                    SetEIObject a, "HTMLTableCell", ieObj_HTMLTableCellIndex, strFrameName, strOName
                    ieObj_HTMLTableCellIndex = ieObj_HTMLTableCellIndex + 1
                    
                Case "HTMLDIVELEMENT"
                    SetEIObject a, "HTMLDivElement", ieObj_HTMLDivElementIndex, strFrameName, strOName
                    ieObj_HTMLDivElementIndex = ieObj_HTMLDivElementIndex + 1
                    
            End Select

            strOValue = g_objHelper.GetHTMLObjectProperty(a, "value")
            strOChecked = g_objHelper.GetHTMLObjectProperty(a, "checked")
            strHREF = g_objHelper.GetHTMLObjectProperty(a, "href")
            strOAttrType = g_objHelper.GetHTMLObjectProperty(a, "type")
            strSRC = g_objHelper.GetHTMLObjectProperty(a, "src")
            strText = g_objHelper.GetHTMLObjectProperty(a, "InnerText")
            
            ' -- Special support for ActiveX --
            If strOType = "HTMLObjectElement" Then strOAttrType = TypeName(a.Object)
            
            ShowObjectInfo CStr(strOName), strOType, strOValue, strOChecked, strHREF, strSRC, strFrameName, strOAttrType, strText
        End If
        
        If UCase$(strOType) = "HTMLFRAMEELEMENT" Or UCase$(strOType) = "HTMLIFRAME" Then
        
            If Len(strOName) Then
            
                strRecordOnlyFromFrame = UCase$(AppOptions("RecordOnlyFromFrame", ""))
                
                If strRecordOnlyFromFrame = UCase$(strOName) Or Len(strRecordOnlyFromFrame) = 0 Then
            
                    OpenDialog frm, booChildWindow, HTMLDoc, booViewOnlyNamedObject, strOName, True
                End If
            Else ' Frame or IFrame with no name are not supported
                frmQuickMessage.OpenDialog W3RUNNER_ERROR_07036, "07036"
            End If
        End If
    Next
TheExit:
    If (Not booRecursiveCall) Then
        
        Status PreProcess(W3RUNNER_MSG_07009, "DIV", ieObj_HTMLDivElementIndex, "INPUT", ieObj_HTMLInputElementIndex, "SELECT", ieObj_HTMLSelectElementIndex, "BUTTON", ieObj_HTMLButtonElementIndex, "ANCHOR", ieObj_HTMLAnchorElementIndex, "IMAGE", ieObj_HTMLImgIndex, "TABLECELL", ieObj_HTMLTableCellIndex), 2
        Status
        If m_booCancelReadingObjectDefinition Then
            FShowError W3RUNNER_ERROR_07035
        End If
    End If
    Exit Function
errmgr:

    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me.Name, "OpenDialog"
End Function

Private Function ShowObjectInfo(strName As String, strType As String, strValue As String, strChecked As String, strHREF As String, strSRC As String, strFrameName As String, strAttrType As String, strText As String) As Boolean

    Dim l As ListItem
    Dim w As New cWindows
    
    Set l = lvAddRow(lvWatchMode, strName, "K" & strName & "_" & w.CreateGUIDKey(), , "Object")
    l.SubItems(LV_FRAME_INDEX) = strFrameName
    l.SubItems(LV_ATTR_TYPE_INDEX) = strAttrType
    l.SubItems(LV_TYPE_INDEX) = strType
    l.SubItems(LV_VALUE_INDEX) = strValue
    l.SubItems(LV_CHECKED_INDEX) = strChecked
    l.SubItems(LV_TEXT_INDEX) = strText
    
    l.SubItems(LV_HREF_INDEX) = strHREF
    l.SubItems(LV_SRC_INDEX) = strSRC
    ShowObjectInfo = True
End Function

Private Sub Form_Load()


    Dim w As New cWindows
    
'    MsgBox "loading me"
    
    If AppOptions("WatchWindowAlwaysOnTop", False) Then
    
        w.SetWinTopMost Me, True
    End If
    
    Me.mnuMouseRightClick.Visible = False
    g_objIniFile.FormSaveRestore Me, False, True
    
    m_lngTxtGeneratedHeightSize = 200 * Screen.TwipsPerPixelY
    
    m_lngTxtGeneratedHeightSize = AppOptions("m_lngTxtGeneratedHeightSize", m_lngTxtGeneratedHeightSize)
    
End Sub

Private Sub Form_Resize()
    On Error Resume Next

    lvWatchMode.Left = 0
    lvWatchMode.Top = 0
    lvWatchMode.Width = Me.Width - (Screen.TwipsPerPixelY * 7)
    lvWatchMode.Height = Me.Height - Me.StatusBar1.Height - (Screen.TwipsPerPixelY * CAPTION_HEIGHT_PIXEL) - m_lngTxtGeneratedHeightSize - (RESIZE_BORDER_HEIGHT * Screen.TwipsPerPixelX)

    txtGenerated.Left = 0
    txtGenerated.Top = lvWatchMode.Height + (RESIZE_BORDER_HEIGHT * Screen.TwipsPerPixelX)
    txtGenerated.Width = lvWatchMode.Width
    txtGenerated.Height = m_lngTxtGeneratedHeightSize
    
    imgSplitterDown.Left = 0
    imgSplitterDown.Width = Me.Width
    imgSplitterDown.Top = Me.txtGenerated.Top - (RESIZE_BORDER_HEIGHT * Screen.TwipsPerPixelX)
    imgSplitterDown.Height = Me.Height
    imgSplitterDown.Visible = True
    
End Sub

Private Sub Form_Unload(Cancel As Integer)
    ResetObjects
    g_objIniFile.FormSaveRestore Me, True, True
    HTMLObjectWindowOpened = False
    lvLoadSaveContext Me.lvWatchMode, True, App
    
    If (frmMain.RecordMode) Then ' stop the record mode
        frmMain.SwitchRecordMode
    End If
End Sub

Private Sub lvWatchMode_ColumnClick(ByVal ColumnHeader As MSComctlLib.ColumnHeader)
   lvWatchMode.SortKey = ColumnHeader.Index - 1
   lvWatchMode.Sorted = True
   If (lvWatchMode.SortOrder = lvwAscending) Then
        lvWatchMode.SortOrder = lvwDescending
   Else
        lvWatchMode.SortOrder = lvwAscending
   End If
End Sub

Public Property Get HTMLObjectWindowOpened() As Boolean
    HTMLObjectWindowOpened = g_static_HTMLObjectWindowOpened
End Property

Public Property Let HTMLObjectWindowOpened(ByVal vNewValue As Boolean)
    g_static_HTMLObjectWindowOpened = vNewValue
End Property

Public Function Status(Optional strMessage As String, Optional lngIndex As Long = 1)

    On Error GoTo errmgr

    Me.StatusBar1.Panels(lngIndex).Text = strMessage
    Me.StatusBar1.Refresh
    Exit Function
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me.Name & ".frm", "Status"
End Function

Private Sub lvWatchMode_MouseDown(Button As Integer, Shift As Integer, x As Single, Y As Single)
    If Button = 2 Then Me.PopupMenu Me.mnuMouseRightClick
End Sub

Public Function GetW3RunnerHTMLObjectType(strIEType As String, strHTMLAttr As String) As String

'HTMLButtonElement
'HTMLImg
'HTMLAnchorElement
'HTMLInputElement radio, CheckBox, Hidden, submit, Text

    Select Case UCase(strIEType & "_" & strHTMLAttr)
    
    
        Case UCase("HTMLButtonElement_Button"): GetW3RunnerHTMLObjectType = "Button"
        Case UCase("HTMLImg_"): GetW3RunnerHTMLObjectType = "Image"
        Case UCase("HTMLAnchorElement_"): GetW3RunnerHTMLObjectType = "Anchor"
        Case UCase("HTMLSelectElement_Select-One"): GetW3RunnerHTMLObjectType = "ComboBox"
        Case UCase("HTMLInputElement_Radio"): GetW3RunnerHTMLObjectType = "RadioButton"
        Case UCase("HTMLInputElement_CheckBox"): GetW3RunnerHTMLObjectType = "CheckBox"
        Case UCase("HTMLInputElement_Hidden"): GetW3RunnerHTMLObjectType = "Hidden"
        Case UCase("HTMLInputElement_Submit"): GetW3RunnerHTMLObjectType = "Submit"
        Case UCase("HTMLInputElement_Button"): GetW3RunnerHTMLObjectType = "Button"
        
        Case UCase("HTMLInputElement_Text"): GetW3RunnerHTMLObjectType = "TextBox"
        Case UCase("HTMLTextAreaElement_Text"), UCase("HTMLTextAreaElement_TextArea"): GetW3RunnerHTMLObjectType = "TextBox"
        
        Case UCase("HTMLInputElement_PassWord"): GetW3RunnerHTMLObjectType = "TextBox"
        Case UCase("HTMLImg"), UCase("HTMLInputElement_Image"): GetW3RunnerHTMLObjectType = "Image"
        
        Case UCase("HTMLDivElement_"): GetW3RunnerHTMLObjectType = "Div"
        
        Case UCase("HTMLTableCell_"): GetW3RunnerHTMLObjectType = "TableCell"
    End Select
End Function

'Private Function PlugObjects(frm As Form, HTMLDoc As HTMLDocument, Optional ByVal strFrameName As String, Optional booRecursiveCall As Boolean) As Boolean
'
'    On Error GoTo ErrMgr
'
'    Dim eCollection         As IHTMLElementCollection
'    Dim i                   As Long
'    Dim a                   As Object
'    Dim strOName            As Variant
'    Dim strOType            As String
'    Dim IMG                 As HTMLImg
'    Dim lngCollectionLength As Long
'    Dim objWaitCursor       As New CWaitCursor
'
'    If Not IsValidObject(HTMLDoc) Then GoTo TheExit
'
'    If (Len(strFrameName)) Then
'        Set eCollection = GetFrame(HTMLDoc, strFrameName).Document.All
'    Else
'        Set eCollection = HTMLDoc.All
'    End If
'
'    If (Not booRecursiveCall) Then
'
'        objWaitCursor.Wait Screen
'        frmMain.Status W3RUNNER_MSG_07016
'        Status W3RUNNER_MSG_07016
'        ResetObjects
'    End If
'
'    lngCollectionLength = eCollection.length - 1
'    For i = 0 To lngCollectionLength
'
'        strOType = TypeName(eCollection.Item(i))
'        Set a = eCollection.Item(i)
'
'        strOName = GetHTMLObjectName(a)
'
'        If Len(strOName) Then
'
'            Select Case UCase$(strOType)
'
'                Case "HTMLINPUTELEMENT"
'
'                    SetEIObject a, "HTMLInputElement", ieObj_HTMLInputElementIndex, strFrameName
'                    ieObj_HTMLInputElementIndex = ieObj_HTMLInputElementIndex + 1
'
'                Case "HTMLTEXTAREAELEMENT"
'
'                    SetEIObject a, "HTMLTextAreaElement", ieObj_HTMLTextAreaElementIndex, strFrameName
'                    ieObj_HTMLTextAreaElementIndex = ieObj_HTMLTextAreaElementIndex + 1
'
'                Case "HTMLSELECTELEMENT"
'
'                    SetEIObject a, "HTMLSelectElement", ieObj_HTMLSelectElementIndex, strFrameName
'                    ieObj_HTMLSelectElementIndex = ieObj_HTMLSelectElementIndex + 1
'
'                Case "HTMLANCHORELEMENT"
'
'                    SetEIObject a, "HTMLAnchorElement", ieObj_HTMLAnchorElementIndex, strFrameName
'                    ieObj_HTMLAnchorElementIndex = ieObj_HTMLAnchorElementIndex + 1
'
'                Case "HTMLBUTTONELEMENT"
'
'                    SetEIObject a, "HTMLButtonElement", ieObj_HTMLButtonElementIndex, strFrameName
'                    ieObj_HTMLButtonElementIndex = ieObj_HTMLButtonElementIndex + 1
'
'                Case "HTMLIMG"
'
'                    SetEIObject a, "HTMLImg", ieObj_HTMLImgIndex, strFrameName
'                    ieObj_HTMLImgIndex = ieObj_HTMLImgIndex + 1
'
'                Case "HTMLTABLECELL"
'
'                    SetEIObject a, "HTMLTableCell", ieObj_HTMLTableCellIndex, strFrameName
'                    ieObj_HTMLTableCellIndex = ieObj_HTMLTableCellIndex + 1
'            End Select
'        End If
'        If UCase$(strOType) = "HTMLFRAMEELEMENT" Then
'
'            PlugObjects frm, HTMLDoc, strOName, True
'            DoEvents
'        End If
'    Next
'TheExit:
'
'    If (Not booRecursiveCall) Then
'        Me.Show
'        Status PreProcess(W3RUNNER_MSG_07009, "INPUT", ieObj_HTMLInputElementIndex, "SELECT", ieObj_HTMLSelectElementIndex, "BUTTON", ieObj_HTMLButtonElementIndex, "ANCHOR", ieObj_HTMLAnchorElementIndex, "IMAGE", ieObj_HTMLImgIndex, "TABLECELL", ieObj_HTMLTableCellIndex), 2
'        frmMain.Status
'
'    End If
'    Exit Function
'    PlugObjects = True
'ErrMgr:
'
'    Debug.Assert 0
'    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me.Name, "Script"
'End Function

Private Function ResetObjects() As Boolean

    Dim i As Long
    
    LOG_DEBUG_STRING "ResetObjects() ---------------------------------------------"
    
    ieObj_HTMLInputElementIndex = 0
    ieObj_HTMLTextAreaElementIndex = 0
    ieObj_HTMLSelectElementIndex = 0
    ieObj_HTMLButtonElementIndex = 0
    ieObj_HTMLAnchorElementIndex = 0
    ieObj_HTMLImgIndex = 0
    ieObj_HTMLTableCellIndex = 0
    ieObj_HTMLDivElementIndex = 0
    
    For i = 0 To MAX_IE_OBJECTS - 1
    
        SetEIObject Nothing, "HTMLInputElement", i
        SetEIObject Nothing, "HTMLSelectElement", i
        SetEIObject Nothing, "HTMLButtonElement", i
        SetEIObject Nothing, "HTMLAnchorElement", i
        SetEIObject Nothing, "HTMLTextAreaElement", i
        SetEIObject Nothing, "HTMLImg", i
        SetEIObject Nothing, "HTMLTableCell", i
        SetEIObject Nothing, "HTMLDivElement", i
    Next
End Function

Private Function ieObj_EventManager(lngIndex As Long, obj As Object, strIEType As String, strEvent As String) As Boolean

    Dim str         As String
    Dim strName     As String
    Dim strType     As String
    Dim strFrame    As String
    Dim strValue    As String
    Dim strChecked  As String
    Dim strVBChecked As String
    Dim objUIItem   As W3RunnerControl
    Dim booIsPassWord As Boolean
    
    Dim strCryptedValue As String
    
    Debug.Print "ieObj_EventManager"
    
    If Not IsValidObject(g_objIEEventFilter) Then ' Not in Record mode
        ieObj_EventManager = True
        Exit Function
    End If
    
    If Not (g_objIEEventFilter.AltKeyDown) Then ' The key CTRL+SHIFT are not down then we ignore the click
    
        ieObj_EventManager = True
        Exit Function
    End If
    
    Select Case UCase$(strIEType)

        Case "HTMLDIVELEMENT": strFrame = ieObj_HTMLDivElementInfo(lngIndex)
        Case "HTMLINPUTELEMENT": strFrame = ieObj_HTMLInputElementInfo(lngIndex)
        Case "HTMLSELECTELEMENT": strFrame = ieObj_HTMLSelectElementInfo(lngIndex)
        Case "HTMLBUTTONELEMENT": strFrame = ieObj_HTMLButtonElementInfo(lngIndex)
        Case "HTMLANCHORELEMENT": strFrame = ieObj_HTMLAnchorElementInfo(lngIndex)
        Case "HTMLTEXTAREAELEMENT": strFrame = ieObj_HTMLTextAreaElementInfo(lngIndex)
        Case "HTMLIMG": strFrame = ieObj_HTMLImgInfo(lngIndex)
        Case "HTMLTABLECELL": strFrame = ieObj_HTMLTableCellInfo(lngIndex)
    End Select
    
    strName = g_objHelper.GetHTMLObjectName(obj)
    
    strType = GetW3RunnerHTMLObjectType(TypeName(obj), g_objHelper.GetHTMLObjectProperty(obj, "type")) ' we do not convert in upper case for the script generated
    strValue = g_objHelper.GetHTMLObjectProperty(obj, "value")
    strChecked = UCase("" & g_objHelper.GetHTMLObjectProperty(obj, "checked"))
    strVBChecked = IIf(UCase$(strChecked) = "TRUE", "vbChecked", "vbUnChecked")
    
    If IsChildWindow Then
        str = "Page.Windows(" & IsChildWindow & ").Controls([DC][NAME][DC],[DC][TYPE][DC],[DC][FRAME][DC])"
    Else
        str = "Page.Controls([DC][NAME][DC],[DC][TYPE][DC],[DC][FRAME][DC])"
    End If
    
    Select Case UCase$(strType)
    
        Case "TEXTBOX"
            booIsPassWord = UCase$(g_objHelper.GetHTMLObjectProperty(obj, "type")) = "PASSWORD"
            If booIsPassWord Then
                
                g_objCryptor.Crypte strValue, strCryptedValue

                str = str & ".SecureText = [DC][CRYPTEDVALUE][DC]"
            Else
                str = str & ".Text = [DC][VALUE][DC]"
            End If
            
        Case "COMBOBOX", "LISTBOX"
            If (Len(strValue)) Then
                str = str & ".Value = [DC][VALUE][DC]"
            Else
                Set objUIItem = New W3RunnerControl
                objUIItem.Initialize strName, obj, Nothing, UCase$(strType), strFrame
                strValue = objUIItem.Text
                str = str & ".Text = [DC][VALUE][DC]"
            End If
            
        Case "BUTTON", "IMAGE", "ANCHOR", "SUBMIT", "TABLECELL", "DIV"
            str = str & ".Click"
        
        Case "CHECKBOX"
            str = str & ".Value = [VBCHECKED]"
            
        Case "RADIOBUTTON"    ' Special case to support array of radio button - We need to redefine the template to set the value parameter
            If IsChildWindow Then
                str = "Page.Windows(" & IsChildWindow & ").Controls([DC][NAME][DC],[DC][TYPE][DC],[DC][FRAME][DC],,[DC][VALUE][DC])"
            Else
                str = "Page.Controls([DC][NAME][DC],[DC][TYPE][DC],[DC][FRAME][DC],,[DC][VALUE][DC])"
            End If
            str = str & ".Value = [CHECKED]"
    End Select
    str = PreProcess(str, "CRYPTEDVALUE", strCryptedValue, "DC", """", "NAME", strName, "TYPE", strType, "FRAME", strFrame, "VALUE", strValue, "CHECKED", strChecked, "VBCHECKED", strVBChecked)
    str = Replace(str, ","""")", ")") ' Remove optional parameters not defined
    str = Replace(str, ","""",", ",,")
    
    AddGeneratedText W3RUNNER_VBSCRIPT_GENERATED_INDENT_STRING & str
    ieObj_EventManager = True
End Function


Private Sub mnuCopyName_Click()

    If Not IsValidObject(lvWatchMode.SelectedItem) Then Exit Sub
    ClipBoard.Clear
    ClipBoard.SetText lvWatchMode.SelectedItem.Text
End Sub

Private Function AddListViewColumns() As Boolean

    If (lvWatchMode.ListItems.Count = 0) Then
    
        lvAddColumn lvWatchMode, "Name", True, 150
        lvAddColumn lvWatchMode, "Frame", , 64
        lvAddColumn lvWatchMode, "MSHTML Type"
        lvAddColumn lvWatchMode, "Type"
        lvAddColumn lvWatchMode, "Value", , 100
        lvAddColumn lvWatchMode, "Checked", , 64
        lvAddColumn lvWatchMode, "Text", , 64
        lvAddColumn lvWatchMode, "HRef", , 64
        lvAddColumn lvWatchMode, "Src", , 64
    End If
    AddListViewColumns = True
End Function


Private Sub imgSplitterDown_MouseDown(Button As Integer, Shift As Integer, x As Single, Y As Single)

    On Error GoTo errmgr

    With imgSplitterDown
    
        picSplitter.Move .Left, .Top, .Width, (5 * Screen.TwipsPerPixelY)
    End With
    picSplitter.Visible = True
    mbMoving = True
    Exit Sub
errmgr:
   
End Sub

Private Sub imgSplitterDown_MouseMove(Button As Integer, Shift As Integer, x As Single, Y As Single)

    On Error GoTo errmgr

    Dim sglPos As Single
    
    If mbMoving Then
        
        sglPos = imgSplitterDown.Top + Y
        
        If sglPos < sglSplitLimit Then
        
            picSplitter.Top = sglSplitLimit
            
        ElseIf sglPos > Me.Height Then
        
            picSplitter.Top = Me.Height
        Else
            picSplitter.Top = sglPos
        End If
    End If
    Exit Sub
errmgr:
   
End Sub

Private Sub imgSplitterDown_MouseUp(Button As Integer, Shift As Integer, x As Single, Y As Single)

    On Error GoTo errmgr

    Dim lngSplitterPos  As Long
    
    lngSplitterPos = imgSplitterDown.Top + (Y)
    
    If lngSplitterPos < sglSplitLimit Then lngSplitterPos = sglSplitLimit
    
    m_lngTxtGeneratedHeightSize = (Me.Height - (GetCaptionMenuHeight(frmMain) * Screen.TwipsPerPixelY)) - lngSplitterPos
    
    AppOptions("m_lngTxtGeneratedHeightSize") = m_lngTxtGeneratedHeightSize
    
    picSplitter.Visible = False
    mbMoving = False
    
    Form_Resize
    Exit Sub
errmgr:
   
End Sub

Public Function AddGeneratedText(str As String) As Boolean

    txtGenerated.Text = txtGenerated.Text & str & vbNewLine
    ScrollToTheEndTxtGenerated
    AddGeneratedText = True
End Function

Private Sub mnuRefresh_Click()
    frmMain.mnuWatchWindow_Click
End Sub

Private Sub txtGenerated_Change()
    Dim objTextFile As New cTextFile
    Dim strText     As String
    
    If Len(RecordFileName) Then
        
        strText = PreProcess(W3RUNNER_MSG_07034, "HEADER", GetRecordFileCommentHeader(), "SOURCE", txtGenerated.Text, "CRLF", vbNewLine)
        objTextFile.LogFile RecordFileName, strText, True
    End If
End Sub

Public Function PopulateGeneratedTextFileRecordFileName() As Boolean

    Dim objTextFile As New cTextFile
    Dim strSource   As String
    
    If Len(RecordFileName) Then
    
        If objTextFile.ExistFile(RecordFileName) Then
        
            strSource = objTextFile.LoadFile(RecordFileName)
            strSource = Replace(strSource, "PUBLIC FUNCTION Main()" & vbNewLine, "")
            strSource = Replace(strSource, "END FUNCTION ' Main()" & vbNewLine, "")
            
            Me.txtGenerated.Text = strSource
            
            ScrollToTheEndTxtGenerated
        End If
    End If
    PopulateGeneratedTextFileRecordFileName = True
End Function

Private Function ScrollToTheEndTxtGenerated() As Boolean

    txtGenerated.SelStart = Len(txtGenerated.Text) - 1
    txtGenerated.SelLength = 1
    ScrollToTheEndTxtGenerated = True
End Function
