Attribute VB_Name = "modEnumTypeReader"
Option Explicit

' Private mobjLocaleTranslator    As COMLocaleTranslator


' --------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : LoadEnumTypeData
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Sub LoadLocalizedEnumTypeData(ByVal icstrLanguage As String, _
                                    ByVal icstrNameSpace As String, _
                                    ByVal icstrEnumTypeName As String, _
                                    ByRef ocolstrValues As Collection, _
                                    ByRef ocolstrText As Collection)
          
On Error GoTo LoadLocalizedEnumTypeDataErr

    Dim objDataAccessor                 As COMDataAccessor
    Dim objLocalizedEnumTypeRowSet
    Dim strTemp                        As String
    Dim mobjLocaleTranslator    As COMLocaleTranslator
            
    ' create the data accessor com object
    
    'If mobjLocaleTranslator Is Nothing Then
        Set objDataAccessor = New COMDataAccessor
        Set mobjLocaleTranslator = objDataAccessor.GetLocaleTranslator
        Call mobjLocaleTranslator.Init(icstrLanguage)
        mobjLocaleTranslator.LanguageCode = icstrLanguage
    'End If
    
        
    Set objLocalizedEnumTypeRowSet = mobjLocaleTranslator.GetLocaleListForEnumTypes(icstrLanguage, icstrNameSpace, icstrEnumTypeName)
    Set ocolstrValues = New Collection
    Set ocolstrText = New Collection
    
    Do While Not objLocalizedEnumTypeRowSet.EOF
        Dim strLocalized
        strLocalized = objLocalizedEnumTypeRowSet.Value("LocalizedString")
        If Len(strLocalized) = 0 Then
            strLocalized = "{" & objLocalizedEnumTypeRowSet.Value("Enumerator") & "}"
        End If
        
        'ocolstrText.Add objLocalizedEnumTypeRowSet.Value("LocalizedString")
        ocolstrText.Add strLocalized
        ocolstrValues.Add objLocalizedEnumTypeRowSet.Value("Enumerator")
        objLocalizedEnumTypeRowSet.MoveNext
    Loop
    
    Exit Sub
    
LoadLocalizedEnumTypeDataErr:
    strTemp = Replace(MTTRReader_ERROR_02506, "[LANGUAGE]", icstrLanguage)
    strTemp = Replace(strTemp, "[ENUM_SPACE]", icstrNameSpace)
    strTemp = Replace(strTemp, "[ENUM_TYPE]", icstrEnumTypeName)
    strTemp = Replace(strTemp, "[ERR_NUM]", CStr(Err.Number))
    strTemp = Replace(strTemp, "[ERR_MSG]", Err.Description)
    Err.Clear
    Call RaiseError(strTemp, , , LOG_WARNING)
End Sub

