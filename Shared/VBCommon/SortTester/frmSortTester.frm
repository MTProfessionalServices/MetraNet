VERSION 5.00
Begin VB.Form frmSortTester 
   Caption         =   "Form1"
   ClientHeight    =   11970
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   9375
   LinkTopic       =   "Form1"
   ScaleHeight     =   11970
   ScaleWidth      =   9375
   StartUpPosition =   3  'Windows Default
   Begin VB.CheckBox ckbQuick2 
      Caption         =   "Case sensitive/Variant Quick Sort"
      Height          =   255
      Left            =   1560
      TabIndex        =   24
      Top             =   1800
      Width           =   2775
   End
   Begin VB.ListBox lstResults 
      Height          =   3765
      Index           =   2
      Left            =   3240
      TabIndex        =   22
      Top             =   3960
      Width           =   2895
   End
   Begin VB.ListBox lstResults 
      Height          =   3765
      Index           =   5
      Left            =   6240
      TabIndex        =   20
      Top             =   8160
      Width           =   2895
   End
   Begin VB.CheckBox ckbSelect2 
      Caption         =   "Case sensitive/Variant Select Sort"
      Height          =   255
      Left            =   1560
      TabIndex        =   19
      Top             =   1440
      Width           =   2775
   End
   Begin VB.CheckBox ckbBubble2 
      Caption         =   "Case sensitive/Variant Bubble Sort"
      Height          =   255
      Left            =   1560
      TabIndex        =   18
      Top             =   1080
      Width           =   2775
   End
   Begin VB.ListBox lstResults 
      Height          =   3765
      Index           =   4
      Left            =   6240
      TabIndex        =   16
      Top             =   3960
      Width           =   2895
   End
   Begin VB.ListBox lstResults 
      Height          =   3765
      Index           =   3
      Left            =   3240
      TabIndex        =   15
      Top             =   8160
      Width           =   2895
   End
   Begin VB.ListBox lstResults 
      Height          =   3765
      Index           =   1
      Left            =   120
      TabIndex        =   13
      Top             =   8160
      Width           =   2895
   End
   Begin VB.ListBox lstResults 
      Height          =   3765
      Index           =   0
      Left            =   120
      TabIndex        =   12
      Top             =   3960
      Width           =   2895
   End
   Begin VB.ListBox lstPreSorted 
      Height          =   2790
      Left            =   4440
      TabIndex        =   9
      Top             =   480
      Width           =   4695
   End
   Begin VB.CheckBox ckbQuick 
      Caption         =   "Quick Sort"
      Height          =   255
      Left            =   120
      TabIndex        =   7
      Top             =   1800
      Width           =   1335
   End
   Begin VB.CheckBox ckbSelect 
      Caption         =   "Select Sort"
      Height          =   255
      Left            =   120
      TabIndex        =   6
      Top             =   1440
      Width           =   1335
   End
   Begin VB.CheckBox ckbBubble 
      Caption         =   "Bubble Sort"
      Height          =   255
      Left            =   120
      TabIndex        =   5
      Top             =   1080
      Width           =   1335
   End
   Begin VB.ComboBox cmbType 
      Height          =   315
      ItemData        =   "frmSortTester.frx":0000
      Left            =   1920
      List            =   "frmSortTester.frx":000D
      Style           =   2  'Dropdown List
      TabIndex        =   4
      Top             =   600
      Width           =   1215
   End
   Begin VB.CommandButton cmdSpeedTest 
      Caption         =   "Start Test"
      Height          =   375
      Left            =   720
      TabIndex        =   1
      Top             =   2280
      Width           =   1455
   End
   Begin VB.TextBox txtNumberOfElements 
      Height          =   285
      Left            =   2400
      TabIndex        =   0
      Text            =   "1000"
      Top             =   240
      Width           =   735
   End
   Begin VB.Label lblSortTimeReport 
      Height          =   255
      Index           =   2
      Left            =   3240
      TabIndex        =   23
      Top             =   3600
      Width           =   2775
   End
   Begin VB.Label lblSortTimeReport 
      Height          =   255
      Index           =   5
      Left            =   6240
      TabIndex        =   21
      Top             =   7920
      Width           =   2775
   End
   Begin VB.Label lblSortTimeReport 
      Height          =   255
      Index           =   4
      Left            =   6240
      TabIndex        =   17
      Top             =   3600
      Width           =   2775
   End
   Begin VB.Label lblSortTimeReport 
      Height          =   255
      Index           =   3
      Left            =   3240
      TabIndex        =   14
      Top             =   7920
      Width           =   2775
   End
   Begin VB.Label lblSortTimeReport 
      Height          =   255
      Index           =   1
      Left            =   120
      TabIndex        =   11
      Top             =   7920
      Width           =   2775
   End
   Begin VB.Label lblSortTimeReport 
      Height          =   255
      Index           =   0
      Left            =   120
      TabIndex        =   10
      Top             =   3600
      Width           =   2775
   End
   Begin VB.Label Label2 
      Caption         =   "Pre-Sorted Elements"
      Height          =   255
      Left            =   4560
      TabIndex        =   8
      Top             =   120
      Width           =   1575
   End
   Begin VB.Label Label1 
      Caption         =   "Type of Elements"
      Height          =   255
      Left            =   120
      TabIndex        =   3
      Top             =   600
      Width           =   1575
   End
   Begin VB.Label Label3 
      Caption         =   "Number of Random Elements:"
      Height          =   255
      Left            =   120
      TabIndex        =   2
      Top             =   240
      Width           =   2175
   End
End
Attribute VB_Name = "frmSortTester"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Const BUBBLE1_INDEX = 0
Const BUBBLE2_INDEX = 1
Const SELECT1_INDEX = 2
Const SELECT2_INDEX = 3
Const QUICK1_INDEX = 4
Const QUICK2_INDEX = 5

Const NUM_SORTS = 5


Private Declare Function GetTickCount Lib "kernel32" () As Long


Private Sub cmdSpeedTest_Click()

    Dim lMyArray
    Dim i As Long
    Dim lngArraySize As Long
    
    Dim lngStartTime    As Long
    Dim lngEndTime      As Long
    
    
    Dim varrLng() As Long
    Dim varrDbl() As Double
    Dim varrStr() As String
    Dim varrTemp
    
    
    
    lngArraySize = CLng(txtNumberOfElements) - 1
    Randomize
    lstPreSorted.Clear
    
    For i = 0 To NUM_SORTS
        lstResults(i).Clear
        lblSortTimeReport(i).Caption = ""
    Next
    
    
    Select Case cmbType
        Case "String"
            ReDim lMyArray(0 To lngArraySize) As String
            For i = 0 To lngArraySize
                lMyArray(i) = CreateRandomString
            Next
            
        Case "Long"
            ReDim lMyArray(0 To lngArraySize) As Long
            For i = 0 To lngArraySize
                lMyArray(i) = CLng(Rnd * 10000)
            Next
            
        Case "Double"
            ReDim lMyArray(0 To lngArraySize) As Double
            For i = 0 To lngArraySize
                lMyArray(i) = Rnd
            Next
            
        Case Else
            MsgBox "invalid data type"
            Exit Sub
    End Select
    
    For i = 0 To lngArraySize
        lstPreSorted.AddItem lMyArray(i)
    Next
    
    DoEvents
        
    
    
    If ckbBubble Then
    
        Select Case cmbType
            Case "String"
                ReDim varrStr(0 To lngArraySize) As String
                varrStr = lMyArray
                lngStartTime = GetTickCount
                Call BubbleSortString(varrStr)
                lngEndTime = GetTickCount
                
            Case "Long"
                ReDim varrLng(0 To lngArraySize) As Long
                varrLng = lMyArray
                lngStartTime = GetTickCount
                Call BubbleSortLong(varrLng)
                lngEndTime = GetTickCount
                
            Case "Double"
                ReDim varrDbl(0 To lngArraySize) As Double
                varrDbl = lMyArray
                lngStartTime = GetTickCount
                Call BubbleSortDouble(varrDbl)
                lngEndTime = GetTickCount
        End Select
        
        lblSortTimeReport(BUBBLE1_INDEX).Caption = "Bubble Sort Time: " & lngEndTime - lngStartTime
         Select Case cmbType
            Case "String"
                varrTemp = varrStr
            Case "Long"
                varrTemp = varrLng
            Case "Double"
                varrTemp = varrDbl
        End Select
        
        For i = 0 To lngArraySize
            lstResults(BUBBLE1_INDEX).AddItem varrTemp(i)
        Next
        DoEvents
        
    End If
    
    
    If ckbBubble2 Then
    
        Select Case cmbType
            Case "String"
                ReDim varrStr(0 To lngArraySize) As String
                varrStr = lMyArray
                lngStartTime = GetTickCount
                Call BubbleSortString(varrStr, False)
                lngEndTime = GetTickCount

            Case "Long"
                ReDim varrLng(0 To lngArraySize) As Long
                varrLng = lMyArray
                lngStartTime = GetTickCount
                Call BubbleSortVariant(varrLng)
                lngEndTime = GetTickCount

            Case "Double"
                ReDim varrDbl(0 To lngArraySize) As Double
                varrDbl = lMyArray
                lngStartTime = GetTickCount
                Call BubbleSortVariant(varrDbl)
                lngEndTime = GetTickCount
        End Select
        
        lblSortTimeReport(BUBBLE2_INDEX).Caption = "Bubble Sort Time: " & lngEndTime - lngStartTime
         Select Case cmbType
            Case "String"
                varrTemp = varrStr
            Case "Long"
                varrTemp = varrLng
            Case "Double"
                varrTemp = varrDbl
        End Select
        
        For i = 0 To lngArraySize
            lstResults(BUBBLE2_INDEX).AddItem varrTemp(i)
        Next
        DoEvents
        
    End If
    
    If ckbSelect Then
    
        Select Case cmbType
            Case "String"
                ReDim varrStr(0 To lngArraySize) As String
                varrStr = lMyArray
                lngStartTime = GetTickCount
                Call SelectSortString(varrStr)
                lngEndTime = GetTickCount
                
            Case "Long"
                ReDim varrLng(0 To lngArraySize) As Long
                varrLng = lMyArray
                lngStartTime = GetTickCount
                Call SelectSortLong(varrLng)
                lngEndTime = GetTickCount
                
            Case "Double"
                ReDim varrDbl(0 To lngArraySize) As Double
                varrDbl = lMyArray
                lngStartTime = GetTickCount
                Call SelectSortDouble(varrDbl)
                lngEndTime = GetTickCount
        End Select
        
        lblSortTimeReport(SELECT1_INDEX).Caption = "Select Sort Time: " & lngEndTime - lngStartTime
         Select Case cmbType
            Case "String"
                varrTemp = varrStr
            Case "Long"
                varrTemp = varrLng
            Case "Double"
                varrTemp = varrDbl
        End Select
        
        For i = 0 To lngArraySize
            lstResults(SELECT1_INDEX).AddItem varrTemp(i)
        Next
        DoEvents
        
    End If

    If ckbSelect2 Then
    
        Select Case cmbType
            Case "String"
                ReDim varrStr(0 To lngArraySize) As String
                varrStr = lMyArray
                lngStartTime = GetTickCount
                Call SelectSortString(varrStr, False)
                lngEndTime = GetTickCount

            Case "Long"
                ReDim varrLng(0 To lngArraySize) As Long
                varrLng = lMyArray
                lngStartTime = GetTickCount
                Call SelectSortVariant(varrLng)
                lngEndTime = GetTickCount

            Case "Double"
                ReDim varrDbl(0 To lngArraySize) As Double
                varrDbl = lMyArray
                lngStartTime = GetTickCount
                Call SelectSortVariant(varrDbl)
                lngEndTime = GetTickCount
        End Select
        
        lblSortTimeReport(SELECT2_INDEX).Caption = "Select Sort Time: " & lngEndTime - lngStartTime
         Select Case cmbType
            Case "String"
                varrTemp = varrStr
            Case "Long"
                varrTemp = varrLng
            Case "Double"
                varrTemp = varrDbl
        End Select
        
        For i = 0 To lngArraySize
            lstResults(SELECT2_INDEX).AddItem varrTemp(i)
        Next
        DoEvents
        
    End If



    If ckbQuick Then
    
        Select Case cmbType
            Case "String"
                ReDim varrStr(0 To lngArraySize) As String
                varrStr = lMyArray
                lngStartTime = GetTickCount
                Call QuickSortString(varrStr)
                lngEndTime = GetTickCount
'
            Case "Long"
                ReDim varrLng(0 To lngArraySize) As Long
                varrLng = lMyArray
                lngStartTime = GetTickCount
                Call QuickSortLong(varrLng)
                lngEndTime = GetTickCount

            Case "Double"
                ReDim varrDbl(0 To lngArraySize) As Double
                varrDbl = lMyArray
                lngStartTime = GetTickCount
                Call QuickSortDouble(varrDbl)
                lngEndTime = GetTickCount
        End Select
        
        lblSortTimeReport(QUICK1_INDEX).Caption = "Quick Sort Time: " & lngEndTime - lngStartTime
         Select Case cmbType
            Case "String"
                varrTemp = varrStr
            Case "Long"
                varrTemp = varrLng
            Case "Double"
                varrTemp = varrDbl
        End Select
        
        For i = 0 To lngArraySize
            lstResults(QUICK1_INDEX).AddItem varrTemp(i)
        Next
        DoEvents
        
    End If



    If ckbQuick2 Then
    
        Select Case cmbType
            Case "String"
                ReDim varrStr(0 To lngArraySize) As String
                varrStr = lMyArray
                lngStartTime = GetTickCount
                Call QuickSortString(varrStr, False)
                lngEndTime = GetTickCount
'
            Case "Long"
                ReDim varrLng(0 To lngArraySize) As Long
                varrLng = lMyArray
                lngStartTime = GetTickCount
                Call QuickSortVariant(varrLng)
                lngEndTime = GetTickCount

            Case "Double"
                ReDim varrDbl(0 To lngArraySize) As Double
                varrDbl = lMyArray
                lngStartTime = GetTickCount
                Call QuickSortVariant(varrDbl)
                lngEndTime = GetTickCount
        End Select
        
        lblSortTimeReport(QUICK2_INDEX).Caption = "Quick Sort Time: " & lngEndTime - lngStartTime
         Select Case cmbType
            Case "String"
                varrTemp = varrStr
            Case "Long"
                varrTemp = varrLng
            Case "Double"
                varrTemp = varrDbl
        End Select
        
        For i = 0 To lngArraySize
            lstResults(QUICK2_INDEX).AddItem varrTemp(i)
        Next
        DoEvents
        
    End If
    
End Sub



   

Private Function CreateRandomString() As String
    Dim intLength   As Long
    Dim i           As Long
    Dim intChar     As Long
    
    intLength = (CLng(Rnd * 100) Mod 15) + 3
    
    CreateRandomString = ""
    
    While i < intLength
        
        intChar = (Rnd * 1000) Mod 128
        If ((intChar >= 65) And (intChar <= 90)) Or _
           ((intChar >= 97) And (intChar <= 122)) Then
           
           i = i + 1
           CreateRandomString = CreateRandomString & Chr$(intChar)
        End If
        
    Wend

End Function


