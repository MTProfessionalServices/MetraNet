VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CDecimal"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
'****************************************************************************************************************************************************
'
' Copyright 1998-2000 by MetraTech Corporation
' All rights reserved.
'
' THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
' NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
' example, but not limitation, MetraTech Corporation MAKES NO
' REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
' PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
' DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
' COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
'
' Title to copyright in this software and any associated
' documentation shall at all times remain with MetraTech Corporation,
' and USER agrees to preserve the same.
'
' MODIFIED      : $Date$
' LAST AUTHOR   : $Author$
' REVISION      : $Revision$
' FILENAME      : $Workfile$
'
' * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
'
' CLASS         : Decimal.
' AUTHOR        : F.Torres
' CREATION DATE : 07/xx/2000
' DESCRIPTION   : Implement some operation for decimal because VBScript does support it; Metratech already supply a
'                 a C++ COM object called IMTDecimal; This class does the same but is probably better implemented.
'                 Because I implemted a default property which is value so in VBScript we can have the following syntax :
'
'                       Dim decAmount
'                       Dim Set decAmount = CreateObject("MTMSIX.DECIMAL")
'
'                       DecAmount = 1223.323232323
'                       DecAmount = "1223.323232323"
'                       DecAmount = AnyVariant
'
'                 We can meter the DecAmount as decimal because it is a Variant containing a decimal.
'
'                 Note : VBScript does not support Decimal computation! And event VB cannot do anything about that.
'
'                 The function Ops allow to perform simple operation on the value itself. The value passed as a parameter is always the second
'                 operand. The function return the result as well;
'
'                 DecAmount = 1223.323232323
'                 DecAmount.Operation("*",453.56)
'
'                 Operation supported : *,/,+,-,\,mod,abs,int.
'
'
'
Option Explicit

Private m_value As Variant

Public Property Get Value() As Variant
Attribute Value.VB_UserMemId = 0
        Value = m_value
End Property

Public Property Let Value(ByVal vNewValue As Variant)
        m_value = CDec(vNewValue)
End Property

Public Function Operation(ByVal strOp As String, Optional ByVal decValue As Variant) As Variant
    
    Select Case UCase(strOp)
    
        Case "*"
            m_value = CDec(m_value) * CDec(decValue)
            Operation = m_value
        
        Case "/"
            m_value = CDec(m_value) / CDec(decValue)
            Operation = m_value
            
        Case "+"
            m_value = CDec(m_value) + CDec(decValue)
            Operation = m_value
            
        Case "-"
            m_value = CDec(m_value) - CDec(decValue)
            Operation = m_value
            
        Case "\"
            m_value = CDec(m_value) \ CDec(decValue)
            Operation = m_value
        Case "MOD"
            m_value = CDec(m_value) Mod CDec(decValue)
            Operation = m_value
        
        Case "ABS"
            m_value = Abs(CDec(m_value))
            Operation = m_value
            
        Case "INT"
            m_value = Int(CDec(m_value))
            Operation = m_value
            
        Case "ROUND"
            If (IsMissing(decValue)) Then
                m_value = Round(CDec(m_value))
            Else
                m_value = Round(CDec(m_value), CLng(decValue))
            End If
            Operation = m_value
        
        Case "="
            Operation = CBool(CDec(m_value) = CDec(decValue))
        Case ">"
            Operation = CBool(CDec(m_value) > CDec(decValue))
        Case ">="
            Operation = CBool(CDec(m_value) >= CDec(decValue))
        Case "<"
            Operation = CBool(CDec(m_value) < CDec(decValue))
        Case "<="
            Operation = CBool(CDec(m_value) <= CDec(decValue))
        Case "<>"
            Operation = CBool(CDec(m_value) <> CDec(decValue))
    End Select
    
End Function

Public Function Test() As Boolean

    Dim dbl1 As Double, dbl2 As Double
    Dim dec1 As Variant, dec2 As Variant
    
    dbl1 = 12345.6789123457
    dbl2 = 67890.12345
    
    dbl1 = -1
    dbl2 = 123.321323123311
    
    dec1 = CDec(dbl1)
    dec2 = CDec(dbl2)
    
    Value = dec1
    MsgBox "double exp=" & (dbl1 * dbl2) & " decimal exp=" & Me.Operation("*", dec2)
    
End Function

