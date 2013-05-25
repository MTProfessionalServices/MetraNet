VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "Unicode2Big5Translater"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Public Item As New Collection
Attribute Item.VB_VarUserMemId = 0
Public TRACE_ID As Long

Public Function Initialize(ByVal strXMLFileName As String) As Boolean

    Dim objTextFile As New cTextFile
    Dim s           As String
    Dim objParser   As New CByteSyntaxAnalyser
    Dim strTok      As String
    Dim strId       As String
    Dim strValue    As String
    Dim strData     As String
    
    On Error GoTo ErrMgr
    
    Initialize = False
    
    TRACE Replace(MTMSIX_ERROR_01074, "[FILE]", strXMLFileName), "Unicode2Big5Translater.cls", "Initialize", LOG_WARNING
        
    If (objTextFile.OpenFile(strXMLFileName)) Then
        
        '<a b='41' u='0041' c='A'/>
        '<a b='81 A2' u='4EEE' c='仮'/>
        Do While Not objTextFile.EOF()
        
            s = objTextFile.ReadLn()
            objParser.Init s
            If (objParser.GetChar("<") = rSUCCEED) Then
                If (objParser.GetIdentifier(strTok) = rSUCCEED) Then
                    If (strTok = "A") Then
                        Do
                            If (objParser.GetIdentifier(strTok) = rFAILED) Then
                            
                                If (objParser.GetChar("/") = rFAILED) Then GoTo SyntaxError
                                Item.Add strData, "I" & strId
                                If Len(strData) > 2 Then
                                    strData = strData
                                End If
                                Exit Do
                            End If
                            If (objParser.GetChar("=") = rFAILED) Then GoTo SyntaxError
                            If (objParser.GetString(strValue, "'") = rFAILED) Then GoTo SyntaxError
                            
                            Select Case strTok
                            
                                Case "U"
                                    strId = strValue
                                    
                                    
                                Case "B"
                                    strData = strValue
                                    If Len(strData) > 2 Then
                                        strData = Mid$(strData, 1, 2) & Mid$(strData, 4, 5)
                                    End If
                                    strData = ConvertBig5HexToString(strData)
                             End Select
                            
                        Loop
                    End If
                End If
            End If
        Loop
        Initialize = True
        
        objTextFile.CloseFile
    End If
    Exit Function
    
SyntaxError:
    TRACE Replace(MTMSIX_ERROR_01070, "[FILE]", strXMLFileName), "UUnicode2Big5Translater.cls", "Initialize", LOG_ERROR
    Exit Function
    
ErrMgr:

    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "UUnicode2Big5Translater.cls", "Initialize", LOG_ERROR

End Function

Public Function UnitCode2Big5(ByVal strUniCode As String) As String
    Dim l               As Long
    Dim i               As Long
    Dim strUniCodeKey   As String
    Dim s               As String
    Dim strBigHex       As String
    
    
    
    On Error GoTo ErrMgr
    
    l = Len(strUniCode)
    
    For i = 1 To l
    
        strUniCodeKey = Hex(AscW(Mid$(strUniCode, i, 1))) ' Build the unicode string
        Do While Len(strUniCodeKey) < 4
        
            strUniCodeKey = "0" & strUniCodeKey
        Loop
        On Error Resume Next
        
        s = s & Item("I" & strUniCodeKey)
        If (Err.Number) Then
            TRACE MTMSIX_ERROR_01071, "Unicode2Big5Translater.cls", "UnitCode2Big5", LOG_ERROR
            Err.Clear
            s = s & MTMSIX_ERROR_01071
        End If
        On Error GoTo ErrMgr
    Next
    UnitCode2Big5 = s
    Exit Function
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "Unicode2Big5Translater.cls", "UnitCode2Big5", LOG_ERROR
End Function



Private Function ConvertBig5HexToString(strBigHex As String) As String

    Dim i As Long
    Dim s As String
    
    For i = 1 To Len(strBigHex) Step 2
    
        s = s & Chr(CLng("&H" & Mid$(strBigHex, i, 2)))
    Next
    ConvertBig5HexToString = s
End Function

Private Sub Class_Initialize()
    TRACE_CONSTRUCTOR_DESTRUCTOR Me, TRACE_CONSTRUCTOR_MODE
End Sub

Private Sub Class_Terminate()
    TRACE_CONSTRUCTOR_DESTRUCTOR Me, TRACE_DESTRUCTOR_MODE
End Sub
