Attribute VB_Name = "WebServiceTestGeneratorMod"
Option Explicit

Public Enum eAPP_ACTION
    LOAD_DATA
    SAVE_DATA
    LOAD_LISTVIEW_COLUMS_SIZE
End Enum


Public Enum WSG_TRACE

    w3rINFO = 1
    w3rERROR = 2
    w3rWARNING = 4
    w3rDEBUG = 64
    w3rINTERNAL = 128
    w3rCLEAR_TRACE = 256
End Enum 'end

Public Const WSG_MESSAGE_1000 = "Web Service Test Generator"
Public Const WSG_MESSAGE_1001 = "Select a File"
Public Const WSG_MESSAGE_1002 = "WSDL File|*.wsdl|XML Files|*.xml|All Files(*.*)|*.*"
Public Const WSG_MESSAGE_1003 = "Ready."
Public Const WSG_MESSAGE_1004 = "Generating test file"

Public g_objIniFile As New cIniFile

Public Sub Main()
    g_objIniFile.InitAutomatic App
    
    frmMain.Show
    frmMain.TRACE WSG_MESSAGE_1003, w3rINFO
End Sub


Public Property Get AppOptions(strName As String, Optional ByVal defaultValue As Variant) As String
    Dim s As String
    
    If (IsMissing(defaultValue)) Then defaultValue = Empty
    
    s = g_objIniFile.getVar("frmoptions", strName)
    If (Len(s)) Then
        AppOptions = s
    Else
        AppOptions = defaultValue
    End If
End Property

Public Property Let AppOptions(strName As String, Optional ByVal defaultValue As Variant, ByVal v As String)
    
    g_objIniFile.SetVar "frmoptions", strName, v
End Property



Public Function GetW3RunnerTraceString(eMode As WSG_TRACE) As String

    Dim s As String

    
    Select Case eMode
        
        Case w3rINFO: s = "INFO"
        Case w3rERROR: s = "ERROR"
        Case w3rWARNING: s = "WARNING"
        Case w3rDEBUG: s = "DEBUG"
        Case w3rINTERNAL: s = "INTERNAL"
        Case w3rCLEAR_TRACE: s = "CLEAR_TRACE"

        Case Else
            s = "UNKNOWN"
    End Select
    GetW3RunnerTraceString = s

End Function



Public Function lvAddColumn(lView As ListView, labl As String, Optional ByVal booClear As Boolean, Optional lngWidth As Long = 128) As Variant

    Dim clmX            As Variant
    
    On Error Resume Next
    
    If (booClear) Then
        lView.ColumnHeaders.Clear
        lView.ListItems.Clear
    End If
    
    Set clmX = lView.ColumnHeaders(labl)
    Err.Clear
    If clmX Is Nothing Then
        Set clmX = lView.ColumnHeaders.Add()
        clmX.Key = labl
        
    End If
    clmX.Width = lngWidth * Screen.TwipsPerPixelX
    clmX.Text = labl
    Set lvAddColumn = clmX
End Function


Public Function lvAddRow(lView As Control, texte As String, Optional Key, Optional tagy, Optional smallIcon) As Variant

    On Error GoTo ErrMgr
    
    Dim itmx As Variant
    Set itmx = lView.ListItems.Add()
    
    itmx.Text = texte
        
    If Not IsMissing(Key) Then itmx.Key = "" & Key
    If Not IsMissing(tagy) Then itmx.Tag = tagy
    
    If Not IsMissing(smallIcon) Then itmx.smallIcon = smallIcon
    
    Set lvAddRow = itmx
    
    Exit Function
ErrMgr:
    
    
End Function


