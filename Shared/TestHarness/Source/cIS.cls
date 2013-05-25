VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "cIs"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private isServerRoot    As Object

Public Function getProperty(objType As String, objName As String, info As String, Value As Variant) As Boolean
'
' COMMENT   : Get property from any object i suppose
'
' IN        : objType if is "" the use the web server object
'
' OUT       :
'
' RETURN    : True if ok
'
    On Error Resume Next
    
    Dim VDirObj As Variant
   
    
    ' Finally, create virtual root directory
    If objType = "" Then
        Set VDirObj = isServerRoot
    Else
        Set VDirObj = isServerRoot.GetObject(objType, objName)
    End If
    If (Err.Number <> 0) Then GoTo lError
        
    Value = VDirObj.get(info)
    If (Err.Number <> 0) Then GoTo lError

    getProperty = True
Exit Function

lError:
    Err.Clear
    getProperty = False

End Function


Public Function CreateVirtualDir(VDirName As String, VDirPath As String, ByVal accessString As String) As Boolean
'
' COMMENT   : Create a virtual directory
'
' IN        : VDirName, VDirPath , accessString=READ=TRUE;WRITE=TRUE;EXECUTE=TRUE;SCRIPT=TRUE
'
' OUT       :
'
' RETURN    : True if ok
'

    On Error Resume Next
    
    Dim VDirObj As Variant
    
    CreateVirtualDir = False
    accessString = UCase(accessString)

    isServerRoot.Delete "IIsWebVirtualDir", VDirName
    Err.Clear
    
    ' Finally, create virtual root directory
    Set VDirObj = isServerRoot.Create("IIsWebVirtualDir", VDirName)
    If (Err.Number <> 0) Then GoTo lError

    ' Configure new virtual root
    VDirObj.Path = VDirPath
    VDirObj.AccessRead = InStr(accessString, "READ=TRUE") <> 0
    VDirObj.AccessWrite = InStr(accessString, "WRITE=TRUE") <> 0
    VDirObj.AccessExecute = InStr(accessString, "EXECUTE=TRUE") <> 0
    VDirObj.AccessScript = InStr(accessString, "SCRIPT=TRUE") <> 0
    VDirObj.EnableDirBrowsing = InStr(accessString, "BROWSEDIR=TRUE") <> 0

    ' Write info back to Metabase
    VDirObj.SetInfo
    If (Err.Number <> 0) Then GoTo lError

    CreateVirtualDir = True
Exit Function

lError:
    Err.Clear
    CreateVirtualDir = False

End Function

Public Function Initialize() As Boolean
    On Error Resume Next
    Set isServerRoot = GetObject(iisName)
    'Init = (Not (isServerRoot Is Nothing))
    Initialize = Err.Number = 0
    Err.Clear
End Function

Public Sub Done()
    releaseServer
End Sub

Private Sub Class_Terminate()
    releaseServer
End Sub

Private Sub releaseServer()
    Set isServerRoot = Nothing
End Sub

Public Function iisName() As String
    iisName = "IIS://localhost/W3SVC/1/Root"
End Function

Public Function webVirtualDirKeyWord() As String
    webVirtualDirKeyWord = "IIsWebVirtualDir"
End Function

Public Function getPhysicalIISWebRoot() As Variant
    Dim v As Variant
    
    If getProperty("", "", "Path", v) Then
        getPhysicalIISWebRoot = v
    Else
        getPhysicalIISWebRoot = ""
    End If
End Function
