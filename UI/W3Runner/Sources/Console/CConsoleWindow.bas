Attribute VB_Name = "CConsoleWindowModule"
Option Explicit

' The following section contains the Public data structures, data types,
' and procedures exported by the NT console subsystem.

Public Const STD_INPUT_HANDLE = -10&
Public Const STD_OUTPUT_HANDLE = -11&
Public Const STD_ERROR_HANDLE = -12&



Public Type SECURITY_ATTRIBUTES
    nLength                     As Long
    lpSecurityDescriptor        As Long
    bInheritHandle              As Long
End Type

Public Type COORD
    x                           As Integer
    y                           As Integer
End Type

Public Type SMALL_RECT
    Left                        As Integer
    Top                         As Integer
    Right                       As Integer
    Bottom                      As Integer
End Type

'   EventType flags:
Public Const CONSOLE_KEY_EVENT = &H1     '  Event contains key event record
Public Const CONSOLE_MOUSE_EVENTC = &H2     '  Event contains mouse event record
Public Const CONSOLE_WINDOW_BUFFER_SIZE_EVENT = &H4     '  Event contains window change event record
Public Const CONSOLE_MENU_EVENT = &H8     '  Event contains menu event record
Public Const CONSOLE_FOCUS_EVENT = &H10    '  event contains focus change

Public Type CHAR_INFO
        Char                    As Integer
        Attributes              As Integer
End Type

'  Attributes flags:
Const FOREGROUND_BLUE = &H1     '  text color contains blue.
Const FOREGROUND_GREEN = &H2     '  text color contains green.
Const FOREGROUND_RED = &H4     '  text color contains red.
Const FOREGROUND_INTENSITY = &H8     '  text color is intensified.
Const BACKGROUND_BLUE = &H10    '  background color contains blue.
Const BACKGROUND_GREEN = &H20    '  background color contains green.
Const BACKGROUND_RED = &H40    '  background color contains red.
Const BACKGROUND_INTENSITY = &H80    '  background color is intensified.

Public Type CONSOLE_SCREEN_BUFFER_INFO
        dwSize                  As COORD
        dwCursorPosition        As COORD
        wAttributes             As Integer
        srWindow                As SMALL_RECT
        dwMaximumWindowSize     As COORD
End Type

Public Type CONSOLE_CURSOR_INFO
        dwSize                  As Long
        bVisible                As Long
End Type

Public Const CTRL_C_EVENT = 0
Public Const CTRL_BREAK_EVENT = 1
Public Const CTRL_CLOSE_EVENT = 2
'  3 is reserved!
'  4 is reserved!
Const CTRL_LOGOFF_EVENT = 5
Const CTRL_SHUTDOWN_EVENT = 6

' Input Mode flags:
Public Const ENABLE_PROCESSED_INPUT = &H1
Public Const ENABLE_LINE_INPUT = &H2
Public Const ENABLE_ECHO_INPUT = &H4
Public Const ENABLE_WINDOW_INPUT = &H8
Public Const ENABLE_MOUSE_INPUT = &H10

' Output Mode flags:
Const ENABLE_PROCESSED_OUTPUT = &H1
Const ENABLE_WRAP_AT_EOL_OUTPUT = &H2

'
'typedef struct _KEY_EVENT_RECORD {
'   BOOL bKeyDown;
'   WORD wRepeatCount;
'   WORD wVirtualKeyCode;
'   WORD wVirtualScanCode;
'   union {
'           WCHAR UnicodeChar;
'           CHAR  AsciiChar;
'   } uChar;
'   DWORD dwControlKeyState;
'} KEY_EVENT_RECORD;
'

Public Type CONSOLE_KEY_EVENT_RECORD
 
    bKeyDown            As Long
    wRepeatCount        As Integer
    wVirtualKeyCode     As Integer
    wVirtualScanCode    As Integer
    'WCHAR UnicodeChar;
    'Char AsciiChar
    uChar               As Integer
    dwControlKeyState   As Long
End Type

'
'typedef struct _INPUT_RECORD {
'       WORD EventType;
'       union {
'           KEY_EVENT_RECORD KeyEvent;
'           MOUSE_EVENT_RECORD MouseEvent;
'           WINDOW_BUFFER_SIZE_RECORD WindowBufferSizeEvent;
'           MENU_EVENT_RECORD MenuEvent;
'           FOCUS_EVENT_RECORD FocusEvent;
'       } Event;
' } INPUT_RECORD;

Public Type CONSOLE_EVENT_INPUT_RECORD
    EventType   As Integer
    Event       As CONSOLE_KEY_EVENT_RECORD ' Should be an union but I need only the key board
                                            ' The KEY event is the biggest so that should be ok
    dummy       As String * 32
End Type



'BOOL PeekConsoleInput(
'  HANDLE hConsoleInput,         // handle to console input buffer
'  PINPUT_RECORD lpBuffer,       // peek data
'  DWORD nLength,                // number of records to read
'  LPDWORD lpNumberOfEventsRead  // number of records read);

Public Declare Function PeekConsoleInput Lib "kernel32" Alias "ReadConsoleOutputA" (ByVal hConsoleInput As Long, lpBuffer As CONSOLE_EVENT_INPUT_RECORD, ByVal nNumberOfMsgToRead As Long, lpNumberOfMsgRead As Long) As Long
Public Declare Function ReadConsoleInput Lib "kernel32" Alias "ReadConsoleOutputA" (ByVal hConsoleInput As Long, lpBuffer As CONSOLE_EVENT_INPUT_RECORD, ByVal nNumberOfMsgToRead As Long, lpNumberOfMsgRead As Long) As Long

Public Declare Function ReadConsoleOutput Lib "kernel32" Alias "ReadConsoleOutputA" (ByVal hConsoleOutput As Long, lpBuffer As CHAR_INFO, dwBufferSize As COORD, dwBufferCoord As COORD, lpReadRegion As SMALL_RECT) As Long
Public Declare Function WriteConsoleOutput Lib "kernel32" Alias "WriteConsoleOutputA" (ByVal hConsoleOutput As Long, lpBuffer As CHAR_INFO, dwBufferSize As COORD, dwBufferCoord As COORD, lpWriteRegion As SMALL_RECT) As Long
Public Declare Function ReadConsoleOutputCharacter Lib "kernel32" Alias "ReadConsoleOutputCharacterA" (ByVal hConsoleOutput As Long, ByVal lpCharacter As String, ByVal nLength As Long, dwReadCoord As COORD, lpNumberOfCharsRead As Long) As Long
Public Declare Function ReadConsoleOutputAttribute Lib "kernel32" (ByVal hConsoleOutput As Long, lpAttribute As Long, ByVal nLength As Long, dwReadCoord As COORD, lpNumberOfAttrsRead As Long) As Long
Public Declare Function WriteConsoleOutputCharacter Lib "kernel32" Alias "WriteConsoleOutputCharacterA" (ByVal hConsoleOutput As Long, ByVal lpCharacter As String, ByVal nLength As Long, dwWriteCoord As COORD, lpNumberOfCharsWritten As Long) As Long

Public Declare Function WriteConsoleOutputAttribute Lib "kernel32" (ByVal hConsoleOutput As Long, lpAttribute As Integer, ByVal nLength As Long, dwWriteCoord As COORD, lpNumberOfAttrsWritten As Long) As Long
Public Declare Function FillConsoleOutputCharacter Lib "kernel32" Alias "FillConsoleOutputCharacterA" (ByVal hConsoleOutput As Long, ByVal cCharacter As Byte, ByVal nLength As Long, dwWriteCoord As COORD, lpNumberOfCharsWritten As Long) As Long
Public Declare Function FillConsoleOutputAttribute Lib "kernel32" (ByVal hConsoleOutput As Long, ByVal wAttribute As Long, ByVal nLength As Long, dwWriteCoord As COORD, lpNumberOfAttrsWritten As Long) As Long
Public Declare Function GetConsoleMode Lib "kernel32" (ByVal hConsoleHandle As Long, lpMode As Long) As Long
Public Declare Function GetNumberOfConsoleInputEvents Lib "kernel32" (ByVal hConsoleInput As Long, lpNumberOfEvents As Long) As Long
Public Declare Function GetConsoleScreenBufferInfo Lib "kernel32" (ByVal hConsoleOutput As Long, lpConsoleScreenBufferInfo As CONSOLE_SCREEN_BUFFER_INFO) As Long
Public Declare Function GetLargestConsoleWindowSize Lib "kernel32" (ByVal hConsoleOutput As Long) As COORD
Public Declare Function GetConsoleCursorInfo Lib "kernel32" (ByVal hConsoleOutput As Long, lpConsoleCursorInfo As CONSOLE_CURSOR_INFO) As Long
Public Declare Function GetNumberOfConsoleMouseButtons Lib "kernel32" (lpNumberOfMouseButtons As Long) As Long
Public Declare Function SetConsoleMode Lib "kernel32" (ByVal hConsoleHandle As Long, ByVal dwMode As Long) As Long
Public Declare Function SetConsoleActiveScreenBuffer Lib "kernel32" (ByVal hConsoleOutput As Long) As Long
Public Declare Function FlushConsoleInputBuffer Lib "kernel32" (ByVal hConsoleInput As Long) As Long
Public Declare Function SetConsoleScreenBufferSize Lib "kernel32" (ByVal hConsoleOutput As Long, dwSize As COORD) As Long
Public Declare Function SetConsoleCursorPosition Lib "kernel32" (ByVal hConsoleOutput As Long, dwCursorPosition As COORD) As Long
Public Declare Function SetConsoleCursorInfo Lib "kernel32" (ByVal hConsoleOutput As Long, lpConsoleCursorInfo As CONSOLE_CURSOR_INFO) As Long
Public Declare Function ScrollConsoleScreenBuffer Lib "kernel32" Alias "ScrollConsoleScreenBufferA" (ByVal hConsoleOutput As Long, lpScrollRectangle As SMALL_RECT, lpClipRectangle As SMALL_RECT, dwDestinationOrigin As COORD, lpFill As CHAR_INFO) As Long
Public Declare Function SetConsoleWindowInfo Lib "kernel32" (ByVal hConsoleOutput As Long, ByVal bAbsolute As Long, lpConsoleWindow As SMALL_RECT) As Long
Public Declare Function SetConsoleTextAttribute Lib "kernel32" (ByVal hConsoleOutput As Long, ByVal wAttributes As Long) As Long
Public Declare Function SetConsoleCtrlHandler Lib "kernel32" (ByVal HandlerRoutine As Long, ByVal Add As Long) As Long
Public Declare Function GenerateConsoleCtrlEvent Lib "kernel32" (ByVal dwCtrlEvent As Long, ByVal dwProcessGroupId As Long) As Long
Public Declare Function AllocConsole Lib "kernel32" () As Long
Public Declare Function FreeConsole Lib "kernel32" () As Long
Public Declare Function GetConsoleTitle Lib "kernel32" Alias "GetConsoleTitleA" (ByVal lpConsoleTitle As String, ByVal nSize As Long) As Long
Public Declare Function SetConsoleTitle Lib "kernel32" Alias "SetConsoleTitleA" (ByVal lpConsoleTitle As String) As Long
Public Declare Function ReadConsole Lib "kernel32" Alias "ReadConsoleA" (ByVal hConsoleInput As Long, lpBuffer As Any, ByVal nNumberOfCharsToRead As Long, lpNumberOfCharsRead As Long, lpReserved As Any) As Long
Declare Function PostMessage Lib "user32" Alias "PostMessageA" (ByVal hwnd As Long, ByVal wMsg As Long, ByVal wParam As Long, ByVal lParam As Long) As Long

'Public Declare Function SendMessage Lib "user32" Alias "SendMessageA" (ByVal hwnd As Long, ByVal wMsg As Long, ByVal wParam As Long, lParam As Long) As Long
' The definition in the api viewer is bad
'       public Declare Function WriteConsole Lib "kernel32" Alias "WriteConsoleA" (ByVal hConsoleOutput As Long, lpBuffer As Any, ByVal nNumberOfCharsToWrite As Long, lpNumberOfCharsWritten As Long, lpReserved As Any) As Long
' Here is the good one...
Public Declare Function WriteConsole Lib "kernel32" Alias "WriteConsoleA" (ByVal hConsoleOutput As Long, ByVal lpBuffer As String, ByVal nNumberOfCharsToWrite As Long, lpNumberOfCharsWritten As Long, lpReserved As Any) As Long

Public Declare Function GetForegroundWindow Lib "user32" () As Long
Public Declare Function CloseHandle Lib "kernel32" (ByVal hObject As Long) As Long
Public Declare Function SetWindowText Lib "user32" Alias "SetWindowTextA" (ByVal hwnd As Long, ByVal lpString As String) As Long
Public Declare Function ShowWindow Lib "user32" (ByVal hwnd As Long, ByVal nCmdShow As Long) As Long

Const CONSOLE_TEXTMODE_BUFFER = 1

Public Declare Function CreateConsoleScreenBuffer Lib "kernel32" (ByVal dwDesiredAccess As Long, ByVal dwShareMode As Long, lpSecurityAttributes As SECURITY_ATTRIBUTES, ByVal dwFlags As Long, lpScreenBufferData As Any) As Long
Public Declare Function GetConsoleCP Lib "kernel32" () As Long
Public Declare Function SetConsoleCP Lib "kernel32" (ByVal wCodePageID As Long) As Long
Public Declare Function GetConsoleOutputCP Lib "kernel32" () As Long
Public Declare Function SetConsoleOutputCP Lib "kernel32" (ByVal wCodePageID As Long) As Long

Public Declare Function GetStdHandle Lib "kernel32" (ByVal nStdHandle As Long) As Long

'Public Const SW_HIDE = 0
'Public Const SW_SHOWNORMAL = 1
' Public Const SW_SHOWMINIMIZED = 2
' Public Const SW_SHOWMAXIMIZED = 3
' Public Const SW_SHOWNOACTIVATE = 4
' Public Const SW_SHOW = 5
' Public Const SW_MINIMIZE = 6
' Public Const SW_SHOWMINNOACTIVE = 7
' Public Const SW_SHOWNA = 8
' Public Const SW_RESTORE = 9
