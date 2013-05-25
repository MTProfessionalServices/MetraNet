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
   Begin VB.CommandButton Command3 
      Caption         =   "Gene Source code"
      Height          =   510
      Left            =   1560
      TabIndex        =   2
      Top             =   1560
      Width           =   1815
   End
   Begin VB.CommandButton Command2 
      Caption         =   "Test Source Code"
      Height          =   510
      Left            =   1560
      TabIndex        =   1
      Top             =   2160
      Width           =   1815
   End
   Begin VB.CommandButton Command1 
      Caption         =   "Gene"
      Height          =   510
      Left            =   1560
      TabIndex        =   0
      Top             =   360
      Width           =   1815
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private Sub Command1_Click()

    Dim xmlDoc As New MSXML2.DOMDocument40
    Dim newnode  As IXMLDOMElement
    Dim newtext ' As IXMLDOMElement
    Dim i As Long
    
    'Set xmlDoc = CreateObject("Microsoft.XMLDOM")
    xmlDoc.async = "false"
    xmlDoc.Load ("C:\Temp\MultiByte\WideCharToMultiByte\UTF8.Template.xml")
    If xmlDoc.parseError Then
        MsgBox "error"
        Exit Sub
    End If
    
    Dim UTF8    As New CUTF8
    Dim itm     As IXMLDOMElement
    Dim strXML  As String
    Dim s       As String
    
    
    Set newnode = xmlDoc.createElement("ASCII32To255")
    xmlDoc.documentElement.appendChild newnode
    For i = 128 To 255
        
        s = s + UTF8.GetASCIIString(i)
    Next
    Set newtext = xmlDoc.createTextNode(s)
    newtext.Text = vbNewLine & s
    newnode.appendChild newtext
    
    xmlDoc.save "C:\Temp\MultiByte\WideCharToMultiByte\UTF8.XMLDOM.xml"
    
'    strXML = strXML & "<?xml version=""1.0"" encoding=""UTF-8""?><chars><ASCII32To255>"
'    For i = 128 To 255
'        strXML = strXML & "<ASCII" & i & ">"
'        strXML = strXML & UTF8.GetASCIIString(i)
'        strXML = strXML & "</ASCII" & i & ">"
'    Next
'    strXML = strXML & "</ASCII32To255></chars>"
'
'    Dim t As New cTextFile
'
'    t.LogFile "C:\Temp\MultiByte\WideCharToMultiByte\UTF8.UTF8FX.xml", strXML, True


End Sub

Private Sub Command2_Click()

    Dim i       As Long
    Dim UTF8    As New CUTF8
    Dim t       As New cTextFile
    Dim s       As String
    
    For i = 128 To 255
        
        s = s & UTF8.GetASCIIString(i)
    Next
    s = UTF8.StringToUTF8(s)
    t.LogFile "C:\Temp\MultiByte\WideCharToMultiByte\ref_verif.txt", s, True
        
        MsgBox UTF8.StringToUTF8("Frédèric")
    
End Sub

Private Sub Command3_Click()

    Dim t   As New cTextFile
    Dim s   As String
    Dim v As Variant
    Dim strTableSource As String
    Dim index As Long
    index = 128
    
    t.OpenFile "C:\Temp\MultiByte\WideCharToMultiByte\ref.txt"
    Do While Not t.EOF()
        s = t.ReadLn()
        If Len(s) Then
        
            v = Split(s, "-")
            strTableSource = strTableSource & "UTF8_TABLE(" & v(0) & ")=" & """" & GetASCIForm(v(1)) & """" & vbNewLine
        End If
    Loop
    
    t.CloseFile
    t.LogFile "C:\Temp\MultiByte\WideCharToMultiByte\UTF8_TABLE.BAS", strTableSource, True


End Sub


Private Function GetASCIForm(ByVal str As String) As String
    Dim s As String
    Dim i As Long
    For i = 1 To Len(str)
        s = s & Asc(Mid(str, i, 1)) & "-"
    Next
    GetASCIForm = Mid(s, 1, Len(s) - 1)
End Function
