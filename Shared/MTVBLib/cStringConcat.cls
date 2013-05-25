VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "cStringConcat"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
' ****************************************************************************************************************************************************
'
'  Copyright 1998-2000 by MetraTech Corporation
'  All rights reserved.
'
'  THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
'  NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
'  example, but not limitation, MetraTech Corporation MAKES NO
'  REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
'  PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
'  DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
'  COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
'
'  Title to copyright in this software and any associated
'  documentation shall at all times remain with MetraTech Corporation,
'  and USER agrees to preserve the same.
'
'  CLASS        :
'  AUTHOR       : Frederic Torres
'  DATE         : 08/xx/2000
'  DESCRIPTION  :
'  VERSION      : none.
'
' ****************************************************************************************************************************************************
Option Explicit

Public s                    As String
Public sx                   As Long

Private M_stepStringAddSize As Long
Private m_AutomaticCRLF     As Boolean

Public Sub Init(stringSize As Long)
    s = Space(stringSize)
    M_stepStringAddSize = stringSize
    If stringSize = 0 Then
        sx = 1 ' Must be 1 in the 2 case
    Else
        sx = 1
    End If
End Sub

Public Function Concat(ByVal ss As String) As Boolean

        Dim lSS                     As Long
        Dim lngTmpStepStringAddSize As Long
        
        lSS = Len(ss)
        If Len(ss) + sx - 1 > Len(s) Then
        
            lngTmpStepStringAddSize = stepStringAddSize
            
            ' Rare case where the string we want to add is greater than the buffer increment size...
            ' Bug fixed 08/31/2001.
            If lSS > stepStringAddSize Then lngTmpStepStringAddSize = lSS + 1
            
            s = s + Space(lngTmpStepStringAddSize)
        End If
        Mid(s, sx, lSS) = ss
        sx = sx + lSS
        
        If (AutomaticCRLF) Then
            AutomaticCRLF = False
            Concat vbCrLf
            AutomaticCRLF = True
        End If
End Function

Private Sub Class_Initialize()
    stepStringAddSize = 1024 * 4
    Init 512
    
End Sub



Public Property Get stepStringAddSize() As Variant
    stepStringAddSize = M_stepStringAddSize
End Property

Public Property Let stepStringAddSize(ByVal vNewValue As Variant)
    M_stepStringAddSize = vNewValue
End Property

Private Sub Class_Terminate()
    s = ""
End Sub



Public Function GetString() As String
    GetString = Mid(s, 1, sx - 1)
End Function

Public Function GetLen() As Long
    GetLen = Len(GetString)
End Function

Public Function Clear() As Boolean

    Init M_stepStringAddSize
    Clear = True
End Function

Public Property Get AutomaticCRLF() As Boolean
    AutomaticCRLF = m_AutomaticCRLF
End Property

Public Property Let AutomaticCRLF(ByVal vNewValue As Boolean)
    m_AutomaticCRLF = vNewValue
End Property
