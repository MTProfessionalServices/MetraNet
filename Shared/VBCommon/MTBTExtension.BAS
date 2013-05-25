Attribute VB_Name = "MTVBExtension"
' ****************************************************************************************************************************************************
' Copyright 1998, 2000 by MetraTech Corporation
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
' $Workfile$
' $Date$
' $Author$
' $Revision$
'
' * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
'
' NAME          :   MTVBExtension
' DESCRIPTION   :   Functions that should be defined as built-in in VB and are not; like IsBoolean().
'                   MTLOG.TXT file.
' VERSION       :   1.0.
' AUTHOR        :   F.Torres.
'
' ****************************************************************************************************************************************************

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

Public Function GetXMLDomFromXML(ByVal strXML As String, ByRef strErrorMessage As String) As Object

    On Error GoTo ErrMgr
    
    Dim m_XMLDoc        As Object ' MSXML2.DOMDocument30
    Dim objPP           As Object
    
    Set objPP = CreateObject("MTVBLIB.CPreProcessor")
    Set m_XMLDoc = CreateObject("MSXML2.DOMDocument.3.0")
    
    If m_XMLDoc.loadXML(strXML) Then
    
        Set GetXMLDomFromXML = m_XMLDoc
    Else
        objPP.Add "ERROR", m_XMLDoc.parseError.errorCode
        objPP.Add "LINE", m_XMLDoc.parseError.Line
        objPP.Add "LINEPOS", m_XMLDoc.parseError.linepos
        objPP.Add "REASON", m_XMLDoc.parseError.reason
        objPP.Add "TEXT", m_XMLDoc.parseError.srcText
        strErrorMessage = objPP.Process(MTMSIX_ERROR_01100)
    End If
    Exit Function
ErrMgr:
   MTGlobal_VB_MSG.TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MTVBExtension.bas", "GetXMLDomFromXML", eMTGLOBAL_LOG_TRACE_MODE.LOG_ERROR
End Function
