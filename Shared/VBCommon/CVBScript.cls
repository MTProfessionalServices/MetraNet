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
Option Explicit

Public VBSEngine                    As Object
Public ScriptSource                 As String
Public BootStrapScriptSource        As String

Private m_lngBootStrapScriptSourceLineCount As Long

Private m_strFileName               As String
Private m_strBootStrapFileName      As String

Private Const REGISTRY_DEBUGGING_FOLDER = "Software\Microsoft\Windows Script\Settings"
Private Const REGISTRY_DEBUGGING_VAR = "JITDebug"

Public CodeLength As Long


Public Function Execute(ByVal strFunctionName As String, ByRef strErrorMessage As String, Optional lngTimeOut As Long = 20) As Boolean

    On Error GoTo ErrMgr
    
    Dim strLineErrorCode    As String
    Dim booIsErrorInInclude As Boolean
       
    VBSEngine.Timeout = lngTimeOut * 1000

    Execute = VBSEngine.Run(strFunctionName)
    Exit Function
ErrMgr:

    If (VBSEngine.Error.Number) Then ' VBScriptinh Control Error
    
        strErrorMessage = GetVBScriptErrorString()
    Else ' Regular Run Time Error
    
        strErrorMessage = Err.Number & " " & Err.Description
    End If
End Function

Private Function RaiseError(ByVal strMessage As String, Optional lngErrorCode As Long = 1) As Boolean
    Err.Raise vbObjectError + lngErrorCode, "CVBScript.cls", strMessage
End Function


Private Function GetLibraryCode(ByVal strFileName As String) As String

    On Error GoTo ErrMgr

    Dim objTextFile     As New MTVBLib.cTextFile
    Dim objCat          As New MTVBLib.cStringConcat
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
ErrMgr:
    RaiseError Err.Description, Err.Number
End Function



Private Function GetScriptBackUpFileName() As String
    GetScriptBackUpFileName = Environ("TEMP") & "\CVBScript.BackUp.vbs"
End Function


Private Function GetScriptLine(lngLine As Long) As String
    
    Dim objTextFile     As New MTVBLib.cTextFile
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

    Dim objTextFile As New MTVBLib.cTextFile
    m_strFileName = vNewValue
    
    ' Load the script + include
    If (Not LoadAScript(FileName, ScriptSource, 0)) Then RaiseError "Cannot load " & FileName
        
End Property

Private Sub CreateScriptControl()
    Set VBSEngine = CreateObject("MSScriptControl.ScriptControl")
    VBSEngine.language = "VBScript"
End Sub

Private Sub Class_Initialize()
    CreateScriptControl
End Sub

Private Sub Class_Terminate()
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
    
    On Error GoTo ErrMgr
    
    If (booClear) Then Set colPublicMethod = New Collection
    
    For Each objProc In VBSEngine.Modules("Global").Procedures
    
        colPublicMethod.Add objProc.Name
    Next
    LoadPublicMethods = True
    Exit Function
ErrMgr:
    MsgBox GetVBErrorString()
End Function

Public Property Get BootStrapFileName() As String
    m_strBootStrapFileName = BootStrapFileName
End Property

Public Property Let BootStrapFileName(ByVal vNewValue As String)

    Dim objTextFile As New cTextFile
    
    m_strBootStrapFileName = vNewValue
    LoadAScript m_strBootStrapFileName, BootStrapScriptSource, m_lngBootStrapScriptSourceLineCount
End Property


Private Function LoadAScript(ByVal strFileName As String, ByRef strScriptSource As String, ByRef lngScriptLine As Long) As Boolean
       
    Dim objTextFile     As New MTVBLib.cTextFile
    
    lngScriptLine = 0
    strScriptSource = ""
        
    If (objTextFile.ExistFile(strFileName)) Then
    
        If (objTextFile.OpenFile(strFileName)) Then
        
            Do While Not objTextFile.EOF()
            
                strScriptSource = strScriptSource & objTextFile.ReadLn() & vbNewLine
                lngScriptLine = lngScriptLine + 1
            Loop
        End If
        objTextFile.CloseFile
        LoadAScript = True
    End If

End Function

Public Function AddMainCode() As Boolean
    ' Add the source code to the scripting engine
    On Error GoTo ErrMgr
    
    Dim strCodeFoDemo As String
    
    #If DEMO Then
        strCodeFoDemo = PreProcess("Private Function ExecuteGlobal(strCode)[CRLF]End Function", "CRLF", vbNewLine)
    #End If
    
    CodeLength = 0
    AddCode BootStrapScriptSource & vbNewLine & strCodeFoDemo & vbNewLine & ScriptSource
    AddMainCode = True
    Exit Function
ErrMgr:
    ShowError GetVBScriptErrorString()
End Function

Public Function AddCode(strCode As String) As Boolean

    On Error GoTo ErrMgr
    
    #If DEMO Then
        If CodeLength + Len(strCode) > MAX_CODE_LENGTH_FOR_DEMO Then
            ShowError PreProcess(FREDRUNNER_ERROR_07012, "K", MAX_CODE_LENGTH_FOR_DEMO)
            Exit Function
        End If
    #End If
    
    CodeLength = CodeLength + Len(strCode)
    VBSEngine.AddCode strCode
    AddCode = True
    Exit Function
ErrMgr:
    ShowError GetVBScriptErrorString()
End Function

Public Function GetVBScriptErrorString() As String
    GetVBScriptErrorString = VBSEngine.Error.Number & " " & VBSEngine.Error.Description & ". Line=" & (VBSEngine.Error.Line - m_lngBootStrapScriptSourceLineCount) & vbNewLine & "" & VBSEngine.Error.Text
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
    
    On Error GoTo ErrMgr
    
    For Each objModule In VBSEngine.Modules
    
        Debug.Print "module:" & objModule.Name
        For Each objProc In objModule.Procedures
                
            Debug.Print " proc:" & objProc.Name
        Next
    Next
    CheckCodeSize = True
    Exit Function
ErrMgr:
    MsgBox GetVBErrorString()
End Function
