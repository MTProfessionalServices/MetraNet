VERSION 5.00
Begin VB.Form Form1 
   Caption         =   "Form1"
   ClientHeight    =   3195
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   4680
   LinkTopic       =   "Form1"
   ScaleHeight     =   3195
   ScaleWidth      =   4680
   StartUpPosition =   3  'Windows Default
   Begin VB.CommandButton Command2 
      Caption         =   "Command1"
      Height          =   615
      Left            =   2760
      TabIndex        =   1
      Top             =   2040
      Width           =   735
   End
   Begin VB.CommandButton Command1 
      Caption         =   "Command1"
      Default         =   -1  'True
      Height          =   1095
      Left            =   1080
      TabIndex        =   0
      Top             =   360
      Width           =   3135
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private m_objSuperUserSessionContext

Private Sub Command1_Click()

    Dim s As New MTMSIX.MSIXHandler
    Dim f As New cTextFile
    On Error GoTo errmgr
    
'    s.Xml = f.LoadFile("S:\Shared\MSIXHandler\Files\CompoundSession.xml")
 '   f.LogFile "S:\Shared\MSIXHandler\Files\C_OutPut.xml", s.Xml, True
 Set s.SessionContext = SuperUserSessionContext
    s.Xml = f.LoadFile("S:\Shared\MSIXHandler\Files\AtomicSession.xml")
    f.LogFile "S:\Shared\MSIXHandler\Files\A_OutPut.xml", s.Xml, True
    MsgBox "+"
    Exit Sub
errmgr:
    MsgBox Err.Number & " " & Err.Description
End Sub

Private Sub Command2_Click()

    Dim objPipeline, objSession, f
    
    Debug.Assert 0
    
    Set f = CreateObject("mtvblib.cTextFile")
    
    Set objPipeline = CreateObject("MetraPipeline.MTPipeline.1")
    
    Set objSession = objPipeline.ExamineSession(f.LoadFile("c:\toto.txt"))
    
    Set objSession = Nothing
    Set objPipeline = Nothing
    Set objPipeline = CreateObject("MetraPipeline.MTPipeline.1")
    
    Set objSession = objPipeline.ExamineSession(f.LoadFile("c:\toto.txt"))
End Sub


  ' ---------------------------------------------------------------------------------------------------------------------------------------
  ' FUNCTION            :
  ' PARAMETERS      :
  ' DESCRIPTION     :
  ' RETURNS           :
  Public Property Get SessionContext()
  
      Set SessionContext = SuperUserSessionContext()
  End Property
  
  ' ---------------------------------------------------------------------------------------------------------------------------------------
  ' FUNCTION            :
  ' PARAMETERS      :
  ' DESCRIPTION     :
  ' RETURNS           :
  Public Property Get SuperUserSessionContext()
  
    If IsEmpty(m_objSuperUserSessionContext) Then Set m_objSuperUserSessionContext = GetSessionContext("su", "su123", "system_user")
    Set SuperUserSessionContext = m_objSuperUserSessionContext
  End Property
  
  ' ---------------------------------------------------------------------------------------------------------------------------------------
  ' FUNCTION            :
  ' PARAMETERS      :
  ' DESCRIPTION     :
  ' RETURNS           :
  Public Function GetSessionContext(strUserName, strPassWord, strNameSpace)
  
      Set GetSessionContext = CreateObject("Metratech.MTLoginContext").Login(strUserName, strNameSpace, strPassWord)
  End Function
