VERSION 5.00
Begin VB.Form frmGroup 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "* #"
   ClientHeight    =   5025
   ClientLeft      =   1095
   ClientTop       =   1515
   ClientWidth     =   7110
   ClipControls    =   0   'False
   HasDC           =   0   'False
   Icon            =   "group.frx":0000
   MaxButton       =   0   'False
   MinButton       =   0   'False
   NegotiateMenus  =   0   'False
   ScaleHeight     =   5025
   ScaleWidth      =   7110
   ShowInTaskbar   =   0   'False
   StartUpPosition =   2  'CenterScreen
   Begin VB.TextBox txtmessage 
      BackColor       =   &H80000000&
      Height          =   2295
      Left            =   2940
      MultiLine       =   -1  'True
      TabIndex        =   9
      Top             =   120
      Width           =   4035
   End
   Begin VB.CommandButton cmdExit 
      Caption         =   "Cancel"
      Height          =   375
      Left            =   5580
      TabIndex        =   8
      Top             =   4560
      Width           =   1395
   End
   Begin VB.CommandButton cmdOK 
      Caption         =   "&Next >"
      Height          =   375
      Left            =   4140
      TabIndex        =   7
      Top             =   4560
      Width           =   1395
   End
   Begin VB.PictureBox Picture1 
      AutoSize        =   -1  'True
      BorderStyle     =   0  'None
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   2505
      Left            =   60
      Picture         =   "group.frx":0442
      ScaleHeight     =   2505
      ScaleWidth      =   2790
      TabIndex        =   6
      Top             =   120
      Width           =   2790
   End
   Begin VB.DirListBox dir95Groups 
      Height          =   765
      Left            =   7380
      TabIndex        =   4
      Top             =   3600
      Visible         =   0   'False
      Width           =   3810
   End
   Begin VB.ListBox lstGroups 
      Height          =   1035
      ItemData        =   "group.frx":2FA1
      Left            =   3000
      List            =   "group.frx":2FA8
      Sorted          =   -1  'True
      TabIndex        =   1
      Top             =   3240
      Width           =   3240
   End
   Begin VB.TextBox txtGroup 
      Height          =   300
      Left            =   3000
      MaxLength       =   128
      TabIndex        =   0
      Text            =   "*"
      Top             =   2880
      Width           =   3240
   End
   Begin VB.Label lblDDE 
      Height          =   225
      Left            =   7620
      TabIndex        =   5
      Top             =   3000
      Visible         =   0   'False
      Width           =   705
   End
   Begin VB.Label lblGroups 
      AutoSize        =   -1  'True
      Caption         =   "#"
      Height          =   195
      Left            =   1020
      TabIndex        =   3
      Top             =   3360
      Width           =   105
   End
   Begin VB.Label lblGroup 
      AutoSize        =   -1  'True
      Caption         =   "#"
      Height          =   195
      Left            =   1020
      TabIndex        =   2
      Top             =   2850
      Width           =   105
   End
End
Attribute VB_Name = "frmGroup"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private mstrGroup As String
Private mstrDefGroup As String
Private mstrProgramsPath As String
Private mfrm As Form
Private mfPrivate As Boolean
Private mfStartMenu As Boolean

Private Sub cmdExit_Click()
    ExitSetup frmGroup, gintRET_EXIT
End Sub

Private Sub cmdOK_Click()
    mstrGroup = txtGroup.Text
    If Not fCreateProgGroup() Then
        '
        ' Couldn't create the group. Let
        ' the user try again.
        '
        txtGroup.SetFocus
    Else
        '
        ' The group got created ok, so unload Choose Program Group dialog
        ' and continue on with setup.
        '
        Unload Me
    End If
End Sub
Private Function fCreateProgGroup() As Boolean
'
' Create a program group.
'
    Dim strMsg As String

    If Not fValidFilename(mstrGroup) Then
        strMsg = ResolveResString(resGROUPINVALIDGROUPNAME, gstrPIPE1, CStr(gintMAX_PATH_LEN), gstrPIPE2, ResolveResString(resCOMMON_INVALIDFILECHARS))
        MsgFunc strMsg, vbOKOnly Or vbQuestion, gstrTitle
        Exit Function
    End If
    '
    'Go ahead and create the main program group
    '
    If Not fCreateShellGroup(mstrGroup, True, , mfPrivate, mfStartMenu) Then
        Exit Function
    End If
    
    fCreateProgGroup = True
End Function


Private Sub Form_Load()
    '
    ' Initialize localized control properties.
    '
    SetFormFont Me
    Caption = ResolveResString(resGROUPFRM, gstrPIPE1, gstrAppName)
    
    lblGroup.Caption = ResolveResString(resGROUPLBLGROUP)
    lblGroups.Caption = ResolveResString(resGROUPLBLGROUPS)
    
    
    '
    ' Initialize the Program Group text box with the
    ' title of the application.
    '
    txtGroup.Text = gstrTitle
    '
    ' Load the ListBox with the program manager groups.
    '
    LoadW95Groups
    '
    ' Initialize the Program Group textbox with the
    ' default group selected in the list box.
    '
    lstGroups_Click

    SetObjectsPos Me, ResolveResString(resGROUPLBLMAIN)
End Sub

Private Sub Form_Paint()
    Draw3DLine Me
End Sub

Private Sub lstGroups_Click()
    txtGroup.Text = lstGroups.Text
End Sub

Private Sub txtGroup_Change()
    cmdOK.Enabled = Len(Trim$(txtGroup.Text)) > 0
End Sub
Private Sub LoadW95Groups()
'
' This routine uses the system registry to
' retrieve a list of all the subfolders in the
' \windows\start menu\programs folder.
'
    Dim strFolder As String
    Dim iFolder As Integer

    mstrProgramsPath = strGetProgramsFilesPath()
    strFolder = Dir$(mstrProgramsPath, vbDirectory)   ' Retrieve the first entry.
    lstGroups.Clear
    Do While Len(strFolder) > 0
        '
        ' Ignore the current directory and the encompassing directory.
        '
        If strFolder <> "." Then
            If strFolder <> ".." Then
                '
                ' Verify that we actually got a directory and not a file.
                '
                If DirExists(mstrProgramsPath & strFolder) Then
                    '
                    ' We got a directory, add it to the list.
                    '
                    lstGroups.AddItem strFolder
                End If
            End If
        End If
        '
        ' Get the next subfolder in the Programs folder
        '
        strFolder = Dir$
    Loop
    '
    ' The lstGroups listbox now contains a listing of all the Programs
    ' subfolders (the groups).
    '
    ' Look for the default folder in the list and select it.  If it's
    ' not there, add it.
    '
    iFolder = SendMessageString(lstGroups.hWnd, LB_FINDSTRINGEXACT, -1, mstrDefGroup)
    If iFolder = LB_ERR Then
        '
        ' The group doesn't yet exist, add it to the list.
        '
        lstGroups.AddItem mstrDefGroup
        lstGroups.ListIndex = lstGroups.NewIndex
    Else
        lstGroups.ListIndex = iFolder
    End If
End Sub
Public Property Get GroupName(frm As Form, strDefGroup As String, Optional fPriv As Boolean = True, Optional ByVal fStart As Boolean = False) As String
    mstrDefGroup = strDefGroup
    Set mfrm = frm

    mfPrivate = fPriv
    mfStartMenu = fStart
    If gfNoUserInput Then
        mstrGroup = mstrDefGroup
        If Not fCreateProgGroup() Then
            ExitSetup frmSetup1, gintRET_FATAL
        End If
    Else
        Show vbModal
    End If
    GroupName = mstrGroup
End Property

Private Sub txtGroup_GotFocus()
    txtGroup.SelStart = 0
    txtGroup.SelLength = Len(txtGroup.Text)
End Sub
