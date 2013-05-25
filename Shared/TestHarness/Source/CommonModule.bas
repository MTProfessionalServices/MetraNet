Attribute VB_Name = "Module2"
Option Explicit



Public Sub ALT_TRACE(strM As String, Optional strModule As String, Optional strFunction As String)

    On Error GoTo ErrMgr

    Debug.Print strM

    Exit Sub
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "Module2", "ALT_TRACE"
End Sub

Public Function ProcessQuery(strSQL As String, obj As Object, ParamArray Properties()) As String

    On Error GoTo ErrMgr

    
    Dim v As Variant
    Dim Value As Variant
    For Each v In Properties
        Value = CallByName(obj, CStr(v), VbGet)
        If (IsNull(Value)) Then Value = "NULL"
        strSQL = Replace(strSQL, "[" & UCase(v) & "]", Value)
    Next
    ProcessQuery = strSQL

    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "Module2", "ProcessQuery"
End Function




Public Function ObjectToString(obj As Object, ParamArray Properties()) As String

    On Error GoTo ErrMgr

    
    Dim v As Variant
    Dim strS As String
    For Each v In Properties
        strS = strS & CStr(v) & "=" & CallByName(obj, CStr(v), VbGet) & "; "
    Next
    ObjectToString = strS

    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "Module2", "ObjectToString"
End Function

Public Function IsValidObject_(v As Variant) As Boolean

    On Error GoTo ErrMgr

    If (IsObject(v)) Then
        IsValidObject_ = Not v Is Nothing
    End If

    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "Module2", "IsValidObject_"
End Function


Public Function GetUnicID() As String

    On Error GoTo ErrMgr


    GetUnicID = "GID" & GetTickCount()
    Sleep 1
    DoEvents

    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "Module2", "GetUnicID"
End Function


Public Function lvSelectAll(lView As ListView, booStatus As Boolean) As Boolean

    Dim l As ListItem
    
    For Each l In lView.ListItems
    
        l.Selected = booStatus
    Next
    lvSelectAll = True
End Function

Public Function lvDeleteItem(lView As ListView, Items As Collection) As Boolean

    Dim v As Variant
    
    For Each v In Items
    
        lView.ListItems.Remove v
    Next
    lvDeleteItem = True

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
        
    End If
    clmX.Width = lngWidth
    clmX.Text = labl
    Set lvAddColumn = clmX
End Function


Public Function lvAddRow(lView As Control, texte As String, Optional key, Optional tagy, Optional smallIcon) As Variant

    On Error GoTo ErrMgr
    
    Dim itmx As Variant
    Set itmx = lView.ListItems.Add()
    
    itmx.Text = texte
        
    If Not IsMissing(key) Then itmx.key = "" & key
    If Not IsMissing(tagy) Then itmx.Tag = tagy
    
    If Not IsMissing(smallIcon) Then itmx.smallIcon = smallIcon
    
    Set lvAddRow = itmx
    
    Exit Function
ErrMgr:
    
    
End Function


Public Function tvAddNode(tvTests As TreeView, ByVal strRootParent As String, ByVal strID As String, ByVal strText As String, ByVal strIcon As String, ByVal strType As String, Optional ByVal booExpand As Boolean = True, Optional ByVal booSelected As Boolean = False) As Boolean

    On Error GoTo ErrMgr


    Dim obNode      As Node
                   
    If (Len(strRootParent)) Then
        Set obNode = tvTests.Nodes.Add(strRootParent, tvwChild, strID, strText, strIcon)
    Else
        Set obNode = tvTests.Nodes.Add(, , strID, strText, strIcon)
    End If
    
    obNode.Tag = strType
        
    
        obNode.Expanded = booExpand
    
    If (booSelected) Then
        obNode.EnsureVisible
        obNode.Selected = True
    End If
    
    

    Exit Function
ErrMgr:
        Clipboard.Clear
        Clipboard.SetText "Testid=" & strID & " TestName=" & strText
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString() & vbNewLine & "Testid=" & strID & vbNewLine & "TestName=" & strText & vbNewLine & "Information has been copied to the clipboard", "Module2", "tvAddNode"
End Function

Public Function GetNewTestApiInstance() As Object

    On Error Resume Next
    Set GetNewTestApiInstance = CreateObject("MTTestAPI.TestAPI")
    If (Err.Number) Then
    
        Err.Clear
        MsgBox "About to register MTTestAPI.exe"
        Shell App.Path & "\MTTestAPI.exe /RegServer"
    
        Set GetNewTestApiInstance = CreateObject("MTTestAPI.TestAPI")
        If (Err.Number) Then
            ShowError TESTHARNESS_ERROR_7020 & vbNewLine & GetVBErrorString(), "Module2", "GetNewTestApiInstance"
        Else
            MsgBox "MTTestAPI.exe registered."
        End If
    End If
    
End Function


Public Function SetVisiblePropertyFromFrame(fr As Frame, booVisible As Boolean) As Boolean

    
    
    Dim objForm As Form
    Dim c       As Variant
    
    Set objForm = fr.Parent
    
    
    For Each c In objForm.Controls
    
        Debug.Print TypeName(c), c.Name
        If GetContainer(c) Is fr Then
        
            c.Visible = booVisible
        End If
    Next
    
    SetVisiblePropertyFromFrame = True
End Function


Private Function GetContainer(ByVal o As Object) As Object
    On Error Resume Next
    Set GetContainer = o.Container
    Err.Clear
End Function



Public Function ComboBoxSet(cbo As ComboBox, ByVal strText As String) As Boolean

    Dim i As Long
    
    For i = 0 To cbo.ListCount - 1
    
        If UCase$(cbo.List(i)) = strText Then
            cbo.ListIndex = i
            ComboBoxSet = True
            Exit Function
        End If
    Next
    cbo.ListIndex = 0
End Function


