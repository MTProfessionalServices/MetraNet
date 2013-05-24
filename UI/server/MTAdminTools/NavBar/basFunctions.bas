Attribute VB_Name = "basFunctions"

'**************************************************************************
' Copyright 1998, 1999 by MetraTech Corporation
' All rights reserved.
'
' THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
' NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
' example, but not limitation, MetraTech Corporation MAKES NO
' REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
' PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
' DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
' COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
'
' Title to copyright in this software and any associated
' documentation shall at all times remain with MetraTech Corporation,
' and USER agrees to preserve the same.
'
'***************************************************************************



'*****************************************************************************
'*****
'***** DESCRIPTION:
'*****
'***** ASSUMPTIONS:
'*****
'***** CALLS (REQUIRES):
'*****
'*****************************************************************************
Option Explicit



'----------------------------------------------------------------------------
' CONSTANTS
'----------------------------------------------------------------------------
Public Const HKEY_LOCAL_MACHINE = &H80000002



'----------------------------------------------------------------------------
' VARIABLES
'----------------------------------------------------------------------------
Public gstrConfigDir    As String
Private mstrWADirectory As String



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


'----------------------------------------------------------------------------
' METHODS
'----------------------------------------------------------------------------

'----------------------------------------------------------------------------
'   Name: appendToURL
'   Description:  This method takes in extra information to add to a query
'                   string.  It checks to see if parameters already exists
'                   and adds a '?' or '&' appropriately
'   Parameters: icstrURL - the URL to append to
'               icstrToAdd - the stuff to add
'   Return Value: the new URL
'-----------------------------------------------------------------------------
Public Function appendToURL(ByVal icstrURL As String, ByVal icstrToAdd As String)
    Dim strSpecialChar As String
    
    If Len(icstrToAdd) = 0 Then
        appendToURL = icstrURL
    Else
        
        If InStr(icstrURL, "?") > 0 Then
            strSpecialChar = "&"
        Else
            strSpecialChar = "?"
        End If
        appendToURL = icstrURL & strSpecialChar & icstrToAdd
    End If
End Function


'----------------------------------------------------------------------------
'   Name: GetRegValue
'   Description:
'   Parameters:
'   Return Value:
'-----------------------------------------------------------------------------
Public Function GetRegValue(hKey As Long, lpszSubKey As String, szKey As String, _
                     szDefault As String) As Variant

    On Error GoTo ERROR_HANDLER
    
    Const ERROR_SUCCESS = 0&
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


'----------------------------------------------------------------------------
'   Name: setConfigDir
'   Description: sets the config directory to the config directory
'                specified in the registry!
'                Version 2 we use a componant call! see function getMTConfigDir()
'   Parameters:
'   Return Value:
'-----------------------------------------------------------------------------
Public Sub setConfigDir()
    If Len(gstrConfigDir) = 0 Then
        'gstrConfigDir = CStr(GetRegValue(HKEY_LOCAL_MACHINE, "Software\Metratech\Netmeter", "ConfigDir", ""))
        gstrConfigDir = getMTConfigDir()
    End If
    
End Sub



'----------------------------------------------------------------------------
'   Name: getConManObject
'   Description: Returns a MTConMan object, which is used to read from the
'               repository and retreive config set objects
'   Parameters: icstrUserName - the username to use when connecting
'               icstrPassword - the password for the username
'   Return Value: a new MTConMan object - Nothing if an error occurs
'-----------------------------------------------------------------------------
'Public Function getConManObject(ByVal icstrUserName As String, _
'                                ByVal icstrPassword As String) As MTConMan
'On Error GoTo ErrHandler
'
'    Dim objConfigMan        As New MTConMan
'    Call objConfigMan.Initialize("localhost", "localhost", "localhost")
'
'    '-----------------------------------------------------------
'    ' Try to log in.  If the login is unsuccessful, then the
'    ' machine is not ready to do configuration set stuff.
'    ' Just return Nothing and exit the function
'    '-----------------------------------------------------------
'    Call objConfigMan.Login(icstrUserName, icstrPassword)
'
'    If objConfigMan Is Nothing Then
'        GoTo ErrHandler
'    End If
'
'    Set getConManObject = objConfigMan
'    Set objConfigMan = Nothing
'    Exit Function
'
'ErrHandler:
'    Set objConfigMan = Nothing
'    Set getConManObject = Nothing
'End Function
  



'----------------------------------------------------------------------------
'   Name: getWADirectory
'   Description: returns the directory of the working area on the specified
'               machine.  Caches it after reading once
'   Parameters: none
'   Return Value: the path of the Working Area on the local machine
'-----------------------------------------------------------------------------
Public Function getWADirectory() As String
On Error GoTo ErrHandler

    Dim xmlParser As MTConfig
    
    If Len(mstrWADirectory) = 0 Then
        Set xmlParser = New MTConfig
        mstrWADirectory = xmlParser.ReadConfiguration(gstrConfigDir & "\MTConfigurationMgr.xml", False).NextStringWithName("working_area")
        Set xmlParser = Nothing
    End If

    getWADirectory = mstrWADirectory
    Exit Function

ErrHandler:
    Set xmlParser = Nothing
    mstrWADirectory = ""
    getWADirectory = ""
End Function

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :   getMTConfigDir
' DESCRIPTION   :   Return the config path. Version 1 used the registry. Version 2 use a componant function call.
' RETURN        :   A String
' VERSION       :   2
'
Public Function getMTConfigDir() As String

'   Old Code for version 1
'
'    Dim objRegistry As New cRegistry
'    If (objRegistry.openSection(objRegistry.HKEY_LOCAL_MACHINE, "software\MetraTech\NetMeter", KEY_READ)) Then
'        getMTConfigDir = objRegistry.getSubVar("ConfigDir")
'    End If
   
    Dim strS                As String
    Static m_objPipeLine    As PIPELINECONTROLLib.MTPipeline
    
    If (m_objPipeLine Is Nothing) Then
    
        Set m_objPipeLine = New PIPELINECONTROLLib.MTPipeline
        'Set m_objPipeLine = CreateObject("MetraPipeline.MTPipeline.1")
    End If
    strS = m_objPipeLine.ConfigurationDirectory()
    
    ' The function add a slash at the end. So I remove it because it was part ot the version 1
    If (Right(strS, 1) = "\") Then
    
        strS = Mid(strS, 1, Len(strS) - 1)
    End If
    getMTConfigDir = strS
    
End Function

