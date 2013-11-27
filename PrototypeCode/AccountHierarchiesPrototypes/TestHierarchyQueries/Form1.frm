VERSION 5.00
Begin VB.Form Form1 
   BackColor       =   &H00808080&
   Caption         =   "Form1"
   ClientHeight    =   9165
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   12240
   LinkTopic       =   "Form1"
   ScaleHeight     =   9165
   ScaleWidth      =   12240
   StartUpPosition =   3  'Windows Default
   Begin VB.CommandButton Command6 
      Caption         =   "Create Hierarchy From XML File:"
      Height          =   495
      Left            =   8640
      TabIndex        =   24
      Top             =   7680
      Width           =   3255
   End
   Begin VB.TextBox filename 
      Height          =   375
      Left            =   8640
      TabIndex        =   23
      Text            =   "C:\Development\AccountHierarchies\prototypes\TestHierarchyQueries\OmniDesk.xml"
      Top             =   8280
      Width           =   3255
   End
   Begin VB.CommandButton ORGCHART 
      Caption         =   "Create MetraTech Org Chart!"
      Height          =   495
      Left            =   8880
      TabIndex        =   22
      Top             =   120
      Width           =   3255
   End
   Begin VB.TextBox Text8 
      Height          =   375
      Left            =   3120
      TabIndex        =   18
      Top             =   8400
      Width           =   1455
   End
   Begin VB.TextBox Text7 
      Height          =   375
      Left            =   1680
      TabIndex        =   17
      Top             =   8400
      Width           =   615
   End
   Begin VB.CommandButton Command5 
      Caption         =   "Generate XML Fragment"
      Height          =   375
      Left            =   4680
      TabIndex        =   16
      Top             =   8400
      Width           =   2055
   End
   Begin VB.TextBox Text6 
      BackColor       =   &H00404040&
      ForeColor       =   &H00C0FFFF&
      Height          =   375
      Left            =   8280
      TabIndex        =   14
      Text            =   "..."
      Top             =   6600
      Width           =   3855
   End
   Begin VB.CommandButton Command4 
      Caption         =   "Move Account"
      Height          =   375
      Left            =   5880
      TabIndex        =   13
      Top             =   7680
      Width           =   1452
   End
   Begin VB.CommandButton Command3 
      Caption         =   "Set Account Hierarchy End Date"
      Height          =   375
      Left            =   3000
      TabIndex        =   12
      Top             =   7680
      Width           =   2655
   End
   Begin VB.CommandButton Clear 
      Caption         =   "Clear"
      Height          =   375
      Left            =   3000
      TabIndex        =   7
      Top             =   240
      Width           =   2415
   End
   Begin VB.CommandButton Command2 
      Caption         =   "Add Account to Hierarchy"
      Height          =   375
      Left            =   240
      TabIndex        =   6
      Top             =   7680
      Width           =   2655
   End
   Begin VB.TextBox Text5 
      Height          =   375
      Left            =   4800
      TabIndex        =   5
      Text            =   "dt_end"
      Top             =   6960
      Width           =   1935
   End
   Begin VB.TextBox Text4 
      Height          =   375
      Left            =   2640
      TabIndex        =   4
      Text            =   "dt_start"
      Top             =   6960
      Width           =   2055
   End
   Begin VB.TextBox Text3 
      Height          =   375
      Left            =   1320
      TabIndex        =   3
      Text            =   "id_descendent"
      Top             =   6960
      Width           =   1215
   End
   Begin VB.TextBox Text2 
      Height          =   375
      Left            =   240
      TabIndex        =   2
      Text            =   "id_ancestor"
      Top             =   6960
      Width           =   975
   End
   Begin VB.TextBox Text1 
      BackColor       =   &H00404040&
      BeginProperty Font 
         Name            =   "Courier New"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00C0FFFF&
      Height          =   5775
      Left            =   240
      MultiLine       =   -1  'True
      ScrollBars      =   2  'Vertical
      TabIndex        =   1
      Top             =   720
      Width           =   11892
   End
   Begin VB.CommandButton Command1 
      Caption         =   "Get t_account_ancestor"
      Height          =   375
      Left            =   360
      TabIndex        =   0
      Top             =   240
      Width           =   2415
   End
   Begin VB.Frame Frame1 
      BackColor       =   &H00808080&
      Height          =   852
      Left            =   240
      TabIndex        =   19
      Top             =   8160
      Width           =   6612
      Begin VB.Label Label9 
         Alignment       =   1  'Right Justify
         BackColor       =   &H00808080&
         Caption         =   "Time"
         Height          =   252
         Left            =   2280
         TabIndex        =   21
         Top             =   360
         Width           =   492
      End
      Begin VB.Label Label11 
         Alignment       =   1  'Right Justify
         BackColor       =   &H00808080&
         Caption         =   "Account ID"
         Height          =   255
         Left            =   480
         TabIndex        =   20
         Top             =   360
         Width           =   855
      End
   End
   Begin VB.Label Label5 
      Alignment       =   1  'Right Justify
      BackColor       =   &H00808080&
      Caption         =   "Status"
      Height          =   252
      Left            =   7440
      TabIndex        =   15
      Top             =   6720
      Width           =   732
   End
   Begin VB.Label Label4 
      BackColor       =   &H00808080&
      Caption         =   "dt_end"
      Height          =   255
      Left            =   4800
      TabIndex        =   11
      Top             =   6720
      Width           =   615
   End
   Begin VB.Label Label3 
      BackColor       =   &H00808080&
      Caption         =   "dt_start"
      Height          =   255
      Left            =   2640
      TabIndex        =   10
      Top             =   6720
      Width           =   615
   End
   Begin VB.Label Label2 
      BackColor       =   &H00808080&
      Caption         =   "id_descendent"
      Height          =   255
      Left            =   1320
      TabIndex        =   9
      Top             =   6720
      Width           =   1095
   End
   Begin VB.Label Label1 
      BackColor       =   &H00808080&
      Caption         =   "id_ancestor"
      Height          =   255
      Left            =   240
      TabIndex        =   8
      Top             =   6720
      Width           =   975
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

'Function to scroll virtually any box that has this capability:
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function ScrollText(MyControl As Control, vLines As Integer) As Long
       Dim Success As Long
       Dim SavedWnd As Long
       Dim R As Long
       Dim Lines As Double
       Const EM_LINESCROLL = &HB6
       ' Get the window handle of the control that currently has the focus
       SavedWnd = Screen.ActiveControl.hwnd
       Lines = vLines
       ' Set the focus to the passed control.
       MyControl.SetFocus
       ' Scroll the lines.
       Success = SendMessage(MyControl.hwnd, EM_LINESCROLL, 0, Lines)
       ' Restore the focus to the original control.
       R = PutFocus(SavedWnd)
       ' Return the number of lines actually scrolled.
       ScrollText = Success
End Function


'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Print t_account_ancestor table
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Sub Command1_Click()
  Dim rs As New MTSQLRowset
  
  rs.Init "queries\audit"
  rs.SetQueryString "select * from t_account_ancestor"
  rs.Execute
  
    Text1 = Text1 & "id_ancestor" & vbTab
    Text1 = Text1 & "id_descendent" & vbTab
    Text1 = Text1 & "num_generations" & vbTab
    Text1 = Text1 & "vt_start" & vbTab
    Text1 = Text1 & "vt_end" & vbTab & vbTab
    Text1 = Text1 & "b_children" & vbTab & vbNewLine
    
  If rs.EOF Then
    Text1 = "Table is empty..." & vbNewLine
    Exit Sub
  End If
  
  rs.MoveFirst
  While Not rs.EOF
      
    Text1 = Text1 & rs.Value("id_ancestor") & vbTab & vbTab
    Text1 = Text1 & rs.Value("id_descendent") & vbTab & vbTab
    Text1 = Text1 & rs.Value("num_generations") & vbTab & vbTab
    Text1 = Text1 & rs.Value("vt_start") & vbTab
    Text1 = Text1 & rs.Value("vt_end") & vbTab
    Text1 = Text1 & rs.Value("b_children") & vbNewLine
    DoEvents
    rs.MoveNext
  Wend
    Call ScrollText(Text1, 5000)
End Sub

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Add Account to Hierarchy
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Sub Command2_Click()
  Dim t As New cTool
  Dim factory As Object
  Dim LoginObj As Object
  Dim myCTX As Object
  Dim cYAAC As Object
  
  Set factory = CreateObject("MTYAAC.YAACFactory")
  Set LoginObj = CreateObject("MTAuthProto.MTLoginContext")
  Set myCTX = LoginObj.login("su", "csr", "csr123")
  Set cYAAC = factory.CreateActorYAAC(myCTX)
    
  cYAAC.GetAncestorMgr().AddToHierarchy CLng(Text2), CLng(Text3), CDate(Text4), CDate(Text5)
  
  Form1.Text6 = "Added:  " & Text3 & " to " & Text2
  Form1.Text6.Refresh
  DoEvents
End Sub

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Sub Clear_Click()

    Text1 = ""
    Text2 = "0"
    Text3 = "0"
    Text4 = "1/1/1753"
    Text5 = "1/1/9999"
    Text6 = ""
    
End Sub

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Sub Command3_Click()
  Text6 = "not implemented"
End Sub

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Sub Command4_Click()
  Text6 = "not implemented"
End Sub

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Get XML Fragment
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Sub Command5_Click()
  Dim accountID As Integer
  Dim snapShot As Date
  Dim factory As Object
  Dim LoginObj As Object
  Dim myCTX As Object
  Dim cYAAC As Object
  
  Set factory = CreateObject("MTYAAC.YAACFactory")
  Set LoginObj = CreateObject("MTAuthProto.MTLoginContext")
  Set myCTX = LoginObj.login("su", "csr", "csr123")
  
  Set cYAAC = factory.CreateActorYAAC(myCTX)
  
  accountID = Text7
  snapShot = Text8

  Text1 = Text1 & "-------------------------------------------------------------------------" & vbNewLine
  Text1 = Text1 & "XML Fragment for accountID " & accountID & " at " & snapShot & vbNewLine
  Text1 = Text1 & "-------------------------------------------------------------------------" & vbNewLine & vbNewLine
  Text1 = Text1 & cYAAC.GetAncestorMgr().HierarchySlice(CLng(accountID), CDate(snapShot)).GetChildListXML.xml & vbNewLine & vbNewLine
  Text1 = Text1 & "-------------------------------------------------------------------------" & vbNewLine
  
  Text6 = "Got XML Fragment for: " & accountID & " at: " & snapShot
End Sub

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Sub Command6_Click()
  Dim objXML As New DOMDocument30                 'XML document object
  Dim objXMLHierarchyNode As IXMLDOMNode
  Dim objXMLCorporate As IXMLDOMNode
  
  'Load the template XML
  objXML.Load filename & ""
  
  'Make sure the file was loaded
  If objXML.parseError Then
    Text6 = "error loading file " & filename
    Exit Sub
  End If

  'Load the templates
  Set objXMLHierarchyNode = objXML.selectSingleNode("/xmlconfig/hierarchy")
  
  ' Add Corporate
  Set objXMLCorporate = objXMLHierarchyNode.selectSingleNode("corporate")
  AddAccountByName objXMLCorporate.Text, "1"
  RecurseHierarchy objXMLHierarchyNode, objXMLCorporate.Text
  
  Text6 = "done."
End Sub

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Sub RecurseHierarchy(objXMLHierarchy As IXMLDOMNode, parent As String)
  Dim objXML As New DOMDocument30                 'XML document object
  Dim objXMLNodeList As IXMLDOMNodeList           'List of matching nodes
  Dim objXMLNode As IXMLDOMNode                   'Used to iterate through list
  Dim objXMLHierarchyNode As IXMLDOMNode          'Used to iterate through list
  Dim objXMLNewHierarhylist As IXMLDOMNodeList
  
  Set objXMLNodeList = objXMLHierarchy.selectNodes("node")
  
  For Each objXMLNode In objXMLNodeList
     Text1 = Text1 & objXMLNode.Text & " --> " & parent & vbNewLine
     AddAccountByName objXMLNode.Text, parent
     DoEvents
     
     ' if next node is a hierachy go for it
     If Not objXMLNode.nextSibling Is Nothing Then
       If objXMLNode.nextSibling.nodeName = "hierarchy" Then
         ' recurse
         Call RecurseHierarchy(objXMLNode.nextSibling, objXMLNode.Text)
       End If
     End If
  Next
 
End Sub

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Generate Org Chart
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Sub ORGCHART_Click()
  
  AddAccountByName "MetraTech", "1"
    AddAccountByName "Scott", "MetraTech"
   
    AddAccountByName "GnA", "MetraTech"
      AddAccountByName "WSG", "GnA"
        AddAccountByName "Ned", "WSG"
    
      AddAccountByName "HR", "GnA"
        AddAccountByName "Pam", "HR"
        AddAccountByName "DavidZ", "HR"
      
      AddAccountByName "Finance", "GnA"
        AddAccountByName "AmyT", "Finance"
        AddAccountByName "Meredith", "Finance"
        AddAccountByName "Jill", "Finance"
        AddAccountByName "Christine", "Finance"
   
    AddAccountByName "Engineering", "MetraTech"
      
      AddAccountByName "Development", "Engineering"
        
        AddAccountByName "DavidB", "Development"
        
        AddAccountByName "UI", "Development"
          AddAccountByName "Kevin", "UI"
          AddAccountByName "Noah", "UI"
          AddAccountByName "Fred", "UI"
          AddAccountByName "Rudi", "UI"
          AddAccountByName "Fabricio", "UI"
        
        AddAccountByName "Core", "Development"
          AddAccountByName "Boris", "Core"
          AddAccountByName "Carl", "Core"
          AddAccountByName "Derek", "Core"
          AddAccountByName "Travis", "Core"
          AddAccountByName "Ralph", "Core"
          AddAccountByName "Raju", "Core"
          AddAccountByName "Harvinder", "Core"
          AddAccountByName "Ning", "Core"
          
      AddAccountByName "QA", "Engineering"
        AddAccountByName "Amy", "QA"
        AddAccountByName "Regina", "QA"
        AddAccountByName "Tina", "QA"
        AddAccountByName "Anagha", "QA"
        AddAccountByName "David", "QA"
        AddAccountByName "Julia", "QA"
        AddAccountByName "Eduard", "QA"
        AddAccountByName "Pradeep", "QA"
      
      AddAccountByName "Services", "Engineering"
        AddAccountByName "Mario", "Services"
        AddAccountByName "Tarla", "Services"
        AddAccountByName "Sony", "Services"
        AddAccountByName "Nars", "Services"
        AddAccountByName "Matt", "Services"
        AddAccountByName "Henerik", "Services"
        AddAccountByName "Dave", "Services"
        
    AddAccountByName "Sales", "MetraTech"
    
    AddAccountByName "Marketing", "MetraTech"
      AddAccountByName "Jed", "Marketing"
        
        
    Text6 = "done"
  
End Sub
