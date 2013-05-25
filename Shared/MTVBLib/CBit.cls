VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CBit"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Public Function WordHi(LongIn As Long) As Integer
   '
   ' Mask off low word then do integer divide to
   ' shift right by 16.
   '
   WordHi = (LongIn And &HFFFF0000) \ &H10000
End Function

Public Function WordLo(LongIn As Long) As Integer
   '
   ' Low word retrieved by masking off high word.
   ' If low word is too large, twiddle sign bit.
   '
   If (LongIn And &HFFFF&) > &H7FFF Then
      WordLo = (LongIn And &HFFFF&) - &H10000
   Else
      WordLo = LongIn And &HFFFF&
   End If
End Function

Public Function IsFlag(ByVal lngValue As Long, ByVal lngBit As Long) As Long
    IsFlag = CBool((lngValue And lngBit) = lngBit)
End Function

Public Function SetBit(lngValue As Long, lngBit As Long) As Long
    If (Not IsFlag(lngValue, lngBit)) Then
        SetBit = lngValue + lngBit
    Else
        SetBit = lngValue
    End If
End Function

Public Function ResetBit(ByVal lngValue As Long, ByVal lngBit As Long) As Long
    If (IsFlag(lngValue, lngBit)) Then
        ResetBit = lngValue - lngBit
    Else
        ResetBit = lngValue
    End If
End Function
