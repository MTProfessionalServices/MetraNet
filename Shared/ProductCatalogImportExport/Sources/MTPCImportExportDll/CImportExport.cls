VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CImportExport"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Private m_lngTime As Long
Public m_objGlobalProfile As New CProfiler
Private m_strApplicationName As String

Public Function Initialize(ByVal strApplicationName As String, ByVal strCommand As String) As Boolean

    Dim objCommandLine As New CCommandLine
    
    'Set static_objCommandLine = New CCommandLine
    static_strCommandLine = strCommand
    
    objCommandLine.Init strCommand
    
    Me.Verbose = objCommandLine.Exist("-v")
    
    Set static_objConsoleWindow = New CConsoleWindow
    m_strApplicationName = strApplicationName
    
    m_objGlobalProfile.Start True, TypeName(Me), "Initialize", "Application " & m_strApplicationName, ePROFILER_FLAG_TRACE
    
    INFO "MTPCImportExport.CImportExport Initialization. Application=" & strApplicationName
    
    Initialize = XMLOutputInitialize()
    
End Function


Public Property Get XMLOutPut() As String
    XMLOutPut = static_objXMLOutPut.GetString()
End Property

Public Property Let XMLOutPut(ByVal vNewValue As String)
    static_objXMLOutPut.Concat vNewValue
End Property

Public Function INFO(ByVal strText As String, Optional ByVal Module As Variant, Optional ByVal strFunctionName As String) As Boolean
    INFO = MTPCImportExportModule.INFO(strText, Module, strFunctionName)
End Function


Private Sub Class_Initialize()
    
End Sub

Private Sub Class_Terminate()

    
    
    INFO PreProcess(MTPCImportExport_MESSAGE_1003, "APPLICATION", m_strApplicationName), Me, "Class_Terminate"
    
    Set m_objGlobalProfile = Nothing
    m_lngTime = GetTickCount() - m_lngTime
    
    INFO "MTPCImportExport.CImportExport Terminate. Application=" & m_strApplicationName & " Time=" & (m_lngTime / 1000)
    
End Sub

Public Property Get Verbose() As Boolean
    Verbose = static_booVerbose
End Property

Public Property Let Verbose(ByVal vNewValue As Boolean)
    static_booVerbose = vNewValue
End Property

Public Function TraceInfo(s) As Boolean
    INFO s
End Function


Public Function Version() As String

    Version = App.Major & "." & App.Minor & "." & App.Revision
End Function


