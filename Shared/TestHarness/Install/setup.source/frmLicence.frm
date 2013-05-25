VERSION 5.00
Begin VB.Form frmLicence 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "License"
   ClientHeight    =   7245
   ClientLeft      =   2760
   ClientTop       =   3750
   ClientWidth     =   9240
   Icon            =   "frmLicence.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   7245
   ScaleWidth      =   9240
   ShowInTaskbar   =   0   'False
   StartUpPosition =   2  'CenterScreen
   Begin VB.ListBox List1 
      Height          =   6690
      Left            =   60
      TabIndex        =   2
      Top             =   60
      Width           =   9135
   End
   Begin VB.CommandButton CancelButton 
      Caption         =   "I Do Not Accept"
      Height          =   375
      Left            =   4560
      TabIndex        =   1
      Top             =   6840
      Width           =   1455
   End
   Begin VB.CommandButton OKButton 
      Caption         =   "I Accept"
      Height          =   375
      Left            =   3120
      TabIndex        =   0
      Top             =   6840
      Width           =   1335
   End
End
Attribute VB_Name = "frmLicence"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Option Explicit

Private Sub CancelButton_Click()
    Unload Me
    #If COMPILE_IN_FLOGVIEWER Then
        frmMdi.CloseApp
    #Else
        End
    #End If
End Sub

Private Sub Form_Load()
    Populate
End Sub

Private Sub OKButton_Click()
    Unload Me
    
End Sub

Public Function Populate()
    AddLine "You must read the following license agreement before installing fLogViewer."
    AddLine "By doing so, you indicate your acceptance of what is written here."
    AddLine ""
    AddLine "fLogViewer version " & App.Major & "." & App.Minor & " (the SOFTWARE) is provided ""as is"" without warranty of any kind, including, but not limited to,"
    AddLine "implied warranties of merchantability or fitness for a particular purpose."
    AddLine "In no event shall the author (Frederic Torres) be liable for any damages to hardware or loss of data whatsoever"
    AddLine "arising out the use of (or inability to use) the SOFTWARE even if advised of the possibility."
    AddLine ""
    AddLine "The SOFTWARE is distributed free of charge (freeware), and as such, you may copy or distribute it freely."
    AddLine "If you wish to distribute it through traditional shareware or freeware (including complilations and magazine cover disks)"
    AddLine "channels, you may not charge a fee for providing the SOFTWARE itself."
    AddLine "You may, however, charge a fee for duplication/media, and a shipping charge."
    AddLine ""
    AddLine "When distributing the SOFTWARE, it should be done so complete and intact, with all required files and documentation."
    AddLine "You may not reverse engineer or decompile the SOFTWARE in any way."
    AddLine ""
    AddLine "Each time you start fLogViewer, the program contacts the fLogViewer WebService and communicate the following information:"
    AddLine ""
    AddLine "           The time, the fLogViewer current version, the number of executions, the country name and the install ID."
    AddLine ""
    AddLine "The WebService returns the following information:"
    AddLine ""
    AddLine "           The last version of fLogViewer available and an optional message."
    AddLine ""
    AddLine "The install ID is a GUID, set at install time, that identifies you as a fLogViewer user."
    AddLine "The Information is not crypted. Check out http://www.flogviewer.com/licence.htm for more information."
    AddLine ""
    AddLine "Installing and using fLogViewer signifies acceptance of these terms and conditions of the license."
    AddLine ""
    AddLine "If you do not agree with the terms of this license you must remove fLogViewer files from your storage devices and cease to use the product."
    AddLine ""
    AddLine "The SOFTWARE is Copyright © 1997-2001 by Frederic Torres."
    AddLine ""
    AddLine "    eMail:        support@ flogviewer.com"
    AddLine "    Web  :        www.flogviewer.com"
    AddLine ""
End Function

Public Sub AddLine(strS As String)
    List1.AddItem strS
End Sub
