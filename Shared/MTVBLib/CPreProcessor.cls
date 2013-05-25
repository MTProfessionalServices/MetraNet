VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CPreProcessor"
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
'  DATE         : 09/xx/2000
'  DESCRIPTION  :
'  VERSION      : none.
'
' ****************************************************************************************************************************************************
' PREVIOUS HISTORY
' ****************************************************************************************************************************************************
'
'                                           OoVbLib5
'
'                               Object Oriented Visual Basic Library
'
'                                     Visual Basic Version 5
'
'                              TORRES Frederic 1995,1996,1997
'
' * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
'
' History :
'
' xx/05/97 - Sophia, PACA, FRANCE, Creation as CStrReplacer.
' 26/03/00 Melrose, MA, USA, Rename the class CPreProcessor and use the class CVariables to store the
' Data
'
' * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
'
'
' ******************************************************************************************************

Option Explicit

Private m_Vars As New CVariables

Public Enum PREPROCESSOR_ADD_FLAG
    
    PREPROCESSOR_ADD_NONE = 0
    PREPROCESSOR_ADD_LOWERCASE = 1
    PREPROCESSOR_ADD_UPPERCASE = 2
    PREPROCESSOR_ADD_ABSOLUTE = 4
    PREPROCESSOR_ADD_CAPTIONCASE = 8
End Enum


Public Sub Clear()
    m_Vars.Clear
End Sub


Public Function Add(ByVal vName As String, ByVal vValue As String, Optional eFlags As PREPROCESSOR_ADD_FLAG) As Boolean

    On Error GoTo ErrMgr
    
    Dim objVar As CVariable
    
    Set objVar = New CVariable
    objVar.Name = vName
    objVar.Value = vValue
    
    If (m_Vars.Exist(vName)) Then
        m_Vars.Remove vName
    End If
    m_Vars.Add vName, vValue
    
    
    If (eFlags And PREPROCESSOR_ADD_LOWERCASE) Then
    
        Add vName & ".LOWERCASE", LCase(vValue)
    End If
    If (eFlags And PREPROCESSOR_ADD_UPPERCASE) Then
    
        Add vName & ".UPPERCASE", UCase(vValue)
    End If
    If (eFlags And PREPROCESSOR_ADD_CAPTIONCASE) Then
    
        Add vName & ".CAPTIONCASE", UCase(Mid("" & vValue, 1, 1)) & LCase(Mid("" & vValue, 2))
    End If
    If (eFlags And PREPROCESSOR_ADD_ABSOLUTE) Then
            
        If (IsNumeric(vValue)) Then vValue = Abs(vValue)
        Add vName & ".ABSOLUTE", vValue
    End If
    
    Add = True
    Exit Function
ErrMgr:

End Function

Public Function ToString() As String

    Dim objVar As CVariable
    Dim s As String
    
    For Each objVar In m_Vars
        s = s + objVar.Name & "=" & objVar.Value & ";" & vbCrLf
    Next
    ToString = s
End Function

Public Function UnProcess(ByVal s As String, Optional charStart As String = "<", Optional charEnd As String = ">") As String
'
' COMMENT   : Do the reverse job of process
'
' IN        :
'
' OUT       :
'
' RETURN    :
'
    Dim objVar As CVariable
    For Each objVar In m_Vars
        s = Replace(s, objVar.Value, charStart & objVar.Name & charEnd)
    Next
    UnProcess = s
End Function


Public Sub standardVar()
'
' COMMENT   : Add standard variables
'
' IN        :
'
' OUT       :
'
' RETURN    :
'
    Add "DCOTE", """"
    Add "SCOTE", "'"
    Add "COMMA", ","
    Add "POINT", "."
    Add "POINTCOMMA", ";"
    
    Add "TAB", Chr(9)
    Add "CR", Chr(13)
    Add "LF", Chr(10)
    Add "SPACE", Chr(32)
    Add "CRLF", Chr(13) & Chr(10)
End Sub

Private Sub Class_Terminate()
    Clear
End Sub

Public Function Item(id As Variant) As CVariable
Attribute Item.VB_UserMemId = 0
    On Error GoTo ErrMgr
    Set Item = m_Vars.Item(id)
    Exit Function
ErrMgr:
    Set Item = Nothing
End Function

Public Function Value(Name As String) As Variant
    On Error GoTo ErrMgr
    Value = m_Vars(Name).Value
    Exit Function
ErrMgr:
    Value = Empty
End Function

Public Function Remove(vName As String) As Boolean
    On Error Resume Next
    m_Vars.Remove vName
    Remove = Err.Number = 0
    Err.Clear
End Function

Public Function LoadHFile(strFileName As String) As Boolean
'    Dim l       As New cLI
'    Dim f       As New cFILE
'    Dim s       As String
'    Dim tok     As String
'    Dim processLine As Boolean
'
'    processLine = True
'
'    f.assign strFileName
'    If f.Reset() Then
'        Do While Not f.EOF
'            s = f.ReadLn()
'            'Debug.Print s
'            l.Init s
'            If l.GetChar("#") Then
'                tok = l.GetIdentifier()
'                Select Case tok
'
'                    Case "DEFINE"
'                        If processLine Then
'                            tok = l.GetIdentifier(False)
'                            Me.Add tok, Trim(Mid(l.s, l.p))
'                        End If
'
'                    Case "IFDEF"
'                        tok = l.GetIdentifier(False)
'                        processLine = Me.Value(tok) <> Empty
'
'                    Case "ENDIF"
'                        processLine = True
'                End Select
'            End If
'        Loop
'        f.CloseFile
'    End If
End Function

Public Function PreProcessFile(strFileName As String, strIncludePath As String) As Boolean
'    Dim f           As New cTextFile
'    Dim s           As String
'    Dim l           As New cLI
'    Dim booPrePro   As Boolean
'    Dim clsResult   As New cStringConcat
'    Dim strHFILE    As String
'    Dim i           As Long
'
'    clsResult.Init 1024
'
'    f.assign strFileName
'    If f.Reset() Then
'        Do While Not f.EOF
'            booPrePro = True
'            s = f.ReadLn()
'            i = i + 1
'            If i > 13 Then
'                i = 0: DoEvents
'            End If
'            l.Init s
'            If l.GetChar("#") Then
'                If l.GetIdentifier() = "INCLUDE" Then
'                    booPrePro = False
'                    l.GetString strHFILE, """"
'                    LoadHFile strIncludePath & "\" & strHFILE
'                End If
'            End If
'            If booPrePro Then
'                clsResult.Concat Me.process(s, "", "") & vbCrLf
'            End If
'        Loop
'        f.CloseFile
'        f.LogFile strFileName & ".pp", clsResult.s, True
'        PreProcessFile = True
'    End If
End Function

Public Property Get Variables() As CVariables
    Set Variables = m_Vars
End Property

Public Property Set Variables(ByVal vNewValue As CVariables)
    Set m_Vars = vNewValue
End Property

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Process
' DESCRIPTION   : Replace all the argument into [] from the string s , based on entries stored in the variables collection/
'                 This function was re writtend to speed the process...
' PARAMETERS    :
' RETURN        :
Public Function Process(ByVal s As String, Optional charStart As String = "[", Optional charEnd As String = "]") As String

    Dim objVar                  As CVariable
    Dim lngBracketStartPos      As Long
    Dim lngBracketEndPos        As Long
    Dim lngPos                  As Long
    Dim strTok                  As String
    
    lngPos = 1
    
    Do
        lngBracketStartPos = InStr(lngPos, s, charStart)
        If (lngBracketStartPos = 0) Then Exit Do
        lngBracketEndPos = InStr(lngBracketStartPos + 1, s, charEnd)
        
        If (lngBracketEndPos) Then
        
            strTok = Mid(s, lngBracketStartPos + 1, lngBracketEndPos - lngBracketStartPos - 1)
            
            ' We do not support [numeric] specialy for the MDM rendering java script when the javascript use array: s=Parameters[0];
            If (m_Vars.Exist(strTok)) And (Not IsNumeric(strTok)) Then
            
                s = Mid(s, 1, lngBracketStartPos - 1) & m_Vars(strTok).Value & Mid(s, lngBracketEndPos + 1)
                lngPos = lngBracketStartPos
            Else
                lngPos = lngBracketEndPos ' Variables not found, we do not say any thing...
                ' We reomve the warning for performance issue and because the previous version was not doing it
                'TRACE PreProcess(MTVBLIB_ERROR_03506, "NAME", strTok), "CPreProcessor.cls", "Process", eMTGLOBAL_LOG_TRACE_MODE.LOG_WARNING
            End If
        Else
            lngPos = lngBracketStartPos + 1 '
            TRACE PreProcess(MTVBLIB_ERROR_03505, "STRING", s), "CPreProcessor.cls", "Process", eMTGLOBAL_LOG_TRACE_MODE.LOG_ERROR
        End If
    Loop
    Process = s
End Function

Public Function Process_(ByVal s As String, Optional charStart As String = "[", Optional charEnd As String = "]") As String

    Dim objVar As CVariable
    For Each objVar In m_Vars
        s = Replace(s, charStart & objVar.Name & charEnd, objVar.Value)
    Next
    Process_ = s
End Function

