VERSION 5.00
Begin VB.UserControl W3EditAx 
   AutoRedraw      =   -1  'True
   BackColor       =   &H00FFFFFF&
   BorderStyle     =   1  'Fixed Single
   ClientHeight    =   3060
   ClientLeft      =   0
   ClientTop       =   0
   ClientWidth     =   3975
   BeginProperty Font 
      Name            =   "Fixedsys"
      Size            =   9
      Charset         =   0
      Weight          =   400
      Underline       =   0   'False
      Italic          =   0   'False
      Strikethrough   =   0   'False
   EndProperty
   ScaleHeight     =   3060
   ScaleWidth      =   3975
End
Attribute VB_Name = "W3EditAx"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Public Event UpdateUserInfo()

Private m_lngFontHeight As Long
Private m_lngFontWidth As Long

Public MemoryTextFile As New CMemoryTextFile

Public Property Get FileName() As String
    FileName = MemoryTextFile.FileName
End Property

Public Property Let FileName(ByVal vNewValue As String)
    MemoryTextFile.FileName = vNewValue
    m_lngFontHeight = UserControl.TextHeight("A")
    m_lngFontWidth = UserControl.TextWidth("A")
End Property

Private Sub UserControl_KeyDown(KeyCode As Integer, Shift As Integer)
      KeyManager KeyCode, Shift
'      UserControl.SetFocus
End Sub

Public Function DrawScreen() As Boolean
    Dim i As Long
    
On Error GoTo ErrMgr
    
    UserControl.Cls
    For i = 1 To MaxRowAvailable()
    
        InternalPrint Me.MemoryTextFile.GetScreenLine(i)
    Next
    DrawCursor True
    UserControl.Refresh
Exit Function
ErrMgr:
    FShowError W3EDIT_ERROR_001 & " " & GetVBErrorString(), Me, "DrawScreen"
End Function

Public Property Get MaxRowAvailable() As Long
    If m_lngFontHeight Then
        MaxRowAvailable = (UserControl.Height / m_lngFontHeight) - 1
    End If
End Property

Private Function KeyManager(KeyCode As Integer, Shift As Integer)

    On Error GoTo ErrMgr

    Static booWorking           As Boolean
    Dim booCtrlDown             As Boolean
    
    If (booWorking) Then
        Exit Function
    End If
    
    booWorking = True
    
    booCtrlDown = (Shift And vbCtrlMask) > 0
    
    Select Case KeyCode
    
        ' Menu Short cut - key must be ignored
        Case Asc("Q"), Asc("q")
            If booCtrlDown Then
                GoTo TheExit
            End If
            
        Case vbKeyDelete
            MemoryTextFile.DeleteChar
            
        Case vbKeyDown
            If MemoryTextFile.ScreenLineIndex < MaxRowAvailable() Then
                DrawCursor False
                MemoryTextFile.NextLine MaxRowAvailable()
                DrawCursor True
                GoTo TheExit
            Else
                MemoryTextFile.NextLine MaxRowAvailable()
            End If
                    
            
        Case vbKeyUp
            
            If MemoryTextFile.ScreenLineIndex > 1 Then
                DrawCursor False
                MemoryTextFile.PreviousLine
                DrawCursor True
                GoTo TheExit
            Else
                MemoryTextFile.PreviousLine
            End If
            
        Case vbKeyReturn ', vbKeySpace
            MemoryTextFile.InsertNewLine
        
        Case vbKeyHome
            MemoryTextFile.FirstChar
            
        Case vbKeyEnd
            MemoryTextFile.LastChar
            
        Case vbKeyRight
            DrawCursor False
            MemoryTextFile.NextChar
            DrawCursor True
            GoTo TheExit
            
            
        Case vbKeyLeft
            DrawCursor False
            MemoryTextFile.PreviousChar
            DrawCursor True
            GoTo TheExit
        
        Case vbKeyPageDown
            If (booCtrlDown) Then
                MemoryTextFile.LastPage MaxRowAvailable
            Else
                MemoryTextFile.NextPage MaxRowAvailable
            End If
            
        Case vbKeyPageUp
            If (booCtrlDown) Then
                MemoryTextFile.FirstPage
            Else
                MemoryTextFile.PreviousPage MaxRowAvailable
            End If

            
        Case vbKeyC
            If booCtrlDown Then ' CTRL+C
            End If
    End Select
    
DrawScreen

TheExit:
    booWorking = False
    RaiseEvent UpdateUserInfo
    Exit Function
ErrMgr:
    FShowError W3EDIT_ERROR_001 & " " & GetVBErrorString(), Me, "KeyManager"
    GoTo TheExit
End Function

Private Sub UserControl_MouseDown(Button As Integer, Shift As Integer, x As Single, Y As Single)
    SetCursorFromMousePositon CLng(x), CLng(Y)
End Sub

Private Sub UserControl_Paint()
    DrawScreen
End Sub

Public Property Get BackColor() As Long
    BackColor = UserControl.BackColor
End Property

Public Property Let BackColor(ByVal vNewValue As Long)
    UserControl.BackColor = vNewValue
End Property

Public Property Get ForeColor() As Long
    ForeColor = UserControl.ForeColor
End Property

Public Property Let ForeColor(ByVal vNewValue As Long)
    UserControl.ForeColor = vNewValue
End Property

Private Sub UserControl_Resize()
    UserControl_Paint
End Sub



Public Function DrawCursor(Show As Boolean) As Boolean

    Dim lngCurX As Long
    Dim lngCurY As Long
    Dim lngColor As Long
    
    
    
    If m_lngFontHeight Then
        If Show Then
            lngColor = vbBlack
        Else
            lngColor = UserControl.BackColor
        End If
        lngCurY = (MemoryTextFile.ScreenLineIndex - 1) * m_lngFontHeight
        lngCurX = (MemoryTextFile.CurrentChar - 1) * m_lngFontWidth
    
        UserControl.DrawWidth = 2
        UserControl.Line (lngCurX, lngCurY)-(lngCurX, lngCurY + m_lngFontHeight), lngColor
        UserControl.DrawWidth = 1
    End If

    
End Function




Private Function InternalPrint(s As String) As Boolean
    Dim strTok      As String
    Dim objParser   As CByteSyntaxAnalyser
    Dim m_lngForeColor As Long
    
    m_lngForeColor = UserControl.ForeColor
   
    
    If Len(s) Then
        
            Set objParser = New CByteSyntaxAnalyser
            
            objParser.Init s
            Do While objParser.EOS = rFALSE
            
                If objParser.GetCByteChar() = 32 Then
                    objParser.NextChar
                    strTok = " "
                Else
                    If objParser.GetIdentifier(strTok, False) = rFALSE Then
                        strTok = objParser.GetCChar()
                        objParser.NextChar
                    Else
                    End If
                End If
                
                Select Case LCase(strTok)
                
                
                    Case "'"
                    
                        UserControl.ForeColor = 5410340
                        UserControl.Print Mid(s, objParser.lngBytesIndex)
                        UserControl.ForeColor = m_lngForeColor
                        Exit Function
                
                    Case "=", ",", "<", ">", ">=", "<=", "(", ")", "-", "+", "/", "\", "*"
                    
                        UserControl.ForeColor = 0
                        UserControl.Print strTok;
                        UserControl.ForeColor = m_lngForeColor
                        
                    Case "function", "sub", "property", "private", "public", "for", "each", "next", "exit", "as", "on", "error", "resume", "dim", "new", "end", "optional", "begin", "gosub", "if", "then", "else", "elseif", "do", "while", "loop", "select", "case", "or", "and", "rnd"
                    
                        UserControl.ForeColor = vbBlue
                        UserControl.Print strTok;
                        UserControl.ForeColor = m_lngForeColor
                        
                    Case "boolean", "long", "byte", "string", "form", "control", "double", "variant", "single", "integer"
                    
                        UserControl.ForeColor = 4210943
                        UserControl.Print strTok;
                        UserControl.ForeColor = m_lngForeColor
                    Case Else
                        UserControl.Print strTok;
                End Select
            Loop
    End If
    UserControl.Print ""
End Function


Private Function SetCursorFromMousePositon(ByVal x As Long, Y As Long) As Boolean
    x = (x \ m_lngFontWidth) + 1
    Y = Y \ m_lngFontHeight + 1
    MemoryTextFile.ScreenLineIndex = Y
    MemoryTextFile.CurrentChar = x
    DrawScreen
End Function
