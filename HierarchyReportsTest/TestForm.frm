VERSION 5.00
Begin VB.Form TestForm 
   Caption         =   "Form1"
   ClientHeight    =   10530
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   13095
   LinkTopic       =   "Form1"
   ScaleHeight     =   10530
   ScaleWidth      =   13095
   StartUpPosition =   3  'Windows Default
   Begin VB.Frame Frame3 
      Caption         =   "Account Information"
      Height          =   1935
      Left            =   240
      TabIndex        =   11
      Top             =   4680
      Width           =   4215
      Begin VB.CommandButton Command1 
         Caption         =   "Get Report List"
         Height          =   375
         Left            =   960
         TabIndex        =   16
         Top             =   1320
         Width           =   2175
      End
      Begin VB.TextBox Password 
         Height          =   285
         Left            =   1440
         TabIndex        =   15
         Text            =   "123"
         Top             =   840
         Width           =   2535
      End
      Begin VB.TextBox LoginID 
         Height          =   285
         Left            =   1440
         TabIndex        =   12
         Text            =   "kevin"
         Top             =   360
         Width           =   2535
      End
      Begin VB.Label Label2 
         Caption         =   "Password:"
         Height          =   255
         Left            =   600
         TabIndex        =   14
         Top             =   840
         Width           =   855
      End
      Begin VB.Label Label1 
         Caption         =   "Account Login:"
         Height          =   255
         Left            =   240
         TabIndex        =   13
         Top             =   360
         Width           =   1215
      End
   End
   Begin VB.CommandButton GetReportXML 
      Caption         =   "Get Top Level XML"
      Height          =   375
      Left            =   2400
      TabIndex        =   6
      Top             =   3480
      Width           =   1695
   End
   Begin VB.CommandButton GetBillXML 
      Caption         =   "Get Top Level XML"
      Height          =   375
      Left            =   2400
      TabIndex        =   4
      Top             =   1320
      Width           =   1695
   End
   Begin VB.ComboBox BillList 
      Height          =   315
      Left            =   480
      Style           =   2  'Dropdown List
      TabIndex        =   2
      Top             =   720
      Width           =   3735
   End
   Begin VB.ComboBox ReportList 
      Height          =   315
      Left            =   480
      Style           =   2  'Dropdown List
      TabIndex        =   1
      Top             =   2880
      Width           =   3735
   End
   Begin VB.TextBox Text1 
      BackColor       =   &H80000007&
      BeginProperty Font 
         Name            =   "Courier New"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H0000FFFF&
      Height          =   9495
      Left            =   4800
      MultiLine       =   -1  'True
      ScrollBars      =   3  'Both
      TabIndex        =   0
      Text            =   "TestForm.frx":0000
      Top             =   240
      Width           =   8055
   End
   Begin VB.Frame Frame1 
      Caption         =   "Bills"
      Height          =   1695
      Left            =   240
      TabIndex        =   3
      Top             =   360
      Width           =   4215
      Begin VB.OptionButton BillView 
         Caption         =   "By Product"
         Height          =   255
         Index           =   1
         Left            =   360
         TabIndex        =   10
         Top             =   1200
         Width           =   1695
      End
      Begin VB.OptionButton BillView 
         Caption         =   "By Folder"
         Height          =   255
         Index           =   0
         Left            =   360
         TabIndex        =   9
         Top             =   840
         Width           =   1095
      End
   End
   Begin VB.Frame Frame2 
      Caption         =   "Reports"
      Height          =   1695
      Left            =   240
      TabIndex        =   5
      Top             =   2520
      Width           =   4215
      Begin VB.OptionButton ReportView 
         Caption         =   "By Folder"
         Height          =   255
         Index           =   0
         Left            =   360
         TabIndex        =   8
         Top             =   840
         Width           =   1095
      End
      Begin VB.OptionButton ReportView 
         Caption         =   "By Product"
         Height          =   255
         Index           =   1
         Left            =   360
         TabIndex        =   7
         Top             =   1200
         Width           =   1455
      End
   End
End
Attribute VB_Name = "TestForm"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private mobjReportManager As ReportManager
Private mobjReportHelper As ReportHelper
Private mobjSliceFactory As New SliceFactory
Private mcollReports As MTCollection
Private mobjYAAC As MTYAAC

Private Sub BillList_Click()
  Dim objItem As MPSReportInfo
  
  'Enable and disable buttons
  For Each objItem In mcollReports
    If objItem.Name = BillList Then
      If objItem.ViewType = VIEW_TYPE_BY_FOLDER Then
        BillView(0).Enabled = True
        BillView(0).SetFocus
        BillView(1).Enabled = False
        
      ElseIf objItem.ViewType = VIEW_TYPE_BY_PRODUCT Then
        BillView(0).Enabled = False
        BillView(1).SetFocus
        BillView(1).Enabled = True
      
      Else
        BillView(0).Enabled = True
        BillView(1).Enabled = True
      
      End If
    End If
  Next
End Sub

Private Sub Command1_Click()
  Dim objYAACFactory As New MTAccountCatalog
  Dim objSC As MTSessionContext
  Dim objLC As New MTLoginContext
  
  On Error GoTo ErrorHandler
  
  Set objSC = objLC.Login(LoginID, "mt", Password)
  
  objYAACFactory.Init objSC
  
  Set mobjYAAC = objYAACFactory.GetActorAccount()
  
  Set mobjReportHelper = mobjReportManager.GetReportHelper(mobjYAAC, 840)
  
  Call WriteText("COUNT: " & mobjYAAC.GetOwnedFolderList.RecordCount)
  Call GetReportList
  
ErrorHandler:
  If Err Then
    Call WriteText("An error occurred: " & Err.Description & " [" & Err.Source & "]")
  End If
  
End Sub

Private Sub Form_Load()
  Dim objFSO As New FileSystemObject
  Dim objRCD As New MTRcd
  Dim strPath As String
  
  On Error GoTo ErrorHandler
  
  'Create the report manager
  
  Set mobjReportManager = New ReportManager
  'Attempt to find the file
  strPath = objRCD.ExtensionDir & "\newsamplesite\mps\siteconfig\reports.xml"
  
  If Not objFSO.FileExists(strPath) Then
    WriteText ("Unable to load report file! [" & strPath & "]")
    Command1.Enabled = False
    GetBillXML.Enabled = False
    GetReportXML.Enabled = False
  Else
    Call mobjReportManager.Initialize(strPath)
  End If
  
ErrorHandler:
  If Err Then
    Call WriteText("Form_Load::An error occurred -- " & Err.Description & "[" & Err.Source & "]")
  End If

End Sub


'Private Sub GetLevel_Click()
'  Dim objRenderInfo As New MPSRenderInfo
'
'  On Error GoTo ErrHandler
'
'  Dim objHierarchyLevel As New HierarchyReportLevel
'  Dim objChildHierarchyLevel As HierarchyReportLevel
'  Dim i
'
'  'Set objHierarchyLevel = mobjReportManager.GetReportTopLevel("Online Bill", objRenderInfo)
'
'  Call objHierarchyLevel.LoadReportLevelFromXML("Online Bill", ReportLevels)
'
'  Text1.Text = Text1.Text & vbNewLine & vbNewLine
'  Text1.Text = Text1.Text & "Report: Online Bill" & vbNewLine
'  Text1.Text = Text1.Text & "Level: " & ReportLevels & vbNewLine
'  Text1.Text = Text1.Text & "Child Levels: " & objHierarchyLevel.NumChildren
'  Text1.Text = Text1.Text & vbNewLine
'  Text1.Text = Text1.Text & Replace(objHierarchyLevel.GetReportLevelAsXML(False), vbTab, "  ")
'
'  'Get XML for child levels
'  For i = 0 To objHierarchyLevel.NumChildren - 1
'    Set objChildHierarchyLevel = objHierarchyLevel.GetChildLevel(i)
'    Text1.Text = Text1.Text & vbNewLine & "Child " & i & ":" & vbNewLine
'    Text1.Text = Text1.Text & Replace(objChildHierarchyLevel.GetReportLevelAsXML(False), vbTab, "  ")
'  Next
'ErrHandler:
'  If Err Then
'    Text1.Text = Text1.Text & vbNewLine & "An Error Occurred! " & Err.Description
'  End If
'
'  Text1.SelStart = Len(Text1.Text) - 1
'  Text1.SelLength = 1
'
'  Set objHierarchyLevel = Nothing
'End Sub

Private Sub GetReportList()
  Dim objRenderInfo As New MPSRenderInfo
  Dim strDisplay As Variant
  Dim objItem As MPSReportInfo
  Dim bob As MPS_REPORT_TYPE
    
  'Clear the list of existing reports
  Call BillList.Clear
  Call ReportList.Clear
  
  'Set mcollReports = mobjReportManager.GetAvailableReportList(  objRenderInfo)
  Set mcollReports = mobjReportHelper.GetAvailableReports(REPORT_TYPE_BILL)
    
  For Each objItem In mcollReports
    Call BillList.AddItem(objItem.Name)
  Next
  
  WriteText ("Got report list...")
  
End Sub




Private Sub GetBillXML_Click()
  Dim strXML As String
  Dim objRenderInfo As New MPSRenderInfo
  Dim objHierarchyTop As HierarchyReportLevel
  Dim objItem As MPSReportInfo
  Dim eViewType As MPS_VIEW_TYPE
  Dim intIndex As Integer
  Dim objTimeSlice As New UsageIntervalSlice
  Dim i As Long
  intIndex = 0
  
'  On Error GoTo ErrorHandler
  
  'Determine the bill to get
  For i = 1 To mcollReports.Count
    Set objItem = mcollReports(i)
  
    If objItem.Name = BillList Then
      intIndex = objItem.Index
      Exit For
    End If
  Next
  
  If intIndex = 0 Then
    Call MsgBox("Doh! Index = 0")
    Exit Sub
  End If
  
  'Write the Report Info
  Call WriteText(vbNewLine & "Report Name: " & objItem.Name)
  Call WriteText(vbNewLine & "Index: " & objItem.Index)
  Call WriteText(vbNewLine & "Description: " & objItem.Description)
  Call WriteText(vbNewLine & "Type: " & objItem.Type)
  Call WriteText(vbNewLine & "View Type: " & objItem.ViewType)
  Call WriteText(vbNewLine & "Restricted: " & objItem.Restricted)
  Call WriteText(vbNewLine & "    Billable               -- " & objItem.RestrictionBillable)
  Call WriteText(vbNewLine & "    FolderAccount          -- " & objItem.RestrictionFolderAccount)
  Call WriteText(vbNewLine & "    OwnedFolders           -- " & objItem.RestrictionOwnedFolders)
  Call WriteText(vbNewLine & "    BillableOwnedFolders   -- " & objItem.RestrictionBillableOwnedFolders)
  Call WriteText(vbNewLine & "Display Method: " & objItem.DisplayMethod)
  Call WriteText(vbNewLine & "Display Data: " & objItem.DisplayData)
  Call WriteText(vbNewLine & "Override: " & objItem.AccountIDOverride)
  
    
  'Determine view type
  If BillView(0).Value Then
    eViewType = VIEW_TYPE_BY_FOLDER
  Else
    eViewType = VIEW_TYPE_BY_PRODUCT
  End If
  
  Set objTimeSlice = mobjReportHelper.GetIntervalTimeSlice(mobjReportHelper.DefaultIntervalID)
  
  mobjReportHelper.ReportIndex = intIndex
  
  'Set objHierarchyTop = mobjReportManager.GetReportTopLevel(intIndex, objRenderInfo)
  Call mobjReportHelper.InitializeReport(objTimeSlice, eViewType, False, False)
  
  
  'Call WriteText(objHierarchyTop.GetReportLevelAsXML(False))
  Call WriteText(vbNewLine & "<-------------------------------------------------->")
  Call WriteText(vbNewLine & "<-------------- " & BillList & "----------------->")
  Call WriteText(vbNewLine & "<-------------------------------------------------->")
  
  Call WriteXMLText(mobjReportHelper.GetReportAsXML)
  
  'Call WriteReport(objHierarchyTop, "0")
  Dim objProductSlice As Object
  Dim objViewSlice As Object
  Dim objAccountSLice As Object
  Dim objProductTimeSlice As Object
  Dim objUsageDetail As Object
  
  Set objProductSlice = mobjSliceFactory.FromString("Instance/166/4")
  Set objAccountSLice = mobjSliceFactory.FromString("PayerPayee/156/156")
  Set objProductTimeSlice = mobjSliceFactory.FromString("And/DateRange/37257/50406/Interval/22758")
  Set objViewSlice = mobjSliceFactory.FromString("ROOT")
  
  Set objUsageDetail = mobjReportHelper.GetUsageDetail(objProductSlice, objViewSlice, objAccountSLice, objProductTimeSlice, "")
  
  
  
  For i = 0 To objUsageDetail.Count - 1
    Debug.Print objUsageDetail.Name(CLng(i)) & ",";
  Next
  Debug.Print
  
  Do While Not objUsageDetail.EOF
    For i = 0 To objUsageDetail.Count - 1
        Debug.Print objUsageDetail.Value(CLng(i)) & ",";
    Next
    Debug.Print
    objUsageDetail.MoveNext
  Loop
  
  
  
  'Get some rowset for Fred
  'http://localhost/newsamplesite/us/products/metratech/audioConfCall.asp?pViewAmount=240&pViewAmountUOM=USD&usageIntervalID=22758&usageIntervalText=6/2/2002 through Today&ddl=1&
  'accountSlice=PayerPayee/156/156&timeSlice=And/DateRange/37257/50406/Interval/22758&
  'productSlice=Instance/166/4&ReportHelper=ReportHelper&sessionSlice=ROOT
  Exit Sub
ErrorHandler:
  If Err Then
    WriteText ("GetBillXML::An error occurred -- " & Err.Description & " [" & Err.Source & "]")
  End If
  
End Sub

Private Sub WriteReport(ByRef objHierarchyReportLevel As HierarchyReportLevel, ByVal strID As String)
  Dim objChildHierarchyReportLevel As HierarchyReportLevel
  Dim i As Integer
  
  Call WriteText(vbNewLine & vbNewLine & "REPORT LEVEL " & strID & vbNewLine)
  Call WriteXMLText(objHierarchyReportLevel.GetReportLevelAsXML(False))
  
  For i = 1 To objHierarchyReportLevel.NumChildren
    Set objChildHierarchyReportLevel = objHierarchyReportLevel.GetChildLevel(i)
    Call WriteReport(objChildHierarchyReportLevel, strID & ":" & i - 1)
  Next
  
  
End Sub

Private Sub GetReportXML_Click()
  Dim strXML As String
  Dim objRenderInfo As New MPSRenderInfo
  Dim objHierarchyTop As HierarchyReportLevel
  Dim objItem As MPSReportInfo
  Dim eViewType As MPS_VIEW_TYPE
  Dim intIndex As Integer
  Dim objTimeSlice As New UsageIntervalSlice
  Dim i As Integer
  
  On Error GoTo ErrorHandler
  
  intIndex = 0
  
  Set objRenderInfo.YAAC = mobjYAAC
  
  'Determine the report to get
  For i = 1 To mcollReports.Count
    Set objItem = mcollReports(i)
  
    If objItem.Name = ReportList Then
      intIndex = objItem.Index
      Exit For
    End If
  Next
  
  If intIndex = 0 Then
    Call MsgBox("Doh! Index = 0")
    Exit Sub
  End If

  'Write the Report Info
  Call WriteText(vbNewLine & "Report Name: " & objItem.Name)
  Call WriteText(vbNewLine & "Index: " & objItem.Index)
  Call WriteText(vbNewLine & "Description: " & objItem.Description & " [" & objItem.DescriptionType & "]")
  Call WriteText(vbNewLine & "Type: " & objItem.Type)
  Call WriteText(vbNewLine & "View Type: " & objItem.ViewType)
  Call WriteText(vbNewLine & "Restricted: " & objItem.Restricted)
  Call WriteText(vbNewLine & "    Languages              -- " & objItem.RestrictionLanguages)
  Call WriteText(vbNewLine & "    Billable               -- " & objItem.RestrictionBillable)
  Call WriteText(vbNewLine & "    FolderOwner            -- " & objItem.RestrictionFolderOwner)
  Call WriteText(vbNewLine & "    OwnedFolders           -- " & objItem.RestrictionOwnedFolders)
  Call WriteText(vbNewLine & "    BillableOwnedFolders   -- " & objItem.RestrictionBillableOwnedFolders)
  Call WriteText(vbNewLine & "Display Method: " & objItem.DisplayMethod)
  Call WriteText(vbNewLine & "Display Data: " & objItem.DisplayData)
  Call WriteText(vbNewLine & "Override: " & objItem.AccountIDOverride)
  
  'Determine view type
  If ReportView(0).Value Then
    eViewType = VIEW_TYPE_BY_FOLDER
  Else
    eViewType = VIEW_TYPE_BY_PRODUCT
  End If
  
  
  objTimeSlice.IntervalID = 23006
  Set objRenderInfo.TimeSlice = objTimeSlice
  objRenderInfo.ViewType = eViewType
    
  Set objHierarchyTop = mobjReportManager.GetReportTopLevel(intIndex, objRenderInfo)
  
  'Call WriteText(objHierarchyTop.GetReportLevelAsXML(False))
  
  Call WriteText(vbNewLine & "<-------------------------------------------------->")
  Call WriteText(vbNewLine & "<-------------- " & ReportList & "----------------->")
  Call WriteText(vbNewLine & "<-------------------------------------------------->")
  Call WriteReport(objHierarchyTop, "0")
  
  
ErrorHandler:
  If Err Then
    WriteText ("GetReportXML::An error occurred -- " & Err.Description & " [" & Err.Source & "]")
  End If
  
End Sub

Private Sub WriteXMLText(ByVal strText As String)
  Dim objConfig As Object
  
  Set objConfig = CreateObject("MTConfigHelper.ConfigHelper")
  
  Call WriteText(objConfig.PrettyPrintXMLFile(strText, 2, 0, True))

End Sub

Private Sub WriteText(ByVal strText As String)
  Text1.Text = Text1.Text & strText
  Text1.SelStart = Len(Text1.Text) - 1
  Text1.SelLength = 1
End Sub



Private Sub ReportList_Click()
  Dim objItem As MPSReportInfo
  
  'Enable and disable buttons
  For Each objItem In mcollReports
    
    If objItem.Name = ReportList Then
      If objItem.ViewType = VIEW_TYPE_BY_FOLDER Then
        ReportView(0).Enabled = True
        ReportView(0).SetFocus
        ReportView(1).Enabled = False
        
      ElseIf objItem.ViewType = VIEW_TYPE_BY_PRODUCT Then
        ReportView(0).Enabled = False
        ReportView(1).SetFocus
        ReportView(1).Enabled = True
      
      Else
        ReportView(0).Enabled = True
        ReportView(1).Enabled = True
      
      End If
    End If
  Next
End Sub
