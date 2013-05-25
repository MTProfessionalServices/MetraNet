Attribute VB_Name = "MPFMModule"
Option Explicit

Public g_objIniFile                     As New cIniFile
Public g_objTextFile                    As New cTextFile
Public g_objPerformanceScriptManager    As New CPerformanceScriptManager

Public Enum MPFM_TRACE_MODE

    mpfmINFO = 1
    mpfmERROR = 2
    mpfmWARNING = 4
    mpfmSQL = 8
    mpfmDEBUG = 64
    mpfmINTERNAL = 128
    mpfmSUCCEED = 256
    mpfmCLEAR_TRACE = 512
    mpfmPERFORMANCE = 1024
End Enum

Public Const MPFM_ERROR_1000 = "No Error"
Public Const MPFM_ERROR_1001 = "Run Time Error Occured."


Public Const MPFM_MSG_1000 = "MetraTech Performance Manager"
Public Const MPFM_MSG_1001 = "Ready..."
Public Const MPFM_MSG_1002 = "Script File Name"
Public Const MPFM_MSG_1003 = "VBScript file|*.vbs|All Files(*.*)|*.*"
Public Const MPFM_MSG_1004 = "The Script was canceled"
Public Const MPFM_MSG_1005 = "Cancel the script execution ?"
Public Const MPFM_MSG_1006 = "Lanch [URL]"


Public Enum eAPP_ACTION
    LOAD_DATA
    SAVE_DATA
    LOAD_LISTVIEW_COLUMS_SIZE
End Enum

Public Sub Main()

    g_objIniFile.InitAutomatic App
    g_objPerformanceScriptManager.Initialize
    Load frmMain
    frmMain.TRACE MPFM_MSG_1001, mpfmINFO
    frmMain.Show
End Sub

Public Property Get AppOptions(ByVal strOptionName As String, Optional strDefaultValue As String, Optional ByVal strSection = "frmOPTIONS") As String

    AppOptions = g_objIniFile.getVar(strSection, strOptionName, strDefaultValue)
End Property

Public Property Let AppOptions(ByVal strOptionName As String, Optional strDefaultValue As String, Optional ByVal strSection = "frmOPTIONS", sValue As String)

    g_objIniFile.SetVar strSection, strOptionName, sValue
End Property



Public Function AppShowError(ByVal strMessage As String, Optional strModuleName As String, Optional strFunctionName As String) As Boolean

    On Error GoTo errmgr
    
    Dim strMessage2 As String

    strMessage2 = PreProcess(strMessage, "CRLF", vbNewLine)
    
    If (Len(strModuleName)) Then
    
        strMessage2 = strMessage2 & vbNewLine & "Module=" & strModuleName & " Function=" & strFunctionName
    End If
    Screen.MousePointer = 0
    MsgBox strMessage2, vbCritical + vbOKOnly
    Exit Function
errmgr:
    MsgBox strMessage2
End Function

Public Function GlobalDoEvents() As Boolean
    DoEvents
End Function

Public Function LanchWebApp(strAppName As String) As Boolean
    Dim strS    As String
    Dim objTool As New cTool
    
    strS = "http://" & AppOptions("WebServer") & "/" & strAppName
    TRACE PreProcess(MPFM_MSG_1006, "URL", strS)
    objTool.ExecFile strS
    LanchWebApp = True
End Function

Public Function TRACE(ByVal strMessage As String, Optional eMode As MPFM_TRACE_MODE = mpfmINFO) As Boolean

    TRACE = frmMain.TRACE(strMessage, eMode)
End Function

Public Function MPFMLogFileName() As String
    MPFMLogFileName = Environ("temp") & "\mpfm.log"
End Function


