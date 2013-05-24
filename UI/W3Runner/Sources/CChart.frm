VERSION 5.00
Object = "{65E121D4-0C60-11D2-A9FC-0000F8754DA1}#2.0#0"; "Mschrt20.ocx"
Begin VB.Form frmChart 
   BackColor       =   &H00FFFFFF&
   Caption         =   "frmChart"
   ClientHeight    =   5625
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   7650
   LinkTopic       =   "Form1"
   ScaleHeight     =   5625
   ScaleWidth      =   7650
   StartUpPosition =   3  'Windows Default
   Begin MSChart20Lib.MSChart Chart 
      Height          =   3855
      Left            =   480
      OleObjectBlob   =   "CChart.frx":0000
      TabIndex        =   0
      Top             =   540
      Width           =   5955
   End
End
Attribute VB_Name = "frmChart"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

