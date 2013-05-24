' ---------------------------------------------------------------------------------------------------------------------------
'
' Copyright 2002 by W3Runner.com.
' All rights reserved.
'
' THIS SOFTWARE IS PROVIDED "AS IS", AND W3Runner.com. MAKES
' NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
' example, but not limitation, W3Runner.com. Corporation MAKES NO
' REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
' PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
' DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
' COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
'
' Title to copyright in this software and any associated
' documentation shall at all times remain with W3Runner.com.,
' and USER agrees to preserve the same.
'
' ----------------------------------------------------------------------------------------------------------------------------
'
' W3Runner VBScript Library
'
' MODULE : W3Runner.vbs
' CREATION_DATE : July 5 2002
' DESCRIPTION : W3Runner's Global constants, functions and classes. This file is automatically included with
'    the current script. Do not change this file. Every functions in this module must be private.
'
' -----------------------------------------------------------------------------------------------------------------------------

OPTION EXPLICIT

PUBLIC CONST W3RUNNER_LIBRARY_VERSION = "2.0"

'
' W3Runner COM Objects
'
PUBLIC CONST CVBScriptExtensions = "W3RunnerLib.CVBScriptExtensions"
PUBLIC CONST CTextFile           = "W3RunnerLib.CTextFile"
PUBLIC CONST CIniFile            = "W3RunnerLib.CIniFile"
PUBLIC CONST CVariables          = "W3RunnerLib.CVariables"
PUBLIC CONST CWindows            = "W3RunnerLib.CWindows"
'
' Enum Type eW3RunnerTraceMode, to be use with the following method of the object UI :
' Public Function TRACE(ByVal strMessage As String, Optional ByVal eMode As eW3RunnerTraceMode = eW3RunnerTrace_INFO) As Boolean
'
PUBLIC CONST w3rINFO   = 1
PUBLIC CONST w3rERROR  = 2
PUBLIC CONST w3rWARNING  = 4
PUBLIC CONST w3rSQL  = 8
PUBLIC CONST w3rURL_DOWNLOADED = 16
PUBLIC CONST w3rMEMORY  = 32
PUBLIC CONST w3rDEBUG  = 64
PUBLIC CONST w3rINTERNAL  = 128
PUBLIC CONST w3rMETHOD  = 256
PUBLIC CONST w3rJAVASCRIPT = 512
PUBLIC CONST w3rSUCCESS  = 1024
PUBLIC CONST w3rCLEAR_TRACE = 2048 ' Logging a message in this mode will clear the TRACES ListView
PUBLIC CONST w3rPERFORMANCE = 4096
PUBLIC CONST w3rWEBSERVICE = 8192
PUBLIC CONST w3rTRACEHTTP = 16384

' Public Enum w3rITEM_CLICK_FLAG
PUBLIC CONST w3rITEM_CLICK_FLAG_ABSOLUTE   = 1
PUBLIC CONST w3rITEM_CLICK_FLAG_RIGHT_CLICK  = 2
PUBLIC CONST w3rITEM_CLICK_FLAG_LEFT_CLICK  = 4
PUBLIC CONST w3rITEM_CLICK_FLAG_CURRENT_POSITION  = 8
PUBLIC CONST w3rITEM_CLICK_FLAG_WM_MOUSE_DOWN  = 16
PUBLIC CONST w3rITEM_CLICK_FLAG_WM_MOUSE_UP  = 32

' Public Enum eW3RunnerEnvironmentInfo, to be use with the following method of the object UI :
' Public Property Get Environ(Optional ByVal varKey As Variant) As String
PUBLIC CONST w3rW3RUNNER_VERSION  = 0
PUBLIC CONST w3rWEB_BROWSER_VERSION  = 1
PUBLIC CONST w3rWINDOWS_SCRIPT_HOST_VERSION = 2
PUBLIC CONST w3rVBSCRIPT_ENGINE_VERSION  = 3
PUBLIC CONST w3rVBSCRIPT_DEBUG_MODE  = 4
PUBLIC CONST w3rWINDOWS_VERSION   = 5
PUBLIC CONST w3rCOMPUTER_NAME   = 6
PUBLIC CONST w3rUSER_NAME   = 7
PUBLIC CONST w3rW3RUNNER_PATH   = 8
PUBLIC CONST w3rW3RUNNER_RESERVED_1   = 9
PUBLIC CONST w3rW3RUNNER_PROGRAM = 10

' Public Enum w3QUIT_MODE
PUBLIC CONST w3rQUIT_MODE_NORMAL = 1
PUBLIC CONST w3rQUIT_MODE_START_SAME_SCRIPT = 2

' Public Enum w3WAIT_MODE
PUBLIC CONST w3rWAIT_MODE_DEFAULT = 1
PUBLIC CONST w3rWAIT_MODE_NO_SLEEP_API_CALL = 2
PUBLIC CONST w3rWAIT_MODE_NO_DOEVENTS_CALL = 4

' Public CTEXTFILE_OPEN_MODE
PUBLIC CONST CTEXTFILE_OPEN_MODE_OPEN_MODE_READ = 1
PUBLIC CONST CTEXTFILE_OPEN_MODE_OPEN_MODE_WRITE = 2
PUBLIC CONST CTEXTFILE_OPEN_MODE_OPEN_MODE_APPEND = 4
PUBLIC CONST CTEXTFILE_OPEN_MODE_OPEN_MODE_EXCUSIVE = 8
PUBLIC CONST CTEXTFILE_OPEN_MODE_OPEN_MODE_READWRITE = 16

' Public Enum CHTTP_ERROR
PUBLIC CONST CHTTP_ERROR_OK     = 1
PUBLIC CONST CHTTP_ERROR_TIME_OUT   = 2
PUBLIC CONST CHTTP_ERROR_MSXML2_XMLHTTP_NOT_FOUND = 4
PUBLIC CONST CHTTP_ERROR_WRITING_OUTPUT_FILE  = 8
PUBLIC CONST CHTTP_ERROR_UNEXPECTED_RUN_TIME_ERROR = 16
PUBLIC CONST CHTTP_ERROR_HTTP_ERROR    = 32
PUBLIC CONST CHTTP_ERROR_OBJECT_NOT_INITIALIZED  = 64
PUBLIC CONST CHTTP_ERROR_CANNOT_OVERWRITE_FILE  = 128

' Just for compatibility with Visual Basic
PUBLIC CONST vbChecked  = 1
PUBLIC CONST vbUnChecked = 0

' Visual Basic enum type VbAppWinStyle
PUBLIC CONST vbHide   = 0
PUBLIC CONST vbNormalFocus = 1
PUBLIC CONST vbMinimizedFocus = 2
PUBLIC CONST vbMaximizedFocus = 3
PUBLIC CONST vbMinimizedNoFocus = 6
PUBLIC CONST vbNormalNoFocus = 4

' Visual Basic Enum Type VBStrConv - The Object HTTP export the Visual Basic function StrConv
PUBLIC CONST vbFromUnicode = 128 ' (&H80)
PUBLIC CONST vbHiragana = 32 ' (&H20)
PUBLIC CONST vbKatakana = 16 ' (&H10)
PUBLIC CONST vbLowerCase = 2
PUBLIC CONST vbNarrow = 8
PUBLIC CONST vbProperCase = 3
PUBLIC CONST vbUnicode = 64 ' (&H40)
PUBLIC CONST vbUpperCase = 1
PUBLIC CONST vbWide = 4

' OLECMDID Enum Type
PUBLIC CONST OLECMDID_OPEN = 1
PUBLIC CONST OLECMDID_NEW = 2
PUBLIC CONST OLECMDID_SAVE = 3
PUBLIC CONST OLECMDID_SAVEAS = 4
PUBLIC CONST OLECMDID_SAVECOPYAS = 5
PUBLIC CONST OLECMDID_PRINT = 6
PUBLIC CONST OLECMDID_PRINTPREVIEW = 7
PUBLIC CONST OLECMDID_PAGESETUP = 8
PUBLIC CONST OLECMDID_SPELL = 9
PUBLIC CONST OLECMDID_PROPERTIES = 10
PUBLIC CONST OLECMDID_CUT = 11
PUBLIC CONST OLECMDID_COPY = 12
PUBLIC CONST OLECMDID_PASTE = 13
PUBLIC CONST OLECMDID_PASTESPECIAL = 14
PUBLIC CONST OLECMDID_UNDO = 15
PUBLIC CONST OLECMDID_REDO = 16
PUBLIC CONST OLECMDID_SELECTALL = 17
PUBLIC CONST OLECMDID_CLEARSELECTION = 18
PUBLIC CONST OLECMDID_ZOOM = 19
PUBLIC CONST OLECMDID_GETZOOMRANGE = 20
PUBLIC CONST OLECMDID_UPDATECOMMANDS = 21
PUBLIC CONST OLECMDID_REFRESH = 22
PUBLIC CONST OLECMDID_STOP = 23
PUBLIC CONST OLECMDID_HIDETOOLBARS = 24
PUBLIC CONST OLECMDID_SETPROGRESSMAX = 25
PUBLIC CONST OLECMDID_SETPROGRESSPOS = 26
PUBLIC CONST OLECMDID_SETPROGRESSTEXT = 27
PUBLIC CONST OLECMDID_SETTITLE = 28
PUBLIC CONST OLECMDID_SETDOWNLOADSTATE = 29
PUBLIC CONST OLECMDID_STOPDOWNLOAD = 30

PUBLIC CONST OLECMDEXECOPT_DODEFAULT = 0
PUBLIC CONST OLECMDEXECOPT_DONTPROMPTUSER = 2
PUBLIC CONST OLECMDEXECOPT_PROMPTUSER = 1
PUBLIC CONST OLECMDEXECOPT_SHOWHELP = 3

PUBLIC CONST OLECMDF_DEFHIDEONCTXTMENU = 32
PUBLIC CONST OLECMDF_ENABLED = 2
PUBLIC CONST OLECMDF_INVISIBLE = 16
PUBLIC CONST OLECMDF_LATCHED = 4
PUBLIC CONST OLECMDF_NINCHED = 8
PUBLIC CONST OLECMDF_SUPPORTED = 1

' See Page.WebBrowserHWND() help
PUBLIC CONST CWINDOW_OBJECT_MAPPER_IE_HWND_CLASS_INTERNET_EXPORER_SERVER = "Internet Explorer_Server"
PUBLIC CONST CWINDOW_OBJECT_MAPPER_IE_HWND_CLASS_SHELL_EMBEDDING = "Shell Embedding"
PUBLIC CONST CWINDOW_OBJECT_MAPPER_IE_HWND_CLASS_SHELL_DOCOBJECT_VIEW = "Shell DocObject View"


'
' WINDOWS API CONSTANTS
'
PUBLIC CONST SW_HIDE = 0
PUBLIC CONST SW_SHOWNORMAL = 1
PUBLIC CONST SW_SHOWMINIMIZED = 2
PUBLIC CONST SW_SHOWMAXIMIZED = 3
PUBLIC CONST SW_SHOWNOACTIVATE = 4
PUBLIC CONST SW_SHOW = 5
PUBLIC CONST SW_MINIMIZE = 6
PUBLIC CONST SW_SHOWMINNOACTIVE = 7
PUBLIC CONST SW_SHOWNA = 8
PUBLIC CONST SW_RESTORE = 9


' W3Runner.vbs Error Message
PUBLIC CONST W3Runner_VBS_ERROR_MESSAGE_1000  = "W3Runner.Vbs.Error.1000-Include file not found [FILE]"
PUBLIC CONST W3Runner_VBS_ERROR_MESSAGE_1001  = "W3Runner.Vbs.Error.1001-Syntax error found in include file [FILE][CRLF][ERROR]"
PUBLIC CONST W3Runner_VBS_ERROR_MESSAGE_1002  = "W3Runner.Vbs.Error.1002-Cannot create COM Object [PROGID]"

' W3Runner.vbs Warning Message
PUBLIC CONST W3Runner_VBS_WARNING_MESSAGE_1000 = "W3Runner.Vbs.Warning.1002-file [FILE] already included" ' Warning

PUBLIC Undefined : Undefined = Empty

PRIVATE w3r_m_objIncludedFileList

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION  : w3rIsAlreadyIncluded
' PARAMETERS :
' DESCRIPTION : Return TRUE is the file was already included in the current session.
' RETURNS  :
PRIVATE FUNCTION w3rIsAlreadyIncluded(strIncludeFileName)

  Dim objVBScriptExtensions

  w3rIsAlreadyIncluded = FALSE

  If IsEmpty(w3r_m_objIncludedFileList) Then

       On Error Resume Next
       Set objVBScriptExtensions = CreateObject(CVBScriptExtensions)
       If Err.Number Then

          MsgBox PreProcess(W3Runner_VBS_ERROR_MESSAGE_1002,Array("PROGID",CVBScriptExtensions))
          Exit Function
       End If
       On Error Goto 0
       Set w3r_m_objIncludedFileList = objVBScriptExtensions.GetNewCollection()
  End If

  On Error Resume Next
  w3r_m_objIncludedFileList.Add UCase(strIncludeFileName),UCase(strIncludeFileName)
  If(Err.Number)Then
     W3Runner.TRACE PreProcess(W3Runner_VBS_WARNING_MESSAGE_1000,Array("FILE",strIncludeFileName)), w3rWARNING
     w3rIsAlreadyIncluded = TRUE
  Else
     w3rIsAlreadyIncluded = FALSE
  End If
  On Error Goto 0
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION  : Include
' PARAMETERS :
' DESCRIPTION : Include the VBScript filename strIncludeFileName
' RETURNS  : TRUE is ok.
PRIVATE FUNCTION Include(strIncludeFileName) ' As Boolean

  Dim varText, strErrorMessage

  Include = FALSE

  If(w3rIsAlreadyIncluded(strIncludeFileName))Then ' already included
      Include = TRUE
      Exit Function
  End If
  W3Runner.TRACE "Include """ & strIncludeFileName & """", w3rMETHOD

  If (W3Runner.LoadVBScriptCode(strIncludeFileName, varText)) Then
  
      On Error Resume Next
      ExecuteGlobal varText 
      If (Err.Number) Then
    
        strErrorMessage = GetVBErrorString() ' Save the current error
        W3Runner.MsgBox PreProcess(W3Runner_VBS_ERROR_MESSAGE_1001,Array("FILE",strIncludeFileName,"ERROR",strErrorMessage,"CRLF",vbNewLine))
        ' Try to find a better error message if we cannot we return false 
        If Not W3Runner.CheckVBScriptCode(strIncludeFileName) Then 
            Msgbox strErrorMessage ' Display the only error info we have
        End If
        Exit Function
      End If
      On Error GoTo 0
      Include = True
  Else
      ' We cannot load the file.
      W3Runner.MsgBox PreProcess(W3Runner_VBS_ERROR_MESSAGE_1000,Array("FILE",strIncludeFileName))
  End If
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION  : IsValidObject
' PARAMETERS  :
' DESCRIPTION  : Return if obj is an object and not nothing.
' RETURNS  :
PRIVATE FUNCTION IsValidObject(obj) ' As Boolean

  IsValidObject = False
  
  If (IsEmpty(obj)) Then Exit Function

  If (IsObject(obj)) Then
      IsValidObject = Not (obj Is Nothing)
  End If
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION  : IIF
' PARAMETERS  :
' DESCRIPTION  : Implement the Visual Basic IIF
' RETURNS  :
PRIVATE FUNCTION IIF(booExp, varRetValueTrue, varRetValueFalse) ' As Variant

  If (booExp) Then
    IIF = varRetValueTrue
  Else
    IIF = varRetValueFalse
  End If
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION  : IsBoolean
' PARAMETERS  :
' DESCRIPTION  :
' RETURNS  :
PRIVATE FUNCTION IsBoolean(varExpression) 'As Boolean

  Dim b 'As Boolean

  On Error Resume Next
  b = CBool(varExpression)
  IsBoolean = CBool(Err.Number = 0)
  Err.Clear
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION  : PreProcess
' PARAMETERS  :
' DESCRIPTION  : Simple and smart string replacement.
'    PreProcess("Hello [SOMETHING]",Array("SOMETHING","World")) will return
'    Hello World
' RETURNS  : Return the string preprocess
PRIVATE FUNCTION PreProcess(ByVal strMessage, Defines) ' As String

  Dim i ' As Long

  For i = 0 To UBound(Defines) Step 2

       strMessage = Replace(strMessage, "[" & Defines(i) & "]", CStr(Defines(i + 1)))
  Next
  PreProcess = strMessage
END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION  : GetVBErrorString
' PARAMETERS  :
' DESCRIPTION  :
' RETURNS  :
PRIVATE FUNCTION GetVBErrorString() ' As String

  Dim strWindowsErrorMessage, strRetVal, strErrorDescription

  strErrorDescription = Err.Description
  strRetVal = "VBScript Run Time Error=" & CStr(Err.Number) & "; description=" &  strErrorDescription & "; source=" & Err.Source & ";"

  If Len(strErrorDescription)=0 Then ' If we have no description

      strWindowsErrorMessage = W3Runner.WinApi.FormatMessage(Err.Number)
      If Len(strWindowsErrorMessage) Then strRetVal = strRetVal & " Windows Error Message=" & strWindowsErrorMessage & "; "
  End If
  GetVBErrorString = strRetVal
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION  : EvalExp
' PARAMETERS  :
' DESCRIPTION  : Evaluate an VBScript expression but catch the error the expression fail.
' RETURNS  :
PRIVATE FUNCTION EvalExp(varEvalMe)

  On Error Resume Next
  EvalExp = Eval(varEvalMe)
  If (Err.Number) Then
      W3Runner.TRACE "Cannot eval " & varEvalMe, w3rERROR
  End If
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION  : w3rTraceW3RunnerEnvironmentInfo
' PARAMETERS  :
' DESCRIPTION  : Display in the Trace list view some context information
' RETURNS  :
PRIVATE FUNCTION w3rTraceW3RunnerEnvironmentInfo() ' As Boolean

  W3Runner.TRACE "W3Runner version " & W3Runner.Environ(w3rW3RUNNER_VERSION)
  W3Runner.TRACE "Windows version " & W3Runner.Environ(w3rWINDOWS_VERSION)
  W3Runner.TRACE "WebBrowser version " & W3Runner.Environ(w3rWEB_BROWSER_VERSION)
  W3Runner.TRACE "Windows Script Host version " & W3Runner.Environ(w3rWINDOWS_SCRIPT_HOST_VERSION)
  W3Runner.TRACE "VBScript Engine version " & W3Runner.Environ(w3rVBSCRIPT_ENGINE_VERSION)
  W3Runner.TRACE "Computer Name " & W3Runner.Environ(w3rCOMPUTER_NAME)
  W3Runner.TRACE "User Name " & W3Runner.Environ(w3rUSER_NAME)
  W3Runner.TRACE "Debug Mode " & IIF(W3Runner.Environ(w3rVBSCRIPT_DEBUG_MODE), "On", "Off")
  W3Runner.TRACE "Temp folder " & W3Runner.Environ("TEMP")
  W3Runner.TRACE "Path " & W3Runner.Environ("PATH")

  w3rTraceW3RunnerEnvironmentInfo = True
  
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION   : Page_OnTrace
' PARAMETERS  :
' DESCRIPTION : Default Event Implementation.
' RETURNS   :
PUBLIC SUB W3Runner_OnTrace(ByVal eTraceType, ByVal strMessage)
END SUB
' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION   : Page_OnError
' PARAMETERS  :
' DESCRIPTION : Default Event Implementation.
' RETURNS   :
PUBLIC SUB W3Runner_OnError(ByVal lngNumber, ByVal strDescription, ByVal strSource)
END SUB

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION  : CommandLineCheck
' PARAMETERS  :
' DESCRIPTION  : Check that this file is executed from W3Runner, if executed as a regular vbscript from the command line
'    this function will display a message.
' RETURNS  :
PRIVATE FUNCTION CommandLineCheck()

  On Error Resume Next
  IsRunningUnderW3Runner = W3RUNNER_RUNNER_RUNNING
  If (Err.Number) Then ' Run from the command line
   WScript.Echo WScript.ScriptName & " can only be executed from W3Runner."
   Err.Clear
  End If
  CommandLineCheck = True
END FUNCTION

CommandLineCheck

