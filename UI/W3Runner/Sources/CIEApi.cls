VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CIEApi"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
' ****************************************************************************************************************************************************
'
'  Written (W) by Frederic Torres 2001-2002
'  ARR.
'
'  CLASS        :
'  AUTHOR       : Frederic Torres
'  DATE         : 10/xx/2001
'  DESCRIPTION  :
'  VERSION      : none.
'
' ****************************************************************************************************************************************************
Option Explicit

Public Function ClearCache(Optional ByVal strFileName As String) As Boolean
    
    Dim objIECache As New CIECache
    objIECache.Load

    ClearCache = objIECache.DeleteAll(, False)
    Exit Function
errmgr:
    FShowError GetVBErrorString(), "CIEApi.cls", "ClearCache"
End Function

Public Function OptionsDialogs() As Boolean
    Dim rtn As Long
    rtn = WinExec("control.exe inetcpl.cpl", SW_SHOW)
End Function

'' NOT_USED
'Public Property Get IEDocument(ByVal lngHWND As Long) As Object
'
'    Dim SWs As New ShellWindows
'    Dim IE  As Variant ' IWebBrowser2
'
'    Set IEDocument = Nothing
'
'    For Each IE In SWs
'
'        If IE.hwnd = lngHWND Then
'
'            Set IEDocument = IE.Document
'        End If
'    Next
'End Property

'' NOT_USED
'Public Property Get IEObject(ByVal lngHWND As Long) As Object
'
'    Dim SWs As New ShellWindows
'    Dim IE  As InternetExplorer
'
'    Set IEObject = Nothing
'
'    For Each IE In SWs
'
'        If IE.hwnd = lngHWND Then
'
'            Set IEObject = IE
'        End If
'    Next
'End Property

