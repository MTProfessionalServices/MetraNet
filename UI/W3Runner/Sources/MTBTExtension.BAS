Attribute VB_Name = "MTVBExtension"

Option Explicit

'Public Enum VB_TYPES
'    vbEmpty = 0
'    vbNull = 1 'Contains no valid data
'    vbInteger = 2 ' Integer
'    vbLong = 3 'Long integer
'    vbSingle = 4 ' Single-precision floating-point number
'    vbDouble = 5 ' Double-precision floating-point number
'    vbCurrency = 6 ' Currency
'    vbDate = 7 'Date
'    vbString = 8 ' String
'    vbObject = 9 ' Object
'    vbError = 10 'Error
'    vbBoolean = 11 ' Boolean
'    vbVariant = 12 ' Variant (used only for arrays of variants)
'    vbDataObject = 13 ' Data access object
'    vbDecimal = 14 'Decimal
'    vbByte = 17 'Byte
'    vbUserDefinedType = 36 'Variants that contain user-defined types
'    vbArray = 8192 'Array
'End Enum


' -----------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :   IsFlag
' PARAMETERS    :
' DESCRIPTION   : Returns TRUE is the bit(s) lngBit are set in lngValue else FALSE
' RETURN        :
Public Function IsFlag(lngValue As Long, lngBit As Long) As Boolean

    IsFlag = CBool((lngValue And lngBit) = lngBit)
End Function


' -----------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : IsValidObject
' PARAMETERS    :
' DESCRIPTION   : Returns TRUE o is an object and different from Nothing. The VB function IsObject returns TRUE for nothing.
' RETURN        :
Public Function IsValidObject(ByVal o As Object) As Boolean


    'If IsMissing(o) Then Exit Function
    'If IsEmpty(o) Then Exit Function
    If Not IsObject(o) Then Exit Function
    If o Is Nothing Then Exit Function
    IsValidObject = True

End Function

' -----------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : PrintableNULL
' PARAMETERS    :
' DESCRIPTION   : Returns the string "NULL" or "EMPTY" or "MISSING" if the variant varVariant is NULL, EMPTY, MISSING else
'                 return the value...
' RETURN        :
Public Function PrintableNULL(varVariant As Variant) As Variant

    If (IsNull(varVariant)) Then
        PrintableNULL = "NULL"
    ElseIf (IsEmpty(varVariant)) Then
        PrintableNULL = "EMPTY"
    ElseIf (IsMissing(varVariant)) Then
        PrintableNULL = "MISSING"
    Else
        PrintableNULL = varVariant
    End If
End Function

' -----------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :   IsBoolean
' PARAMETERS    :
' DESCRIPTION   :   Return TRUE is the varV can be converted as a boolean with the function CBOOL()
' RETURN        :
Public Function IsBoolean(varV As Variant) As Boolean
    On Error Resume Next
    Dim b As Boolean
    b = CBool(varV)
    IsBoolean = Err.Number = 0
    Err.Clear
End Function

' -----------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :   VT_Convert
' PARAMETERS    :
' DESCRIPTION   :   Convert varValue into a the VT_TYPE and return the result into a variant...
'                   If the convertion failed return false and update varOutPutValue with the value
' RETURN        : TRUE if ok!
Public Function VT_Convert(ByVal varValue As Variant, ByVal lngVT_Type As Long, ByRef varOutPutValue) As Boolean

    On Error GoTo ErrMgr
    
    VT_Convert = True
    
    Select Case lngVT_Type
    
        Case vbLong: varOutPutValue = CLng(varValue)
        Case vbByte: varOutPutValue = CByte(varValue)
        Case vbInteger: varOutPutValue = CInt(varValue)
        Case vbSingle: varOutPutValue = CSng(varValue)
        Case vbDouble: varOutPutValue = CDbl(varValue)
        Case vbDate: varOutPutValue = CDate(varValue)
        Case vbBoolean: varOutPutValue = CBool(varValue)
        Case vbDecimal: varOutPutValue = CDec(varValue)
        Case vbCurrency: varOutPutValue = CCur(varValue)
        Case vbString: varOutPutValue = CStr(varValue)
        Case vbVariant: varOutPutValue = CVar(varValue)
        Case Else
            GoTo ErrMgr ' Here we pretend the convertion failed
    End Select
    
    Exit Function
ErrMgr:
    
    VT_Convert = False
    varOutPutValue = varValue ' Convertion error return false but update the output value
    Err.Clear
End Function



' -----------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Convert
' PARAMETERS    :
' DESCRIPTION   : To VB type convertion without error and with default values.
' RETURN        :
'Public Function Convert(ByVal varValue As Variant, ConvertTo As VB_TYPES, Optional varDefaultValue As Variant) As Variant
'
'    On Error GoTo ErrMgr
'
'    Select Case ConvertTo
'
'        Case vbEmpty ' 0
'            Convert = Empty
'
'        Case vbNull ' 1 'Contains no valid data
'            Convert = Null
'
'        Case vbInteger ' 2 ' Integer
'            Convert = CInt(varValue)
'
'        Case vbLong ' 3 'Long integer
'            Convert = CLng(varValue)
'
'        Case vbSingle ' 4 ' Single-precision floating-point number
'            Convert = CSng(varValue)
'
'        Case vbDouble ' 5 ' Double-precision floating-point number
'            Convert = CDbl(varValue)
'
'        Case vbCurrency ' 6 ' Currency
'            Convert = CCur(varValue)
'
'        Case vbDate ' 7 'Date
'            Convert = CDate(varValue)
'
'        Case vbString ' 8 ' String
'            Convert = CStr(varValue)
'
'        Case vbObject ' 9 ' Object
'            Set Convert = varValue
'
'        Case vbError ' 10 'Error
'            GoTo ErrMgr
'
'        Case vbBoolean ' 11 ' Boolean
'            Convert = CBool(varValue)
'
'        Case vbVariant ' 12 ' Variant (used only for arrays of variants)
'            Convert = CVar(varValue)
'
'        Case vbDataObject ' 13 ' Data access object
'            GoTo ErrMgr
'
'        Case vbDecimal ' 14 'Decimal
'            Convert = CDec(varValue)
'
'        Case vbByte ' 17 'Byte
'            Convert = CByte(varValue)
'
'        Case vbUserDefinedType ' 36 'Variants that contain user-defined types
'            GoTo ErrMgr
'
'        Case vbArray ' 8192 'Array
'    End Select
'    Exit Function
'ErrMgr:
'    If (IsMissing(varDefaultValue)) Then
'        Convert = Empty
'    Else
'        Convert = varDefaultValue
'    End If
'    Err.Clear
'End Function

' -----------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : InArray
' PARAMETERS    :
' DESCRIPTION   : Return True is the first item is in the list
' RETURN        :
Public Function InArray(ByVal varValue As Variant, varArray As Variant) As Long

    Dim i As Long
    
    varValue = UCase$(varValue)
    
    For i = 0 To UBound(varArray)
    
        If (varValue = UCase$(varArray(i))) Then
            InArray = i + 1
            Exit Function
        End If
    Next
    InArray = 0
End Function

Public Function COMPropertyExist(objObject As Object, ByVal strPropertyName As String, Optional ByRef varValue As Variant) As Boolean

    On Error Resume Next
    
    varValue = CallByName(objObject, strPropertyName, VbGet)
    COMPropertyExist = CBool(Err.Number = 0)
    Err.Clear
End Function



Public Function COMPropertyType(objObject As Object, ByVal strPropertyName As String) As Long

    On Error Resume Next
    
    Dim varValue As Variant
    
    varValue = CallByName(objObject, strPropertyName, VbGet)
    COMPropertyType = VarType(varValue)
    Err.Clear
End Function

Public Function ControlExist(frm As Form, ByVal strControlName As String) As Boolean

    Dim objCtl As Control
    
    For Each objCtl In frm.Controls
    
        If (UCase$(strControlName) = UCase$(objCtl.Name)) Then
        
            ControlExist = True
        End If
    Next
End Function

' -----------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : MakeItAnObject
' PARAMETERS    :
' DESCRIPTION   : The function IsValidObject accept only an object. If your object is a variant you
'                 must call this function in between :
'                    If IsValidObject(MakeItAnObject(MyObjectInAVariant)) Then
' RETURN        :
Public Function MakeItAnObject(v As Variant) As Object

    Dim o As Object
    
    Set MakeItAnObject = Nothing
    
    If IsMissing(v) Then Exit Function
    If IsEmpty(v) Then Exit Function
    
    Set o = v
    Set MakeItAnObject = o
    
    
End Function


' -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :   GetVBErrorString
' PARAMETERS    :
' DESCRIPTION   :   Return the current VB Run Time Error in a following way error=13 description=Type mismatch source=CTextFile
' RETURN        :
Public Function GetVBErrorString() As String

    GetVBErrorString = "error=" & CStr(Err.Number) & " description=" & Err.Description & " source=" & Err.Source
End Function



Public Function PreProcess(ByVal strMessage As String, ParamArray defines() As Variant) As String
    Dim i           As Long
    Dim ii          As Long
    Dim varValue    As Variant
    Dim lngPos      As Long
    Dim lngPosEnd   As Long
    Dim booIsDefine As Boolean
    Dim lngTmpLen   As Long
    
    Const PREPROCESS_IF = "#IF"
    Const PREPROCESS_END = "#END"
    
    For i = 0 To UBound(defines()) Step 2
    
        lngPos = InStr(strMessage, PREPROCESS_IF & "[" & defines(i) & "]")
        If lngPos Then
        
            lngPosEnd = InStr(lngPos, strMessage, PREPROCESS_END)
            varValue = defines(i + 1)
            If Not CBool(varValue) Then
                ' We clear the all text
                strMessage = DeleteString(strMessage, lngPos, lngPosEnd - lngPos + Len(PREPROCESS_END) + Len(vbNewLine))
            Else
                ' Clear only the #IF[] and #END
                lngTmpLen = Len(PREPROCESS_IF) + 2 + Len(defines(i)) + Len(vbNewLine)
                strMessage = DeleteString(strMessage, lngPos, lngTmpLen)
                lngPosEnd = lngPosEnd - lngTmpLen ' Change the lngPOS because we deleted the #IF[]
                strMessage = DeleteString(strMessage, lngPosEnd - 1, Len(PREPROCESS_END) + Len(vbNewLine))
            End If
        End If
    Next
    
    For i = 0 To UBound(defines()) Step 2
    
        varValue = defines(i + 1)
        If IsMissing(varValue) Then
            varValue = ""
        End If
        strMessage = Replace(strMessage, "[" & defines(i) & "]", CStr(varValue))
    Next
    PreProcess = strMessage
End Function



Public Function LB_AddIfNotExist(lb As ComboBox, ByVal strItem As String) As Boolean

    Dim i As Long
    Dim strItemUpper As String
    
    strItemUpper = UCase$(strItem)
    For i = 0 To lb.ListCount - 1
    
        If UCase$(lb.List(i)) = strItemUpper Then
            LB_AddIfNotExist = True
            Exit Function
        End If
    Next
    lb.AddItem strItem
    LB_AddIfNotExist = True
End Function


Public Function LB_Save(lb As ComboBox, strFileName As String) As Boolean

    Dim i As Long
    Dim s As String
    Dim objTextFile As New cTextFile
    
    For i = 0 To lb.ListCount - 1
    
        s = s & lb.List(i) & vbNewLine
    Next
    If Len(Trim(s)) Then
        LB_Save = objTextFile.LogFile(strFileName, s, True)
    Else
        LB_Save = True
    End If
End Function



Public Function LB_Read(lb As ComboBox, strFileName As String) As Boolean

    Dim objTextFile As New cTextFile
    Dim s           As String
    
    lb.Clear
    If Not objTextFile.ExistFile(strFileName) Then Exit Function
    
    If objTextFile.OpenFile(strFileName) Then
    
        Do While Not objTextFile.EOF()
        
            s = objTextFile.ReadLn()
            If Len(Trim(s)) Then lb.AddItem s
        Loop
        objTextFile.CloseFile
    End If
    LB_Read = True
End Function

Public Function DeleteString(ByRef strString As String, ByVal lngStart As Long, ByVal lngLen As Long) As String
    DeleteString = Mid(strString, 1, lngStart - 1) & Mid(strString, lngStart + lngLen)
End Function

Public Function SetFrameEnabled(objForm As Form, objFrame As Frame, booEnabled As Boolean) As Boolean
    
    Dim C As Control
    
    For Each C In objForm.Controls
    
        If C.Container Is objFrame Then
            C.Enabled = booEnabled
        End If
    Next
    SetFrameEnabled = True
End Function


Public Property Get COMProperty(ByVal o As Object, ByVal strPropertyName As String) As Variant
    On Error Resume Next
    COMProperty = CallByName(o, strPropertyName, VbGet)
End Property

Public Property Let COMProperty(ByVal o As Object, ByVal strPropertyName As String, ByVal vNewValue As Variant)
    On Error Resume Next
    
    If IsNull(vNewValue) Then
        CallByName o, strPropertyName, VbLet, ""
    Else
        CallByName o, strPropertyName, VbLet, vNewValue
    End If
End Property


Public Function LB_SelectByItemData(lb As Variant, lngIndex As Long) As Boolean

    Dim i As Long
    
    For i = 0 To lb.ListCount - 1
    
        If lb.ItemData(i) = lngIndex Then
            lb.ListIndex = i
            LB_SelectByItemData = True
            Exit Function
        End If
    Next
End Function



Public Function LB_SelectByText(lb As Variant, ByVal strText As String) As Boolean

    Dim i As Long
    
    strText = UCase$(strText)
    
    For i = 0 To lb.ListCount - 1
    
        If UCase$(lb.List(i)) = strText Then
            lb.ListIndex = i
            LB_SelectByText = True
            Exit Function
        End If
    Next
End Function

