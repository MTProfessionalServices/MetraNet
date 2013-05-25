VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CDateFile"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
' ****************************************************************************************************************************************
' Copyright 1997-2000 by MetraTech
' All rights reserved.
'
' THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
' REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
' example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
' WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
' OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
' INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
' RIGHTS.
'
' Title to copyright in this software and any associated
' documentation shall at all times remain with MetraTech, and USER
' agrees to preserve the same.
'
' Created by: Torres Frederic
' $Header$
'
' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
' CLASS         : CDateFile
' DESCRIPTION   : Allow to retreive the Creation Date, Last Modified Date and Last Access Date of a file.
'                 Use the Initialize() function to initialize the instance, then call the property CreationDate, LastMofifiedDate, LastAccessDate.
'                 The time is returned in Local time.
'
' ***************************************************************************************************************************************

Option Explicit

Private m_LocalTimeZoneInfo     As TIME_ZONE_INFORMATION
Private m_FileName              As String
Private m_HFile                 As Long
Private m_FT_CREATE             As FILETIME
Private m_FT_ACCESS             As FILETIME
Private m_FT_WRITE              As FILETIME

Private Const OFS_MAXPATHNAME = 260
Private Const OF_READWRITE = &H2

Private Type OFSTRUCT
   cBytes      As Byte
   fFixedDisk  As Byte
   nErrCode    As Integer
   Reserved1   As Integer
   Reserved2   As Integer
   szPathName(OFS_MAXPATHNAME) As Byte
End Type

Private Type FILETIME
  dwLowDateTime     As Long
  dwHighDateTime    As Long
End Type

Private Type SYSTEMTIME
  wYear          As Integer
  wMonth         As Integer
  wDayOfWeek     As Integer
  wDay           As Integer
  wHour          As Integer
  wMinute        As Integer
  wSecond        As Integer
  wMilliseconds  As Long
End Type

Private Type TIME_ZONE_INFORMATION
   Bias         As Long
   StandardName(32) As Integer
   StandardDate As SYSTEMTIME
   StandardBias As Long
   DaylightName(32) As Integer
   DaylightDate As SYSTEMTIME
   DaylightBias As Long
End Type

Private Declare Sub GetLocalTime Lib "kernel32" (lpSystemTime As SYSTEMTIME)
Private Declare Function GetFileTime Lib "kernel32" (ByVal hFile As Long, lpCreationTime As FILETIME, lpLastAccessTime As FILETIME, lpLastWriteTime As FILETIME) As Long
Private Declare Function SetFileTime Lib "kernel32" (ByVal hFile As Long, lpCreationTime As FILETIME, lpLastAccessTime As FILETIME, lpLastWriteTime As FILETIME) As Long
Private Declare Function FileTimeToSystemTime Lib "kernel32" (lpFileTime As FILETIME, lpSystemTime As SYSTEMTIME) As Long
Private Declare Function SystemTimeToFileTime Lib "kernel32" (lpSystemTime As SYSTEMTIME, lpFileTime As FILETIME) As Long
Private Declare Function OpenFile Lib "kernel32" (ByVal lpFileName As String, lpReOpenBuff As OFSTRUCT, ByVal wStyle As Long) As Long
Private Declare Function CloseHandle Lib "kernel32" (ByVal hFile As Long) As Long
Private Declare Function GetTimeZoneInformation Lib "kernel32" (lpTimeZoneInformation As TIME_ZONE_INFORMATION) As Long

Private Declare Function SystemTimeToTzSpecificLocalTime Lib "kernel32" (lpTimeZoneInformation As TIME_ZONE_INFORMATION, lpUniversalTime As SYSTEMTIME, lpLocalTime As SYSTEMTIME) As Long


' ----------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETER     :
' DESCRIPTION   :
' RETURN        :
Private Function GetFileDateString(CT As FILETIME) As String

    Dim utcST           As SYSTEMTIME
    Dim localTimeST     As SYSTEMTIME
    Dim lngErr          As Long
    Dim strDateEuro     As String
    
    If (FileTimeToSystemTime(CT, utcST)) Then
    
        lngErr = SystemTimeToTzSpecificLocalTime(m_LocalTimeZoneInfo, utcST, localTimeST)
        If (lngErr) Then
            With localTimeST
                strDateEuro = "" & .wMonth & "/" & .wDay & "/" & .wYear & " " & .wHour & ":" & .wMinute & ":" & .wSecond
                GetFileDateString = CDate(strDateEuro)
            End With
        Else
            Debug.Print Err.LastDllError
        End If
    End If
End Function

' ----------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETER     :
' DESCRIPTION   :
' RETURN        :
Public Property Get CreationDate() As Date

   If (OpenFileDateInfo()) Then
   
        CreationDate = GetFileDateString(m_FT_CREATE)
        CloseFileDateInfo
   End If
End Property

' ----------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETER     :
' DESCRIPTION   :
' RETURN        :
Public Property Get LastMofifiedDate() As Date

   If (OpenFileDateInfo()) Then
   
        LastMofifiedDate = GetFileDateString(m_FT_WRITE)
        CloseFileDateInfo
   End If
End Property

' ----------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETER     :
' DESCRIPTION   :
' RETURN        :
Public Property Get LastAccessDate() As Date

   If (OpenFileDateInfo()) Then
   
        LastAccessDate = GetFileDateString(m_FT_ACCESS)
        CloseFileDateInfo
   End If
End Property

' ----------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETER     :
' DESCRIPTION   :
' RETURN        :
Private Function OpenFileDateInfo() As Boolean

    Dim OFS As OFSTRUCT
    
    m_HFile = OpenFile(FileName, OFS, OF_READWRITE)
    If (m_HFile) Then
        GetFileTime m_HFile, m_FT_CREATE, m_FT_ACCESS, m_FT_WRITE
        OpenFileDateInfo = True
    End If
End Function

' ----------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETER     :
' DESCRIPTION   :
' RETURN        :
Private Function CloseFileDateInfo() As Boolean
    CloseHandle m_HFile
    CloseFileDateInfo = True
End Function

' ----------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETER     :
' DESCRIPTION   :
' RETURN        :
Public Function Initialize(strFileName As String) As Boolean
    m_FileName = strFileName
    Initialize = True
End Function

Public Function ToString() As String
    ToString = "FileName=" & FileName & "; CreationDate=" & CreationDate & "; LastMofifiedDate=" & LastMofifiedDate & " LastAccessDate=" & LastAccessDate & ";"
End Function

Private Sub Class_Initialize()
    GetTimeZoneInformation m_LocalTimeZoneInfo
End Sub

Public Property Get FileName() As String
    FileName = m_FileName
End Property

