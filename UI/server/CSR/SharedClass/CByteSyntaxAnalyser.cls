VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CByteSyntaxAnalyser"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
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
'  CLASS        : CByteSyntaxAnalyser
'  AUTHOR       : Frederic Torres
'  DATE         : 03/xx/2000
'  DESCRIPTION  : This file comes from the OoVbLib6v1. NOT MODIFIED SINCE AND SHOULD NOT BE.
'                 This file allows to do Syntax Checking.
'
'                 Becarefull all the function return a enum type and not a boolean.
'
'  VERSION      : none.
'  DEPENDENCY   : CVariantStack
'
'**************************************************************************
Option Explicit

Public Enum FUNCTION_RETURN_CODE
    rSUCCEED = 0
    rFAILED = -1
    rVBERROR = -2
    rTRUE = rSUCCEED
    rFALSE = rFAILED
End Enum

Private m_Bytes()           As Byte
Private m_string            As String
Private m_stack             As New CVariantStack
Private m_lngMaxBytesIndex  As Long

Public lngBytesIndex        As Long
Public booKillSpaceOnly     As Boolean
Public booAcceptPointInId   As Boolean
Public booAccept2PointInId  As Boolean
Public booAcceptMinusInId   As Boolean
Public lngCurrentLine       As Long
Public lngIdSize            As Long
Public lngStringSize        As Long
Public strDateSeparator     As String

Const stringCote = """"

Public Function Init(strS As String) As FUNCTION_RETURN_CODE

    On Error GoTo ErrMgr
    
    Str2BytesArray strS
    
    m_string = strS
    lngBytesIndex = 0
    m_lngMaxBytesIndex = 0
    lngCurrentLine = 1
    Init = rSUCCEED
    Exit Function
ErrMgr:
    Init = rVBERROR
End Function


Public Function Done() As FUNCTION_RETURN_CODE

    On Error GoTo ErrMgr
    
    Erase m_Bytes()
    Done = rSUCCEED
    Exit Function
ErrMgr:
    Done = rVBERROR
End Function

Public Function GetIdentifier(strId As String, Optional booUpCase As Boolean = True) As FUNCTION_RETURN_CODE

    On Error GoTo ErrMgr
    
    If (KillSpace() = rVBERROR) Then
    
        GetIdentifier = rVBERROR
        Exit Function
    End If
    
    ' Pre alloc the string so we do not lose time
    Dim strS        As String: strS = Space(lngIdSize)
    Dim strSIndex   As Long
    
    Do While ((IsCharID() = rTRUE) And (EOS() = rFALSE))
        Mid(strS, strSIndex + 1, 1) = Chr(m_Bytes(lngBytesIndex))
        NextChar
        strSIndex = strSIndex + 1
        If (EOS() = rTRUE) Then Exit Do
    Loop
    If (booUpCase) Then
        strId = UCase(Mid(strS, 1, strSIndex))
    Else
        strId = Mid(strS, 1, strSIndex)
    End If
    GetIdentifier = IIf(Len(strId), rSUCCEED, rFAILED)
    Exit Function
ErrMgr:
    GetIdentifier = rVBERROR
End Function

Public Function getInteger(lngI As Long) As FUNCTION_RETURN_CODE
    On Error GoTo ErrMgr
    
    If (KillSpace() = rVBERROR) Then
    
        getInteger = rVBERROR
        Exit Function
    End If
    
    ' Pre alloc the string so we do not lose time
    Dim strS        As String: strS = Space(lngIdSize)
    Dim strSIndex   As Long
    
    Do While (((IsCharInteger()) = rTRUE) And (EOS() = rFALSE))
        Mid(strS, strSIndex + 1, 1) = Chr(m_Bytes(lngBytesIndex))
        NextChar
        strSIndex = strSIndex + 1
    Loop
    strS = Mid(strS, 1, strSIndex)
    lngI = CLng(strS)
    getInteger = rSUCCEED
    
    Exit Function
ErrMgr:
    getInteger = rVBERROR
End Function

Public Function GetString(strString As String, Optional strCote As String = """") As FUNCTION_RETURN_CODE
    On Error GoTo ErrMgr
    
    Dim eRetCode As FUNCTION_RETURN_CODE
    Dim lngCote  As Byte: lngCote = Asc(Mid(strCote, 1, 1))
    
    eRetCode = GetChar(strCote)
    If (eRetCode <> rTRUE) Then
        GetString = eRetCode
        Exit Function
    End If
        
    ' Pre alloc the string so we do not lose time
    Dim strS        As String: strS = Space(lngStringSize)
    Dim strSIndex   As Long
    
    Do While (True)
        If (EOS() = rTRUE) Then Exit Do
        
        If (m_Bytes(lngBytesIndex) = lngCote) Then
            If (EOS() = rFALSE) Then
                If (lngBytesIndex + 1 < Length()) Then
                    If (m_Bytes(lngBytesIndex + 1) = lngCote) Then
                        ' End of string char doubled
                        NextChar ' Skip the first char separator and continue like nothing happend
                    Else
                        Exit Do ' we found the end of the string
                    End If
                Else
                    Exit Do
                End If
            End If
        End If
        
        Mid(strS, strSIndex + 1, 1) = Chr(m_Bytes(lngBytesIndex))
        NextChar
        strSIndex = strSIndex + 1
    Loop
    If ((m_Bytes(lngBytesIndex) = lngCote) And (EOS() = rFALSE)) Then
        strString = Mid(strS, 1, strSIndex)
        GetString = rSUCCEED
        NextChar
    Else
        GetString = rFAILED
    End If
    Exit Function
ErrMgr:
    GetString = rVBERROR
End Function

Public Function GetUpToChar(theChar As String, strS As String, Optional lngStringSize As Long = 1024) As FUNCTION_RETURN_CODE
    On Error GoTo ErrMgr
    
    If (KillSpace() = rVBERROR) Then
    
        GetUpToChar = rVBERROR
        Exit Function
    End If
    
    Dim bytTheChar As Byte
    bytTheChar = Asc(Mid(theChar, 1, 1))
    
    ' Pre alloc the string so we do not lose time
    strS = Space(lngStringSize)
    Dim strSIndex   As Long
    
    Do While (GetCByteChar() <> bytTheChar) And (EOS() = rFALSE)
        Mid(strS, strSIndex + 1, 1) = Chr(m_Bytes(lngBytesIndex))
        NextChar
        strSIndex = strSIndex + 1
        If (EOS() = rSUCCEED) Then Exit Do
    Loop
    strS = Mid(strS, 1, strSIndex)
    
    GetUpToChar = rSUCCEED
    Exit Function
ErrMgr:
    GetUpToChar = rVBERROR
End Function


Public Function GetNextLine() As FUNCTION_RETURN_CODE

    On Error GoTo ErrMgr
    
    Do While (EOS() = rFALSE)
    
        If (m_Bytes(lngBytesIndex) = Asc(vbCr)) Then
            NextChar
            If (EOS() = rFALSE) Then
                If (m_Bytes(lngBytesIndex) = Asc(vbLf)) Then
                    NextChar
                End If
                GetNextLine = rSUCCEED
                Exit Function
            End If
        End If
        NextChar
    Loop
    GetNextLine = rFALSE
    Exit Function
ErrMgr:
    GetNextLine = rVBERROR
End Function

Public Function GetChar(c As String) As FUNCTION_RETURN_CODE

    On Error GoTo ErrMgr
      
    Dim bytChar As Byte: bytChar = Asc(Mid(c, 1, 1))
    
    If (KillSpace() = rVBERROR) Then
    
        GetChar = rVBERROR
        Exit Function
    End If
        
    If (Me.EOS() = rSUCCEED) Then
        GetChar = rFALSE
        Exit Function
    End If
        
    If (m_Bytes(lngBytesIndex) = bytChar) Then
    
        NextChar
        GetChar = rTRUE
        Exit Function
    End If
    GetChar = rFALSE
    Exit Function
ErrMgr:
    GetChar = rVBERROR
End Function

Public Function KillSpace() As FUNCTION_RETURN_CODE

    On Error GoTo ErrMgr
    Do While ((IsCharSpace() = rTRUE) And (EOS() = rFALSE))
        NextChar
        If (EOS() = rTRUE) Then Exit Do
    Loop
    KillSpace = rSUCCEED
Exit Function
ErrMgr:
    KillSpace = rVBERROR
End Function

Public Function getDouble(dblD As Double) As FUNCTION_RETURN_CODE
    On Error GoTo ErrMgr
    
    If (KillSpace() = rVBERROR) Then
    
        getDouble = rVBERROR
        Exit Function
    End If
    
    ' Pre alloc the string so we do not lose time
    Dim strS        As String: strS = Space(lngIdSize)
    Dim strSIndex   As Long
    
    Do While (((IsCharDouble()) = rTRUE) And (EOS() = rFALSE))
        Mid(strS, strSIndex + 1, 1) = Chr(m_Bytes(lngBytesIndex))
        NextChar
        strSIndex = strSIndex + 1
    Loop
    strS = Mid(strS, 1, strSIndex)
    dblD = CDbl(strS)
    getDouble = rSUCCEED
    
    Exit Function
ErrMgr:
    getDouble = rVBERROR
End Function

Public Function EOS() As FUNCTION_RETURN_CODE
    On Error GoTo ErrMgr
    If (lngBytesIndex < Length()) Then
        EOS = rFALSE
    Else
        EOS = rTRUE
    End If
    Exit Function
ErrMgr:
    EOS = rVBERROR
End Function
Private Sub Class_Initialize()
    On Error GoTo ErrMgr
    booKillSpaceOnly = False
    booAcceptPointInId = True
    booAccept2PointInId = False
    lngIdSize = 256
    lngStringSize = 256
    strDateSeparator = "/"
    m_stack.Init 64
    Exit Sub
ErrMgr:
    Debug.Print Err.Description
    Err.Clear
End Sub

Public Function NextLine() As FUNCTION_RETURN_CODE
    On Error GoTo ErrMgr
    
    Do While (IsCRLF() = rFAILED)
        NextChar
        If (EOS() = rTRUE) Then Exit Do
    Loop
    Do While (IsCRLF() = rSUCCEED)
        NextChar
        If (EOS() = rTRUE) Then Exit Do
    Loop
    
    NextLine = rSUCCEED
    Exit Function
ErrMgr:
    NextLine = rVBERROR
End Function

Public Function see(Optional pp As Long) As String
    On Error GoTo ErrMgr
    
    Exit Function
ErrMgr:
    see = rVBERROR
End Function

Public Function Percent() As Long
    On Error GoTo ErrMgr
    Percent = CLng((lngBytesIndex / Length()) * 100)
    Exit Function
ErrMgr:
    Percent = rVBERROR
End Function

Public Function Length() As Long
    On Error GoTo ErrMgr
    Length = UBound(m_Bytes()) + 1
    Exit Function
ErrMgr:
    Length = 0
    Err.Clear
End Function

Public Function Str2BytesArray(strS As String) As FUNCTION_RETURN_CODE
    On Error GoTo ErrMgr
    
    Dim i As Long
    
    
    ReDim m_Bytes(Len(strS) - 1)
    For i = 1 To Len(strS)
    
        m_Bytes(i - 1) = Asc(Mid(strS, i, 1))
    Next
    Str2BytesArray = rSUCCEED
    Exit Function
ErrMgr:
    Str2BytesArray = rFAILED
End Function

Private Function IsCharSpace() As FUNCTION_RETURN_CODE

    On Error GoTo ErrMgr
    
    If (CBool(m_Bytes(lngBytesIndex) = vbKeySpace)) Then
        IsCharSpace = rTRUE
        Exit Function
    End If
    If (booKillSpaceOnly) Then
        IsCharSpace = rFALSE
        Exit Function
    End If
    If (CBool(m_Bytes(lngBytesIndex) = vbKeyTab)) Then
        IsCharSpace = rTRUE
        Exit Function
    End If
    If (CBool(m_Bytes(lngBytesIndex) = 13)) Then
        IsCharSpace = rTRUE
        Exit Function
    End If
    If (CBool(m_Bytes(lngBytesIndex) = 10)) Then
        IsCharSpace = rTRUE
        Exit Function
    End If
    IsCharSpace = rFALSE
Exit Function
ErrMgr:
    IsCharSpace = rVBERROR
End Function

Public Function IsCharAlpha() As FUNCTION_RETURN_CODE

    On Error GoTo ErrMgr
    
    If ((m_Bytes(lngBytesIndex) >= Asc("A")) And (m_Bytes(lngBytesIndex) <= Asc("Z"))) Or _
       ((m_Bytes(lngBytesIndex) >= Asc("a")) And (m_Bytes(lngBytesIndex) <= Asc("z"))) Or _
       (m_Bytes(lngBytesIndex) = Asc("_")) Then
       
        IsCharAlpha = rTRUE
    Else
        IsCharAlpha = rFALSE
    End If
Exit Function
ErrMgr:
    IsCharAlpha = rVBERROR
End Function

Public Function IsCharNumeric() As FUNCTION_RETURN_CODE

    On Error GoTo ErrMgr
    
    If ((m_Bytes(lngBytesIndex) >= Asc("0")) And (m_Bytes(lngBytesIndex) <= Asc("9"))) Then
        IsCharNumeric = rTRUE
    Else
        IsCharNumeric = rFALSE
    End If
Exit Function
ErrMgr:
    IsCharNumeric = rVBERROR
End Function


Public Function IsCharID() As FUNCTION_RETURN_CODE
    On Error GoTo ErrMgr
    If (IsCharNumeric() = rTRUE) Then
        IsCharID = rTRUE
        Exit Function
    End If
    If (IsCharAlpha() = rTRUE) Then
        IsCharID = rTRUE
        Exit Function
    End If
    If (booAcceptPointInId) Then
        If (m_Bytes(lngBytesIndex) = Asc(".")) Then
            IsCharID = rTRUE
            Exit Function
        End If
    End If
    If (booAccept2PointInId) Then
        If (m_Bytes(lngBytesIndex) = Asc(":")) Then
            IsCharID = rTRUE
            Exit Function
        End If
    End If
    If (booAcceptMinusInId) Then
        If (m_Bytes(lngBytesIndex) = Asc("-")) Then
            IsCharID = rTRUE
            Exit Function
        End If
    End If
    IsCharID = rFALSE
    
    Exit Function
ErrMgr:
    IsCharID = rVBERROR
End Function

Public Function IsCharAlphaNumeric() As FUNCTION_RETURN_CODE
    On Error GoTo ErrMgr
    If (IsCharNumeric() = rTRUE) Then
        IsCharAlphaNumeric = rTRUE
        Exit Function
    End If
    If (IsCharAlpha() = rTRUE) Then
        IsCharAlphaNumeric = rTRUE
        Exit Function
    End If
    IsCharAlphaNumeric = rFALSE
    Exit Function
ErrMgr:
    IsCharAlphaNumeric = rVBERROR
End Function

Public Function IsCharInteger() As FUNCTION_RETURN_CODE
    On Error GoTo ErrMgr
    If (IsCharNumeric() = rTRUE) Then
        IsCharInteger = rTRUE
        Exit Function
    End If
    If (m_Bytes(lngBytesIndex) = Asc("+")) Then
        IsCharInteger = rTRUE
        Exit Function
    End If
    If (m_Bytes(lngBytesIndex) = Asc("-")) Then
        IsCharInteger = rTRUE
        Exit Function
    End If
    IsCharInteger = rFALSE
    Exit Function
ErrMgr:
    IsCharInteger = rVBERROR
End Function

Public Function IsCharDouble() As FUNCTION_RETURN_CODE
    On Error GoTo ErrMgr
    If (IsCharInteger() = rTRUE) Then
        IsCharDouble = rTRUE
        Exit Function
    End If
    If (m_Bytes(lngBytesIndex) = Asc(".")) Then
        IsCharDouble = rTRUE
        Exit Function
    End If
    IsCharDouble = rFALSE
    Exit Function
ErrMgr:
    IsCharDouble = rVBERROR
End Function

Public Function IsCharDate() As FUNCTION_RETURN_CODE
    On Error GoTo ErrMgr
    If (IsCharNumeric() = rTRUE) Then
        IsCharDate = rTRUE
        Exit Function
    End If
    If (m_Bytes(lngBytesIndex) = Asc(strDateSeparator)) Then
        IsCharDate = rTRUE
        Exit Function
    End If
    IsCharDate = rFALSE
    Exit Function
ErrMgr:
    IsCharDate = rVBERROR
End Function


Public Function Bench() As FUNCTION_RETURN_CODE

    Dim i           As Long
    Dim d           As Double
    Dim r           As Long
    Dim b           As Long
    Dim s           As String
    Dim vbLex       As New CByteSyntaxAnalyser
    
        
    Const strTest = vbCrLf & "Toto(1245,123.456)" & vbCrLf
    Dim tim As Long
    
    'tim = GetTickCount()
    For b = 1 To 5000
            vbLex.Init strTest
            vbLex.GetNextLine
            vbLex.GetIdentifier s
            vbLex.GetChar "("
            vbLex.getInteger i
            vbLex.GetChar ","
            vbLex.getDouble d
            vbLex.GetChar ")"
            vbLex.GetNextLine
    Next
    'MsgBox GetTickCount() - tim
    
    Bench = rSUCCEED
    
End Function

Public Function DataString(Optional lngIndex As Long = -1) As String
    If (lngIndex = -1) Then
        DataString = m_string
    Else
        Dim i As Long
        Dim s As String
        For i = lngIndex To Length() - 1
            s = s & Me.GetCChar(i)
        
        Next
        DataString = s
    End If
End Function


Public Function GetCByteChar(Optional lngIndex As Long = -1) As Byte

    If (lngIndex = -1) Then lngIndex = lngBytesIndex
    If (Length() = 0) Then Exit Function
    
    GetCByteChar = (m_Bytes(lngIndex))
End Function

Public Function GetCChar(Optional lngIndex As Long = -1) As String

    If (lngIndex = -1) Then lngIndex = lngBytesIndex
    
    If (Length() = 0) Then Exit Function
    
    GetCChar = Chr(m_Bytes(lngIndex))

    
End Function

Public Function PopBytesIndex(Optional booRestorIndex As Boolean = True) As Long
    If (booRestorIndex) Then
        lngBytesIndex = CLng(m_stack.Pop())
        PopBytesIndex = lngBytesIndex
    Else
        m_stack.Pop ' Lose the value
    End If
End Function
Public Function PushBytesIndex() As Long
    m_stack.Push lngBytesIndex
    PushBytesIndex = lngBytesIndex
End Function
Private Sub Class_Terminate()
    m_stack.Done
End Sub


Private Function IsCRLF() As FUNCTION_RETURN_CODE

    On Error GoTo ErrMgr
    

    If (CBool(m_Bytes(lngBytesIndex) = 13)) Then
        IsCRLF = rTRUE
        Exit Function
    End If
    If (CBool(m_Bytes(lngBytesIndex) = 10)) Then
        IsCRLF = rTRUE
        Exit Function
    End If
    IsCRLF = rFALSE
Exit Function
ErrMgr:
    IsCRLF = rVBERROR
End Function

Public Function NextChar(Optional lngStep As Long = 1) As Boolean

    On Error GoTo ErrMgr
    
    lngBytesIndex = lngBytesIndex + lngStep
        
    If (lngBytesIndex > m_lngMaxBytesIndex) Then m_lngMaxBytesIndex = lngBytesIndex
    
    NextChar = True
    Exit Function
ErrMgr:
End Function

Public Property Get MaxBytesIndex() As Long
    MaxBytesIndex = m_lngMaxBytesIndex
End Property


Public Function IsID(strId As String) As FUNCTION_RETURN_CODE

    On Error GoTo ErrMgr
    
    Dim i As Long
    
    Dim clsTmpParser As New CByteSyntaxAnalyser
    
    clsTmpParser.Init strId
    
    IsID = rFAILED
    
    For i = 1 To Len(strId)
    
        If (clsTmpParser.IsCharID() = rFAILED) Then Exit Function
    Next
    IsID = rSUCCEED
    Exit Function
ErrMgr:
End Function

Public Function IsLong(strLong As String) As Boolean
    If (IsNumeric(strLong)) Then
        IsLong = InStr(strLong, ".") = 0
    End If
End Function

Public Function IsBool(strStr As String) As Boolean
        IsBool = UCase(strStr = "TRUE") Or UCase(strStr = "FALSE")
End Function
