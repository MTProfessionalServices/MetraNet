VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CConsoleKeyBoard"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Public Parent As CConsoleWindow

Private m_hInPutConsole     As Long

Public Function Load() As Boolean
    m_hInPutConsole = GetStdHandle(STD_INPUT_HANDLE)
    If (SetConsoleMode(m_hInPutConsole, ENABLE_LINE_INPUT + ENABLE_ECHO_INPUT)) Then
        Load = FlushKeyBoard()
    End If
End Function

Public Function ReadString(strUserInput As String) As Boolean

    Dim lngChar     As Long
    strUserInput = ""
    Do
        If (ReadChar(lngChar)) Then
            If (lngChar = 13) Then
                ReadString = True
                'Parent.WriteText Chr(10)
                Exit Function
            Else
                strUserInput = strUserInput & Chr(lngChar)
            End If
        Else
            Exit Do
        End If
    Loop
End Function

Public Function IsKey() As Boolean

    Dim lngEventsCount          As Long
    Dim ConsoleEvent            As CONSOLE_EVENT_INPUT_RECORD
    
    If (GetNumberOfConsoleInputEvents(m_hInPutConsole, lngEventsCount)) Then
        IsKey = CBool(lngEventsCount)
    End If
    Exit Function
    
        
    Debug.Assert 0
    Do
    ' Read how many event in the buffer
    If (GetNumberOfConsoleInputEvents(m_hInPutConsole, lngEventsCount)) Then
    
        If (lngEventsCount > 0) Then ' If there are 1 or more events
        
            ' Get the event but do not delete it from the buffer
            
            ConsoleEvent.EventType = 0
            If (PeekConsoleInput(m_hInPutConsole, ConsoleEvent, 1, lngEventsCount)) Then
            
                ' If we have a KeyBoard Event
                If (ConsoleEvent.EventType And CONSOLE_KEY_EVENT = CONSOLE_KEY_EVENT) Then
                
                    IsKey = True
                    Exit Function '  We find the next keyboard event
                Else
                    ' Delete the non keyboard event - we do not support them
                    ReadConsoleInput m_hInPutConsole, ConsoleEvent, 1, lngEventsCount
                End If
            End If
        Else
            Exit Function ' ok no event
        End If
    Else
        Exit Function ' Error case
    End If
    Loop
End Function

Public Function FlushKeyBoard() As Boolean

    FlushKeyBoard = FlushConsoleInputBuffer(m_hInPutConsole)
End Function


Public Function UnLoad() As Boolean
    CloseHandle m_hInPutConsole
    UnLoad = True
End Function



Public Function ReadChar(lngChar As Long) As Boolean

    Dim lngCharRead As Long
    
    If (ReadConsole(m_hInPutConsole, lngChar, 1, lngCharRead, vbNullString)) Then
    
        ReadChar = CBool(lngCharRead = 1)
    End If
End Function
