VERSION 5.00
Object = "{EAB22AC0-30C1-11CF-A7EB-0000C05BAE0B}#1.1#0"; "ieframe.dll"
Begin VB.Form Form1 
   BackColor       =   &H00FFFFFF&
   BorderStyle     =   1  'Fixed Single
   Caption         =   "MetraNet"
   ClientHeight    =   7935
   ClientLeft      =   45
   ClientTop       =   435
   ClientWidth     =   11970
   ForeColor       =   &H80000005&
   Icon            =   "Form1.frx":0000
   KeyPreview      =   -1  'True
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   7935
   ScaleWidth      =   11970
   ShowInTaskbar   =   0   'False
   StartUpPosition =   1  'CenterOwner
   WindowState     =   2  'Maximized
   Begin VB.Timer Timer1 
      Interval        =   1
      Left            =   480
      Top             =   4440
   End
   Begin SHDocVwCtl.WebBrowser WebBrowser1 
      Height          =   9135
      Left            =   600
      TabIndex        =   0
      Top             =   840
      Width           =   11415
      ExtentX         =   20135
      ExtentY         =   16113
      ViewMode        =   0
      Offline         =   0
      Silent          =   0
      RegisterAsBrowser=   0
      RegisterAsDropTarget=   1
      AutoArrange     =   0   'False
      NoClientEdge    =   0   'False
      AlignLeft       =   0   'False
      NoWebView       =   0   'False
      HideFileNames   =   0   'False
      SingleClick     =   0   'False
      SingleSelection =   0   'False
      NoFolders       =   0   'False
      Transparent     =   0   'False
      ViewID          =   "{0057D0E0-3573-11CF-AE69-08002B2E1262}"
      Location        =   "http:///"
   End
   Begin VB.Label Label1 
      Alignment       =   2  'Center
      BackColor       =   &H00FFFFFF&
      Caption         =   "Welcome to the MetraNet Installation Menu"
      BeginProperty Font 
         Name            =   "Calibri"
         Size            =   18
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00A85A10&
      Height          =   615
      Left            =   50
      TabIndex        =   1
      Top             =   240
      Width           =   6750
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Declare Function GetWindowLong Lib "user32" Alias "GetWindowLongA" (ByVal hwnd As Long, ByVal nIndex As Long) As Long
Private Declare Function SetWindowLong Lib "user32" Alias "SetWindowLongA" (ByVal hwnd As Long, ByVal nIndex As Long, ByVal dwNewLong As Long) As Long
Private Declare Function SetLayeredWindowAttributes Lib "user32" (ByVal hwnd As Long, ByVal crKey As Long, ByVal bAlpha As Byte, ByVal dwFlags As Long) As Long

Private Const GWL_EXSTYLE = (-20)
Private Const WS_EX_LAYERED = &H80000
Private Const LWA_ALPHA = &H2

Private Declare Function SetWindowPos Lib "user32" (ByVal hwnd As Long, ByVal hWndInsertAfter _
    As Long, ByVal X As Long, ByVal Y As Long, ByVal cx As Long, ByVal cy As Long, _
    ByVal wFlags As Long) As Long
    
Private Const SWP_NOMOVE = &H2
Private Const SWP_NOSIZE = &H1
Private Const HWND_TOPMOST As Long = -1
Private Const HWND_NOTOPMOST = -2
Private Const SWP_FRAMECHANGED = &H20
Private Const SWP_SHOWME = SWP_FRAMECHANGED Or SWP_NOMOVE Or SWP_NOSIZE

Private Sub Form_Load()
    WebBrowser1.Navigate AppPath + "Docs\Default.htm"
    ReadSettings
End Sub

Private Function AppPath() As String
    AppPath = App.Path
    If Right(App.Path, 1) <> "\" Then
        AppPath = AppPath & "\"
    End If
End Function

Private Sub Form_Unload(Cancel As Integer)
    End
End Sub

Private Sub Timer1_Timer()
'On error resume next
    With WebBrowser1
        .Left = 0
        .Top = 850
        .Width = Form1.Width + 300
         .Height = Form1.Height
    End With
'   Label1.Left = (Form1.Width / 2) - (Label1.Width / 2)
   Label1.Width = Form1.Width
   Load Form2
   Form2.Show
   Form2.Left = (Form1.Width / 2) - Form2.Width * 1.6
   Call SetWindowLong(Form2.hwnd, GWL_EXSTYLE, GetWindowLong(Form2.hwnd, GWL_EXSTYLE) Or WS_EX_LAYERED)
   Call SetLayeredWindowAttributes(Form2.hwnd, 0, 10, LWA_ALPHA)
   Call SetWindowPos(Form2.hwnd, HWND_TOPMOST, 0&, 0&, 0&, 0&, SWP_SHOWME)
   Form3.Show
   Form3.Left = (Form1.Width / 2) - Form3.Width * 1.6
   Call SetWindowLong(Form3.hwnd, GWL_EXSTYLE, GetWindowLong(Form3.hwnd, GWL_EXSTYLE) Or WS_EX_LAYERED)
   Call SetLayeredWindowAttributes(Form3.hwnd, 0, 10, LWA_ALPHA)
   Call SetWindowPos(Form3.hwnd, HWND_TOPMOST, 0&, 0&, 0&, 0&, SWP_SHOWME)
   Timer1.Enabled = False
End Sub

Private Sub ReadSettings()
On Error GoTo errsub
   Dim intF As Integer
   Dim ss As String, s1 As String, s2 As String
   intF = FreeFile()
   Open AppPath + "Docs\settings" For Binary As #intF
   Line Input #1, s1
   If Len(s1) > 0 Then Form1.Caption = s1
   Line Input #1, s2
   If Len(s2) > 0 Then Label1 = s2
errsub:
End Sub

