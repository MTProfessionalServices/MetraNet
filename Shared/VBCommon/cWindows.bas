Attribute VB_Name = "cWindowsModule"
Option Explicit

'CodePage
Public Const CP_ACP = 0 'ANSI
Public Const CP_MACCP = 2 'Mac
Public Const CP_OEMCP = 1 'OEM
Public Const CP_UTF7 = 65000
Public Const CP_UTF8 = 65001

'dwFlags
Public Const WC_NO_BEST_FIT_CHARS = &H400
Public Const WC_COMPOSITECHECK = &H200
Public Const WC_DISCARDNS = &H10
Public Const WC_SEPCHARS = &H20 'Default
Public Const WC_DEFAULTCHAR = &H40

Public Declare Function WideCharToMultiByte Lib "kernel32" (ByVal CodePage As Long, _
                                                    ByVal dwFlags As Long, _
                                                    ByVal lpWideCharStr As Long, _
                                                    ByVal cchWideChar As Long, _
                                                    ByVal lpMultiByteStr As Long, _
                                                    ByVal cbMultiByte As Long, _
                                                    ByVal lpDefaultChar As Long, _
                                                    ByVal lpUsedDefaultChar As Long) As Long
                                                    

Public Type PROCESS_MEMORY_COUNTERS
    cb                          As Long
    PageFaultCount              As Long
    PeakWorkingSetSize          As Long
    WorkingSetSize              As Long
    QuotaPeakPagedPoolUsage     As Long
    QuotaPagedPoolUsage         As Long
    QuotaPeakNonPagedPoolUsage  As Long
    QuotaNonPagedPoolUsage      As Long
    PagefileUsage               As Long
    PeakPagefileUsage           As Long
End Type



Public Type MEMORYSTATUS
    dwLength As Long
    dwMemoryLoad As Long
    dwTotalPhys As Long
    dwAvailPhys As Long
    dwTotalPageFile As Long
    dwAvailPageFile As Long
    dwTotalVirtual As Long
    dwAvailVirtual As Long
End Type

'Private Declare Sub GlobalMemoryStatus Lib "kernel32" (lpBuffer As MEMORYSTATUS)
   

Public Declare Sub ExitProcess Lib "kernel32" (ByVal uExitCode As Long)
Public Declare Function GetCurrentProcess Lib "kernel32" () As Long
Public Declare Function GetProcessMemoryInfo Lib "psapi.dll" (ByVal lHandle As Long, ByVal lpStructure As Long, ByVal lSize As Long) As Integer

Public Declare Function GetCurrentProcessId Lib "kernel32" () As Long

      Public Declare Function Process32First Lib "kernel32" ( _
         ByVal hSnapshot As Long, lppe As PROCESSENTRY32) As Long

      Public Declare Function Process32Next Lib "kernel32" ( _
         ByVal hSnapshot As Long, lppe As PROCESSENTRY32) As Long

      
      
      Public Declare Function EnumProcesses Lib "psapi.dll" _
         (ByRef lpidProcess As Long, ByVal cb As Long, _
            ByRef cbNeeded As Long) As Long

      Public Declare Function GetModuleFileNameExA Lib "psapi.dll" _
         (ByVal hProcess As Long, ByVal hModule As Long, _
            ByVal ModuleName As String, ByVal nSize As Long) As Long

      Public Declare Function EnumProcessModules Lib "psapi.dll" _
         (ByVal hProcess As Long, ByRef lphModule As Long, _
            ByVal cb As Long, ByRef cbNeeded As Long) As Long

      Public Declare Function CreateToolhelp32Snapshot Lib "kernel32" ( _
         ByVal dwFlags As Long, ByVal th32ProcessID As Long) As Long

      Public Declare Function GetVersionExA Lib "kernel32" _
         (lpVersionInformation As OSVERSIONINFO) As Integer

      Public Type PROCESSENTRY32
         dwSize As Long
         cntUsage As Long
         th32ProcessID As Long           ' This process
         th32DefaultHeapID As Long
         th32ModuleID As Long            ' Associated exe
         cntThreads As Long
         th32ParentProcessID As Long     ' This process's parent process
         pcPriClassBase As Long          ' Base priority of process threads
         dwFlags As Long
         szExeFile As String * 260       ' MAX_PATH
      End Type

'      Public Type OSVERSIONINFO
'         dwOSVersionInfoSize As Long
'         dwMajorVersion As Long
'         dwMinorVersion As Long
'         dwBuildNumber As Long
'         dwPlatformId As Long           '1 = Windows 95.
'                                        '2 = Windows NT
'
'         szCSDVersion As String * 128
'      End Type

      
      
      'Public Const MAX_PATH = 260
      'Public Const STANDARD_RIGHTS_REQUIRED = &HF0000
      'Public Const SYNCHRONIZE = &H100000
      'STANDARD_RIGHTS_REQUIRED Or SYNCHRONIZE Or &HFFF
      Public Const PROCESS_ALL_ACCESS = &H1F0FFF
      Public Const TH32CS_SNAPPROCESS = &H2&
      Public Const hNull = 0



'Treat entire URL param as one URL segment
Public Const URL_ESCAPE_SEGMENT_ONLY    As Long = &H2000
Public Const URL_ESCAPE_PERCENT         As Long = &H1000
Public Const URL_UNESCAPE_INPLACE       As Long = &H100000

'escape #'s in paths
Public Const URL_INTERNAL_PATH          As Long = &H800000
Public Const URL_DONT_ESCAPE_EXTRA_INFO As Long = &H2000000
Public Const URL_ESCAPE_SPACES_ONLY     As Long = &H4000000
Public Const URL_DONT_SIMPLIFY          As Long = &H8000000

'Converts unsafe characters, such as spaces, into their corresponding escape sequences.
Public Declare Function UrlEscape Lib "shlwapi" Alias "UrlEscapeA" (ByVal pszURL As String, ByVal pszEscaped As String, pcchEscaped As Long, ByVal dwFlags As Long) As Long

'Converts escape sequences back into ordinary characters.
Public Declare Function UrlUnescape Lib "shlwapi" Alias "UrlUnescapeA" (ByVal pszURL As String, ByVal pszUnescaped As String, pcchUnescaped As Long, ByVal dwFlags As Long) As Long


Public Declare Function GetLocaleInfo Lib "kernel32" Alias "GetLocaleInfoA" (ByVal Locale As Long, ByVal LCType As Long, ByVal lpLCData As String, ByVal cchData As Long) As Long
Public Declare Function GetUserDefaultLCID% Lib "kernel32" ()



Public Type MOUSEHOOKSTRUCT
        'pt As POINTAPI
        pt_x As Long
        pt_y As Long
        hwnd As Long
        wHitTestCode As Long
        dwExtraInfo As Long
End Type

Public Declare Function CallWindowProc Lib "user32" Alias "CallWindowProcA" (ByVal lpPrevWndFunc As Long, ByVal hwnd As Long, ByVal msg As Long, ByVal wParam As Long, ByVal lParam As Long) As Long

' Key State Masks for Mouse Messages
Public Const MK_LBUTTON = &H1
Public Const MK_RBUTTON = &H2
Public Const MK_SHIFT = &H4
Public Const MK_CONTROL = &H8
Public Const MK_MBUTTON = &H10


Public Const TIME_ZONE_ID_INVALID = &HFFFFFFFF
Public Const TIME_ZONE_ID_UNKNOWN = 0
Public Const TIME_ZONE_ID_STANDARD = 1
Public Const TIME_ZONE_ID_DAYLIGHT = 2

Public Declare Sub CoFreeUnusedLibraries Lib "OLE32" ()


Public Type SYSTEMTIME
    Year As Integer
    Month As Integer
    DayOfWeek As Integer
    Day As Integer
    Hour As Integer
    Minute As Integer
    Second As Integer
    Milliseconds As Integer
End Type

Public Type TIME_ZONE_INFORMATION
  Bias As Long
  StandardName(32) As Integer
  StandardDate As SYSTEMTIME
  StandardBias As Long
  DaylightName(32) As Integer
  DaylightDate As SYSTEMTIME
  DaylightBias As Long
End Type

Public Declare Function GetTimeZoneInformation Lib "kernel32" (lpTimeZoneInformation As TIME_ZONE_INFORMATION) As Long

Public Declare Sub GetSystemTime Lib "kernel32" (lpSystemTime As SYSTEMTIME)


' Listbox messages
Public Const LB_INITSTORAGE = &H1A8
Public Const LB_ADDSTRING = &H180
Public Const LB_INSERTSTRING = &H181
Public Const LB_DELETESTRING = &H182
Public Const LB_SELITEMRANGEEX = &H183
Public Const LB_RESETCONTENT = &H184
Public Const LB_SETSEL = &H185
Public Const LB_SETCURSEL = &H186
Public Const LB_GETSEL = &H187
Public Const LB_GETCURSEL = &H188
Public Const LB_GETTEXT = &H189
Public Const LB_GETTEXTLEN = &H18A
Public Const LB_GETCOUNT = &H18B
Public Const LB_SELECTSTRING = &H18C
Public Const LB_DIR = &H18D
Public Const LB_GETTOPINDEX = &H18E
Public Const LB_FINDSTRING = &H18F
Public Const LB_GETSELCOUNT = &H190
Public Const LB_GETSELITEMS = &H191
Public Const LB_SETTABSTOPS = &H192
Public Const LB_GETHORIZONTALEXTENT = &H193
Public Const LB_SETHORIZONTALEXTENT = &H194
Public Const LB_SETCOLUMNWIDTH = &H195
Public Const LB_ADDFILE = &H196
Public Const LB_SETTOPINDEX = &H197
Public Const LB_GETITEMRECT = &H198
Public Const LB_GETITEMDATA = &H199
Public Const LB_SETITEMDATA = &H19A
Public Const LB_SELITEMRANGE = &H19B
Public Const LB_SETANCHORINDEX = &H19C
Public Const LB_GETANCHORINDEX = &H19D
Public Const LB_SETCARETINDEX = &H19E
Public Const LB_GETCARETINDEX = &H19F
Public Const LB_SETITEMHEIGHT = &H1A0
Public Const LB_GETITEMHEIGHT = &H1A1
Public Const LB_FINDSTRINGEXACT = &H1A2
Public Const LB_SETLOCALE = &H1A5
Public Const LB_GETLOCALE = &H1A6
Public Const LB_SETCOUNT = &H1A7
Public Const LB_MSGMAX = &H1A8
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' Used by cSemaphore.cls
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' For the constant see WINNT.H in VC - WIN32_NO_STATUS
'
Public Const STATUS_WAIT_0 = &H0
Public Const STATUS_ABANDONED_WAIT_0 = &H80
Public Const STATUS_USER_APC = &HC0
Public Const STATUS_TIMEOUT = &H102
Public Const STATUS_PENDING = &H103
Public Const STATUS_SEGMENT_NOTIFICATION = &H40000005
Public Const STATUS_GUARD_PAGE_VIOLATION = &H80000001
Public Const STATUS_DATATYPE_MISALIGNMENT = &H80000002
Public Const STATUS_BREAKPOINT = &H80000003
Public Const STATUS_SINGLE_STEP = &H80000004
Public Const STATUS_ACCESS_VIOLATION = &HC0000005
Public Const STATUS_IN_PAGE_ERROR = &HC0000006
Public Const STATUS_INVALID_HANDLE = &HC0000008
Public Const STATUS_NO_MEMORY = &HC0000017
Public Const STATUS_ILLEGAL_INSTRUCTION = &HC000001D
Public Const STATUS_NONCONTINUABLE_EXCEPTION = &HC0000025
Public Const STATUS_INVALID_DISPOSITION = &HC0000026
Public Const STATUS_ARRAY_BOUNDS_EXCEEDED = &HC000008C
Public Const STATUS_FLOAT_DENORMAL_OPERAND = &HC000008D
Public Const STATUS_FLOAT_DIVIDE_BY_ZERO = &HC000008E
Public Const STATUS_FLOAT_INEXACT_RESULT = &HC000008F
Public Const STATUS_FLOAT_INVALID_OPERATION = &HC0000090
Public Const STATUS_FLOAT_OVERFLOW = &HC0000091
Public Const STATUS_FLOAT_STACK_CHECK = &HC0000092
Public Const STATUS_FLOAT_UNDERFLOW = &HC0000093
Public Const STATUS_INTEGER_DIVIDE_BY_ZERO = &HC0000094
Public Const STATUS_INTEGER_OVERFLOW = &HC0000095
Public Const STATUS_PRIVILEGED_INSTRUCTION = &HC0000096
Public Const STATUS_STACK_OVERFLOW = &HC00000FD
Public Const STATUS_CONTROL_C_EXIT = &HC000013A

Public Const Delete = &H10000
Public Const READ_CONTROL = &H20000
Public Const WRITE_DAC = &H40000
Public Const WRITE_OWNER = &H80000

Public Declare Function GetForegroundWindow Lib "user32" () As Long
Public Declare Function SetForegroundWindow Lib "user32" (ByVal hwnd As Long) As Long

Public Const LBS_MULTIPLESEL = &H8
Public Const LBS_OWNERDRAWFIXED = &H10


Public Type CWPSTRUCT
        lParam As Long
        wParam As Long
        message As Long
        hwnd As Long
End Type

Public Declare Function GetActiveWindow Lib "user32" () As Long

Public Const SYNCHRONIZE = &H100000
Public Const STANDARD_RIGHTS_REQUIRED = &HF0000
Public Const STANDARD_RIGHTS_ALL = &H1F0000
Public Const STANDARD_RIGHTS_READ = (READ_CONTROL)
Public Const STANDARD_RIGHTS_WRITE = (READ_CONTROL)
Public Const STANDARD_RIGHTS_EXECUTE = (READ_CONTROL)
Public Const SPECIFIC_RIGHTS_ALL = &HFFFF

Public Const SEMAPHORE_ALL_ACCESS = (STANDARD_RIGHTS_REQUIRED + SYNCHRONIZE + &H3)
Public Const SEMAPHORE_MODIFY_STATE = &H2

Public Const WAIT_OBJECT_0 = ((STATUS_WAIT_0) + 0)
Public Const WAIT_TIMEOUT = STATUS_TIMEOUT
Public Const WAIT_ABANDONED = ((STATUS_ABANDONED_WAIT_0) + 0)

Public Const REG_Option_NON_VOLATILE = 0
Public Declare Function SetWindowText Lib "user32" Alias "SetWindowTextA" (ByVal hwnd As Long, ByVal lpString As String) As Long


' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' Used for the registry access by CRegistry.cls
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Type SECURITY_ATTRIBUTES
        nLength As Long
        lpSecurityDescriptor As Long
        bInheritHandle As Long
End Type
    

Type FILETIME
        dwLowDateTime   As Long
        dwHighDateTime  As Long
End Type

Public Const KEY_QUERY_VALUE = (&H1)
Public Const KEY_SET_VALUE = (&H2)
Public Const KEY_CREATE_SUB_KEY = (&H4)
Public Const KEY_ENUMERATE_SUB_KEYS = (&H8)
Public Const KEY_NOTIFY = (&H10)
Public Const KEY_CREATE_LINK = (&H20)

Private Declare Function WindowFromPointXY Lib "user32" Alias "WindowFromPoint" (ByVal xPoint As Long, ByVal yPoint As Long) As Long

Public Const KEY_ALL_ACCESS = ( _
                                STANDARD_RIGHTS_ALL Or _
                                KEY_QUERY_VALUE Or _
                                KEY_SET_VALUE Or _
                                KEY_CREATE_SUB_KEY Or _
                                KEY_ENUMERATE_SUB_KEYS _
                                Or KEY_NOTIFY Or _
                                KEY_CREATE_LINK) And _
                                (Not SYNCHRONIZE _
                                )

                                
Public Const KEY_READ = (STANDARD_RIGHTS_READ Or KEY_QUERY_VALUE Or KEY_ENUMERATE_SUB_KEYS Or KEY_NOTIFY) And (Not SYNCHRONIZE)

Public Const cHKEY_CLASSES_ROOT = &H80000000
Public Const cHKEY_CURRENT_USER = &H80000001
Public Const cHKEY_LOCAL_MACHINE = &H80000002
Public Const cHKEY_USERS = &H80000003

Declare Function UnhookWindowsHookEx Lib "user32" (ByVal hHook As Long) As Long
Declare Function CallNextHookEx Lib "user32" (ByVal hHook As Long, ByVal ncode As Long, ByVal wParam As Long, lParam As Any) As Long



' SetWindowsHook() codes
Public Const WH_MIN = (-1)
Public Const WH_MSGFILTER = (-1)
Public Const WH_JOURNALRECORD = 0
Public Const WH_JOURNALPLAYBACK = 1
Public Const WH_KEYBOARD = 2
Public Const WH_GETMESSAGE = 3
Public Const WH_CALLWNDPROC = 4
Public Const WH_CBT = 5
Public Const WH_SYSMSGFILTER = 6
Public Const WH_MOUSE = 7
Public Const WH_HARDWARE = 8
Public Const WH_DEBUG = 9
Public Const WH_SHELL = 10
Public Const WH_FOREGROUNDIDLE = 11
Public Const WH_MAX = 11

' Hook Codes
Public Const HC_ACTION = 0
Public Const HC_GETNEXT = 1
Public Const HC_SKIP = 2
Public Const HC_NOREMOVE = 3
Public Const HC_NOREM = HC_NOREMOVE
Public Const HC_SYSMODALON = 4
Public Const HC_SYSMODALOFF = 5

' CBT Hook Codes
Const HCBT_MOVESIZE = 0
Const HCBT_MINMAX = 1
Const HCBT_QS = 2
Const HCBT_CREATEWND = 3
Const HCBT_DESTROYWND = 4
Const HCBT_ACTIVATE = 5
Const HCBT_CLICKSKIPPED = 6
Const HCBT_KEYSKIPPED = 7
Const HCBT_SYSCOMMAND = 8
Const HCBT_SETFOCUS = 9



'public const KEY_WRITE               ((STANDARD_RIGHTS_WRITE      |\
'                                  KEY_SET_VALUE              |\
'                                  KEY_CREATE_SUB_KEY)         \
'                                  &                           \
'                                 (~SYNCHRONIZE))
'
'public const KEY_EXECUTE             ((KEY_READ)                   \
'                                  &                           \
'                                 (~SYNCHRONIZE))
                                
                                                                   
Public Const REG_NONE = (0)                       ' No value type
Public Const REG_SZ = (1)                         ' Unicode nul terminated string
Public Const REG_EXPAND_SZ = (2)                  ' Unicode nul terminated string  (with environment variable references)
Public Const REG_BINARY = (3)                     ' Free form binary
Public Const REG_DWORD = (4)                      ' 32-bit number
Public Const REG_DWORD_LITTLE_ENDIAN = (4)        ' 32-bit number (same as REG_DWORD)
Public Const REG_DWORD_BIG_ENDIAN = (5)           ' 32-bit number
Public Const REG_LINK = (6)                       ' Symbolic Link (unicode)
Public Const REG_MULTI_SZ = (7)                   ' Multiple Unicode strings
Public Const REG_RESOURCE_LIST = (8)              ' Resource list in the resource map
Public Const REG_FULL_RESOURCE_DESCRIPTOR = (9)   ' Resource list in the hardware description
Public Const REG_RESOURCE_REQUIREMENTS_LIST = (10)
                                  
Declare Function GetCursorPos Lib "user32" (lpPoint As POINTAPI) As Long
Type POINTAPI
        x As Long
        Y As Long
End Type




Public Declare Function AnyPopup Lib "user32" () As Long
Public Declare Function ShowOwnedPopups Lib "user32" (ByVal hwnd As Long, ByVal fShow As Long) As Long

Public Const EWX_LOGOFF = 0
Public Const EWX_SHUTDOWN = 1
Public Const EWX_REBOOT = 2
Public Const EWX_FORCE = 4

Public Declare Function ExitWindowsEx Lib "user32" (ByVal uFlags As Long, ByVal dwReserved As Long) As Long

Public Const INFINITE = -1&

Public Declare Function DrawFocusRect Lib "user32" (ByVal hdc As Long, lpRect As RECT) As Long
Public Declare Function OpenProcess Lib "kernel32" (ByVal dwDesiredAccess As Long, ByVal bInheritHandle As Long, ByVal dwProcessId As Long) As Long
Public Declare Function CloseHandle Lib "kernel32" (ByVal hObject As Long) As Long
Public Declare Function GetExitCodeProcess Lib "kernel32" (ByVal hProcess As Long, lpExitCode As Long) As Long
Public Declare Sub Sleep Lib "kernel32" (ByVal dwMilliseconds As Long)
Public Declare Function WaitForSingleObject Lib "kernel32" (ByVal hHandle As Long, ByVal dwMilliseconds As Long) As Long
Public Declare Function GetWindowThreadProcessId Lib "user32" (ByVal hwnd As Long, lpdwProcessId As Long) As Long
Public Declare Function IsWindow Lib "user32" (ByVal hwnd As Long) As Long
Public Declare Function FindWindow Lib "user32" Alias "FindWindowA" (ByVal lpClassName As String, ByVal lpWindowName As String) As Long
Public Declare Function FillRect Lib "user32" (ByVal hdc As Long, lpRect As RECT, ByVal hBrush As Long) As Long

Public Declare Function TextOutBStr Lib "gdi32" Alias "TextOutA" (ByVal hdc As Long, ByVal x As Long, ByVal Y As Long, lpString As Any, ByVal nCount As Long) As Long

Public Declare Function SetTextAlign Lib "gdi32" (ByVal hdc As Long, ByVal wFlags As Long) As Long
Public Declare Function SetTextColor Lib "gdi32" (ByVal hdc As Long, ByVal crColor As Long) As Long
Public Declare Function SetBkColor Lib "gdi32" (ByVal hdc As Long, ByVal crColor As Long) As Long
Public Declare Function InvalidateRect Lib "user32" (ByVal hwnd As Long, lpRect As RECT, ByVal bErase As Long) As Long


Public Declare Function DeleteObject Lib "gdi32" (ByVal hObject As Long) As Long
Public Declare Function CreateSolidBrush Lib "gdi32" (ByVal crColor As Long) As Long

Public Declare Function SendMessage Lib "user32" Alias "SendMessageA" (ByVal hwnd As Long, ByVal wMsg As Long, ByVal wParam As Long, lParam As Long) As Long

Public Declare Function GetSysColor Lib "user32" (ByVal nIndex As Long) As Long

Public Declare Function GetWindow Lib "user32" (ByVal hwnd As Long, ByVal wCmd As Long) As Long
Public Declare Function GetWindowText Lib "user32" Alias "GetWindowTextA" (ByVal hwnd As Long, ByVal lpString As String, ByVal cch As Long) As Long
Public Declare Function GetParent Lib "user32" (ByVal hwnd As Long) As Long
Public Declare Function SetWindowsHookEx Lib "user32" Alias "SetWindowsHookExA" (ByVal idHook As Long, ByVal lpfn As Long, ByVal hmod As Long, ByVal dwThreadId As Long) As Long

' ** Constants relating to the selected status of list item:
Public Const ODA_FOCUS = &H4       ' This is for the List box of Combo box!
Public Const ODS_FOCUS = &H10
Public Const ODS_SELECTED = &H1

' The Windows Standard colors constants:- To be used with GetSysColor call
Public Const COLOR_WINDOW = 5
Public Const COLOR_WINDOWTEXT = 8
Public Const COLOR_HIGHLIGHT = 13
Public Const COLOR_HIGHLIGHTTEXT = 14
Public Const COLOR_GRAYTEXT = 17


Public Const STILL_ACTIVE = &H103

'Private Const SYNCHRONIZE = &H100000

Public Const WAIT_FAILED = -1&        'Error on call
'Public Const WAIT_OBJECT_0 = 0        'Normal completion
'Public Const WAIT_ABANDONED = &H80&   '
'Public Const WAIT_TIMEOUT = &H102&    'Timeout period elapsed
Public Const IGNORE = 0               'Ignore signal


Public Const SW_HIDE = 0
Public Const SW_SHOWNORMAL = 1
Public Const SW_SHOWMINIMIZED = 2
Public Const SW_SHOWMAXIMIZED = 3
Public Const SW_SHOWNOACTIVATE = 4
Public Const SW_SHOW = 5
Public Const SW_MINIMIZE = 6
Public Const SW_SHOWMINNOACTIVE = 7
Public Const SW_SHOWNA = 8
Public Const SW_RESTORE = 9



Public Const PROCESS_TERMINATE = &H1
Public Const PROCESS_CREATE_THREAD = &H2
Public Const PROCESS_VM_OPERATION = &H8
Public Const PROCESS_VM_READ = &H10
Public Const PROCESS_VM_WRITE = &H20
Public Const PROCESS_DUP_HANDLE = &H40
Public Const PROCESS_CREATE_PROCESS = &H80
Public Const PROCESS_SET_QUOTA = &H100
Public Const PROCESS_SET_INFORMATION = &H200
Public Const PROCESS_QUERY_INFORMATION = &H400

'/*
' * GetWindow() Constants
' */
Public Enum eGetWindow
     GW_HWNDFIRST = 0
    GW_HWNDLAST = 1
    GW_HWNDNEXT = 2
    GW_HWNDPREV = 3
    GW_OWNER = 4
    GW_CHILD = 5
    GW_MAX = 5
End Enum




'/*
' * Browse dir api
' */
Public Const BIF_RETURNONLYFSDIRS = &H1

Public Type SHITEMID
  cb      As Long
  abID    As Byte
End Type

Public Type ITEMIDLIST
  mkid    As SHITEMID
End Type

Public Type BROWSEINFO
  hOwner          As Long
  pidlRoot        As Long
  pszDisplayName  As String
  lpszTitle       As String
  ulFlags         As Long
  lpfn            As Long
  lParam          As Long
  iImage          As Long
End Type

Public Declare Function SHGetPathFromIDList Lib "shell32.dll" Alias "SHGetPathFromIDListA" (ByVal pidl As Long, ByVal pszPath As String) As Long
Public Declare Function SHBrowseForFolder Lib "shell32.dll" Alias "SHBrowseForFolderA" (lpBrowseInfo As BROWSEINFO) As Long
   
Public Declare Function GetTickCount Lib "kernel32" () As Long
'Declare Sub Sleep Lib "kernel32" (ByVal dwMilliseconds As Long)

' SetWindowPos() hwndInsertAfter values
Public Const HWND_TOP = 0
Public Const HWND_BOTTOM = 1
Public Const HWND_TOPMOST = -1
Public Const HWND_NOTOPMOST = -2

' SetWindowPos Flags
Public Const SWP_NOSIZE = &H1
Public Const SWP_NOMOVE = &H2
Public Const SWP_NOZORDER = &H4
Public Const SWP_NOREDRAW = &H8
Public Const SWP_NOACTIVATE = &H10
Public Const SWP_FRAMECHANGED = &H20        '  The frame changed: send WM_NCCALCSIZE
Public Const SWP_SHOWWINDOW = &H40
Public Const SWP_HIDEWINDOW = &H80
Public Const SWP_NOCOPYBITS = &H100
Public Const SWP_NOOWNERZORDER = &H200      '  Don't do owner Z ordering

Public Const SWP_DRAWFRAME = SWP_FRAMECHANGED
Public Const SWP_NOREPOSITION = SWP_NOOWNERZORDER


Declare Function SetWindowPos Lib "user32" (ByVal hwnd As Long, ByVal hWndInsertAfter As Long, ByVal x As Long, ByVal Y As Long, ByVal cx As Long, ByVal cy As Long, ByVal wFlags As Long) As Long


Declare Function ReleaseCapture Lib "user32" () As Long
'Declare Function SendMessage Lib "user32" _
'    Alias "SendMessageA" ( _
'    ByVal hwnd As Long, ByVal wMsg As Long, _
'    ByVal wParam As Long, lParam As Any) As Long
Public Const HTCAPTION = 2
'Public Const WM_NCLBUTTONDOWN = &HA1


Declare Function GetWindowsDirectory Lib "kernel32" Alias "GetWindowsDirectoryA" (ByVal lpBuffer As String, ByVal nSize As Long) As Long

Public Declare Function GetComputerName Lib "kernel32" Alias "GetComputerNameA" (ByVal lpBuffer As String, nSize As Long) As Long
Public Declare Function SetMenu Lib "user32" (ByVal hwnd As Long, ByVal hMenu As Long) As Long
Public Declare Function DrawMenuBar Lib "user32" (ByVal hwnd As Long) As Long
Public Declare Function GetClassName Lib "user32" Alias "GetClassNameA" (ByVal hwnd As Long, ByVal lpClassName As String, ByVal nMaxCount As Long) As Long

Const HKEY_CLASSES_ROOT = &H80000000
Const HKEY_CURRENT_USER = &H80000001
Const HKEY_LOCAL_MACHINE = &H80000002
Const HKEY_USERS = &H80000003

Public Const ERROR_SUCCESS = 0&


Enum HelpCommandValues

cdlHelpCommandHelp = &H102  ' Displays Help for a particular command
cdlHelpContents = &H3 '    Displays the contents topic in the current Help file
cdlHelpContext = &H1  '   Displays Help for a particular topic
cdlHelpContextPopup = &H8 '    Displays a topic identified by a context number
cdlHelpForceFile = &H9    '   Creates a Help file that displays text in only one font
cdlHelpHelpOnHelp = &H4    '  Displays Help for using the Help application itself
cdlHelpIndex = &H3       'Displays the index of the specified Help file
cdlHelpKey = &H101  ' Displays Help for a particular keyword
cdlHelpPartialKey = &H105  '  Calls the search engine in Windows Help
cdlHelpQuit = &H2    'Notifies the Help application that the specified Help file is no longer in use
cdlHelpSetContents = &H5 '    Designates a specific topic as the contents topic
cdlHelpSetIndex = &H5    'Sets the current index for multi-index Help
End Enum


Public Declare Function ShellExecute Lib "shell32.dll" Alias "ShellExecuteA" (ByVal hwnd As Long, ByVal lpOperation As String, ByVal lpFile As String, ByVal lpParameters As String, ByVal lpDirectory As String, ByVal nShowCmd As Long) As Long



Public Declare Function SendMessageLong Lib "user32" Alias "SendMessageA" _
   (ByVal hwnd As Long, _
    ByVal wMsg As Long, _
    ByVal wParam As Long, _
    ByVal lParam As Long) As Long

Public Declare Function SendMessageAny Lib "user32" Alias "SendMessageA" _
   (ByVal hwnd As Long, _
    ByVal wMsg As Long, _
    ByVal wParam As Long, _
    lParam As Any) As Long
       
Public Const LVM_FIRST = &H1000
Public Const LVM_SETITEMSTATE = (LVM_FIRST + 43)
Public Const LVM_GETITEMSTATE As Long = (LVM_FIRST + 44)
Public Const LVM_GETITEMTEXT = (LVM_FIRST + 45)
Public Const LVM_SETEXTENDEDLISTVIEWSTYLE = (LVM_FIRST + 54)
Public Const LVM_GETEXTENDEDLISTVIEWSTYLE = (LVM_FIRST + 55)

Public Const LVS_EX_GRIDLINES = &H1
Public Const LVS_EX_CHECKBOXES = &H4
Public Const LVS_EX_FULLROWSELECT = &H20          'applies to report mode only

Public Const LVIF_STATE = &H8
Public Const LVIS_STATEIMAGEMASK As Long = &HF000
 
Public Const SW_NORMAL = 1
'Public Const SW_SHOWMAXIMIZED = 3
Public Const SW_SHOWDEFAULT = 10
'Public Const SW_SHOWNOACTIVATE = 4
'Public Const SW_SHOWNORMAL = 1

Public Type LVITEM
    mask As Long
    iItem As Long
    iSubItem As Long
    state As Long
    stateMask As Long
    pszText As String
    cchTextMax As Long
    iImage As Long
    lParam As Long
    iIndent As Long
End Type
 
 
Public Type LVCOLUMN
    mask As Long
    fmt As Long
    cx As Long
    pszText  As String
    cchTextMax As Long
    iSubItem As Long
    iImage As Long
    iOrder As Long
End Type

Public Const MAX_PATH = 255
    
Public Declare Function GetDesktopWindow Lib "user32" () As Long

'Public Declare Function ShellExecute Lib "shell32.dll" Alias "ShellExecuteA" _
'   (ByVal hwnd As Long, ByVal lpOperation As String, _
'    ByVal lpFile As String, ByVal lpParameters As String, _
'    ByVal lpDirectory As String, ByVal nShowCmd As Long) As Long


'Public Const LVM_FIRST = &H1000
'Public Const LVM_SETEXTENDEDLISTVIEWSTYLE = LVM_FIRST + 54
'Public Const LVM_GETEXTENDEDLISTVIEWSTYLE = LVM_FIRST + 55
'Public Const LVS_EX_FULLROWSELECT = &H20
'Public Const LVS_EX_GRIDLINES = &H1
'Public Const LVS_EX_CHECKBOXES = &H4
Public Const LVS_EX_HEADERDRAGDROP = &H10
Public Const LVS_EX_TRACKSELECT = &H8
Public Const LVS_EX_ONECLICKACTIVATE = &H40
Public Const LVS_EX_TWOCLICKACTIVATE = &H80
Public Const LVS_EX_SUBITEMIMAGES = &H2

' ******************************************************************************************************************************************************************
' ** TRAY ICON
' ******************************************************************************************************************************************************************

Public Type NOTIFYICONDATA
    cbSize              As Long
    hwnd                As Long
    uID                 As Long
    uFlags              As Long
    uCallbackMessage    As Long
    hIcon               As Long
    szTip               As String * 64
End Type

Public Declare Function Shell_NotifyIcon Lib "shell32.dll" Alias "Shell_NotifyIconA" (ByVal dwMessage As Long, lpData As NOTIFYICONDATA) As Long

Public Const NIM_ADD = &H0
Public Const NIM_MODIFY = &H1
Public Const NIM_DELETE = &H2
Public Const NIF_MESSAGE = &H1
Public Const NIF_ICON = &H2
Public Const NIF_TIP = &H4
'Make your own constant, e.g.:
Public Const NIF_DOALL = NIF_MESSAGE Or NIF_ICON Or NIF_TIP
'Public Const WM_MOUSEMOVE = &H200
'Public Const WM_LBUTTONDBLCLK = &H203
'Public Const WM_LBUTTONDOWN = &H201
'Public Const WM_RBUTTONDOWN = &H204


'Public Const WM_MOUSEFIRST = &H200
'Public Const WM_MOUSEMOVE = &H200
'Public Const WM_LBUTTONDOWN = &H201
'Public Const WM_LBUTTONUP = &H202
'Public Const WM_LBUTTONDBLCLK = &H203
'Public Const WM_RBUTTONDOWN = &H204
'Public Const WM_RBUTTONUP = &H205
'Public Const WM_RBUTTONDBLCLK = &H206
'Public Const WM_MBUTTONDOWN = &H207
'Public Const WM_MBUTTONUP = &H208
'Public Const WM_MBUTTONDBLCLK = &H209
'Public Const WM_MOUSELAST = &H209


' ******************************************************************************************************************************************************************
' ** COM CONSTANTES
' ******************************************************************************************************************************************************************

Public Const vbComHResult = 24
Public Const vbComULong = 19
Public Const vbComUInt = 23
Public Const vbComwORD = 18






Public Declare Function WNetGetUser Lib "mpr.dll" Alias "WNetGetUserA" (ByVal lpName As String, ByVal lpUserName As String, lpnLength As Long) As Long
Public Declare Function GetUserName Lib "advapi32.dll" Alias "GetUserNameA" (ByVal lpBuffer As String, nSize As Long) As Long
'Private Declare Function GetComputerName Lib "kernel32" Alias "GetComputerNameA" (ByVal lpBuffer As String, nSize As Long) As Long

Public Type OSVERSIONINFO
    dwVersionInfoSize   As Long
    dwMajorVersion      As Long
    dwMinorVersion      As Long
    dwBuildNumber       As Long
    dwPlatform          As Long
    szCSDVersion        As String * 128
End Type

Public Declare Function GetVersionEx& Lib "kernel32" Alias "GetVersionExA" (lpStruct As OSVERSIONINFO)




Public Declare Sub GlobalMemoryStatus Lib "kernel32" (lpBuffer As MEMORYSTATUS)
Public Declare Function GetMenu Lib "user32" (ByVal hwnd As Long) As Long
Public Declare Function GetSubMenu Lib "user32" (ByVal hMenu As Long, ByVal nPos As Long) As Long
Public Declare Function GetMenuItemID Lib "user32" (ByVal hMenu As Long, ByVal nPos As Long) As Long
Public Declare Function SetMenuItemBitmaps Lib "user32" (ByVal hMenu As Long, ByVal nPosition As Long, ByVal wFlags As Long, ByVal hBitmapUnchecked As Long, ByVal hBitmapChecked As Long) As Long
Public Declare Function GetMenuItemCount Lib "user32" (ByVal hMenu As Long) As Long
Public Const MF_BITMAP = &H4&

Type MENUITEMINFO
    cbSize As Long
    fMask As Long
    fType As Long
    fState As Long
    wID As Long
    hSubMenu As Long
    hbmpChecked As Long
    hbmpUnchecked As Long
    dwItemData As Long
    dwTypeData As String
    cch As Long
End Type



Declare Function GetMenuItemInfo Lib "user32" Alias "GetMenuItemInfoA" (ByVal hMenu As Long, ByVal un As Long, ByVal b As Boolean, lpMenuItemInfo As MENUITEMINFO) As Boolean

Public Const MIIM_ID = &H2
Public Const MIIM_TYPE = &H10
Public Const MFT_STRING = &H0&


Public Declare Sub CopyMemory Lib "kernel32" Alias "RtlMoveMemory" (pDest As Any, pSource As Any, ByVal ByteLen As Long)

Public Declare Function GetWindowLong Lib "user32" Alias "GetWindowLongA" (ByVal hwnd As Long, ByVal nIndex As Long) As Long
Public Declare Function SetWindowLong Lib "user32" Alias "SetWindowLongA" (ByVal hwnd As Long, ByVal nIndex As Long, ByVal dwNewLong As Long) As Long
' Window field offsets for GetWindowLong() and GetWindowWord()

Public Const GWL_WNDPROC = (-4)
Public Const GWL_HINSTANCE = (-6)
Public Const GWL_HWNDPARENT = (-8)
Public Const GWL_STYLE = (-16)
Public Const GWL_EXSTYLE = (-20)
Public Const GWL_USERDATA = (-21)
Public Const GWL_ID = (-12)


'  Scroll bar messages
Public Const SBM_SETPOS = &HE0 ' not in win3.1
Public Const SBM_GETPOS = &HE1 ' not in win3.1
Public Const SBM_SETRANGE = &HE2 ' not in win3.1
Public Const SBM_SETRANGEREDRAW = &HE6 ' not in win3.1
Public Const SBM_GETRANGE = &HE3 ' not in win3.1
Public Const SBM_ENABLE_ARROWS = &HE4 ' not in win3.1

Type TLONG
    l As Long
End Type


Type T2DWORD
    lo As Integer
    hi As Integer
End Type

'Public Declare Sub CopyMemory Lib "KERNEL32" Alias "RtlMoveMemory" (lpvDest As Any, lpvSource As Any, ByVal cbCopy As Long)

'Public Const WM_MENUSELECT = &H11F
'Public Const WM_MENUCHAR = &H120


Public Declare Sub OutputDebugString Lib "kernel32" Alias "OutputDebugStringA" (ByVal lpOutputString As String)
       
         

Declare Sub DebugBreak Lib "kernel32" ()


' ********************************************************************************************************************************************************************************
' ***  WINDOW MESSAGE WM_xxxxxxxx
' ********************************************************************************************************************************************************************************

Public Const WM_NULL = &H0
Public Const WM_CREATE = &H1
Public Const WM_DESTROY = &H2
Public Const WM_MOVE = &H3
Public Const WM_SIZE = &H5
Public Const WM_ACTIVATE = &H6
Public Const WM_SETFOCUS = &H7
Public Const WM_KILLFOCUS = &H8
Public Const WM_ENABLE = &HA
Public Const WM_SETREDRAW = &HB
Public Const WM_SETTEXT = &HC
Public Const WM_GETTEXT = &HD
Public Const WM_GETTEXTLENGTH = &HE
Public Const WM_PAINT = &HF
Public Const WM_CLOSE = &H10
Public Const WM_QUERYENDSESSION = &H11
Public Const WM_QUIT = &H12
Public Const WM_QUERYOPEN = &H13
Public Const WM_ERASEBKGND = &H14
Public Const WM_SYSCOLORCHANGE = &H15
Public Const WM_ENDSESSION = &H16
Public Const WM_SHOWWINDOW = &H18
Public Const WM_WININICHANGE = &H1A
Public Const WM_SETTINGCHANGE = WM_WININICHANGE
Public Const WM_DEVMODECHANGE = &H1B
Public Const WM_ACTIVATEAPP = &H1C
Public Const WM_FONTCHANGE = &H1D
Public Const WM_TIMECHANGE = &H1E
Public Const WM_CANCELMODE = &H1F
Public Const WM_SETCURSOR = &H20
Public Const WM_MOUSEACTIVATE = &H21
Public Const WM_CHILDACTIVATE = &H22
Public Const WM_QUEUESYNC = &H23
Public Const WM_GETMINMAXINFO = &H24
Public Const WM_PAINTICON = &H26
Public Const WM_ICONERASEBKGND = &H27
Public Const WM_NEXTDLGCTL = &H28
Public Const WM_SPOOLERSTATUS = &H2A
Public Const WM_DRAWITEM = &H2B
Public Const WM_MEASUREITEM = &H2C
Public Const WM_DELETEITEM = &H2D
Public Const WM_VKEYTOITEM = &H2E
Public Const WM_CHARTOITEM = &H2F
Public Const WM_SETFONT = &H30
Public Const WM_GETFONT = &H31
Public Const WM_SETHOTKEY = &H32
Public Const WM_GETHOTKEY = &H33
Public Const WM_QUERYDRAGICON = &H37
Public Const WM_COMPAREITEM = &H39
Public Const WM_GETOBJECT = &H3D
Public Const WM_COMPACTING = &H41
Public Const WM_COMMNOTIFY = &H44
Public Const WM_WINDOWPOSCHANGING = &H46
Public Const WM_WINDOWPOSCHANGED = &H47
Public Const WM_POWER = &H48
Public Const WM_COPYDATA = &H4A
Public Const WM_CANCELJOURNAL = &H4B
Public Const WM_NOTIFY = &H4E
Public Const WM_INPUTLANGCHANGEREQUEST = &H50
Public Const WM_INPUTLANGCHANGE = &H51
Public Const WM_TCARD = &H52
Public Const WM_HELP = &H53
Public Const WM_USERCHANGED = &H54
Public Const WM_NOTIFYFORMAT = &H55
Public Const WM_CONTEXTMENU = &H7B
Public Const WM_STYLECHANGING = &H7C
Public Const WM_STYLECHANGED = &H7D
Public Const WM_DISPLAYCHANGE = &H7E
Public Const WM_GETICON = &H7F
Public Const WM_SETICON = &H80
Public Const WM_NCCREATE = &H81
Public Const WM_NCDESTROY = &H82
Public Const WM_NCCALCSIZE = &H83
Public Const WM_NCHITTEST = &H84
Public Const WM_NCPAINT = &H85
Public Const WM_NCACTIVATE = &H86
Public Const WM_GETDLGCODE = &H87
Public Const WM_SYNCPAINT = &H88
Public Const WM_NCMOUSEMOVE = &HA0
Public Const WM_NCLBUTTONDOWN = &HA1
Public Const WM_NCLBUTTONUP = &HA2
Public Const WM_NCLBUTTONDBLCLK = &HA3
Public Const WM_NCRBUTTONDOWN = &HA4
Public Const WM_NCRBUTTONUP = &HA5
Public Const WM_NCRBUTTONDBLCLK = &HA6
Public Const WM_NCMBUTTONDOWN = &HA7
Public Const WM_NCMBUTTONUP = &HA8
Public Const WM_NCMBUTTONDBLCLK = &HA9
Public Const WM_KEYFIRST = &H100
Public Const WM_KEYDOWN = &H100
Public Const WM_KEYUP = &H101
Public Const WM_CHAR = &H102
Public Const WM_DEADCHAR = &H103
Public Const WM_SYSKEYDOWN = &H104
Public Const WM_SYSKEYUP = &H105
Public Const WM_SYSCHAR = &H106
Public Const WM_SYSDEADCHAR = &H107
Public Const WM_KEYLAST = &H108
Public Const WM_IME_STARTCOMPOSITION = &H10D
Public Const WM_IME_ENDCOMPOSITION = &H10E
Public Const WM_IME_COMPOSITION = &H10F
Public Const WM_IME_KEYLAST = &H10F
Public Const WM_INITDIALOG = &H110
Public Const WM_COMMAND = &H111
Public Const WM_SYSCOMMAND = &H112
Public Const WM_TIMER = &H113
Public Const WM_HSCROLL = &H114
Public Const WM_VSCROLL = &H115
Public Const WM_INITMENU = &H116
Public Const WM_INITMENUPOPUP = &H117
Public Const WM_MENUSELECT = &H11F
Public Const WM_MENUCHAR = &H120
Public Const WM_ENTERIDLE = &H121
Public Const WM_MENURBUTTONUP = &H122
Public Const WM_MENUDRAG = &H123
Public Const WM_MENUGETOBJECT = &H124
Public Const WM_UNINITMENUPOPUP = &H125
Public Const WM_MENUCOMMAND = &H126
Public Const WM_CTLCOLORMSGBOX = &H132
Public Const WM_CTLCOLOREDIT = &H133
Public Const WM_CTLCOLORLISTBOX = &H134
Public Const WM_CTLCOLORBTN = &H135
Public Const WM_CTLCOLORDLG = &H136
Public Const WM_CTLCOLORSCROLLBAR = &H137
Public Const WM_CTLCOLORSTATIC = &H138
Public Const WM_MOUSEFIRST = &H200
Public Const WM_MOUSEMOVE = &H200
Public Const WM_LBUTTONDOWN = &H201
Public Const WM_LBUTTONUP = &H202
Public Const WM_LBUTTONDBLCLK = &H203
Public Const WM_RBUTTONDOWN = &H204
Public Const WM_RBUTTONUP = &H205
Public Const WM_RBUTTONDBLCLK = &H206
Public Const WM_MBUTTONDOWN = &H207
Public Const WM_MBUTTONUP = &H208
Public Const WM_MBUTTONDBLCLK = &H209
Public Const WM_MOUSEWHEEL = &H20A
Public Const WM_MOUSELAST = &H20A
Public Const WM_PARENTNOTIFY = &H210
Public Const WM_ENTERMENULOOP = &H211
Public Const WM_EXITMENULOOP = &H212
Public Const WM_NEXTMENU = &H213
Public Const WM_SIZING = &H214
Public Const WM_CAPTURECHANGED = &H215
Public Const WM_MOVING = &H216
Public Const WM_POWERBROADCAST = &H218
Public Const WM_DEVICECHANGE = &H219
Public Const WM_MDICREATE = &H220
Public Const WM_MDIDESTROY = &H221
Public Const WM_MDIACTIVATE = &H222
Public Const WM_MDIRESTORE = &H223
Public Const WM_MDINEXT = &H224
Public Const WM_MDIMAXIMIZE = &H225
Public Const WM_MDITILE = &H226
Public Const WM_MDICASCADE = &H227
Public Const WM_MDIICONARRANGE = &H228
Public Const WM_MDIGETACTIVE = &H229
Public Const WM_MDISETMENU = &H230
Public Const WM_ENTERSIZEMOVE = &H231
Public Const WM_EXITSIZEMOVE = &H232
Public Const WM_DROPFILES = &H233
Public Const WM_MDIREFRESHMENU = &H234
Public Const WM_IME_SETCONTEXT = &H281
Public Const WM_IME_NOTIFY = &H282
Public Const WM_IME_CONTROL = &H283
Public Const WM_IME_COMPOSITIONFULL = &H284
Public Const WM_IME_SELECT = &H285
Public Const WM_IME_CHAR = &H286
Public Const WM_IME_REQUEST = &H288
Public Const WM_IME_KEYDOWN = &H290
Public Const WM_IME_KEYUP = &H291
Public Const WM_MOUSEHOVER = &H2A1
Public Const WM_MOUSELEAVE = &H2A3
Public Const WM_CUT = &H300
Public Const WM_COPY = &H301
Public Const WM_PASTE = &H302
Public Const WM_CLEAR = &H303
Public Const WM_UNDO = &H304
Public Const WM_RENDERFORMAT = &H305
Public Const WM_RENDERALLFORMATS = &H306
Public Const WM_DESTROYCLIPBOARD = &H307
Public Const WM_DRAWCLIPBOARD = &H308
Public Const WM_PAINTCLIPBOARD = &H309
Public Const WM_VSCROLLCLIPBOARD = &H30A
Public Const WM_SIZECLIPBOARD = &H30B
Public Const WM_ASKCBFORMATNAME = &H30C
Public Const WM_CHANGECBCHAIN = &H30D
Public Const WM_HSCROLLCLIPBOARD = &H30E
Public Const WM_QUERYNEWPALETTE = &H30F
Public Const WM_PALETTEISCHANGING = &H310
Public Const WM_PALETTECHANGED = &H311
Public Const WM_HOTKEY = &H312
Public Const WM_PRINT = &H317
Public Const WM_PRINTCLIENT = &H318
Public Const WM_HANDHELDFIRST = &H358
Public Const WM_HANDHELDLAST = &H35F
Public Const WM_AFXFIRST = &H360
Public Const WM_AFXLAST = &H37F
Public Const WM_PENWINFIRST = &H380
Public Const WM_PENWINLAST = &H38F
Public Const WM_APP = &H8000
Public Const WM_USER = &H400

Public Declare Function GetTmpPath Lib "kernel32" Alias "GetTempPathA" (ByVal nBufferLength As Long, ByVal lpBuffer As String) As Long


Public Const FO_COPY = &H2

Public Const FOF_SIMPLEPROGRESS = &H100

Public Const FOF_NOCONFIRMATION = &H10


Public Declare Function SHFileOperation Lib "shell32.dll" Alias "SHFileOperationA" (lpFileOp As SHFILEOPSTRUCT) As Long




    
'Public Declare Function FindWindow Lib "user32" Alias "FindWindowA" (ByVal lpClassName As String, ByVal lpWindowName As String) As Long
Public Declare Function ShowWindow Lib "user32" (ByVal hwnd As Long, ByVal nCmdShow As Long) As Long
Public Declare Function EnableWindow Lib "user32" (ByVal hwnd As Long, ByVal fEnable As Long) As Long

Public Declare Function EnumWindows Lib "user32" (ByVal lpEnumFunc As Long, lParam As Any) As Long
'Public Declare Function GetWindowText Lib "user32" Alias "GetWindowTextA" (ByVal hwnd As Long, ByVal lpString As String, ByVal cch As Long) As Long

Public Declare Function EnumChildWindows Lib "user32" (ByVal hWndParent As Long, ByVal lpEnumFunc As Long, ByVal lParam As Long) As Long
Public Declare Function EnumDesktops Lib "user32" Alias "EnumDesktopsA" (ByVal hwinsta As Long, ByVal lpEnumFunc As Long, ByVal lParam As Long) As Long
Public Declare Function EnumDesktopWindows Lib "user32" (ByVal hDesktop As Long, ByVal lpfn As Long, ByVal lParam As Long) As Long
Public Declare Function EnumPropsEx Lib "user32" Alias "EnumPropsExA" (ByVal hwnd As Long, ByVal lpEnumFunc As Long, ByVal lParam As Long) As Long
Public Declare Function EnumProps Lib "user32" Alias "EnumPropsA" (ByVal hwnd As Long, ByVal lpEnumFunc As Long) As Long
Public Declare Function EnumThreadWindows Lib "user32" (ByVal dwThreadId As Long, ByVal lpfn As Long, ByVal lParam As Long) As Long

Public Declare Function EnumWindowStations Lib "user32" Alias "EnumWindowStationsA" (ByVal lpEnumFunc As Long, ByVal lParam As Long) As Long
Public Declare Function FindWindowEx Lib "user32" Alias "FindWindowExA" (ByVal hWnd1 As Long, ByVal hWnd2 As Long, ByVal lpsz1 As String, ByVal lpsz2 As String) As Long

'Public Declare Function GetDesktopWindow Lib "user32" () As Long

'Public Declare Function GetWindow Lib "user32" (ByVal hwnd As Long, ByVal wCmd As Long) As Long

Declare Function IsWindowVisible Lib "user32" (ByVal hwnd As Long) As Long

Public Declare Function GetWindowRect Lib "user32" (ByVal hwnd As Long, lpRect As RECT) As Long
Public Declare Function MoveWindow Lib "user32" (ByVal hwnd As Long, ByVal x As Long, ByVal Y As Long, ByVal nWidth As Long, ByVal nHeight As Long, ByVal bRepaint As Long) As Long
Public Declare Function IsZoomed Lib "user32" (ByVal hwnd As Long) As Long
Public Declare Function IsIconic Lib "user32" (ByVal hwnd As Long) As Long
Public Declare Function GetClientRect Lib "user32" (ByVal hwnd As Long, lpRect As RECT) As Long
Public Declare Function GetDC Lib "user32" (ByVal hwnd As Long) As Long
Public Declare Function ReleaseDC Lib "user32" (ByVal hwnd As Long, ByVal hdc As Long) As Long
Public Declare Function StretchBlt Lib "gdi32" (ByVal hdc As Long, ByVal x As Long, ByVal Y As Long, ByVal nWidth As Long, ByVal nHeight As Long, ByVal hSrcDC As Long, ByVal xSrc As Long, ByVal ySrc As Long, ByVal nSrcWidth As Long, ByVal nSrcHeight As Long, ByVal dwRop As Long) As Long
Public Declare Function SetActiveWindow Lib "user32" (ByVal hwnd As Long) As Long
Public Declare Function FlashWindow Lib "user32" (ByVal hwnd As Long, ByVal bInvert As Long) As Long


Public Type RECT

        Left    As Long
        Top     As Long
        Right   As Long
        Bottom  As Long
End Type

Public Const ODT_LISTBOX = 2


Type DRAWITEMSTRUCT
    CtlType As Long
    CtlID As Long
    itemID As Long
    itemAction As Long
    itemState As Long
    hwndItem As Long
    hdc As Long
    rcItem As RECT
    itemData As Long
End Type


Public Const LBN_SELCHANGE = 1
Public Const LBN_DBLCLK = 2
Public Const LBN_SELCANCEL = 3
Public Const LBN_SETFOCUS = 4
Public Const LBN_KILLFOCUS = 5


'Public Const LB_SETCURSEL = &H186
'Public Const LB_GETSEL = &H187
'Public Const LB_GETCURSEL = &H188
'Public Const LB_GETTEXT = &H189
'Public Const LB_GETTEXTLEN = &H18A



Public Type SHFILEOPSTRUCT
    hwnd As Long
    wFunc As Long
    pFrom As String
    pTo As String
    fFlags As Integer
    fAnyOperationsAborted As Boolean
    hNameMappings As Long
    lpszProgressTitle As String
End Type

Public Declare Function SetCursorPos Lib "user32" (ByVal x As Long, ByVal Y As Long) As Long

Declare Function PostMessage Lib "user32" Alias "PostMessageA" (ByVal hwnd As Long, ByVal wMsg As Long, ByVal wParam As Long, ByVal lParam As Long) As Long

Declare Function SHShutDownDialog Lib "shell32" Alias "#60" (ByVal lType As Long) As Long
    
Public Declare Function TextOut Lib "gdi32" Alias "TextOutA" (ByVal hdc As Long, ByVal x As Long, ByVal Y As Long, ByVal lpString As String, ByVal nCount As Long) As Long


' Windows api
'Public Declare Sub OutputDebugString Lib "kernel32" Alias "OutputDebugStringA" (ByVal lpOutputString As String)

Public Function WindowMessageString(lWindowMessage As Long) As String
    Select Case lWindowMessage
        Case WM_NULL
           WindowMessageString = "WM_NULL"
        Case WM_CREATE
           WindowMessageString = "WM_CREATE"
        Case WM_DESTROY
           WindowMessageString = "WM_DESTROY"
        Case WM_MOVE
           WindowMessageString = "WM_MOVE"
        Case WM_SIZE
           WindowMessageString = "WM_SIZE"
        Case WM_ACTIVATE
           WindowMessageString = "WM_ACTIVATE"
        Case WM_SETFOCUS
           WindowMessageString = "WM_SETFOCUS"
        Case WM_KILLFOCUS
           WindowMessageString = "WM_KILLFOCUS"
        Case WM_ENABLE
           WindowMessageString = "WM_ENABLE"
        Case WM_SETREDRAW
           WindowMessageString = "WM_SETREDRAW"
        Case WM_SETTEXT
           WindowMessageString = "WM_SETTEXT"
        Case WM_GETTEXT
           WindowMessageString = "WM_GETTEXT"
        Case WM_GETTEXTLENGTH
           WindowMessageString = "WM_GETTEXTLENGTH"
        Case WM_PAINT
           WindowMessageString = "WM_PAINT"
        Case WM_CLOSE
           WindowMessageString = "WM_CLOSE"
        Case WM_QUERYENDSESSION
           WindowMessageString = "WM_QUERYENDSESSION"
        Case WM_QUIT
           WindowMessageString = "WM_QUIT"
        Case WM_QUERYOPEN
           WindowMessageString = "WM_QUERYOPEN"
        Case WM_ERASEBKGND
           WindowMessageString = "WM_ERASEBKGND"
        Case WM_SYSCOLORCHANGE
           WindowMessageString = "WM_SYSCOLORCHANGE"
        Case WM_ENDSESSION
           WindowMessageString = "WM_ENDSESSION"
        Case WM_SHOWWINDOW
           WindowMessageString = "WM_SHOWWINDOW"
        Case WM_WININICHANGE
           WindowMessageString = "WM_WININICHANGE"
        Case WM_SETTINGCHANGE
           WindowMessageString = "WM_SETTINGCHANGE"
        Case WM_DEVMODECHANGE
           WindowMessageString = "WM_DEVMODECHANGE"
        Case WM_ACTIVATEAPP
           WindowMessageString = "WM_ACTIVATEAPP"
        Case WM_FONTCHANGE
           WindowMessageString = "WM_FONTCHANGE"
        Case WM_TIMECHANGE
           WindowMessageString = "WM_TIMECHANGE"
        Case WM_CANCELMODE
           WindowMessageString = "WM_CANCELMODE"
        Case WM_SETCURSOR
           WindowMessageString = "WM_SETCURSOR"
        Case WM_MOUSEACTIVATE
           WindowMessageString = "WM_MOUSEACTIVATE"
        Case WM_CHILDACTIVATE
           WindowMessageString = "WM_CHILDACTIVATE"
        Case WM_QUEUESYNC
           WindowMessageString = "WM_QUEUESYNC"
        Case WM_GETMINMAXINFO
           WindowMessageString = "WM_GETMINMAXINFO"
        Case WM_PAINTICON
           WindowMessageString = "WM_PAINTICON"
        Case WM_ICONERASEBKGND
           WindowMessageString = "WM_ICONERASEBKGND"
        Case WM_NEXTDLGCTL
           WindowMessageString = "WM_NEXTDLGCTL"
        Case WM_SPOOLERSTATUS
           WindowMessageString = "WM_SPOOLERSTATUS"
        Case WM_DRAWITEM
           WindowMessageString = "WM_DRAWITEM"
        Case WM_MEASUREITEM
           WindowMessageString = "WM_MEASUREITEM"
        Case WM_DELETEITEM
           WindowMessageString = "WM_DELETEITEM"
        Case WM_VKEYTOITEM
           WindowMessageString = "WM_VKEYTOITEM"
        Case WM_CHARTOITEM
           WindowMessageString = "WM_CHARTOITEM"
        Case WM_SETFONT
           WindowMessageString = "WM_SETFONT"
        Case WM_GETFONT
           WindowMessageString = "WM_GETFONT"
        Case WM_SETHOTKEY
           WindowMessageString = "WM_SETHOTKEY"
        Case WM_GETHOTKEY
           WindowMessageString = "WM_GETHOTKEY"
        Case WM_QUERYDRAGICON
           WindowMessageString = "WM_QUERYDRAGICON"
        Case WM_COMPAREITEM
           WindowMessageString = "WM_COMPAREITEM"
        Case WM_GETOBJECT
           WindowMessageString = "WM_GETOBJECT"
        Case WM_COMPACTING
           WindowMessageString = "WM_COMPACTING"
        Case WM_COMMNOTIFY
           WindowMessageString = "WM_COMMNOTIFY"
        Case WM_WINDOWPOSCHANGING
           WindowMessageString = "WM_WINDOWPOSCHANGING"
        Case WM_WINDOWPOSCHANGED
           WindowMessageString = "WM_WINDOWPOSCHANGED"
        Case WM_POWER
           WindowMessageString = "WM_POWER"
        Case WM_COPYDATA
           WindowMessageString = "WM_COPYDATA"
        Case WM_CANCELJOURNAL
           WindowMessageString = "WM_CANCELJOURNAL"
        Case WM_NOTIFY
           WindowMessageString = "WM_NOTIFY"
        Case WM_INPUTLANGCHANGEREQUEST
           WindowMessageString = "WM_INPUTLANGCHANGEREQUEST"
        Case WM_INPUTLANGCHANGE
           WindowMessageString = "WM_INPUTLANGCHANGE"
        Case WM_TCARD
           WindowMessageString = "WM_TCARD"
        Case WM_HELP
           WindowMessageString = "WM_HELP"
        Case WM_USERCHANGED
           WindowMessageString = "WM_USERCHANGED"
        Case WM_NOTIFYFORMAT
           WindowMessageString = "WM_NOTIFYFORMAT"
        Case WM_CONTEXTMENU
           WindowMessageString = "WM_CONTEXTMENU"
        Case WM_STYLECHANGING
           WindowMessageString = "WM_STYLECHANGING"
        Case WM_STYLECHANGED
           WindowMessageString = "WM_STYLECHANGED"
        Case WM_DISPLAYCHANGE
           WindowMessageString = "WM_DISPLAYCHANGE"
        Case WM_GETICON
           WindowMessageString = "WM_GETICON"
        Case WM_SETICON
           WindowMessageString = "WM_SETICON"
        Case WM_NCCREATE
           WindowMessageString = "WM_NCCREATE"
        Case WM_NCDESTROY
           WindowMessageString = "WM_NCDESTROY"
        Case WM_NCCALCSIZE
           WindowMessageString = "WM_NCCALCSIZE"
        Case WM_NCHITTEST
           WindowMessageString = "WM_NCHITTEST"
        Case WM_NCPAINT
           WindowMessageString = "WM_NCPAINT"
        Case WM_NCACTIVATE
           WindowMessageString = "WM_NCACTIVATE"
        Case WM_GETDLGCODE
           WindowMessageString = "WM_GETDLGCODE"
        Case WM_SYNCPAINT
           WindowMessageString = "WM_SYNCPAINT"
        Case WM_NCMOUSEMOVE
           WindowMessageString = "WM_NCMOUSEMOVE"
        Case WM_NCLBUTTONDOWN
           WindowMessageString = "WM_NCLBUTTONDOWN"
        Case WM_NCLBUTTONUP
           WindowMessageString = "WM_NCLBUTTONUP"
        Case WM_NCLBUTTONDBLCLK
           WindowMessageString = "WM_NCLBUTTONDBLCLK"
        Case WM_NCRBUTTONDOWN
           WindowMessageString = "WM_NCRBUTTONDOWN"
        Case WM_NCRBUTTONUP
           WindowMessageString = "WM_NCRBUTTONUP"
        Case WM_NCRBUTTONDBLCLK
           WindowMessageString = "WM_NCRBUTTONDBLCLK"
        Case WM_NCMBUTTONDOWN
           WindowMessageString = "WM_NCMBUTTONDOWN"
        Case WM_NCMBUTTONUP
           WindowMessageString = "WM_NCMBUTTONUP"
        Case WM_NCMBUTTONDBLCLK
           WindowMessageString = "WM_NCMBUTTONDBLCLK"
        Case WM_KEYFIRST
           WindowMessageString = "WM_KEYFIRST"
        Case WM_KEYDOWN
           WindowMessageString = "WM_KEYDOWN"
        Case WM_KEYUP
           WindowMessageString = "WM_KEYUP"
        Case WM_CHAR
           WindowMessageString = "WM_CHAR"
        Case WM_DEADCHAR
           WindowMessageString = "WM_DEADCHAR"
        Case WM_SYSKEYDOWN
           WindowMessageString = "WM_SYSKEYDOWN"
        Case WM_SYSKEYUP
           WindowMessageString = "WM_SYSKEYUP"
        Case WM_SYSCHAR
           WindowMessageString = "WM_SYSCHAR"
        Case WM_SYSDEADCHAR
           WindowMessageString = "WM_SYSDEADCHAR"
        Case WM_KEYLAST
           WindowMessageString = "WM_KEYLAST"
        Case WM_IME_STARTCOMPOSITION
           WindowMessageString = "WM_IME_STARTCOMPOSITION"
        Case WM_IME_ENDCOMPOSITION
           WindowMessageString = "WM_IME_ENDCOMPOSITION"
        Case WM_IME_COMPOSITION
           WindowMessageString = "WM_IME_COMPOSITION"
        Case WM_IME_KEYLAST
           WindowMessageString = "WM_IME_KEYLAST"
        Case WM_INITDIALOG
           WindowMessageString = "WM_INITDIALOG"
        Case WM_COMMAND
           WindowMessageString = "WM_COMMAND"
        Case WM_SYSCOMMAND
           WindowMessageString = "WM_SYSCOMMAND"
        Case WM_TIMER
           WindowMessageString = "WM_TIMER"
        Case WM_HSCROLL
           WindowMessageString = "WM_HSCROLL"
        Case WM_VSCROLL
           WindowMessageString = "WM_VSCROLL"
        Case WM_INITMENU
           WindowMessageString = "WM_INITMENU"
        Case WM_INITMENUPOPUP
           WindowMessageString = "WM_INITMENUPOPUP"
        Case WM_MENUSELECT
           WindowMessageString = "WM_MENUSELECT"
        Case WM_MENUCHAR
           WindowMessageString = "WM_MENUCHAR"
        Case WM_ENTERIDLE
           WindowMessageString = "WM_ENTERIDLE"
        Case WM_MENURBUTTONUP
           WindowMessageString = "WM_MENURBUTTONUP"
        Case WM_MENUDRAG
           WindowMessageString = "WM_MENUDRAG"
        Case WM_MENUGETOBJECT
           WindowMessageString = "WM_MENUGETOBJECT"
        Case WM_UNINITMENUPOPUP
           WindowMessageString = "WM_UNINITMENUPOPUP"
        Case WM_MENUCOMMAND
           WindowMessageString = "WM_MENUCOMMAND"
        Case WM_CTLCOLORMSGBOX
           WindowMessageString = "WM_CTLCOLORMSGBOX"
        Case WM_CTLCOLOREDIT
           WindowMessageString = "WM_CTLCOLOREDIT"
        Case WM_CTLCOLORLISTBOX
           WindowMessageString = "WM_CTLCOLORLISTBOX"
        Case WM_CTLCOLORBTN
           WindowMessageString = "WM_CTLCOLORBTN"
        Case WM_CTLCOLORDLG
           WindowMessageString = "WM_CTLCOLORDLG"
        Case WM_CTLCOLORSCROLLBAR
           WindowMessageString = "WM_CTLCOLORSCROLLBAR"
        Case WM_CTLCOLORSTATIC
           WindowMessageString = "WM_CTLCOLORSTATIC"
        Case WM_MOUSEFIRST
           WindowMessageString = "WM_MOUSEFIRST"
        Case WM_MOUSEMOVE
           WindowMessageString = "WM_MOUSEMOVE"
        Case WM_LBUTTONDOWN
           WindowMessageString = "WM_LBUTTONDOWN"
        Case WM_LBUTTONUP
           WindowMessageString = "WM_LBUTTONUP"
        Case WM_LBUTTONDBLCLK
           WindowMessageString = "WM_LBUTTONDBLCLK"
        Case WM_RBUTTONDOWN
           WindowMessageString = "WM_RBUTTONDOWN"
        Case WM_RBUTTONUP
           WindowMessageString = "WM_RBUTTONUP"
        Case WM_RBUTTONDBLCLK
           WindowMessageString = "WM_RBUTTONDBLCLK"
        Case WM_MBUTTONDOWN
           WindowMessageString = "WM_MBUTTONDOWN"
        Case WM_MBUTTONUP
           WindowMessageString = "WM_MBUTTONUP"
        Case WM_MBUTTONDBLCLK
           WindowMessageString = "WM_MBUTTONDBLCLK"
        Case WM_MOUSEWHEEL
           WindowMessageString = "WM_MOUSEWHEEL"
        Case WM_MOUSELAST
           WindowMessageString = "WM_MOUSELAST"
        Case WM_PARENTNOTIFY
           WindowMessageString = "WM_PARENTNOTIFY"
        Case WM_ENTERMENULOOP
           WindowMessageString = "WM_ENTERMENULOOP"
        Case WM_EXITMENULOOP
           WindowMessageString = "WM_EXITMENULOOP"
        Case WM_NEXTMENU
           WindowMessageString = "WM_NEXTMENU"
        Case WM_SIZING
           WindowMessageString = "WM_SIZING"
        Case WM_CAPTURECHANGED
           WindowMessageString = "WM_CAPTURECHANGED"
        Case WM_MOVING
           WindowMessageString = "WM_MOVING"
        Case WM_POWERBROADCAST
           WindowMessageString = "WM_POWERBROADCAST"
        Case WM_DEVICECHANGE
           WindowMessageString = "WM_DEVICECHANGE"
        Case WM_MDICREATE
           WindowMessageString = "WM_MDICREATE"
        Case WM_MDIDESTROY
           WindowMessageString = "WM_MDIDESTROY"
        Case WM_MDIACTIVATE
           WindowMessageString = "WM_MDIACTIVATE"
        Case WM_MDIRESTORE
           WindowMessageString = "WM_MDIRESTORE"
        Case WM_MDINEXT
           WindowMessageString = "WM_MDINEXT"
        Case WM_MDIMAXIMIZE
           WindowMessageString = "WM_MDIMAXIMIZE"
        Case WM_MDITILE
           WindowMessageString = "WM_MDITILE"
        Case WM_MDICASCADE
           WindowMessageString = "WM_MDICASCADE"
        Case WM_MDIICONARRANGE
           WindowMessageString = "WM_MDIICONARRANGE"
        Case WM_MDIGETACTIVE
           WindowMessageString = "WM_MDIGETACTIVE"
        Case WM_MDISETMENU
           WindowMessageString = "WM_MDISETMENU"
        Case WM_ENTERSIZEMOVE
           WindowMessageString = "WM_ENTERSIZEMOVE"
        Case WM_EXITSIZEMOVE
           WindowMessageString = "WM_EXITSIZEMOVE"
        Case WM_DROPFILES
           WindowMessageString = "WM_DROPFILES"
        Case WM_MDIREFRESHMENU
           WindowMessageString = "WM_MDIREFRESHMENU"
        Case WM_IME_SETCONTEXT
           WindowMessageString = "WM_IME_SETCONTEXT"
        Case WM_IME_NOTIFY
           WindowMessageString = "WM_IME_NOTIFY"
        Case WM_IME_CONTROL
           WindowMessageString = "WM_IME_CONTROL"
        Case WM_IME_COMPOSITIONFULL
           WindowMessageString = "WM_IME_COMPOSITIONFULL"
        Case WM_IME_SELECT
           WindowMessageString = "WM_IME_SELECT"
        Case WM_IME_CHAR
           WindowMessageString = "WM_IME_CHAR"
        Case WM_IME_REQUEST
           WindowMessageString = "WM_IME_REQUEST"
        Case WM_IME_KEYDOWN
           WindowMessageString = "WM_IME_KEYDOWN"
        Case WM_IME_KEYUP
           WindowMessageString = "WM_IME_KEYUP"
        Case WM_MOUSEHOVER
           WindowMessageString = "WM_MOUSEHOVER"
        Case WM_MOUSELEAVE
           WindowMessageString = "WM_MOUSELEAVE"
        Case WM_CUT
           WindowMessageString = "WM_CUT"
        Case WM_COPY
           WindowMessageString = "WM_COPY"
        Case WM_PASTE
           WindowMessageString = "WM_PASTE"
        Case WM_CLEAR
           WindowMessageString = "WM_CLEAR"
        Case WM_UNDO
           WindowMessageString = "WM_UNDO"
        Case WM_RENDERFORMAT
           WindowMessageString = "WM_RENDERFORMAT"
        Case WM_RENDERALLFORMATS
           WindowMessageString = "WM_RENDERALLFORMATS"
        Case WM_DESTROYCLIPBOARD
           WindowMessageString = "WM_DESTROYCLIPBOARD"
        Case WM_DRAWCLIPBOARD
           WindowMessageString = "WM_DRAWCLIPBOARD"
        Case WM_PAINTCLIPBOARD
           WindowMessageString = "WM_PAINTCLIPBOARD"
        Case WM_VSCROLLCLIPBOARD
           WindowMessageString = "WM_VSCROLLCLIPBOARD"
        Case WM_SIZECLIPBOARD
           WindowMessageString = "WM_SIZECLIPBOARD"
        Case WM_ASKCBFORMATNAME
           WindowMessageString = "WM_ASKCBFORMATNAME"
        Case WM_CHANGECBCHAIN
           WindowMessageString = "WM_CHANGECBCHAIN"
        Case WM_HSCROLLCLIPBOARD
           WindowMessageString = "WM_HSCROLLCLIPBOARD"
        Case WM_QUERYNEWPALETTE
           WindowMessageString = "WM_QUERYNEWPALETTE"
        Case WM_PALETTEISCHANGING
           WindowMessageString = "WM_PALETTEISCHANGING"
        Case WM_PALETTECHANGED
           WindowMessageString = "WM_PALETTECHANGED"
        Case WM_HOTKEY
           WindowMessageString = "WM_HOTKEY"
        Case WM_PRINT
           WindowMessageString = "WM_PRINT"
        Case WM_PRINTCLIENT
           WindowMessageString = "WM_PRINTCLIENT"
        Case WM_HANDHELDFIRST
           WindowMessageString = "WM_HANDHELDFIRST"
        Case WM_HANDHELDLAST
           WindowMessageString = "WM_HANDHELDLAST"
        Case WM_AFXFIRST
           WindowMessageString = "WM_AFXFIRST"
        Case WM_AFXLAST
           WindowMessageString = "WM_AFXLAST"
        Case WM_PENWINFIRST
           WindowMessageString = "WM_PENWINFIRST"
        Case WM_PENWINLAST
           WindowMessageString = "WM_PENWINLAST"
        Case WM_APP
           WindowMessageString = "WM_APP"
        Case WM_USER
           WindowMessageString = "WM_USER"
        Case Else
            Dim strS As String
            strS = Hex(lWindowMessage)
            If (Len(strS) <= 2) Then strS = "00" & strS
            If (Len(strS) <= 3) Then strS = "0" & strS
            WindowMessageString = "UNKNOWN " & "0x" & strS
    End Select
End Function

Public Property Get WindowFromXY(ByVal x As Long, ByVal Y As Long) As Long
    WindowFromXY = WindowFromPointXY(x, Y)
End Property

Public Property Get WindowFromCurrentCursorPos() As Long
    Dim pt As POINTAPI
    GetCursorPos pt
    WindowFromCurrentCursorPos = WindowFromPointXY(pt.x, pt.Y)
End Property


Function HiByte(ByVal w As Integer) As Byte

    If w And &H8000 Then
        HiByte = &H80 Or ((w And &H7FFF) \ &HFF)
    Else
        HiByte = w \ 256
    End If
End Function

Function HiWord(dw As Long) As Integer

    If dw And &H80000000 Then
        HiWord = (dw \ 65535) - 1
    Else
        HiWord = dw \ 65535
    End If
End Function

Function LoByte(w As Integer) As Byte

    LoByte = w And &HFF
End Function

Function loWord(dw As Long) As Integer

    If dw And &H8000& Then
        loWord = &H8000 Or (dw And &H7FFF&)
    Else
        loWord = dw And &HFFFF&
    End If
End Function

Function LShiftWord(ByVal w As Integer, ByVal c As Integer) As Integer

    Dim dw As Long
    dw = w * (2 ^ c)
    If dw And &H8000& Then
        LShiftWord = CInt(dw And &H7FFF&) Or &H8000
    Else
        LShiftWord = dw And &HFFFF&
    End If
End Function

Function RShiftWord(ByVal w As Integer, ByVal c As Integer) As Integer

    Dim dw As Long
    If c = 0 Then
        RShiftWord = w
    Else
        dw = w And &HFFFF&
        dw = dw \ (2 ^ c)
        RShiftWord = dw And &HFFFF&
    End If
End Function

Public Function DecodeLParam(ByVal lParam As Long, ByRef HiWord As Long, ByRef loWord As Long) As Boolean
    
    HiWord = 0
    loWord = 0
    CopyMemory loWord, lParam, 2
    CopyMemory HiWord, ByVal (VarPtr(lParam) + 2), 2
    DecodeLParam = True
End Function

Public Function MakeLParam(ByRef lParam As Long, ByVal HiWord As Long, ByVal loWord As Long) As Boolean
    
    CopyMemory lParam, loWord, 2
    CopyMemory ByVal (VarPtr(lParam) + 2), HiWord, 2
    MakeLParam = True
End Function

