VERSION 5.00
Begin VB.Form Form1 
   Caption         =   "Form1"
   ClientHeight    =   2670
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   6870
   LinkTopic       =   "Form1"
   ScaleHeight     =   2670
   ScaleWidth      =   6870
   StartUpPosition =   1  'CenterOwner
   Begin VB.CommandButton Command2 
      Caption         =   "BUG"
      Height          =   735
      Left            =   2760
      TabIndex        =   1
      Top             =   1800
      Width           =   2775
   End
   Begin VB.CommandButton Command1 
      Caption         =   "Command1"
      Height          =   735
      Left            =   360
      TabIndex        =   0
      Top             =   240
      Width           =   2775
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit


Private Sub Command1_Click()
    Dim objMTYAC As New MTYAAC.YAAC
    Dim objAccountTemplate As MTAccountTemplate
    Dim objSecurityContext As New MTSecurityContext
    Dim objLoginContext As New MTLoginContext
    Dim objMSIXAccountTemplate As New MSIXAccountTemplate



Debug.Assert 0
    Set objSecurityContext = objLoginContext.Login("su", "csr", "csr123").SecurityContext

    ' Subscriber account id, CSR Security COntext
    objMTYAC.InitAsSecuredResource 123, objSecurityContext
    objMSIXAccountTemplate.Initialize objMTYAC.AccountTemplate
    objMSIXAccountTemplate.LoadMSIXHandler "metratech.com\accountcreation.msixdef"
    objMSIXAccountTemplate.Load
    objMSIXAccountTemplate.Properties("Address1").Value = Now()
    objMSIXAccountTemplate.Save
    

    
End Sub

Private Sub Command2_Click()
    
    
    Dim objAccountTemplateProperties As New MTAccountTemplateProperties
    Dim objAccountTemplateProperty As MTAccountTemplateProperty
    
    Debug.Assert 0
    Set objAccountTemplateProperty = objAccountTemplateProperties.Add("NAME", "VALUE")
End Sub
