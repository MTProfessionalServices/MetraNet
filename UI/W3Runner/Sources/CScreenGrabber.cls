VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CScreenGrabber"
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
'  DATE         : 06/xx/2001
'  DESCRIPTION  :
'  VERSION      : none.
'
' ****************************************************************************************************************************************************
Option Explicit

Public Enum eGRAB_MODE
    eGRAB_MODE_FULL_SCREEN = 1
    eGRAB_MODE_WINDOW = 2
End Enum

Private Declare Function BitBlt Lib "gdi32" (ByVal hDCDest As Long, ByVal XDest As Long, ByVal YDest As Long, ByVal nWidth As Long, ByVal nHeight As Long, ByVal hDCSrc As Long, ByVal XSrc As Long, ByVal YSrc As Long, ByVal dwRop As Long) As Long
Private Declare Function GetDesktopWindow Lib "user32" () As Long
Private Declare Function GetWindowDC Lib "user32" (ByVal HWND As Long) As Long
Private Declare Function ReleaseDC Lib "user32" (ByVal HWND As Long, ByVal hdc As Long) As Long

Public Function Grab(ByVal eGrabMode As eGRAB_MODE, ByVal strFileName As String, Optional ByVal lngHWND As Long, Optional ByVal lngWidth As Long = 0, Optional ByVal lngHeight As Long = 0, Optional ByVal lngLeft As Long = 0, Optional ByVal lngTop As Long = 0) As Boolean

    Select Case eGrabMode
        Case eGRAB_MODE_FULL_SCREEN
            InitPicture Screen.Width, Screen.Height
            Grab = GrabScreen(strFileName)
            
        Case eGRAB_MODE_WINDOW
            InitPicture lngWidth * Screen.TwipsPerPixelX, lngHeight * Screen.TwipsPerPixelY
            Grab = GrabWindow(lngHWND, strFileName, lngWidth, lngHeight, lngLeft, lngTop)
    End Select
End Function

Private Function GrabScreen(ByVal strFileName As String) As Boolean

    Dim WidthDesk   As Long
    Dim HeightDesk  As Long
    
    WidthDesk = Screen.Width \ Screen.TwipsPerPixelX
    HeightDesk = Screen.Height \ Screen.TwipsPerPixelY
    GrabScreen = GrabStdWindow(GetDesktopWindow(), 0, 0, WidthDesk, HeightDesk, strFileName)
End Function

Public Function GrabWindow(ByVal lngHWND As Long, ByVal strFileName As String, Optional ByVal lngWidth As Long = 0, Optional ByVal lngHeight As Long = 0, Optional ByVal lngLeft As Long = 0, Optional ByVal lngTop As Long = 0) As Boolean

    GrabWindow = GrabStdWindow(lngHWND, lngLeft, lngTop, lngWidth, lngHeight, strFileName)
End Function

Public Function GrabStdWindow(ByVal lngHWND As Long, ByVal lngLeft As Long, ByVal lngTop As Long, ByVal lngWidth As Long, ByVal lngHeight As Long, ByVal strFileName As String) As Boolean

    'get the desktop handle and display context
    Dim hDCDesk  As Long
    
    hDCDesk = GetWindowDC(lngHWND)
    
    'copy the desktop to the picture box
    frmScreenGrabber.Picture1.Width = lngWidth * Screen.TwipsPerPixelX
    frmScreenGrabber.Picture1.Height = lngWidth * Screen.TwipsPerPixelY
    DoEvents
    Call BitBlt(frmScreenGrabber.Picture1.hdc, 0, 0, lngWidth, lngHeight, hDCDesk, lngLeft, lngTop, vbSrcCopy)
    Call ReleaseDC(lngHWND, hDCDesk)
    
    SavePicture frmScreenGrabber.Picture1.Image, strFileName
    
    Unload frmScreenGrabber
    
    GrabStdWindow = True
End Function

Private Function InitPicture(Screenwidth As Long, Screenheight As Long) As Boolean
    Load frmScreenGrabber
    frmScreenGrabber.Picture1.Width = Screenwidth
    frmScreenGrabber.Picture1.Height = Screenheight
End Function
