VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CVariable"
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
'  DATE         : Sunday Feb-4-2000
'  DESCRIPTION  : Generic all purpose Variable class and see the collection CVariables
'  VERSION      : none.
'
' ****************************************************************************************************************************************************

Option Explicit

Private m_varCaption    As Variant
Private m_strName       As String
Private m_varValue      As Variant
Private m_lngType       As Variant ' This is the vbtype like vbLong
Public Index            As Long
Public Tag              As Variant

Private Sub Class_Initialize()
    m_lngType = vbVariant
End Sub

Public Property Get Name() As String
    Name = m_strName
End Property

Public Property Let Name(ByVal vNewValue As String)

    If (VbType <> vbVariant) Then
    
        m_strName = vNewValue ' Do some checking...
    Else
        m_strName = vNewValue
    End If
End Property

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Value
' DESCRIPTION   : This function will try to convert the data into the type. If the convertion failed we accept the new value
'                 But we do not reset the type
'
'
Public Property Get Value() As Variant
Attribute Value.VB_UserMemId = 0
    If (IsObject(m_varValue)) Then
        Set Value = m_varValue
    Else
        Value = m_varValue
    End If
End Property


' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Value
' DESCRIPTION   : Set value get
'
Public Property Let Value(ByVal vNewValue As Variant)
    
    If (IsObject(vNewValue)) Then
        Set m_varValue = vNewValue
    Else
        m_varValue = vNewValue
    End If
End Property


' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Value
' DESCRIPTION   : Set Value Get
'
'
'
Public Property Set Value(ByVal vNewValue As Variant)
    
    Set m_varValue = vNewValue
End Property

Public Property Get VbType() As Variant
    VbType = m_lngType
End Property

Public Property Let VbType(ByVal vNewValue As Variant)
    m_lngType = vNewValue
End Property

Public Function ToString(Optional strSeparator As String = ";", Optional strDCote As String = """", Optional booIncludeType As Boolean = True) As String

    Dim strToString As String
    
    Select Case VbType
    
        Case vbString
            strToString = IIf(booIncludeType, "string/", "") & TypeName(Value) & " " & Name & "=" & strDCote & Value & strDCote & strSeparator
            
        Case vbDate
            strToString = IIf(booIncludeType, "date/", "") & TypeName(Value) & " " & Name & "=" & strDCote & Value & strDCote & strSeparator
            
        Case vbLong, vbInteger, vbByte
            strToString = IIf(booIncludeType, "long/", "") & TypeName(Value) & " " & Name & "=" & Value & strSeparator
            
        Case vbDouble, vbSingle
            strToString = IIf(booIncludeType, "double/", "") & TypeName(Value) & " " & Name & "=" & Value & strSeparator
            
        Case vbBoolean
            strToString = IIf(booIncludeType, "boolean/", "") & TypeName(Value) & " " & Name & "=" & Value & strSeparator
            
        Case vbObject
            strToString = IIf(booIncludeType, "object/", "") & TypeName(Value) & " " & Name & "=" & TypeName(Value) & strSeparator
            
        Case Else
            If (IsObject(Value)) Then
                strToString = "object/object " & TypeName(Value) & " " & Name & "=" & strDCote & TypeName(Value) & strDCote & strSeparator
            Else
                strToString = IIf(booIncludeType, "variant/", "") & TypeName(Value) & " " & Name & "=" & strDCote & Value & strDCote & strSeparator
            End If
    End Select
    
    strToString = strToString & " Caption=""" & Me.Caption & """"
    ToString = strToString
    
End Function


Public Property Get CotedValue(Optional strCote = "'") As Variant
    Select Case VbType
        Case vbString, vbDate
            CotedValue = strCote & m_varValue & strCote
        Case Else
            CotedValue = m_varValue
    End Select
End Property

Public Property Get Caption() As Variant

    If (IsEmpty(m_varCaption)) Then
    
        Caption = Me.Name
    Else
        Caption = m_varCaption
    End If
End Property

Public Property Let Caption(ByVal vNewValue As Variant)
    m_varCaption = vNewValue
End Property


Public Property Get id() As String
    id = Name
End Property

Public Property Let id(ByVal vNewValue As String)
    Name = id
End Property
