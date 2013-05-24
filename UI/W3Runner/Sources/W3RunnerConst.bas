Attribute VB_Name = "W3RunnerConst"
Option Explicit

#If RECORD_MODE_ Then
     Public Const APP_TITLE = "W3Runner"
 #Else
     Public Const APP_TITLE = "W3Runner RT"
 #End If
 
Public Const W3RUNNER_CRYPTED_SCRIPT_EXTENSION = "w3vbc"
Public Const W3RUNNER_FILE_OPEN_FILTER = "VBScript files|*.vbs|W3Runner Crypted VBScript files|*." & W3RUNNER_CRYPTED_SCRIPT_EXTENSION


Public Const HTTP_W3RUNNER_SERVER_NAME = "http://www.w3runner.com"

Public Const W3RUNNER_DEFAULT_HOME_PAGE_COMMAND = "%W3Runner Welcome Page%"

Public Const W3RUNNER_EXE_FILE_NAME = "W3Runner"
Public Const W3RUNNER_INI_FILENAME = "W3Runner.ini"


Public Enum w3rQUIT_MODE
    w3rQUIT_MODE_NORMAL = 1
    w3rQUIT_MODE_START_SAME_SCRIPT = 2
End Enum

Public Enum w3rWAIT_MODE
    w3rWAIT_MODE_DEFAULT = 1
    w3rWAIT_MODE_NO_SLEEP_API_CALL = 2
    w3rWAIT_MODE_NO_DOEVENTS_CALL = 4
End Enum

Public Enum GetBrowserInfo
    GetBrowserInfo_LEFT_POS
    GetBrowserInfo_TOP_POS
    GetBrowserInfo_MENU_HEIGHT
End Enum

Public Enum eGetHTMLObjectPosType
    eGetHTMLObjectPosType_MIDDLE = 1
    eGetHTMLObjectPosType_LEFT_TOP = 2
    eGetHTMLObjectPosType_ABSOLUTE_LEFT_TOP = 3
End Enum

Public Const MICROSOFT_MSHTML_WEBSITE = "http://msdn.microsoft.com/library/default.asp?url=/workshop/browser/mshtml/mshtml.asp"

'Public Const LOCALE_SCURRENCY = &H14
'Public Const LOCALE_ICOUNTRY = &H5         '  country code
'Public Const LOCALE_SCOUNTRY = &H6         '  localized name of country
'Public Const LOCALE_SENGCOUNTRY = &H1002      '  English name of country

Public Const W3RUNNER_EVENT_W3RUNNER_ONTRACE = "W3RUNNER_ONTRACE"
Public Const W3RUNNER_EVENT_W3RUNNER_ONERROR = "W3RUNNER_ONERROR"

Public Const W3RUNNER_VBSCRIPT_GENERATED_INDENT_STRING = "    "

Public Const W3RUNNER_WEBSERVER_DEFAULT_TIMEOUT = 5
Public Const CAPTION_HEIGHT_PIXEL = 28
Public Const RESIZE_BORDER_HEIGHT = 3
Public Const RESIZE_BORDER_WIDTH = 7




Public Const DEFAULT_ADVANCED_WAITFORDOWNLOAD_SLEEP_TIME = 200
Public Const DEFAULT_ADVANCED_URL_TIME = 500
Public Const DEFAULT_ADVANCED_WATCH_READY_STATE_TIME = 500
Public Const DEFAULT_ADVANCED_CLICK_TIME = 50
Public Const DEFAULT_EDITOR = "NotePad.exe"

Public Const TRIAL_MAX_UI_ITEM_BASE_1 = 24
Public Const TRIAL_MAX_UI_ITEM_BASE_2 = TRIAL_MAX_UI_ITEM_BASE_1 * 2

Public Enum eW3RunnerContainsCompareMode
    ierContainsCompareMode_VALUE = 1
    ierContainsCompareMode_TEXT = 2
End Enum

Public Enum eW3RunnerEnvironmentInfo

    w3rW3RUNNER_VERSION = 0
    w3rWEB_BROWSER_VERSION = 1
    w3rWINDOWS_SCRIPT_HOST_VERSION = 2
    w3rVBSCRIPT_ENGINE_VERSION = 3
    w3rVBSCRIPT_DEBUG_MODE = 4
    w3rWINDOWS_VERSION = 5
    w3rCOMPUTER_NAME = 6
    w3rUSER_NAME = 7
    w3rW3RUNNER_PATH = 8
    w3rRESERVED_W3RUNNER_WEBSERVER_IP = 9 ' Not documented
    w3rW3RUNNER_PROGRAM = 10
    w3rENVIRONMENT_MAX_VALUE = 10
    
End Enum

Public eW3RunnerEnvironmentInfoStrings() As String

Public Enum eW3RunnerTraceMode

    w3rINFO = 1
    w3rERROR = 2
    w3rWARNING = 4
    w3rSQL = 8
    w3rURL_DOWNLOADED = 16
    w3rMEMORY = 32
    w3rDEBUG = 64
    w3rINTERNAL = 128
    w3rMETHOD = 256
    w3rJAVASCRIPT = 512
    w3rSUCCESS = 1024
    w3rCLEAR_TRACE = 2048
    w3rPERFORMANCE = 4096
    w3rWEBSERVICE = 8192
    w3rTRACEHTTP = 16384
End Enum

Public Const W3RUNNER_MODE_DESIGN = "design"
Public Const W3RUNNER_MODE_RECORDING = "recording"
Public Const W3RUNNER_MODE_RUN = "run"
Public Const MAX_PREVIOUS_FILE = 6

Public Const TIP_INDEX_END_RECORD_TIP = 1
Public Const MDMTEXT_COMMAND_LINE_ORDER_SENDKEYS = "/sendkeys"
Public Const W3RUNNER_HTTP_PROTOCOL = "w3runnerserver://"
Public Const W3RUNNER_HTTP_IP = "http://w3runnerserverip/"


Public Const W3RUNNER_DEFAULT_FUNCTION_NAME = "Main"
Public Const W3RUNNER_DEFAULT_VBSCRIPT_TIME_OUT = 100 ' No Time OUt
Public Const W3RUNNER_DEFAULT_ASP_TIME_OUT = 20
Public Const W3RUNNER_DEFAULT_MSGBOX_TIME_OUT = 20

Public Const W3RUNNER_IEOBJECTSTYPESUPPORTED = "HTMLTextAreaElement;HTMLInputElement;HTMLSelectElement;HTMLButtonElement;HTMLAnchorElement;HTMLImg;HTMLFrameElement;HTMLTableCell;HTMLBody;HTMLMapElement;"

Public Const WELCOME_PAGE_END_OF_BLANK_URL = "/W3Runner/WebServices/"

' We use this function to support the HTTP Recorder
Public Function GetProgramName() As String

    If InStr(App.EXEName, W3RUNNER_EXE_FILE_NAME) Then
        GetProgramName = W3RUNNER_EXE_FILE_NAME
    Else
        GetProgramName = App.EXEName
    End If
End Function
 
