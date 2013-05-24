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
'**************************************************************************
'
'  Copyright 1998 by MetraTech Corporation
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
'  CLASS        : CVariables
'  AUTHOR       : Frederic Torres
'  DATE         : 03/xx/2000
'  DESCRIPTION  : Generic all purpose collection of CVariable. See class CVariable.
'
' ****************************************************************************************************************************************************************

Option Explicit

Private mCol                    As Collection

Private m_booCaseSensitive      As Boolean ' Default Mode Not Case Sensitive

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
Public Property Get Item(vntKey As Variant) As CVariable
Attribute Item.VB_UserMemId = 0
   On Error GoTo ErrMgr
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
ErrMgr:
   Set Item = Nothing
End Property

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Remove
' DESCRIPTION   : Remove a CVar instance from the collection. If the item does not exist the function DOES not
'                 raise an error, but return FALSE!
' PARAMETERS    :
' RETURNS       : TRUE if the item was removed, FALSE it item does not exist...
Public Function Remove(vntKey As Variant) As Boolean

    On Error GoTo ErrMgr
    
    If IsNumeric(vntKey) Then
         mCol.Remove vntKey
    Else
         If (m_booCaseSensitive) Then
             mCol.Remove vntKey
         Else
             mCol.Remove UCase(vntKey)
         End If
    End If
    Remove = True
    Exit Function
ErrMgr:
    Debug.Print Err.Description: Debug.Assert False
End Function

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
Public Property Get Count() As Long
    On Error GoTo ErrMgr
    Count = mCol.Count
    Exit Property
ErrMgr:
    Debug.Print Err.Description: Debug.Assert False
End Property

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
Public Property Get NewEnum() As IUnknown
Attribute NewEnum.VB_UserMemId = -4
    On Error GoTo ErrMgr
    Set NewEnum = mCol.[_NewEnum]
    Exit Property
ErrMgr:
    Debug.Print Err.Description: Debug.Assert False
End Property

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
Private Sub Class_Initialize()
    On Error GoTo ErrMgr
    Set mCol = New Collection
    Exit Sub
ErrMgr:
    Debug.Print Err.Description: Debug.Assert False
End Sub

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
Private Sub Class_Terminate()
    On Error GoTo ErrMgr
    Clear
    Set mCol = Nothing
    Exit Sub
ErrMgr:
    Debug.Print Err.Description: Debug.Assert False
End Sub

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
Public Sub Clear()
    On Error GoTo ErrMgr
    Do While Count > 0
        Remove 1
    Loop
    Exit Sub
ErrMgr:
    Debug.Print Err.Description: Debug.Assert False
End Sub

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
Public Function Add(ByVal strName As String, Optional varValue As Variant, Optional lngVbType As Long = vbVariant) As CVariable

    On Error GoTo ErrMgr
      
    Dim clsV As CVariable
    
    ' Remove the instance if already exist...
    If (Exist(strName)) Then Me.Remove strName
    
    Set clsV = New CVariable
    clsV.Name = strName
    clsV.Value = varValue
    clsV.VbType = lngVbType
    If (m_booCaseSensitive) Then
        mCol.Add clsV, strName
    Else
        mCol.Add clsV, UCase(strName)
    End If
    clsV.Index = mCol.Count - 1
    Set Add = clsV
    Exit Function
ErrMgr:
    Set Add = Nothing
End Function

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
Public Function ToString() As String
    Dim clsV As CVariable
    Dim strS As String
    
    For Each clsV In Me
    
        strS = strS & clsV.ToString() & vbCrLf
    Next
    ToString = strS
End Function


' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
Public Property Get Exist(vntKey As Variant) As Boolean
   On Error GoTo ErrMgr
   Dim Itm As CVariable
   Set Itm = Me.Item(vntKey)
   Exist = Not (Itm Is Nothing)
   Exit Property
ErrMgr:
   Err.Clear
End Property

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
Friend Function LoadSet(parser As CByteSyntaxAnalyser, Optional lngSepa As String = ",", Optional booAcceptMinusInId As Boolean = False, Optional booVariableList As Boolean = False, Optional varDefaultValue As Variant) As Boolean

    On Error GoTo ErrMgr
    
    Dim strName     As String
    Dim strValue    As String
    Dim varValue    As Variant
    Dim booIsStr    As Boolean
    Dim lngType     As Long
    
    parser.booAcceptMinusInId = booAcceptMinusInId
    
    LoadSet = False
    
    Do While (parser.EOS = rFALSE)
    
        If (parser.GetIdentifier(strName, Not Me.CaseSensitive()) = rSUCCEED) Then
  
            If (booVariableList) Then
                Add strName, varDefaultValue, VarType(varDefaultValue)
            Else
                If (parser.GetChar("=") = rSUCCEED) Then
                    parser.PushBytesIndex
                    booIsStr = (parser.GetChar("""") = rSUCCEED)
                    parser.PopBytesIndex
                    If (booIsStr) Then
                        If (Not parser.GetString(strValue) = rSUCCEED) Then
                            Exit Function ' Syntax error
                        End If
                        ' Here we have a string
                        lngType = vbString
                    Else
                        ' Get the value as an id
                        If (parser.GetIdentifier(strValue, False) = rSUCCEED) Then
                            If (IsNumeric(strValue)) Then
                                If (parser.IsLong(strValue)) Then
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
                            ElseIf (parser.IsBool(strValue)) Then
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
            If (parser.GetChar(lngSepa) = rFALSE) Then Exit Do
        End If
        parser.KillSpace
    Loop
    LoadSet = True
    Exit Function
ErrMgr:

End Function


' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
Public Property Get CaseSensitive() As Boolean
    CaseSensitive = m_booCaseSensitive

End Property

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
Public Property Let CaseSensitive(ByVal vNewValue As Boolean)
    m_booCaseSensitive = vNewValue
End Property


' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
Friend Function LoadInsertSet(parser As CByteSyntaxAnalyser, Optional lngSepa As String = ",", Optional booAcceptMinusInId As Boolean = False) As Boolean

    On Error GoTo ErrMgr
    
    Dim strName     As String
    Dim strValue    As String
    Dim varValue    As Variant
    Dim booIsStr    As Boolean
    Dim lngType     As Long
    Dim lngVarCount As Long
    
    Me.Clear    ' We have to do a clear - because we expect that the first var is in the first pos in
                ' in the collection! Can be improved!!!
    
    parser.booAcceptMinusInId = booAcceptMinusInId
    
    LoadInsertSet = False
    
    ' Read the value list
    
    If (parser.GetChar("(") = rFAILED) Then Exit Function
    
    Do While (parser.EOS = rFALSE)
        If (parser.GetIdentifier(strName, Not Me.CaseSensitive()) = rSUCCEED) Then
            Add strName
            If (parser.GetChar(lngSepa) = rFALSE) Then Exit Do
        End If
    Loop
    
    If (parser.GetChar(")") = rFAILED) Then Exit Function
    
    If (parser.GetIdentifier(strValue) = rFAILED) Then Exit Function
    If (strValue <> "VALUES") Then Exit Function
    
    ' Read the list of values
    
    If (parser.GetChar("(") = rFAILED) Then Exit Function
    lngVarCount = 1
    Do While (parser.EOS = rFALSE)
    
        parser.PushBytesIndex
        booIsStr = (parser.GetChar("""") = rSUCCEED)
        parser.PopBytesIndex
        If (booIsStr) Then
            If (Not parser.GetString(strValue) = rSUCCEED) Then Exit Function ' Syntax error
            lngType = vbString ' Here we have a string
        Else
            ' Get the value as an id
            If (parser.GetIdentifier(strValue, False) = rSUCCEED) Then
                If (IsNumeric(strValue)) Then
                    If (parser.IsLong(strValue)) Then
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
                ElseIf (parser.IsBool(strValue)) Then
                    lngType = vbBoolean
                    varValue = CBool(strValue)
                Else
                    varValue = strValue
                End If
        End Select
        ' Address the var with the index
        Me.SetValue lngVarCount, varValue, lngType
        lngVarCount = lngVarCount + 1
        
        If (parser.GetChar(lngSepa) = rFALSE) Then Exit Do
    Loop

    If (parser.GetChar(")") = rFAILED) Then Exit Function
    
    LoadInsertSet = True
    Exit Function
ErrMgr:
Resume
End Function

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
Public Function SetValue(vntKey As Variant, Optional varValue As Variant, Optional varVbType As Variant) As Boolean

    On Error GoTo ErrMgr
      
    Dim clsV As CVariable
    
    Set clsV = Me.Item(vntKey)
    If (clsV Is Nothing) Then Exit Function
    
    If (Not IsMissing(varValue)) Then clsV.Value = varValue
    
    If (Not IsMissing(varVbType)) Then clsV.VbType = varVbType
    
    SetValue = True
    
    Exit Function
ErrMgr:
    
End Function

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
Public Property Get Collection() As Collection
    Set Collection = mCol
End Property
