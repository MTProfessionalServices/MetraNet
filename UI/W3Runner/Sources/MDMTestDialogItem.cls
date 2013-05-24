VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "FredRunnerControl"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Const CLICK_UNKNOW_DECALAGE = 2

Public Enum w3rITEM_CLICK_FLAG
    w3rITEM_CLICK_FLAG_NONE = 0
    w3rITEM_CLICK_FLAG_ABSOLUTE = 1
End Enum

Private o               As Object
Private m_MDMTestForm   As frmMain
Private m_booTraceMethod As Boolean

Public Name             As String
Public ParentFrameName  As String
Public InternalType     As String

Public frm              As frmMain

Private Sub Class_Initialize()
    g_static_booAutoFireEvent = AppOptions("AutoFireJavaScriptEvent", True)
    m_booTraceMethod = True
End Sub

Public Sub SetFocus()

    On Error GoTo ErrMgr

    If (m_booTraceMethod) Then frmMain.TRACE Name & ".SetFocus", w3rMETHOD
    o.focus
    If (g_static_booAutoFireEvent) Then FireEvent "onfocus"
    If (m_booTraceMethod) Then StuffToDoForAfterEachMethod
    Exit Sub
ErrMgr:
    FShowError FREDRUNNER_ERROR_07003 & " " & GetVBErrorString(), "FredRunnerControl.cls", "SetFocus"
End Sub

Public Sub Click(Optional ByVal x As Long, Optional ByVal Y As Long, Optional eFlag As w3rITEM_CLICK_FLAG = w3rITEM_CLICK_FLAG_NONE)

    On Error GoTo ErrMgr
    
    Dim varX                As Variant
    Dim varY                As Variant
    Dim nMousePosition      As Long
    Dim lngWebBrowserHWND   As Long
    Dim xx                  As Long
    Dim yy                  As Long
    
    If (x) Or (Y) Then
    
        If eFlag And w3rITEM_CLICK_FLAG_ABSOLUTE Then
            varX = -CLICK_UNKNOW_DECALAGE
            varY = -CLICK_UNKNOW_DECALAGE
        Else
            If Not GetPos(varX, varY, eGetHTMLObjectPosType_LEFT_TOP) Then
                Err.Raise 7030, PreProcess(FREDRUNNER_ERROR_07030, "NAME", Me.Name, "TYPE", VBA.TypeName(o))
            End If
        End If
        
        If (m_booTraceMethod) Then
            frmMain.TRACE Name & ".Click(" & x & "," & Y & ")", w3rMETHOD
        End If
        
        xx = varX + x + CLICK_UNKNOW_DECALAGE
        yy = varY + Y + CLICK_UNKNOW_DECALAGE
        
        MakeLParam nMousePosition, yy, xx
        
        lngWebBrowserHWND = frm.WebBrowserHWND
        
        If (m_booTraceMethod) Then
        
            frmMain.TRACE "LPARAM=" & Hex(nMousePosition) & " " & nMousePosition, w3rINTERNAL
            frmMain.TRACE Name & PreProcess(".SendMessage([HWND],[MSG],[WPARAM],[LPARAM]) ' XY=[XY]", "HWND", Hex(lngWebBrowserHWND), "MSG", "WM_LBUTTONDOWN", "WPARAM", "MK_LBUTTON", "LPARAM", "" & Hex(nMousePosition), "XY", x & " " & Y), w3rMETHOD
        End If
        
        SendMessage lngWebBrowserHWND, WM_LBUTTONDOWN, MK_LBUTTON, ByVal nMousePosition
        
        If (m_booTraceMethod) Then frmMain.TRACE Name & PreProcess(".SendMessage([HWND],[MSG],[WPARAM],[LPARAM]) ' XY=[XY]", "HWND", Hex(lngWebBrowserHWND), "MSG", "WM_LBUTTONUP", "WPARAM", "0", "LPARAM", "" & Hex(nMousePosition), "XY", x & " " & Y), w3rMETHOD
        SendMessage frm.WebBrowserHWND, WM_LBUTTONUP, 0, ByVal nMousePosition

    Else
    
        If (m_booTraceMethod) Then frmMain.TRACE Name & ".Click", w3rMETHOD
        
        Set frmMain.ObjectToClick = o ' The click is raised in a timer event...
        frmMain.TimerObjectClick.Enabled = True
    End If
    If (m_booTraceMethod) Then StuffToDoForAfterEachMethod
    Exit Sub
ErrMgr:
    FShowError FREDRUNNER_ERROR_07003 & " " & GetVBErrorString(), "FredRunnerControl.cls", "Click"
End Sub

Public Property Get Value() As Variant

    On Error GoTo ErrMgr
    
    Dim strTypeName As String

    If (m_booTraceMethod) Then frmMain.TRACE Name & ".Value (Get) """ & o.Value & """", w3rMETHOD
    strTypeName = UCase(TypeName())
    
    If strTypeName = UCase$("HTMLInputElement") And UCase$(TypeAttribut) = "CHECKBOX" Then ' By doing a loop the ComboBox.Value is not more case sensitif
    
        Value = o.Checked
        
    ElseIf strTypeName = UCase$("HTMLInputElement") And UCase$(TypeAttribut) = "RADIO" Then ' By doing a loop the ComboBox.Value is not more case sensitif
    
        Value = o.Checked
        
    Else
        Value = o.Value
    End If
    If (m_booTraceMethod) Then StuffToDoForAfterEachMethod
    Exit Property
ErrMgr:
    FShowError FREDRUNNER_ERROR_07003 & " " & GetVBErrorString(), "FredRunnerControl.cls", "Value Get"
End Property

Public Property Let Value(ByVal vNewValue As Variant)

    On Error GoTo ErrMgr

    Dim a               As HTMLSelectElement
    Dim cboO            As HTMLOptionElement
    Dim xx              As DispHTMLDOMAttribute
    Dim i               As Long
    Dim strTypeName     As String
    
    If (m_booTraceMethod) Then frmMain.TRACE Name & ".Value = """ & vNewValue & """", w3rMETHOD
    
    strTypeName = UCase(TypeName())
    
    If strTypeName = UCase$("HTMLSelectElement") Then ' By doing a loop the ComboBox.Value is not more case sensitif
        
            Set a = o
            
            For i = 0 To a.Children.Length - 1
            
                If UCase$(a.Children.Item(i).Value) = UCase$(vNewValue) Then
                
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
        o.Value = vNewValue
    End If
    If (m_booTraceMethod) Then StuffToDoForAfterEachMethod
    Exit Property
ErrMgr:
    FShowError FREDRUNNER_ERROR_07003 & " " & GetVBErrorString(), "FredRunnerControl.cls", "Value Let"
End Property

Public Function Initialize(strName As String, obj As Object, MDMTestForm As frmMain, strInternalType As String, strParentFrameName As String) As Boolean

    On Error GoTo ErrMgr

    Set o = obj
    Set m_MDMTestForm = MDMTestForm
    Name = strName
    ParentFrameName = strParentFrameName
    InternalType = strInternalType
    Initialize = True
    
    Exit Function
ErrMgr:
    FShowError FREDRUNNER_ERROR_07003 & " " & GetVBErrorString(), "FredRunnerControl.cls", "Initialize"
End Function

Public Property Get Object() As Object

    On Error GoTo ErrMgr
    
    If (m_booTraceMethod) Then frmMain.TRACE Name & ".Object (Get)", w3rMETHOD
    Set Object = o
    If (m_booTraceMethod) Then StuffToDoForAfterEachMethod
    Exit Property
ErrMgr:
    FShowError FREDRUNNER_ERROR_07003 & " " & GetVBErrorString(), "FredRunnerControl.cls", "Object"
End Property

Public Function FireEvent(ByVal strEventName As String) As Boolean
    
    On Error GoTo ErrMgr
    
    If (m_booTraceMethod) Then
        frmMain.TRACE "Raise event " & Name & "." & strEventName, w3rJAVASCRIPT
    End If
    
    On Error Resume Next
    o.FireEvent strEventName
    If Err.Number Then
        frmMain.TRACE Name & "." & strEventName & " event cannot be raised. error " & GetVBErrorString(), w3rJAVASCRIPT
        Err.Clear
    End If
    On Error GoTo ErrMgr
    
    If (m_booTraceMethod) Then StuffToDoForAfterEachMethod
    FireEvent = True
    Exit Function
ErrMgr:
    FShowError FREDRUNNER_ERROR_07003 & " " & GetVBErrorString(), "FredRunnerControl.cls", "Object"
End Function

Public Property Get ListIndex() As Long

    On Error GoTo ErrMgr
    
    If (m_booTraceMethod) Then frmMain.TRACE Name & ".ListIndex (Get) " & o.selectedIndex, w3rMETHOD
    ListIndex = o.selectedIndex
    If (m_booTraceMethod) Then StuffToDoForAfterEachMethod
    Exit Property
ErrMgr:
    FShowError FREDRUNNER_ERROR_07003 & " " & GetVBErrorString(), "FredRunnerControl.cls", "ListIndex"
End Property

Public Property Let ListIndex(ByVal vNewValue As Long)

    On Error GoTo ErrMgr
    
    If (m_booTraceMethod) Then frmMain.TRACE Name & ".ListIndex = " & vNewValue, w3rMETHOD
    o.selectedIndex = vNewValue
    If (m_booTraceMethod) Then StuffToDoForAfterEachMethod
    Exit Property
ErrMgr:
    FShowError FREDRUNNER_ERROR_07003 & " " & GetVBErrorString(), "FredRunnerControl.cls", "ListIndex"
End Property

Public Function SendKeys(ByVal strKeys As String, Optional booWait As Boolean = True) As Boolean
    Me.SetFocus
    FredRunnerMod.Wait 0.001
    
    If (m_booTraceMethod) Then
        frmMain.TRACE PreProcess("[NAME].SendKeys([DC][STRKEYS][DC],[BOOWAIT])", "NAME", Name, "STRKEYS", strKeys, "BOOWAIT", booWait, "DC", """"), w3rMETHOD
    End If
    
    VBA.SendKeys strKeys, booWait
    If (m_booTraceMethod) Then StuffToDoForAfterEachMethod
End Function

Public Property Get Text() As String

    On Error GoTo ErrMgr
    
    Dim strText As String
    
    Select Case InternalType
        Case "COMBOBOX"
            If (Me.ListIndex <> -1) Then strText = Me.List(Me.ListIndex)
                
        Case "TEXTBOX"
            strText = o.Value
    End Select
    
    If (m_booTraceMethod) Then frmMain.TRACE Name & ".Text (Get) " & strText, w3rMETHOD
    Text = strText
    If (m_booTraceMethod) Then StuffToDoForAfterEachMethod
    Exit Property
ErrMgr:
    FShowError FREDRUNNER_ERROR_07003 & " " & GetVBErrorString(), "FredRunnerControl.cls", "Text"
End Property

Public Property Let Text(ByVal vNewValue As String)

    On Error GoTo ErrMgr
    
    Dim i                           As Long
    Dim m_booPreviousTraceMethod    As Boolean
    
    If (m_booTraceMethod) Then frmMain.TRACE Name & ".Text = """ & vNewValue & """", w3rMETHOD
    
    If UCase$(TypeName()) = UCase$("HTMLSelectElement") Then ' Simulate the VB Set Text on a combo box
        
        m_booPreviousTraceMethod = m_booTraceMethod ' Save and cancel the trace mode, we will use the method ListCount and List for an internal purpose...
        m_booTraceMethod = False
        
        For i = 0 To Me.ListCount - 1
        
            If (UCase$(Me.List(i)) = UCase$(vNewValue)) Then  ' Comparaison is not case sensitive...
            
                m_booTraceMethod = m_booPreviousTraceMethod
                Me.ListIndex = i
                Exit Property
            End If
        Next
        Err.Raise 7010, App.EXEName, PreProcess(FREDRUNNER_ERROR_07010, "ITEM", vNewValue, "NAME", Name)
    Else
        o.Value = vNewValue
    End If
    If (m_booTraceMethod) Then StuffToDoForAfterEachMethod
    Exit Property
ErrMgr:
    FShowError FREDRUNNER_ERROR_07003 & " " & GetVBErrorString(), "FredRunnerControl.cls", "Text"
End Property

Public Function ListCount() As Long

    On Error GoTo ErrMgr
    
    If (m_booTraceMethod) Then frmMain.TRACE Name & ".ListCount (Get) " & o.childNodes.Length, w3rMETHOD
    
    ListCount = o.childNodes.Length
    
    If (m_booTraceMethod) Then StuffToDoForAfterEachMethod
    
    Exit Function
ErrMgr:
    FShowError FREDRUNNER_ERROR_07003 & " " & GetVBErrorString(), "FredRunnerControl.cls", "ListCount"
End Function

Public Property Get List(ByVal lngIndex As Long) As String

    On Error GoTo ErrMgr
    
    If (m_booTraceMethod) Then frmMain.TRACE Name & ".List(" & lngIndex & ") (Get) " & o.Item(lngIndex).Text, w3rMETHOD
    
    List = o.Item(lngIndex).Text
    
    If (m_booTraceMethod) Then StuffToDoForAfterEachMethod
    
    Exit Property
ErrMgr:
    FShowError FREDRUNNER_ERROR_07003 & " " & GetVBErrorString(), "FredRunnerControl.cls", "List"
End Property

Public Function TypeName() As String
    TypeName = VBA.TypeName(o)
    If (m_booTraceMethod) Then StuffToDoForAfterEachMethod
End Function

Public Function TypeAttribut() As String
    TypeAttribut = GetHTMLObjectProperty(o, "type")
    If (m_booTraceMethod) Then StuffToDoForAfterEachMethod
End Function

Private Function StuffToDoForAfterEachMethod() As Boolean
    GlobalDoEvents
    RunSlowMode
End Function

Public Property Get Checked() As Variant
    MsgBox "The Property checked has been replace by the property value. Please do a search replace in all your scripts."
End Property

Public Property Let Checked(ByVal vNewValue As Variant)
    MsgBox "The Property checked has been replace by the property value. Please do a search replace in all your scripts."
End Property


Public Function GetPos(ByRef x As Variant, ByRef Y As Variant, eType As eGetHTMLObjectPosType) As Boolean
    Dim lngX As Long, lngY As Long
    If (GetHTMLObjectPos(lngX, lngY, frm, o, ParentFrameName, eType)) Then
        GetPos = True
        x = lngX
        Y = lngY
    End If
End Function

Public Property Get Property(ByVal strPropertyName As String) As Variant

    Property = GetHTMLObjectProperty(o, strPropertyName)
End Property




Public Property Get Item(ByVal varKey As Variant) As Variant
Attribute Item.VB_UserMemId = 0
 
'    Dim m As HTMLMapElement
'    Dim ma As HTMLAreaElement
'    Set ma = m.childNodes(0)
    
    Dim i       As Long
    Dim strKey  As String
    
    Set Item = Nothing
    
    If (m_booTraceMethod) Then
        frmMain.TRACE PreProcess("[NAME].Item([DC][VARKEY][DC])", "NAME", Name, "VARKEY", varKey, "DC", IIf(IsNumeric(varKey), "", """")), w3rMETHOD
    End If
    
    If IsNumeric(varKey) Then
        Set Item = o.childNodes(CLng(varKey))
    Else
        strKey = UCase$(varKey)
        
        For i = 0 To o.childNodes.Length - 1
        
            If UCase$(GetHTMLObjectProperty(o.childNodes(i), "name")) = strKey Then
            
                Set Item = o.childNodes(i)
                
'                If AppOptions("MoveMouseCursor", False) Then
'                    SetHTMLObjectCursorPos m_MDMTestForm, o.childNodes(i), ParentFrameName
'                End If
                Exit Property
            End If
        Next
    End If
End Property

'Public Sub Scroll(Optional ByVal strDirection As String)
'
'    On Error GoTo ErrMgr
'
'    Dim b As HTMLBody
'
''empty string Component is inside the client area of the object.
''outside Component is outside the bounds of the object.
''scrollbarDown      Down scroll arrow is at the specified location.
''scrollbarHThumb    Horizontal scroll thumb or box is at the specified location.
''scrollbarLeft      Left scroll arrow is at the specified location.
''scrollbarPageDown  Page-down scroll bar shaft is at the specified location.
''scrollbarPageLeft  Page-left scroll bar shaft is at the specified location.
''scrollbarPageRight Page-right scroll bar shaft is at the specified location.
''scrollbarPageUp    Page-up scroll bar shaft is at the specified location.
''scrollbarRight     Right scroll arrow is at the specified location.
''scrollbarUp        Up scroll arrow is at the specified location.
''scrollbarVThumb    Vertical scroll thumb or box is at the specified location.
''handleBottom       Bottom sizing handle is at the specified location.
''handleBottomLeft   Lower-left sizing handle is at the specified location.
''handleBottomRight  Lower-right sizing handle is at the specified location.
''handleLeft         Left sizing handle is at the specified location.
''handleRight        Right sizing handle is at the specified location.
''handleTop          Top sizing handle is at the specified location.
''handleTopLeft      Upper-left sizing handle is at the specified location.
''handleTopRight     Upper-right sizing handle is at the specified location.
'
'    If (m_booTraceMethod) Then frmMain.TRACE Name & ".Scroll(""" & strDirection & """)", w3rMETHOD
'    o.doScroll strDirection
'    If (m_booTraceMethod) Then StuffToDoForAfterEachMethod
'    Exit Sub
'ErrMgr:
'    FShowError FREDRUNNER_ERROR_07003 & " " & GetVBErrorString(), "FredRunnerControl.cls", "Scroll"
'End Sub
