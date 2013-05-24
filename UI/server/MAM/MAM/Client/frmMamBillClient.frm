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
      Height          =   735
      Left            =   2280
      TabIndex        =   0
      Top             =   1080
      Width           =   2175
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private Sub Command1_Click()

    Dim mambill As New CMAMSubscriberBill
    
    Dim Factory, loginObj, myCTX, aYaac
    
'    Debug.Assert 0
    
    Set Factory = CreateObject("MetraTech.MTAccountCatalog")
  Set loginObj = CreateObject("MetraTech.MTLoginContext")
  Set myCTX = loginObj.login("su", "system_user", "su123")

  Factory.Init myCTX

  Set aYaac = Factory.GetAccount(156)
    
    Dim cr As Object
    
    mambill.Initialize aYaac
    mambill.LoadSummary
    mambill.LoadProductViewData ""
    
    Set cr = mambill.GetChildrenTYPESDetailAsRowSet()
    Set cr = mambill.GetChildrenDetailAsRowSet(cr, "metratech.com/audioconfconcall")
    
    DumpRowSet cr

End Sub

Public Function DumpRowSet(r) As Boolean
    Dim i As Long
    r.MoveFirst
    
    For i = 0 To r.Count - 1
        Debug.Print r.Name(CLng(i)) & ",";
    Next
    Debug.Print ""
    
    Do While Not r.EOF
    
        For i = 0 To r.Count - 1
            Debug.Print r.Value(CLng(i)) & ",";
        Next
        Debug.Print ""
        r.MoveNext
    Loop

End Function
