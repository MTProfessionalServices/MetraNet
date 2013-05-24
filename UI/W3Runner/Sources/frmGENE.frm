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
      Caption         =   "Set Index"
      Height          =   495
      Left            =   120
      TabIndex        =   2
      Top             =   1440
      Width           =   2055
   End
   Begin VB.CommandButton Command2 
      Caption         =   "Call General Event handler"
      Height          =   495
      Left            =   120
      TabIndex        =   1
      Top             =   840
      Width           =   2055
   End
   Begin VB.CommandButton Command1 
      Caption         =   "Declare object"
      Height          =   495
      Left            =   120
      TabIndex        =   0
      Top             =   240
      Width           =   2055
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit


Const MAX_IE_OBJECTS = 128

Private Sub Command1_Click()

    Dim i As Long
    Dim s As String
    
    For i = 0 To MAX_IE_OBJECTS - 1
    
        s = s & PreProcess("Private WithEvents ieObj_HTMLTextAreaElement[I]  As HTMLTextAreaElement", "I", i) & vbNewLine
        s = s & PreProcess("Private WithEvents ieObj_HTMLInputElement[I]     As HTMLInputElement", "I", i) & vbNewLine
        s = s & PreProcess("Private WithEvents ieObj_HTMLSelectElement[I]    As HTMLSelectElement", "I", i) & vbNewLine
        s = s & PreProcess("Private WithEvents ieObj_HTMLButtonElement[I]    As HTMLButtonElement", "I", i) & vbNewLine
        s = s & PreProcess("Private WithEvents ieObj_HTMLAnchorElement[I]    As HTMLAnchorElement", "I", i) & vbNewLine
        s = s & PreProcess("Private WithEvents ieObj_HTMLImg[I]              As HTMLImg", "I", i) & vbNewLine
        s = s & PreProcess("Private WithEvents ieObj_HTMLTableCell[I]        As HTMLTableCell", "I", i) & vbNewLine
        s = s & PreProcess("Private WithEvents ieObj_HTMLDivElement[I]       As HTMLDivElement", "I", i) & vbNewLine
    Next
    Clipboard.Clear
    Clipboard.SetText s
End Sub

Private Sub Command2_Click()

    Dim i As Long
    Dim s As String
    
    For i = 0 To MAX_IE_OBJECTS - 1
    
        s = s & PreProcess("Private Function ieObj_HTMLInputElement[I]_onclick() As Boolean", "I", i) & vbNewLine
        s = s & PreProcess("  ieObj_HTMLInputElement[I]_onclick = ieObj_EventManager([I], ieObj_HTMLInputElement[I], ""HTMLInputElement"", ""OnClick"")", "I", i) & vbNewLine
        s = s & PreProcess("End Function", "I", i) & vbNewLine
        
        s = s & PreProcess("Private Function ieObj_HTMLSelectElement[I]_onclick() As Boolean", "I", i) & vbNewLine
        s = s & PreProcess("  ieObj_HTMLSelectElement[I]_onclick = ieObj_EventManager([I], ieObj_HTMLSelectElement[I], ""HTMLSelectElement"", ""OnClick"")", "I", i) & vbNewLine
        s = s & PreProcess("End Function", "I", i) & vbNewLine
        
        s = s & PreProcess("Private Function ieObj_HTMLButtonElement[I]_onclick() As Boolean", "I", i) & vbNewLine
        s = s & PreProcess("  ieObj_HTMLButtonElement[I]_onclick = ieObj_EventManager([I], ieObj_HTMLButtonElement[I], ""HTMLButtonElement"", ""OnClick"")", "I", i) & vbNewLine
        s = s & PreProcess("End Function", "I", i) & vbNewLine
    
        s = s & PreProcess("Private Function ieObj_HTMLAnchorElement[I]_onclick() As Boolean", "I", i) & vbNewLine
        s = s & PreProcess("  ieObj_HTMLAnchorElement[I]_onclick = ieObj_EventManager([I], ieObj_HTMLAnchorElement[I], ""HTMLAnchorElement"", ""OnClick"")", "I", i) & vbNewLine
        s = s & PreProcess("End Function", "I", i) & vbNewLine
        
        s = s & PreProcess("Private Function ieObj_HTMLTextAreaElement[I]_onclick() As Boolean", "I", i) & vbNewLine
        s = s & PreProcess("  ieObj_HTMLTextAreaElement[I]_onclick = ieObj_EventManager([I], ieObj_HTMLTextAreaElement[I], ""HTMLTextAreaElement"", ""OnClick"")", "I", i) & vbNewLine
        s = s & PreProcess("End Function", "I", i) & vbNewLine
        
        s = s & PreProcess("Private Function ieObj_HTMLImg[I]_onclick() As Boolean", "I", i) & vbNewLine
        s = s & PreProcess("  ieObj_HTMLImg[I]_onclick = ieObj_EventManager([I], ieObj_HTMLImg[I], ""HTMLImg"", ""OnClick"")", "I", i) & vbNewLine
        s = s & PreProcess("End Function", "I", i) & vbNewLine
        
        s = s & PreProcess("Private Function ieObj_HTMLTableCell[I]_onclick() As Boolean", "I", i) & vbNewLine
        s = s & PreProcess("  ieObj_HTMLTableCell[I]_onclick = ieObj_EventManager([I], ieObj_HTMLTableCell[I], ""HTMLTableCell"", ""OnClick"")", "I", i) & vbNewLine
        s = s & PreProcess("End Function", "I", i) & vbNewLine
        
        s = s & PreProcess("Private Function ieObj_HTMLDivElement[I]_onclick() As Boolean", "I", i) & vbNewLine
        s = s & PreProcess("  ieObj_HTMLDivElement[I]_onclick = ieObj_EventManager([I], ieObj_HTMLDivElement[I], ""HTMLDivElement"", ""OnClick"")", "I", i) & vbNewLine
        s = s & PreProcess("End Function", "I", i) & vbNewLine
        
    Next
    Clipboard.Clear
    Clipboard.SetText s
End Sub

Private Sub Command3_Click()
    Dim i As Long
    Dim s As String
    
    For i = 0 To MAX_IE_OBJECTS - 1
        s = s & PreProcess("Case [I]: Set ieObj_HTMLInputElement[I] = o", "I", i) & vbNewLine
    Next
    s = s & vbNewLine
    
    For i = 0 To MAX_IE_OBJECTS - 1
        s = s & PreProcess("Case [I]: Set ieObj_HTMLSelectElement[I] = o", "I", i) & vbNewLine
    Next
    s = s & vbNewLine
    
    For i = 0 To MAX_IE_OBJECTS - 1
        s = s & PreProcess("Case [I]: Set ieObj_HTMLButtonElement[I] = o", "I", i) & vbNewLine
    Next
    s = s & vbNewLine
    
    For i = 0 To MAX_IE_OBJECTS - 1
        s = s & PreProcess("Case [I]: Set ieObj_HTMLAnchorElement[I] = o", "I", i) & vbNewLine
    Next
    s = s & vbNewLine
    
    For i = 0 To MAX_IE_OBJECTS - 1
        s = s & PreProcess("Case [I]: Set ieObj_HTMLImg[I] = o", "I", i) & vbNewLine
    Next
    s = s & vbNewLine
    
    For i = 0 To MAX_IE_OBJECTS - 1
        s = s & PreProcess("Case [I]: Set ieObj_HTMLTableCell[I] = o", "I", i) & vbNewLine
    Next
    s = s & vbNewLine
    
    For i = 0 To MAX_IE_OBJECTS - 1
        s = s & PreProcess("Case [I]: Set ieObj_HTMLDivElement[I] = o", "I", i) & vbNewLine
    Next
    s = s & vbNewLine
    
    Clipboard.Clear
    Clipboard.SetText s
End Sub

