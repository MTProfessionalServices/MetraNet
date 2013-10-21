VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CHtmlParser"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
'****************************************************************************************************************************************************
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
'****************************************************************************************************************************************************
' CLASS         : CHtmlParser
' AUTHOR        : F.Torres
' CREATION DATE : 08/xx/2000
' VERSION       : 1.0
' DESCRIPTION   : First note this class is private. This class implement the MDM HTML Rendering process.
'                 Some errors are printed in red/bold into the screen to tell the programmer that something is wrong.
'
' MODIFIED      : $Date: 10/29/2002 1:16:04 PM$
' LAST AUTHOR   : $Author: Frederic Torres$
' REVISION      : $Revision: 61$
' FILENAME      : $Workfile: C:\builds\v3.5\Development\Shared\MSIXHandler\CHtmlParser.cls$
'
'****************************************************************************************************************************************************
Option Explicit

Public TRACE_ID As Long

Public VBRunTimeError   As String

Public Enum eHTMLPARSER_ERROR_FLAG

    eHTMLPARSER_ERROR_FLAG_OK = 1
    eHTMLPARSER_ERROR_FLAG_TAG_NOT_FOUND = 2
    
    eHTMLPARSER_ERROR_FLAG_ATTRIBUT_NAME_NOT_FOUND = 4
    eHTMLPARSER_ERROR_FLAG_ATTRIBUT_NAME_NOT_FOUND_BUT_OK = eHTMLPARSER_ERROR_FLAG_ATTRIBUT_NAME_NOT_FOUND + eHTMLPARSER_ERROR_FLAG_OK
    
    eHTMLPARSER_ERROR_FLAG_FAILED = 8
    eHTMLPARSER_ERROR_FLAG_VB_RUN_TIME_ERROR = 16
    eHTMLPARSER_ERROR_FLAG_NAME_NOT_FOUND_IN_SERVICE = 32
    eHTMLPARSER_ERROR_FLAG_SYNTAX_ERROR = 64
    eHTMLPARSER_ERROR_FLAG_NO_MORE_TAG = 128
End Enum

Private Const DCOTE = """"
Private Const GREATER_CHAR_ASCII = 62
Private Const DOUBLE_QUOTE_CHAR_ASCII = 34
Private Const SIMPLE_QUOTE_CHAR_ASCII = 39

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : HTMLProcessor()
' PARAMETERS    :
'                   objService As MSIXHandler - Was added for the MDM v2 to render a grid <MDMGRID>
'                   objService                - Was added for the MDM v2 to render a grid <MDMGRID>
' DESCRIPTION   :
' RETURN        :
Public Function HTMLProcessor(ByRef strHTML As String, ByVal strTag As String, objProperties As MSIXProperties, strTemplateFileName As String, strServiceName As String, Optional strOptionalValue As String, Optional strFormAction As String, Optional objDictionary As Dictionary, Optional objMDMConfiguration As MDMConfiguration, Optional objForm As MDMForm, Optional objService As MSIXHandler, Optional objPolicy As Object, Optional objSecurityConText As Object) As eHTMLPARSER_ERROR_FLAG
                                            ' The char ^ shows the position
    Dim lngTagStartPosition     As Long     ' Where the tag start : ^<INPUT>
    Dim lngTagPositionAfterTag  As Long     ' Where the tag start : <INPUT^  name='OK' ...>
    Dim lngTagEndPosition       As Long     ' Where the tag start : <INPUT  name='OK' ...>^
    Dim lngStart                As Long: lngStart = 1
    Dim lngPosJustAfterTag      As Long     ' Same as lngTagStartPosition! I beleive!
    Dim lngLoopCounter          As Long
    Dim lngSyntaxErrorPos       As Long
    Dim lngHEADTagPos           As Long
    Dim lngTmpPosition          As Long
    
    Dim bytValue                As Byte
    
    Dim strAttrValue            As String
    Dim strAttrName             As String
    Dim strImagePathSearch      As String
    Dim strImagePathReplace     As String
    Dim strNewTag               As String
    Dim strUCaseHTML            As String
    Dim strNameValue            As String
    Dim strChar                 As String
    Dim strValue                As String
    Dim strInternalErrorMessage As String
    Dim strHTMLAttributeDisable As String
    
    Dim varValue                As Variant
    
    Dim booOK                   As Boolean
    Dim objProperty             As MSIXProperty
    
    Dim objParser               As New CByteSyntaxAnalyser
    Dim objTagAttributs         As New CVariables
    Dim objProfiler             As New CProfiler
    Dim objTool                 As New MSIXTools
    Dim rcd                     As New MTRcd         ' create RCD
    
    'SECENG: These changes for integration SecurityFramework.Encoder subsystem
    Dim winPath
    Dim sfPath
    Dim SFCOM
    Dim sfProperties            As String
    Dim SfcomIsInitialize As Boolean
    'SECENG: Initialization of the security framework
    Set SFCOM = CreateObject("MetraTech.SecurityFramework.SFCOM")
    sfProperties = rcd.ConfigDir & "Security\Validation\MtSfConfigurationLoader.xml"
    TRACE sfProperties, "CHtmlParser.cls", "HTMLProcessor:SecurityFramework configuration path"
    
    SFCOM.Initialize sfProperties
    
    On Error GoTo ErrMgr
    
    objProfiler.Start MTMSIX_PROFILER_ON, "CHtmlParser.cls", "HTMLProcessor", "Tag=" & strTag
    
    HTMLProcessor = eHTMLPARSER_ERROR_FLAG_FAILED                 ' Default value
  
    strTag = "<" & UCase$(strTag)
    Do
        lngLoopCounter = lngLoopCounter + 1
        strHTMLAttributeDisable = vbNullString
        
        strUCaseHTML = UCase$(strHTML)                               ' Process a find not case sensitive
        
        lngTagPositionAfterTag = InStr(lngStart, strUCaseHTML, strTag)  ' Find the tag for exemple <SELECT,<INPUT,<FORM
        
        If (lngTagPositionAfterTag = 0) Then                            ' No or no more tags found
        
            HTMLProcessor = IIf(lngLoopCounter = 1, eHTMLPARSER_ERROR_FLAG_TAG_NOT_FOUND, eHTMLPARSER_ERROR_FLAG_NO_MORE_TAG) + eHTMLPARSER_ERROR_FLAG_OK
            Exit Do
        End If
                                
        lngTagStartPosition = lngTagPositionAfterTag
        
        ' -- MDM BUG Found in 3.5 , if we have the <MDMLABEL> in a row and the first one value is less than the len of "MDMLABEL", then the second <MDMLABEL> is skipped
        ' Therefore we just skip the first char
        
        'lngStart = lngTagPositionAfterTag + Len(strTag)                 ' Prepare the next position for the next instr
        lngStart = lngTagPositionAfterTag + 1                           ' Prepare the next position for the next instr
        
        '  Debug info mid$(strHTML,lngTagPositionAfterTag,100)
        
        lngTagPositionAfterTag = lngTagPositionAfterTag + Len(strTag)       ' Prepare the position to start parsing...
                
        objParser.Init strHTML                                      ' Init the parser instance
        objParser.lngBytesIndex = lngTagPositionAfterTag - 1
        
        lngPosJustAfterTag = lngTagPositionAfterTag ' We store the pos just after the tag so we can insert attribut
                                                ' and the beginning of the tag rather than the end. This is important
                                                ' for the tag value.
                    
        ' Now that the tag is found, read all the attributs and put them into a collection
        If (objParser.EOS() = rSUCCEED) Then Exit Do
        
        objTagAttributs.Clear
        Do
            'objParser.KillSpace
            
            If (objParser.GetIdentifier(strAttrName) = rSUCCEED) Then ' Read the attribut
            
                If (objParser.GetChar("=") = rSUCCEED) Then
                
                    lngSyntaxErrorPos = objParser.lngBytesIndex
                    ' Read the name value
                    objParser.KillSpace
                    
                    bytValue = objParser.GetCByteChar() ' Test if the name is defined as a "" string or a '' string or as an id
                    
                    If (bytValue = DOUBLE_QUOTE_CHAR_ASCII) Or (bytValue = SIMPLE_QUOTE_CHAR_ASCII) Then
                    
                        booOK = objParser.GetString(strAttrValue, Chr(bytValue)) = rSUCCEED ' read as a string
                    Else
                        booOK = objParser.GetIdentifier(strAttrValue) = rSUCCEED ' read as an id
                    End If
                    If (Not booOK) Then GoTo SyntaxError
                    
                    objTagAttributs.Add strAttrName, strAttrValue
                    
                End If
            Else
                If (objParser.GetCByteChar() = GREATER_CHAR_ASCII) Then
                
                    objParser.NextChar
                    lngTagEndPosition = objParser.lngBytesIndex
                    Exit Do ' We read all the attributs
                Else
                    ' attribute with not value like CHECKED for exemple
                    objTagAttributs.Add strAttrName, strAttrName
                    objParser.NextChar
                End If
            End If
        Loop
                
        ' I test if the tag has a name. some tag may or do not have a name this is why there is this hard coded list
        ' MDM v2 - The tag <MDMGRID>,<MDMTABS> were added for the mdm v2
        If objTagAttributs.Exist("NAME") Or strTag = "<MDMSECURITY" Or strTag = "<MDMTABS" Or strTag = "<MDMGRID" Or strTag = "<LABEL" Or strTag = "<MDMLABEL" Or strTag = "<FORM" Or strTag = "<HEAD" Or strTag = "<IMG" Or strTag = "<LINK" Then     ' Search if the name is a property of the object or we are processing the <FORM>
               
            If objTagAttributs.Exist("NAME") Then
            
                Set objProperty = objProperties.Item(objTagAttributs("NAME").Value)
            End If
            
            If (objProperty Is Nothing) Then    ' If the attribute name does not match a property in the service
                                                ' try to find why! there are good and bad reason!
                                                
                If objTagAttributs.Exist("MultiLanguage") Then
                
'                    Debug.Assert 0
                    booOK = True ' when MultiLanguage the property does not exist as a IMTProperty but will have
                                 ' a special case for INPUT Textbox
                                                                
                ' I do not want to process the tag LINK based on the type but based on the HTML tag name
                ' that's why I have strTag <> "<LINK", see elseif that follow:
                ElseIf (objTagAttributs.Exist("TYPE")) And strTag <> "<LINK" And strTag <> "<LABEL" And strTag <> "<MDMLABEL" Then
                
                    Select Case UCase$(objTagAttributs("TYPE"))
                    
                        Case "HIDDEN":
'                            'Debug.Assert 0
                            booOK = False ' In that case it is ok we do nothing with <INPUT TYPE=HIDDEN NAME=XXXX> when name is not a properties - we use this tag for FredRunner
                            GoSub ReplaceTheImagePath
                            
                        Case "IMAGE", "HIDDEN":
                            booOK = False ' In that case it is ok we do nothing with <INPUT TYPE=IMAGE>
                            GoSub ReplaceTheImagePath
                            
                        Case Else
                            ' This is no more use full, but it could save us in the future so I keep it
                            If (Len(objTagAttributs("NAME").Value) > 3) Then
                            
                                If (UCase$(Mid$(objTagAttributs("NAME").Value, 1, 3)) = "MDM") Then   ' This is a mdm field! Probably mdmAction as type=hidden
                                                                                                    ' for a refresh! We will just ignore it.
                                    booOK = False
                                Else
                                    GoSub WarningPropertyNotFound: booOK = False
                                End If
                            Else
                                GoSub WarningPropertyNotFound: booOK = False
                            End If
                    End Select
                    
                ElseIf (strTag = "<MDMSECURITY") Or (strTag = "<MDMTABS") Or (strTag = "<MDMGRID") Or (strTag = "<FORM") Or (strTag = "<HEAD") Or (strTag = "<LABEL") Or (strTag = "<MDMLABEL") Then
                
                    booOK = True ' It is a form,head, there is no property to match but we want to ad some code after <FORM>
                                 ' If a label reference a dictionary entry there is no match with a service property name
                    
                ElseIf (strTag = "<IMG") Then ' we do not process <IMG> but we check the path
                
                    booOK = False
                    GoSub ReplaceTheImagePath
                
                ElseIf (strTag = "<LINK") Then ' we do not process <IMG> but we check the path
                
                    booOK = False
                    GoSub RemoveLinkTags
                Else
                    If UCase$(Mid(objTagAttributs("NAME").Value, 1, 3)) = "MDM" Then
                    
                        booOK = False
                    Else
                        GoSub WarningPropertyNotFound
                        booOK = False
                    End If
                End If
            Else
                ' If the object match the a service/com object property and the enabled is false
                ' we manually add the attribute disabled=true
                If (objProperty.Enabled = False) Then
                        strHTMLAttributeDisable = HTML_ATTIBUTE_DISABLED
                End If
                
                '#Local strValue = "" & FormatData(objProperty.Value, objProperty.Format)
                strValue = "" & FormatDataLocalized(objProperty.Value, objDictionary)
                
                booOK = True
            End If
                        
            If (booOK) Then
                
                Select Case strTag ' Now we search for the > end of the tag
                
                    Case "<MDMGRID" ' The MetraTech Tag - MDM v2
                    
                        If (ClearCloseTag(strHTML, lngTagStartPosition, "MDMGRID")) Then  ' Clear the tag from <MDMGRID> to </GRID>
                        
                            If (objForm.Grids.Exist(objTagAttributs("NAME"))) Then
                            
                                strValue = objForm.Grids.Item(objTagAttributs("NAME")).HTMLRendered
                                strHTML = InsertAStringAt(strHTML, strValue, lngTagStartPosition)  ' +1 because the parser start at 0
                            Else
                                GoTo GridNotFound
                            End If
                        End If
                        
'                    Case "<MDMTABS" ' The MetraTech Tag - MDM v2
'
'                        If (ClearCloseTag(strHTML, lngTagStartPosition, "MDMTABS")) Then  ' Clear the tag from <MDMGRID> to </GRID>
'
'                                ' We already test that the tabs contains item
'
'                                strValue = objForm.Tabs.HTMLRendered
'                                strHTML = InsertAStringAt(strHTML, strValue, lngTagStartPosition)  ' +1 because the parser start at 0
'                        End If
                        
                    Case "<MDMSECURITY" ' MDM v3.0
                            Dim arrCapabilities As Variant
                            Dim strOperator As String
                            Dim bClear As Boolean
                            Dim cap As Variant
                            
                            bClear = True
                                                        
                            If (objTagAttributs.Exist("Capabilities")) Then
                                
                                arrCapabilities = Split(objTagAttributs.Item("Capabilities").Value, ",")
                                
                                If (objTagAttributs.Exist("Operator")) Then
                                  strOperator = objTagAttributs.Item("Operator").Value
                                Else
                                  strOperator = "AND"
                                End If
                                
                                For Each cap In arrCapabilities
                                   Select Case UCase(strOperator)
                                     Case "AND"
                                       If CheckCoarseCapability(objPolicy, objSecurityConText, CStr(Trim(cap)), "") Then
                                         bClear = False
                                       Else
                                         bClear = True
                                         Exit For
                                       End If
                                     
                                     Case "OR"
                                       If CheckCoarseCapability(objPolicy, objSecurityConText, CStr(Trim(cap)), "") Then
                                          bClear = False
                                          Exit For
                                       End If
                                   End Select
                                Next
                                
                                If bClear Then
                                   ClearCloseTag strHTML, lngTagStartPosition, "MDMSECURITY"
                                Else
                                   ' Clear the tag <MDMSECURITY ...>
                                   Mid(strHTML, lngTagStartPosition, lngTagEndPosition - lngTagStartPosition + 1) = Space(lngTagEndPosition - lngTagStartPosition + 1)
                                   
                                   
                                   ' Clear the tag </MDMSECURITY>
                                   lngTmpPosition = InStr(lngTagStartPosition, strUCaseHTML, "</MDMSECURITY>")
                                   Mid(strHTML, lngTmpPosition, Len("</MDMSECURITY>")) = Space(Len("</MDMSECURITY>"))
                                End If
 
                            Else
                                GoTo MDMSECURITYCapabilitiesNotDefined
                            End If
                        
                        
                    Case "<LABEL", "<MDMLABEL" ' The MetraTech Tag
                    
                        If (ClearCloseTag(strHTML, lngTagStartPosition, IIf(strTag = "<LABEL", "LABEL", "MDMLABEL"))) Then ' Clear the tag from <LABEL> to </LABEL>
                                                        
                                If (Not IsValidObject(objProperty)) Then ' Process label for a dictionary entry
                                
                                    If (objDictionary.Exist(objTagAttributs("NAME"))) Then
                                    
                                        strValue = objDictionary.Item(objTagAttributs("NAME"))
                                    Else
                                        
                                        If (objTagAttributs.Exist("TYPE")) Then ' MDM V2 - <MDMLABEL> And <LABEL> can display information directly from a MetraTech FQN
                                        
                                            Select Case UCase$(objTagAttributs("TYPE").Value)
                                            
                                                Case "FQN"

                                                    If (objTool.GetLocalizedString(objProperties.Language, objTagAttributs("NAME").Value, varValue)) Then
                                                    
                                                        strValue = varValue
                                                    Else
                                                        GoTo FQNNotFound
                                                    End If
                                                Case Else
                                                    GoTo MDMLABELEntryNotFound
                                            End Select
                                        Else
                                            GoTo MDMLABELEntryNotFound
                                        End If
                                   End If

                                Else    ' Process label for a service/productview property
                                    
                                    If (Not objTagAttributs.Exist("TYPE")) Then objTagAttributs.Add "TYPE", "Value" ' Add the default type
                                    
                                    Select Case UCase$(objTagAttributs("TYPE").Value) ' Find what kind of info we need to replace with
                                    
                                        Case "CAPTION":         strValue = objProperty.Caption
                                        
                                        ' #LOCAL Case "VALUE":           strValue ' FormatData()
                                        Case "VALUE":           strValue = FormatDataLocalized(strValue, objDictionary)
                                        
                                        Case "ABSOLUTEVALUE":   strValue = IIf(IsNumeric(strValue), Abs(strValue), strValue)
                                        Case "LOCALIZEDVALUE":  strValue = objProperty.LocalizedValue
                                        Case "LENGTH":          strValue = objProperty.Length
                                        Case "REQUIRED":        strValue = objProperty.Required
                                        Case "DEFAULTVALUE":    strValue = objProperty.DefaultValue
                                        Case "USERVISIBLE":     strValue = objProperty.UserVisible
                                        Case "TYPE":            strValue = objProperty.PropertyType
                                        Case Else ' Type unknow
                                            GoTo ErrorAttributeTypeRequired ' Type not found
                                    End Select
                                End If
                                strHTML = InsertAStringAt(strHTML, strValue, lngTagStartPosition)  ' +1 because the parser start at 0
                        Else
                            GoTo HTMLTagSyntaxError
                        End If
                        
                    
                    Case "<SELECT" ' we add just after the tag
                        
                        If (objProperty.IsEnumType()) Then
                        
                            strValue = objProperty.EnumType.GetHTMLOptionTags()
                        Else
                            ' Trace a warning
                            TRACE Replace(MTMSIX_ERROR_01005, "[NAME]", objProperty.Name), "MTMSIX:CHtmlParser", "HTMLProcessor", LOG_WARNING
                            strValue = ""
                        End If
                        strHTML = InsertAStringAt(strHTML, strValue, lngTagEndPosition + 1)  ' +1 because the parser start at 0
                        strHTML = InsertAStringAt(strHTML, strHTMLAttributeDisable, lngTagPositionAfterTag) ' +1 because the parser start at 0
                        
                        
                    Case "<TEXTAREA" ' Here we need to add MaxLength before > the tag and the value after
                                     ' I add a > after the MaxLength and replace the real > with a space
                                     ' Actually the MaxLength is not used but I keep it.
                                     
                        ' #LOCAL strValue = FormatData(objProperty.Value, objProperty.Format)
                        If Not IsValueEmpty(objProperty.Value) Then
                            strValue = FormatDataLocalized(SFCOM.ForHtml(objProperty.Value), objDictionary)
                        Else
                            strValue = FormatDataLocalized(objProperty.Value, objDictionary)
                        End If
                        
                        strHTML = InsertAStringAt(strHTML, strValue, lngTagEndPosition + 1) ' +1 because the parser start at 0
                        
                        GoSub CheckForHTMLAttributeDisable
                        strHTML = InsertAStringAt(strHTML, strHTMLAttributeDisable, lngTagPositionAfterTag) ' +1 because the parser start at 0
                        
                    Case "<INPUT" ' we add just before the tag
                    
                        strValue = ""
                        If objTagAttributs.Exist("TYPE") Then
                        
                            Select Case UCase$(objTagAttributs.Item("TYPE"))
                            
                                Case "RADIO"
                                    If objTagAttributs.Exist("VALUE") Then
                                    
                                        If UCase$(objTagAttributs("VALUE").Value) = UCase$(objProperty.Value) Then strValue = " CHECKED "
                                    End If
                                    strHTML = InsertAStringAt(strHTML, strHTMLAttributeDisable, lngTagPositionAfterTag) ' +1 because the parser start at 0
                                    
                                Case "CHECKBOX"
                                    ' In the case of the check box we need to add just after a <INPUT Type='hidden'> to resolve the
                                    ' case when the check box is not selected because there is nothing in the query string.
                                    ' This is a problem is HTML 3.2.
                                    ' We do not care about the value but with this tag we mark that there is a checkbox name
                                    ' see attribute name that if there is not value in the query string imply that the value
                                    ' is FALSE.
                                    strValue = "<INPUT Type=""Hidden"" Value=""1"" Name=""mdm_CheckBox_" & objProperty.Name & """ > "
                                    strHTML = InsertAStringAt(strHTML, strValue, lngTagEndPosition + 1) ' +1 because the parser start at 0
                                    
                                    ' TRACE "KEVIN PROBLEM: property name=" & objProperty.Name & " value=" & objProperty.Value, , , LOG_WARNING
                                    
                                    ' Add the normal value the regular way
                                    strValue = IIf(objProperty.BooleanValue, " CHECKED ", "")
                                    strHTML = InsertAStringAt(strHTML, strHTMLAttributeDisable, lngTagPositionAfterTag) ' +1 because the parser start at 0
                                    
                                Case "TEXT", "PASSWORD"
                                    
'                                    Debug.Assert 0
                                    If objTagAttributs.Exist("MultiLanguage") Then ' We use ProcessHTMLSpecialChars() to replace chars like '," correctly
                                    
                                        'Debug.Assert 0
                                    
                                        If UCase$(objTagAttributs.Item("MultiLanguage").Value) = "TRUE" Then
                                        
                                            Mid$(strHTML, lngTagStartPosition, lngTagEndPosition - lngTagStartPosition + 1) = Space(lngTagEndPosition - lngTagStartPosition + 1)
                                            
                                            
                                            Dim objLanguageList As New MetraTech_Localization.LanguageList
                                            Dim varLanguage
                                            Dim objHTMLAttr As CVariable
                                            strValue = ""
                                            
                                            Dim varLanguageInfo
                                            For Each varLanguage In objLanguageList.CodesInPreferredOrder
                                            
                                                strValue = strValue & "<INPUT "
                                                
                                                For Each objHTMLAttr In objTagAttributs
                                                
                                                    Select Case UCase$(objHTMLAttr.Name)
                                                        Case "MULTILANGUAGE"
                                                            ' do nothing
                                                        Case "NAME", "ID"
                                                            strValue = strValue & objHTMLAttr.Name & "=""" & objHTMLAttr.Value & "__" & varLanguage & """ "
                                                        Case Else
                                                            strValue = strValue & objHTMLAttr.Name & "=""" & objHTMLAttr.Value & """ "
                                                    End Select
                                                Next
                                                Set varLanguageInfo = objLanguageList.GetLanguageInformationFromCode(varLanguage)
                                                strValue = strValue & ">" & GetLanguageDisplayInformation(varLanguage, objDictionary) & "<br>"
                                            Next
                                        End If
                                    Else
                                        GoSub CheckForHTMLAttributeDisable
                                        

                                        ' BUG:8487 - Process special chare like "
                                        ' #LOCAL strValue = strHTMLAttributeDisable & " Value=""" & FormatData(ProcessHTMLChar("" & objProperty.Value), objProperty.Format) & """ "      ' Set the attribute value
                                        'SECENG:
										On Error Resume Next
                                        If Not IsValueEmpty(objProperty.Value) Then
                                            strValue = strHTMLAttributeDisable & " Value=""" & FormatDataLocalized(SFCOM.ForHtmlAttr(objProperty.Value), objDictionary) & """ "      ' Set the attribute value
                                        Else
                                            strValue = strHTMLAttributeDisable & " Value=""" & FormatDataLocalized(objProperty.Value, objDictionary) & """ "      ' Set the attribute value
                                        End If
										
										If (Err.Number) Then
	                                         strValue = strHTMLAttributeDisable
 	                                         Err.Clear
 	                                    End If
 	                                    On Error GoTo ErrMgr
										   
                                        If (objProperty.Length) Then strValue = strValue & " MaxLength=""" & objProperty.Length & """ "      ' Set the MaxLen is defined
                                    End If
                                    
                                Case "HIDDEN"
                                    '#LOCAL strValue = " Value=""" & FormatData(objProperty.Value, objProperty.Format) & """ " ' Set the attribute value
                                    If Not IsNull(objProperty.Value) Then
                                        strValue = " Value=""" & FormatDataLocalized(SFCOM.ForHtmlAttr(objProperty.Value), objDictionary) & """ "  ' Set the attribute value
                                    Else
                                        strValue = " Value=""" & FormatDataLocalized(objProperty.Value, objDictionary) & """ "  ' Set the attribute value
                                    End If
                                    
                            End Select
                        Else
                            GoTo ErrorAttributeTypeRequired
                        End If
                        ' Add the attribute value in the tag
                        strHTML = InsertAStringAt(strHTML, strValue, lngPosJustAfterTag)   ' +1 because the parser start at 0
                        
                    Case "<FORM" ' we add just after the tag
                    
                        If (objTagAttributs.Exist("NAME")) Then
                        
                            If (UCase$(objTagAttributs.Item("NAME")) = "MDM") Then
                    
                                If (Len(strOptionalValue)) Then
                                    strValue = strOptionalValue
                                    strHTML = InsertAStringAt(strHTML, strValue, lngTagEndPosition + 1) ' +1 because the parser start at 0
                                End If
                                
                                If (Len(strFormAction)) Then

                                    strValue = " Method=" + DCOTE + objMDMConfiguration.HtmlFormMethod + DCOTE + " Action=""" & strFormAction & """ "
                                    strHTML = InsertAStringAt(strHTML, strValue, lngPosJustAfterTag)   ' +1 because the parser start at 0
                                End If
                            Else
                                ' Trace warning more that one <FORM> found
                                TRACE Replace(MTMSIX_ERROR_01021, "[FILE]", strTemplateFileName), "CHtmlParser.cls", "HTMLProcessor"
                            End If
                        End If
                        
                    Case "<HEAD" ' we add just after the tag <HEAD>
                    
                        If (Len(strOptionalValue)) Then
                            strValue = strOptionalValue
                            strHTML = InsertAStringAt(strHTML, strValue, lngTagEndPosition + 1) ' +1 because the parser start at 0
                        End If
                End Select
            End If
        Else
            GoTo NameNotFound ' The Tag as attribute name
        End If
    Loop
    objProfiler.UserDefinedText = objProfiler.UserDefinedText & " TagLoop=" & (lngLoopCounter - 1)
    
    If (strTag = "<LINK") Then GoSub AddNewTagsLink
    
    Exit Function
    
' Sub function


CheckForHTMLAttributeDisable:
    ' If the field is not enabled we set the HTML Attribut and change the style. We do not replace
    ' the class attribute we insert one at the beginning so the class attribute set at edit time is ignored.
    ' This is working with IE5 but may not be supported with IE4 or Netscape...
    If (Len(strHTMLAttributeDisable)) Then
    
        If (strTag = "<INPUT") Or (strTag = "<TEXTAREA") Then
        
            strHTMLAttributeDisable = HTML_ATTIBUTE_READ_ONLY
            strHTMLAttributeDisable = strHTMLAttributeDisable & " Class='fieldNonEditable' "
        End If
    End If
Return

' Localize image path
ReplaceTheImagePath:
                    
    
    
        If objTagAttributs.Exist("Localized") Then
        
            If (CBool(objTagAttributs.Item("Localized").Value)) Then
        
                If (Not ClearHTMLSource(strHTML, lngTagPositionAfterTag, lngTagEndPosition - lngTagPositionAfterTag)) Then GoTo ErrorParsingImagePath
                
                If (Not ProcessAttributSrcInAttributCollection(objTagAttributs, IIf(strTag = "<LINK", "HREF", "SRC"), objDictionary)) Then GoTo ErrorParsingImagePath
                strValue = BuildHTMLAttibut(objTagAttributs)
                strHTML = InsertAStringAt(strHTML, strValue, lngTagPositionAfterTag)
            End If
        End If
    
Return

AddNewTagsLink:

    lngHEADTagPos = InStr(UCase$(strHTML), HTML_HEAD_TAG)
    
    If (lngHEADTagPos) Then
    
        strHTML = InsertAStringAt(strHTML, BuildLocalizedLink(objDictionary), lngHEADTagPos + Len(HTML_HEAD_TAG))
    End If
Return


' Localize Style Sheet
RemoveLinkTags:
                    
    
    
        If objTagAttributs.Exist("Localized") Then
        
            If (CBool(objTagAttributs.Item("Localized").Value)) Then
        
                If (Not ClearHTMLSource(strHTML, lngTagPositionAfterTag - Len("<LINK"), Len("<LINK") + lngTagEndPosition - lngTagPositionAfterTag + 1)) Then GoTo ErrorParsingImagePath
                
                'strValue = "ZIZI"
                'strHTML = InsertAStringAt(strHTML, strValue, lngTagPositionAfterTag)
            End If
        End If
    
Return


' Trace Warning
WarningPropertyNotFound: ' Log just a warning
    strInternalErrorMessage = Replace(MTMSIX_ERROR_01009, "[TAG]", Mid$(strTag, 2))
    strInternalErrorMessage = Replace(strInternalErrorMessage, "[NAME]", objTagAttributs("NAME").Value)
    strInternalErrorMessage = Replace(strInternalErrorMessage, "[SERVICE]", strServiceName)
    TRACE strInternalErrorMessage, "CHtmlParser.cls", "HTMLProcessor", LOG_INFO ' Trace the error
Return

' Errors + Exit

ErrorDictionaryNotSet:
    strInternalErrorMessage = ""
    If (objTagAttributs.Exist("NAME")) Then strInternalErrorMessage = objTagAttributs.Item("NAME").Value
    strInternalErrorMessage = Replace(MTMSIX_ERROR_01043, "[NAME]", strInternalErrorMessage)
    strInternalErrorMessage = Replace(strInternalErrorMessage, "[TAG]", Mid$(strTag, 2))
    GoTo TraceInternalErrorMessageAndExitWithSyntaxError
    
ErrorDictionaryEntryNotFound:
    strInternalErrorMessage = ""
    If (objTagAttributs.Exist("NAME")) Then strInternalErrorMessage = objTagAttributs.Item("NAME").Value
    strInternalErrorMessage = Replace(MTMSIX_ERROR_01044, "[NAME]", strInternalErrorMessage)
    strInternalErrorMessage = Replace(strInternalErrorMessage, "[TAG]", Mid$(strTag, 2))
    GoTo TraceInternalErrorMessageAndExitWithSyntaxError
        
ErrorAttributeTypeRequired:
    strInternalErrorMessage = ""
    If (objTagAttributs.Exist("NAME")) Then strInternalErrorMessage = objTagAttributs.Item("NAME").Value
    strInternalErrorMessage = Replace(MTMSIX_ERROR_01037, "[NAME]", strInternalErrorMessage)
    strInternalErrorMessage = Replace(strInternalErrorMessage, "[TAG]", Mid$(strTag, 2))
    GoTo TraceInternalErrorMessageAndExitWithSyntaxError
    
MDMLABELEntryNotFound:

    strInternalErrorMessage = ""
    If (objTagAttributs.Exist("NAME")) Then strInternalErrorMessage = objTagAttributs.Item("NAME").Value
    strInternalErrorMessage = Replace(MTMSIX_ERROR_01088, "[NAME]", strInternalErrorMessage)
    strInternalErrorMessage = Replace(strInternalErrorMessage, "[TAG]", Mid$(strTag, 2))
    GoTo TraceInternalErrorMessageAndExitWithSyntaxError
    
    
MDMSECURITYCapabilitiesNotDefined:
    strInternalErrorMessage = ""
    If (objTagAttributs.Exist("NAME")) Then strInternalErrorMessage = objTagAttributs.Item("NAME").Value
    strInternalErrorMessage = Replace(MTMSIX_ERROR_01093, "[NAME]", strInternalErrorMessage)
    strInternalErrorMessage = Replace(strInternalErrorMessage, "[TAG]", Mid$(strTag, 2))
    GoTo TraceInternalErrorMessageAndExitWithSyntaxError
    
    
FQNNotFound:
    strInternalErrorMessage = ""
    If (objTagAttributs.Exist("NAME")) Then strInternalErrorMessage = objTagAttributs.Item("NAME").Value
    strInternalErrorMessage = Replace(MTMSIX_ERROR_01089, "[FQN]", strInternalErrorMessage)
    strInternalErrorMessage = Replace(strInternalErrorMessage, "[TAG]", Mid$(strTag, 2))
    GoTo TraceInternalErrorMessageAndExitWithSyntaxError
    
HTMLTagSyntaxError:
    strInternalErrorMessage = ""
    If (objTagAttributs.Exist("NAME")) Then strInternalErrorMessage = objTagAttributs.Item("NAME").Value
    strInternalErrorMessage = Replace(MTMSIX_ERROR_01042, "[NAME]", strInternalErrorMessage)
    strInternalErrorMessage = Replace(strInternalErrorMessage, "[TAG]", Mid$(strTag, 2))
    GoTo TraceInternalErrorMessageAndExitWithSyntaxError

ErrorParsingImagePath:
    strInternalErrorMessage = ""
    If (objTagAttributs.Exist("NAME")) Then strInternalErrorMessage = objTagAttributs.Item("NAME").Value
    strInternalErrorMessage = Replace(MTMSIX_ERROR_01020, "[NAME]", strInternalErrorMessage)
    GoTo TraceInternalErrorMessageAndExitWithSyntaxError
    
NameNotFound:
    strInternalErrorMessage = Replace(MTMSIX_ERROR_01008, "[TAG]", Mid$(strTag, 2))
    strInternalErrorMessage = Replace(strInternalErrorMessage, "[FILE]", strTemplateFileName)
    GoTo TraceInternalErrorMessageAndExitWithSyntaxError
    
GridNotFound:
    strInternalErrorMessage = PreProcess(MTMSIX_ERROR_01083, "NAME", objTagAttributs("NAME").Value, "[FILE]", strTemplateFileName)
    GoTo TraceInternalErrorMessageAndExitWithSyntaxError
    
    
SyntaxError:
    strInternalErrorMessage = Replace(MTMSIX_ERROR_01010, "[FILE]", strTemplateFileName)
    strInternalErrorMessage = Replace(strInternalErrorMessage, "[TEXT]", Mid$(strHTML, lngSyntaxErrorPos, 100))
    GoTo TraceInternalErrorMessageAndExitWithSyntaxError
        
TraceInternalErrorMessageAndExitWithSyntaxError:
    TRACE strInternalErrorMessage, "CHtmlParser.cls", "HTMLProcessor", LOG_ERROR ' Trace the error
    strHTML = strHTML & FormatHTMLError(strInternalErrorMessage)
    HTMLProcessor = eHTMLPARSER_ERROR_FLAG_SYNTAX_ERROR
Exit Function
        
ErrMgr: ' Standard VB Error handler - just in case...

    VBRunTimeError = GetVBErrorString()
    TRACE MTMSIX_ERROR_01033 & " " & VBRunTimeError, "CHtmlParser.cls", "HTMLProcessor", LOG_ERROR
    HTMLProcessor = eHTMLPARSER_ERROR_FLAG_VB_RUN_TIME_ERROR
    
End Function


' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Private Function InsertAStringAt(ByRef strSourceString As String, strInsertString As String, lngPos As Long) As String

    On Error GoTo ErrMgr

    InsertAStringAt = Mid$(strSourceString, 1, lngPos - 1) & strInsertString & Mid$(strSourceString, lngPos)
    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "CHtmlParser.cls", "InsertAStringAt", LOG_ERROR
End Function



' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Private Function ClearHTMLSource(ByRef strHTML As String, ByVal lngStartPos As Long, ByVal lngCharCount As Long) As Boolean

    On Error GoTo ErrMgr

    Dim i As Long
    
    For i = lngStartPos To lngStartPos + lngCharCount - 1
    
        Mid$(strHTML, i, 1) = Chr(32)
    Next
    ClearHTMLSource = True

    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "CHtmlParser.cls", "ClearHTMLSource", LOG_ERROR
End Function


' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Function ProcessAttributSrcInAttributCollection(objAttributs As CVariables, strHTMLAttribut As String, Optional objDictionary As Dictionary) As Boolean

    On Error GoTo ErrMgr

    Dim objSRC          As CVariable
    Dim objTextFile     As New cTextFile
    Dim strTagError     As String
    
    
    
    ProcessAttributSrcInAttributCollection = True
    
    If (objAttributs.Exist(strHTMLAttribut)) Then
        
        Set objSRC = objAttributs.Item(strHTMLAttribut)
        
        If (objDictionary.Exist("DEFAULT_PATH_SEARCH")) Then
        
            If (objDictionary.Exist("DEFAULT_PATH_REPLACE")) Then
        
                objSRC.Value = Replace(LCase(CStr(objSRC.Value)), LCase(objDictionary.Item("DEFAULT_PATH_SEARCH").Value), LCase(objDictionary.Item("DEFAULT_PATH_REPLACE").Value))
            Else
                strTagError = "DEFAULT_PATH_REPLACE": GoSub TraceError
            End If
        Else
            strTagError = "DEFAULT_PATH_SEARCH": GoSub TraceError
        End If
        
        If (objDictionary.Exist("CUSTOM_PATH_SEARCH")) Then
        
            If (objDictionary.Exist("CUSTOM_PATH_REPLACE")) Then
            
                objSRC.Value = Replace(LCase(CStr(objSRC.Value)), LCase(objDictionary.Item("CUSTOM_PATH_SEARCH").Value), LCase(objDictionary.Item("CUSTOM_PATH_REPLACE").Value))
            Else
                strTagError = "CUSTOM_PATH_REPLACE": GoSub TraceError
            End If
        Else
            strTagError = "CUSTOM_PATH_SEARCH": GoSub TraceError
        End If
    End If
    Exit Function
    
TraceError:
    TRACE Replace(MTMSIX_ERROR_01040, "[ENTRY]", strTagError), "CHtmlParser.cls", "ProcessAttributSrcInAttributCollection", LOG_ERROR
    ProcessAttributSrcInAttributCollection = False
Return

ErrMgr:
      TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "CHtmlParser.cls", "ProcessAttributSrcInAttributCollection", LOG_ERROR
End Function



' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Private Function BuildHTMLAttibut(objAttributs As CVariables) As String

    On Error GoTo ErrMgr

    Dim objSRC          As CVariable
    Dim strS            As String
    Const DCOTE = """"
    
    strS = strS & " "
    For Each objSRC In objAttributs
    
        strS = strS & objSRC.Name & "=" & DCOTE & objSRC.Value & DCOTE & " "
    Next
    BuildHTMLAttibut = strS
    

    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "CHtmlParser.cls", "BuildHTMLAttibut", LOG_ERROR
End Function


Private Function ClearCloseTag(strHTML As String, ByVal lngTagPositionAfterTag As Long, ByVal strTag As String) As Boolean

    On Error GoTo ErrMgr


    Dim lngTagEndPosition    As Long
    Dim strEndTag       As String
    
    strEndTag = UCase$("</" & strTag & ">")
    ' Search from the current pos the /TAG in upper case
    lngTagEndPosition = InStr(lngTagPositionAfterTag, UCase$(strHTML), strEndTag)
    
    If (lngTagEndPosition) Then ' If found
    
        lngTagEndPosition = lngTagEndPosition + Len(strEndTag) ' Get the end with the /TAG
        ' Here we delete the char - we have to because if we let the space there always 1 unexpected white char visible before the data
        DeleteHTMLSource strHTML, lngTagPositionAfterTag, lngTagEndPosition - lngTagPositionAfterTag + 1
        ClearCloseTag = True
    End If
    

    Exit Function
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "CHtmlParser.cls", "ClearCloseTag", LOG_ERROR
End Function



' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Private Function FormatHTMLError(strErrorMessage As String) As String

    On Error GoTo ErrMgr


    FormatHTMLError = Replace(g_strHTMLTemplateUIErrorMessage, "[MESSAGE]", strErrorMessage)

    Exit Function
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "CHtmlParser.cls", "FormatHTMLError", LOG_ERROR
End Function



' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Private Function DeleteHTMLSource(ByRef strHTML As String, ByVal lngStartPos As Long, ByVal lngCharCount As Long) As Boolean

    On Error GoTo ErrMgr


    Dim i As Long
    
    strHTML = Mid$(strHTML, 1, lngStartPos - 1) & Mid$(strHTML, lngStartPos + lngCharCount - 1)
    DeleteHTMLSource = True

    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "CHtmlParser.cls", "ClearHTMLSource", LOG_ERROR
End Function

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Private Function BuildLocalizedLink(objDictionary As Dictionary) As String

    Dim strPathReplace              As String
    Dim strHttpPathReplace          As String
    Dim strStylesRelativePathFolder As String
    Dim strHTMLLinks                As String
    
    Dim objTextFile                 As New cTextFile
    Dim objPP                       As New CPreProcessor
    Dim objFiles                    As New CVariables
    Dim objFile                     As CVariable
    
    On Error GoTo ErrMgr
    
    
    strHTMLLinks = vbNewLine
            
    '
    ' First let us read and build the string for the default style sheet
    '
    strHttpPathReplace = objDictionary(MDM_DEFAULT_IMAGE_PATH_REPLACE)      ' Get the HTTP path for replace
    objPP.Add "DEFAULT_PATH_REPLACE", strHttpPathReplace                    ' Store the value in the pre-processor
    
    strPathReplace = objDictionary(MDM_DEFAULT_IMAGE_PATH_REPLACE_FOLDER)   ' Get the folder path for replace, this entry is added by the VBSCRIPT mdm
                                                                            ' function mdm_PopulateDictionaryWithInternalStuff()
                                                                                                                                        
    strStylesRelativePathFolder = "\" & objDictionary.GetValue(MDM_STYLES_RELATIVE_PATH, "styles")
    objFiles.Clear
    If (objTextFile.GetFilesList(strPathReplace & strStylesRelativePathFolder, WILDCARD_EXTENSION_CSS, objFiles)) Then  ' Read all the .CSS file stored
    
        For Each objFile In objFiles ' For each css file build a <LINK TAG>
        
            objPP.Add "FILE_NAME", objFile.Name
            'strHTMLLinks = strHTMLLinks & "<!-- Default Localized Link -->" & vbNewLine
            strHTMLLinks = strHTMLLinks & objPP.Process("<LINK rel='STYLESHEET' type='text/css' href='[DEFAULT_PATH_REPLACE]/styles/[FILE_NAME]'>", "[", "]") & vbNewLine
        Next
    End If
    '
    ' Second let us read and build the string for the custom style sheet
    '
    strHttpPathReplace = objDictionary(MDM_CUSTOM_IMAGE_PATH_REPLACE)       ' Get the HTTP path for replace
    objPP.Add "CUSTOM_PATH_REPLACE", strHttpPathReplace             ' Store the value in the pre-processor
    
    strPathReplace = objDictionary(MDM_CUSTOM_IMAGE_PATH_REPLACE_FOLDER)   ' Get the folder path for replace, this entry is added by the VBSCRIPT mdm
                                                                   ' function mdm_PopulateDictionaryWithInternalStuff()

    objFiles.Clear
    If (objTextFile.GetFilesList(strPathReplace & strStylesRelativePathFolder, WILDCARD_EXTENSION_CSS, objFiles)) Then ' Read all the .CSS file stored
    
        For Each objFile In objFiles ' For each css file build a <LINK TAG>
        
            objPP.Add "FILE_NAME", objFile.Name
            strHTMLLinks = strHTMLLinks & "<!-- Custom Localized Link -->" & vbNewLine
            strHTMLLinks = strHTMLLinks & objPP.Process("<LINK rel='STYLESHEET' type='text/css' href='[CUSTOM_PATH_REPLACE]/styles/[FILE_NAME]'>", "[", "]") & vbNewLine
        Next
    End If
    BuildLocalizedLink = strHTMLLinks
        
    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "CHtmlParser.cls", "BuildLocalizedLink", LOG_ERROR
End Function

Public Function HTMLWidgetsProcessor(ByRef strHTML As String, objWidgets As MDMWidgets) As Boolean

    On Error GoTo ErrMgr
    
    Dim objWidget As MDMWidget
    
    For Each objWidget In objWidgets
    
        HTMLWidgetProcessor strHTML, objWidget
    Next
    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "CHtmlParser.cls", "HTMLWidgetsProcessor", LOG_ERROR
End Function


Private Function HTMLWidgetProcessor(ByRef strHTML As String, objWidget As MDMWidget) As Boolean

    On Error GoTo ErrMgr
    
    Dim strHeader As String
    Dim strFooter As String
    Dim lngPos    As Long
    Dim strHTMLUCase As String

    strHTMLUCase = UCase(strHTML)
    
    strHeader = objWidget.GetHeader()
    If (Len(strHeader)) Then
        lngPos = InStr(strHTMLUCase, HTML_HEAD_TAG)
        If (lngPos) Then
            strHTML = InsertAStringAt(strHTML, strHeader, lngPos + Len(HTML_HEAD_TAG))
        End If
    End If
    
    strHTMLUCase = UCase(strHTML)
    strFooter = objWidget.GetFooter()
    If (Len(strFooter)) Then
        lngPos = InStr(strHTMLUCase, HTML_FORM_CLOSE_TAG)
        If (lngPos) Then
            strHTML = InsertAStringAt(strHTML, strFooter, lngPos + Len(HTML_FORM_CLOSE_TAG))
        End If
    End If
    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "CHtmlParser.cls", "HTMLWidgetProcessor", LOG_ERROR
End Function

Public Function ConditionalRendering(ByRef strHTML As String, ByVal objDictionary As Dictionary, ByVal MDMConditionalMark As String, booMDMElse As Boolean) As Boolean

    On Error GoTo ErrMgr
    
    Dim strHeader       As String
    Dim strFooter       As String
    Dim lngPos          As Long
    Dim lngEndPos       As Long
    Dim strHTMLUCase    As String
    Dim objParser       As New CByteSyntaxAnalyser
    Dim strInternalErrorMessage As String
    Dim strId           As String
    Dim lngIDEndPos     As Long
    Dim booConditional  As Boolean
    
    strHTMLUCase = UCase(strHTML)
    Do
        lngPos = InStr(strHTMLUCase, MDMConditionalMark)
        If (lngPos) Then
            ''Debug.Assert 0
            lngEndPos = InStr(lngPos, strHTMLUCase, MDM_CONDITIONAL_RENDERING_ENDIF)
            If (lngEndPos) Then
                objParser.Init strHTML
                objParser.lngBytesIndex = lngPos + Len(MDMConditionalMark) - 1 ' The parser start at 0 so we do -1
                lngIDEndPos = objParser.lngBytesIndex ' use this to find the length of the all strnig #MDMIF ......
                
                If (objParser.GetIdentifier(strId) = rSUCCEED) Then
                
                    ' Done by kevin b
                    If objDictionary.Exist(strId) Then
                    
                       booConditional = CBool(objDictionary.GetValue(strId))
                    Else
                        booConditional = False
                    End If
                    
                    If (booMDMElse) Then booConditional = Not booConditional
                    
                    If (booConditional) Then
                    
                        lngIDEndPos = objParser.lngBytesIndex - lngIDEndPos
                        ' We keep the code and remove the conditional tag
                        Mid(strHTML, lngPos, Len(strHTML) + Len(MDMConditionalMark) + lngIDEndPos - 1) = Space(Len(MDMConditionalMark) + lngIDEndPos)
                        Mid(strHTML, lngEndPos, Len(strHTML) + Len(MDM_CONDITIONAL_RENDERING_ENDIF) - 1) = Space(Len(MDM_CONDITIONAL_RENDERING_ENDIF))
                    Else
                        ' We erase the all portion of code
                        ClearHTMLSource strHTML, lngPos, lngEndPos - lngPos + 1 + Len(MDM_CONDITIONAL_RENDERING_ENDIF)
                    End If
                    strHTMLUCase = UCase$(strHTML)
                Else
                    strInternalErrorMessage = MTMSIX_ERROR_01085
                    GoTo TraceInternalErrorMessageAndExitWithSyntaxError
                End If
            Else
                strInternalErrorMessage = MTMSIX_ERROR_01084
                GoTo TraceInternalErrorMessageAndExitWithSyntaxError
            End If
        Else
            Exit Do
        End If
    Loop
    Exit Function
    ConditionalRendering = True
TraceInternalErrorMessageAndExitWithSyntaxError:
    TRACE strInternalErrorMessage, "CHtmlParser.cls", "ConditionalRendering", LOG_ERROR ' Trace the error
    strHTML = strHTML & FormatHTMLError(strInternalErrorMessage)
    
Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "CHtmlParser.cls", "ConditionalRendering", LOG_ERROR
End Function



Public Function ProcessMDMInclude(ByRef strHTML As String, ByVal objDictionary As Dictionary) As Boolean

    On Error GoTo ErrMgr
    
    Dim strHeader                   As String
    Dim strFooter                   As String
    Dim lngPos                      As Long
    Dim lngEndPos                   As Long
    Dim strHTMLUCase                As String
    Dim objParser                   As New CByteSyntaxAnalyser
    Dim strInternalErrorMessage     As String
    Dim strId                       As String
    Dim booConditional              As Boolean
    Dim strIncludeSourceFile        As String
    Dim strIncludeFileName          As String
    Dim objTextFile                 As New cTextFile
    Dim strIncludeSourceFileNameOnly        As String
    Dim lngMDMHTMLTagPos            As Long
    
    Const MDM_INCLUDE_TAG = "#MDMINCLUDE"
    Const MDM_HTML_TAG = "<MDMHTML>"
    Const MDM_INCLUDE_END_TAG = vbNewLine
    
    strHTMLUCase = UCase(strHTML)
    Do
        lngPos = InStr(strHTMLUCase, MDM_INCLUDE_TAG)
        If (lngPos) Then
'            'Debug.Assert 0
            lngEndPos = InStr(lngPos, strHTMLUCase, vbNewLine) ' Search end of line
            
            If (lngEndPos) Then
            
                objParser.Init strHTML
                objParser.lngBytesIndex = lngPos + Len(MDM_INCLUDE_TAG) - 1 ' The parser start at 0 so we do -1
                
                If (objParser.GetIdentifier(strId) = rSUCCEED) Then
                
                    If objDictionary.Exist(strId) Then
                    
                        strIncludeFileName = objDictionary.Item(strId).Value
                        
                        ' MDM v 3.5 - Include Dictionary Entry that contains HTML
                        lngMDMHTMLTagPos = InStr(UCase$(strIncludeFileName), "<MDMHTML>")
                        
                        If (lngMDMHTMLTagPos) Or (Len(Trim(strIncludeFileName)) = 0) Then
                        
                            ' Remove the <MDMHTML> Tag
                            If (lngMDMHTMLTagPos) Then Mid(strIncludeFileName, lngMDMHTMLTagPos, Len(MDM_HTML_TAG)) = Space(Len(MDM_HTML_TAG))
                            strIncludeSourceFile = strIncludeFileName
                            GoSub IncludeHTMLTemplate
                        
                        ElseIf objTextFile.ExistFile(strIncludeFileName) Then
                        
                            strIncludeSourceFileNameOnly = objTextFile.GetFileName(strIncludeFileName)
                            strIncludeSourceFile = objTextFile.LoadFile(strIncludeFileName)
                            GoSub IncludeHTMLTemplate
                        Else
                            
                            strInternalErrorMessage = PreProcess(MTMSIX_ERROR_01097, "FILENAME", strIncludeFileName) ' file not found
                            GoTo TraceInternalErrorMessageAndExitWithSyntaxError
                        End If
                    Else
                        ClearHTMLSource strHTML, lngPos, lngEndPos - lngPos
                    End If
                    strHTMLUCase = UCase$(strHTML)
                Else
                    strInternalErrorMessage = MTMSIX_ERROR_01096 ' Syntax error
                    GoTo TraceInternalErrorMessageAndExitWithSyntaxError
                End If
            Else
                strInternalErrorMessage = MTMSIX_ERROR_01095 ' MDMINclude parsing error
                GoTo TraceInternalErrorMessageAndExitWithSyntaxError
            End If
        Else
            Exit Do
        End If
    Loop
    ProcessMDMInclude = True
    Exit Function
    
IncludeHTMLTemplate:
    ' Add comment before and after the include
    strIncludeSourceFile = vbNewLine & "<!-- MDMINCLUDE " & strIncludeSourceFileNameOnly & " begin -->" & vbNewLine & strIncludeSourceFile
    strIncludeSourceFile = strIncludeSourceFile & vbNewLine & "<!-- MDMINCLUDE " & strIncludeSourceFileNameOnly & " end -->" & vbNewLine
    
    ClearHTMLSource strHTML, lngPos, lngEndPos - lngPos
    strHTML = InsertAStringAt(strHTML, strIncludeSourceFile, lngPos)
Return
    
TraceInternalErrorMessageAndExitWithSyntaxError:
    TRACE strInternalErrorMessage, "CHtmlParser.cls", "ProcessMDMInclude", LOG_ERROR ' Trace the error
    strHTML = strHTML & FormatHTMLError(strInternalErrorMessage)
Exit Function

ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "CHtmlParser.cls", "ProcessMDMInclude", LOG_ERROR
End Function

' BUG:8487 - Process special chare like "
Private Function ProcessHTMLChar(ByVal str As String) As String

    str = Replace(str, "<", "&lt;")
    str = Replace(str, ">", "&gt;")
    str = Replace(str, "&", "&amp;")
    str = Replace(str, """", "&quot;")
    
    ProcessHTMLChar = str
End Function


Public Function HTMLWidgetsProcessorPVB(ByVal strHTML As String, ByVal objWidgets As MDMWidgets) As String
  Dim strHTMLResult As String
  strHTMLResult = strHTML
  HTMLWidgetsProcessor strHTMLResult, objWidgets
HTMLWidgetsProcessorPVB = strHTMLResult
End Function

Public Function GetLanguageDisplayInformation(sLanguageCode, objDictionary) As String
  Dim sDictionaryEntryCacheName
  sDictionaryEntryCacheName = "LANGUAGECODE_DISPLAYINFORMATION_CACHE_" & UCase(sLanguageCode)
  
  If (Not objDictionary.Exist(sDictionaryEntryCacheName)) Then
    'We need to build the cache entry for this language
    Dim sDictionaryEntryName
    sDictionaryEntryName = "LANGUAGECODE_DISPLAYINFORMATION_" & UCase(sLanguageCode)
    
    Dim sDisplayName
    If objDictionary.Exist(sDictionaryEntryName) Then
        sDisplayName = objDictionary.Item(sDictionaryEntryName)
    Else
        sDisplayName = sLanguageCode
    End If
    
    Dim objLanguageList As New MetraTech_Localization.LanguageList
    Dim varLanguageInfo
    Set varLanguageInfo = objLanguageList.GetLanguageInformationFromCode(sLanguageCode)
    
    Dim sFilePath
    sFilePath = objDictionary.Item("PATH_COMMON") & "\images\language\" & sLanguageCode & ".gif"
    If Dir$(sFilePath) <> "" Then
      objDictionary.Add sDictionaryEntryCacheName, " <span title='" & varLanguageInfo.Code & " " & varLanguageInfo.Id & vbNewLine & varLanguageInfo.Description & "'><strong><img src='" & objDictionary.Item("HTTP_COMMON") & "/Images/Language/" & sLanguageCode & ".gif ' alt='" & varLanguageInfo.Code & " " & varLanguageInfo.Id & vbNewLine & varLanguageInfo.Description & "'  border='0' align='middle' valign='absmiddle'> " & sDisplayName & "</strong></span>"
    Else
      objDictionary.Add sDictionaryEntryCacheName, " <span title='" & varLanguageInfo.Code & " " & varLanguageInfo.Id & vbNewLine & varLanguageInfo.Description & "'><strong>" & sDisplayName & "</strong></span>"
    End If
  End If
  
  GetLanguageDisplayInformation = objDictionary.Item(sDictionaryEntryCacheName)
End Function

'Checks if the strValue argument is null or empty string
Private Function IsValueEmpty(ByVal strValue As String) As Boolean
    Dim result As Boolean
    result = IsNull(strValue) Or IsEmpty(strValue) Or Trim(strValue) = ""
    IsValueEmpty = result
End Function
