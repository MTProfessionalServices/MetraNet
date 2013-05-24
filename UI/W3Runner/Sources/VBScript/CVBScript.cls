VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CVBScript"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
' ************************************************************************************************************************************************************************************************************************************************************************
'
' NAME          :   CVBScript.cls
' DESCRIPTION   :   Wrapper to make an application VBScriptAble...
' AUTHOR        :   F.Torres.
' CREATION DATE :   07/14/1999
'
' HISTORY       :   07/14/2000
'                   I developped this class to implement the first fLogViewer function Plug in.
'
'                   11/01/2000
'                   Turn the fLogViewer plug in into object. The class support Object Plug In.
'
'                   01/21/2001
'                   Support of debug mode
'
'                   03/13/2001
'                   Use and Improved this class for W3Runner.
'
'                   09/18/2001
'                   Add the notion of firing event. use a regular function call. For W3Runner W3Runner_OnError, W3Runner_OnTrace
'
'
' ************************************************************************************************************************************************************************************************************************************************************************
Option Explicit

Public VBSEngine                    As Object
Public ScriptSource                 As String
Public BootStrapScriptSource        As String

Private Const VBSCRIPT_CONTROL_PROG_ID = "MSScriptControl.ScriptControl"

Private Const VBSCRIPT_ERROR_07011 = "File [FILE] not found."
Private Const VBSCRIPT_ERROR_07027 = "Error=[ERROR], Description=[DESCRIPTION][CRLF]VBScript Source=[VBSCRIPT]" ' VBScript Class Error message format
Private Const VBSCRIPT_MSG_07035 = "This line has been commented because you can not have 2 or more Page.WaitDownload() in a row. Check to be sure that the Page.WaitForDownLoad() which is not commented is the one you really want to wait for."
Private Const VBSCRIPT_ERROR_07033 = "Run time error catch calling the event [EVENT][CRLF][VBSCRIPT_ERROR]"


Private Const CVBSCRIPT_ERROR_1000 = "CVBScript.Cls-Unexpected VBScript run time error"

Private m_lngBootStrapScriptSourceLineCount As Long

Private m_strFileName               As String
Private m_strBootStrapFileName      As String

Private Const REGISTRY_DEBUGGING_FOLDER = "Software\Microsoft\Windows Script\Settings"
Private Const REGISTRY_DEBUGGING_VAR = "JITDebug"

Public CodeLength As Long

Private m_varWebBrowserVersion As Variant
Private m_booRunning As Boolean

Public OnErrorEvent As String


Public Function Execute(ByVal strFunctionName As String, ByRef strErrorMessage As String, Optional lngTimeOut As Long = 20, Optional booEval As Boolean = False) As Variant

    On Error GoTo errmgr
    
    Dim objError            As New CError
    Dim strLineErrorCode    As String
    Dim booIsErrorInInclude As Boolean
    Dim varEvalValue As Variant
       
    If (lngTimeOut) Then
        VBSEngine.TimeOut = lngTimeOut * 1000
    End If

    m_booRunning = True
    If booEval Then
    
        Execute = VBSEngine.Eval(strFunctionName)
    Else
    
        Execute = VBSEngine.Run(strFunctionName)
    End If
    m_booRunning = False
    Exit Function
errmgr:

    If (VBSEngine.Error.Number) Then ' VBScriptin Control Error
    
        objError.Save VBSEngine.Error
        If Len(OnErrorEvent) Then Me.ExecuteEvent OnErrorEvent, objError.Number, objError.Description, objError.Source
        #If W3RUNNER_DEFINE Then
            frmMain.TRACE objError.ToString(), w3rERROR
        #End If
        
    Else ' Regular Run Time Error
    
        objError.Save Err
        If Len(OnErrorEvent) Then Me.ExecuteEvent OnErrorEvent, Err.Number, Err.Description, Err.Source
        #If W3RUNNER_DEFINE Then
            frmMain.TRACE objError.ToString(), w3rERROR
        #End If
    End If
    m_booRunning = False
End Function

Private Function RaiseError(ByVal strMessage As String, Optional lngErrorCode As Long = 1) As Boolean
    Err.Raise vbObjectError + lngErrorCode, "CVBScript.cls", strMessage
End Function


Private Function GetLibraryCode(ByVal strFileName As String) As String

    On Error GoTo errmgr

    Dim objTextFile     As New cTextFile
    Dim objCat          As New cStringConcat
    Dim strShortName    As String
    Dim s               As String
    Dim lngLineCounter  As Long
    
    objCat.Init 16384
    strFileName = GetLibraryPath() & "\" & strFileName
    strShortName = objTextFile.GetFileName(strFileName)

    If (objTextFile.ExistFile(strFileName)) Then
            
        If (objTextFile.OpenFile(strFileName)) Then
        
            Do While Not objTextFile.EOF()
            
                s = objTextFile.ReadLn()
                lngLineCounter = lngLineCounter + 1
                objCat.Concat s & " '~#|L=" & lngLineCounter & " ~#|F=" & strShortName & vbNewLine
            Loop
            objTextFile.CloseFile
        End If
        GetLibraryCode = vbNewLine & objCat.GetString()
    End If
    Exit Function
errmgr:
    RaiseError Err.Description, Err.Number
End Function



Private Function GetScriptBackUpFileName() As String
    GetScriptBackUpFileName = Environ("TEMP") & "\CVBScript.BackUp.vbs"
End Function


Private Function GetScriptLine(lngLine As Long) As String
    
    Dim objTextFile     As New cTextFile
    Dim lngLineCounter  As Long
    Dim s               As String
    
    If (objTextFile.OpenFile(FileName())) Then
    
        Do While Not objTextFile.EOF()
        
            s = objTextFile.ReadLn()
            lngLineCounter = lngLineCounter + 1
            If (lngLineCounter = lngLine) Then
                GetScriptLine = s
                Exit Function
            End If
        Loop
    End If
End Function


Public Property Get FileName() As String
    FileName = m_strFileName
End Property

Public Property Let FileName(ByVal vNewValue As String)

    Dim objTextFile As New cTextFile
    m_strFileName = vNewValue
    
    ' Load the script + include
    If (Not LoadAScript(FileName, ScriptSource, 0, Me.IsFileNameCrypted(m_strFileName))) Then RaiseError "Cannot load " & FileName
        
End Property

Private Sub CreateScriptControl()
    Set VBSEngine = CreateObject(VBSCRIPT_CONTROL_PROG_ID)
    VBSEngine.language = "VBScript"
    VBSEngine.TimeOut = CLng(200) * 1000
End Sub

Private Sub Class_Initialize()
    CreateScriptControl
End Sub

Private Sub Class_Terminate()
    'If IsValidObject(VBSEngine) Then
        'VBSEngine.Reset
    'End If
    Set VBSEngine = Nothing
End Sub

Private Function GetLibraryPath() As String

    Dim objTextFile As New cTextFile

    GetLibraryPath = objTextFile.GetPathFromFileName(FileName)
    
End Function

Public Function LoadPublicMethods(colPublicMethod As Collection, Optional ByVal booClear As Boolean = True) As Boolean

    Dim objTextFile As New cTextFile
    Dim strS        As String
    Dim objParser   As New CByteSyntaxAnalyser
    Dim strTok      As String
    Dim objProc     As Variant
    Dim strSource   As String
    Dim lngLine     As Long
    
    On Error GoTo errmgr
    
    If (booClear) Then Set colPublicMethod = New Collection
    
    For Each objProc In VBSEngine.Modules("Global").Procedures
    
        colPublicMethod.Add objProc.Name
    Next
    LoadPublicMethods = True
    Exit Function
errmgr:
    MsgBox GetVBErrorString()
End Function

Public Property Get BootStrapFileName() As String
    m_strBootStrapFileName = BootStrapFileName
End Property

Public Property Let BootStrapFileName(ByVal vNewValue As String)

    Dim objTextFile As New cTextFile
    
    m_strBootStrapFileName = vNewValue
    LoadAScript m_strBootStrapFileName, BootStrapScriptSource, m_lngBootStrapScriptSourceLineCount, Me.IsFileNameCrypted(m_strBootStrapFileName)
End Property


Public Function UnLoadAScript(ByVal strFileName As String, ByRef strScriptSource As String, ByRef lngScriptLine As Long) As Boolean
       
    Dim objTextFile         As New cTextFile
    Dim strInfo             As String
    Dim strLine             As String
    Dim objCat              As New cStringConcat
    Dim booErrorLineInfo    As Boolean
    
    booErrorLineInfo = AppOptions("CVBScript_ErrorLineInfo", True)
    
    lngScriptLine = 0
    strScriptSource = ""
    
    objCat.Init 65535
    
    If (objTextFile.ExistFile(strFileName)) Then
    
        If (objTextFile.OpenFile(strFileName)) Then
        
            Do While Not objTextFile.EOF()
                
                strLine = objTextFile.ReadLn()
                
                If CanAddCommand(strLine) And booErrorLineInfo Then
                
                    strInfo = Space(128) & " '" & SCRIPT_INFO_MARK & " Line='" & (lngScriptLine + 1) & "' File='" & strFileName & "'"
                    objCat.Concat strLine & strInfo & vbNewLine
                Else
                    objCat.Concat strLine & vbNewLine
                End If
                lngScriptLine = lngScriptLine + 1
            Loop
        End If
        objTextFile.CloseFile
        strScriptSource = objCat.GetString()
        UnLoadAScript = True
    Else
        Err.Raise vbObjectError + 7011, App.EXEName, PreProcess(VBSCRIPT_ERROR_07011, "FILE", strFileName)
    End If

End Function

Public Function AddMainCode() As Boolean
    ' Add the source code to the scripting engine
    On Error GoTo errmgr
    
    Dim strCodeFoDemo As String
    
    CodeLength = 0
    AddCode BootStrapScriptSource & vbNewLine & strCodeFoDemo & vbNewLine & ScriptSource
    AddMainCode = True
    Exit Function
errmgr:
    ShowError GetVBScriptErrorString()
End Function

Public Function AddCode(strCode As String) As Boolean

    On Error GoTo errmgr
    
    CodeLength = CodeLength + Len(strCode)
    VBSEngine.AddCode strCode
    AddCode = True
    Exit Function
errmgr:
    ShowError GetVBScriptErrorString()
End Function

Public Function GetVBScriptErrorString() As String

    GetVBScriptErrorString = PreProcess(VBSCRIPT_ERROR_07027, "ERROR", VBSEngine.Error.Number, "DESCRIPTION", VBSEngine.Error.Description, "LINE", (VBSEngine.Error.Line - m_lngBootStrapScriptSourceLineCount - 2), "VBSCRIPT", Replace(VBSEngine.Error.Text, SCRIPT_INFO_MARK, vbNewLine), "CRLF", vbNewLine)
End Function

Public Property Get DebugMode() As Boolean
    Dim r       As New CRegistry2
    Dim Value   As String
        
    Value = r.getVar(REGISTRY_DEBUGGING_VAR, , r.HKEY_CURRENT_USER, REGISTRY_DEBUGGING_FOLDER)
    DebugMode = IIf(IsNumeric(Value), CLng(Value), 0)
End Property

Public Property Let DebugMode(ByVal vNewValue As Boolean)
    Dim r As New CRegistry2
    
    r.SetVar REGISTRY_DEBUGGING_VAR, Abs(vNewValue), REG_DWORD, r.HKEY_CURRENT_USER, REGISTRY_DEBUGGING_FOLDER
End Property

Public Function CheckCodeSize() As Boolean

    Dim objModule, objProc
    
    On Error GoTo errmgr
    
    For Each objModule In VBSEngine.Modules
    
        Debug.Print "module:" & objModule.Name
        For Each objProc In objModule.Procedures
                
            Debug.Print " proc:" & objProc.Name
        Next
    Next
    CheckCodeSize = True
    Exit Function
errmgr:
    MsgBox GetVBErrorString()
End Function

Public Property Get SCRIPT_INFO_MARK() As String
    SCRIPT_INFO_MARK = "#SCRIPT.INFO{}"
End Property

Private Function CanAddCommand(ByVal strLine As String) As Boolean
    strLine = Trim(strLine)
    If Len(strLine) Then
        If Right(strLine, 1) <> "_" Then
            CanAddCommand = True
        End If
    End If
End Function

' This can only work if the lastest windows script hosting is installed
Public Function GetFileVersionInfo(ByVal strFileName As String) As String

    Dim fso As Object
    
    On Error GoTo errmgr
    
    Set fso = CreateObject("Scripting.FileSystemObject")
    GetFileVersionInfo = fso.GetFileVersion(strFileName)
    Exit Function
errmgr:
    Err.Clear
End Function

Public Function WindowsScriptHostVersion(Optional ByVal strFileName As String = "\system32\CScript.exe") As String

    Dim objWin As New cWindows
    On Error Resume Next
    WindowsScriptHostVersion = GetFileVersionInfo(objWin.GetWinDir() & strFileName)
End Function

Public Function VBScriptEngineVersion(Optional ByVal strFileName As String = "\system32\vbscript.dll") As String
    Dim objWin As New cWindows
    On Error Resume Next
    VBScriptEngineVersion = GetFileVersionInfo(objWin.GetWinDir() & strFileName)
End Function

Public Function VBScriptControlVersion(Optional ByVal strFileName As String = "\system32\MSscript.ocx") As String
    Dim objWin As New cWindows
    On Error Resume Next
    VBScriptControlVersion = GetFileVersionInfo(objWin.GetWinDir() & strFileName)
End Function

Public Function LoadAScript(ByVal strFileName As String, ByRef strScriptSource As String, ByRef lngScriptLine As Long, ByVal booCrypted As Boolean) As Boolean
       
    Dim objTextFile             As New cTextFile
    Dim strInfo                 As String
    Dim strLine                 As String
    Dim objCat                  As New cStringConcat
    Dim booErrorLineInfo        As Boolean
    Dim objParser               As New CByteSyntaxAnalyser
    Dim booTraceFunctionCall    As Boolean
    Dim strID                   As String
    Dim strFunctionName         As String
    Dim strFileNameOnly         As String
    Dim strFunctionCallTrace    As String
    Dim objStack                As New CVariantStack
    Dim objPoissonSuceur        As New CPoissonSuceur
    
    objStack.Initialize 256
    
    strFileNameOnly = UCase$(objTextFile.GetFileName(strFileName))
    booErrorLineInfo = AppOptions("CVBScript_ErrorLineInfo", False)
    booTraceFunctionCall = AppOptions("CVBScript_TraceFunctionCall", False)
    
    If LCase(objTextFile.GetFileName(strFileName)) = "W3Runner.vbs" Then
        booTraceFunctionCall = False
    End If
    
    lngScriptLine = 0
    strScriptSource = ""
    
    objCat.Init 65535
    
    If (objTextFile.ExistFile(strFileName)) Then
    
        If (objTextFile.OpenFile(strFileName)) Then
        
            Do While Not objTextFile.EOF()
                
                strLine = objTextFile.ReadLn()
                If booCrypted Then
                
                    objPoissonSuceur.DeCrypte strLine, strLine
                End If
                
                If CanAddCommand(strLine) Then
                
'                    If booTraceFunctionCall Then
'
'                        objParser.Init strLine
'                        If objParser.GetIdentifier(strID, True) = rSUCCEED Then
'
'                            If strID = "PUBLIC" Or strID = "PRIVATE" Then
'
'                                If objParser.GetIdentifier(strID, True) = rSUCCEED Then
'
'                                    If strID = "SUB" Or strID = "FUNCTION" Or strID = "PROPERTY" Then
'
'                                        objParser.GetIdentifier strFunctionName, False
'                                        objStack.Push strFunctionName
'                                        strFunctionCallTrace = PreProcess("DebugOutPutString [DC]Start[DC],[DC][TYPE][DC],[DC][FUNCTIONNAME][DC]", "DC", """", "FUNCTIONNAME", strFunctionName, "TYPE", LCase(strID))
'                                    End If
'                                End If
'                            End If
'
'                            If strID = "END" Or strID = "EXIT" Then
'
'                                If objParser.GetIdentifier(strID, True) = rSUCCEED Then
'
'                                    If strID = "SUB" Or strID = "FUNCTION" Or strID = "PROPERTY" Then
'
'                                        strFunctionName = objStack.Pop
'                                        strFunctionCallTrace = PreProcess("DebugOutPutString [DC]End[DC],[DC][TYPE][DC],[DC][FUNCTIONNAME][DC]", "DC", """", "FUNCTIONNAME", strFunctionName, "TYPE", LCase(strID))
'                                        objCat.Concat strFunctionCallTrace & vbNewLine
'                                        strFunctionCallTrace = ""
'                                    End If
'                                End If
'                            End If
'                        End If
'                    End If
                    
                    ' Add the line now
                    objCat.Concat strLine
                    
                    If booErrorLineInfo Then
                    
                        strInfo = Space(128) & " '" & SCRIPT_INFO_MARK & "Line=" & (lngScriptLine + 1) & "[CRLF]File=" & strFileName
                        objCat.Concat strInfo
                        If Len(strFunctionCallTrace) Then
                            objCat.Concat vbNewLine & strFunctionCallTrace
                            strFunctionCallTrace = ""
                        End If
                    End If
                    objCat.Concat vbNewLine
                Else
                    objCat.Concat strLine & vbNewLine
                End If
                lngScriptLine = lngScriptLine + 1
            Loop
        End If
        objTextFile.CloseFile
        strScriptSource = objCat.GetString()
        LoadAScript = True
    Else
    
        Err.Raise vbObjectError + 7011, App.EXEName, PreProcess(VBSCRIPT_ERROR_07011, "FILE", strFileName)
    End If
End Function

Public Property Get WebBrowserVersion() As String

    Dim r       As New CRegistry2
    
    Const REGISTRY_FOLDER = "Software\Microsoft\Internet Explorer"
    Const REGISTRY_VAR = "Version"

    If IsEmpty(m_varWebBrowserVersion) Then
    
        m_varWebBrowserVersion = r.getVar(REGISTRY_VAR, , r.HKEY_LOCAL_MACHINE, REGISTRY_FOLDER)
    End If
    WebBrowserVersion = CStr(m_varWebBrowserVersion)
End Property

Public Function WindowsVersion() As String
    Dim objWin As cWindows
    Set objWin = New cWindows
    WindowsVersion = objWin.GetVersion32()
End Function


Public Function CommentWaitForDownLoad(ByVal strFileName As String) As Boolean
       
    Dim objTextFile         As New cTextFile
    Dim strLine             As String
    Dim lngMaxLines         As Long
    Dim i                   As Long
    Dim objParser           As New CByteSyntaxAnalyser
    Dim lines()             As String
    Dim strTok              As String
    Dim strTOK2             As String
    Dim objCat              As New cStringConcat
    
    On Error GoTo errmgr
    
'    Debug.Assert 0
    
    objParser.booAccept2PointInId = True
    
    If (objTextFile.ExistFile(strFileName)) Then
    
        ' Load the file in an string array
        If (objTextFile.OpenFile(strFileName)) Then
        
            Do While Not objTextFile.EOF()
                
                lngMaxLines = lngMaxLines + 1
                ReDim Preserve lines(lngMaxLines)
                lines(lngMaxLines) = objTextFile.ReadLn()
            Loop
        End If
        objTextFile.CloseFile
        
        ' Process the Page.WaitForDownLoad Line
        For i = 1 To lngMaxLines
        
            objParser.Init lines(i)
            If objParser.GetIdentifier(strTok) = rSUCCEED Then
            
                If strTok = "PAGE.WAITFORDOWNLOAD" And i > 1 Then
                    
                    objParser.Init lines(i - 1)
                    If objParser.GetIdentifier(strTOK2) = rSUCCEED Then
                    
                        If strTOK2 = "PAGE.WAITFORDOWNLOAD" Then

                            lines(i - 1) = "' " & lines(i - 1) & " ' " & VBSCRIPT_MSG_07035
                        End If
                    End If
                End If
            End If
        Next
        
        objCat.Init 16384
        ' Write the file
        For i = 1 To lngMaxLines
            objCat.Concat lines(i) & vbNewLine
        Next
        objTextFile.LogFile strFileName, objCat.GetString(), True
        CommentWaitForDownLoad = True
    End If
    Exit Function
errmgr:
End Function


Public Function ExecuteEvent(strFunction As String, ParamArray Values() As Variant) As Boolean

    On Error GoTo errmgr
    
    If Len(strFunction) = 0 Then Exit Function
    
    If Not m_booRunning Then Exit Function
    
    Select Case UBound(Values())
    
        Case 0: ExecuteEvent = IsEmpty(VBSEngine.Run(strFunction, Values(0)))
        Case 1: ExecuteEvent = IsEmpty(VBSEngine.Run(strFunction, Values(0), Values(1)))
        Case 2: ExecuteEvent = IsEmpty(VBSEngine.Run(strFunction, Values(0), Values(1), Values(2)))
        Case 3: ExecuteEvent = IsEmpty(VBSEngine.Run(strFunction, Values(0), Values(1), Values(2), Values(3)))
    End Select
    Exit Function
errmgr:
    ' Cannot call fshowerror because it trace the string
    #If W3RUNNER_DEFINE Then
        g_objW3RunnerObject.MsgBox PreProcess(VBSCRIPT_ERROR_07033, "EVENT", strFunction, "VBSCRIPT_ERROR", GetVBScriptErrorString(), "CRLF", vbNewLine), , False
    #Else
        MsgBox PreProcess(VBSCRIPT_ERROR_07033, "EVENT", strFunction, "VBSCRIPT_ERROR", GetVBScriptErrorString(), "CRLF", vbNewLine), vbCritical
    #End If
    
End Function

Private Function ShowError(strErrorMessage As String)
    #If W3RUNNER_DEFINE Then
        FShowError strErrorMessage, Me
    #Else
        MsgBox strErrorMessage, vbCritical + vbOKOnly
    #End If
End Function

Public Function IsFileNameCrypted(strFileName As String) As Boolean
    IsFileNameCrypted = InStr(strFileName, "." & W3RUNNER_CRYPTED_SCRIPT_EXTENSION)
End Function

