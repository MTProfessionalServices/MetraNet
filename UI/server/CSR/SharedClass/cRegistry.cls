VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "cRegistry"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Attribute VB_Ext_KEY = "SavedWithClassBuilder" ,"Yes"
Attribute VB_Ext_KEY = "Top_Level" ,"Yes"
'**************************************************************************
'
'  Copyright 1998 by MetraTech Corporation
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
'  CLASS        : CRegistry
'  AUTHOR       : Frederic Torres
'  DATE         : 03/xx/2000
'  DESCRIPTION  : Comes from the F.Torres's OoVbLib6v1. Modified since.
'  VERSION      : none.
'
'**************************************************************************

Option Explicit

'
' internal variable of the class
'
Public sectionIndex             As Long
Private opened                  As Boolean

Public varNames                 As New Collection
Public varValues                As New Collection
Public subVarNames              As New Collection
Public subVarValues             As New Collection

Const REG_SZ = 1
Const REG_BINARY = 3
Const REG_DWORD = 4

Const ERROR_NONE = 0
Const ERROR_BADDB = 1
Const ERROR_BADKEY = 2
Const ERROR_CANTOPEN = 3
Const ERROR_CANTREAD = 4
Const ERROR_CANTWRITE = 5
Const ERROR_OUTOFMEMORY = 6
Const ERROR_INVALID_PARAMETER = 7
Const ERROR_ACCESS_DENIED = 8
Const ERROR_NO_MORE_ITEMS = 259

Private Declare Function RegCloseKey Lib "advapi32.dll" (ByVal hKey As Long) As Long
Private Declare Function RegCreateKey Lib "advapi32.dll" Alias "RegCreateKeyA" (ByVal hKey As Long, ByVal szSubKey As String, hkeyResult As Long) As Long
Private Declare Function RegDeleteKey Lib "advapi32.dll" Alias "RegDeleteKeyA" (ByVal hKey As Long, ByVal szSubKey As String) As Long
Private Declare Function RegEnumKey Lib "advapi32.dll" Alias "RegEnumKeyA" (ByVal hKey As Long, ByVal iSubKey As Long, ByVal szBuffer As String, ByVal cbBuf As Long) As Long
Private Declare Function RegOpenKey Lib "advapi32.dll" Alias "RegOpenKeyA" (ByVal hKey As Long, ByVal szSubKey As String, hkeyResult As Long) As Long
Private Declare Function RegQueryValue Lib "advapi32.dll" Alias "RegQueryValueA" (ByVal hKey As Long, ByVal szSubKey As String, ByVal szValue As String, chValue As Long) As Long
Private Declare Function RegSetValue Lib "advapi32.dll" Alias "RegSetValueA" (ByVal hKey As Long, ByVal szSubKey As String, ByVal fdwType As Long, ByVal lpszValue As String, ByVal cb As Long) As Long

Private Declare Function RegCreateKeyEx Lib "advapi32.dll" Alias "RegCreateKeyExA" (ByVal hKey As Long, ByVal lpSubKey As String, ByVal reserved As Long, ByVal lpClass As String, ByVal dwOptions As Long, ByVal samDesired As Long, lpSecurityAttributes As SECURITY_ATTRIBUTES, phkResult As Long, lpdwDisposition As Long) As Long
Private Declare Function RegQueryValueEx Lib "advapi32.dll" Alias "RegQueryValueExA" (ByVal hKey As Long, ByVal lpValueName As String, ByVal lpReserved As Long, lpType As Long, lpData As Any, lpcbData As Long) As Long         ' Note that if you declare the lpData parameter as String, you must pass it By Value.

Private Declare Function RegEnumKeyEx Lib "advapi32.dll" Alias "RegEnumKeyExA" _
(ByVal hKey As Long, ByVal dwIndex As Long, ByVal lpName As String, lpcbName As Long, lpReserved As Long, ByVal lpClass As String, lpcbClass As Long, lpftLastWriteTime As FILETIME) As Long

Private Declare Function RegOpenKeyEx Lib "advapi32.dll" Alias "RegOpenKeyExA" (ByVal hKey As Long, ByVal lpSubKey As String, ByVal ulOptions As Long, ByVal samDesired As Long, phkResult As Long) As Long
Private Declare Function RegSetValueEx Lib "advapi32.dll" Alias "RegSetValueExA" (ByVal hKey As Long, ByVal lpValueName As String, ByVal reserved As Long, ByVal dwType As Long, lpData As Any, ByVal cbData As Long) As Long         ' Note that if you declare the lpData parameter as String, you must pass it By Value.
'Declare Function RegSetValueEx Lib "advapi32.dll" Alias "RegSetValueExA" (ByVal hKey As Long, ByVal lpValueName As String, ByVal Reserved As Long, ByVal dwType As Long, lpData As Any, ByVal cbData As Long) As Long         ' Note that if you declare the lpData parameter as String, you must pass it By Value.

'Private Declare Function RegEnumValue Lib "advapi32.dll" Alias "RegEnumValueA" (ByVal hKey As Long, ByVal dwIndex As Long, ByVal lpValueName As String, lpcbValueName As Long, lpReserved As Long, lpType As Long, lpData As Byte, lpcbData As Long) As Long
'Private Declare Function RegEnumValue Lib "advapi32.dll" Alias "RegEnumValueA" (ByVal hKey As Long, ByVal dwIndex As Long, ByVal lpValueName As String, lpcbValueName As Long, lpReserved As Long, lpType As Long, lpData As Byte, lpcbData As Long) As Long
' Here is the good one
Private Declare Function RegEnumValue Lib "advapi32.dll" Alias "RegEnumValueA" (ByVal hKey As Long, ByVal dwIndex As Long, ByVal lpValueName As String, lpcbValueName As Long, ByVal lpReserved As Long, lpType As Long, lpData As Any, lpcbData As Long) As Long

Private Declare Function RegQueryInfoKey Lib "advapi32.dll" Alias "RegQueryInfoKeyA" (ByVal hKey As Long, ByVal lpClass As String, lpcbClass As Long, lpReserved As Long, lpcSubKeys As Long, lpcbMaxSubKeyLen As Long, lpcbMaxClassLen As Long, lpcValues As Long, lpcbMaxValueNameLen As Long, lpcbMaxValueLen As Long, lpcbSecurityDescriptor As Long, lpftLastWriteTime As FILETIME) As Long

Private Declare Function GetLastError Lib "kernel32" () As Long

Private Declare Function RegEnumValueString Lib "advapi32.dll" Alias _
    "RegEnumValueA" (ByVal hKey As Long, ByVal dwIndex As Long, _
    ByVal lpValueName As String, lpcbValueName As Long, lpReserved As Long, _
    lpType As Long, ByVal lpValue As String, lpcbData As Long) As Long

'Private Declare Function RegEnumKey Lib "advapi32.dll" Alias "RegEnumKeyA" (ByVal hKey As Long, ByVal dwIndex As Long, ByVal lpName As String, ByVal cbName As Long) As Long

Public Function HKEY_CLASSES_ROOT()
    HKEY_CLASSES_ROOT = cHKEY_CLASSES_ROOT
End Function

Public Function HKEY_CURRENT_USER()
    HKEY_CURRENT_USER = cHKEY_CURRENT_USER
End Function

Public Function HKEY_LOCAL_MACHINE()
    HKEY_LOCAL_MACHINE = cHKEY_LOCAL_MACHINE
End Function

Public Function HKEY_USERS()
    HKEY_USERS = cHKEY_USERS
End Function

Public Function ERROR_SUCCESS()
    ERROR_SUCCESS = ERROR_NONE
End Function

Public Function openSection(hKey As Long, sectionName As String, Optional access As Long = KEY_READ) As Boolean
    
    Dim r       As Long
  
        
    If opened Then closeSection
    
    r = RegOpenKeyEx(hKey, sectionName, CLng(0), access, sectionIndex)
    If r = ERROR_SUCCESS Then
        opened = True
        openSection = True
    End If
    
End Function


Public Function closeSection() As Boolean
    If opened Then
           RegCloseKey sectionIndex
           opened = False
    End If
    closeSection = True
End Function

Public Function getSubVar(Name As String) As String
    Dim Value   As String
    Dim e       As Long
    Dim lpType  As Long
    
    Value = Space(1024 * 4)
    
'    '(ByVal hKey As Long,
'    ByVal lpValueName As String,
'    ByVal lpReserved As Long,
'    lpType As Long,
'    lpData As Any,
'    lpcbData As Long) As Long
'    ' Note that if you declare the lpData parameter as String, you must pass it By Value.
    
    e = RegQueryValueEx(sectionIndex, Name, 0, lpType, ByVal Value, Len(Value))
    If e = ERROR_SUCCESS Then
        e = InStr(Value, Chr(0))
        If e - 1 > 0 Then
            Value = Mid(Value, 1, e - 1)
            getSubVar = Value
        End If
    End If
End Function

Public Function setVar(Name As String, Value As String) As Boolean
    setVar = RegSetValue(sectionIndex, Name, REG_SZ, Value, Len(Value)) = ERROR_SUCCESS
End Function

Public Function getVar(Name As String) As String
    Dim Value   As String
    Dim e       As Long
    
    Value = Space(1024 * 4)
    
    e = RegQueryValue(sectionIndex, Name, Value, Len(Value))
    If e = ERROR_SUCCESS Then
        Value = Mid(Value, 1, InStr(Value, Chr(0)) - 1)
        getVar = Value
    End If
End Function

Public Function setVarEasy(appName As String, vName As String, Value As String, Optional subVar) As Boolean
    
    If openSection(HKEY_LOCAL_MACHINE, "Software\" & appName, True) Then
        If IsMissing(subVar) Then
            setVarEasy = RegSetValue(sectionIndex, vName, REG_SZ, Value, Len(Value)) = ERROR_SUCCESS
        Else
            setVarEasy = setSubVar(vName, Value, REG_SZ)
        End If
        closeSection
    End If
End Function

Public Function getVarEasy(appName As String, vName As String, Optional subVar) As String
    
    If openSection(HKEY_LOCAL_MACHINE, "Software\" & appName) Then
        If IsMissing(subVar) Then
            getVarEasy = getVar(vName)
        Else
            getVarEasy = getSubVar(vName)
        End If
        closeSection
    End If
End Function



Public Function deleteVar(ByVal hKey As Long, ByVal szSubKey As String) As Boolean
    Dim er As Long
    er = RegDeleteKey(hKey, szSubKey)
    deleteVar = er = ERROR_SUCCESS
End Function


Public Function setSubVar(sValueName As String, vValueSetting As String, lType As Long) As Boolean
    Dim r As Long
    r = RegSetValueEx(sectionIndex, sValueName, 0, lType, ByVal vValueSetting, Len(vValueSetting))
    setSubVar = r = ERROR_SUCCESS

End Function

Public Function createVar(ByVal hKey As Long, ByVal szSubKey As String) As Boolean
    Dim hkeyResult As Long
    
    Dim er As Long
    er = RegCreateKey(hKey, szSubKey, hkeyResult)
    createVar = er = ERROR_SUCCESS
End Function




 
