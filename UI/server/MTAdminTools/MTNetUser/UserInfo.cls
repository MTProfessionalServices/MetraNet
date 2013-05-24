VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "UserInfo"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit
'
' Win32 APIs to determine OS information.
'
Private Declare Function NetUserGetLocalGroups Lib "netapi32" (lpServer As Any, UserName As Byte, ByVal Level As Long, ByVal Flags As Long, lpBuffer As Long, ByVal MaxLen As Long, lpEntriesRead As Long, lpTotalEntries As Long) As Long
Private Declare Function NetApiBufferFree Lib "netapi32" (ByVal pBuffer As Long) As Long

Private Declare Function LogonUser Lib "advapi32.dll" Alias "LogonUserA" (ByVal lpszUsername As String, ByVal lpszDomain As String, ByVal lpszPassword As String, ByVal dwLogonType As Long, ByVal dwLogonProvider As Long, phToken As Long) As Long
Private Declare Function ImpersonateLoggedOnUser Lib "advapi32.dll" (ByVal hToken As Long) As Long
Private Declare Function RevertToSelf Lib "advapi32.dll" () As Long

Private Declare Function GetLastError Lib "kernel32" () As Long
Private Declare Function CloseHandle Lib "kernel32" (ByVal hToken As Long) As Boolean
Private Declare Function FormatMessage Lib "kernel32" Alias "FormatMessageA" _
                                      (ByVal dwFlags As Long, _
                                      lpSource As Any, _
                                      ByVal dwMessageId As Long, _
                                      ByVal dwLanguageId As Long, _
                                      ByVal lpBuffer As String, _
                                      ByVal nSize As Long, _
                                      Arguments As Long) As Long

Private Declare Sub CopyMem Lib "kernel32" Alias "RtlMoveMemory" (pTo As Any, uFrom As Any, ByVal lSize As Long)
Private Declare Function lstrlenW Lib "kernel32" (ByVal lpString As Long) As Long
Private Declare Function lstrcpyW Lib "kernel32" (lpString1 As Byte, ByVal lpString2 As Long) As Long

Private Const LG_INCLUDE_INDIRECT As Long = &H1&
Private Const NERR_Success As Long = 0&
Private m_LocalGroups() As String


Private Type USER_INFO
  Name As Long
  Password As Long
End Type

' *********************************************************
'  Private Methods
' *********************************************************
Public Function CheckLogon(ByVal strUser As String, _
                           ByVal strPassword As String, _
                           Optional ByVal strDomain As String = ".") As Boolean
  Dim lpToken As Long
  Dim lpRet As Long
  Dim bReturn As Boolean
  

  
  Call RevertToSelf
  
  bReturn = LogonUser(strUser, _
                         strDomain, _
                         strPassword, _
                         2, _
                         0, _
                         lpToken)
                         
  lpRet = ImpersonateLoggedOnUser(lpToken)
  
  'Close the handle
  Call CloseHandle(lpToken)
  
  CheckLogon = bReturn
  
End Function

Public Function CheckForGroup(ByVal strUser As String, _
                              Optional ByVal strServer As String = "", _
                              Optional ByVal strGroup As String = "Administrators")
  Dim lpBuffer As Long
  Dim yUserName() As Byte
  Dim yServer() As Byte
  Dim lpGroups() As Long
  Dim nRead As Long
  Dim nTotal As Long
  Dim nRet As Long
  Dim i As Long
  Const Flags& = LG_INCLUDE_INDIRECT 'To get domain groups as well
  'Const Flags& = 0 'don't get domain groups
   
   CheckForGroup = False
   
   yUserName = strUser & vbNullChar
   If Len(strServer) = 0 Or UCase(strServer) = "LOCALHOST" Then     'use the localhost
      nRet = NetUserGetLocalGroups(ByVal 0&, yUserName(0), 0, Flags, lpBuffer, &H4000, nRead, nTotal)
   Else
      If InStr(strServer, "\\") = 1 Then
         yServer = strServer & vbNullChar
      Else
         yServer = "\\" & strServer & vbNullChar
      End If
      nRet = NetUserGetLocalGroups(yServer(0), yUserName(0), 0, Flags, lpBuffer, &H400, nRead, nTotal)
   End If
      
   If nRet = NERR_Success Then
      ReDim lpGroups(0 To nRead - 1) As Long
      ReDim m_LocalGroups(0 To nRead - 1) As String
      CopyMem lpGroups(0), ByVal lpBuffer, nRead * 4
      
      For i = 0 To nRead - 1
         m_LocalGroups(i) = PointerToStringW(lpGroups(i))
         
         'Check the group
         If UCase(strGroup) = UCase(m_LocalGroups(i)) Then
          CheckForGroup = True
          Exit For
         End If
      Next i
   End If
   '
   ' Clean up
   '
   
   If lpBuffer Then
      Call NetApiBufferFree(lpBuffer)
   End If
End Function

Private Function PointerToStringW(lpStringW As Long) As String
   Dim Buffer() As Byte
   Dim nLen As Long
   
   If lpStringW Then
      nLen = lstrlenW(lpStringW) * 2
      If nLen Then
         ReDim Buffer(0 To (nLen - 1)) As Byte
         CopyMem Buffer(0), ByVal lpStringW, nLen
         PointerToStringW = Buffer
      End If
   End If
End Function
