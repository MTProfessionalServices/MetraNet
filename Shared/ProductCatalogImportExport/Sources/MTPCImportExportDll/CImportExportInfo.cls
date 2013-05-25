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

Public Export As New MTPCImportExport.CExport
Public Import As New MTPCImportExport.CImport


Public m_objGlobalProfile As New CProfiler

Private m_strApplicationName As String

Public Function Version() As String

    Version = App.Major & "." & App.Minor & "." & App.Revision
End Function

Public Function Initialize(ByVal strApplicationName As String) As Boolean

    m_strApplicationName = strApplicationName
    
    m_objGlobalProfile.Start True, TypeName(Me), "Initialize", "Application " & m_strApplicationName, ePROFILER_FLAG_TRACE
    
    INFO "MTPCImportExport.CImportExport Initialization. Application=" & strApplicationName
    
    Set static_objMTProductCatalog = New MTProductCatalog
    
    Initialize = XMLOutputInitialize()
    
End Function



Public Property Get XMLOutPut() As String
    XMLOutPut = static_objXMLOutPut.GetString()
End Property

Public Property Let XMLOutPut(ByVal vNewValue As String)
    static_objXMLOutPut.Concat vNewValue
End Property

Public Property Get ProductCatalog() As MTProductCatalog
    Set ProductCatalog = static_objMTProductCatalog
End Property

Public Function INFO(ByVal strText As String, Optional ByVal Module As Variant, Optional ByVal strFunctionName As String) As Boolean
    INFO = MTPCImportExportModule.INFO(strText, Module, strFunctionName)
End Function


Private Sub Class_Terminate()
    INFO "MTPCImportExport.CImportExport Terminate. Application=" & m_strApplicationName
    Set m_objGlobalProfile = Nothing
End Sub
