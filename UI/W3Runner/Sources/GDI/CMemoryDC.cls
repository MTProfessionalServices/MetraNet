VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CMemoryDC"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Public Enum CMEMORYDC_SCROLL
    CMEMORYDC_SCROLL_DOWN = 1
    CMEMORYDC_SCROLL_UP = 2
End Enum

Private m_HDC        As Long
Private m_Width      As Long
Private m_Height     As Long

Private m_lngBackGroundColor As Long
Private m_lngForeCColor As Long

Private Font        As CGDIHandle
Private Bmp         As CGDIHandle
Private Pen         As CGDIHandle

Public CurrentX As Long
Public CurrentY As Long


Public Function Initialize(lngWidth As Long, lngHeight As Long, lngColor As Long) As Boolean

   Dim hWndScn  As Long
   Dim hDCScn   As Long

   m_Width = lngWidth
   m_Height = lngHeight
   BackGroundColor = lngColor
   
   If m_Width <= 0 Or m_Height <= 0 Then Exit Function
   
   ' Create new bitmap, select it into memory DC, using desktop DC to insure we get full-color rather than mono.
   hWndScn = GetDesktopWindow()
   hDCScn = GetDC(hWndScn)
   m_HDC = CreateCompatibleDC(hDCScn)
   
   Bmp.Initialize m_HDC, CreateCompatibleBitmap(hDCScn, m_Width, m_Height)
      
   ReleaseDC hWndScn, hDCScn
   
   Me.BackGroundColor = lngColor
   
   Initialize = True
End Function

Public Function Clear() As Boolean

    Rectangle 0, 0, m_Width, m_Height, BackGroundColor
    Clear = True
End Function

Public Function CopyTo(lngHDC As Long) As Boolean

    BitBlt lngHDC, 0, 0, m_Width, m_Height, m_HDC, 0, 0, vbSrcCopy
    CopyTo = True
End Function

Public Function ScrollLine(eDirection As CMEMORYDC_SCROLL, lngLine As Long, lngLineHeight As Long) As Boolean
   
'
'hDestDC     Specifies the device context that is to receive the bitmap.
'X,Y         Specifies the logical x-coordinate and y-coordinate of the
'            upper-left corner of the destination rectangle.
'
'nWidth   Specifies the width (in logical units) of the destination
'         rectangle and the source bitmap.
'
'nHeight  Specifies the height (in logical units) of the destination
'         rectangle and the source bitmap.
'
'hSrcDC   Identifies the device context from which the bitmap will be
'         copied. It must be NULL(zero) if the dwRop&amp; parameter specifies a
'         raster operation that does not include a source.
'
'XSrc  Specifies the logical x-coordinate and the y-coordinate of the upper-
'      left corner of the source bitmap.
'
'dwRop Specifies the raster operation to be performed as defined below.
    BitBlt m_HDC, 0, lngLine * lngLineHeight, m_Width, m_Height - (lngLine * lngLineHeight), m_HDC, 0, 0, vbSrcCopy
End Function

Public Function Free() As Boolean

   If IsValidObject(Bmp) Then
        
        Set Font = Nothing
        Set Bmp = Nothing
        Set Pen = Nothing
        DeleteDC m_HDC
   End If
   Free = True
   
End Function

Private Sub Class_Initialize()
    Set Font = New CGDIHandle
    Set Bmp = New CGDIHandle
End Sub


Public Function Rectangle(lngLeft As Long, lngTop As Long, lngWidth As Long, lngHeight As Long, lngColor As Long) As Boolean

    Dim b       As LOGBRUSH
    Dim Brush   As New CGDIHandle
    Dim r       As RECT
    
    b.lbColor = lngColor
    b.lbStyle = BS_SOLID
    b.lbHatch = HS_SOLID = 8
    
    Brush.Initialize m_HDC, CreateBrushIndirect(b)
   
    r.Left = lngLeft
    r.Top = lngTop
    r.Right = lngWidth
    r.Bottom = lngHeight
   
    FillRect m_HDC, r, Brush.Handle
    
    Rectangle = True
End Function

Public Function WriteLine(X1 As Long, Y1 As Long, X2 As Long, Y2 As Long, lngColor As Long) As Boolean

    Dim p As POINTAPI
    
    'Dim Pen As New CGDIHandle
    'Pen.Initialize m_HDC, CreatePen(PS_SOLID, 1, lngColor)
    
    MoveToEx m_HDC, X1, Y1, p
    LineTo m_HDC, X2, Y2
    WriteLine = True
End Function

Public Function WriteText(s As String) As Boolean

    TextOut m_HDC, CurrentX, CurrentY, s, Len(s)
    WriteText = True
End Function

Public Function SetFont(strFontName As String, sngFontSizePoint As Single, booBOLD As Boolean) As Boolean

    Dim FontInfo As LOGFONT
    Dim prevFont As Long, hFont As Long, ret As Long
    
    'These are the important settings: lfCharSet and lfFaceName
    FontInfo.lfCharSet = DEFAULT_CHARSET
    FontInfo.lfFaceName = strFontName & Chr$(0) 'Null character at end
    FontInfo.lfEscapement = 0
    FontInfo.lfItalic = 0
    FontInfo.lfOrientation = 0
    FontInfo.lfHeight = 0
    FontInfo.lfWidth = 0
    FontInfo.lfEscapement = 0     ' Set lfEscapement and lfOrientation to 10 * angle to rotate text
    FontInfo.lfOrientation = 0    ' for example, to rotate 45 degrees set the values to 450
    FontInfo.lfWeight = IIf(booBOLD, FW_BOLD, FW_NORMAL)
    
    FontInfo.lfItalic = 0
    FontInfo.lfUnderline = 0
    FontInfo.lfStrikeOut = 0
    FontInfo.lfCharSet = ANSI_CHARSET
    FontInfo.lfOutPrecision = OUT_DEFAULT_PRECIS
    FontInfo.lfClipPrecision = CLIP_DEFAULT_PRECIS
    FontInfo.lfQuality = DEFAULT_QUALITY
    FontInfo.lfPitchAndFamily = DEFAULT_PITCH Or FF_DONTCARE
    
    
    ' Set the font point size
    FontInfo.lfHeight = GetDeviceCaps(m_HDC, LOGPIXELSY)
    FontInfo.lfHeight = -MulDiv(sngFontSizePoint, FontInfo.lfHeight, 72)
    
    
    ' Windows expects the font size to be in pixels and to be negative if you are specifying the character height you want.
    'FontInfo.lfHeight = (lngFontSizePoint * -20) '/ Screen.TwipsPerPixelY
    Font.Initialize m_HDC, CreateFontIndirect(FontInfo)
    
    SetFont = True
     
End Function


Public Property Get hdc() As Long
    hdc = m_HDC
End Property

Public Property Get ForeColor() As Long
    ForeColor = m_lngForeCColor
End Property

Public Property Let ForeColor(ByVal vNewValue As Long)
    SetTextColor m_HDC, vNewValue
    m_lngForeCColor = vNewValue
End Property

Public Property Get Width() As Long
    Width = m_Width
End Property

Public Property Get BackGroundColor() As Long
    BackGroundColor = m_lngBackGroundColor
End Property

Public Property Let BackGroundColor(ByVal vNewValue As Long)
    m_lngBackGroundColor = vNewValue
    SetBkColor m_HDC, m_lngBackGroundColor
End Property



