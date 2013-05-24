VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CWebLoad"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
' ****************************************************************************************************************************************************
'
'  Written (W) by Frederic Torres 2001-2002
'  ARR.
'
'  CLASS        :
'  AUTHOR       : Frederic Torres
'  DATE         : 09/xx/2001
'  DESCRIPTION  :
'  VERSION      : none.
'
' ****************************************************************************************************************************************************
Option Explicit

#If W3RUNNER_DEFINE Then
        
#Else
    Private m_objInternalHTTP As CHTTP
#End If

Public Enum WEBLOAD_MODE
    WEBLOAD_MODE_RECORD = 1
    WEBLOAD_MODE_GET_VBSCRIPT = 2
    WEBLOAD_MODE_GET_TRACE = 4
End Enum

Private m_strFileName As String

Private m_lngRecordID As Long

Public Function Initialize() As Boolean

End Function

Public Function Record(eMode As WEBLOAD_MODE, ByVal URL As Variant, ByVal Flags As Variant, ByVal TargetFrameName As Variant, ByVal PostData As Variant, ByVal Headers As Variant) As Variant

    Dim v               As Variant
    Dim s               As String
    Dim strScript       As String
    Dim strMethod       As String
    Dim strParameters   As String
    Dim objTextFile     As New cTextFile
    Dim ArrParameters   As Variant
    Dim ArrParameter    As Variant
    Dim ArrHeaders      As Variant
    Dim ArrHeader       As Variant
    Dim lngPos          As Long
    Dim strHTTPScript   As String
    Dim strHTTPParameters   As String
    Dim strHTTPHeaders   As String
    
    On Error GoTo errmgr
    
    lngPos = InStr(URL, "?")
    If lngPos Then
        strParameters = Mid(URL, lngPos + 1)
        URL = Mid(URL, 1, lngPos - 1)
    End If
    
    ' Check if we have a form post
    If InStr(Headers, "application/x-www-form-urlencoded") Then
    
        'TRACE url & vbNewLine & TypeName(PostData) & vbNewLine & Headers, w3rMEMORY
        v = PostData
        strParameters = StrConv(v, vbUnicode)
        strParameters = Replace(strParameters, Chr(0), "")
        strMethod = "POST"
    Else
        strMethod = "GET"
    End If
    
    strScript = strScript & "HTTP.Method = ""[METHOD]""" & vbNewLine
    strScript = strScript & "HTTP.URL = ""[URL]""" & vbNewLine
    strScript = strScript & "HTTP.Target = ""[TARGET]""" & vbNewLine
    
    If Len(Headers) Then ' Decode Input Headers
    
        s = Replace(Headers, vbNewLine, Chr(13))
        
        ArrHeaders = Split(s, Chr(13))
        
        For Each v In ArrHeaders
        
            If Len(CStr(v)) Then
            
                ArrHeader = Split(v, ":")
                strScript = strScript & "HTTP.InputHeaders.Add """ & ArrHeader(0) & """,""" & Trim(ArrHeader(1)) & """" & vbNewLine
                strHTTPHeaders = strHTTPHeaders & ArrHeader(0) & ":" & ArrHeader(1) & ";"
            End If
        Next
    End If
    
    If Len(strParameters) Then ' Decode Parameters
    
        ArrParameters = Split(strParameters, "&")
        
        For Each v In ArrParameters
        
            ArrParameter = Split(CStr(v), "=")
            If IsArray(ArrParameter) Then
            
                If UBound(ArrParameter) = 1 Then
                
                    strScript = strScript & "HTTP.Parameters.Add """ & ArrParameter(0) & """,""" & DecodeUrl(ArrParameter(1)) & """" & vbNewLine
                    strHTTPParameters = strHTTPParameters & ArrParameter(0) & "=" & DecodeUrl(ArrParameter(1)) & ";"
                    
                ElseIf UBound(ArrParameter) = 0 Then
                
                    strScript = strScript & "HTTP.Parameters.Add """ & ArrParameter(0) & """,""" & """" & vbNewLine
                    strHTTPParameters = strHTTPParameters & ArrParameter(0) & "=" & ";"
                End If
            End If
        Next
    End If
    
    ' Generate the VBScript source code
    strScript = strScript & "If HTTP.Execute<>CHTTP_ERROR_OK Then" & vbNewLine
    strScript = strScript & "   HTTP.Trace w3rERROR" & vbNewLine
    strScript = strScript & "   Exit Function" & vbNewLine
    strScript = strScript & "End If" & vbNewLine
    strScript = PreProcess(strScript, "METHOD", strMethod, "URL", URL, "TARGET", TargetFrameName, "DC", """")
    
    ' Generate the call in a traceable way
    strHTTPScript = "[METHOD] [DC][URL][DC] [DC][PARAM][DC] [DC][HEADER][DC]"
    strHTTPScript = PreProcess(strHTTPScript, "HEADER", strHTTPHeaders, "PARAM", strHTTPParameters, "METHOD", strMethod, "URL", URL, "TARGET", TargetFrameName, "DC", """")
    
    If eMode = WEBLOAD_MODE_RECORD Then
    
        Record = LogString(strScript)
        
    ElseIf eMode = WEBLOAD_MODE_GET_TRACE Then
    
        #If W3RUNNER_DEFINE Then
            frmMain.TRACE strHTTPScript, w3rTRACEHTTP
        #Else
        #End If
    Else
        Record = strScript
    End If
    Exit Function
errmgr:
    Debug.Assert 0
End Function



Public Function LogString(strScript As String) As Boolean
    Dim objTextFile As New cTextFile
    LogString = objTextFile.LogFile(FileName, strScript)
End Function

Public Property Get FileName() As String
    If Len(m_strFileName) Then
        FileName = m_strFileName
    Else
        FileName = Environ("TEMP") & "\" & GetProgramName() & ".Http.Protocol.vbs"
    End If
End Property

Public Property Let FileName(ByVal vNewValue As String)
    m_strFileName = vNewValue
End Property

Public Function StartRecording(strScriptFileName As String) As Boolean

    Dim objTextFile As New cTextFile
    objTextFile.DeleteFile FileName
    m_lngRecordID = GetTickCount()
    StartRecording = LogString(PreProcess(W3RUNNER_MSG_07035, "SCRIPT", strScriptFileName, "NOW", Now(), "CRLF", vbNewLine, "LINE", String(128, "*"), "RECORDID", m_lngRecordID))
End Function

Public Function StopRecording() As Boolean

    StopRecording = LogString(PreProcess(W3RUNNER_MSG_07045, "NOW", Now(), "CRLF", vbNewLine, "LINE", String(128, "*"), "RECORDID", m_lngRecordID))
End Function

Public Function GetObjHTTP() As CHTTP
    #If W3RUNNER_DEFINE Then
        Set GetObjHTTP = g_objHTTP
    #Else
        If Not IsValidObject(m_objInternalHTTP) Then
            Set m_objInternalHTTP = New CHTTP
        End If
        Set GetObjHTTP = m_objInternalHTTP
    #End If
End Function
