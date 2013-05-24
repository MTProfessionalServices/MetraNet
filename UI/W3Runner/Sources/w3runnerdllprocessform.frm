VERSION 5.00
Begin VB.Form frmMTVBSysLibProcessForm 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Form1"
   ClientHeight    =   1365
   ClientLeft      =   45
   ClientTop       =   330
   ClientWidth     =   3675
   Icon            =   "FredRunnerDllProcessForm.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   1365
   ScaleWidth      =   3675
   ShowInTaskbar   =   0   'False
   StartUpPosition =   3  'Windows Default
   Begin VB.ComboBox cboHistory 
      Height          =   315
      Left            =   1320
      Style           =   2  'Dropdown List
      TabIndex        =   1
      Top             =   960
      Width           =   1590
   End
   Begin VB.PictureBox pic 
      AutoRedraw      =   -1  'True
      BackColor       =   &H00FFFFFF&
      Height          =   975
      Left            =   120
      ScaleHeight     =   61
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   181
      TabIndex        =   0
      Top             =   120
      Width           =   2775
   End
End
Attribute VB_Name = "frmMTVBSysLibProcessForm"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private m_objProcess As CProcess
Private m_sngX As Long
Private m_sngY As Long

Private m_UpdateCounter As Long

Const MaxY As Double = 100

Const PICTURE_MAX_X = 500
Public CanClose As Boolean
Public MaxYData  As Long

Public Function Initialize(objProcess As CProcess, lngMaxYData As Long) As Boolean

    Set m_objProcess = objProcess
    Caption = m_objProcess.ShortName
    
    Width = (PICTURE_MAX_X + 8) * Screen.TwipsPerPixelX
    Height = ((MaxY + 25) * Screen.TwipsPerPixelY) + Me.cboHistory.Height
    
    Me.pic.Left = 0
    Me.pic.Top = Me.cboHistory.Height
    Me.pic.Width = PICTURE_MAX_X * Screen.TwipsPerPixelX
    Me.pic.Height = 100 * Screen.TwipsPerPixelX
    
    cboHistory.Left = 0
    cboHistory.Top = 0
    cboHistory.Width = Me.pic.Width

    
    MaxYData = lngMaxYData
            
    Me.Show
End Function

Private Sub Form_Load()
    Dim w As New cWindows
    w.SetWinTopMost Me, True
End Sub

Private Sub Form_QueryUnload(Cancel As Integer, UnloadMode As Integer)
    Cancel = Not CanClose
End Sub

Private Sub Form_Unload(Cancel As Integer)
    
    Set m_objProcess = Nothing
End Sub

Public Function Update() As Boolean

    Dim sngValue As Double
    
    On Error Resume Next
    
    Const PlotXStep = 1
    
    m_UpdateCounter = m_UpdateCounter + 1
    
    Caption = m_objProcess.ShortName & " I:" & m_UpdateCounter & " M:" & m_objProcess.GetMemoryUsage() & " VM:" & m_objProcess.GetVirtualMemoryUsage() & " GM:" & m_objProcess.GetGlobalMemoryUsage() & " GVM:" & m_objProcess.GetGlobalVirtualMemoryUsage()
    cboHistory.AddItem Caption
    cboHistory.ListIndex = cboHistory.NewIndex
    
    sngValue = m_objProcess.GetMemoryUsage()
    sngValue = sngValue / (MaxYData / MaxY)
    DrawBar sngValue, vbRed
    
    sngValue = m_objProcess.GetVirtualMemoryUsage
    sngValue = sngValue / (MaxYData / MaxY)
    DrawBar sngValue, vbGreen
    
    pic.Line (0, MaxY / 2)-(1001, MaxY / 2), vbBlack
    pic.CurrentX = 0
    pic.CurrentY = MaxY / 2
    pic.ForeColor = vbBlack
    pic.Print CLng(((MaxYData / 2) / 1024)) & "Mb"
    
    m_sngX = m_sngX + 1
    
    Update = True
    
End Function

Private Function DrawBar(sngValue As Double, lngColor)
    pic.Line (m_sngX, MaxY)-(m_sngX, CLng(MaxY - sngValue)), lngColor
End Function
