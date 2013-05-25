Attribute VB_Name = "Module2"
Option Explicit



Public Sub ALT_TRACE(strM As String, Optional strModule As String, Optional strFunction As String)
    Debug.Print strM
End Sub

Public Function ProcessQuery(strSQL As String, obj As Object, ParamArray Properties()) As String
    
    Dim v As Variant
    Dim Value As Variant
    For Each v In Properties
        Value = CallByName(obj, CStr(v), VbGet)
        If (IsNull(Value)) Then Value = "NULL"
        strSQL = Replace(strSQL, "[" & UCase(v) & "]", CStr(Value))
    Next
    ProcessQuery = strSQL
End Function




Public Function ObjectToString(obj As Object, ParamArray Properties()) As String
    
    Dim v As Variant
    Dim strS As String
    For Each v In Properties
        strS = strS & CStr(v) & "=" & CallByName(obj, CStr(v), VbGet) & "; "
    Next
    ObjectToString = strS
End Function

Public Function IsValidObject_(v As Variant) As Boolean
    If (IsObject(v)) Then
        IsValidObject_ = Not v Is Nothing
    End If
End Function


Public Function GetUnicID() As String

    GetUnicID = "GID" & GetTickCount()
    Sleep 1
    DoEvents
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
        clmX.key = labl
        clmX.Width = lngWidth
    End If
    clmX.Text = labl
    Set lvAddColumn = clmX
End Function


Public Function lvAddRow(lView As Control, texte As String, Optional key, Optional tagy, Optional smallIcon) As Variant

    On Error GoTo errmgr
    
    Dim itmx As Variant
    Set itmx = lView.ListItems.Add()
    
    itmx.Text = texte
        
    If Not IsMissing(key) Then itmx.key = "" & key
    If Not IsMissing(tagy) Then itmx.Tag = tagy
    
    If Not IsMissing(smallIcon) Then itmx.smallIcon = smallIcon
    
    Set lvAddRow = itmx
    
    Exit Function
errmgr:
    
    
End Function


Public Function tvAddNode(TransactionChart As TreeView, ByVal strRootParent As String, ByVal strID As String, ByVal strText As String, ByVal strIcon As String, ByVal strType As String, Optional ByVal booExpand As Boolean = True, Optional ByVal booSelected As Boolean = False) As Boolean

    Dim obNode      As Node
                   
    If (Len(strRootParent)) Then
        Set obNode = TransactionChart.Nodes.Add(strRootParent, tvwChild, strID, strText, strIcon)
    Else
        Set obNode = TransactionChart.Nodes.Add(, , strID, strText, strIcon)
    End If
    
    obNode.Tag = strType
        
    
        obNode.Expanded = booExpand
    
    If (booSelected) Then
        obNode.EnsureVisible
        obNode.Selected = True
    End If
    
    
End Function




