VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CRegistry2"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
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
'  DATE         : Feb-4-1999
'  Description  : Generic all purpose collection of variable. A variable is a : name and value. Optional is the vb type.
'                 Apr-4-2000, Support of MSIXDEF Standard String Type. The Old way the VB Long Type is still supported.
'  VERSION      : none.
'
' ****************************************************************************************************************************************************
' ******************************************************************************************************
'
'                                           OoVbLib5
'
'                               Object Oriented Visual Basic Library
'
'                                     Visual Basic Version 5
'
'                                TORRES Frederic 1995,1996,1997
'
' * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
'
' History :
'
'  From VbLib3 for Vb3 (Aix en pce)
'  From OoVbLib4 For Vb4 16b/32b (Marseille,xx/03/97)
'  From OoVbLib5 For Vb5 (Sophia,xx/01/1998)
'  From OoVbLib6 For Vb5 (Boston,21/11/1998)
'
' * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
'
'
' ******************************************************************************************************

Option Explicit

'
' internal variable of the class
'
Public sectionIndex             As Long
Private opened                  As Boolean


Public Enum REGISTRY_VAR_TYPE
    REG_SZ = 1
    REG_BINARY = 3
    REG_DWORD = 4
End Enum

Public Enum REGISTRY_OPEN_MODE

    REGISTRY_OPEN_MODE_KEY_READ = KEY_READ   ' 131097
    REGISTRY_OPEN_MODE_KEY_ALL_ACCESS = KEY_ALL_ACCESS ' 983103
End Enum


'Const REG_SZ = 1
'Const REG_BINARY = 3
'Const REG_DWORD = 4



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

Private Declare Function RegCreateKeyEx Lib "advapi32.dll" Alias "RegCreateKeyExA" (ByVal hKey As Long, ByVal lpSubKey As String, ByVal Reserved As Long, ByVal lpClass As String, ByVal dwOptions As Long, ByVal samDesired As Long, lpSecurityAttributes As SECURITY_ATTRIBUTES, phkResult As Long, lpdwDisposition As Long) As Long
Private Declare Function RegQueryValueEx Lib "advapi32.dll" Alias "RegQueryValueExA" (ByVal hKey As Long, ByVal lpValueName As String, ByVal lpReserved As Long, lpType As Long, lpData As Any, lpcbData As Long) As Long         ' Note that if you declare the lpData parameter as String, you must pass it By Value.

Private Declare Function RegEnumKeyEx Lib "advapi32.dll" Alias "RegEnumKeyExA" _
(ByVal hKey As Long, ByVal dwIndex As Long, ByVal lpName As String, lpcbName As Long, lpReserved As Long, ByVal lpClass As String, lpcbClass As Long, lpftLastWriteTime As FILETIME) As Long

Private Declare Function RegOpenKeyEx Lib "advapi32.dll" Alias "RegOpenKeyExA" (ByVal hKey As Long, ByVal lpSubKey As String, ByVal ulOptions As Long, ByVal samDesired As Long, phkResult As Long) As Long
Private Declare Function RegSetValueEx Lib "advapi32.dll" Alias "RegSetValueExA" (ByVal hKey As Long, ByVal lpValueName As String, ByVal Reserved As Long, ByVal dwType As Long, lpData As Any, ByVal cbData As Long) As Long         ' Note that if you declare the lpData parameter as String, you must pass it By Value.
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

Public Function OpenSection(hKey As Long, sectionName As String, ByVal lngAccess As REGISTRY_OPEN_MODE) As Boolean
    
    Dim r       As Long
  
        
    If opened Then CloseSection
    
    sectionIndex = 0
    r = RegOpenKeyEx(hKey, sectionName, CLng(0), lngAccess, sectionIndex)
    If r = ERROR_SUCCESS Then
        opened = True
        OpenSection = True
    End If
    
End Function


Public Function CloseSection() As Boolean
    If opened Then
           RegCloseKey sectionIndex
           opened = False
    End If
    CloseSection = True
End Function




Public Function DeleteVar(ByVal hKey As Long, ByVal szSubKey As String) As Boolean
    Dim er As Long
    er = RegDeleteKey(hKey, szSubKey)
    DeleteVar = er = ERROR_SUCCESS
End Function

Public Function CreateVar(ByVal hKey As Long, ByVal szSubKey As String) As Boolean

    Dim hkeyResult                                      As Long
    Dim er                                              As Long
    Dim clas                                            As String * 1024
    Dim lpSecurityAttributes                            As SECURITY_ATTRIBUTES
    Dim lpdwDisposition                                 As Long
    
    '(ByVal hKey As Long, ByVal lpSubKey As String, ByVal Reserved As Long,
    'ByVal lpClass As String, ByVal dwOptions As Long, ByVal samDesired As Long,
    'lpSecurityAttributes As SECURITY_ATTRIBUTES, phkResult As Long, lpdwDisposition As Long) As Long
    
    'er = RegCreateKey(hKey, szSubKey, hkeyResult)
        
    er = RegCreateKeyEx(hKey, szSubKey, 0, vbNullString, REG_Option_NON_VOLATILE, KEY_ALL_ACCESS, lpSecurityAttributes, hkeyResult, lpdwDisposition)
    CreateVar = er = ERROR_SUCCESS
End Function




 
Private Sub Class_Initialize()
    
    'ini.Init App.path & "\CRegistry.ini"
    'internalLOG = UCase(ini.getVar("SYSTEM", "INTERNALLOG")) = "TRUE"
End Sub


Private Sub Class_Terminate()
    'ini.Done
End Sub







Public Function SetVar(ByVal sValueName As String, ByVal Value As Variant, ByVal lngType As REGISTRY_VAR_TYPE, Optional ByVal lngKey As Long, Optional ByVal strSection As String) As Boolean

    Dim r               As Long
    Dim lngDWWordValue  As Long
    
    If (lngKey) Then
        If Not Me.OpenSection(lngKey, strSection, REGISTRY_OPEN_MODE_KEY_ALL_ACCESS) Then Exit Function
    End If
    
    Select Case lngType
        Case REG_DWORD
            lngDWWordValue = Value
            r = RegSetValueEx(sectionIndex, sValueName, 0, lngType, lngDWWordValue, Len(lngDWWordValue))
        Case REG_SZ
            r = RegSetValueEx(sectionIndex, sValueName, 0, lngType, ByVal CStr(Value), Len(Value))
    End Select
        
    SetVar = r = ERROR_SUCCESS


  If (lngKey) Then
         Me.CloseSection
    End If
    
End Function


Public Function getVar(ByVal Name As String, Optional ByVal lngMaxLen As Long = 1024, Optional ByVal lngKey As Long, Optional ByVal strSection As String) As String
    Dim Value   As String
    Dim e       As Long
    Dim lpType  As Long
    Dim lngLong As Long

    If (lngKey) Then
        If Not Me.OpenSection(lngKey, strSection, REGISTRY_OPEN_MODE_KEY_READ) Then Exit Function
    End If

    Value = Space(lngMaxLen)
 
    e = RegQueryValueEx(sectionIndex, Name, ByVal 0&, lpType, ByVal Value, Len(Value))
    If e = ERROR_SUCCESS Then
    
        Select Case lpType
            Case REG_DWORD
                e = RegQueryValueEx(sectionIndex, Name, ByVal 0&, lpType, lngLong, Len(Value))
                getVar = CStr(lngLong)
            Case REG_SZ
                e = InStr(Value, Chr(0))
                If e - 1 > 0 Then
                    Value = Mid(Value, 1, e - 1)
                    getVar = Value
                End If
        End Select
    End If
    
    If (lngKey) Then
         Me.CloseSection
    End If
    
End Function


