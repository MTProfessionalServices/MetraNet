Attribute VB_Name = "vblib"
Option Explicit

Public Const MTVBLIB_ERROR_03500 = "03500-MTVBLIB-COM/XML mismatch [FILE]"
Public Const MTVBLIB_ERROR_03501 = "03501-MTVBLIB-Failed reading xml file [FILE]"
Public Const MTVBLIB_ERROR_03502 = "03502-MTVBLIB-File [FILE] not found"
Public Const MTVBLIB_ERROR_03503 = "03503-MTVBLIB-XML Parsing error File [FILE]"
Public Const MTVBLIB_ERROR_03504 = "03504-MTVBLIB-XMLDOM Parsing filename=[FILENAME] error=[ERROR] filepos=[FILEPOS] line=[LINE] linepos=[LINEPOS] reason=[REASON] scrtext=[TEXT]"
Public Const MTVBLIB_ERROR_03505 = "03505-MTVBLIB-Function Process() found a non closed bracket in the string '[STRING]'"
Public Const MTVBLIB_ERROR_03506 = "03506-MTVBLIB-Warning-Variable [NAME] not found in the variables collection."

Public Enum eMTGLOBAL_LOG_TRACE_MODE '

    LOG_APPLICATION_ERROR = 256 ' This is not a real MTLogger Value but an internal value, when an application
                                ' want to log an application error, this enum type item will log a warning...
    LOG_TRACE = 6
    LOG_DEBUG = 5
    LOG_INFO = 4
    LOG_WARNING = 3
    LOG_ERROR = 2
    LOG_FATAL = 1
    LOG_OFF = 0
End Enum
   

' -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :   LogMessage
' PARAMETERS    :
'                   strText            - The message
'                   enmLogLevel        - MT Logging mode, see enum type eMTGLOBAL_LOG_TRACE_MODE
' DESCRIPTION   :   Log the message strText
' RETURN        :   TRUE.
Public Sub LogMessage(Optional strText As String, Optional enmLogLevel As eMTGLOBAL_LOG_TRACE_MODE = LOG_DEBUG)

'    Logger strText, enmLogLevel
End Sub

' -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :   LogError
' PARAMETERS    :
'                   strText            - Additional text to the error
'                   strModuleName      - The name of the module/class/form where the error occured.
'                   strFunctionName    - The name of the function/sub/property where the error occured.
'                   enmLogLevel        - MT Logging mode, see enum type eMTGLOBAL_LOG_TRACE_MODE
' DESCRIPTION   :   Log the message strText.
' RETURN        :   TRUE.
Public Sub LogError(Optional ByVal strText As String, Optional ByVal strModuleName As String, Optional ByVal strFunctionName As String, Optional ByVal enmLogLevel As eMTGLOBAL_LOG_TRACE_MODE = LOG_ERROR)
        
    Dim strVBErrorString As String
    
    If (Err.Number) Then
    
        strVBErrorString = GetVBErrorString() ' Let us save the VB error we must log
        'TRACE strVBErrorString & strText, strModuleName, strFunctionName, enmLogLevel
    Else
        'TRACE strText, strModuleName, strFunctionName, enmLogLevel
    End If
End Sub



' -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : TRACE
' PARAMETERS    :
'                   strText            - The message
'                   strModuleName      - The name of the module/class/form
'                   strFunctionName    - The name of the function/sub/property
'                   enmLogLevel        - MT Logging mode, see enum type eMTGLOBAL_LOG_TRACE_MODE
' DESCRIPTION   :   Log the message strText
' RETURN        :   TRUE.
Public Function RACE(ByVal strText As String, Optional ByVal strModuleName As String, Optional ByVal strFunctionName As String, Optional ByVal enmLogLevel As eMTGLOBAL_LOG_TRACE_MODE = LOG_DEBUG) As Boolean

    Dim strModuleTrace      As String
    Dim strFunctionTrace    As String
    Dim strAppInfo          As String
    
    If (Len(strModuleName)) Then strModuleTrace = "Module=" & strModuleName & ";"
    If (Len(strFunctionName)) Then strFunctionTrace = "Function=" & strFunctionName & ";"
      
'    TRACE = Logger(strModuleTrace & " " & strFunctionTrace & " " & strText & " ", enmLogLevel)
End Function



