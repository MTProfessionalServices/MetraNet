VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CWindowObjectMapper"
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
'  DATE         : 05/xx/2001
'  DESCRIPTION  :
'  VERSION      : none.
'
' ****************************************************************************************************************************************************
Option Explicit

Private Const WEBROWSER_DECAL_LEFT_POS = 4

Private m_lngHwnd As Long

Public Function Initialize(ByVal lngHWND As Long) As Boolean

    
    m_lngHwnd = lngHWND
    
    
End Function
'
'Private Function Load(eStart As eGetWindow) As Boolean
'
'    Dim RetVal      As Long
'    Dim hwndPeer    As Long
'    Dim ClassString As String * 256
'    Dim lngChar0Pos As Long
'    Dim strClass    As String
'
'    hwndPeer = GetWindow(m_lngHwnd, eStart)
'    Do While (hwndPeer <> 0)
'
'        If hwndPeer <> 0 Then
'
'            RetVal = cWindowsModule.GetClassName(hwndPeer, ClassString, 256)
'            lngChar0Pos = InStr(ClassString, Chr$(0))
'            If (RetVal) Then
'                strClass = Left$(ClassString, lngChar0Pos - 1)
'                Debug.Print strClass & " " & hwndPeer
'            End If
'        End If
'        hwndPeer = GetWindow(hwndPeer, GW_HWNDNEXT)
'    Loop
'    Load = True
'    Debug.Print
'End Function

Public Function GetHWNDFromClass(ByVal strSearchedClass As String) As Long
    Dim objChildren     As Collection
    Dim lngChildHWND    As Variant
    Set objChildren = GetHWNDChildren(m_lngHwnd)

    For Each lngChildHWND In objChildren
    
        If strSearchedClass = GetClassFromHWND(lngChildHWND) Then
        
            GetHWNDFromClass = lngChildHWND
            Exit Function
        End If
    Next
End Function

Public Function GetClassHWNDHelper(strClass As String) As Long

    GetClassHWNDHelper = FindWindowEx(m_lngHwnd, 0, strClass, "")
End Function

Public Function GetWebBrowserHwndFromWebBrowseControl(f As Form, ByVal lngLeft As Long, ByVal lngTop As Long, ByVal lngWidth As Long, ByVal lngHeight As Long, Optional strWindowsObjectClassName As String = CWINDOW_OBJECT_MAPPER_IE_HWND_CLASS_INTERNET_EXPORER_SERVER) As Long

    Dim objWindowObjectMapper           As New CWindowObjectMapper
    Dim objWebBrowserObjectMapper       As New CWindowObjectMapper
    Dim objWebBrowserViewObjectMapper   As New CWindowObjectMapper
    Dim objInternetExplorerServer       As New CWindowObjectMapper
    Dim lngWebBrowserHWND               As Long
    Dim lngWebBrowserViewHwnd           As Long
    Dim lngInternetExplorerServer       As Long
    Dim objChildren                     As Collection
    Dim lngChildHWND                    As Variant
    
        

    
    ' Get the "Shell Embedding" that is the web browser exclude the report browser and user IFrame
    lngChildHWND = GetWebBrowserShellEmbeddingHWND(f, lngLeft, lngTop, lngWidth, lngHeight)
    Debug.Print CWINDOW_OBJECT_MAPPER_IE_HWND_CLASS_SHELL_EMBEDDING & " " & Hex(lngChildHWND)
    
    If UCase$(strWindowsObjectClassName) = UCase(CWINDOW_OBJECT_MAPPER_IE_HWND_CLASS_SHELL_EMBEDDING) Then
    
        GetWebBrowserHwndFromWebBrowseControl = lngChildHWND
        Exit Function
    End If
    
    objWebBrowserViewObjectMapper.Initialize lngChildHWND
    lngWebBrowserViewHwnd = objWebBrowserViewObjectMapper.GetHWNDFromClass(CWINDOW_OBJECT_MAPPER_IE_HWND_CLASS_SHELL_DOCOBJECT_VIEW)
    
    Debug.Print CWINDOW_OBJECT_MAPPER_IE_HWND_CLASS_SHELL_DOCOBJECT_VIEW & " " & Hex(lngWebBrowserViewHwnd)
    
    If UCase$(strWindowsObjectClassName) = UCase(CWINDOW_OBJECT_MAPPER_IE_HWND_CLASS_SHELL_DOCOBJECT_VIEW) Then
    
        GetWebBrowserHwndFromWebBrowseControl = lngWebBrowserViewHwnd
        Exit Function
    End If
    
    
    objWebBrowserViewObjectMapper.Initialize lngWebBrowserViewHwnd
    lngInternetExplorerServer = objWebBrowserViewObjectMapper.GetHWNDFromClass(strWindowsObjectClassName)
    Debug.Print "Internet Explorer_Server " & Hex(lngInternetExplorerServer)
    
    If lngInternetExplorerServer Then
    
        GetWebBrowserHwndFromWebBrowseControl = lngInternetExplorerServer
        Exit Function
    End If
    
    ' error
    
End Function

Public Function GetHWNDChildren(ByVal lngParentHWND As Long) As Collection

    Dim lngHWND As Long
    Dim objCol  As New Collection
    
    lngHWND = GetWindow(lngParentHWND, GW_CHILD)
    Do While (lngHWND <> 0)
        
        objCol.Add lngHWND
        lngHWND = GetWindow(lngHWND, GW_HWNDNEXT)
    Loop
    Set GetHWNDChildren = objCol
End Function

Public Function GetClassFromHWND(ByVal lngHWND As Long) As String

    Dim ClassString As String * 256
    Dim lngRetVal   As Long
    Dim lngChar0Pos As Long
    
    lngRetVal = cWindowsModule.GetClassName(lngHWND, ClassString, 256)
    lngChar0Pos = InStr(ClassString, Chr$(0))
    If lngChar0Pos Then
        GetClassFromHWND = Left$(ClassString, lngChar0Pos - 1)
    End If
End Function

Public Function GetWebBrowserShellEmbeddingHWND(f As Form, ByVal lngLeft As Long, ByVal lngTop As Long, ByVal lngWidth As Long, ByVal lngHeight As Long) As Long
   
    Dim objWindowObjectMapper       As New CWindowObjectMapper
    Dim objChildren                 As Collection
    Dim lngChildHWND                As Variant
    Dim ClientRect                  As RECT
    Dim WindowsRect                 As RECT
    Dim lngBrowserLeft              As Long
    
'    Debug.Assert 0
    
    objWindowObjectMapper.Initialize f.HWND
    Set objChildren = GetHWNDChildren(f.HWND)
    
    For Each lngChildHWND In objChildren

        If CWINDOW_OBJECT_MAPPER_IE_HWND_CLASS_SHELL_EMBEDDING = GetClassFromHWND(lngChildHWND) Then
        
            Debug.Print "Shell Embedding " & Hex(lngChildHWND)
            GetClientRect lngChildHWND, ClientRect
            GetWindowRect lngChildHWND, WindowsRect
            
            lngBrowserLeft = WindowsRect.Left - (f.Left / Screen.TwipsPerPixelX) - WEBROWSER_DECAL_LEFT_POS
            If mpEqual(lngLeft, lngBrowserLeft) And mpEqual(lngHeight, ClientRect.Bottom) And mpEqual(lngWidth, ClientRect.Right) Then
            
                GetWebBrowserShellEmbeddingHWND = lngChildHWND
                Exit Function
            End If
        End If
    Next
End Function

Private Function mpEqual(ByVal lngValue As Long, ByVal lngRangeValue As Long)
    mpEqual = (lngValue >= lngRangeValue - 1) And (lngValue <= lngRangeValue + 1)
End Function

' NOT_USED
Public Function GetWebBrowserHWNDFromHWNDParent(ByVal lngHWNDParent As Long, Optional strWindowsObjectClassName As String = CWINDOW_OBJECT_MAPPER_IE_HWND_CLASS_INTERNET_EXPORER_SERVER) As Long

    Dim objChildren                     As Collection
    Dim lngChildHWND                    As Variant
    Dim objWebBrowserViewObjectMapper   As New CWindowObjectMapper
    Dim lngWebBrowserViewHwnd           As Long
    Dim lngInternetExplorerServer       As Long
    
    'objWindowObjectMapper.Initialize lngHWNDParent
    
    Set objChildren = GetHWNDChildren(lngHWNDParent)
    
    For Each lngChildHWND In objChildren

        If CWINDOW_OBJECT_MAPPER_IE_HWND_CLASS_SHELL_EMBEDDING = GetClassFromHWND(lngChildHWND) Then
        
            Debug.Print CWINDOW_OBJECT_MAPPER_IE_HWND_CLASS_SHELL_EMBEDDING & " " & Hex(lngChildHWND)
            If UCase$(strWindowsObjectClassName) = UCase(CWINDOW_OBJECT_MAPPER_IE_HWND_CLASS_SHELL_EMBEDDING) Then GetWebBrowserHWNDFromHWNDParent = lngChildHWND: Exit Function
               
            objWebBrowserViewObjectMapper.Initialize lngChildHWND
            lngWebBrowserViewHwnd = objWebBrowserViewObjectMapper.GetHWNDFromClass(CWINDOW_OBJECT_MAPPER_IE_HWND_CLASS_SHELL_DOCOBJECT_VIEW)
            Debug.Print CWINDOW_OBJECT_MAPPER_IE_HWND_CLASS_SHELL_DOCOBJECT_VIEW & " " & Hex(lngWebBrowserViewHwnd)
            If UCase$(strWindowsObjectClassName) = UCase(CWINDOW_OBJECT_MAPPER_IE_HWND_CLASS_SHELL_DOCOBJECT_VIEW) Then GetWebBrowserHWNDFromHWNDParent = lngWebBrowserViewHwnd: Exit Function
            
            
            '
            'lngWebBrowserViewHwnd = lngChildHWND
            
            objWebBrowserViewObjectMapper.Initialize lngWebBrowserViewHwnd
            lngInternetExplorerServer = objWebBrowserViewObjectMapper.GetHWNDFromClass(strWindowsObjectClassName)
            Debug.Print CWINDOW_OBJECT_MAPPER_IE_HWND_CLASS_INTERNET_EXPORER_SERVER & " " & Hex(lngInternetExplorerServer)
            If lngInternetExplorerServer Then GetWebBrowserHWNDFromHWNDParent = lngInternetExplorerServer: Exit Function
            
            ' we failed
        End If
    Next
End Function
