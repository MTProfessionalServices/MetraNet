VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "cWindows"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Attribute VB_Ext_KEY = "SavedWithClassBuilder" ,"Yes"
Attribute VB_Ext_KEY = "Top_Level" ,"Yes"
' ****************************************************************************************************************************************************
'
'  Copyright 1998-2000 by MetraTech Corporation
'  All rights reserved.
'
'  THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
'  NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
'  example, but not limitation, MetraTech Corporation MAKES NO
'  REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
'  PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
'  DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
'  COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
'
'  Title to copyright in this software and any associated
'  documentation shall at all times remain with MetraTech Corporation,
'  and USER agrees to preserve the same.
'
'  CLASS        :
'  AUTHOR       : Frederic Torres
'  DATE         : xx/03/98 Sophia Antipolis...21/11/98 Boston. Just cleaning...
'  DESCRIPTION  : Windows API Wrapper
'  VERSION      : none.
'
' ****************************************************************************************************************************************************
' ************************************************************************************************************************
' cWindows.cls
'
'
'
'
'
' ************************************************************************************************************************
Option Explicit



' Positive value are Windows error
Public Enum eWINDOWS_FILE_COPY_RETURN_CODE
    RC_OK = -1
    RC_USER_CANCEL = -2
End Enum

Public Enum eWINDOWS_FILE_COPY_FILE_OPERATION

    FO_COPY = &H2&  'Copies the files specified in the
                'pFrom member to the location
            'specified in the pTo member.
    FO_DELETE = &H3& 'Deletes the files specified in pFrom
            '(pTo is ignored.)
    FO_MOVE = &H1&   'Moves the files specified in pFrom
            'to the location specified in pTo.
    FO_RENAME = &H4& 'Renames the files specified in pFrom
End Enum
Public Enum eWINDOWS_FILE_COPY_FILE_FLAGS

    FOF_ALLOWUNDO = &H40&
    FOF_CONFIRMMOUSE = &H2&     'Not currently implemented.
    FOF_CREATEPROGRESSDLG = &H0&    'handle to the parent
                                        'window for the progress
                                        'dialog box
    FOF_FILESONLY = &H80&           'Perform the operation
                    'on files only if a
                    'wildcard file name
                    '(*.*) is specified.

    FOF_MULTIDESTFILES = &H1&       'The pTo member
                    'specifies multiple
                    'destination files (one
                    'for each source file)
                    'rather than one directory
                    'where all source files
                    'are to be deposited.

    FOF_NOCONFIRMATION = &H10&      'Respond with Yes to All
                    'for any dialog box that
                    'is displayed.

    FOF_NOCONFIRMMKDIR = &H200&     'Does not confirm the
                    'creation of a new
                    'directory if the
                    'operation requires one
                    'to be created.

    FOF_RENAMEONCOLLISION = &H8&    'Give the file being
                    'operated on a new name
                    'in a move, copy, or
                    'rename operation if a
                    'file with the target
                    'name already exists.

       FOF_SILENT = &H4&            'Does not display a
                                                 'progress dialog box.

    FOF_SIMPLEPROGRESS = &H100&  'Displays a progress
                    'dialog box but does not
                    'show the file names.

    FOF_WANTMAPPINGHANDLE = &H20&
                                   ' If FOF_RENAMEONCOLLISION is specified,
                                   'the hNameMappings member will be filled
                                   'in if any files were renamed.

      ' The SHFILOPSTRUCT is not double word aligned.  If no steps are
      ' taken, the last 3 variables will not be passed correctly.  This
      ' has no impact unless the progress title needs to be changed.

End Enum

Public Enum STGM
    STGM_DIRECT = &H0&
    STGM_TRANSACTED = &H10000
    STGM_SIMPLE = &H8000000
    STGM_READ = &H0&
    STGM_WRITE = &H1&
    STGM_READWRITE = &H2&
    STGM_SHARE_DENY_NONE = &H40&
    STGM_SHARE_DENY_READ = &H30&
    STGM_SHARE_DENY_WRITE = &H20&
    STGM_SHARE_EXCLUSIVE = &H10&
    STGM_PRIORITY = &H40000
    STGM_DELETEONRELEASE = &H4000000
    STGM_CREATE = &H1000&
    STGM_CONVERT = &H20000
    STGM_FAILIFTHERE = &H0&
    STGM_NOSCRATCH = &H100000
End Enum

Public Enum SHELLFOLDERS            ' Shell Folder Path Constants...
    CSIDL_DESKTOP = &H0&            ' ..\WinNT\profiles\username\Desktop
    CSIDL_PROGRAMS = &H2&           ' ..\WinNT\profiles\username\Start Menu\Programs
    CSIDL_CONTROLS = &H3&           ' No Path
    CSIDL_PRINTERS = &H4&           ' No Path
    CSIDL_PERSONAL = &H5&           ' ..\WinNT\profiles\username\Personal
    CSIDL_FAVORITES = &H6&          ' ..\WinNT\profiles\username\Favorites
    CSIDL_STARTUP = &H7&            ' ..\WinNT\profiles\username\Start Menu\Programs\Startup
    CSIDL_RECENT = &H8&             ' ..\WinNT\profiles\username\Recent
    CSIDL_SENDTO = &H9&             ' ..\WinNT\profiles\username\SendTo
    CSIDL_BITBUCKET = &HA&          ' No Path
    CSIDL_STARTMENU = &HB&          ' ..\WinNT\profiles\username\Start Menu
    CSIDL_DESKTOPDIRECTORY = &H10&  ' ..\WinNT\profiles\username\Desktop
    CSIDL_DRIVES = &H11&            ' No Path
    CSIDL_NETWORK = &H12&           ' No Path
    CSIDL_NETHOOD = &H13&           ' ..\WinNT\profiles\username\NetHood
    CSIDL_FONTS = &H14&             ' ..\WinNT\fonts
    CSIDL_TEMPLATES = &H15&         ' ..\WinNT\ShellNew
    CSIDL_COMMON_STARTMENU = &H16&  ' ..\WinNT\profiles\All Users\Start Menu
    CSIDL_COMMON_PROGRAMS = &H17&   ' ..\WinNT\profiles\All Users\Start Menu\Programs
    CSIDL_COMMON_STARTUP = &H18&    ' ..\WinNT\profiles\All Users\Start Menu\Programs\Startup
    CSIDL_COMMON_DESKTOPDIRECTORY = &H19& '..\WinNT\profiles\All Users\Desktop
    CSIDL_APPDATA = &H1A&           ' ..\WinNT\profiles\username\Application Data
    CSIDL_PRINTHOOD = &H1B&         ' ..\WinNT\profiles\username\PrintHood
End Enum

Public Enum SHOWCMDFLAGS
    SHOWNORMAL = 5
    SHOWMAXIMIZE = 3
    SHOWMINIMIZE = 7
End Enum

 
#If UNICODE Then
    Private Declare Function SHGetPathFromIDList Lib "shell32" Alias "SHGetPathFromIDListW" (ByVal pidl As Long, ByVal szPath As Long) As Long
#Else
    Private Declare Function SHGetPathFromIDList Lib "shell32" Alias "SHGetPathFromIDListA" (ByVal pidl As Long, ByVal szPath As String) As Long
#End If

Private Declare Function SHGetSpecialFolderLocation Lib "shell32" (ByVal hwndOwner As Long, ByVal nFolder As Integer, ppidl As Long) As Long
 
Private Const MAX_PATH = 255
Private Const MAX_NAME = 40

Private Declare Function CoCreateGuid Lib "OLE32.DLL" (pGuid As GUID) As Long
Private Declare Function StringFromGUID2 Lib "OLE32.DLL" (pGuid As GUID, ByVal PointerToString As Long, ByVal MaxLength As Long) As Long

' Private members
Private Const GUID_OK As Long = 0

Private Type GUID
    Guid1           As Long
    Guid2           As Integer
    Guid3           As Integer
    Guid4(0 To 7)   As Byte
End Type


Private OsVers As OsVersionInfo


Public Function CreateGUIDKey() As String
'
' COMMENT   : Return a GUID
'
' IN        :
'
' OUT       :
'
' RETURN    :
'
    '*** Possible max length for buffer
    Const GUID_LENGTH   As Long = 38

    Dim udtGUID As GUID
    'User Defined Type
    Dim strFormattedGUID As String
    'The formatted string
    Dim lngResult As Long
    'Useless result flag

    '*** Create a 'raw' GUID
    lngResult = CoCreateGuid(udtGUID)

    If lngResult = GUID_OK Then
        '*** Pre-allocate space for the ID
        strFormattedGUID = String$(GUID_LENGTH, 0)
        '*** Convert the 'raw' GUID to a
        'formatted string
        StringFromGUID2 udtGUID, _
            StrPtr(strFormattedGUID), GUID_LENGTH + 1
    Else
        '*** Return nothing or handle error
        strFormattedGUID = ""
    End If
    ' *** Return our nicely formatted GUID
    CreateGUIDKey = strFormattedGUID
End Function

Public Function getSystemFolderPath(ByVal id As Integer) As String
'
' COMMENT   :
'
' IN        :
'
' OUT       :
'
' RETURN    :
'

    Dim rc As Long                                      ' Return code
    Dim pidl As Long                                    ' ptr to Item ID List
    Dim cbPath As Long                                  ' char count of path
    Dim szPath As String                                ' String var for path
    Dim sfPath As String

    szPath = Space(MAX_PATH)                            ' Pre-allocate path string for api call
    getSystemFolderPath = ""

    rc = SHGetSpecialFolderLocation(0, id, pidl)     ' Get pidl for Id...
    If (rc = 0) Then                                    ' If success is 0
        #If UNICODE Then
        rc = SHGetPathFromIDList(pidl, StrPtr(szPath))  ' Get Path from Item Id List
        #Else
        rc = SHGetPathFromIDList(pidl, szPath)          ' Get Path from Item Id List
        #End If
        If (rc = 1) Then                                ' If success is 1
            szPath = Trim$(szPath)                      ' Fix path string
            cbPath = Len(szPath)                        ' Get length of path
            If (Asc(Right(szPath, 1)) = 0) Then cbPath = cbPath - 1 ' Adjust path length
            If (cbPath > 0) Then sfPath = Left$(szPath, cbPath) ' Adjust path string variable
            getSystemFolderPath = sfPath ' Return success
        End If
    End If

End Function



 
 
Public Function ShellAndWait(ByVal JobToDo As String, Optional ExecMode, Optional TimeOut) As Long
'
' COMMENT   :
'
' IN        :
'
' OUT       :
'
' RETURN    :
'
   '
   ' Shells a new process and waits for it to complete.
   ' Calling application is totally non-responsive while
   ' new process executes.
   '
   Dim ProcessID    As Long
   Dim hProcess     As Long
   Dim nRet         As Long
   Const fdwAccess = SYNCHRONIZE
   
   If IsMissing(ExecMode) Then
      ExecMode = vbNormalFocus 'vbMinimizedNoFocus
   Else
      If ExecMode < vbHide Or ExecMode > vbMinimizedNoFocus Then
         ExecMode = vbMinimizedNoFocus
      End If
   End If
   
   On Error Resume Next
      ProcessID = Shell(JobToDo, CLng(ExecMode))
      
      If Err Then
         ShellAndWait = vbObjectError + Err.Number
         Exit Function
      End If
   On Error GoTo 0
         
   If IsMissing(TimeOut) Then
      TimeOut = INFINITE
   End If
   
   hProcess = OpenProcess(fdwAccess, False, ProcessID)
   nRet = WaitForSingleObject(hProcess, CLng(TimeOut))
   Call CloseHandle(hProcess)
   
   Select Case nRet
      Case WAIT_TIMEOUT: Debug.Print "Timed out!"
      Case WAIT_OBJECT_0: Debug.Print "Normal completion."
      Case WAIT_ABANDONED: Debug.Print "Wait Abandoned!"
      Case WAIT_FAILED: Debug.Print "Wait Error:"; Err.LastDllError
   End Select
   ShellAndWait = nRet
End Function

Public Function ShellAndLoop(ByVal JobToDo As String, Optional ExecMode) As Long
'
' COMMENT   :
'
' IN        :
'
' OUT       :
'
' RETURN    :
'
   '
   ' Shells a new process and waits for it to complete.
   ' Calling application is responsive while new process
   ' executes. It will react to new events, though execution
   ' of the current thread will not continue.
   '
   Dim ProcessID    As Long
   Dim hProcess     As Long
   Dim nRet         As Long
   Const fdwAccess = PROCESS_QUERY_INFORMATION
   '
   ' !!! The value of this constant is probably WRONG !!! STILL_ACTIVE = 1
   '
   Const STILL_ACTIVE = 1
   
   If IsMissing(ExecMode) Then
      ExecMode = vbMinimizedNoFocus
   Else
      If ExecMode < vbHide Or ExecMode > vbMinimizedNoFocus Then
         ExecMode = vbMinimizedNoFocus
      End If
   End If
   
   On Error Resume Next
      ProcessID = Shell(JobToDo, CLng(ExecMode))
      If Err Then
         ShellAndLoop = vbObjectError + Err.Number
         Exit Function
      End If
   On Error GoTo 0
   
   hProcess = OpenProcess(fdwAccess, False, ProcessID)
   Do
      GetExitCodeProcess hProcess, nRet
      DoEvents
      Sleep 100
   Loop While nRet = STILL_ACTIVE
   Call CloseHandle(hProcess)
   
   ShellAndLoop = nRet
End Function

Public Function ShellAndClose(ByVal JobToDo As String, Optional ExecMode) As Long
'
' COMMENT   :
'
' IN        :
'
' OUT       :
'
' RETURN    :
'
   '
   ' Shells a new process and waits for it to complete.
   ' Calling application is responsive while new process
   ' executes. It will react to new events, though execution
   ' of the current thread will not continue.
   '
   ' Will close a DOS box when Win95 doesn't. More overhead
   ' than ShellAndLoop but useful when needed.
   '
   Dim ProcessID    As Long
   Dim PID          As Long
   Dim hProcess     As Long
   Dim hWndJob      As Long
   Dim nRet         As Long
   Dim TitleTmp     As String
   Const fdwAccess = PROCESS_QUERY_INFORMATION
   '
   ' !!! The value of this constant is probably WRONG !!! STILL_ACTIVE = 1
   '
   Const STILL_ACTIVE = 1

   If IsMissing(ExecMode) Then
      ExecMode = vbMinimizedNoFocus
   Else
      If ExecMode < vbHide Or ExecMode > vbMinimizedNoFocus Then
         ExecMode = vbMinimizedNoFocus
      End If
   End If
   
   On Error Resume Next
      ProcessID = Shell(JobToDo, CLng(ExecMode))
      If Err Then
         ShellAndClose = vbObjectError + Err.Number
         Exit Function
      End If
   On Error GoTo 0
   
   hWndJob = FindWindow(vbNullString, vbNullString)
   Do Until hWndJob = 0
      If GetParent(hWndJob) = 0 Then
         Call GetWindowThreadProcessId(hWndJob, PID)
         If PID = ProcessID Then Exit Do
      End If
      hWndJob = GetWindow(hWndJob, GW_HWNDNEXT)
   Loop
   
   hProcess = OpenProcess(fdwAccess, False, ProcessID)
   Do
      TitleTmp = Space(256)
      nRet = GetWindowText(hWndJob, TitleTmp, Len(TitleTmp))
      If nRet Then
         TitleTmp = UCase(Left(TitleTmp, nRet))
         If InStr(TitleTmp, "FINISHED") = 1 Then
            Call SendMessage(hWndJob, WM_CLOSE, 0, 0)
         End If
      End If
      
      GetExitCodeProcess hProcess, nRet
      DoEvents
      Sleep 100
   Loop While nRet = STILL_ACTIVE
   Call CloseHandle(hProcess)
   
   ShellAndClose = nRet
End Function
 
Public Function hWndShell(ByVal JobToDo As String, Optional ExecMode) As Long
'
' COMMENT   : Shells a new process and returns the hWnd of its main window.
'
' IN        :
'
' OUT       :
'
' RETURN    :
'
   
   Dim ProcessID        As Long
   Dim PID              As Long
   Dim hProcess         As Long
   Dim hWndJob          As Long

   If IsMissing(ExecMode) Then
      ExecMode = vbMinimizedNoFocus
   Else
      If ExecMode < vbHide Or ExecMode > vbMinimizedNoFocus Then
         ExecMode = vbMinimizedNoFocus
      End If
   End If
   
   On Error Resume Next
      ProcessID = Shell(JobToDo, CLng(ExecMode))
      If Err Then
         hWndShell = 0
         Exit Function
      End If
   On Error GoTo 0
   
   hWndJob = FindWindow(vbNullString, vbNullString)
   Do While hWndJob <> 0
      If GetParent(hWndJob) = 0 Then
         Call GetWindowThreadProcessId(hWndJob, PID)
         If PID = ProcessID Then
            hWndShell = hWndJob
            Exit Do
         End If
      End If
      hWndJob = GetWindow(hWndJob, GW_HWNDNEXT)
   Loop
End Function
Public Function cursorPos(x As Long, Y As Long) As Long
'
' COMMENT   :
'
' IN        :
'
' OUT       :
'
' RETURN    :
'

    Dim lpPoint As POINTAPI
    cursorPos = GetCursorPos(lpPoint)
    x = lpPoint.x
    Y = lpPoint.Y
End Function

Public Sub LogOff()
'
' COMMENT   :
'
' IN        :
'
' OUT       :
'
' RETURN    :
'
    ExitWindowsEx EWX_LOGOFF, 0
End Sub

Public Sub SetWinUserMove(theForm As Object)
'
' COMMENT   :
'
' IN        :
'
' OUT       :
'
' RETURN    :
'
    ReleaseCapture
    SendMessage theForm.hwnd, WM_NCLBUTTONDOWN, HTCAPTION, 0&
End Sub

Public Function getBrowseDirectory(hwnd As Long, Optional msg As String) As String
'
' COMMENT   :
'
' IN        :
'
' OUT       :
'
' RETURN    :
'

    Dim bi          As BROWSEINFO
    Dim IDL         As ITEMIDLIST
    Dim r           As Long
    Dim pidl        As Long
    Dim tmpPath     As String
    Dim pos         As Integer
    
    bi.hOwner = hwnd
    bi.pidlRoot = 0&
    bi.lpszTitle = IIf(msg <> "", msg, "Select the search directory")
    bi.ulFlags = BIF_RETURNONLYFSDIRS
    
   'get the folder
    pidl = SHBrowseForFolder(bi)
    
    tmpPath = Space$(512)
    r = SHGetPathFromIDList(ByVal pidl, ByVal tmpPath)
      
    If r Then
        pos = InStr(tmpPath, Chr$(0))
        tmpPath = Left(tmpPath, pos - 1)
        getBrowseDirectory = tmpPath
    Else
        getBrowseDirectory = ""
    End If
End Function
Public Sub ReBoot()
'
' COMMENT   :
'
' IN        :
'
' OUT       :
'
' RETURN    :
'
    ExitWindowsEx EWX_REBOOT, 0
End Sub

Public Sub ShutDown()
'
' COMMENT   :
'
' IN        :
'
' OUT       :
'
' RETURN    :
'
    ExitWindowsEx EWX_SHUTDOWN, 0
End Sub
 
 

Public Sub SetWinTopMost(theForm As Object, Optional topMost As Boolean = False)
'
' COMMENT   :
'
' IN        :
'
' OUT       :
'
' RETURN    :
'
    If topMost Then
        SetWindowPos theForm.hwnd, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE + SWP_NOSIZE
    Else
        SetWindowPos theForm.hwnd, HWND_NOTOPMOST, 0, 0, 0, 0, SWP_NOMOVE + SWP_NOSIZE
    End If
End Sub


Public Function GetWinDir() As String
'
' COMMENT   :
'
' IN        :
'
' OUT       :
'
' RETURN    :
'

    Dim w As String
    Dim r As Long
    
    
    w = Space(255)
    r = GetWindowsDirectory(w, Len(w))
    
    r = InStr(w, Chr(0))
    If r = 0 Then
        GetWinDir = w
    Else
        GetWinDir = Mid(w, 1, r - 1)
    End If

End Function

Public Function ComputerName() As String
'
' COMMENT   :
'
' IN        :
'
' OUT       :
'
' RETURN    :
'
    Dim l       As Long
    Dim Name    As String
    
    Name = Space(132)
    l = GetComputerName(Name, Len(Name))
    If InStr(Name, Chr(0)) <> 0 Then
        Name = Left(Name, InStr(Name, Chr(0)) - 1)
    End If
    ComputerName = Name
End Function
Public Function UserName() As String
    Dim s1 As String
    s1 = Space(512)
    GetUserName s1, Len(s1)
    If InStr(s1, Chr(0)) <> 0 Then
        s1 = Left(s1, InStr(s1, Chr(0)) - 1)
    End If
    UserName = Trim$(s1)
End Function
Public Function NetUserName() As String
' Function that returns the netword name of the currently logged on user
' Example - MyString =FindNetUserName

Dim s1 As String
s1 = Space(512)
WNetGetUser vbNullString, s1, Len(s1)
NetUserName = Trim$(s1)
End Function
Public Function GetVersion32() As String
' Call to get the 32 Bit O/S ID. Returned values are either "95" or "NT" or "Unknown"
' Example - MyString = GetVersion32'OsVers.dwVersionInfoSize = 148&
Dim v As String

OsVers.dwVersionInfoSize = Len(OsVers)
GetVersionEx OsVers

v = OsVers.dwMajorVersion & "." & OsVers.dwMinorVersion & " -  Build:" & OsVers.dwBuildNumber

If OsVers.dwPlatform = 1& Then
    v = "Windows 95 " & v
ElseIf OsVers.dwPlatform = 2& Then
    v = "NT " & v
Else
   v = "Unknown"
End If
GetVersion32 = v
End Function

Public Function SendChar(hwnd As Long, bytChar As Long, Optional lParam As Long = 0) As Boolean
    SendMessage hwnd, WM_CHAR, bytChar, lParam
    SendChar = True
End Function

 
 
Public Function getMemoryInfo() As String
Dim memsts  As MEMORYSTATUS
Dim memory  As Long
Dim msg     As String

GlobalMemoryStatus memsts

memory = memsts.dwTotalPhys
msg = msg & "Total Physical Memory: "
msg = msg & Format$(memory \ 1024, "###,###,###") & "K" & vbCrLf
memory = memsts.dwAvailPhys
msg = msg & "Available Physical Memory: "
msg = msg & Format$(memory \ 1024, "###,###,###") & "K" & vbCrLf
memory = memsts.dwTotalVirtual
msg = msg & "Total Virtual Memory: "
msg = msg & Format$(memory \ 1024, "###,###,###") & "K" & vbCrLf
memory = memsts.dwAvailVirtual
msg = msg & "Available Virtual Memory: "
msg = msg & Format$(memory \ 1024, "###,###,###") & "K" & vbCrLf & vbCrLf
getMemoryInfo = msg
End Function

 

Public Sub ClearMaximizeButton(f As Object, c As Boolean)
    Dim style As Long
    
 
    ' Window Styles
Const WS_OVERLAPPED = &H0&
Const WS_POPUP = &H80000000
Const WS_CHILD = &H40000000
Const WS_MINIMIZE = &H20000000
Const WS_VISIBLE = &H10000000
Const WS_DISABLED = &H8000000
Const WS_CLIPSIBLINGS = &H4000000
Const WS_CLIPCHILDREN = &H2000000
Const WS_MAXIMIZE = &H1000000
Const WS_CAPTION = &HC00000                  '  WS_BORDER Or WS_DLGFRAME
Const WS_BORDER = &H800000
Const WS_DLGFRAME = &H400000
Const WS_VSCROLL = &H200000
Const WS_HSCROLL = &H100000
Const WS_SYSMENU = &H80000
Const WS_THICKFRAME = &H40000
Const WS_GROUP = &H20000
Const WS_TABSTOP = &H10000

Const WS_MINIMIZEBOX = &H20000
Const WS_MAXIMIZEBOX = &H10000

Const WS_TILED = WS_OVERLAPPED
Const WS_ICONIC = WS_MINIMIZE
Const WS_SIZEBOX = WS_THICKFRAME
Const WS_OVERLAPPEDWINDOW = (WS_OVERLAPPED Or WS_CAPTION Or WS_SYSMENU Or WS_THICKFRAME Or WS_MINIMIZEBOX Or WS_MAXIMIZEBOX)
Const WS_TILEDWINDOW = WS_OVERLAPPEDWINDOW
    
    
    style = GetWindowLong(f.hwnd, GWL_STYLE)
    
    If c Then
        style = SetWindowLong(f.hwnd, GWL_STYLE, WS_OVERLAPPED)
    Else
        style = SetWindowLong(f.hwnd, GWL_STYLE, style - WS_MAXIMIZEBOX - WS_THICKFRAME)
        'style = SetWindowLong(f.hwnd, GWL_STYLE, style - WS_MAXIMIZEBOX)
    End If
End Sub

Public Function SendCharString(hwnd As Long, strS As String, Optional lParam As Long = 0) As Boolean
    Dim i As Long
    For i = 1 To Len(strS)
        SendChar hwnd, Asc(Mid(strS, i, 1)), lParam
    Next
    SendCharString = True
End Function

Public Function Sleep(lngMilliSec As Long) As Boolean
    On Error GoTo ErrMgr
    cWindowsModule.Sleep lngMilliSec
    Sleep = True
    Exit Function
ErrMgr:
End Function

Public Function GetTickCount() As Long
    GetTickCount = cWindowsModule.GetTickCount()
End Function

Public Function FilesCopy(strSourceWildCard As String, strDestinationPath As String, Optional eFileOperation As eWINDOWS_FILE_COPY_FILE_OPERATION = eWINDOWS_FILE_COPY_FILE_OPERATION.FO_COPY, Optional eFileFlags As eWINDOWS_FILE_COPY_FILE_FLAGS = eWINDOWS_FILE_COPY_FILE_FLAGS.FOF_ALLOWUNDO + eWINDOWS_FILE_COPY_FILE_FLAGS.FOF_FILESONLY, Optional strTitle As String, Optional lngHWND As Long) As eWINDOWS_FILE_COPY_RETURN_CODE

    Dim x As SHFILEOPSTRUCT
    
    On Error GoTo ErrMgr
    
    Dim lngResult As Long
    
    x.hNameMappings = 0
    x.hwnd = lngHWND
    x.lpszProgressTitle = ""
    x.pFrom = strSourceWildCard
    x.pTo = strDestinationPath
    x.fFlags = eFileFlags
    x.wFunc = eFileOperation
    x.fAnyOperationsAborted = 0
    If (strTitle <> "") Then
        x.lpszProgressTitle = strTitle
        'x.fFlags = x.fFlags + FOF_SIMPLEPROGRESS
    End If

    lngResult = SHFileOperation(x)

    If lngResult <> 0 Then              'Operation failed
        FilesCopy = Err.LastDllError          'Msgbox the error that occurred in the
                                        'API.
    Else
        If x.fAnyOperationsAborted <> 0 Then
            FilesCopy = RC_USER_CANCEL
        Else
            FilesCopy = RC_OK
        End If
    End If
    
    FilesCopy = True
    Exit Function
ErrMgr:
    FilesCopy = False

End Function

Public Function GetTempPath(Optional SetVar As String = "TEMP") As String

    'Dim strTmpPath      As String
    'Dim lngTmpPathSize  As Long
    'strTmpPath = Space(256)
    'lngTmpPathSize = GetTmpPath(Len(strTmpPath), strTmpPath)
    'strTmpPath = Left(strTmpPath, lngTmpPathSize)
    
    GetTempPath = Environ(SetVar)
End Function

Public Function GetWindowCaption(lngHWND As Long) As String
    Dim strBuf As String
    strBuf = Space(256)
    GetWindowText lngHWND, strBuf, Len(strBuf)
    GetWindowCaption = Mid(strBuf, 1, InStr(strBuf, Chr(0)) - 1)
End Function

Public Function GetWindowClassName(lngHWND As Long) As String
    Dim strBuf As String
    strBuf = Space(256)
    GetClassName lngHWND, strBuf, Len(strBuf)
    GetWindowClassName = Mid(strBuf, 1, InStr(strBuf, Chr(0)) - 1)
End Function


Public Function ShutDownDialog() As Boolean
    SHShutDownDialog EWX_SHUTDOWN
End Function
