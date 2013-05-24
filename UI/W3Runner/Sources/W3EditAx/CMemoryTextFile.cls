VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CMemoryTextFile"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Public ScreenLineIndex  As Long
Public CurrentLine      As Long
Public CurrentChar      As Long
Public TabSize          As Long

Public Lines As Collection
Private m_strFileName As String

Public Property Get FileName() As String
    FileName = m_strFileName
End Property

Public Property Let FileName(ByVal vNewValue As String)
    m_strFileName = vNewValue
    Read
End Property

Public Function Read() As Boolean

    Dim objTextFile As New cTextFile
    
    Set Lines = New Collection
    
    If objTextFile.OpenFile(FileName) Then
    
        Do While Not objTextFile.EOF
        
            Lines.Add Replace(objTextFile.ReadLn(), vbTab, Space(TabSize))
        Loop
    End If
    Read = True
End Function

Private Sub Class_Initialize()
    CurrentLine = 1
    CurrentChar = 1
    ScreenLineIndex = 1
    TabSize = AppOptions("TabSize", 2)
End Sub

Public Function GetScreenLine(Optional ByVal lngScreenLineIndex As Long = -1) As String
    
    
    If lngScreenLineIndex = -1 Then
        lngScreenLineIndex = Me.ScreenLineIndex
    End If
    
    If lngScreenLineIndex <= Me.Lines.Count Then
        GetScreenLine = Me.Lines(GetLineIndex(lngScreenLineIndex))
    End If
End Function

Public Function GetLineIndex(Optional ByVal lngScreenLineIndex As Long = -1) As Long
    If lngScreenLineIndex = -1 Then
    
        GetLineIndex = CurrentLine + ScreenLineIndex - 1
    Else
        GetLineIndex = CurrentLine + lngScreenLineIndex - 1
    End If
End Function

Public Function NextLine(lngMaxRow As Long) As Boolean
    If Me.ScreenLineIndex < lngMaxRow Then
        Me.ScreenLineIndex = Me.ScreenLineIndex + 1
    Else
        If ScreenLineIndex + CurrentLine <= Lines.Count Then
            CurrentLine = CurrentLine + 1
        End If
    End If
    InternalCheck
    NextLine = True
End Function


Public Function PreviousLine() As Boolean
    If Me.ScreenLineIndex > 1 Then
    
        Me.ScreenLineIndex = Me.ScreenLineIndex - 1
    Else
    
        CurrentLine = CurrentLine - 1
        If CurrentLine < 1 Then
            CurrentLine = 1
        End If
    End If
    InternalCheck
    PreviousLine = True
End Function


Public Function NextPage(lngPageSize As Long) As Boolean

   If Me.ScreenLineIndex + CurrentLine + lngPageSize - 1 < Lines.Count Then
        CurrentLine = CurrentLine + lngPageSize
    Else
        Me.LastPage lngPageSize
    End If
    InternalCheck
    NextPage = True
End Function

Public Function PreviousPage(lngPageSize As Long) As Boolean
    CurrentLine = CurrentLine - lngPageSize + 1
    If CurrentLine < 1 Then
        CurrentLine = 1
    End If
    InternalCheck
    PreviousPage = True
End Function

Public Function FirstPage() As Boolean
    CurrentLine = 1
    Me.ScreenLineIndex = 1
    FirstPage = True
End Function

Public Function LastPage(lngPageSize As Long) As Boolean
    CurrentLine = Lines.Count - lngPageSize + 1
    Me.ScreenLineIndex = lngPageSize
    InternalCheck
    LastPage = True
End Function




Public Function NextChar() As Boolean
    
    If CurrentChar > Len(GetScreenLine()) Then
        
    Else
        CurrentChar = CurrentChar + 1
        NextChar = True
    End If
    InternalCheck
    
End Function

Public Function PreviousChar() As Boolean
    
    CurrentChar = CurrentChar - 1
    If CurrentChar < 1 Then CurrentChar = 1
    InternalCheck
    PreviousChar = True
End Function

Public Function FirstChar() As Boolean
    
    CurrentChar = 1
    FirstChar = True
End Function


Public Function LastChar() As Boolean
    
    CurrentChar = Len(GetScreenLine()) + 1
    InternalCheck
    LastChar = True
End Function

Private Function InternalCheck() As Boolean

    If CurrentChar > Len(Me.GetScreenLine()) + 1 Then
        CurrentChar = Len(Me.GetScreenLine()) + 1
    End If
End Function

Public Function DeleteChar() As Boolean
    Dim strPart1        As String
    Dim strPart2        As String
    Dim strCurrentLine  As String
    If Len(Me.GetScreenLine()) = 0 Then
        DeleteChar = DeleteCurrentLine()
    Else
        strCurrentLine = Me.GetScreenLine()
    
        If Me.CurrentChar - 1 > 0 Then
    
            strPart1 = Mid(strCurrentLine, 1, Me.CurrentChar - 1)
        End If
        strPart2 = Mid(strCurrentLine, Me.CurrentChar + 1)
        strCurrentLine = strPart1 & strPart2
        ReplaceCurrentLine strCurrentLine
    End If
End Function

Public Function DeleteCurrentLine() As Boolean
    Lines.Remove GetLineIndex()
    DeleteCurrentLine = True
End Function

Private Function ReplaceCurrentLine(strNewLine As String) As Boolean

    Lines.Add strNewLine, , , GetLineIndex()
    Lines.Remove GetLineIndex()
    ReplaceCurrentLine = True
End Function

Public Function InsertNewLine(Optional strNewLine As String, Optional lngLineIndex As Long = -1) As Boolean

    If lngLineIndex = -1 Then
        Lines.Add strNewLine, , , GetLineIndex()
    Else
    End If
End Function

