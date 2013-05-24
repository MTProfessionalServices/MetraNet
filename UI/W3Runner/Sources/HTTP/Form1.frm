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
   Begin VB.CommandButton Command4 
      Caption         =   "GET HEADERS"
      Height          =   375
      Left            =   240
      TabIndex        =   3
      Top             =   1800
      Width           =   3195
   End
   Begin VB.CommandButton Command3 
      Caption         =   "GET JPG"
      Height          =   375
      Left            =   240
      TabIndex        =   2
      Top             =   1320
      Width           =   3195
   End
   Begin VB.CommandButton Command2 
      Caption         =   "POST"
      Height          =   615
      Left            =   2280
      TabIndex        =   1
      Top             =   240
      Width           =   1335
   End
   Begin VB.CommandButton Command1 
      Caption         =   "GET"
      Height          =   615
      Left            =   600
      TabIndex        =   0
      Top             =   240
      Width           =   1335
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub Command1_Click()

    Dim http        As New CHTTP
    Dim varText     As Variant

    If http.Initialize() = CHTTP_ERROR_OK Then
    
   ' If http.Execute("GET", "http://66.31.63.42:81/FredRunner/WebServices/WebService.SendStartInfo.asp", "p=1234", varText) = CHTTP_ERROR_OK Then
    
        varText = "c:\temp\a.jpg"
        If http.Execute("GET", "http://localhost:81/fredrunner/images/FredRunnerLogoSmall.jpg", , varText) = CHTTP_ERROR_OK Then
        'If http.Execute("GET", "http://localhost:81/fredrunner", , varText) = CHTTP_ERROR_OK Then
        
            MsgBox varText
        End If
'
'        If http.Execute("GET", "http://localhost:81/fredrunner", , Environ("temp") & "\CHTTP_TEXT.TXT") = CHTTP_ERROR_OK Then
'            MsgBox "ok"
'        End If
    End If
End Sub

Private Sub Command2_Click()

    Dim http As New CHTTP
    Dim varText As Variant

    If http.Initialize = CHTTP_ERROR_OK Then
    
        If http.Execute("POST", "http://localhost:81/fredrunner/order2.asp", "CompanyName=kikiCorp&firstname=fred&lastname=torres", varText) = CHTTP_ERROR_OK Then
        
            
            Debug.Print varText
        End If
    End If
End Sub

Private Sub Command3_Click()

    Dim http        As New CHTTP
    Dim varText     As Variant

    If http.Initialize() = CHTTP_ERROR_OK Then
        varText = "c:\temp\a.jpg"
        If http.Execute("GET", "http://localhost:81/fredrunner/images/FredRunnerLogoSmall.jpg", , varText) = CHTTP_ERROR_OK Then
            MsgBox varText
        End If
    End If
End Sub

Private Sub Command4_Click()
  Dim http        As New CHTTP
    Dim varHeaders     As Variant

    If http.Initialize() = CHTTP_ERROR_OK Then
        varText = "c:\temp\a.jpg"
        If http.Execute("HEAD", "http://localhost:81/fredrunner/images/FredRunnerLogoSmall.jpg", , , varHeaders) = CHTTP_ERROR_OK Then
            MsgBox varHeaders
        End If
    End If
End Sub
