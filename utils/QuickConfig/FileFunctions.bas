Attribute VB_Name = "FileFunctions"
Public Declare Function GetOpenFileName Lib "comdlg32.dll" Alias _
  "GetOpenFileNameA" (pOpenfilename As OPENFILENAME) As Long
  
Public Type OPENFILENAME
  lStructSize As Long
  hwndOwner As Long
  hInstance As Long
  lpstrFilter As String
  lpstrCustomFilter As String
  nMaxCustFilter As Long
  nFilterIndex As Long
  lpstrFile As String
  nMaxFile As Long
  lpstrFileTitle As String
  nMaxFileTitle As Long
  lpstrInitialDir As String
  lpstrTitle As String
  flags As Long
  nFileOffset As Integer
  nFileExtension As Integer
  lpstrDefExt As String
  lCustData As Long
  lpfnHook As Long
  lpTemplateName As String
End Type

Private Declare Sub CopyMemory Lib "kernel32" Alias "RtlMoveMemory" (Destination As Any, Source As Any, ByVal Length As Long)

Private Declare Function CloseHandle Lib "kernel32" _
   (ByVal hfile As Long) As Long
   
Private Declare Function CreateFile Lib "kernel32" _
   Alias "CreateFileA" _
  (ByVal lpFileName As String, _
   ByVal dwDesiredAccess As Long, _
   ByVal dwShareMode As Long, _
   ByVal lpSecurityAttributes As Long, _
   ByVal dwCreationDisposition As Long, _
   ByVal dwFlagsAndAttributes As Long, _
   ByVal hTemplateFile As Long) As Long
   
Private Const FILE_SHARE_READ = &H1
Private Const FILE_SHARE_DELETE As Long = &H4
Private Const FILE_FLAG_BACKUP_SEMANTICS = &H2000000
Private Const OPEN_EXISTING = 3


Public Function FileExists(ByVal sSource As String) As Boolean
On Error GoTo errlog

   Dim lFile As Long

   lFile = CreateFile(sSource, 0&, FILE_SHARE_READ, 0&, _
                      OPEN_EXISTING, FILE_FLAG_BACKUP_SEMANTICS, 0&)
   
   If lFile > 0 Then
      FileExists = True
   End If
   
   Call CloseHandle(lFile)
   
errlog:
subErrLog ("modFileFuncs: DoesFileExist")
End Function

'Public Function DoesFolderExist(ByVal sFolder As String) As Boolean
'On Error GoTo errlog
'
'   Dim hfile As Long
'   Dim WFD As WIN32_FIND_DATA
'
'   sFolder = UnQualifyPath(sFolder)
'
'   hfile = FindFirstFile(sFolder, WFD)
'
'   DoesFolderExist = (hfile <> INVALID_HANDLE_VALUE) And _
'                  (WFD.dwFileAttributes And FILE_ATTRIBUTE_DIRECTORY)
'
'   Call FindClose(hfile)
'
'errlog:
'subErrLog ("modFileFuncs: DoesFolderExist")
'End Function

'Public Sub RemoveArrayElement(ByRef AryVar() As String, ByVal _
'    RemoveWhich As Long)
'    '// The size of the array elements
'    '// In the case of string arrays, they are
'    '// simply 32 bit pointers to BSTR's.
'    Dim byteLen As Byte
'
'    '// String pointers are 4 bytes
'    byteLen = 4
'
'    '// The copymemory operation is not necessary unless
'    '// we are working with an array element that is not
'    '// at the end of the array
'    If RemoveWhich < UBound(AryVar) Then
'        '// Copy the block of string pointers starting at
'        ' the position after the
'        '// removed item back one spot.
'        CopyMemory ByVal VarPtr(AryVar(RemoveWhich)), ByVal _
'            VarPtr(AryVar(RemoveWhich + 1)), (byteLen) * _
'            (UBound(AryVar) - RemoveWhich)
'    End If
'
'    '// If we are removing the last array element
'    '// just deinitialize the array
'    '// otherwise chop the array down by one.
'    If UBound(AryVar) = LBound(AryVar) Then
''        Erase AryVar
'    Else
'        ReDim Preserve AryVar(UBound(AryVar) - 1)
'    End If
'End Sub


