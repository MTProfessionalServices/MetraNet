VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CVariables"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
' ****************************************************************************************************************************************************
'
'  Copyright 1995-2002 by Frederic Torres
'  All rights reserved.
'
'  CLASS        :
'  AUTHOR       : Frederic Torres
'  DATE         : Feb-4-1999
'  Description  : Generic all purpose collection of variable. A variable is a : name and value. Optional is the vb type.
'                 The Old way the VB Long Type is still supported.
'  VERSION      : none.
'
' ****************************************************************************************************************************************************

Option Explicit

Private mCol                    As Collection
Private m_booCaseSensitive      As Boolean
Public OptionExplicit           As Boolean ' Default value is TRUE. If TRUE, all variables must be declared before they can be used. See Item Get Property.



Public Sub Remove(ByVal vntKey As Variant)
    On Error GoTo errmgr
    
    If IsNumeric(vntKey) Then
         mCol.Remove vntKey
    Else
         If (m_booCaseSensitive) Then
             mCol.Remove vntKey
         Else
             mCol.Remove UCase(vntKey)
         End If
    End If
    Exit Sub
errmgr:
    Debug.Print Err.Description: Debug.Assert False
End Sub

Public Property Get Count() As Long
    On Error GoTo errmgr
    Count = mCol.Count
    Exit Property
errmgr:
    Debug.Print Err.Description: Debug.Assert False
End Property

Public Property Get NewEnum() As IUnknown
Attribute NewEnum.VB_UserMemId = -4
    On Error GoTo errmgr
    Set NewEnum = mCol.[_NewEnum]
    Exit Property
errmgr:
    Debug.Print Err.Description: Debug.Assert False
End Property

Private Sub Class_Initialize()
    On Error GoTo errmgr
    Set mCol = New Collection
    OptionExplicit = True
    Exit Sub
errmgr:
    Debug.Print Err.Description: Debug.Assert False
End Sub

Private Sub Class_Terminate()
    On Error GoTo errmgr
    Clear
    Set mCol = Nothing
    Exit Sub
errmgr:
    Debug.Print Err.Description: Debug.Assert False
End Sub

Public Sub Clear()
    On Error GoTo errmgr
    Do While Count > 0
        Remove 1
    Loop
    Exit Sub
errmgr:
    Debug.Print Err.Description: Debug.Assert False
End Sub

Public Function Add(ByVal strName As String, Optional ByVal varValue As Variant, Optional ByVal varType As Variant, Optional ByVal strProgId As String, Optional varCaption As Variant, Optional varTag As Variant) As CVariable

    On Error GoTo errmgr
      
    Dim clsV As CVariable
    
    ' Now we can create an object
    If (Len(strProgId)) Then
    
        Set varValue = CreateObject(strProgId)
    End If
    
    Set clsV = New CVariable
    
    If (Exist(strName)) Then Me.Remove strName ' Remove the instance if already exist...
    
    clsV.Name = strName
    If (IsObject(varValue)) Then
    
        Set clsV.Value = varValue
        varType = vbObject
    Else
        clsV.Value = varValue
        If (IsMissing(varValue)) Then varValue = Empty
    End If
    
    clsV.Caption = IIf(IsMissing(varCaption), Empty, varCaption)
    clsV.Tag = IIf(IsMissing(varTag), Empty, varTag)
        
    If (IsMissing(varType)) Then varType = vbVariant
        
    If (IsNumeric(varType)) Then
    
        clsV.VbType = varType
    Else
        Select Case UCase(varType)  ' Convert MSIX Def type into VT TYPE
        
            Case "STRING": clsV.VbType = vbString
            Case "INT32": clsV.VbType = vbLong
            Case "INT16": clsV.VbType = vbInteger
            Case "INT8": clsV.VbType = vbByte
            Case "DOUBLE": clsV.VbType = vbDouble
            Case "FLOAT": clsV.VbType = vbSingle
            Case "TIMESTAMP", "DATE": clsV.VbType = vbDate
            Case "BOOLEAN": clsV.VbType = vbBoolean
            Case "DECIMAL", "NUMERIC": clsV.VbType = vbDecimal
            Case Else
                clsV.VbType = varType
        End Select
    End If
    
    If (m_booCaseSensitive) Then
        mCol.Add clsV, strName
    Else
        mCol.Add clsV, UCase(strName)
    End If
    clsV.Index = mCol.Count
    Set Add = clsV
    Exit Function
errmgr:
    Set Add = Nothing
End Function

Public Function ToString(Optional ByVal booEnter As Boolean = True, Optional ByVal strSeparator As String = ";", Optional ByVal strDCote As String = """", Optional ByVal booIncludeType As Boolean = True) As String
    Dim clsV As CVariable
    Dim strS As String
    
    For Each clsV In Me
    
        strS = strS & clsV.ToString(strSeparator, strDCote, booIncludeType) & IIf(booEnter, vbCrLf, "")
    Next
    ToString = strS
End Function


Public Property Get Exist(ByVal vntKey As Variant) As Boolean
   On Error GoTo errmgr
   
   Dim Itm                  As CVariable
   Dim booOptionExplicit    As Boolean
   
   booOptionExplicit = OptionExplicit
   OptionExplicit = True
   
   Set Itm = Me.Item(vntKey)
   Exist = Not (Itm Is Nothing)
   
   OptionExplicit = booOptionExplicit
   
   Exit Property
errmgr:
   Err.Clear
End Property


Public Function LoadSet(ByVal varDataSource As Variant, Optional ByVal lngSepa As String = ",", Optional ByVal booAcceptMinusInId As Boolean = False, Optional ByVal booVariableList As Boolean = False, Optional ByVal varDefaultValue As Variant) As Boolean

    On Error GoTo errmgr
    
    Dim strName     As String
    Dim strValue    As String
    Dim varValue    As Variant
    Dim booIsStr    As Boolean
    Dim lngType     As Long
    Dim objParser   As CByteSyntaxAnalyser
    
    
    If (IsMissing(varDefaultValue)) Then varDefaultValue = Empty
    
    If (varType(varDataSource) = vbString) Then
    
            Set objParser = New CByteSyntaxAnalyser
            objParser.Init CStr(varDataSource)
    Else
            Set objParser = varDataSource
    End If
    
    objParser.booAcceptMinusInId = booAcceptMinusInId
    
    LoadSet = False
    
    Do While (objParser.EOS = rFALSE)
    
        If (objParser.GetIdentifier(strName, Not Me.caseSensitive()) = rSUCCEED) Then
  
            If (booVariableList) Then
                Add strName, varDefaultValue, varType(varDefaultValue)
            Else
                If (objParser.GetChar("=") = rSUCCEED) Then
                    objParser.PushBytesIndex
                    booIsStr = (objParser.GetChar("""") = rSUCCEED)
                    objParser.PopBytesIndex
                    If (booIsStr) Then
                        If (Not objParser.GetString(strValue) = rSUCCEED) Then
                            Exit Function ' Syntax error
                        End If
                        ' Here we have a string
                        lngType = vbString
                    Else
                        ' Get the value as an id
                        If (objParser.GetIdentifier(strValue, False) = rSUCCEED) Then
                            If (IsNumeric(strValue)) Then
                                If (objParser.IsLong(strValue)) Then
                                    lngType = vbLong
                                Else
                                    lngType = vbDouble
                                End If
                            ElseIf (IsDate(strValue)) Then
                                lngType = vbDate
                            Else
                                lngType = vbString
                            End If
                        End If
                    End If
                    Select Case lngType
                        Case vbLong
                            varValue = CLng(strValue)
                        Case vbDouble
                            varValue = CDbl(strValue)
                        Case vbDate
                            varValue = CDate(strValue)
                        Case Else
                            If (IsDate(strValue)) Then
                                lngType = vbDate
                                varValue = CDate(strValue)
                            ElseIf (objParser.IsBool(strValue)) Then
                                lngType = vbBoolean
                                varValue = CBool(strValue)
                            Else
                                varValue = strValue
                            End If
                    End Select
                    Add strName, varValue, lngType
                Else
                    Exit Function ' Syntax error
                End If
            End If
            ' No more
            If (objParser.GetChar(lngSepa) = rFALSE) Then Exit Do
        End If
        objParser.KillSpace
    Loop
    LoadSet = True
    Exit Function
errmgr:

End Function

Public Property Get caseSensitive() As Boolean
    caseSensitive = m_booCaseSensitive
End Property

Public Property Let caseSensitive(ByVal vNewValue As Boolean)
    m_booCaseSensitive = vNewValue
End Property

'Public Function LoadInsertSet(ByVal parser As CByteSyntaxAnalyser, Optional ByVal lngSepa As String = ",", Optional ByVal booAcceptMinusInId As Boolean = False) As Boolean
'
'    On Error GoTo errmgr
'
'    Dim strName     As String
'    Dim strValue    As String
'    Dim varValue    As Variant
'    Dim booIsStr    As Boolean
'    Dim lngType     As Long
'    Dim lngVarCount As Long
'
'    Me.Clear    ' We have to do a clear - because we expect that the first var is in the first pos in
'                ' in the collection! Can be improved!!!
'
'    parser.booAcceptMinusInId = booAcceptMinusInId
'
'    LoadInsertSet = False
'
'    ' Read the value list
'
'    If (parser.GetChar("(") = rFAILED) Then Exit Function
'
'    Do While (parser.EOS = rFALSE)
'        If (parser.GetIdentifier(strName, Not Me.caseSensitive()) = rSUCCEED) Then
'            Add strName
'            If (parser.GetChar(lngSepa) = rFALSE) Then Exit Do
'        End If
'    Loop
'
'    If (parser.GetChar(")") = rFAILED) Then Exit Function
'
'    If (parser.GetIdentifier(strValue) = rFAILED) Then Exit Function
'    If (strValue <> "VALUES") Then Exit Function
'
'    ' Read the list of values
'
'    If (parser.GetChar("(") = rFAILED) Then Exit Function
'    lngVarCount = 1
'    Do While (parser.EOS = rFALSE)
'
'        parser.PushBytesIndex
'        booIsStr = (parser.GetChar("""") = rSUCCEED)
'        parser.PopBytesIndex
'        If (booIsStr) Then
'            If (Not parser.GetString(strValue) = rSUCCEED) Then Exit Function ' Syntax error
'            lngType = vbString ' Here we have a string
'        Else
'            ' Get the value as an id
'            If (parser.GetIdentifier(strValue, False) = rSUCCEED) Then
'                If (IsNumeric(strValue)) Then
'                    If (parser.IsLong(strValue)) Then
'                        lngType = vbLong
'                    Else
'                        lngType = vbDouble
'                    End If
'                ElseIf (IsDate(strValue)) Then
'                    lngType = vbDate
'                Else
'                    lngType = vbString
'                End If
'            End If
'        End If
'        Select Case lngType
'            Case vbLong
'                varValue = CLng(strValue)
'            Case vbDouble
'                varValue = CDbl(strValue)
'            Case vbDate
'                varValue = CDate(strValue)
'            Case Else
'                If (IsDate(strValue)) Then
'                    lngType = vbDate
'                    varValue = CDate(strValue)
'                ElseIf (parser.IsBool(strValue)) Then
'                    lngType = vbBoolean
'                    varValue = CBool(strValue)
'                Else
'                    varValue = strValue
'                End If
'        End Select
'        ' Address the var with the index
'        Me.SetValue lngVarCount, varValue, lngType
'        lngVarCount = lngVarCount + 1
'
'        If (parser.GetChar(lngSepa) = rFALSE) Then Exit Do
'    Loop
'
'    If (parser.GetChar(")") = rFAILED) Then Exit Function
'
'    LoadInsertSet = True
'    Exit Function
'errmgr:
'Resume
'End Function


Public Function SetValue(vntKey As Variant, Optional varValue As Variant, Optional varVbType As Variant) As Boolean

    On Error GoTo errmgr
      
    Dim clsV As CVariable
    
    Set clsV = Me.Item(vntKey)
    If (clsV Is Nothing) Then Exit Function
    
    If (Not IsMissing(varValue)) Then clsV.Value = varValue
    
    If (Not IsMissing(varVbType)) Then clsV.VbType = varVbType
    
    SetValue = True
    
    Exit Function
errmgr:
    
End Function

Public Property Get Collection() As Collection
    Set Collection = mCol
End Property

Public Function GetSQLInsert(strTableName As String) As String

    Dim objVar          As CVariable
    Dim strSQL          As String
    Dim strSQL1         As String
    Dim strSQL2         As String
    
    strSQL = "insert into " & strTableName & " ("
    For Each objVar In Me
        strSQL1 = strSQL1 & objVar.Name & ","
        Select Case objVar.VbType
            Case vbString, vbDate
                strSQL2 = strSQL2 & "'" & objVar.Value & "'" & ","
            Case Else
                strSQL2 = strSQL2 & objVar.Value & ","
        End Select
    Next
    If (Len(strSQL1)) Then strSQL1 = Left(strSQL1, Len(strSQL1) - 1)
    If (Len(strSQL2)) Then strSQL2 = Left(strSQL2, Len(strSQL2) - 1)
    
    strSQL = strSQL & strSQL1 & ") values (" & strSQL2 & ")"
    
    GetSQLInsert = strSQL
    
End Function

Public Function CopyTo(ByVal objVariablesDestination As CVariables) As Boolean
    Dim objVar As CVariable
    For Each objVar In Me
        objVariablesDestination.Add objVar.Name, objVar.Value, objVar.VbType
    Next
    CopyTo = True
    
End Function


Public Property Get ItemByValue(ByVal vntValue As Variant) As CVariable

   On Error GoTo errmgr
   
   Dim objVar As CVariable
   
   For Each objVar In Me
        If UCase(CStr(objVar.Value)) = UCase(CStr(vntValue)) Then
        
            Set ItemByValue = objVar
            Exit Property
        End If
   Next
   Exit Property
errmgr:
   Set ItemByValue = Nothing
End Property

Public Function LoadIdList(ByVal strIDList As String, Optional ByVal lngSepa As String = ",") As Boolean

    On Error GoTo errmgr
    
    Dim strName     As String
    Dim strValue    As String
    Dim varValue    As Variant
    Dim booIsStr    As Boolean
    Dim lngType     As Long
    Dim lngVarCount As Long
    Dim parser      As New CByteSyntaxAnalyser
    
    Me.Clear    ' We have to do a clear - because we expect that the first var is in the first pos in
                ' in the collection! Can be improved!
    
    parser.Init strIDList
    
    Do While (parser.EOS = rFALSE)
    
        If (parser.GetIdentifier(strName, Not Me.caseSensitive()) = rSUCCEED) Then
        
            Add strName, strName
            If (parser.GetChar(lngSepa) = rFALSE) Then Exit Do
        Else
            Exit Function
        End If
    Loop
    LoadIdList = True
    Exit Function
errmgr:

End Function



' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Item
' PARAMETERS    :
'                   vntKey - item key name id or item long index, start at 1..
' DESCRIPTION   : Return the instance of CVariableThis method is the default method.
'                 The method is not case sensitive. Returns Nothing if the item is not found.
'
'                 If the vntKey is not existing the function will return nothing.
'                 If the Property OptionExplicit is FALSE then if the vntKey is not existing the property will create a new instance
'                 with for name vntKey, the type is VARIANT and the value is Empty.
'
' RETURN        :
Public Property Get Item(ByVal vntKey As Variant) As CVariable
Attribute Item.VB_UserMemId = 0

   On Error GoTo errmgr
   
   If IsNumeric(vntKey) Then
        Set Item = mCol(CLng(vntKey))
   Else
        If (m_booCaseSensitive) Then
            Set Item = mCol(vntKey)
        Else
            Set Item = mCol(UCase(vntKey))
        End If
   End If
   Exit Property
errmgr:
    If (Not OptionExplicit) Then
        ' Here we create every variable that does not exist...
        If Not IsNumeric(vntKey) Then
        
            Err.Clear
            Me.Add vntKey, Empty
            Set Item = Item(vntKey) ' Now we add the variable we can call the item method.
            Exit Property
        End If
    End If
    Set Item = Nothing
End Property


Public Function LoadCSVString(ByVal strIDList As String, Optional ByVal lngSepa As String = ",") As Boolean

    On Error GoTo errmgr
    
    Dim strName     As String
    Dim strValue    As String
    Dim varValue    As Variant
    Dim booIsStr    As Boolean
    Dim lngType     As Long
    Dim lngVarCount As Long
    Dim parser      As New CByteSyntaxAnalyser
    
    
    Me.Clear    ' We have to do a clear - because we expect that the first var is in the first pos in
                ' in the collection! Can be improved!
    
    parser.Init strIDList
    
    Do While (parser.EOS = rFALSE)
    
        If (parser.GetUpToChar(lngSepa, strName) = rSUCCEED) Then
        
            Add strName, strName
            If (parser.GetChar(lngSepa) = rFAILED) Then Exit Do
        Else
            Exit Function
        End If
    Loop
    LoadCSVString = True
    Exit Function
errmgr:

End Function


