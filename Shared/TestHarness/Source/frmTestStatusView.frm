VERSION 5.00
Object = "{831FDD16-0C5C-11D2-A9FC-0000F8754DA1}#2.0#0"; "mscomctl.ocx"
Object = "{5E9E78A0-531B-11CF-91F6-C2863C385E30}#1.0#0"; "msflxgrd.ocx"
Begin VB.Form frmTestStatusView 
   Caption         =   "Tests DashBoard"
   ClientHeight    =   8700
   ClientLeft      =   165
   ClientTop       =   600
   ClientWidth     =   14595
   KeyPreview      =   -1  'True
   LinkTopic       =   "Form1"
   ScaleHeight     =   8700
   ScaleWidth      =   14595
   Begin MSComctlLib.ImageList ImageListGrid 
      Left            =   10200
      Top             =   5280
      _ExtentX        =   1005
      _ExtentY        =   1005
      BackColor       =   -2147483643
      ImageWidth      =   16
      ImageHeight     =   16
      MaskColor       =   12632256
      _Version        =   393216
      BeginProperty Images {2C247F25-8591-11D1-B16A-00C0F0283628} 
         NumListImages   =   3
         BeginProperty ListImage1 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmTestStatusView.frx":0000
            Key             =   "Error"
         EndProperty
         BeginProperty ListImage2 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmTestStatusView.frx":059A
            Key             =   "Info"
         EndProperty
         BeginProperty ListImage3 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmTestStatusView.frx":0CEC
            Key             =   ""
            Object.Tag             =   "Warning"
         EndProperty
      EndProperty
   End
   Begin VB.Frame frmCriteria 
      Caption         =   "Criterias"
      Height          =   1215
      Left            =   0
      TabIndex        =   2
      Top             =   360
      Width           =   17535
      Begin VB.TextBox TxtTestName 
         Height          =   335
         Left            =   6960
         TabIndex        =   22
         Top             =   720
         Width           =   1600
      End
      Begin VB.TextBox TxtMessage 
         Height          =   335
         Left            =   12720
         TabIndex        =   19
         Top             =   360
         Width           =   1600
      End
      Begin VB.TextBox TxtNTUser 
         Height          =   335
         Left            =   12720
         TabIndex        =   16
         Top             =   720
         Width           =   1600
      End
      Begin VB.TextBox TxtSessionID 
         Height          =   335
         Left            =   6960
         TabIndex        =   15
         Top             =   360
         Width           =   1600
      End
      Begin VB.TextBox TxtScxriptName 
         Height          =   335
         Left            =   4080
         TabIndex        =   12
         Top             =   360
         Width           =   1600
      End
      Begin VB.TextBox TxtStatus 
         Height          =   335
         Left            =   4080
         TabIndex        =   11
         Top             =   720
         Width           =   1600
      End
      Begin VB.TextBox txtEndTime 
         Height          =   335
         Left            =   9720
         TabIndex        =   10
         Top             =   720
         Width           =   1600
      End
      Begin VB.TextBox txtStartTime 
         Height          =   335
         Left            =   9720
         TabIndex        =   8
         Top             =   360
         Width           =   1600
      End
      Begin VB.TextBox txtComputer 
         Height          =   335
         Left            =   1080
         TabIndex        =   6
         Top             =   720
         Width           =   1600
      End
      Begin VB.TextBox TxtTester 
         Height          =   335
         Left            =   1080
         TabIndex        =   4
         Top             =   360
         Width           =   1600
      End
      Begin VB.Label Label10 
         Caption         =   "Test Name"
         Height          =   375
         Left            =   5880
         TabIndex        =   23
         Top             =   720
         Width           =   1695
      End
      Begin VB.Label Label9 
         Caption         =   "Message :"
         Height          =   372
         Left            =   11640
         TabIndex        =   20
         Top             =   360
         Width           =   1692
      End
      Begin VB.Label Label8 
         Caption         =   "NTUser"
         Height          =   375
         Left            =   11640
         TabIndex        =   18
         Top             =   720
         Width           =   1695
      End
      Begin VB.Label Label7 
         Caption         =   "Session ID :"
         Height          =   372
         Left            =   5880
         TabIndex        =   17
         Top             =   360
         Width           =   1692
      End
      Begin VB.Label Label6 
         Caption         =   "Script FileName :"
         Height          =   372
         Left            =   2760
         TabIndex        =   14
         Top             =   360
         Width           =   1692
      End
      Begin VB.Label Label5 
         Caption         =   "Status :"
         Height          =   372
         Left            =   2760
         TabIndex        =   13
         Top             =   720
         Width           =   1692
      End
      Begin VB.Label Label4 
         Caption         =   "End Time :"
         Height          =   372
         Left            =   8760
         TabIndex        =   9
         Top             =   720
         Width           =   1692
      End
      Begin VB.Label Label3 
         Caption         =   "Start Time :"
         Height          =   372
         Left            =   8760
         TabIndex        =   7
         Top             =   360
         Width           =   1692
      End
      Begin VB.Label Label2 
         Caption         =   "Computer :"
         Height          =   375
         Left            =   120
         TabIndex        =   5
         Top             =   720
         Width           =   1695
      End
      Begin VB.Label Label1 
         Caption         =   "Tester :"
         Height          =   375
         Left            =   120
         TabIndex        =   3
         Top             =   360
         Width           =   1695
      End
   End
   Begin MSFlexGridLib.MSFlexGrid Grid 
      Height          =   5412
      Left            =   -240
      TabIndex        =   1
      Top             =   2640
      Width           =   8772
      _ExtentX        =   15478
      _ExtentY        =   9551
      _Version        =   393216
      AllowUserResizing=   1
   End
   Begin VB.Timer Timer1 
      Interval        =   1000
      Left            =   18600
      Top             =   8040
   End
   Begin MSComctlLib.StatusBar sbStatusBar 
      Align           =   2  'Align Bottom
      Height          =   372
      Left            =   0
      TabIndex        =   0
      Top             =   8328
      Width           =   14592
      _ExtentX        =   25744
      _ExtentY        =   661
      _Version        =   393216
      BeginProperty Panels {8E3867A5-8586-11D1-B16A-00C0F0283628} 
         NumPanels       =   2
         BeginProperty Panel1 {8E3867AB-8586-11D1-B16A-00C0F0283628} 
            AutoSize        =   1
            Object.Width           =   23433
            MinWidth        =   1764
         EndProperty
         BeginProperty Panel2 {8E3867AB-8586-11D1-B16A-00C0F0283628} 
            AutoSize        =   2
            Object.Width           =   1773
            MinWidth        =   1764
         EndProperty
      EndProperty
   End
   Begin MSComctlLib.ImageList ImageList1 
      Left            =   8880
      Top             =   2040
      _ExtentX        =   1005
      _ExtentY        =   1005
      BackColor       =   -2147483643
      ImageWidth      =   16
      ImageHeight     =   16
      MaskColor       =   12632256
      _Version        =   393216
      BeginProperty Images {2C247F25-8591-11D1-B16A-00C0F0283628} 
         NumListImages   =   12
         BeginProperty ListImage1 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmTestStatusView.frx":1286
            Key             =   "Start"
         EndProperty
         BeginProperty ListImage2 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmTestStatusView.frx":1820
            Key             =   "ExportCSV"
         EndProperty
         BeginProperty ListImage3 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmTestStatusView.frx":1DBA
            Key             =   "WebService"
         EndProperty
         BeginProperty ListImage4 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmTestStatusView.frx":1F14
            Key             =   "StopRecord"
         EndProperty
         BeginProperty ListImage5 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmTestStatusView.frx":24AE
            Key             =   "Go"
         EndProperty
         BeginProperty ListImage6 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmTestStatusView.frx":2A48
            Key             =   "ObjectBrowser"
         EndProperty
         BeginProperty ListImage7 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmTestStatusView.frx":2FE2
            Key             =   "WatchWindow"
         EndProperty
         BeginProperty ListImage8 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmTestStatusView.frx":357C
            Key             =   "Record"
         EndProperty
         BeginProperty ListImage9 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmTestStatusView.frx":3B16
            Key             =   "Stop"
         EndProperty
         BeginProperty ListImage10 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmTestStatusView.frx":40B0
            Key             =   "Open"
         EndProperty
         BeginProperty ListImage11 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmTestStatusView.frx":464A
            Key             =   "Options"
         EndProperty
         BeginProperty ListImage12 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmTestStatusView.frx":4BE4
            Key             =   "Functions"
         EndProperty
      EndProperty
   End
   Begin MSComctlLib.Toolbar Toolbar1 
      Align           =   1  'Align Top
      Height          =   360
      Left            =   0
      TabIndex        =   21
      Top             =   0
      Width           =   14595
      _ExtentX        =   25744
      _ExtentY        =   635
      ButtonWidth     =   609
      ButtonHeight    =   582
      AllowCustomize  =   0   'False
      Wrappable       =   0   'False
      Appearance      =   1
      Style           =   1
      ImageList       =   "ImageList1"
      _Version        =   393216
      BeginProperty Buttons {66833FE8-8583-11D1-B16A-00C0F0283628} 
         NumButtons      =   2
         BeginProperty Button1 {66833FEA-8583-11D1-B16A-00C0F0283628} 
            Key             =   "SQLRun"
            Object.ToolTipText     =   "Refresh"
            ImageKey        =   "Go"
         EndProperty
         BeginProperty Button2 {66833FEA-8583-11D1-B16A-00C0F0283628} 
            Key             =   "ExportCSV"
            Object.ToolTipText     =   "Export"
            ImageKey        =   "ExportCSV"
         EndProperty
      EndProperty
   End
   Begin VB.Menu mnuFile 
      Caption         =   "File"
      Begin VB.Menu mnuClose 
         Caption         =   "Close"
      End
   End
   Begin VB.Menu mnuEdit 
      Caption         =   "Edit"
      Begin VB.Menu mnuEditCopy 
         Caption         =   "Copy"
      End
      Begin VB.Menu mnuClear 
         Caption         =   "&Clear"
         Shortcut        =   {F6}
      End
      Begin VB.Menu mnuFileExportAsCsv 
         Caption         =   "Export as csv"
      End
      Begin VB.Menu mnuEditDeleteSelection 
         Caption         =   "Delete"
      End
      Begin VB.Menu mnuRien1 
         Caption         =   "-"
      End
      Begin VB.Menu mnuEditRefresh 
         Caption         =   "Refresh"
         Shortcut        =   {F5}
      End
   End
End
Attribute VB_Name = "frmTestStatusView"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Const MAX_WIDTH = 14688
Private m_objIniFile As New cIniFile
Private m_objDB      As New CDB
Private m_strSQL        As String
Private m_objRst        As ADODB.Recordset


Private Sub Form_KeyPress(KeyAscii As Integer)
    Select Case KeyAscii
        Case 13: RefreshUI
        
    End Select
    
End Sub

Private Function RefreshUI() As Boolean

    Toolbar1_ButtonClick Toolbar1.Buttons("SQLRun")
End Function


Private Sub Form_Load()
    mnuEditDeleteSelection.Visible = False
End Sub

Private Sub Form_Resize()

    If Me.WindowState = vbMinimized Then Exit Sub

        If Width < MAX_WIDTH Then Width = MAX_WIDTH
    
        frmCriteria.Top = Me.Toolbar1.Height + (0 * Screen.TwipsPerPixelY)
        frmCriteria.Left = (2 * Screen.TwipsPerPixelX)
        frmCriteria.Width = Me.Width - (12 * Screen.TwipsPerPixelX)
    
        Grid.Left = 0
        Grid.Top = frmCriteria.Top + frmCriteria.Height + (2 * Screen.TwipsPerPixelX)
        Grid.Width = Me.Width - (10 * Screen.TwipsPerPixelX)
        Grid.Height = Me.Height - Me.Toolbar1.Height - frmCriteria.Height - Me.sbStatusBar.Height - (50 * Screen.TwipsPerPixelX)
    
End Sub

Private Sub Form_Unload(Cancel As Integer)
    m_objIniFile.setForm Me
    g_objIniFile.FormSaveRestore Me, True, True
    
    SaveColSize
End Sub

Public Function Status(Optional ByVal strMessage As String, Optional lngIndex As Long = 1) As Boolean

    On Error GoTo ErrMgr

    If g_booCommandLineMode Then Exit Function
    
    Me.sbStatusBar.Panels(lngIndex).Text = strMessage

    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), Me.Name, "Status"
End Function

Private Sub Grid_DblClick()
    MsgBox Grid.Text
End Sub

Private Sub Grid_MouseDown(Button As Integer, Shift As Integer, x As Single, Y As Single)
    If Button = 2 Then
    Me.PopupMenu Me.mnuEdit
    End If
End Sub

Private Sub mnuClear_Click()
    Dim v As Control
    For Each v In Me.Controls
        If TypeOf v Is TextBox Then
            v.Text = ""
        End If
    Next
End Sub

Private Sub mnuClose_Click()
    Unload Me
End Sub

Private Sub mnuEditCopy_Click()
    Clipboard.Clear
    Clipboard.SetText Me.Grid.Text
    
End Sub

Private Sub mnuEditDeleteSelection_Click()

    If MsgBox("Delete the current rows from the database ?", vbQuestion + vbYesNo) = vbYes Then
    
        If m_objRst.RecordCount Then
            m_objRst.MoveFirst
            Do While Not m_objRst.EOF
            
                DeleteRow m_objRst.Fields("id").Value
                m_objRst.MoveNext
            Loop
        End If
        RefreshUI
    End If
End Sub

Private Sub mnuEditRefresh_Click()
    RefreshUI
End Sub

Private Sub mnuFileExportAsCsv_Click()
'
End Sub

Private Sub Text1_Change()

End Sub

Private Sub Timer1_Timer()
    Status Now() & " ", 2
End Sub

Public Property Get Config(strName As String, Optional ByVal strDefaultValue As String, Optional strSection As String = "BAG") As String
    Dim s As String
    s = m_objIniFile.getVar(strSection, strName)
    If Len(s) Then
        Config = s
    Else
        Config = strDefaultValue
    End If
End Property


Public Property Let Config(strName As String, Optional ByVal strDefaultValue As String, Optional strSection As String = "BAG", v As String)
    Dim s As String
    m_objIniFile.SetVar strSection, strName, v
End Property


Public Function OpenDialog() As Boolean

    On Error GoTo ErrMgr
    
    g_objIniFile.FormSaveRestore Me, False, True
    m_objIniFile.Init Environ("TEMP") & "\TestDashBoard.Config.Txt"
    
    m_objDB.Server = Config("SQLServer", "BigDisk")
    m_objDB.Database = Config("SQLDatabase", "TestHarnessCoverageDB")
    m_objDB.Login = Config("SQLUserName", "sa")
    m_objDB.PassWord = Config("SQLPassWord", "")
    m_objIniFile.getForm Me
    
    If m_objDB.OpenDB() Then
    
        OpenDialog = True
        
        LoadGrid
        Me.Show vbModal
        
        m_objDB.CloseDB
        Unload Me
    End If
    
    Exit Function
ErrMgr:
    ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), TypeName(Me), "OpenDialog"
    Unload Me
End Function

Public Property Get SQLTable() As String
    SQLTable = Config("SQLTable", "t_TestDashBoard")
End Property


Private Sub Toolbar1_ButtonClick(ByVal Button As MSComctlLib.Button)
    Select Case Button.key
        Case "SQLRun"
            LoadGrid
        Case "ExportCSV"
            mnuFileExportAsCsv_Click
    End Select
    
End Sub



Private Sub txtEndTime_DblClick()
    txtEndTime.Text = Now
End Sub

Private Sub txtStartTime_DblClick()
        txtStartTime.Text = Now
End Sub


Private Function SaveColSize() As Boolean
    Dim c As Long
    Dim lngSize As Long
    If IsValidObject(m_objRst) Then
        For c = 0 To m_objRst.Fields.count - 1
        
            Config("Grid.Col.Size" & c, , "GRID") = Grid.ColWidth(c)
        Next
        SaveColSize = True
    End If
End Function



Private Function ReadColSize() As Boolean
    Dim c As Long
    Dim lngSize As Long
    Dim strValue As String
    
    For c = 0 To m_objRst.Fields.count - 1
    
        strValue = Config("Grid.Col.Size" & c, , "GRID")
        
        If IsNumeric(strValue) Then
        
            Grid.ColWidth(c) = strValue
        End If
    Next
    ReadColSize = True
End Function


Public Function DeleteRow(lngID As Long) As Boolean
    Dim strSQL As String
    
    m_strSQL = "delete from " & SQLTable() & " where id=" & lngID
    
    If m_objDB.SqlRun(m_strSQL, Nothing) Then
    
        DeleteRow = True
    End If
End Function



Public Function LoadGrid() As Boolean

    Dim c As Long
    Dim l As Long
    Dim strAND As String
    Dim strWHERE As String
    Dim booError As Boolean
    Dim strSTATUS As String
    
    On Error GoTo ErrMgr
        
    strWHERE = " Where "
    m_strSQL = "select * from " & SQLTable()
        
    If Len(Me.txtStartTime.Text) Then
        
        m_strSQL = m_strSQL & strAND & strWHERE & "TimeStamp between '" & Me.txtStartTime.Text & "' And '" & Me.txtEndTime.Text & "'"
        strAND = " And "
        strWHERE = " "
    End If
    
    If Len(TxtTester.Text) Then
        
        m_strSQL = m_strSQL & strAND & strWHERE & "Upper(Tester) like '%" & UCase$(Me.TxtTester.Text) & "%' "
        strAND = " And "
        strWHERE = " "
    End If
    
    If Len(txtComputer.Text) Then
        
        m_strSQL = m_strSQL & strAND & strWHERE & "Upper(Computer) like '%" & UCase$(Me.txtComputer.Text) & "%' "
        strAND = " And "
        strWHERE = " "
    End If
    
    If Len(TxtTestName.Text) Then
        
        m_strSQL = m_strSQL & strAND & strWHERE & "Upper(TestName) like '%" & UCase$(TxtTestName) & "%' "
        strAND = " And "
        strWHERE = " "
    End If
    
    If Len(TxtScxriptName.Text) Then
        
        m_strSQL = m_strSQL & strAND & strWHERE & "Upper(ScriptName) Like '%" & UCase$(Me.TxtScxriptName.Text) & "%' "
        strAND = " And "
        strWHERE = " "
    End If
    
    If Len(TxtStatus.Text) Then
        
        m_strSQL = m_strSQL & strAND & strWHERE & "Upper(Status) Like '%" & UCase$(Me.TxtStatus.Text) & "%' "
        strAND = " And "
        strWHERE = " "
    End If
    
    If Len(TxtSessionID.Text) Then
        
        m_strSQL = m_strSQL & strAND & strWHERE & "Upper(SessionId) Like '%" & UCase$(Me.TxtSessionID.Text) & "%' "
        strAND = " And "
        strWHERE = " "
    End If
    
    If Len(TxtNTUser.Text) Then
        
        m_strSQL = m_strSQL & strAND & strWHERE & "Upper(NTUser) Like '%" & UCase$(Me.TxtNTUser.Text) & "%' "
        strAND = " And "
        strWHERE = " "
    End If
    
    If Len(TxtMessage.Text) Then
        
        m_strSQL = m_strSQL & strAND & strWHERE & "Upper(Message) Like '%" & UCase$(Me.TxtMessage.Text) & "%' "
        strAND = " And "
        strWHERE = " "
    End If
    
    
    m_strSQL = m_strSQL & " order by id desc"
    
    Grid.Enabled = False
    Grid.Visible = False
    
    Set m_objRst = m_objDB.SqlRun(m_strSQL, m_objDB.NewRecordset())
    
    Grid.Cols = 1
    Grid.Rows = 1
        
    Grid.Cols = m_objRst.Fields.count + 1
    Grid.Rows = m_objRst.RecordCount + 1
    
    Grid.Row = 0
    For c = 0 To m_objRst.Fields.count - 1
        Grid.Col = c + 1
        Grid.Text = "" & m_objRst.Fields(c).Name
    Next
    
    l = 0
    Do While Not m_objRst.EOF
    
        booError = False
        strSTATUS = m_objRst.Fields("STATUS").Value
        If UCase$(Mid(strSTATUS, 1, 4)) = "END(" Then
            
            booError = UCase$(strSTATUS) <> "END(STATUS=OK)"
        End If
    
        l = l + 1
        Grid.Row = l
        For c = 0 To m_objRst.Fields.count - 1
            Grid.Col = c + 1
            Grid.Text = "" & m_objRst.Fields(c).Value
            If booError Then
                Grid.CellForeColor = vbRed
                'If c = 0 Then Set Grid.CellPicture = Me.ImageListGrid.ListImages("Error").Picture
            End If
        Next
        m_objRst.MoveNext
    Loop
    ReadColSize
    Grid.Enabled = True
    Grid.Visible = True
    
    LoadGrid = True
    Exit Function
ErrMgr:
    MsgBox GetVBErrorString()
End Function
