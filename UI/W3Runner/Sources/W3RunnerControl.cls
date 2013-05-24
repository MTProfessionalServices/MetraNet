VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "W3RunnerControl"
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
'  DATE         : 12/xx/2000
'  DESCRIPTION  :
'  VERSION      : none.
'
' ****************************************************************************************************************************************************
Option Explicit

Const CLICK_UNKNOW_DECALAGE = 2

Public Enum w3rITEM_CLICK_FLAG
    w3rITEM_CLICK_FLAG_ABSOLUTE = 1
    w3rITEM_CLICK_FLAG_RIGHT_CLICK = 2
    w3rITEM_CLICK_FLAG_LEFT_CLICK = 4
    w3rITEM_CLICK_FLAG_CURRENT_POSITION = 8
    w3rITEM_CLICK_FLAG_WM_MOUSE_DOWN = 16
    w3rITEM_CLICK_FLAG_WM_MOUSE_UP = 32
End Enum

Private o                       As Object
Private m_MDMTestForm           As frmMain
Private m_booTraceMethod        As Boolean
Private m_strImage              As String
Private m_lngWebBrowserHWND     As Long

Public Name                     As String
Public ParentFrameName          As String
Public InternalType             As String
Public frm                      As frmMain

Private Sub Class_Initialize()

    g_static_booAutoFireEvent = AppOptions("AutoFireJavaScriptEvent", True)
    m_booTraceMethod = True
End Sub

Public Sub SetFocus(Optional booInternal As Boolean = False)

    On Error GoTo errmgr

    If Not booInternal Then
        
        If (m_booTraceMethod) Then frmMain.TRACE Name & ".SetFocus", w3rMETHOD
    End If
    
    o.focus
    
    If Not booInternal Then
    
        If (g_static_booAutoFireEvent) Then FireEvent "onfocus"
        If (m_booTraceMethod) Then StuffToDoForAfterEachMethod
    End If
    Exit Sub
errmgr:
    If Not booInternal Then
        FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "SetFocus"
    Else
        Err.Clear
    End If
End Sub

Public Sub Click(Optional ByVal x As Long, Optional ByVal Y As Long, Optional eFlag As w3rITEM_CLICK_FLAG = w3rITEM_CLICK_FLAG_LEFT_CLICK + w3rITEM_CLICK_FLAG_WM_MOUSE_DOWN + w3rITEM_CLICK_FLAG_WM_MOUSE_UP)

    On Error GoTo errmgr
    
    Dim varX                As Variant
    Dim varY                As Variant
    Dim nMousePosition      As Long
    Dim lngWebBrowserHWND   As Long
    Dim xx                  As Long
    Dim yy                  As Long
    Dim lngWM_BUTTONDOWN    As Long
    Dim lngWM_BUTTONUP      As Long
    Dim objWindowApi        As New cWindows
        
    If eFlag And w3rITEM_CLICK_FLAG_CURRENT_POSITION Then
        'Debug.Assert 0
        objWindowApi.cursorPos x, Y
        
        x = x - frmMain.WebBrowserLeft
        Y = Y - frmMain.WebBrowserTop
    End If
            
    If (x) Or (Y) Then
    
        If eFlag And w3rITEM_CLICK_FLAG_RIGHT_CLICK Then
        
            lngWM_BUTTONDOWN = WM_RBUTTONDOWN: lngWM_BUTTONUP = WM_RBUTTONUP
        Else
            lngWM_BUTTONDOWN = WM_LBUTTONDOWN: lngWM_BUTTONUP = WM_LBUTTONUP
        End If
        
        If (m_booTraceMethod) Then frmMain.TRACE Name & ".Click(" & x & "," & Y & "," & eFlag & ")", w3rMETHOD
            
        If eFlag And w3rITEM_CLICK_FLAG_CURRENT_POSITION Then
    
            xx = x
            yy = Y
        Else
            If eFlag And w3rITEM_CLICK_FLAG_ABSOLUTE Then
            
                varX = -CLICK_UNKNOW_DECALAGE
                varY = -CLICK_UNKNOW_DECALAGE
            Else
                If Not GetPos(varX, varY, eGetHTMLObjectPosType_LEFT_TOP) Then Err.Raise 7030, PreProcess(W3RUNNER_ERROR_07030, "NAME", Me.Name, "TYPE", VBA.TypeName(o))
            End If
                
            xx = varX + x + CLICK_UNKNOW_DECALAGE
            yy = varY + Y + CLICK_UNKNOW_DECALAGE
        End If
        
        MakeLParam nMousePosition, yy, xx
        lngWebBrowserHWND = frm.WebBrowserHWND
        
        ' Mouse Down
        If eFlag And w3rITEM_CLICK_FLAG_WM_MOUSE_DOWN Then
        
            If (m_booTraceMethod) Then
            
                frmMain.TRACE "LPARAM=" & Hex(nMousePosition) & " " & nMousePosition, w3rINTERNAL
                frmMain.TRACE Name & PreProcess(".SendMessage([HWND],[MSG],[WPARAM],[LPARAM]) ' XY=[XY]", "HWND", Hex(lngWebBrowserHWND), "MSG", "WM_LBUTTONDOWN", "WPARAM", "MK_LBUTTON", "LPARAM", "" & Hex(nMousePosition), "XY", x & " " & Y), w3rMETHOD
            End If
            g_objW3RunnerObject.SendMessage WebBrowserHWND(), lngWM_BUTTONDOWN, MK_LBUTTON, ByVal nMousePosition, False, False
        End If
        
        ' Mouse Up
        If eFlag And w3rITEM_CLICK_FLAG_WM_MOUSE_UP Then
        
            If (m_booTraceMethod) Then frmMain.TRACE Name & PreProcess(".SendMessage([HWND],[MSG],[WPARAM],[LPARAM]) ' XY=[XY]", "HWND", Hex(lngWebBrowserHWND), "MSG", "WM_LBUTTONUP", "WPARAM", "0", "LPARAM", "" & Hex(nMousePosition), "XY", x & " " & Y), w3rMETHOD
            g_objW3RunnerObject.SendMessage WebBrowserHWND(), lngWM_BUTTONUP, 0, ByVal nMousePosition, False, False
        End If
        
    Else
    
        If (m_booTraceMethod) Then frmMain.TRACE Name & ".Click", w3rMETHOD
        
        Set frmMain.ObjectToClick = o ' The click is raised in a timer event...
        frmMain.TimerObjectClick.Enabled = True
        g_lngDownLoadResponseTimeDelay = frmMain.TimerObjectClick.Interval
    End If
    If (m_booTraceMethod) Then StuffToDoForAfterEachMethod
    Exit Sub
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "Click"
End Sub

Public Property Get value(Optional ByVal lngIndex As Variant) As Variant

    On Error GoTo errmgr
    
    Dim strTypeName As String

    'If (m_booTraceMethod) Then frmMain.TRACE Name & ".Value (Get) """ & o.Value & """", w3rMETHOD
    strTypeName = UCase$(TypeName())
    
    If strTypeName = "HTMLINPUTELEMENT" And UCase$(TypeAttribut) = "CHECKBOX" Then ' By doing a loop the ComboBox.Value is not more case sensitif
    
        value = o.Checked
        
    ElseIf strTypeName = "HTMLINPUTELEMENT" And UCase$(TypeAttribut) = "RADIO" Then  ' By doing a loop the ComboBox.Value is not more case sensitif
    
        value = o.Checked
        
    ElseIf strTypeName = "HTMLSELECTELEMENT" Then
    
        If IsMissing(lngIndex) Then
            lngIndex = Me.ListIndex
        End If
        value = o.Item(CLng(lngIndex)).value
    Else
        value = o.value ' Any object including *
    End If
    If (m_booTraceMethod) Then StuffToDoForAfterEachMethod
    Exit Property
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "Value Get"
End Property

Public Property Let value(Optional ByVal lngIndex As Variant, ByVal vNewValue As Variant)

    On Error GoTo errmgr

    Dim a               As HTMLSelectElement
    Dim cboO            As HTMLOptionElement
    Dim xx              As DispHTMLDOMAttribute
    Dim i               As Long
    Dim strTypeName     As String
    
    If (m_booTraceMethod) Then frmMain.TRACE Name & ".Value = """ & vNewValue & """", w3rMETHOD
    
    strTypeName = UCase(TypeName())
    
    If strTypeName = UCase$("HTMLSelectElement") Then ' By doing a loop the ComboBox.Value is not more case sensitif
        
            Set a = o
            
            For i = 0 To a.children.Length - 1
            
                If UCase$(a.children.Item(i).value) = UCase$(vNewValue) Then
                
                    a.selectedIndex = i
                    Exit For
                End If
            Next
            If (g_static_booAutoFireEvent) Then
                FireEvent "onchange"
            End If
            
    ElseIf strTypeName = UCase$("HTMLInputElement") And UCase$(TypeAttribut) = "CHECKBOX" Then ' By doing a loop the ComboBox.Value is not more case sensitif
    
        o.Checked = CBool(vNewValue)
        If (g_static_booAutoFireEvent) Then FireEvent "onclick"
        
    ElseIf strTypeName = UCase$("HTMLInputElement") And UCase$(TypeAttribut) = "RADIO" Then ' By doing a loop the ComboBox.Value is not more case sensitif
    
        o.Checked = CBool(vNewValue)
        If (g_static_booAutoFireEvent) Then FireEvent "onclick"
    Else
        o.value = vNewValue
    End If
    If (m_booTraceMethod) Then StuffToDoForAfterEachMethod
    Exit Property
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "Value Let"
End Property

Public Function Initialize(strName As String, obj As Object, MDMTestForm As frmMain, strInternalType As String, strParentFrameName As String) As Boolean

    On Error GoTo errmgr

    Set o = obj
    Set m_MDMTestForm = MDMTestForm
    Name = strName
    ParentFrameName = strParentFrameName
    InternalType = strInternalType
    Initialize = True
    Exit Function
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "Initialize"
End Function

Public Property Get Object() As Object

    On Error GoTo errmgr
    
    'If (m_booTraceMethod) Then frmMain.TRACE Name & ".Object (Get)", w3rMETHOD
    Set Object = o
    If (m_booTraceMethod) Then StuffToDoForAfterEachMethod
    Exit Property
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "Object Get"
End Property

Public Function FireEvent(ByVal strEventName As String) As Boolean
    
    On Error GoTo errmgr
    
    If (m_booTraceMethod) Then
        frmMain.TRACE "Raise event " & Name & "." & strEventName, w3rJAVASCRIPT
    End If
    
    On Error Resume Next
    o.FireEvent strEventName
    If Err.Number Then
        frmMain.TRACE Name & "." & strEventName & " event cannot be raised. error " & GetVBErrorString(), w3rJAVASCRIPT
        Err.Clear
    End If
    On Error GoTo errmgr
    
    If (m_booTraceMethod) Then StuffToDoForAfterEachMethod
    FireEvent = True
    Exit Function
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "FireEvent"
End Function

Public Property Get ListIndex() As Long

    On Error GoTo errmgr
    
    'If (m_booTraceMethod) Then frmMain.TRACE Name & ".ListIndex (Get) " & o.selectedIndex, w3rMETHOD
    ListIndex = o.selectedIndex
    If (m_booTraceMethod) Then StuffToDoForAfterEachMethod
    Exit Property
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "ListIndex Get"
End Property

Public Property Let ListIndex(ByVal vNewValue As Long)

    On Error GoTo errmgr
    
    If (m_booTraceMethod) Then frmMain.TRACE Name & ".ListIndex = " & vNewValue, w3rMETHOD
    o.selectedIndex = vNewValue
    If (m_booTraceMethod) Then StuffToDoForAfterEachMethod
    Exit Property
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "ListIndex Let"
End Property

Public Property Get Text(Optional strTextType As String = "innerText") As String

    
    On Error GoTo errmgr
    
    Dim strText As String
    
    If Len(PassWordChar) Then
        On Error GoTo 0
        Err.Raise vbObjectError + 7048, App.EXEName, W3RUNNER_ERROR_07048
    End If
    
    Select Case InternalType
        
        Case "COMBOBOX", "LISTBOX"
            If (Me.ListIndex <> -1) Then strText = Me.List(Me.ListIndex)
                
        Case "TEXTBOX", "HIDDEN", "*" ' * for no type
            strText = o.value
            
        Case Else
            
            Select Case UCase$(strTextType)
            
                Case "INNERTEXT": strText = o.innerText
                Case "OUTERTEXT": strText = o.outerText
                Case "INNERHTML": strText = o.innerHTML
                Case "OUTERHTML": strText = o.outerHTML
            End Select
    End Select
    
    'If (m_booTraceMethod) Then frmMain.TRACE Name & ".Text (Get) " & strText, w3rMETHOD
    Text = strText
    If (m_booTraceMethod) Then StuffToDoForAfterEachMethod
    Exit Property
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "Text Get"
End Property

Public Property Let Text(Optional strTextType As String = "innerText", ByVal vNewValue As String)

    On Error GoTo errmgr
    
    Dim i                           As Long
    Dim m_booPreviousTraceMethod    As Boolean
    
    If (m_booTraceMethod) Then frmMain.TRACE Name & ".Text = """ & vNewValue & """", w3rMETHOD
    
    ' COMBOBOX Cases
    If UCase$(TypeName()) = "HTMLSELECTELEMENT" Then ' Simulate the VB Set Text on a combo box
        
        m_booPreviousTraceMethod = m_booTraceMethod ' Save and cancel the trace mode, we will use the method ListCount and List for an internal purpose...
        m_booTraceMethod = False
        
        For i = 0 To Me.ListCount - 1
        
            If (UCase$(Me.List(i)) = UCase$(vNewValue)) Then  ' Comparaison is not case sensitive...
            
                m_booTraceMethod = m_booPreviousTraceMethod
                Me.ListIndex = i
                Exit Property
            End If
        Next
        frmMain.TRACE PreProcess(W3RUNNER_ERROR_07010, "ITEM", vNewValue, "NAME", Name), w3rERROR
    Else
        ' Any Other Object - No need to support *
        o.value = vNewValue
    End If
    If (m_booTraceMethod) Then StuffToDoForAfterEachMethod
    Exit Property
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "Text Let"
End Property

Public Function ListCount() As Long

    On Error GoTo errmgr
    
    'If (m_booTraceMethod) Then frmMain.TRACE Name & ".ListCount (Get) " & o.childNodes.Length, w3rMETHOD
    
    ListCount = o.childNodes.Length
    
    If (m_booTraceMethod) Then StuffToDoForAfterEachMethod
    
    Exit Function
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "ListCount Get"
End Function

Public Property Get List(ByVal lngIndex As Long) As String

    On Error GoTo errmgr
    
    'If (m_booTraceMethod) Then frmMain.TRACE Name & ".List(" & lngIndex & ") (Get) " & o.Item(lngIndex).Text, w3rMETHOD
    
    List = o.Item(lngIndex).Text
    
    If (m_booTraceMethod) Then StuffToDoForAfterEachMethod
    
    Exit Property
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "List Get"
End Property

Public Function TypeName() As String
    On Error GoTo errmgr
    
    TypeName = VBA.TypeName(o)
    If (m_booTraceMethod) Then StuffToDoForAfterEachMethod
    Exit Function
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "TypeName"
End Function

Public Function TypeAttribut() As String

    On Error GoTo errmgr
    
    TypeAttribut = g_objHelper.GetHTMLObjectProperty(o, "type")
    If (m_booTraceMethod) Then StuffToDoForAfterEachMethod
Exit Function
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "TypeAttribut"
End Function



Public Function GetPos(ByRef x As Variant, ByRef Y As Variant, eType As eGetHTMLObjectPosType) As Boolean

    Dim lngX As Long, lngY As Long
    
    On Error GoTo errmgr
    
    If (GetHTMLObjectPos(lngX, lngY, frm, o, ParentFrameName, eType)) Then
    
        GetPos = True
        x = lngX
        Y = lngY
    End If
Exit Function
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "GetPos"
End Function

Public Property Get Item(ByVal varKey As Variant) As Variant
Attribute Item.VB_UserMemId = 0
    
    Dim i       As Long
    Dim strKey  As String
    Dim objItem As Object
    
    On Error GoTo errmgr
    
    Set Item = Nothing
    
    If (m_booTraceMethod) Then
        frmMain.TRACE PreProcess("[NAME].Item([DC][VARKEY][DC])", "NAME", Name, "VARKEY", varKey, "DC", IIf(IsNumeric(varKey), "", """")), w3rMETHOD
    End If
    
    If IsNumeric(varKey) Then
    
        Set objItem = o.childNodes(CLng(varKey))
        Set Item = objItem
        SetMouse True, objItem
    Else
        strKey = UCase$(varKey)
        
        For i = 0 To o.childNodes.Length - 1
        
            If UCase$(g_objHelper.GetHTMLObjectProperty(o.childNodes(i), "name")) = strKey Then
            
                Set objItem = o.childNodes(i)
                Set Item = objItem
                SetMouse True, objItem
                Exit Property
            End If
        Next
    End If
Exit Property
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "Item"
End Property

' Get or set the image file name associated with a map object
' no documented
Public Property Get Image() As String
    Image = m_strImage
End Property

Public Property Let Image(ByVal vNewValue As String)
    m_strImage = vNewValue
End Property

Private Sub Class_Terminate()
    Debug.Print "Control.Destructor"
End Sub

' Not documented
Public Function SetMouse(Optional ByVal booInternal As Boolean = False, Optional varAreaObject As Variant) As Boolean

    Dim objDummy  As Object
    Dim objImage  As W3RunnerControl
    Dim strCoords As String
    Dim varCoords As Variant
    Dim lngDecalX As Long
    Dim lngDecalY As Long
    
    On Error GoTo errmgr
    
    If (m_booTraceMethod) And (Not booInternal) Then frmMain.TRACE Name & PreProcess(".SetMouse()"), w3rMETHOD
    
    If IsMissing(varAreaObject) Then

        If AppOptions("MoveMouseCursor", False) And (InternalType <> "HIDDEN") Then 'And (strType <> "MAP")
        
            If (InternalType = "MAP") Then ' <MAP> Case
                
                If Len(Me.Image) Then
                    
                    Set objImage = m_MDMTestForm.m_objW3RunnerPage.Controls(Me.Image, "Image", Me.ParentFrameName)    ' Force to look up the associated object
                End If
            Else
                SetHTMLObjectCursorPos m_MDMTestForm, o, ParentFrameName
            End If
        End If
        
    Else ' <AREA> CASE
        If Len(Me.Image) Then

            Set objImage = m_MDMTestForm.m_objW3RunnerPage.Controls(Me.Image, "Image", Me.ParentFrameName)    ' Force to look up the associated object
            
            Select Case UCase$(g_objHelper.GetHTMLObjectProperty(varAreaObject, "shape"))
            
                Case "CIRCLE", "POLY"
                    '                                                0  1  2   3
                    '<area name="RightBottom" shape="circle" coords="75,75,25"    href="mapdemo2.asp?state=RightBottom">
                
                    strCoords = g_objHelper.GetHTMLObjectProperty(varAreaObject, "coords")
                    varCoords = Split(strCoords, ",")
                    lngDecalX = varCoords(0)
                    lngDecalY = varCoords(1)
                    SetHTMLObjectCursorPos m_MDMTestForm, objImage.Object, ParentFrameName, lngDecalX, lngDecalY
                
                Case "RECT"
                    '                                                0  1  2   3
                    '<area name="LeftBottom"  shape="rect"   coords="0,50,50,100" href="mapdemo2.asp?state=LeftBottom">
                
                    strCoords = g_objHelper.GetHTMLObjectProperty(varAreaObject, "coords")
                    varCoords = Split(strCoords, ",")
                    lngDecalX = varCoords(0) + ((varCoords(2) - varCoords(0)) / 2)
                    lngDecalY = varCoords(1) + ((varCoords(3) - varCoords(1)) / 2)
                    SetHTMLObjectCursorPos m_MDMTestForm, objImage.Object, ParentFrameName, lngDecalX, lngDecalY
                    
            End Select
            If (m_booTraceMethod) Then StuffToDoForAfterEachMethod
            
        End If
    End If
Exit Function
errmgr:

    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "SetMouse"
End Function

' Not documented
Public Function Contains(ByVal strValue As String, Optional strContainsCompareMode As String = "Text") As Long

    Dim i               As Long
    Dim booTraceMethod  As Boolean
    Dim booEqual        As Boolean
        
    On Error GoTo errmgr
    
    booTraceMethod = m_booTraceMethod
    m_booTraceMethod = False
    Contains = -1
    
    Select Case Me.InternalType
    
        Case "COMBOBOX", "LISTBOX"
        
            For i = 0 To Me.ListCount - 1
            
                Select Case strContainsCompareMode
                
                    Case "VALUE"
                    
                        booEqual = UCase$(Me.value(i)) = UCase$(strValue)
                        
                    Case "TEXT"
                    
                        booEqual = UCase$(Me.List(i)) = UCase$(strValue)
                End Select
                                
                If booEqual Then
                
                    Contains = i
                    GoTo TheExit
                End If
            Next
    End Select
TheExit:
    If (m_booTraceMethod) Then StuffToDoForAfterEachMethod
    m_booTraceMethod = booTraceMethod
Exit Function
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "Contains"
    GoTo TheExit
End Function


Public Function SendKeys(ByVal strKeys As String, Optional booWait As Boolean = False, Optional booNewProcess As Boolean = False, Optional lngTimeToWait As Long = 1) As Boolean
    
    On Error GoTo errmgr

    Me.SetFocus
    W3RunnerMod.Wait 0.1
    
    SendKeys = g_objW3RunnerObject.SendKeys(strKeys, booWait, booNewProcess, lngTimeToWait, "Page")
    
    If (m_booTraceMethod) Then StuffToDoForAfterEachMethod
Exit Function
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "SendKeys"
End Function

Public Property Get Attributes(ByVal strName As String) As String

    On Error GoTo errmgr

    Attributes = "" & o.getAttribute(strName)
    If (m_booTraceMethod) Then StuffToDoForAfterEachMethod
Exit Property
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "Attributes"
End Property

Public Function SendChars(ByVal strChars As String, Optional ByVal lngLPARAM As Long = 0, Optional ByVal booPost As Boolean = True) As Boolean

    Dim objWin  As New cWindows
    Dim i       As Long
    Dim lngHWND As Long
    
    On Error GoTo errmgr
    
    Me.SetFocus
    W3RunnerMod.Wait 0.001

    If (m_booTraceMethod) Then frmMain.TRACE Name & PreProcess(".SendChars [DC][VALUE][DC]", "VALUE", strChars, "DC", """"), w3rMETHOD
    
    For i = 1 To Len(strChars)
    
        Select Case Mid(strChars, i, 1)
            Case vbTab
                g_objW3RunnerObject.SendMessage WebBrowserHWND(), WM_KEYDOWN, Asc(Mid(strChars, i, 1)), CLng("&H000F0001"), booPost, Not m_booTraceMethod
                DoEvents
                g_objW3RunnerObject.SendMessage WebBrowserHWND(), WM_KEYUP, Asc(Mid(strChars, i, 1)), CLng("&HC00F0001"), booPost, Not m_booTraceMethod
                DoEvents
                
            Case Else
                g_objW3RunnerObject.SendMessage WebBrowserHWND(), WM_CHAR, Asc(Mid(strChars, i, 1)), lngLPARAM, booPost, Not m_booTraceMethod
        End Select
    Next
    If (m_booTraceMethod) Then StuffToDoForAfterEachMethod
    SendChars = True
Exit Function
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "SendChars"
End Function

Private Property Get WebBrowserHWND() As Long

    On Error GoTo errmgr

    If m_lngWebBrowserHWND = 0 Then
    
        m_lngWebBrowserHWND = m_MDMTestForm.m_objW3RunnerPage.WebBrowserHWND
    End If
    WebBrowserHWND = m_lngWebBrowserHWND
Exit Property
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "WebBrowserHWND"
End Property

Private Function UnCrypte(ByVal strString As String) As String
    
    If Not g_objCryptor.DeCrypte(strString, UnCrypte) Then
    
        Err.Raise vbObjectError + 7047, App.EXEName, PreProcess(W3RUNNER_ERROR_07047, "STRING", strString)
    End If
End Function

Public Function PassWordChar() As String
    If UCase$(Me.Attributes("Type")) = "PASSWORD" Then
        PassWordChar = "*"
    End If
End Function

Public Property Let SecureText(ByVal vNewValue As Variant)

    Dim booTraceMethodBackUp As Boolean
    
    ' Trace
    If (m_booTraceMethod) Then frmMain.TRACE Name & ".SecureText = """ & vNewValue & """", w3rMETHOD
    
    ' Stop the tracing and call the Text property with the uncrypted value
    booTraceMethodBackUp = m_booTraceMethod
    m_booTraceMethod = False
    Text = UnCrypte(vNewValue)
    
    ' Restore the tracing state
    m_booTraceMethod = booTraceMethodBackUp
End Property

Public Property Get ActiveX() As Variant

On Error GoTo errmgr
    
    Set ActiveX = o.Object
    If (m_booTraceMethod) Then StuffToDoForAfterEachMethod
    Exit Property
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "ActiveX Get"
End Property



' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Function FindText(ByVal strSearchedText As String, Optional ByVal strTextType As String = "innerText", Optional ByVal booIgnoreCase As Boolean = True, Optional booRegularExp As Boolean = False) As Long

    On Error GoTo errmgr
    
    frmMain.TRACE PreProcess("[NAME].FindText([DC][STRSEARCHEDTEXT][DC],[DC][STRTEXTTYPE][DC],[BOOIGNORECASE],[REGEXP])", "DC", """", "STRSEARCHEDTEXT", strSearchedText, "STRTEXTTYPE", strTextType, "BOOIGNORECASE", booIgnoreCase, "REGEXP", booRegularExp, "NAME", Name), w3rMETHOD
    
    Dim strText     As String
    Dim objRegExp   As New CRegExp
    
    
    Select Case UCase$(strTextType)
        Case "INNERTEXT": strText = Object.innerText
        Case "OUTERTEXT": strText = Object.outerText
        Case "INNERHTML": strText = Object.innerHTML
        Case "OUTERHTML": strText = Object.outerHTML
    End Select
    
    If booRegularExp Then
    
        objRegExp.IgnoreCase = booIgnoreCase
        objRegExp.Pattern = strSearchedText
        FindText = objRegExp.Execute(strText)
    Else
        If (booIgnoreCase) Then
            FindText = InStr(UCase(strText), UCase(strSearchedText))
        Else
            FindText = InStr(strText, strSearchedText)
            
        End If
    End If
    Exit Function
errmgr:
    FShowError W3RUNNER_ERROR_07003 & " " & GetVBErrorString(), Me, "FindText"
End Function

