Attribute VB_Name = "TRACER"
Option Explicit

Public Enum TRACER_TRACE_MODE

    trcINFO = 1
    trcERROR = 2
    trcWARNING = 4
    trcSQL = 8
    trcURL = 16
    trcMEMORY = 32
    trcDEBUG = 64
    trcINTERNAL = 128
    trcMETHOD = 256
    trcJAVASCRIPT = 512
    trcSUCCESS = 1024
    trcCLEAR_TRACE = 2048
    trcPERFORMANCE = 4096
    trcWEBSERVICE = 8192
    trcTRACEHTTP = 16384
End Enum

Private Function LogFileName() As String

    LogFileName = Environ("TEMP") & "\" & App.EXEName & ".Tracer.log"
End Function

Public Function DebugOut(ByVal strMessage As String, Optional eMode As TRACER_TRACE_MODE = trcINFO, Optional strModule As Variant, Optional strFunctionName As String) As Boolean

    #If TRACER Then
    
        If IsMissing(strModule) Then strModule = ""
        If IsObject(strModule) Then strModule = TypeName(strModule)
        If Len(strModule) Then strModule = "Module:" & strModule
        If Len(strFunctionName) Then strFunctionName = "Function:" & strFunctionName
        
        
        Dim objTextFile As New cTextFile
        DebugOut = objTextFile.LogFile(LogFileName(), Now() & " " & strModule & " " & strFunctionName & " " & strMessage)
    #Else
        DebugOut = True
    #End If
End Function


