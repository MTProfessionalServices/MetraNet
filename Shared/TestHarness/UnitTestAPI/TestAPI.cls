VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "TestAPI"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
' ****************************************************************************************************************************************************
' Copyright 1998, 2000 by MetraTech Corporation
' All rights reserved.
'
' THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
' NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
' example, but not limitation, MetraTech Corporation MAKES NO
' REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
' PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
' DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
' COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
'
' Title to copyright in this software and any associated
' documentation shall at all times remain with MetraTech Corporation,
' and USER agrees to preserve the same.
'
' $Workfile: TestAPI.cls$
' $Date: 9/11/2002 8:43:24 AM$
' $Author: Alon Becker$
' $Revision: 21$
'
' * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
'
' CLASS         :   TestAPI.cls
' DESCRIPTION   :   Functions that a test script/app can use to write log and result files to be used
'                   by the test harness
' VERSION       :   1.0.
' AUTHOR        :   F.Torres, A. R.
'
' ****************************************************************************************************************************************************

Option Explicit


Const LOG_END_RESULT_FILE_RESULT2 = "} [MODE_STRING]:[TEST_NAME] ( Result:'[RESULT]', StartTime:'[STARTTIME]', EndTime:'[ENDTIME]', Computer:'[COMPUTER]', UserName:'[USERNAME]', Description:'[RESULT_DESCRIPTION]' )"
Const LOG_FUNCTION_RESULT_FILE_RESULT2 = ":=[MODE_STRING]:[TEST_NAME] ( Result:'[RESULT]', StartTime:'[STARTTIME]', EndTime:'[ENDTIME]', Computer:'[COMPUTER]', UserName:'[USERNAME]', Description:'[RESULT_DESCRIPTION]' )"
Const LOG_START_RESULT_FILE_RESULT2 = "{ [MODE_STRING]:[TEST_NAME] ( [PARAMETERS] )"

Public TextFile         As New cTextFile        ' Returns an instance of the object MTVBLib.CTextFile
Public PreProcessor     As New CPreProcessor    ' Returns an instance of the object MTVBLib.CPreProcessor
Public WinApi           As New cWindows         ' Returns an instance of the object MTVBLib.CWindows

Private Function FindEnvValue(EnvVar As String) As String
    Dim Length As Long
    Dim EnvString As String
    
    Length = Len(EnvVar)
    If (Length > 0) Then
      EnvString = Environ(EnvVar)
      FindEnvValue = EnvString
    Else
      FindEnvValue = ""
    End If
End Function

'Get the logfile name for test scripts
Private Function GetLogFileName() As String
    Dim EnvValue As String
    
    EnvValue = FindEnvValue("METRATECHTESTDATABASE")
    If (EnvValue = "") Then
      GetLogFileName = Environ("TEMP") & "\" & "test.log"
    Else
      GetLogFileName = EnvValue & "\" & "test.log"
    End If
End Function


'Get the filepath for the result.csv file used by the test harness
Private Function GetResultFileName() As String

    Dim EnvValue As String
    
    EnvValue = FindEnvValue("METRATECHTESTDATABASE")
    
    If (EnvValue = "") Then
      GetResultFileName = Environ("TEMP") & "\" & "Result.csv"
    Else
      GetResultFileName = EnvValue & "\" & "Result.csv"
    End If
End Function

Private Function GetResult2FileName() As String

    Dim EnvValue As String
    
    EnvValue = FindEnvValue("METRATECHTESTDATABASE")
    
    If (EnvValue = "") Then
      GetResult2FileName = Environ("TEMP") & "\" & "Result2.csv"
    Else
      GetResult2FileName = EnvValue & "\" & "Result2.csv"
    End If
End Function


' ------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : LogFile
' PARAMETERS    :
'                 strFileName - Complete Path and file name for the log file used by the script.
'                 strMessage - A string that has to be logged.
'                 booCreateFile - An optional boolean variable, if true then the log file will be
'                 created.  If it already exists, it will be deleted and then recreated.
' DESCRIPTION   : Write a message to a log file.
' RETURN        : True if Ok
Public Function LogFile(ByVal strFileName As String, ByVal strMessage As String, Optional ByVal booCreateFile As Boolean = False) As Boolean
    LogFile = TextFile.LogFile(strFileName, strMessage, booCreateFile)
End Function

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : TRACE
' PARAMETERS    :
'                 strMessage - A string that has to be logged.
'                 booCreateFile - An optional boolean variable, if true then the log file will be
'                 created.  If it already exists, it will be deleted and then recreated.
' DESCRIPTION   : Write a message to the log file $(METRATECHTESTDATABASE)\test.log
'                 If $(METRATECHTESTDATABASE) does not exist, write to $(TEMP)\test.log
' RETURN        : True if Ok
Public Function TRACE(ByVal strMessage As String, Optional ByVal booCreateFile As Boolean = False) As Boolean

    TRACE = TextFile.LogFile(GetLogFileName(), strMessage, booCreateFile)
    TraceStrings.Add strMessage
    LogInResult2 IndentThis("[INFO]" & strMessage)
End Function

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Sleep
' PARAMETERS    :
'                 lngTime - time in milliseconds.
' DESCRIPTION   : Sleep for specified time
' RETURN        : True if Ok
Public Function Sleep(ByVal lngMilliSecond As Long) As Boolean
    cWindowsModule.Sleep lngMilliSecond
    Sleep = True
End Function

Private Function GetModeString(mode As LOG_RESULT_MODE) As String

    If mode And LOG_RESULT_MODE_SESSION Then
    
        GetModeString = "Session"
        
    ElseIf mode And LOG_RESULT_MODE_COMPAREDEF Then
    
        GetModeString = "CompareDef"
        
    ElseIf mode And LOG_RESULT_MODE_TEST Then
    
        GetModeString = "Test"
        
    ElseIf mode And LOG_RESULT_MODE_SUPER_SESSION Then
    
        GetModeString = "SuperSession"
        
    ElseIf mode And LOG_RESULT_MODE_CHECKPOINT Then
        
        GetModeString = "CheckPoint"
    Else
    
    End If
    
End Function


' ------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : LogResult
' PARAMETERS    :
'                 strTestName - Name of the test, as a string.
'                 booResult - Test result, as a boolean.  True, if test has succeeded.
'                 strStartTime - Time the test was started, as a string.
'                 strEndTime - Time the test was finished, as a string.
'                 strResultDescription - An optional string describing the test result.
' DESCRIPTION   : Append a string describing the test result in a specific format to
'                 $(METRATECHTESTDATABASE)\result.csv file.
'                 If $(METRATECHTESTDATABASE) does not exist, write to $(TEMP)\result.csv file.
' RETURN        : The string that was appened.
Public Function LogResult( _
            ByVal strTestName As String, _
            ByVal booResult As Boolean, _
            ByVal strStartTime As String, _
            ByVal strEndTime As String, _
            Optional ByVal strResultDescription As String, _
            Optional ByVal lngMode As Long = -1, _
            Optional ByVal strParameters As String, _
            Optional ByVal strTestPath As String) As String




    Dim strMessage      As String
    Dim objPreProcessor As New CPreProcessor
    Dim mode            As LOG_RESULT_MODE
    
    If lngMode = -1 Then
        mode = LOG_RESULT_MODE_END + LOG_RESULT_MODE_TEST  ' Default mode to keep compatiblity with the past...
    Else
        mode = lngMode
    End If
    
    ' -- Remove all CRLF, CR and LF
    strResultDescription = Replace(strResultDescription, vbNewLine, "<br/>")
    strResultDescription = Replace(strResultDescription, vbCr, "<br/>")
    strResultDescription = Replace(strResultDescription, vbLf, "<br/>")

    objPreProcessor.Add "TEST_NAME", strTestName
    objPreProcessor.Add "RESULT", IIf(booResult, "[SUCCEED]", "[FAILED]")
    objPreProcessor.Add "RESULT_DESCRIPTION", strResultDescription
    objPreProcessor.Add "USERNAME", Replace(WinApi.UserName, Chr(0), Chr(32))
    objPreProcessor.Add "COMPUTER", Replace(WinApi.ComputerName, Chr(0), Chr(32))
    objPreProcessor.Add "STARTTIME", strStartTime
    objPreProcessor.Add "ENDTIME", strEndTime
    objPreProcessor.Add "MODE_STRING", GetModeString(mode)
    objPreProcessor.Add "MODE", Format(mode, "00")
    objPreProcessor.Add "PARAMETERS", strParameters
    objPreProcessor.Add "TEST_PATH", strTestPath
    
        
    If mode And LOG_RESULT_MODE_START Then ' LOG START RESULT
        
        If mode And LOG_RESULT_MODE_TEST Then
            
            strMessage = IndentThis(objPreProcessor.Process(LOG_START_RESULT_FILE_RESULT2))
            
        ElseIf mode And LOG_RESULT_MODE_SESSION Then
        
            strMessage = IndentThis(objPreProcessor.Process(LOG_START_RESULT_FILE_RESULT2))
            
        ElseIf mode And LOG_RESULT_MODE_SUPER_SESSION Then
        
            strMessage = IndentThis(objPreProcessor.Process(LOG_START_RESULT_FILE_RESULT2))
            IndentLevel = 0 ' Reset the counter - some time there are some bugs...
            
        Else
        
            strMessage = IndentThis(objPreProcessor.Process("Invalid value parameter Mode, function LogResult, Object TestAPI"))
        End If
        LogInResult2 strMessage
        LogResult = strMessage

        IndentLevel = IndentLevel + 1
        
    Else ' LOG END RESULT
    
        IndentLevel = IndentLevel - 1
        
        If mode And LOG_RESULT_MODE_TEST Then
            
            strMessage = IndentThis(objPreProcessor.Process(LOG_END_RESULT_FILE_RESULT2))
            
        ElseIf mode And LOG_RESULT_MODE_SESSION Then
        
            strMessage = IndentThis(objPreProcessor.Process(LOG_END_RESULT_FILE_RESULT2))
            
        ElseIf mode And LOG_RESULT_MODE_SUPER_SESSION Then
        
            strMessage = IndentThis(objPreProcessor.Process(LOG_END_RESULT_FILE_RESULT2))
            
        ElseIf mode And LOG_RESULT_MODE_CHECKPOINT Then ' Same as a test but no indentation, no start , no end
            
            IndentLevel = IndentLevel + 1
            strMessage = IndentThis(objPreProcessor.Process(LOG_FUNCTION_RESULT_FILE_RESULT2))
            
        ElseIf mode And LOG_RESULT_MODE_COMPAREDEF Then ' Same as a test but no indentation, no start , no end

            IndentLevel = IndentLevel + 1
            strMessage = IndentThis(objPreProcessor.Process(LOG_FUNCTION_RESULT_FILE_RESULT2))
                                
        Else
            strMessage = IndentThis(objPreProcessor.Process("Invalid value parameter Mode, function LogResult, Object TestAPI"))
        End If
        LogInResult2 strMessage

        ' ----------------------------------------------------------------------------------------------------------------------------------------------------------------
        ' -- This is the old code before 4.0 this does not change --------------------------------------------------------------------------------------------------------
        ' ----------------------------------------------------------------------------------------------------------------------------------------------------------------
        
        strMessage = objPreProcessor.Process(TemplateResultString)
        TextFile.LogFile GetResultFileName(), strMessage
        LogResult = strMessage
        
    End If
    
End Function

Private Function IndentThis(ByVal s As String) As String

    If IndentLevel < 0 Then
        IndentLevel = 0
    End If
    IndentThis = Space(IndentLevel * 5) + s
End Function

Public Function SkipResult(ByVal strTestName As String, ByVal strStartTime As String, ByVal strEndTime As String, Optional ByVal strResultDescription As String) As String

    Dim strMessage      As String
    Dim objPreProcessor As New CPreProcessor
    
    objPreProcessor.Add "TEST_NAME", strTestName
    objPreProcessor.Add "RESULT", "[SKIPPED]"
    objPreProcessor.Add "RESULT_DESCRIPTION", strResultDescription
    objPreProcessor.Add "USERNAME", Replace(WinApi.UserName, Chr(0), Chr(32))
    objPreProcessor.Add "COMPUTER", Replace(WinApi.ComputerName, Chr(0), Chr(32))
    objPreProcessor.Add "STARTTIME", strStartTime
    objPreProcessor.Add "ENDTIME", strEndTime
    
    strMessage = objPreProcessor.Process(TemplateResultString)
    
    TextFile.LogFile GetResultFileName(), strMessage
    SkipResult = strMessage
End Function

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Property Get TemplateResultString
' PARAMETERS    :
'
' DESCRIPTION   : Returns the format of the string that is logged to the result.csv file.
'                 This file is used by the test harness.
' RETURN        : A string, specifying the format.
Public Property Get TemplateResultString() As String

    TemplateResultString = """[TEST_NAME]"",""[RESULT]"",""[RESULT_DESCRIPTION]"",""[USERNAME]"",""[COMPUTER]"",""[STARTTIME]"",""[ENDTIME]"",""[TEST_PATH]"""
End Property

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Property Get GetLogResultFileName
' PARAMETERS    :
'
' DESCRIPTION   : Returns the complete path of the result file (result.csv) that is being used.
' RETURN        : A string, specifying the complete path of the result.csv file
Public Property Get GetLogResultFileName() As String
    GetLogResultFileName = GetResultFileName()
End Property

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Property Get GetTestLogFileName
' PARAMETERS    :
'
' DESCRIPTION   : Returns the complete path of the log file (test.log) that is being used.
' RETURN        : A string, specifying the complete path of the test.log file
Public Property Get GetTestLogFileName() As String
    GetTestLogFileName = GetLogFileName()
End Property

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Property Get GetFormattedTime
' PARAMETERS    :
'
' DESCRIPTION   : Returns the expected format for starttime and endtime.
'
' RETURN        : A string, specifying the time format.
Private Function GetFormatedTime() As String
    GetFormatedTime = Format(Now(), "yyyy/mm/dd hh:mm:ss")
End Function

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : ExecSync
' PARAMETERS    :
'                JobToDo - The name of the job as String
'                ExecMode - The execution mode, optional, as VBAppWinStyle.
'                Default is vbNormalFocus
' DESCRIPTION   :Shells a new process and waits for it to complete.
'                Calling application is totally non-responsive while
'                new process executes.
' RETURN        : True if Ok
Public Function ExecSync(ByVal JobToDo As String, Optional ExecMode As VbAppWinStyle = vbNormalFocus) As Boolean

    Dim oShl As Object ' IWshRuntimeLibrary.IWshShell_Class
    Set oShl = GetWshShellObject()
    If Not IsValidObject(oShl) Then Exit Function
    
    On Error Resume Next
    oShl.Run JobToDo, ExecMode, True
    If (Err.Number) Then
    
        ShowError PreProcess(MTTESTAPI_ERROR_1001 & GetVBErrorString(), "PRG", JobToDo), "TestApi.Cls", "ExecSync"
        Err.Clear
        Exit Function
    End If
    

''   Dim ProcessID            As Long
''   Dim lngProcessStatus     As Long
''   Dim hProcess             As Long
''   Dim t As New cTool
''
''    t.execPrgSyncrone JobToDo, , vbNormalFocus
      
'   ProcessID = Shell(JobToDo, CLng(ExecMode))
'   Do
'
'        hProcess = OpenProcess(CLng(PROCESS_QUERY_INFORMATION), False, ProcessID)
'        If (hProcess) Then
'            CloseHandle (hProcess)
'        Else
'            Exit Do
'        End If
'        Sleep 100
'        DoEvents
'   Loop
   ExecSync = True
End Function

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : DeleteResultFile
' PARAMETERS    :
' DESCRIPTION   : Delete the result file name. The result file name is the file that contains the test result information.
' RETURN        :
Public Function DeleteResultFile() As Boolean
    Dim objTextFile As New cTextFile
    DeleteResultFile = objTextFile.DeleteFile(GetLogResultFileName)
End Function

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : TestHarnessMode
' PARAMETERS    :
' DESCRIPTION   : The TestHarness set this property to TRUE to tell the test client that they are running from the test harness.
'                 A Test Client cannot set this property but only get it.
' RETURN        :
Public Property Get TestHarnessMode() As Boolean
    TestHarnessMode = UnitTestAPIModule.static_TestHarnessMode
End Property

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : TestHarnessMode
' PARAMETERS    :
' DESCRIPTION   : Set property Get.
' RETURN        :
Public Property Let TestHarnessMode(ByVal vNewValue As Boolean)
    UnitTestAPIModule.static_TestHarnessMode = vNewValue
End Property



' ------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : TraceStrings
' PARAMETERS    :
' DESCRIPTION   :   Returns the static collection of strings reference. This function is public but must not be documented
' RETURN        :
Public Property Get TraceStrings() As Collection ' documented=no
    Set TraceStrings = UnitTestAPIModule.static_TraceStrings
End Property

Private Sub Class_Initialize()
'Do not use comlogger to log errors.

    Dim objMTVBLibInfo As MTVbLibInfo
    
    On Error Resume Next
    Set objMTVBLibInfo = New MTVbLibInfo
    If Err.Number Then
        MsgBox MTTESTAPI_ERROR_1002
    End If
    objMTVBLibInfo.LogWithoutCOMLogger = True
End Sub

Public Function TypeName(ByRef v As Variant) As String
    TypeName = VBA.TypeName(v)
End Function

Public Property Get TestSessionParameters() As CVariables
    Set TestSessionParameters = static_TestSessionParameters
End Property

Public Property Get Clipboard() As Object
    Set Clipboard = VB.Clipboard
End Property

Public Property Get Environ(ByVal strName As String, Optional ByVal strGroup As String) As String

    Dim w As Object ' IWshRuntimeLibrary.IWshShell_Class
    Dim E As Object ' IWshEnvironment
    
    Set w = GetWshShellObject()
    If Not IsValidObject(w) Then Exit Property
               
    If (Len(strGroup) = 0) Then
    
        Set E = w.Environment("USER")
    Else
        Set E = w.Environment(strGroup)
    End If
    Environ = E.Item(strName)
End Property

Public Property Let Environ(ByVal strName As String, Optional ByVal strGroup As String, ByVal vNewValue As String)

    Dim w As Object ' IWshRuntimeLibrary.IWshShell_Class
    Dim E As Object ' IWshEnvironment
    
    Set w = GetWshShellObject()
    If Not IsValidObject(w) Then Exit Property
    
    If (Len(strGroup) = 0) Then strGroup = "USER"
    
    Set E = w.Environment(strGroup)
    E.Item(strName) = vNewValue

'    Dim WshShell, WshSysEnv
 '   Set WshShell = CreateObject("WScript.Shell")
  '  Set WshSysEnv = WshShell.Environment("SYSTEM")
   ' 'WScript.Echo WshSysEnv("NUMBER_OF_PROCESSORS")
End Property

Private Function GetWshShellObject() As Object ' IWshRuntimeLibrary.IWshShell_Class

    'Dim oShl As IWshRuntimeLibrary.IWshShell_Class
    
    On Error Resume Next
    Set GetWshShellObject = CreateObject("WScript.Shell")
    'Set GetWshShellObject = New IWshRuntimeLibrary.IWshShell_Class
    If (Err.Number) Then
    
        ShowError MTTESTAPI_ERROR_1000 & GetVBErrorString(), "TestApi.Cls", "GetWshShellObject"
        Err.Clear
        Exit Function
    End If
End Function

Public Function GetNewVBCollection() As Collection
    Set GetNewVBCollection = New Collection
End Function

Public Function GetValidSessionID(Optional ByVal strServiceName As String = "metratech.com/testservice") As String

'    Dim m_objINSession  As COMMeterLib.Session
'    Dim m_objMeter      As COMMeterLib.Meter
'
''    Debug.Assert 0
'    Set m_objMeter = New Meter
'    m_objMeter.Startup
'
'    ' Create the session object
'    Set m_objINSession = m_objMeter.CreateSession(strServiceName)
'    GetValidSessionID = m_objINSession.SessionID & "=="
'
'    Set m_objINSession = Nothing
'    Set m_objMeter = Nothing
End Function

Public Function WaitForPipeLineToProcessTransaction(ByVal strUID As String, Optional ByVal lngSessionCount As Long = 1, Optional WScript As Object, Optional ByVal lngSecondTimeOut As Long = 10, Optional ByVal lngSleepTime As Long = 700) As Boolean
     
'    Dim objMeterRowset  As METERROWSETLib.MeterRowset
'    Dim lngTime         As Long
'
'    Set objMeterRowset = New METERROWSETLib.MeterRowset
'    objMeterRowset.BatchID = strUID
'
'    If IsValidObject(WScript) Then WScript.Echo "Wait for session UID=" & strUID & " to be processed by the pipeline."
'
'    lngTime = GetTickCount()
'
'    Do While True
'
'        If IsValidObject(WScript) Then WScript.Echo "."
'        Sleep lngSleepTime
'        DoEvents
'
'        If objMeterRowset.CommittedCount() = lngSessionCount Then
'
'            WaitForPipeLineToProcessTransaction = True
'            Exit Function
'        End If
'
'        If GetTickCount() > lngTime + (lngSecondTimeOut * 1000) Then
'
'            If IsValidObject(WScript) Then WScript.Echo "Session UID=" & strUID & " Times Out."
'            WaitForPipeLineToProcessTransaction = False
'            Exit Function
'        End If
'    Loop
'
End Function



Public Property Get IndentLevel() As Long
        IndentLevel = static_IndentLevel
End Property

Public Property Let IndentLevel(ByVal vNewValue As Long)
    static_IndentLevel = vNewValue
End Property

Private Function LogInResult2(strMessage As String) As Boolean

    LogInResult2 = TextFile.LogFile(GetResult2FileName(), Now() & " " & Replace(strMessage, vbNewLine, ""))
End Function

Public Function Version() As Double

    Version = CDbl(App.Major & "." & App.Minor)
End Function

Public Function Revision() As Double

    Revision = CDbl(App.Revision)
End Function





' ------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : CurrentTest
' PARAMETERS    :
' DESCRIPTION   : The TestHarness set this property to TRUE to tell the test client that they are running from the test harness.
'                 A Test Client cannot set this property but only get it.
' RETURN        :
Public Property Get CurrentTest() As String
    CurrentTest = UnitTestAPIModule.static_CurrentTest
End Property

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : CurrentTest
' PARAMETERS    :
' DESCRIPTION   : Set property Get.
' RETURN        :
Public Property Let CurrentTest(ByVal vNewValue As String)
    UnitTestAPIModule.static_CurrentTest = vNewValue
End Property
