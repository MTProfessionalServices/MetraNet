VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MTVbLibInfo"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Public Property Get LogWithoutCOMLogger() As Boolean

    LogWithoutCOMLogger = g_booLogWithoutCOMLogger
End Property

Public Property Let LogWithoutCOMLogger(ByVal vNewValue As Boolean)

    g_booLogWithoutCOMLogger = vNewValue
End Property

Public Function Test()

    LogError "my test", "module", "function", eMTGLOBAL_LOG_TRACE_MODE.LOG_WARNING
End Function

Public Property Get LogFileName() As String

    If (Len(g_strLogWithoutCOMLoggerFileName) = 0) Then
        LogFileName = Environ("temp") & "\MTVBLIB.LOG"
    Else
        LogFileName = g_strLogWithoutCOMLoggerFileName
    End If
End Property

Public Property Let LogFileName(ByVal vNewValue As String)

    g_strLogWithoutCOMLoggerFileName = vNewValue
End Property

