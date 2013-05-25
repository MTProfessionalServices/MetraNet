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
   Begin VB.CommandButton Command1 
      Caption         =   "Command1"
      Height          =   1215
      Left            =   1320
      TabIndex        =   0
      Top             =   600
      Width           =   1575
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private Sub Command1_Click()

    Dim objFailTransaction As New MSIXHandler
    Dim objTextFile        As New cTextFile
    Dim strXML             As String
    
    'strXML = objTextFile.LoadFile(App.Path & "\XML In\AddCharge.Error.msix.xml")
    strXML = objTextFile.LoadFile(App.Path & "\XML In\AudioConfCall.Connection.Feature.msix.xml")
    
    objFailTransaction.XML = strXML
    
    objTextFile.LogFile Environ("TEMP") & "\MTMSIX.XML", objFailTransaction.XML, True
    
    Dim objChildrenType As MSIXHandlerType
    
    For Each objChildrenType In objFailTransaction.SessionChildrenTypes
    
        Debug.Print objChildrenType.Name & " "; objChildrenType.Children.Count
    Next
    
    MsgBox objFailTransaction.SessionChildrenTypes("metratech.com/audioConfConnection").Children.UpdateProperty("payer", "Fred", "=", "kevin") = 2
    
    MsgBox objFailTransaction.GetChildrenAsRowset("metratech.com/audioConfConnection").RecordCount
    
End Sub

