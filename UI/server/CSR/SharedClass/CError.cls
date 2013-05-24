VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CError"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
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
'  CLASS        : CPipeLineAccess
'  AUTHOR       : Frederic Torres
'  DATE         : 03/xx/2000
'  DESCRIPTION  :
'  VERSION      : none.
'
'**************************************************************************
Option Explicit

Public Enum CERROR_SEVERITY
    CERROR_WARNING = 0
    CERROR_ERROR
    CERROR_FATAL_ERROR
End Enum

Public Number           As Long
Public Description      As String
Public Source           As String
Public LastDllError     As Long
Public time             As Date
Public strModuleName    As String
Public strFunctionName  As String
Public strUserMsg       As String
Public Severity         As CERROR_SEVERITY

'----------------------------------------------------------------------
'   Method:         Save
'   Description:    If there is a VB error pending save it and return true!
'   Author:         FAT
'   Last Modified:  08/09/1999
'
'   NOTES:
'----------------------------------------------------------------------
Public Function Save(Optional strUserMsg_ As String, Optional strModuleName_ As String, Optional strFunctionName_ As String, Optional lngApplicationError As Long = 0, Optional eSeverity As CERROR_SEVERITY = CERROR_ERROR) As Boolean
    If ((Err.Number <> 0) Or (strUserMsg_ <> "")) Then
        Severity = eSeverity
        If (Err.Number <> 0) Then
            Number = Err.Number
            Description = Err.Description
            
            'If (Len(strUserMsg_)) Then Description = Description & "UserMessage={" & strUserMsg_ & "};"
            
            Source = Err.Source
        Else
            Number = lngApplicationError * (-1)
            'Description = "UserMessage={" & strUserMsg_ & "};"
            Source = Err.Source
        End If
        LastDllError = Err.LastDllError
        time = Now()
        strModuleName = strModuleName_
        strFunctionName = strFunctionName_
        strUserMsg = strUserMsg_
        Save = True
        Err.Clear
        Debug.Print "CError.Save():" & Me.ToString()
    End If
End Function

'----------------------------------------------------------------------
'   Method:         ToString
'   Description:    Return the data of the instance in a string format!
'   Author:         FAT
'   Last Modified:  08/09/1999
'
'   NOTES:
'----------------------------------------------------------------------
Public Function ToString(Optional v As Variant) As String

    Dim str         As String
    Dim strCrLf     As String
    
    strCrLf = " - "
    
    str = "[CERROR]"
        
    If (strUserMsg <> "") Then
    
        str = str & strUserMsg & strCrLf
    End If
    
    If (Number <> 0) Then
    
        If (strUserMsg <> "") Then str = str & strCrLf
        str = str & "VB Error=" & Me.Number & " Description=" & Me.Description & " Source=" & Me.Source & strCrLf
    End If
        
    If (Severity <> CERROR_WARNING) Then
    
        str = str & " Time=" & Me.time & ". LastDllError=" & Me.LastDllError & "." & strCrLf
        str = str & " Module=" & Me.strModuleName & ". Function=" & Me.strFunctionName & "." & strCrLf
    End If
    ToString = str

    
End Function


Public Sub Raise()
    Err.Raise Me.Number, Me.Source, Me.Description
End Sub
