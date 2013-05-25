Attribute VB_Name = "MPFMModule"
Option Explicit

Public g_objIniFile                     As New cIniFile
Public g_objTextFile                    As New cTextFile



Public Const MPV_ERROR_1000 = "No Error"
Public Const MPV_ERROR_1001 = "Run Time Error Occured."
Public Const MPV_ERROR_1002 = "Invalid value read in csv file [FILE], Line [LINE], Column [COLUMN]"
Public Const MPV_ERROR_1003 = "Cannot open database"

Public Const MPV_MSG_1000 = "MetraTech Performance Viewer"
Public Const MPV_MSG_1001 = "Ready..."
Public Const MPV_MSG_1002 = "Script File Name"
Public Const MPV_MSG_1003 = "VBScript file|*.vbs|All Files(*.*)|*.*"
Public Const MPV_MSG_1004 = "The Script was canceled"
Public Const MPV_MSG_1005 = "Cancel the script execution ?"
Public Const MPV_MSG_1006 = "Lanch [URL]"
Public Const MPV_MSG_1007 = "Refreshing data"


Public Enum MPV_TRACE_MODE

    mpvINFO = 1
    mpvERROR = 2
    mpvWARNING = 4
    mpvSQL = 8
    mpvDEBUG = 64
    mpvINTERNAL = 128
    mpvSUCCEED = 256
    mpvCLEAR_TRACE = 512
    mpvPERFORMANCE = 1024
End Enum

Public Enum eAPP_ACTION
    LOAD_DATA
    SAVE_DATA
    LOAD_LISTVIEW_COLUMS_SIZE
End Enum

Public Sub Main()

    g_objIniFile.InitAutomatic App
    
    Load frmMain
    frmMain.TRACE MPV_MSG_1001, mpvINFO
    frmMain.Show
    frmMain.mnuView_Click
End Sub

Public Property Get AppOptions(ByVal strOptionName As String, Optional strDefaultValue As String, Optional ByVal strSection = "frmOPTIONS") As String

    AppOptions = g_objIniFile.getVar(strSection, strOptionName, strDefaultValue)
End Property

Public Property Let AppOptions(ByVal strOptionName As String, Optional strDefaultValue As String, Optional ByVal strSection = "frmOPTIONS", sValue As String)

    g_objIniFile.SetVar strSection, strOptionName, sValue
End Property



Public Function AppShowError(ByVal strMessage As String, Optional strModuleName As String, Optional strFunctionName As String) As Boolean

    On Error GoTo ErrMgr
    
    Dim strMessage2 As String

    strMessage2 = PreProcess(strMessage, "CRLF", vbNewLine)
    
    If (Len(strModuleName)) Then
    
        strMessage2 = strMessage2 & vbNewLine & "Module=" & strModuleName & " Function=" & strFunctionName
    End If
    Screen.MousePointer = 0
    MsgBox strMessage2, vbCritical + vbOKOnly
    Exit Function
ErrMgr:
    MsgBox strMessage2
End Function

Public Function GlobalDoEvents() As Boolean
    DoEvents
End Function

Public Function LanchWebApp(strAppName As String) As Boolean
    Dim strS    As String
    Dim objTool As New cTool
    
    strS = "http://" & AppOptions("WebServer") & "/" & strAppName
    TRACE PreProcess(MPV_MSG_1006, "URL", strS)
    objTool.ExecFile strS
    LanchWebApp = True
End Function

Public Function TRACE(ByVal strMessage As String, Optional eMode As MPV_TRACE_MODE = mpvINFO) As Boolean

    TRACE = frmMain.TRACE(strMessage, eMode)
End Function

Public Function MPFMLogFileName() As String
    MPFMLogFileName = Environ("temp") & "\mpfm.log"
End Function




