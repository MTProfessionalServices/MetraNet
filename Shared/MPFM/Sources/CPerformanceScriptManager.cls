VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CPerformanceScriptManager"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit



Public TextFile As cTextFile

Private m_strScriptFileName As String

Public VBScriptEngine As CVBScript
Private m_booCancelScript   As Boolean

Public Function Initialize() As Boolean

    Initialize = True
End Function

Public Property Get ScriptFileName() As String
    ScriptFileName = m_strScriptFileName
End Property

Public Property Let ScriptFileName(ByVal v As String)
    m_strScriptFileName = v
    InitVBScriptEngine
End Property

Public Function TRACE(ByVal strMessage As String, Optional eMode As MPFM_TRACE_MODE = mpfmINFO) As Boolean
    TRACE = frmMain.TRACE(strMessage, eMode)
End Function

Public Property Get ScriptFileNameOnly() As String
    Dim objTextFile As New cTextFile
    ScriptFileNameOnly = objTextFile.GetFileName(Me.ScriptFileName)
End Property

Public Function Run(Optional strParameter As String) As Boolean

    Run = ExecFunction("run", strParameter)
End Function


Private Function InitVBScriptEngine() As Boolean

    On Error GoTo errmgr
    
    Dim strDefaultCode As String

    Set VBScriptEngine = New CVBScript
    
    
    'Debug.Assert 0
    
    VBScriptEngine.FileName = Me.ScriptFileName
    VBScriptEngine.BootStrapFileName = App.Path & "\mpfm.vbs"
    VBScriptEngine.OnErrorEvent = ""
        
    VBScriptEngine.VBSEngine.AddObject "MPFM", g_objPerformanceScriptManager
        
    strDefaultCode = "PUBLIC CONST MPFM_RUNNING = TRUE"
    
    strDefaultCode = strDefaultCode & PreProcess("[CRLF]Private Function GetFredRunnerLibraryPath()[CRLF]GetFredRunnerLibraryPath = UI.Environ(""MetratechTestDatabase"") & ""\Development\ui\Application Tests\FredRunner.Library""[CRLF]End Function[CRLF]", "CRLF", vbNewLine)
    strDefaultCode = strDefaultCode & PreProcess("[CRLF]Private Function GetMetratechTestDatabase()[CRLF]GetMetratechTestDatabase = UI.Environ(""MetratechTestDatabase"")[CRLF]End Function[CRLF]", "CRLF", vbNewLine)
    
    If (Not VBScriptEngine.AddCode(strDefaultCode)) Then Exit Function
    
    If (Not VBScriptEngine.AddMainCode) Then Exit Function
    
    'If (Not LoadScriptFilePublicMethod) Then Exit Function
    InitVBScriptEngine = True
Exit Function
errmgr:
    AppShowError MPFM_ERROR_1001 & " " & GetVBErrorString(), "frmMain.frm", "InitVBScriptEngine"
End Function



Public Function Environ(ByVal strName As String) As String
    Environ = VBA.Environ$(strName)
End Function



' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : LoadVBScriptCode
' PARAMETERS    :
' DESCRIPTION   : Load some VBScript code and add at the end of each line the line number and the file name
' RETURN        :
Public Function LoadVBScriptCode(ByVal strFileName As String, ByRef varCode As Variant) As Boolean

    On Error GoTo errmgr
        
    Dim objVBEngine     As New CVBScript
    Dim objTextFile     As New cTextFile
    Dim strCodeSource   As String
    Dim lngLineCount    As Long
    
    If objTextFile.ExistFile(strFileName) Then
    
        objVBEngine.LoadAScript strFileName, strCodeSource, lngLineCount
        varCode = strCodeSource
        LoadVBScriptCode = True
    End If
Exit Function
errmgr:
    AppShowError MPFM_ERROR_1001 & " " & GetVBErrorString(), "FredRunnerPage.cls", "LoadVBScriptCode"
End Function


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : CheckVBScriptCode
' PARAMETERS    :
' DESCRIPTION   : Allow the FredRunner VBS function Include to show a good error message in case of syntax error.
'                 This is an internal, non documented function...
' RETURN        :
Public Function CheckVBScriptCode(ByVal strFileName As String) As Boolean

    On Error GoTo errmgr
    
    Dim objVBEngine     As New CVBScript
    Dim objTextFile     As New cTextFile
    Dim strCodeSource   As String
    Dim lngLineCount    As Long
    
    If objTextFile.ExistFile(strFileName) Then
    
        objVBEngine.LoadAScript strFileName, strCodeSource, lngLineCount
        CheckVBScriptCode = objVBEngine.AddCode(strCodeSource)
    End If
Exit Function
errmgr:
    AppShowError MPFM_ERROR_1001 & " " & GetVBErrorString(), "FredRunnerPage.cls", "CheckVBScriptCode"
End Function

Public Property Get CancelScript() As Boolean
    CancelScript = m_booCancelScript
    GlobalDoEvents
End Property

Public Property Let CancelScript(ByVal v As Boolean)
    m_booCancelScript = v
End Property

Public Property Get Path() As String
    Path = App.Path
End Property



Public Function MsgBox(ByVal strMessage As String, Optional strTitle As String) As Boolean

    On Error GoTo errmgr
    
    'Dim strMsgBoxTimeOut
    'strMsgBoxTimeOut = AppOptions("MsgBoxTimeOut", FRED_RUNNER_DEFAULT_MSGBOX_TIME_OUT)

    VBA.MsgBox strMessage, , strTitle
        
    'MsgBox = frmMsgbox.OpenDialog(strMessage, strTitle, strMsgBoxTimeOut)
Exit Function
errmgr:
    AppShowError MPFM_ERROR_1001 & " " & GetVBErrorString(), "CPerformanceScriptManager.cls", "MsgBox"
End Function



' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Property Get ScriptFilePath() As String

    On Error GoTo errmgr
    
    Dim objTextFile As New cTextFile
    ScriptFilePath = objTextFile.GetPathFromFileName(ScriptFileName)
Exit Function
errmgr:
    AppShowError MPFM_ERROR_1001 & " " & GetVBErrorString(), "FredRunnerPage.cls", "ScriptFilePath"
End Property


Private Function ExecFunction(strFunction As String, strParameter) As Variant

    Dim strErrorMessage As String
    Dim i As Long
    
    CancelScript = False

    ' force to re-load
    ScriptFileName = ScriptFileName
    
    ExecFunction = VBScriptEngine.Execute("MPFMClient." & strFunction & "(""" & strParameter & """)", strErrorMessage, , True)

    If Len(strErrorMessage) Then TRACE strErrorMessage, mpfmERROR
    
    If g_objPerformanceScriptManager.CancelScript Then TRACE MPFM_MSG_1004
    
End Function


Public Function Statistic(Optional strParameter As String) As Boolean

    Statistic = ExecFunction("Statistic", strParameter)
End Function

Public Sub Sleep(ByVal lngMSTime As Long)
    cWindowsModule.Sleep lngMSTime
End Sub

Private Sub Class_Initialize()
    Set TextFile = New cTextFile
End Sub



Public Function Export() As Boolean

    Export = ExecFunction("Export", ResultFileName())
End Function
