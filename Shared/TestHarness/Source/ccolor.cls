VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CColor"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private m_Red   As Long
Private m_Green As Long
Private m_Blue  As Long

Private Type TColor4Byte
    bytRed      As Byte
    bytGreen    As Byte
    bytBlue     As Byte
    bytDummy    As Byte
End Type

Private Type TColor1Long
    lngValue As Long
End Type

Public Property Get Red() As Long
    Red = m_Red
End Property

Public Property Let Red(ByVal vNewValue As Long)
    m_Red = vNewValue
End Property

Public Property Get Green() As Long
    Green = m_Green
End Property

Public Property Let Green(ByVal vNewValue As Long)
    m_Green = vNewValue
End Property

Public Property Get Blue() As Long
Blue = m_Blue
End Property

Public Property Let Blue(ByVal vNewValue As Long)
    m_Blue = vNewValue
End Property

Public Property Get Bit24() As Long
    Bit24 = RGB(Red, Green, Blue)
End Property

Public Property Let Bit24(ByVal vNewValue As Long)

    Dim type1Long  As TColor1Long
    Dim type4Byte  As TColor4Byte
    
    type1Long.lngValue = vNewValue
    LSet type4Byte = type1Long
    
    Red = type4Byte.bytRed
    Green = type4Byte.bytGreen
    Blue = type4Byte.bytBlue
    
End Property

Public Function Nuance(lngNuance As Long) As Boolean

    Blue = Blue + ((Blue * Abs(lngNuance) / 100) * IIf(lngNuance > 0, 1, -1))
    Red = Red + ((Red * Abs(lngNuance) / 100) * IIf(lngNuance > 0, 1, -1))
    Green = Green + ((Green * Abs(lngNuance) / 100) * IIf(lngNuance > 0, 1, -1))
    Nuance = True
End Function

Public Function GetHTMLColor() As String
    GetHTMLColor = Pad0(Hex(Red)) & Pad0(Hex(Green)) & Pad0(Hex(Blue))
End Function

Private Function Pad0(strS As String) As String
    If Len(strS) = 1 Then
        Pad0 = "0" & strS
    Else
        Pad0 = strS
    End If
    
End Function

Public Function Lighter() As Boolean

    Red = Red + (7 * (255 - Red) / 8)
    Green = Green + (7 * (255 - Green) / 8)
    Blue = Blue + (7 * (255 - Blue) / 8)
End Function
