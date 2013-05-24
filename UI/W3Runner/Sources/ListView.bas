Attribute VB_Name = "ListViewModule"
Option Explicit

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

    On Error GoTo errmgr
    
    Dim itmx As Variant
    Set itmx = lView.ListItems.Add()
    
    itmx.Text = texte
        
    If Not IsMissing(Key) Then itmx.Key = "" & Key
    If Not IsMissing(tagy) Then itmx.Tag = tagy
    
    If Not IsMissing(smallIcon) Then itmx.smallIcon = smallIcon
    
    Set lvAddRow = itmx
    
    Exit Function
errmgr:
    
    
End Function




Public Function lvLoadSaveContext(lView As ListView, booSave As Boolean, clsApp As Variant, Optional strFileName As String, Optional strSection As String) As Boolean
 
    Dim Inif        As New cIniFile
    Dim C           As Long
    Dim strS        As String
    Dim lngMaxLen() As Long
                
    If (lView.ColumnHeaders.Count = 0) Then Exit Function
    
    If (strFileName = "") Then strFileName = clsApp.path & "\" & clsApp.EXEName & ".ini"
    If (strSection = "") Then strSection = lView.Name
    
    Inif.Init strFileName
    
    Erase lngMaxLen()
    ReDim lngMaxLen(1 To lView.ColumnHeaders.Count)
    
    For C = 1 To lView.ColumnHeaders.Count
    
        lngMaxLen(C) = -1
        
        If (booSave) Then
        
            Inif.SetVar strSection, "Col(" & C & ").Size", CStr(lView.ColumnHeaders(C).Width)
        Else
            strS = Inif.getVar(strSection, "Col(" & C & ").Size")
            If (IsNumeric(strS)) Then lngMaxLen(C) = CLng(strS)
        End If
    Next
    
    If (Not booSave) Then
    
        For C = 1 To lView.ColumnHeaders.Count
        
            If (lngMaxLen(C) <> -1) Then
            
                lView.ColumnHeaders(C).Width = lngMaxLen(C)
            End If
        Next
    End If
    
    Erase lngMaxLen()
    
    Inif.done
    
    lvLoadSaveContext = True
End Function

