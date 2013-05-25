Attribute VB_Name = "Module1"
'----------------------------------------------------------------------------
' DECLARES
'----------------------------------------------------------------------------
'Registry Function Prototypes
Declare Function RegOpenKeyEx Lib "advapi32" Alias "RegOpenKeyExA" _
        (ByVal hKey As Long, ByVal lpSubKey As String, ByVal ulOptions As Long, _
        ByVal samDesired As Long, phkResult As Long) As Long

Declare Function RegCloseKey Lib "advapi32" (ByVal hKey As Long) As Long

Declare Function RegQueryValueEx Lib "advapi32" Alias "RegQueryValueExA" _
        (ByVal hKey As Long, ByVal lpValueName As String, ByVal lpReserved As Long, _
         ByRef lpType As Long, ByVal szData As String, ByRef lpcbData As Long) As Long


Public Const HKEY_LOCAL_MACHINE = &H80000002

'----------------------------------------------------------------------------
'   Name: GetRegValue
'   Description:
'   Parameters:
'   Return Value:
'-----------------------------------------------------------------------------
Public Function GetRegValue(hKey As Long, lpszSubKey As String, szKey As String, _
                     szDefault As String) As Variant

    Const ERROR_SUCCESS = 0&
    On Error GoTo ERROR_HANDLER
    Dim phkResult As Long, lResult As Long, szBuffer As String, lBuffSize As Long
    
      'Create Buffer
      szBuffer = Space$(255)
      lBuffSize = Len(szBuffer)
      
      'Open the key
      RegOpenKeyEx hKey, lpszSubKey, 0, 1, phkResult
    
      'Query the value
      lResult = RegQueryValueEx(phkResult, szKey, 0, 0, szBuffer, lBuffSize)
    
      'Close the key
      RegCloseKey phkResult
    
      'Return obtained value
      If lResult = ERROR_SUCCESS Then
        GetRegValue = Left(szBuffer, lBuffSize - 1)
      Else
        GetRegValue = szDefault
      End If
      Exit Function
    
ERROR_HANDLER:
      'MsgBox "ERROR #" & Str$(Err) & " : " & Error & Chr(13) _
      '       & "Please exit and try again."
      GetRegValue = ""

End Function

