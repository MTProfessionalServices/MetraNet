VERSION 5.00
Object = "{831FDD16-0C5C-11D2-A9FC-0000F8754DA1}#2.0#0"; "mscomctl.ocx"
Begin VB.Form PackageProgressBar 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Progress"
   ClientHeight    =   1200
   ClientLeft      =   45
   ClientTop       =   330
   ClientWidth     =   7680
   ClipControls    =   0   'False
   ControlBox      =   0   'False
   FillStyle       =   0  'Solid
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   1200
   ScaleWidth      =   7680
   ShowInTaskbar   =   0   'False
   StartUpPosition =   2  'CenterScreen
   Begin MSComctlLib.ProgressBar PackageProgress 
      Height          =   255
      Left            =   120
      TabIndex        =   0
      Top             =   840
      Width           =   7455
      _ExtentX        =   13150
      _ExtentY        =   450
      _Version        =   393216
      Appearance      =   1
   End
   Begin VB.Label lblFile 
      ForeColor       =   &H00800000&
      Height          =   255
      Left            =   1440
      TabIndex        =   3
      Top             =   480
      Width           =   6135
   End
   Begin VB.Label Label2 
      Caption         =   "Processing File:"
      Height          =   255
      Left            =   120
      TabIndex        =   2
      Top             =   480
      Width           =   1215
   End
   Begin VB.Label Label1 
      Caption         =   "Waving the magic wand... be patient!"
      Height          =   255
      Left            =   120
      TabIndex        =   1
      Top             =   120
      Width           =   3615
   End
End
Attribute VB_Name = "PackageProgressBar"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit
Private mCount As Long

Public Sub SetNumItems(aItems As Long)

PackageProgress.Max = aItems + 1
PackageProgress.Min = 0

mCount = 0
End Sub


Public Sub Update()

mCount = mCount + 1

If mCount < PackageProgress.Max Then
  PackageProgress.Value = mCount
End If
End Sub

