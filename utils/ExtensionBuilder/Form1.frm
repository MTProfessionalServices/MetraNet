VERSION 5.00
Begin VB.Form ExtensionWizard 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Platform Extension Build Wizard"
   ClientHeight    =   14415
   ClientLeft      =   45
   ClientTop       =   330
   ClientWidth     =   17265
   BeginProperty Font 
      Name            =   "MS Sans Serif"
      Size            =   12
      Charset         =   0
      Weight          =   700
      Underline       =   0   'False
      Italic          =   0   'False
      Strikethrough   =   0   'False
   EndProperty
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   14415
   ScaleWidth      =   17265
   ShowInTaskbar   =   0   'False
   StartUpPosition =   1  'CenterOwner
   Begin VB.Frame BogusLine 
      Height          =   135
      Left            =   120
      TabIndex        =   17
      Top             =   4680
      Width           =   7095
   End
   Begin VB.Frame Frame 
      Caption         =   "Frame1"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   3735
      Index           =   3
      Left            =   7560
      TabIndex        =   14
      Top             =   6240
      Visible         =   0   'False
      Width           =   7095
      Begin VB.CommandButton BuildButton 
         Caption         =   "Build!"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   375
         Left            =   5280
         TabIndex        =   16
         Top             =   3120
         Width           =   1335
      End
      Begin VB.TextBox BuildOutput 
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   2295
         Left            =   120
         MultiLine       =   -1  'True
         ScrollBars      =   2  'Vertical
         TabIndex        =   15
         Text            =   "Form1.frx":0000
         Top             =   480
         Width           =   6495
      End
   End
   Begin VB.Frame Frame 
      Caption         =   "Frame1"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   3735
      Index           =   2
      Left            =   120
      TabIndex        =   10
      Top             =   6240
      Visible         =   0   'False
      Width           =   7095
      Begin VB.TextBox OutputDirTextBox 
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   375
         Left            =   240
         TabIndex        =   12
         Text            =   "Text1"
         Top             =   1080
         Width           =   4095
      End
      Begin VB.CommandButton BrowseForOutputDir 
         Caption         =   "Browse..."
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   420
         Left            =   240
         TabIndex        =   11
         Top             =   1560
         Width           =   1215
      End
      Begin VB.Label Label4 
         Caption         =   "Please enter the location to generate the platform extension installation program."
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   12
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   615
         Left            =   240
         TabIndex        =   13
         Top             =   360
         Width           =   4335
      End
   End
   Begin VB.PictureBox Picture1 
      BorderStyle     =   0  'None
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   615
      Left            =   120
      Picture         =   "Form1.frx":0006
      ScaleHeight     =   615
      ScaleWidth      =   2175
      TabIndex        =   6
      Top             =   120
      Width           =   2175
   End
   Begin VB.Frame Frame 
      Caption         =   "Frame1"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   3735
      Index           =   1
      Left            =   7440
      TabIndex        =   4
      Top             =   720
      Visible         =   0   'False
      Width           =   7095
      Begin VB.CommandButton BrowseForExtension 
         Caption         =   "Browse..."
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   420
         Left            =   240
         TabIndex        =   9
         Top             =   1560
         Width           =   1215
      End
      Begin VB.TextBox ExtensionDirTextBox 
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   375
         Left            =   240
         TabIndex        =   5
         Text            =   "Text1"
         Top             =   1080
         Width           =   4095
      End
      Begin VB.Label Label3 
         Caption         =   "Please enter the location of your platform extension."
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   12
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   615
         Left            =   240
         TabIndex        =   8
         Top             =   360
         Width           =   4335
      End
   End
   Begin VB.Frame Frame 
      Caption         =   "Frame1"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   3735
      Index           =   0
      Left            =   120
      TabIndex        =   2
      Top             =   720
      Width           =   7095
      Begin VB.Label Label1 
         Caption         =   $"Form1.frx":04BC
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   12
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   1935
         Left            =   240
         TabIndex        =   3
         Top             =   360
         Width           =   5415
      End
   End
   Begin VB.CommandButton NextButton 
      Caption         =   "Next"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   6000
      TabIndex        =   1
      Top             =   5040
      Width           =   1215
   End
   Begin VB.CommandButton PreviousButton 
      Caption         =   "Previous"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   4680
      TabIndex        =   0
      Top             =   5040
      Width           =   1215
   End
   Begin VB.Label Label2 
      Caption         =   "Platform Extension Builder"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   12
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   2400
      TabIndex        =   7
      Top             =   240
      Width           =   3135
   End
End
Attribute VB_Name = "ExtensionWizard"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

' *************************************************************************
' Copyright 1997-2000 by MetraTech
' All rights reserved.
'
' THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
' REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
' example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
' WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
' OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
' INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
' RIGHTS.
'
' Title to copyright in this software and any associated
' documentation shall at all times remain with MetraTech, and USER
' agrees to preserve the same.
'
' Created by: Carl Shimer
' $Header$
'
'
'  This is a wizard application for building MetraTech platform extensions
'
'
' *************************************************************************


Private m_lngCurrentForm As Long
Const m_FirstForm As Long = 0
Const m_LastForm As Long = 3
Private mExtensionTools As ExtensionTools.ExtensionBuild




Private Sub BrowseForExtension_Click()
  ExtensionDirTextBox.Text = getBrowseDirectory(0, "Platform Extension directory")
End Sub

Private Sub BrowseForOutputDir_Click()
  OutputDirTextBox.Text = getBrowseDirectory(0, "directory for generated installation program")
End Sub
' --------------------------------------------------------------------------
' Name:     BuildButton_Click
' Effects:       builds the platform extension in the specified output directory
' Return Value:  none
' Description:   Runs the platform extension builder
' Side Effects:  eats disk space.
' --------------------------------------------------------------------------
Private Sub BuildButton_Click()
  ' build extensions
  Dim aFile As String
  Dim aFileObj As New FileSystemObject
  
  BuildOutput.Text = ""
  ExtensionWizard.MousePointer = vbHourglass
  On Error GoTo ErrHandler
  aFile = mExtensionTools.BuildExtension()
  ' read the temporary file
  BuildOutput.Text = aFileObj.GetFile(aFile).OpenAsTextStream.ReadAll
  ExtensionWizard.MousePointer = vbDefault
  ' delete the temporary file
  aFileObj.DeleteFile (aFile)
  Exit Sub
  
ErrHandler:
  ExtensionWizard.MousePointer = vbDefault
  BuildOutput.Text = "Error encountered during build: " & vbNewLine & vbNewLine
  BuildOutput.Text = BuildOutput.Text & Err.Description & vbNewLine
  If aFile <> "" Then
    aFileObj.DeleteFile (aFile)
  End If
  
End Sub

Private Sub PreviousButton_Click()
    ShowForm m_lngCurrentForm - 1
End Sub

Private Sub NextButton_Click()
    ShowForm m_lngCurrentForm + 1
End Sub
' --------------------------------------------------------------------------
' Name:      ShowForm
' Effects:       Changes the form based on the next and previous button
' Arguments:     form number
' Description:   Makes the current frame active in the window.  The effect is a simple wizard
' --------------------------------------------------------------------------
Public Function ShowForm(lngForm As Long)

    ' check upper bounds of form
    If lngForm > m_LastForm Then
      Unload ExtensionWizard
      Exit Function
    End If
    
    ' specific code for each frame.... this probably could
    ' get done in a prettier fashion :)
    If lngForm = 2 Then
      ' verify inputs
      If ExtensionDirTextBox.Text = "" Then
        Call MsgBox("A platform extension directory must be specified", vbOKOnly, "Error")
        Exit Function
      Else
        mExtensionTools.SrcDir = ExtensionDirTextBox.Text
      End If
    
    End If
    If lngForm = 3 Then
      ' verify inputs
      If OutputDirTextBox.Text = "" Then
        Call MsgBox("A output directory must be specified", vbOKOnly, "Error")
        Exit Function
      Else
       mExtensionTools.OutputDir = OutputDirTextBox.Text
      End If
    End If

    ' make the current frame invsible
    Frame(m_lngCurrentForm).Visible = False
    m_lngCurrentForm = lngForm
    
    ' set the window parameters
    Frame(m_lngCurrentForm).Left = Frame(0).Left
    Frame(m_lngCurrentForm).Top = Frame(0).Top
    Frame(m_lngCurrentForm).Width = Frame(0).Width
    Frame(m_lngCurrentForm).Height = Frame(0).Height
    
    ' the new frame is now visable
    Frame(m_lngCurrentForm).Visible = True
    Frame(m_lngCurrentForm).BorderStyle = 0
    
    ' adjust button visability
    If lngForm = m_FirstForm Then
      PreviousButton.Visible = False
    Else
      PreviousButton.Visible = True
    End If
    
    ' adjust "next" button text
    If lngForm = m_LastForm Then
      NextButton.Caption = "Finish"
    Else
      NextButton.Caption = "Next"
    End If
    
    
    
End Function
' --------------------------------------------------------------------------
' Name:      getBrowseDirectory
' Effects:       Opens a browse dialog for a directory
' Arguments:     <hwnd> - window handle
'                <msg> - Message to display on top of windo
' Return Value:  the directory
' Description:     Opens a browse dialog for a directory
' --------------------------------------------------------------------------

Private Function getBrowseDirectory(hwnd As Long, Optional msg As String) As String

  Dim bi          As BROWSEINFO
  Dim IDL         As ITEMIDLIST
  Dim r           As Long
  Dim pidl        As Long
  Dim tmpPath     As String
  Dim pos         As Integer
    
   bi.hOwner = hwnd
   bi.pidlRoot = 0&
   bi.lpszTitle = IIf(msg <> "", msg, "Select the search directory")
   bi.ulFlags = BIF_RETURNONLYFSDIRS
   
  'get the folder
   pidl = SHBrowseForFolder(bi)
   
   tmpPath = Space$(512)
   r = SHGetPathFromIDList(ByVal pidl, ByVal tmpPath)
     
   If r Then
       pos = InStr(tmpPath, Chr$(0))
       tmpPath = Left(tmpPath, pos - 1)
       getBrowseDirectory = tmpPath
   Else
       getBrowseDirectory = ""
   End If
End Function

' --------------------------------------------------------------------------
' Name:      <name of method>
' Effects:       <descibe the effects of the method on ASP state>
' Arguments:     <argument 1> - <argument 1 description>
'                <argument 2> - <argument 2 description>
'                <argument 3> - <Value returned by reference>
' Return Value:  <return value description>
' Description:   <enter detailed description here>
' Side Effects:  <Any modifications to variables in session/global objects>
' --------------------------------------------------------------------------
Private Sub Form_Load()
    Width = 7400
    Height = 6000
    
    ExtensionDirTextBox.Text = ""
    OutputDirTextBox.Text = ""
    BuildOutput.Text = ""
    
    ShowForm (0)
    
    Set mExtensionTools = New ExtensionTools.ExtensionBuild
End Sub
