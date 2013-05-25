VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MSIXHandler"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Attribute VB_Ext_KEY = "RVB_UniqueId" ,"399321CE03B7"
' ****************************************************************************************************************************************************
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
' * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
'
' CLASS         : MSIX.
' AUTHOR        : F.Torres
' CREATION DATE : 07/xx/2000
' DESCRIPTION   : This object and associated objects implement a full COM Object Model for a MetraTech service or product view.
'                 Some of the properties and methods of this object are reserved by the MetraTech Dialog Manager VBScript layer.
'                 Refer to the Metratech Dialog Manager Programming Guide for more information.
'
'
' $Date$
' $Author$
' $Revision$
' $Workfile$
'
' *********************************************************************************************************************************************************
Option Explicit


Public Enum eMSIX_SESSION_TYPE
    eMSIX_SESSION_TYPE_ATOMIC = 1
    eMSIX_SESSION_TYPE_COMPOUND = 2
    eMSIX_SESSION_TYPE_PARENT = 4
    eMSIX_SESSION_TYPE_CHILD = 8
End Enum

Public Enum eMSIX_METER_MODE
    eMSIX_METER_MODE_METER_SESSION = 1 ' Default mode
    eMSIX_METER_MODE_PASS_FIRST_SESSION = 2 ' Default mode
    eMSIX_METER_MODE_PASS_SESSION = 4 ' Default mode
    eMSIX_METER_MODE_METER_SESSION_SET = 8 ' Default mode
End Enum

Public TRACE_ID As Long

Public Enum eMSIX_RENDER_FLAG ' HTML Rendering flags

    eMSIX_RENDER_FLAG_RENDER_FROM_SERVICE = 1
    eMSIX_RENDER_FLAG_RENDER_FROM_PRODUCTVIEW = 2
    eMSIX_RENDER_FLAG_LOCALIZE_ENUM_TYPE = 4
    eMSIX_RENDER_FLAG_RENDER_INPUT_TAG = 8
    eMSIX_RENDER_FLAG_RENDER_SELECT_TAG = 16
    eMSIX_RENDER_FLAG_RENDER_TEXTAREA_TAG = 32
    eMSIX_RENDER_FLAG_RENDER_FORM_TAG = 64
    eMSIX_RENDER_FLAG_RENDER_IMG_TAG = 128
    eMSIX_RENDER_FLAG_RENDER_LINK_TAG = 256
    eMSIX_RENDER_FLAG_RENDER_LABEL_TAG = 512
    eMSIX_RENDER_FLAG_RENDER_INSERT_JAVASCRIPT = 1024
    eMSIX_RENDER_FLAG_RENDER_GRID = 2048 ' MDM V2
    eMSIX_RENDER_FLAG_RENDER_TABS = 4096 ' MDM V2
    eMSIX_RENDER_FLAG_RENDER_SERVICE_PROPERTY_WITH_BRACKET = 8192   ' MDM V2
    eMSIX_RENDER_FLAG_RENDER_WIDGETS = 16384     ' MDM V2
    
    eMSIX_RENDER_FLAG_DEFAULT_VALUE = eMSIX_RENDER_FLAG_RENDER_INPUT_TAG + eMSIX_RENDER_FLAG_RENDER_SELECT_TAG + eMSIX_RENDER_FLAG_RENDER_TEXTAREA_TAG + eMSIX_RENDER_FLAG_RENDER_FORM_TAG + eMSIX_RENDER_FLAG_RENDER_IMG_TAG + eMSIX_RENDER_FLAG_RENDER_LINK_TAG + eMSIX_RENDER_FLAG_RENDER_LABEL_TAG + eMSIX_RENDER_FLAG_RENDER_INSERT_JAVASCRIPT + eMSIX_RENDER_FLAG_RENDER_GRID + eMSIX_RENDER_FLAG_RENDER_TABS + eMSIX_RENDER_FLAG_RENDER_SERVICE_PROPERTY_WITH_BRACKET + eMSIX_RENDER_FLAG_RENDER_WIDGETS
End Enum

Public Enum eMSIX_PROPERTIES_FLAG ' This enum type has to be in this class rather than in MSIXProperties class because of a VB bug of Class Circlular dependencies...

    eMSIX_PROPERTIES_FLAG_SERVICE = 1
    eMSIX_PROPERTIES_FLAG_PRODUCTVIEW = 2
    eMSIX_PROPERTIES_FLAG_COM_OBJECT = 4
End Enum

Public Name                         As String                       ' The name of the service/product view once the object is initialized, for example: metratech.com/AddCharge.
Private m_Properties                As MSIXProperties               ' The collection of MSIXDEF properties.
Public Monitor                      As MSIXMonitor                  ' Reserved. Documented=no
Public PreProcessor                 As New CVariables               ' Related to the MDM HTML Rendering Processor. This object allows you to programmatically add some search/replace tags before the Rendering process.
Public Configuration                As MDMConfiguration             ' Stores the optional mdm.xml file. See the MDM Programming Guide for more details.
Public m_strVersion                 As String                       ' MDM Version 1.3 or 2.0. MDM V2
Public SessionContext               As Object                       ' MDM v3.0 - To Integrate security
Public Policy                       As Object                       ' MDM v3.0 - To Integrate security
Public MsixdefExtension             As String                       ' MDM v2.2 - Specify in which extension folder name the MSIXDEF file name must be loaded - default value is core...

'Public MSIXSessionMeteredInformation As New MSIXSessionMeteredInformation ' MDM 3.5 contains some MSIX Session information that were metered
'Public MSIXMeteredInformation        As New MSIXMeteredInformation        ' MDM 3.5 contains some MSIX information that were metered
Public SessionType                   As eMSIX_SESSION_TYPE
Public SessionChildrenTypes          As MSIXHandlerTypes                   ' A collection of MSIXHandlerTypes
Public ChildKey                      As String                      ' MDM 3.5 The key of the children in the parent collection - Unique temporary id

Public uID                          As String                       ' MDM 3.5 used set by the property XML

Private m_objPreProcessor           As New MTVBLib.CPreProcessor    ' The PreProcessor for the HTML Rendering
Private m_strMDMDir                 As String                       ' Where is located the MDM folder.
Private m_strAppDir                 As String                       ' Where is located the Application folder
Private m_objDictionary             As Dictionary                   ' The dictionary, the client application must set this object with the Initialize() function
Private m_JavaScriptCode            As String                       ' Related to the MDM. Contains the JavaScript preprocessed for the current service/product view. The source file : mdm\internal\xxxxx.js.
Private m_strLanguage               As String                       ' Store the language. Set with the initialize() method.
Private m_lngInstanceId             As Long                         ' Internal ID for debug purpose.
Private m_booRenderLocalizationMode As Boolean                      ' Store the mode : Localize enum type while rendering
                                    
Private m_PipeLine                  As CPipeLineAccess              ' Pipe line object used to meter. This object is stored at the class level rather than at Meter() function level because an MTOutputSession object is no more valid if the MT.Meter object is deleted. To keep the MT.Meter object alive after the metering this object is not in the Meter() function.
                                    
Private m_objTools                  As MSIXTools                    ' Stored the instance of the MSIXTools object. This class allow this object and give it to its Properties object.

Private m_eRenderFlags              As eMSIX_RENDER_FLAG            ' Store the rendering flag. This member is set at the class level so different function can use it.

Private m_booLocalized              As Boolean

Private m_objCOMObject              As Object                       ' The COM Object instance when the service deal with a COM Object

Private m_objUnSerializedInstanceSecurityContext As Object

Private m_strSessionSetUIDAsString  As String ' for property XML get and set


                                                 
                                                        
' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : ToString()
' PARAMETERS    :
'                   booHTMLTable - If FALSE returns a CSV format, or returns an HTML table format.
'
' DESCRIPTION   : Returns the value(s) of the instance in a string.
' RETURN        :
Public Function ToString(Optional booHTMLTable As Boolean = False) As String

    On Error GoTo ErrMgr
    
    

    If (Me.Properties.IsProductView()) Then
    
        ToString = Tools.PropertiesRowSetToString(Properties)
    Else
        ToString = Me.Properties.ToString(booHTMLTable)
    End If
    Exit Function
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXHandler.cls", "ToString", LOG_ERROR
End Function

' --------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Meter
' PARAMETERS    :
'                 booSynchronously  - Meter synchronously if TRUE. The default value is FALSE.
'                 varOutPutSession  - The metering output session if the parameter is defined.
'                 strServerName     - The metering server name. The default value is : AccountPipeline.
'
' DESCRIPTION   : Meters the service property values.
'                 <code>Empty</code> or <code>Null</code> property values are not metered (Not supported by the pipeline).
'                 If the MSIXProperty.Enabled is FALSE, the MSIX property is not metered (the default value is TRUE).
'                 The eMSIX_PROPERTY_FLAG_METERED flag must be set in the MSIXProperty.Flag so the MSIX property
'                 can be metered. The flag is set by default when the service definition is loaded from an msixdef
'                 file; if the the service property is added programmatically, the flag is not set.
'                 See MSIXProperty.Add() for more details.
'
'                 Date - The MSIX date properties are always metered with their GMT values, the localization is ignored.
'
'                 Boolean - The MSIX Boolean properties are metered with the values 'T' for TRUE and 'F' for FALSE.
'
'                 Once a session is metered, all the metering SDK objects (InputSession, OutPutSession As COMMeterLib.Session,
'                 Meter As COMMeterLib.Meter) remain alive until another metering or until the MSIXHandler object is freed.
'                 This is done so the output session is valid after the metering.
'
'                 If the metering failed, the function raises an error.
'
' RETURN        : TRUE if succeed else raises an error.
Public Function Meter(Optional ByVal booSynchronously As Boolean = False, Optional ByRef varOutPutSession As Variant, Optional ByVal strServerName As String, Optional ByVal eMeterMode As eMSIX_METER_MODE = eMSIX_METER_MODE_METER_SESSION) As Boolean

    Dim objPro                      As MSIXProperty
    Dim objError                    As New CError
    Dim m_objAccountDataSession     As Session
    Dim m_objCreditCardDataSession  As Session
    Dim lngRetCode                  As Long
    Dim objOutPutProperty           As CVariable
    Dim TimeZoneIdBackUp            As Variant
        
    On Error GoTo ErrMgr
        
    Select Case eMeterMode
        Case eMSIX_METER_MODE_METER_SESSION ' Default mode we meter one session
            GoSub InitM_PipeLine
            
        Case eMSIX_METER_MODE_PASS_FIRST_SESSION ' Session Set mode - Pass the data
            GoSub InitM_PipeLine
            
        Case eMSIX_METER_MODE_PASS_SESSION
            m_PipeLine.Properties.Clear
            
        Case eMSIX_METER_MODE_METER_SESSION_SET ' Session Set mode - Meter the session
            m_PipeLine.Meter booSynchronously, SessionContext, eMeterMode ' Meter
            GoSub Clean
            GoTo TheExit
    End Select
    
    '
    ' Pass the session properties to the pipeline
    '
    TimeZoneIdBackUp = Properties.TimeZoneId ' We save and reset the time zone id, because in case it was set for display purpose we want to meter the date in a gmt time
    Properties.TimeZoneId = Empty
        
    For Each objPro In Properties ' Loop around all the MSIX properties and give them to the PipeLineAccess object
        
        If (objPro.Flags And eMSIX_PROPERTY_FLAG_METERED) Then
        
            If Not CBool(objPro.Flags And eMSIX_PROPERTY_FLAG_SKIP_NEXT_METERING) Then
            
                If (IsNull(objPro.Value) Or IsEmpty(objPro.Value)) Then
                
                    'TRACE Replace(MTMSIX_ERROR_01022, "[NAME]", objPro.Name), "MSIXHandler.cls", "Meter", LOG_DEBUG
                    
                ElseIf (Not objPro.Enabled) Then
                
                    'TRACE Replace(MTMSIX_ERROR_01030, "[NAME]", objPro.Name), "MSIXHandler.cls", "Meter", LOG_DEBUG
                Else
                    If (objPro.PropertyType = MSIXDEF_TYPE_BOOLEAN) Then ' Be sure to meter the property boolean pipeline value
                    
                        m_PipeLine.Properties.Add objPro.Name, IIf(objPro.Value, MSIXDEF_TYPE_BOOLEAN_TRUE, MSIXDEF_TYPE_BOOLEAN_FALSE)
                    Else
                        m_PipeLine.Properties.Add objPro.Name, objPro.Value
                    End If
                End If
            End If
        End If
    Next
    Properties.TimeZoneId = TimeZoneIdBackUp ' Restore the time zone id

    m_PipeLine.Meter booSynchronously, SessionContext, eMeterMode ' Meter
        
    Select Case eMeterMode
        Case eMSIX_METER_MODE_METER_SESSION ' Default mode we meter one session
            ' If we meter synchronously we return the output session
            If (booSynchronously) Then Set varOutPutSession = m_PipeLine.OutSession()
            GoSub Clean
        
        Case eMSIX_METER_MODE_PASS_FIRST_SESSION ' Session Set mode - Pass the data
        Case eMSIX_METER_MODE_PASS_SESSION
        Case eMSIX_METER_MODE_METER_SESSION_SET ' Session Set mode - Meter the session
            GoSub Clean
    End Select
TheExit:
    Meter = True
    Exit Function
    
InitM_PipeLine:
    Set m_PipeLine = New CPipeLineAccess    ' Create a new pipe line access object, if one was already existing it is deleted.
    If (Len(strServerName) = 0) Then strServerName = MTMSIX_DEFAULT_SERVER_NAME_TO_METER ' Test the Pipeline server to use and set the default value.
    m_PipeLine.ObjectName = strServerName
    m_PipeLine.Session = Me.Name ' Set the name of the service to meter metratech.com/AddCharge
    m_PipeLine.RequestResponse = booSynchronously ' Set the Synchronous mode
Return
        
Clean:
    For Each objPro In Properties ' Reset the flag for the property with flag eMSIX_PROPERTY_FLAG_SKIP_NEXT_METERING
    
        If CBool(objPro.Flags And eMSIX_PROPERTY_FLAG_SKIP_NEXT_METERING) Then objPro.Flags = objPro.Flags - eMSIX_PROPERTY_FLAG_SKIP_NEXT_METERING
    Next
        
    Select Case eMeterMode
        Case eMSIX_METER_MODE_METER_SESSION ' Default mode we meter one session
        Case eMSIX_METER_MODE_PASS_FIRST_SESSION ' Session Set mode - Pass the data
        Case eMSIX_METER_MODE_PASS_SESSION
        Case eMSIX_METER_MODE_METER_SESSION_SET ' Session Set mode - Meter the session
    End Select
Return

ErrMgr:
    
    Dim lngNumber As Long, strSource As String, strDescription As String
    
    lngNumber = Err.Number
    strSource = Err.Source
    strDescription = Err.Description
    
    GoSub Clean
    
    Err.Raise lngNumber, strSource, strDescription
End Function

' -------------------------------------------------------------------------------
' FUNCTION      : RenderHTML
' PARAMETERS    :
'                   strHTMLTemplateSource               - The HTML Template source code. This was replaced in MDM V2! MDM V1 was defining the file name.
'                   varHTMLRendered                     - The HTML Source code rendered.
'                   strFormAction                       - The name for the VBScript/ASP dialog file.
'                   eRenderFlags                        - Rendering flag. Set by default to eMSIX_RENDER_FLAG_DEFAULT_VALUE.
'                   strOptionalHTMLTemplateSourceCode   - Optional HTML source code added at the end of the template file before rendering.
'                   objForm                             - MDM v2 - Optional Used to render grid
'
' DESCRIPTION   : Related to the MDM. Renders the HTML template file, strHTMLTemplateFile, and returns the result in varHTMLRendered.
' RETURN        : TRUE if metering succeeds.
Public Function RenderHTML(ByVal strHTMLTemplateSource As String, ByRef varHTMLRendered As Variant, Optional ByVal strFormAction As String, Optional ByVal eRenderFlags As eMSIX_RENDER_FLAG = eMSIX_RENDER_FLAG_DEFAULT_VALUE, Optional ByVal strOptionalHTMLTemplateSourceCode As String, Optional ByVal objForm As MDMForm) As Boolean

    On Error GoTo ErrMgr
    
    Dim strHTML                 As String
    Dim varHTML                 As String
    Dim strFolder               As String
    Dim strFileName             As String
    Dim strErrorMessage         As String
    Dim strCurrenttag           As String
    Dim strJavaScriptCode       As String
    Dim strDecimalSeparator     As String
    Dim strThousandSeparator    As String
    Dim strHTMLTemplateFileName As String
    Dim objTextFile             As New cTextFile
    Dim objHTMLParser           As New CHtmlParser
    Dim objProfiler             As New CProfiler
    Dim objMSIXProperty         As MSIXProperty
    
    objProfiler.Start MTMSIX_PROFILER_ON, "MSIXHandler.cls", "RenderHTMLDialog", "Service=" & Me.Name
            
    If (RenderLocalizationMode) Then ' Set the Localization bit if asked and not set
    
        If Not (eRenderFlags And eMSIX_RENDER_FLAG_LOCALIZE_ENUM_TYPE) Then eRenderFlags = eRenderFlags + eMSIX_RENDER_FLAG_LOCALIZE_ENUM_TYPE
    End If

    RenderFlags = eRenderFlags                  ' Set the rendering flag at the class level
    Me.Properties.RenderFlags = eRenderFlags    ' Set the rendering flag for the properties object
    
    If IsValidObject(objForm) Then
        strHTMLTemplateFileName = objForm.HTMLTemplateFileName
        Me.Dictionary.Add "MDM_FORM_JAVASCRIPT_INITIALIZE", objForm.JavaScriptInitialize
        If (Len(objForm.JavaScriptInitialize)) Then objForm.JavaScriptInitialize = ""
    Else
        strHTMLTemplateFileName = MTMSIX_ERROR_01090
        Me.Dictionary.Add "MDM_FORM_JAVASCRIPT_INITIALIZE", ""
    End If
    
    ' MDM V2
'    If (Not LoadTemplate(strHTMLTemplateFile, varHTML)) Then ' Load the template
'
'        RenderHTML = False: Exit Function
'    Else
'        strHTML = varHTML
'    End If
    strHTML = strHTMLTemplateSource
        
    If (Len(strOptionalHTMLTemplateSourceCode)) Then ' Optional HTML Source code
    
        strHTML = strHTML & strOptionalHTMLTemplateSourceCode
    End If
            
    m_objPreProcessor.Clear ' Clear the pre processor. The PreProcessor is defined at the class level.
    
    PreProcessor.CopyTo m_objPreProcessor.Variables ' Copy the custom Search/Replace tags, set by the programmer in the preprocessor
    
    AddToPreProcessor "MDM_FOLDER", Me.MDMDir, PREPROCESSOR_ADD_NONE ' Populate the PreProcessor with some global values - probably very usefull
    AddToPreProcessor "APP_FOLDER", Me.AppDir, PREPROCESSOR_ADD_NONE
    AddToPreProcessor "NOW", MTNow(), PREPROCESSOR_ADD_NONE
    AddToPreProcessor "VERSION", Me.Version(), PREPROCESSOR_ADD_NONE
        
    strDecimalSeparator = MTMSIX_DEFAULT_DECIMAL_SEPARATOR
    strThousandSeparator = MTMSIX_DEFAULT_THOUSAND_SEPARATOR
    
    If (IsValidObject(Me.Dictionary)) Then ' Decimal and thousand separator...
    
        strDecimalSeparator = Me.Dictionary.GetValue("DECIMAL_SEPARATOR", strDecimalSeparator)
        strThousandSeparator = Me.Dictionary.GetValue("THOUSAND_SEPARATOR", strThousandSeparator)
    End If
    
    AddToPreProcessor "DECIMAL_SEPARATOR", strDecimalSeparator, PREPROCESSOR_ADD_NONE
    AddToPreProcessor "THOUSAND_SEPARATOR", strThousandSeparator, PREPROCESSOR_ADD_NONE
            
    If (Len(strFormAction)) Then ' Populate the PreProcessor with some global values - probably very usefull
    
        AddToPreProcessor "HTTP_ASP_PATH", objTextFile.GetPathFromFileName(strFormAction, "/"), PREPROCESSOR_ADD_NONE
        AddToPreProcessor "HTTP_ASP_FILE", strFormAction, PREPROCESSOR_ADD_NONE
        AddToPreProcessor "HTTP_ASP_FILE_NAME_ONLY", objTextFile.GetFileName(strFormAction, "/"), PREPROCESSOR_ADD_NONE
    End If
            
    If (Len(strFormAction)) Then ' If the <FORM> action attribute id passed set the pre-process tag HTTP_ASP_HELP_FILE
    
        If (IsValidObject(Dictionary)) Then ' If the Dictionary object is set
        
            If (Me.Dictionary.Exist(MDM_CUSTOM_IMAGE_PATH_REPLACE)) Then
        
                ' Insert in the PreProcessor the macro to call the help file
                
                If (InStr(UCase$(strFormAction), "/DEFAULT/")) Then ' Check if we are dealing with a default or custom asp file
                
                    strFolder = Dictionary.Item(MDM_DEFAULT_IMAGE_PATH_REPLACE).Value & "/help"     ' 1 Get the localized help file path
                Else
                    strFolder = Dictionary.Item(MDM_CUSTOM_IMAGE_PATH_REPLACE).Value & "/help"      ' 1 Get the localized help file path
                End If
                
                strFileName = objTextFile.GetFileName(strFormAction, "/")                   ' 2 Get the Current Dialog ASP File Name Only
                strFileName = Mid$(strFileName, 1, Len(strFileName) - 3) & "hlp.asp"         ' 3 Remove the extension .asp and add the .hlp.asp
                AddToPreProcessor "HTTP_ASP_HELP_FILE", strFolder & "/" & strFileName, PREPROCESSOR_ADD_NONE ' 4 Insert the help file name in the preprocessor
            Else
                TRACE Replace(MTMSIX_ERROR_01027, "[ENTRY]", MDM_CUSTOM_IMAGE_PATH_REPLACE), "MSIXHandler.cls", "RenderHTML", LOG_ERROR
            End If
        End If
    End If
    
    '
    ' -- Here start the rendering --
    '
    
    ' MDM v3 - Apply security on the html template first
    If (IsValidObject(Me.SecurityContext)) Then   ' Process the <LINK> - Localize the path
    
        
        objHTMLParser.HTMLProcessor strHTML, "MDMSECURITY", Properties, strHTMLTemplateFileName, Me.Name, , , Dictionary, , objForm, Me, Me.Policy, Me.SecurityContext
    End If
    
    If (IsValidObject(objForm)) Then
        ''Debug.Assert 0
        Me.Dictionary.Remove "MDM_PVB_FILTER_MODE"
        Me.Dictionary.Remove "MDM_PVB_FILTER_MULTI_COLUM_MODE"
    
        If objForm.Grid.FilterMode = MDM_FILTER_MODE_ON Then
           
            Me.Dictionary.Add "MDM_PVB_FILTER_MODE", 1
            If (IsValidObject(objForm.Grid.FilterProperty)) Then
            
                Me.Dictionary.Add "MDM_PVB_FILTER_PROPERTY_NAME", objForm.Grid.FilterProperty.Caption
            Else
                Me.Dictionary.Add "MDM_PVB_FILTER_PROPERTY_NAME", MTMSIX_ERROR_01086
            End If
            
        ElseIf objForm.Grid.FilterMode = MDM_FILTER_MULTI_COLUMN_MODE_ON Then
        
            Me.Dictionary.Add "MDM_PVB_FILTER_MULTI_COLUM_MODE", 1
        End If
    End If
    
    
    '
    ' #MDMInclude tag - MDM 3.0
    '
    objHTMLParser.ProcessMDMInclude strHTML, Dictionary
    
    
    '
    ' Conditional Rendering
    '
    objHTMLParser.ConditionalRendering strHTML, Dictionary, MDM_CONDITIONAL_RENDERING_IF, False
    objHTMLParser.ConditionalRendering strHTML, Dictionary, MDM_CONDITIONAL_RENDERING_IFNOT, True
    
    
    ' MDM v2 - The tab MDMTABS must be processed first because it complete the HTML Template it does not process it
    If (eRenderFlags And eMSIX_RENDER_FLAG_RENDER_TABS) Then   ' Process the <LINK> - Localize the path
    
        If (IsValidObject(objForm)) Then
        
            If (objForm.TabsDefined()) Then
        
                objHTMLParser.HTMLProcessor strHTML, "MDMTABS", Properties, strHTMLTemplateFileName, Me.Name, , , Dictionary, , objForm, Me
            End If
        End If
    End If
    
    ' MDM v2 - The tab MDMTABS must be processed first because it complete the HTML Template it does not process it
    If (eRenderFlags And eMSIX_RENDER_FLAG_RENDER_GRID) Then   ' Process the <LINK> - Localize the path
    
        If (IsValidObject(objForm)) Then
        
            If (objForm.GridsDefined()) Then
            
                objHTMLParser.HTMLProcessor strHTML, "MDMGRID", Properties, strHTMLTemplateFileName, Me.Name, , , Dictionary, , objForm, Me
            End If
        End If
    End If

        
    If (eRenderFlags And eMSIX_RENDER_FLAG_RENDER_INPUT_TAG) Then   ' Process the <INPUT>
        
        objHTMLParser.HTMLProcessor strHTML, "INPUT", Properties, strHTMLTemplateFileName, Me.Name, , , Dictionary
    End If
    
    If (eRenderFlags And eMSIX_RENDER_FLAG_RENDER_LABEL_TAG) Then   ' Process the <LABEL>
        
        objHTMLParser.HTMLProcessor strHTML, "LABEL", Properties, strHTMLTemplateFileName, Me.Name, , , Dictionary
        objHTMLParser.HTMLProcessor strHTML, "MDMLABEL", Properties, strHTMLTemplateFileName, Me.Name, , , Dictionary
    End If
    
    If (eRenderFlags And eMSIX_RENDER_FLAG_RENDER_FORM_TAG) Then   ' Process the <FORM>

        ' Add some attribute to the tag <FORM> and add the MDM JavaScript right after. The tag is mandatory so check for it too.
        
        strJavaScriptCode = IIf(eRenderFlags And eMSIX_RENDER_FLAG_RENDER_INSERT_JAVASCRIPT, m_JavaScriptCode, "")  ' Adding the javascript is now a flag and can be turned off, be default on
        
        ' THIS IS TEMPORARY COMMENTED - WE DO NOT NEED ACTION FOR GRID
        'If (objForm.GridsDefined()) Then ' Add the JavaScript related to the grid
        '
        '    strJavaScriptCode = Replace(strJavaScriptCode, "</SCRIPT>", objForm.RenderGridJavaScript() & Chr(18))
        '    strJavaScriptCode = Replace(strJavaScriptCode, Chr(18), "</SCRIPT>")
        'End If
        
        If (IsFlag(objHTMLParser.HTMLProcessor(strHTML, "FORM", Properties, strHTMLTemplateFileName, Me.Name, strJavaScriptCode, strFormAction, , Me.Configuration), eHTMLPARSER_ERROR_FLAG_TAG_NOT_FOUND)) Then
        
            strCurrenttag = "<FORM>"
            GoTo MandatoryHTMLTagNotFound
        End If
        
        If (IsValidObject(Me.Dictionary)) Then ' If the dictionary is set and the META TAG Char set is defined for the current language then we insert the META tag after the tag <HEAD>

            If (Me.Dictionary.Exist(MDM_LANGUAGE_META_TAG)) Then
            
                ' Add the Meta Tag after the tag <HEAD> if the tag <HEAD> is not found raise an error! This tag is mandatory
                If (IsFlag(objHTMLParser.HTMLProcessor(strHTML, "HEAD", Properties, strHTMLTemplateFileName, Me.Name, GetDictionnaryHTMLMetaTag()), eHTMLPARSER_ERROR_FLAG_TAG_NOT_FOUND)) Then
                
                    strCurrenttag = HTML_HEAD_TAG
                    GoTo MandatoryHTMLTagNotFound
                End If
            Else
                TRACE Replace(MTMSIX_ERROR_01027, "[ENTRY]", MDM_LANGUAGE_META_TAG), "MSIXHandler.cls", "RenderHTML", LOG_WARNING
            End If
        End If
    End If
    
    If (eRenderFlags And eMSIX_RENDER_FLAG_RENDER_SELECT_TAG) Then  ' Process the <SELECT>
        
        objHTMLParser.HTMLProcessor strHTML, "SELECT", Properties, strHTMLTemplateFileName, Me.Name
    End If
    
    If (eRenderFlags And eMSIX_RENDER_FLAG_RENDER_TEXTAREA_TAG) Then  ' Process the <TEXTAREA>
            
        objHTMLParser.HTMLProcessor strHTML, "TEXTAREA", Properties, strHTMLTemplateFileName, Me.Name
    End If
    
    ' Render IMG tag at the end because it will add some text useless to parse
    If (eRenderFlags And eMSIX_RENDER_FLAG_RENDER_IMG_TAG) Then   ' Process the <IMG>
        
        If (IsValidObject(Dictionary)) Then ' If the Dictionary object is set only because we just replace the path based in an entry in the dictionary
        
            objHTMLParser.HTMLProcessor strHTML, "IMG", Properties, strHTMLTemplateFileName, Me.Name, , , Dictionary
        End If
    End If
    
    If (eRenderFlags And eMSIX_RENDER_FLAG_RENDER_LINK_TAG) Then  ' Process the <LINK> - Localize the path
        
        If (IsValidObject(Dictionary)) Then ' If the Dictionary object is set only because we just replace the path based in an entry in the dictionary
        
            objHTMLParser.HTMLProcessor strHTML, "LINK", Properties, strHTMLTemplateFileName, Me.Name, , , Dictionary
        End If
    End If

    
    ' MDM v2 - Render last because it will slow down the rendering if it was done at the beginningh...
    If (eRenderFlags And eMSIX_RENDER_FLAG_RENDER_WIDGETS) Then
    
        If (IsValidObject(objForm)) Then
        
            If (objForm.WidgetsDefined()) Then
            
                objHTMLParser.HTMLWidgetsProcessor strHTML, objForm.Widgets
            End If
        End If
    End If
           
    varHTMLRendered = PreProcess(strHTML, eRenderFlags, False) ' Execute the PreProcessor

    RenderHTML = True
    Exit Function
    
MandatoryHTMLTagNotFound:

    strErrorMessage = Replace(MTMSIX_ERROR_01013, "[TAG]", strCurrenttag)
    strErrorMessage = Replace(strErrorMessage, "[FILE]", strHTMLTemplateFileName)
    RaiseError strErrorMessage
    Exit Function
    
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXHandler.cls", "RenderHTML", LOG_ERROR
End Function
 

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Add
' PARAMETERS    :
' DESCRIPTION   : Because I want to be able to add name/value to the pre processor from anyware in the class
'                 and add some specific code for every new entry. I wrote this function.
'                 Since I added the eFlag notion to the method Add, this function makes less sense but I keep it!
'                 At least the function test the null value!
' RETURN        :
Private Function AddToPreProcessor(strName As String, ByVal varValue As Variant, eFlag As PREPROCESSOR_ADD_FLAG) As Boolean

    On Error GoTo ErrMgr

    If (IsNull(varValue)) Then varValue = "NULL"
    
    AddToPreProcessor = m_objPreProcessor.Add(UCase$(strName), varValue, eFlag)
    Exit Function
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXHandler.cls", "AddToPreProcessor", LOG_ERROR
End Function

' -------------------------------------------------------------------------------
' FUNCTION      : RequiredFieldsOK
' PARAMETERS    :
'                   objError - The instance of the MDM object error.
'
' DESCRIPTION   : Related to the MDM, this function returns TRUE if all the required misx properties of a service are set.
'                 If not, the object objXError contains the description of the property which is not set.
'                 This function can be canceled if Configuration.CheckRequiredField is FALSE (See the mdm.xml file, in the MDM Programming Guide).
' RETURN        :
Public Function RequiredFieldsOK(objError As MDMError) As Boolean

    On Error GoTo ErrMgr

    Dim objProperty         As MSIXProperty
    Dim strErrorMessage     As String
    
    If (Me.Configuration.CheckRequiredField) Then
    
        RequiredFieldsOK = False ' Default return value...
        
        For Each objProperty In Me.Properties
        
            If (objProperty.Required) And (objProperty.Enabled) Then
                
                If (Len("" & objProperty.Value) = 0) Then ' Empty and Null are seen as empty string too
                
                    strErrorMessage = Replace(MTMSIX_ERROR_01004, "[NAME]", objProperty.Caption)     ' Trace the error
                    TRACE CStr(strErrorMessage), "MSIXHandler.cls", "RequiredFieldsOK", LOG_ERROR
                    objError.Number = MakeItUserVisibleMTCOMError(1004)     ' Return the error
                    objError.Description = strErrorMessage
                    objError.Source = "MTMSIX.MSIX.RequiredFieldsOK()"
                    objError.PropertyName = objProperty.Name
                    Exit Function
                End If
            End If
        Next
    End If
    RequiredFieldsOK = True
    Exit Function
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXHandler.cls", "RequiredFieldsOK", LOG_ERROR
End Function
' -------------------------------------------------------------------------------
' FUNCTION      : ValidateRequiredFieldsWithRegEx
' PARAMETERS    :
'                   regExPattern - Regular Expression which shouldn't match value of any field.
'                       For instance if you need only positive integers you could use [^0-9]
'                   objError - The instance of the MDM object error.
'
' DESCRIPTION   : Related to the MDM, this function returns TRUE if all the misx properties of a service are valid.
'                 If not, the object objXError contains the description of the property which is not valid.
' RETURN        :
Public Function ValidateRequiredFieldsWithRegEx(regExPattern As String, objError As MDMError) As Boolean

    On Error GoTo ErrMgr

    Dim objProperty         As MSIXProperty
    Dim strErrorMessage     As String
    Dim myRegExp            As New RegExp
    Dim myMatches           As MatchCollection
    
    
    myRegExp.Pattern = regExPattern
    
    If (Me.Configuration.CheckRequiredField) Then
    
        ValidateRequiredFieldsWithRegEx = False ' Default return value...
        
        For Each objProperty In Me.Properties
                
            If (objProperty.Required) And (objProperty.Enabled) And Not (objProperty.IsEnumType) Then
                
                If Not (Len("" & objProperty.Value) = 0) Then ' Do not check Empty and Null strings
                    Set myMatches = myRegExp.Execute(objProperty.Value)
                                        
                    If myMatches.Count > 0 Then
                        strErrorMessage = Replace(MTMSIX_ERROR_01109, "[NAME]", objProperty.Caption)      ' Trace the error
                        TRACE CStr(strErrorMessage), "MSIXHandler.cls", "ValidateRequiredFieldsWithRegEx", LOG_ERROR
                        objError.Number = MakeItUserVisibleMTCOMError(1004)     ' Return the error
                        objError.Description = strErrorMessage
                        objError.Source = "MTMSIX.MSIX.ValidateRequiredFieldsWithRegEx()"
                        objError.PropertyName = objProperty.Name
                        Exit Function
                    End If
                End If
            End If
        Next
    End If
    ValidateRequiredFieldsWithRegEx = True
    Exit Function
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXHandler.cls", "ValidateRequiredFieldsWithRegEx", LOG_ERROR
End Function
' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : LoadMSIXDEFServiceXMLFile
' PARAMETERS    :
'                 strXMLFileName - Full path to the MSIXDEF file.
' DESCRIPTION   : Load a MSIXDEF file. By calling this function the object is set as a service definition.
' RETURN        :
Private Function LoadMSIXDEFServiceXMLFile(ByVal strXMLFileName As String) As Boolean

    On Error GoTo ErrMgr

    Dim objTextFile     As New cTextFile
    Dim strName         As String
    
    InitPropertiesObject eMSIX_PROPERTIES_FLAG_SERVICE
    
    ' Here we test if the file has a full path if yes we use it else we add the standard metratech
    ' path : config/Properties.
    ' I did that so I can load msixdef file that are located in config/services or not.
    If (Not objTextFile.ExistFile(strXMLFileName)) Then

        'strXMLFileName = ServiceDir() & "\" & strXMLFileName
        If (Not Tools.GetRCDFullPathAndFileName("config\service", strXMLFileName, strXMLFileName, Me.MsixdefExtension)) Then Exit Function
    End If
    LoadMSIXDEFServiceXMLFile = Properties.LoadMSIXDEFXMLFile(strXMLFileName, strName)
    Name = strName
    
    Exit Function
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXHandler.cls", "LoadMSIXDEFServiceXMLFile", LOG_ERROR
End Function
 
' --------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Initialize
' PARAMETERS    :
'                 strMSIXDEFServiceFileName     - The name of the msixdef file if the object must be initialized as a service. Supports relative or full path.
'                 strMSIXDEFProductViewFileName - The name of the msixdef file if the object must be initialized as a product view. Supports relative or full path.
'                                                 In this case, the parameter strMDMDir must be defined.
'                 strLanguage                   - The language allows the localization of the MSIX property and of the enum types. The default value is US.
'                 strAppDir                     - The client application main folder, used to read the mdm.xml optional configuration file .
'                 strMDMDir                     - The MDM folder, used to load some MDM related file such as the Javascript UI file or the HTML Product tool bar file.
'                 objCache                      - An instance of the object MSIXCache. The usage of the cache object
'                 booLocalize                   - If TRUE the service/product view data are loaded.
'
' DESCRIPTION   : Initializes the object:
'                   - Load the service msixdef file or the product view msixdef file definition in the Properties object,
'                   including the enum types and their localization.
'                   - Creates the Tool object.
'                   - Loads and pre-processes the MDM JavaScript for the current service or product view. See mdm\internal\mdm.JavaScript.tpl.js.
'                   - Loads the mdm.xml file if available.
'
'                In the case of a product view, the function loads the product view msixdef file and the reserved properties as well.
'                See the file mdm\internal\AccountUsageProductView.msixdef.
'
' RETURN        : Returns TRUE if the function succeeds. If the function fails, error messages are logged in the MTLog.txt file.
Public Function Initialize(Optional ByVal strMSIXDEFServiceFileName As String, Optional ByVal strMSIXDEFProductViewFileName As String, Optional ByVal strLanguage As String = METRATECH_DEFAULT_LANGUAGE, Optional ByVal strAppDir As String, Optional ByVal strMDMDir As String, Optional ByVal objCache As MSIXCache, Optional ByVal booLocalize As Boolean = True, Optional ByVal strVersion As String) As Boolean

    On Error GoTo ErrMgr

    Dim objProfiler As New CProfiler
    Dim booRetVal   As Boolean: booRetVal = True
    Dim objTextFile As New cTextFile
    
    'MTMSIX_PROFILER_ON = True
    
    objProfiler.Start MTMSIX_PROFILER_ON, "MSIXHandler.cls", "Initialize"
    
    m_booLocalized = booLocalize
    m_strMDMDir = strMDMDir
    m_strAppDir = strAppDir
    Language = strLanguage

    Set Tools.Cache = objCache
    
    ' I add the MDM_FOLDER because the MSIXTools class needs it to load the big5 file.xml file...
    If (IsValidObject(objCache)) Then If (Len(strMDMDir)) Then If (Not objCache.Exist("MDM_FOLDER")) Then objCache.Add "MDM_FOLDER", strMDMDir
                
    If (Len(strMSIXDEFProductViewFileName)) Then ' Load the msixdef product view or the service file
    
        booRetVal = booRetVal And LoadMSIXDEFProductViewXMLFile(strMSIXDEFProductViewFileName)
        
    ElseIf (Len(strMSIXDEFServiceFileName)) Then  ' Read the service definition - optional too
    
        booRetVal = booRetVal And LoadMSIXDEFServiceXMLFile(strMSIXDEFServiceFileName)
    Else
        InitPropertiesObject eMSIX_PROPERTIES_FLAG_SERVICE ' We initialize a service object empty
    End If
    
    If (Len(MDMDir())) Then ' Read the java script UI handler. This JavaScript is PreProcessed with service definition properties info.
    
        booRetVal = booRetVal And LoadJavaScriptCode()
    End If
        
    Initialize = booRetVal
    
    Version = IIf(Len(strVersion), strVersion, Version) ' The Properties object must be allocated
    
    Set Configuration = New MDMConfiguration
    If (objTextFile.ExistFile(AppDir() & "\mdm.xml")) Then ' The mdm.xml file is optional
    
        Configuration.LoadXMLFile AppDir() & "\mdm.xml"
        MTMSIX_PROFILER_ON = Configuration.ProfilerMode
    End If
    
    Set Me.Properties.Configuration = Configuration
        
    TRACE_CONSTRUCTOR_DESTRUCTOR Properties, TRACE_MSIXHANDLER_INIT_MSIXPROPERTIES, "MSIXHandler ID=" & ObjPtr(Me) & " MSIXProperties.Name=" & Me.Properties.Name
    
    Exit Function
ErrMgr:

    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXHandler.cls", "Initialize", LOG_ERROR
End Function

' -------------------------------------------------------------------------------
' FUNCTION      : MDMDir
' PARAMETERS    :
' DESCRIPTION   : Gets the MDM folder.
' RETURN        :
Public Property Get MDMDir() As String
 
    On Error GoTo ErrMgr

    MDMDir = m_strMDMDir
    Exit Property
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXHandler.cls", "MDMDir", LOG_ERROR
End Property

' -------------------------------------------------------------------------------
' FUNCTION      : LoadJavaScriptCode
' PARAMETERS    :
' DESCRIPTION   : Related to the MDM. This function loads and preprocesses the MDM javaScript for the current service/product view. This function must be called
'                 after MSIX properties are added programmatically, generally in the MDM dialog Form_Initialize() event. This function is
'                 Automatically called by the initialize() function.
'
' RETURN        :
Public Function LoadJavaScriptCode() As Boolean

    On Error GoTo ErrMgr

    Dim strFileName As String
    Dim objTextFile As New cTextFile
    Dim strIn       As String
    Dim strOut      As String
    Dim objProperty As MSIXProperty
    Dim objPP       As New CPreProcessor: objPP.standardVar
    Dim strStringIDChars As String
    
    strFileName = InternalDir() & "\mdm.JavaScript.tpl.js"
    
    objPP.Add "NOW", MTNow()
    
    ' Get the strind id chars list
    strStringIDChars = MDM_TYPE_STRINGID_DEFAULT_CHARS
    If (IsValidObject(Me.Dictionary)) Then
        If (Me.Dictionary.Exist("MDM_TYPE_STRINGID_DEFAULT_CHARS")) Then
        
            strStringIDChars = Me.Dictionary("MDM_TYPE_STRINGID_DEFAULT_CHARS")
        End If
    End If
    objPP.Add "MDM_TYPE_STRINGID_CHARS", strStringIDChars
        
    If (objTextFile.OpenFile(strFileName)) Then
    
        Do While Not objTextFile.EOF()
        
            strIn = objTextFile.ReadLn()
            
            If (Len(strIn)) Then ' Test the size before calling the VB mid$() function, because it does not like empty string.
            
                If (Mid$(Trim(strIn), 1, 1) = "#") Then
                
                    For Each objProperty In Me.Properties
                    
                        objPP.Add "PROPERTY_NAME", UCase$(objProperty.Name)
                        objPP.Add "PROPERTY_MAXLENGTH", objProperty.Length
                        objPP.Add "PROPERTY_REQUIRED", objProperty.Required
                        
                        objPP.Add "PROPERTY_TYPE", objProperty.PropertyType
                        If (objProperty.PropertyType = MSIXDEF_TYPE_STRING) Then
                            If (objProperty.Flags And eMSIX_PROPERTY_FLAG_STRING_ID) Then objPP.Add "PROPERTY_TYPE", MDM_TYPE_STRINGID
                        End If
                                                
                        strOut = strOut & objPP.Process(Mid$(strIn, 2), "[", "]") & vbCrLf
                    Next
                Else
                    strOut = strOut & objPP.Process(strIn, "[", "]") & vbCrLf
                End If
            Else
                strOut = strOut & vbCrLf
            End If
        Loop
        objTextFile.CloseFile
        m_JavaScriptCode = strOut
        m_JavaScriptCode = vbNewLine & "<!-- MDM Client Side -->" & vbNewLine & m_JavaScriptCode
    End If
    LoadJavaScriptCode = CBool(Len(m_JavaScriptCode))
    Exit Function
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXHandler.cls", "LoadJavaScriptCode", LOG_ERROR
End Function

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Tools
' PARAMETERS    :
' DESCRIPTION   : Gets the instance of the MSIXTool object associated with the service/product view object.
'                 The MSIXHandler object creates the MSIXTool instance and gives it to the <code>Properties</code>
'                 object in the initialize() function.
'                 The MSIXTool object exposes different useful functions used internally that can be used by
'                 the client as well. For example, IsPayementServerInstalled() or EMailAddressValid().
'                 See the MDM Programming Guide and MDM Object Model for more details.
' RETURN        :
Public Property Get Tools() As MSIXTools

    On Error GoTo ErrMgr

    If (Not IsValidObject(m_objTools)) Then
    
         Set m_objTools = New MSIXTools
         m_objTools.InstanceId = m_lngInstanceId
    End If
    Set Tools = m_objTools
    Exit Property
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXHandler.cls", "Tools", LOG_ERROR
End Property

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : PreProcess
' PARAMETERS    :
'                 strSourceString   - The HTML text that must be pre processed.
'                 eRenderFlags      - The rendering flags, used to know if we localize the enum type.
'                 booClear          - Do we clear the pre-processor before all.
'                 booPreProcess     - If we just want to fill the pre-processor set the property to false.
'
' DESCRIPTION   : Related to the MDM. Pre-processes the HTML code from strSourceString, based on all the service/product view msix
'                 properties (value, caption, type, required...).
'                 If the dictionary object is defined, Pre-Processes the HTML code from strSourceString, based on all the dictionary
'                 entries. This function uses the MSIXProperty.Format for the values. If the TimeZoneId is defined the date values
'                 are be localized.
'                 This function supports only the non-HTML syntax for the rendering.
'                 See the MDM Programming Guide for more details.
'
'                 This function is not documented in COM API Documentation
'
' RETURN        : Returns the PreProcessed String.
Public Function PreProcess(ByVal strSourceString As String, ByVal eRenderFlags As eMSIX_RENDER_FLAG, Optional booClear As Boolean = True, Optional booPreProcess As Boolean = True) As String ' Documented=no - This function is not public in the documentation

    On Error GoTo ErrMgr

    Dim objMSIXProperty         As MSIXProperty
    Dim strResult               As String
    Dim objProfiler             As New CProfiler
    
    objProfiler.Start MTMSIX_PROFILER_ON, "MSIXHandler.cls", "PreProcess", "Service=" & Me.Name
    
    Properties.RenderFlags = eRenderFlags
    
    If (booClear) Then m_objPreProcessor.Clear
    
    If (RenderFlags And eMSIX_RENDER_FLAG_RENDER_SERVICE_PROPERTY_WITH_BRACKET) Then ' MDM V2 - Compatibility mode

        
             
        For Each objMSIXProperty In Properties ' Populate the PreProcessor with the Service property name/value, caption, type, reuiqred...
            
            If (objMSIXProperty.PropertyType = MSIXDEF_TYPE_STRING) Then ' This is just an optimization to put less entry in the pre-processor
            
                AddToPreProcessor objMSIXProperty.Name, FormatData(objMSIXProperty.Value, objMSIXProperty.Format), PREPROCESSOR_ADD_LOWERCASE + PREPROCESSOR_ADD_UPPERCASE
            Else
                AddToPreProcessor objMSIXProperty.Name, FormatData(objMSIXProperty.Value, objMSIXProperty.Format), PREPROCESSOR_ADD_NONE + PREPROCESSOR_ADD_ABSOLUTE
            End If
            
            AddToPreProcessor objMSIXProperty.Name & ".CAPTION", objMSIXProperty.Caption, PREPROCESSOR_ADD_NONE
            AddToPreProcessor objMSIXProperty.Name & ".MAXLENGTH", objMSIXProperty.Length, PREPROCESSOR_ADD_NONE
            AddToPreProcessor objMSIXProperty.Name & ".REQUIRED", LCase(objMSIXProperty.Required), PREPROCESSOR_ADD_NONE
            AddToPreProcessor objMSIXProperty.Name & ".DEFAULTVALUE", objMSIXProperty.DefaultValue, PREPROCESSOR_ADD_NONE
            AddToPreProcessor objMSIXProperty.Name & ".TYPE", LCase(objMSIXProperty.PropertyType), PREPROCESSOR_ADD_NONE
            AddToPreProcessor objMSIXProperty.Name & ".USERVISIBLE", LCase(objMSIXProperty.UserVisible), PREPROCESSOR_ADD_NONE
            
            If (objMSIXProperty.PropertyType = MSIXDEF_TYPE_BOOLEAN) Then AddToPreProcessor objMSIXProperty.Name & ".CHECKED", IIf(Me.Tools.BooleanValue(objMSIXProperty.Value(, False)), "CHECKED", ""), PREPROCESSOR_ADD_NONE
        Next
    End If
    
    
    If (booPreProcess) Then
    
        strResult = m_objPreProcessor.Process(strSourceString, "[", "]") ' PreProcessor the the service/product view properties
        
        If (IsValidObject(Dictionary)) Then
            
            strResult = Me.Dictionary.PreProcess(strResult, "[", "]") ' PreProcessor for the translation
        End If
        PreProcess = strResult
    End If
    
    If (Me.Configuration.LogWarning) Then
    
        Me.Log "HTML Renderer-PreProcessor Info:PreProcessor.Count=" & m_objPreProcessor.Variables.Count & " Dictionary.count=" & Dictionary.Count
    End If
    Exit Function
ErrMgr:

  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXHandler.cls", "PreProcess", LOG_ERROR
End Function

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : LoadTemplate
' PARAMETERS    :
'                       strHTMLTemplateFile - The HTML template file to load (The full path must be specified).
'                       varHTML             - Contents of the file.
'
' DESCRIPTION   : Loads an HTML template file into the varHTML parameter.
' RETURN        :
Public Function LoadTemplate(ByVal strHTMLTemplateFile As String, ByRef varHTML As Variant) As Boolean

    On Error GoTo ErrMgr

    Dim objTextFile             As New cTextFile
    
    If (Len(strHTMLTemplateFile) = 0) Then
        varHTML = Empty
        LoadTemplate = True
        Exit Function ' If the template is not defined we just return TRUE ' a dialog may have no template
    End If
        
    If (objTextFile.ExistFile(strHTMLTemplateFile)) Then
    
        varHTML = objTextFile.LoadFile(strHTMLTemplateFile)
        LoadTemplate = True
    Else
        TRACE Replace(MTMSIX_ERROR_01007, "[FILE]", strHTMLTemplateFile), "MSIXHandler.cls", "LoadTemplate", LOG_ERROR
    End If
    Exit Function
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXHandler.cls", "LoadTemplate", LOG_ERROR
End Function


' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : LoadMSIXDEFProductViewXMLFile
' PARAMETERS    :
'                 strXMLFileName - Full path to the MSIXDEF file.
' DESCRIPTION   : Load a MSIXDEF file. By calling this function the object is set as a product view.
'                 Note that the function read the file mdm\internal\AccountUsageProductView.msixdef which contains
'                 the product view property stored in the table t_acc_usage.
' RETURN        :
Private Function LoadMSIXDEFProductViewXMLFile(ByVal strXMLFileName As String) As Boolean

    On Error GoTo ErrMgr
    
    Dim objTextFile                                 As New cTextFile
    Dim strName                                     As String
    Dim strMSIXDEFAccountUsageProductViewFileName   As String

    InitPropertiesObject eMSIX_PROPERTIES_FLAG_PRODUCTVIEW
        
    ' Load the product view reserved properties from the mdm\internal folder.
    strMSIXDEFAccountUsageProductViewFileName = InternalDir() & "\AccountUsageProductView.msixdef"
    
    If (Properties.LoadMSIXDEFXMLFile(strMSIXDEFAccountUsageProductViewFileName, "", , eMSIX_PROPERTY_FLAG_ACCOUNT_USAGE_TABLE)) Then
        
        If (Not objTextFile.ExistFile(strXMLFileName)) Then ' Here we test if the file has a path if yes we use it else we add the standard metratech path : config/Properties.
        
            'strXMLFileName = ProductViewDir() & "\" & strXMLFileName
            If (Not Tools.GetRCDFullPathAndFileName("config\productview", strXMLFileName, strXMLFileName, Me.MsixdefExtension)) Then Exit Function
        End If
        LoadMSIXDEFProductViewXMLFile = Properties.LoadMSIXDEFXMLFile(strXMLFileName, strName, False)
        Name = strName
    Else
        TRACE MTMSIX_ERROR_01050, "MSIXHandler.cls", "LoadMSIXDEFProductViewXMLFile"
    End If
    Exit Function
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXHandler.cls", "LoadMSIXDEFProductViewXMLFile", LOG_ERROR
End Function


' -------------------------------------------------------------------------------
' FUNCTION      : Log
' PARAMETERS    :
'                   strText     - The text to log.
'                   eLoginLevel - The login level. The default value is LOG_DEBUG.
'                                 See the MDM Programming Guide for more details.
' DESCRIPTION   : Logs strText, prefixed by the name of the service/product view.
' RETURN        :
Public Function Log(ByVal strText As String, Optional ByVal eLoginLevel As eLOG_TRACE_MODE = LOG_DEBUG) As Boolean

    On Error GoTo ErrMgr
    
    If IsValidObject(Me.Configuration) Then
        If Not Me.Configuration.LogDebug And eLoginLevel = LOG_DEBUG Then
            Exit Function
        End If
    End If
    
    Log = TRACE("MSIXHandler:" & Me.Name & ":" & strText, , , eLoginLevel)
    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString() & " Message=" & strText, Me, "Log", LOG_ERROR
End Function

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Clear
' PARAMETERS    :
' DESCRIPTION   : Clears the MSIX property values of the service definition.
'                 Does not clear the service or product view definition.
'                 It is not possible to clear the MSIX property values of a product view,
'                 but a product view rowset can be re-loaded.
' RETURN        :
Public Function Clear() As Boolean

    On Error GoTo ErrMgr
    
    #If LOG_OBJECT_INFO Then
        TRACE_CONSTRUCTOR_DESTRUCTOR Me, TRACE_CLEAR_MODE
    #End If

    Properties.ClearData ' Set to empty the service property value
    Clear = True
    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXHandler.cls", "Clear", LOG_ERROR
End Function

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : ServiceDir
' PARAMETERS    :
' DESCRIPTION   : Returns the Config\Service folder full path. This function is deprecated.
' RETURN        :
Friend Property Get ServiceDir() As String
    
    ServiceDir = ConfigDir & "\Service"

    On Error GoTo ErrMgr
    Exit Property
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXHandler.cls", "Clear", LOG_ERROR
End Property

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : ProductViewDir
' PARAMETERS    :
' DESCRIPTION   : Returns the Config\ProductView folder full path. This function is deprecated.
' RETURN        :
Friend Property Get ProductViewDir() As String

    On Error GoTo ErrMgr
    
    ProductViewDir = ConfigDir & "\ProductView"
    Exit Property
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXHandler.cls", "Clear", LOG_ERROR
End Property

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : ConfigDir
' PARAMETERS    :
' DESCRIPTION   : Gets the Config folder (full path).
' RETURN        :
Public Property Get ConfigDir() As String

    On Error GoTo ErrMgr

    ConfigDir = Tools.GetMTConfigDir()
    Exit Property
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXHandler.cls", "ConfigDir", LOG_ERROR
End Property

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : InternalDir
' PARAMETERS    :
' DESCRIPTION   : Returns the mdm\InternalDir folder full path.
' RETURN        :
Friend Property Get InternalDir() As String

    On Error GoTo ErrMgr

    InternalDir = MDMDir() & "\Internal"
    Exit Property
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXHandler.cls", "InternalDir", LOG_ERROR
End Property

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Class_Initialize
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Private Sub Class_Initialize()

    On Error GoTo ErrMgr
    
    Dim objWin As New cWindows
    
    SessionType = eMSIX_SESSION_TYPE_ATOMIC
    
    g_booReadEnumType = True
    
    m_lngInstanceId = objWin.GetTickCount()
    
    ' This Trace are important because I can check that the object is really created or Deleted
    ' TRACE "Constructor MSIXHandler ID=" & m_lngInstanceId & " ThreadID=" & App.ThreadID, "MSIX", "Class_Initialize", LOG_DEBUG
    Set Monitor = New MSIXMonitor
    
    g_lngMSIXInstanceActive = g_lngMSIXInstanceActive + 1
    g_lngMSIXInstanceCreated = g_lngMSIXInstanceCreated + 1

    m_strLanguage = METRATECH_DEFAULT_LANGUAGE
    m_strVersion = MDM_VERSION_13
    
    TRACE_CONSTRUCTOR_DESTRUCTOR Me, TRACE_CONSTRUCTOR_MODE
    
    MsixdefExtension = ""

    Exit Sub
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXHandler.cls", "Class_Initialize", LOG_ERROR
End Sub

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Class_Terminate
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Private Sub Class_Terminate()

    On Error GoTo ErrMgr
    
    Set m_objDictionary = Nothing
    Set m_objTools = Nothing

    If IsValidObject(Properties) Then  ' This is very important

        Properties.Delete               ' Because we have a notion of Parent in different classes of the all object model
                                        ' we introduced COM Circular references. The Delete() function break this circle.
        Set Properties = Nothing
        
    End If
    
    g_lngMSIXInstanceActive = g_lngMSIXInstanceActive - 1
    
    ' This Trace are important because I can check that the object is really created or Deleted
    
    TRACE_CONSTRUCTOR_DESTRUCTOR Me, TRACE_DESTRUCTOR_MODE
    
    Set Monitor = Nothing
    
    Exit Sub
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXHandler.cls", "Class_Terminate", LOG_ERROR
End Sub



' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : ProductViewMode
' PARAMETERS    :
' DESCRIPTION   : Returns TRUE is the object is a product view or FALSE for a service.
' RETURN        :
Friend Function ProductViewMode() As Boolean

    On Error GoTo ErrMgr

    ProductViewMode = CBool(Me.Properties.Flags And eMSIX_PROPERTIES_FLAG_PRODUCTVIEW)
    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXHandler.cls", "Version", LOG_ERROR
End Function

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : AppDir
' PARAMETERS    :
' DESCRIPTION   : Gets the application folder. This value is set by the client in the Initialize() function.
' RETURN        :
Public Property Get AppDir() As String

    On Error GoTo ErrMgr

    AppDir = m_strAppDir
    Exit Property
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXHandler.cls", "AppDir", LOG_ERROR
End Property

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Dictionary
' PARAMETERS    :
' DESCRIPTION   : Gets or sets the instance of the dictionary. The value is defined in the Initialize() function.
'                 If the dictionary object is not defined, the property return <code>Nothing</code>.
' RETURN        :
Public Property Get Dictionary() As Dictionary

    On Error GoTo ErrMgr

    Set Dictionary = m_objDictionary

    Exit Property
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXHandler.cls", "Dictionary", LOG_ERROR
End Property

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Dictionary
' PARAMETERS    :
' DESCRIPTION   : See property Get.
' RETURN        :
Public Property Set Dictionary(ByVal vNewValue As Dictionary)

    On Error GoTo ErrMgr

    Set m_objDictionary = vNewValue
    Exit Property
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXHandler.cls", "Dictionary", LOG_ERROR
End Property

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : RenderFlags
' PARAMETERS    :
' DESCRIPTION   : The MSIXEnumType class at some point need to know in which mode is the MSIX instance
'                 That's why this function is friendly!
' RETURN        :
Friend Property Get RenderFlags() As eMSIX_RENDER_FLAG

    On Error GoTo ErrMgr
    
    RenderFlags = m_eRenderFlags
    Exit Property
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXHandler.cls", "Dictionary", LOG_ERROR
End Property

Friend Property Let RenderFlags(eValue As eMSIX_RENDER_FLAG)

On Error GoTo ErrMgr

    m_eRenderFlags = eValue
    
    ' Update the MSIXProperties object from here because we do not have a circular reference
    ' the Class MSIXProperties does not have any parent...
    Me.Properties.RenderFlags = m_eRenderFlags
    Exit Property
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXHandler.cls", "Dictionary", LOG_ERROR
End Property

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : GetDictionnaryHTMLMetaTag
' PARAMETERS    :
' DESCRIPTION   : Returns from the dictionary the entry MDM_LANGUAGE_META_TAG
' RETURN        :
Friend Function GetDictionnaryHTMLMetaTag() As String

On Error GoTo ErrMgr

    GetDictionnaryHTMLMetaTag = vbNewLine & "<!-- Meta Tag from dictionary -->" & vbNewLine & Dictionary.Item(MDM_LANGUAGE_META_TAG).Value & vbNewLine
    Exit Function
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXHandler.cls", "Dictionary", LOG_ERROR
End Function


' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : InitPropertiesObject
' PARAMETERS    :
' DESCRIPTION   : Internal Initialization. To break the evil circle of the COM Circular reference due to the Parent member
'                 the object Properties does not have a Parent member referencing this class. But this class have to share
'                 some data. So these data are given to the Properties object while the MSIXHandler object is initializing.
' RETURN        :
Private Function InitPropertiesObject(eFlags As eMSIX_PROPERTIES_FLAG) As Boolean

    On Error GoTo ErrMgr
   
    Set Properties = New MSIXProperties
    
    Properties.Localized = Me.Localized
    Properties.Flags = eFlags           ' Tell the properties if it is a service or a product view
    Properties.Language = Me.Language
    Set Properties.Tools = Me.Tools     ' Give the instance of the of the tool class
    InitPropertiesObject = True
    
    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXHandler.cls", "InitPropertiesObject", LOG_ERROR
End Function

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : RenderLocalizationMode
' PARAMETERS    :
' DESCRIPTION   : Gets or sets the Rendering Localization Mode. If TRUE, the <code>RenderHTML()</code> function will localize the enum types.
'                 The default value is FALSE.
'                 If you set this property to TRUE the flag eMSIX_RENDER_FLAG_LOCALIZE_ENUM_TYPE is set into <code>RenderFlag</code> property
'                 when the function <code>RenderHTML()</code> is called. Then during the all life of the MDM dialog/PVB the value of the MSIX properties
'                 will be returned localized. The method <code>MSIXProperty.Value</code> has an optional parameter that can force to return
'                 the value (the non localized value) but on the case by case.
'
' RETURN        :
Public Property Get RenderLocalizationMode() As Boolean

    On Error GoTo ErrMgr
    
    RenderLocalizationMode = m_booRenderLocalizationMode
    Exit Property
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXHandler.cls", "RenderLocalizationMode", LOG_ERROR
End Property

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : RenderLocalizationMode
' PARAMETERS    :
' DESCRIPTION   : See property Get.
' RETURN        :
Public Property Let RenderLocalizationMode(ByVal vNewValue As Boolean)
    On Error GoTo ErrMgr
    
    m_booRenderLocalizationMode = vNewValue
    Exit Property
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXHandler.cls", "RenderLocalizationMode", LOG_ERROR
End Property

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : JavaScriptCode
' PARAMETERS    :
' DESCRIPTION   : Gets or sets the the pre-processed java script. In the initialize() function, the MDM JavaScript is loaded
'                 and preprocessed. Some MDM dialogs require changes to the pre-processed MDM JavaScript source code.
' RETURN        :
Public Property Get JavaScriptCode() As String

    On Error GoTo ErrMgr

    JavaScriptCode = m_JavaScriptCode
    Exit Property
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXHandler.cls", "JavaScriptCode", LOG_ERROR
End Property


' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : JavaScriptCode
' PARAMETERS    :
' DESCRIPTION   : See property Get.
' RETURN        :
Public Property Let JavaScriptCode(vNewValue As String)

    On Error GoTo ErrMgr

    m_JavaScriptCode = vNewValue
    Exit Property
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXHandler.cls", "JavaScriptCode", LOG_ERROR
End Property


' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Language
' PARAMETERS    :
' DESCRIPTION   : Gets the language associated with the service/product view. This value is set in the Initialize() function.
' RETURN        :
Public Property Get Language() As String

    On Error GoTo ErrMgr
    If Len(m_strLanguage) = 0 Or IsNumeric(m_strLanguage) Then
      m_strLanguage = "US"
      TRACE "Language not set defaulting to: " & m_strLanguage
    End If
    Language = m_strLanguage
    Exit Property
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXHandler.cls", "Language Get", LOG_ERROR
End Property

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Language
' PARAMETERS    :
' DESCRIPTION   : See property Get.
' RETURN        :
Friend Property Let Language(ByVal v As String)

    On Error GoTo ErrMgr
    
    m_strLanguage = v
    
    Exit Property
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXHandler.cls", "Language let", LOG_ERROR
End Property

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : SendTemplatedEMail
' PARAMETERS    :
'                   strEMailTemplateFileName    -   The XML email template file name (full path).
'                   strEMailSentTo              -   The email.
'                   objExtraTags                -   Extra tags for the email template.
'                   strTemplateName             -   The name of the template in the file (the default value is default).
'
' DESCRIPTION   : Send a templated email based on the MSIX property names/values of the service.
' RETURN        : TRUE if Ok else raise the error.
Public Function SendTemplatedEMail(ByVal strEMailTemplateFileName As String, ByVal strEMailSentTo As String, Optional ByVal objExtraTags As CVariables, Optional ByVal strTemplateName As String = "default", Optional ByVal strLanguage As String = "") As Boolean
    
    Dim objMsg                   As Object
    Dim objMail                  As Object
    Dim objTextFile              As New cTextFile
    Dim objProperty              As MSIXProperty
    Dim strError                 As String
    Dim objVar                   As CVariable
    
    On Error GoTo ErrMgr
    
'    'Debug.Assert 0
    
    SendTemplatedEMail = False
          
    Set objMsg = CreateObject("EMAILMESSAGE.MTEmailMessage.1")
    Set objMail = CreateObject("EMAIL.MTEmail.1")
        
    On Error Resume Next
    Err.Clear
    objMail.Init objMsg
    If (Err.Number) Then
    
        strError = MTMSIX_ERROR_01063 & GetVBErrorString()
        Log strError, LOG_ERROR
        GoSub Clean
        On Error GoTo 0
        RaiseError strError, , , LOG_APPLICATION_ERROR
    End If
    
    On Error GoTo ErrMgr
    
    If (Not objTextFile.ExistFile(strEMailTemplateFileName)) Then ' Check If the template exist
    
          Log Replace(MTMSIX_ERROR_01061, "[FILE]", strEMailTemplateFileName), LOG_ERROR
          Exit Function
    End If
        
    objMail.TemplateFileName = strEMailTemplateFileName
    objMail.TemplateName = "default"
    objMail.TemplateLanguage = IIf(strLanguage = "", UCase$(Language), UCase$(strLanguage))
    objMail.LoadTemplate
    
    objMsg.MessageTo = strEMailSentTo
    
    For Each objProperty In Me.Properties ' Add the service property as macros
    
        Log Replace(MTMSIX_ERROR_01062, "[NAME_VALUE]", "%%" & UCase$(objProperty.Name) & "%%" & "=" & objProperty.Value), LOG_DEBUG
        objMail.AddParam "%%" & UCase$(objProperty.Name) & "%%", "" & objProperty.LocalizedValue ' will convert NULL or EMPTY in ""
    Next
        
    If (IsValidObject(objExtraTags)) Then  ' Add the optional macros
    
        For Each objVar In objExtraTags
        
            Log Replace(MTMSIX_ERROR_01062, "[NAME_VALUE]", "%%" & UCase$(objVar.Name) & "%%" & "=" & objVar.Value), LOG_DEBUG
            objMail.AddParam "%%" & UCase$(objVar.Name) & "%%", "" & objVar.Value ' will convert NULL or EMPTY in ""
        Next
    End If

    On Error Resume Next
    Err.Clear
    objMail.send
    If (Err.Number) Then
    
        strError = MTMSIX_ERROR_01063 & GetVBErrorString()
        Log strError, LOG_ERROR
        GoSub Clean
        On Error GoTo 0
        RaiseError strError, , , LOG_APPLICATION_ERROR
    Else
        SendTemplatedEMail = True
    End If
    On Error GoTo 0
    
    GoSub Clean
    
    Exit Function
    
Clean:
    Set objMail = Nothing
    Set objMsg = Nothing
Return

ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXHandler.cls", "SendTemplatedEMail", LOG_ERROR
End Function

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Localized
' PARAMETERS    :
' DESCRIPTION   : Gets true if the service/product view properties are localized
' RETURN        :
Public Property Get Localized() As Boolean
    Localized = m_booLocalized
End Property

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Object
' PARAMETERS    :
' DESCRIPTION   : When a MSIX Handler support a COM object rather than a mt service or product view.
'                 The set property initialize the MSIXHandler based on the MTProperties collection exposed by
'                 the object. Once Initialized the MSIXHandler is populated including with the first level of
'                 of compound object.
' RETURN        :
Public Property Get Instance(Optional ByVal booInitialize As Boolean = True) As Object
    Set Instance = m_objCOMObject
End Property

Public Property Set Instance(Optional ByVal booInitialize As Boolean = True, ByVal vNewValue As Object)

    If (IsValidObject(vNewValue)) Then ' Init the MSIXProperties with COM Object description
    
        Set m_objCOMObject = vNewValue
        
        If (booInitialize) Then
        
            'Debug.Assert 0
        
            Properties.Flags = eMSIX_PROPERTIES_FLAG_COM_OBJECT
            Properties.InitializeAsCOMObject m_objCOMObject
            Me.Name = TypeName(m_objCOMObject)
            Properties.Name = Me.Name
            Properties.CancelLocalization
            Me.LoadJavaScriptCode
            
        End If
        If Not Properties.PopulateFromCOMObject(m_objCOMObject) Then

            RaiseError PreProcess(MTMSIX_ERROR_01103, "OBJECTTYPE", TypeName(vNewValue)), , , LOG_APPLICATION_ERROR
        End If
    Else
        Set m_objCOMObject = Nothing
    End If
End Property


' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Version
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Property Get Version() As String
    Version = m_strVersion
End Property

Friend Property Let Version(ByVal vNewValue As String)
    m_strVersion = vNewValue
    Properties.Version = vNewValue
End Property


' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Properties
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Property Get Properties() As MSIXProperties
Attribute Properties.VB_UserMemId = 0
    On Error GoTo ErrMgr

    Set Properties = m_Properties

    Exit Property
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIX.cls", "Get Properties", LOG_ERROR
End Property

Public Property Set Properties(ByVal vNewValue As MSIXProperties)
    On Error GoTo ErrMgr
    
    If IsValidObject(m_Properties) Then
      m_Properties.Delete
      Set m_Properties = Nothing
    End If
    If IsValidObject(vNewValue) Then
      Set m_Properties = vNewValue
    End If

    Exit Property
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIX.cls", "Let Properties", LOG_ERROR
End Property

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Version
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Property Get DLLVersion() As String
    DLLVersion = App.Major & "." & App.Minor
End Property

Public Property Get SecurityContext() As Object

    If IsValidObject(SessionContext) Then
        Set SecurityContext = SessionContext.SecurityContext
    End If
End Property

Public Function MeterCSVFile(ByVal strInputCSVFile As String, ByVal strOutPutCSVFile As String, ByVal booBacthMode As Boolean, Optional ByVal WScript As Variant, Optional ByRef varMeteredRow As Variant, Optional ByVal booContinueIfFail As Boolean = False, Optional ByRef varErrorCount As Variant, Optional ByVal strExtraPropertiesCSV As String, Optional ByVal bForceOutput As Boolean = False) As Boolean

    Dim objTextFile         As New cTextFile
    Dim strCSVHeaders       As String
    Dim arrCSVHeaders       As Variant
    Dim s                   As String
    Dim arrData             As Variant
    Dim i                   As Long
    Dim varOutPutSession    As Variant
    Dim objOutPutCSV        As New cStringConcat
    Dim lngAccountID        As String
    Dim strDashValues       As String
    Dim eMeterFlag          As eMSIX_METER_MODE
    Dim lngAccountIDCounter As Long
    Dim booIsAccountCreationService As Boolean
    Dim strTmpAccountID     As String
    Dim lngErrorNumber      As Long
    Dim strErrorDescription As String
    Dim booMeterSucceed     As Boolean
    Dim v                   As Variant
    Dim ss                  As String
    Dim booUTF8Mode         As Boolean
        
    
    Const UTF8_CSV_MARK = "#UTF8 "

    
    varErrorCount = 0
    
    booIsAccountCreationService = InStr(LCase$(Me.Name), "accountcreation")
    
    If IsMissing(WScript) Then Set WScript = Nothing
    
    Debug.Assert 0
    
    On Error GoTo ErrMgr
    
    eMeterFlag = eMSIX_METER_MODE_PASS_FIRST_SESSION
    
    objOutPutCSV.Init 16384
    
    If booIsAccountCreationService Or bForceOutput Then objOutPutCSV.Concat "AccountID, UserName, Name_Space, PassWord_"
    
    If objTextFile.OpenFile(strInputCSVFile) Then
    
        If IsValidObject(WScript) Then WScript.StdOut.Write IIf(booBacthMode, "Filling session set", "Metering")
    
        strCSVHeaders = objTextFile.ReadLn()
        arrCSVHeaders = Tools.SmartSplit(strCSVHeaders, ",")
        
        For i = 0 To UBound(arrCSVHeaders)
        
            If Mid(arrCSVHeaders(i), 1, 1) = "#" Then objOutPutCSV.Concat "," & arrCSVHeaders(i)
        Next
        objOutPutCSV.Concat vbNewLine
                
        Do While Not objTextFile.EOF()
        
            booUTF8Mode = False
            s = Trim(objTextFile.ReadLn)
            
            
            If Len(s) Then
            
                If Mid(s, 1, 1) = "'" Then
                
                    'WScript.Echo s ' Print the comment
                Else
                    strDashValues = ""
                    Me.Clear
                                        
                    If InStr(s, UTF8_CSV_MARK) = 1 Then ' In 3.7 we support a way to load/decode UTF8
                    
                        Debug.Assert 0
                        s = Mid(s, Len(UTF8_CSV_MARK) + 1)
                        booUTF8Mode = True
                    End If
                    
                    arrData = Tools.SmartSplit(s, ",")
                                        
                    For i = 0 To UBound(arrData)
                        
                        If Me.Properties.Exist(arrCSVHeaders(i)) Then
                        
                            If Len(arrData(i)) Then
                                
                                Debug.Print arrCSVHeaders(i) & "=" & Trim(arrData(i))
                                
                                If booUTF8Mode And ( _
                                    Me.Properties.Item(arrCSVHeaders(i)).PropertyType = MSIXDEF_TYPE_STRING Or _
                                    Me.Properties.Item(arrCSVHeaders(i)).PropertyType = MSIXDEF_TYPE_UNISTRING _
                                ) Then  ' THIS IS VERY SLOW BUT SO FAR THIS THE ONLY WAY THAT WORKS...
                                
                                    arrData(i) = SlowConvertFromUTF8ToUnicode(Trim(arrData(i)))
                                End If
                                Debug.Print arrCSVHeaders(i) & "=" & Trim(arrData(i))
                                
                                Me.Properties(arrCSVHeaders(i)).Value = Trim(arrData(i))
                            Else
                                Me.Properties(arrCSVHeaders(i)).Value = Empty ' Will not be metered
                            End If
                        Else
                            If Mid(arrCSVHeaders(i), 1, 1) = "#" Then
                            
                               strDashValues = strDashValues & arrData(i) & ","
                            Else
                                On Error GoTo 0
                                RaiseError MTGlobal_VB_MSG.PreProcess(MTMSIX_ERROR_01099, "NAME", arrCSVHeaders(i)), TypeName(Me), 1099, LOG_ERROR
                            End If
                        End If
                    Next
                    
                    Me.Properties.CSV(True) = strExtraPropertiesCSV
                    
                    booMeterSucceed = True
                    
                    If booBacthMode Then
                    
                        strTmpAccountID = ""
                        Me.Meter False, , , eMeterFlag
                        eMeterFlag = eMSIX_METER_MODE_PASS_SESSION
                        If Len(strDashValues) Then strDashValues = Mid(strDashValues, 1, Len(strDashValues) - 1)
                    Else
                    
                        If booContinueIfFail Then
                            On Error Resume Next
                            Me.Meter True, varOutPutSession
                            If Err.Number Then
                                GoSub LogError
                                varErrorCount = varErrorCount + 1
                                booMeterSucceed = False
                            End If
                            On Error GoTo ErrMgr
                        Else
                            Me.Meter True, varOutPutSession
                        End If
                        If booMeterSucceed Then
                            strTmpAccountID = varOutPutSession.GetProperty("_AccountId")
                        End If
                    End If
                    If booMeterSucceed Then
                        
                        If booIsAccountCreationService Or bForceOutput Then ' Check for account creation msixdef
                            objOutPutCSV.Concat strTmpAccountID & "," & Me.Properties("UserName").Value & "," & Me.Properties("Name_Space").Value & "," & Me.Properties("PassWord_").Value & "," & strDashValues & vbNewLine ' AccountID Is Empty For Now
                        End If
                        lngAccountIDCounter = lngAccountIDCounter + 1
                    End If
                    If IsValidObject(WScript) Then WScript.StdOut.Write "."
                End If
            End If
        Loop
        
        objTextFile.CloseFile
        
        If booBacthMode Then
        
            If IsValidObject(WScript) Then WScript.Echo vbNewLine & "Metering SessionSet with " & lngAccountIDCounter & " session(s)"
            Me.Meter False, varOutPutSession, , eMSIX_METER_MODE_METER_SESSION_SET
        Else
            If IsValidObject(WScript) Then WScript.Echo vbNewLine
        End If
        
        varMeteredRow = lngAccountIDCounter
        
        objTextFile.LogFile strOutPutCSVFile, objOutPutCSV.GetString(), True
        MeterCSVFile = True
    End If
    Exit Function
    
LogError:
    lngErrorNumber = Err.Number
    strErrorDescription = GetVBErrorString()
    TRACE MTMSIX_ERROR_01033 & strErrorDescription, "MSIXHandler.cls", "MeterCSVFile", LOG_ERROR
Return
    
ErrMgr:
    GoSub LogError
    RaiseError strErrorDescription, TypeName(Me), lngErrorNumber, LOG_ERROR
End Function

Public Property Get ReadEnumType() As Boolean
    ReadEnumType = g_booReadEnumType
End Property

Public Property Let ReadEnumType(ByVal vNewValue As Boolean)
    g_booReadEnumType = vNewValue
End Property


Private Function GetChildIndexWithMostProperties(ByVal handlers As MSIXHandlers) As Long
  
  Dim handler As MSIXHandler
  Dim childIndex As Long
  Dim numChildProperties As Long
  Dim i As Long
  
  On Error GoTo ErrMgr

  childIndex = 1
  numChildProperties = 0
  
  For i = 1 To handlers.Count
    If (handlers(i).Properties.Count > numChildProperties) Then
      numChildProperties = handlers(i).Properties.Count
      childIndex = i
    End If
  Next

  GetChildIndexWithMostProperties = childIndex

Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), Me, "GetMaxColumnsOfChildren", LOG_ERROR
End Function


Public Function GetChildrenAsRowset(ByVal strChildrenType As String, Optional ByVal booLocalize As Boolean = True, Optional ByVal strFailureSessionId As String) As Object

    Dim objChildMSIXHandler         As MSIXHandler
    Dim lngMaxChildren              As Long
    Dim objRowset                   As New MTSQLRowsetSimulator
    Dim objFirstChildMSIXHandler    As MSIXHandler
    Dim i                           As Long
    Dim r                           As Long
    Dim arrColumnNames              As Long
    Dim objChildrenType             As MSIXHandlerType
    Dim objChild                    As MSIXHandler
    Dim objMSIXProperty             As MSIXProperty
    Dim iChildKeyColumn             As Long
    Dim iErrorColumn                As Long
    
    ''Debug.Assert 0
    
    If Not IsValidObject(Me.SessionChildrenTypes) Then Exit Function
    If Not SessionChildrenTypes.Exist(strChildrenType) Then Exit Function
        
    Set objChildrenType = SessionChildrenTypes.Item(strChildrenType)
    
    ' Initialize with the row that has the most columns
    Set objFirstChildMSIXHandler = objChildrenType.Children(GetChildIndexWithMostProperties(objChildrenType.Children))
    
    ' Because it is not selected for display, the Child Key column needs to be the last column
    iChildKeyColumn = objFirstChildMSIXHandler.Properties.Count + IIf(Len(strFailureSessionId), 1, 0)
    iErrorColumn = IIf(Len(strFailureSessionId), 1, 0)
    
    objRowset.Initialize objChildrenType.Children.Count, iChildKeyColumn + 1
    
    ' Popupate the columns name
    For i = 1 To objFirstChildMSIXHandler.Properties.Count
        objRowset.Name(i - 1 + iErrorColumn) = IIf(booLocalize, objFirstChildMSIXHandler.Properties(i).Caption, objFirstChildMSIXHandler.Properties(i).Name)
    Next
    
    If (Len(strFailureSessionId)) Then
        objRowset.Name(iErrorColumn - 1) = "_Error"
    End If
    
    ' Internal property
    objRowset.Name(iChildKeyColumn) = "_ChildKey"
    
    ' populate the data
    For Each objChild In objChildrenType.Children
    
        For i = 1 To objChild.Properties.Count
        
            objRowset.Value(i - 1 + iErrorColumn) = objChild.Properties(i).Value
        Next
        objRowset.Value(iChildKeyColumn) = objChild.ChildKey
        If (Len(strFailureSessionId)) Then
            If objChild.uID = strFailureSessionId Then
                objRowset.Value(iErrorColumn - 1) = "True"
            Else
                objRowset.Value(iErrorColumn - 1) = "False"
            End If
        End If
        objRowset.MoveNext
    Next
    objRowset.MoveFirst
    Set GetChildrenAsRowset = objRowset

Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), Me, "GetChildrenAsRowset", LOG_ERROR
End Function


Private Function GetMainSession(XMLDoc As MSXML2.DOMDocument30) As IXMLDOMNode

    Dim objBeginSession  As IXMLDOMNode
    Dim objBeginSessions As IXMLDOMNodeList
    
    On Error GoTo ErrMgr
    
    Set objBeginSessions = XMLDoc.selectNodes("/msix/beginsession")
    For Each objBeginSession In objBeginSessions
    
        ' find the one which has not parentid member
        If Not IsValidObject(objBeginSession.selectSingleNode("/parentid")) Then
            Set GetMainSession = objBeginSession
            Exit Function
        End If
    Next
Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), Me, "GetMainSession", LOG_ERROR
End Function


Public Function IsAtomic() As Boolean
    IsAtomic = SessionType And eMSIX_SESSION_TYPE_ATOMIC
End Function

Public Function CommonProperties() As Collection

    Dim objCommonProperties     As New Collection
    Dim booIsInAllChildren      As Boolean
    Dim objMSIXChild            As MSIXHandler
    Dim objSessionChildrenType  As MSIXHandlerType
    Dim objMSIXHandler          As MSIXProperty
    
    If IsAtomic() Then
    
        For Each objMSIXHandler In Me.Properties
        
            objCommonProperties.Add objMSIXHandler.Name
        Next
    Else
        For Each objMSIXHandler In Me.Properties
        
            booIsInAllChildren = True
            
            For Each objSessionChildrenType In Me.SessionChildrenTypes
            
                For Each objMSIXChild In objSessionChildrenType.Children
                        
                    If Not objMSIXChild.Properties.Exist(objMSIXHandler.Name) Then
                        booIsInAllChildren = False
                        Exit For
                    End If
                Next
            Next
            If booIsInAllChildren Then
                objCommonProperties.Add objMSIXHandler.Name
            End If
        Next
    End If
    Set CommonProperties = objCommonProperties
End Function

Public Function UpdateParentAndChildrenProperty(ByVal strPropertyName As String, ByVal strNewValue As Variant, Optional ByVal strOperator As String, Optional ByVal varCompareValue As Variant) As Long

    Dim objFakeMSIXHandlers     As New MSIXHandlers
    Dim objMSIXChild            As MSIXHandler
    Dim objSessionChildrenType  As MSIXHandlerType
    Dim lngUpdateCounter        As Long
    
    ' Put the parent instance in a fake MSIXHandlers so we can call the property objFakeMSIXHandlers.UpdateProperty
    objFakeMSIXHandlers.Add "parent", Me, Me.Language, Me.Version
    lngUpdateCounter = lngUpdateCounter + objFakeMSIXHandlers.UpdateProperty(strPropertyName, strNewValue, strOperator, varCompareValue)
    
    For Each objSessionChildrenType In Me.SessionChildrenTypes
    
        lngUpdateCounter = lngUpdateCounter + objSessionChildrenType.Children.UpdateProperty(strPropertyName, strNewValue, strOperator, varCompareValue)
    Next
    UpdateParentAndChildrenProperty = lngUpdateCounter
End Function

Private Function ExecuteSQLQuery(strFolderInit, strSQL) As Object
    Dim LastRowset
    Set LastRowset = CreateObject("MTSQLRowset.MTSQLRowset.1")
    LastRowset.Init strFolderInit
    LastRowset.SetQueryString strSQL
    LastRowset.Execute
    Set ExecuteSQLQuery = LastRowset
End Function

Private Function GetEnumData(ByVal lngID As Long) As String
'
'    Dim strSQL As String
'    Dim r As Object
'    strSQL = "select nm_enum_data from t_enum_data where id_enum_data = " & lngID
'    Set r = ExecuteSQLQuery("queries\audit", strSQL)
'    GetEnumData = r.Value(0)
    GetEnumData = Tools.PVNameIdLookUpObject.GetName(lngID)
End Function


Public Property Let XML( _
    Optional ByVal MDMFolder As String, _
    Optional ByVal strLanguage As String = "US", _
    Optional ByVal strVersion As String = "3.5", _
    Optional ByVal IsCompoundParentOrAtomic As Boolean = True, _
    Optional ByVal objChildSessionParam As Variant, _
    Optional ByVal strServerName As String, _
    Optional ByVal objCache As MSIXCache, _
    strXML As String)

    On Error GoTo ErrMgr
    
    Dim strServiceName      As String
    Dim strServiceFileName  As String
    Dim strChildServiceName As String
    Dim IsCompound          As Boolean
    Dim i                   As Long
    Dim objMSIXHanlderChild As MSIXHandler
    Dim strErrorMessage     As String
    Dim SessionChildrenType As MSIXHandlerType
    Dim objPipeline         As New MTPipeline
    Dim objSession          As IMTSession
    Dim objSessionSet       As IMTSessionSet
    Dim vchild              As Variant
    Dim objChildSession     As IMTSession
    Dim Value               As Variant
    Dim temp                As Variant
    

'Debug.Assert 0
    

'    Dim t As New cTextFile
 '   t.LogFile Environ("temp") & "\msixhandler.let.xml.xml", strXML
    
    If IsMissing(objChildSessionParam) Then
    
'        Set objSession = objPipeline.ExamineSession(strXML)
'
        Set objSessionSet = objPipeline.ExamineSessions(strXML)
        For Each temp In objSessionSet ' Just a trick to get the first session
            Set objSession = temp
            Set temp = Nothing '
            Exit For
        Next
        m_strSessionSetUIDAsString = objSessionSet.UIDAsString ' Save this to restore it when we serialize out
    Else
        Set objSession = objChildSessionParam
    End If
    
    If objSession.HoldsSessionContext Then ' If we have a security context save the object
        Set m_objUnSerializedInstanceSecurityContext = objSession.SessionContext
    End If
    
    If IsCompoundParentOrAtomic Then
        Set SessionChildrenTypes = Nothing ' Clear children in case they were already loaded...
    End If
    
    strServiceName = GetEnumData(objSession.ServiceID)
    strServiceFileName = Replace(strServiceName & ".msixdef", "/", "\")
            
    Debug.Print "load " & strServiceName
    
    If Not Me.Initialize(strServiceFileName, , strLanguage, , MDMFolder, objCache, , strVersion) Then
        
        strErrorMessage = MTGlobal_VB_MSG.PreProcess(MTMSIX_ERROR_01101, "SERVICEDEF", strServiceName): GoTo RAISE_MSG_ERROR
    End If
    
    Me.Properties.Name = strServiceName
    Me.Properties.Session = objSession ' COPY THE PROPERTIES VALUE
    Me.uID = objSession.UIDAsString
        
    If objSession.IsParent Then ' we need to read the children
    
        ''Debug.Assert 0
        
        SessionType = eMSIX_SESSION_TYPE_COMPOUND + IIf(IsCompoundParentOrAtomic, eMSIX_SESSION_TYPE_PARENT, eMSIX_SESSION_TYPE_CHILD)
        
        ' Alloc the types collection
        If Not IsValidObject(SessionChildrenTypes) Then Set SessionChildrenTypes = New MSIXHandlerTypes

        For Each objChildSession In objSession.SessionChildren

            strChildServiceName = GetEnumData(objChildSession.ServiceID)
            
            ' Find the Child Type Collection to use
            If SessionChildrenTypes.Exist(strChildServiceName) Then
                Set SessionChildrenType = SessionChildrenTypes(strChildServiceName)
            Else
                Set SessionChildrenType = SessionChildrenTypes.Add(strChildServiceName)
            End If

            ' Alloc a new instance
            Set objMSIXHanlderChild = New MSIXHandler
            Set objMSIXHanlderChild.Dictionary = Me.Dictionary

            objMSIXHanlderChild.SessionType = eMSIX_SESSION_TYPE_CHILD + eMSIX_SESSION_TYPE_COMPOUND
            
            ' Recursiv call to populate the child instance
            objMSIXHanlderChild.XML(MDMFolder, strLanguage, strVersion, False, objChildSession) = "THIS TEXT IS IGNORED"
            
            ' Add to the collection
            SessionChildrenType.Children.Add , objMSIXHanlderChild
        Next
    End If
    GoSub Clean
    Exit Property
    
Clean:
    Set objSession = Nothing
    Set objSessionSet = Nothing
    Set objPipeline = Nothing
Return
        
RAISE_MSG_ERROR:
    GoSub Clean
    TRACE strErrorMessage, Me, "XML Let", LOG_ERROR
    On Error GoTo 0
    RaiseError strErrorMessage, TypeName(Me)
Exit Property ' never executed
    
ErrMgr:
    Select Case Err.Number
    Case &HE1200019
      strErrorMessage = MTMSIX_ERROR_01105 & GetVBErrorString()
    Case Else
      strErrorMessage = MTMSIX_ERROR_01033 & GetVBErrorString()
    End Select
    GoTo RAISE_MSG_ERROR
End Property

'
' if we have a mom user we try to impersonate the account use to metered
' if we do not we reuse the same security context : this case should only happend for unit test purpose...
'


Public Property Get XML(Optional ByVal MDMFolder As String, Optional ByVal strLanguage As String = "US", Optional ByVal strVersion As String = "3.5", Optional ByVal IsCompoundParentOrAtomic As Boolean = True, Optional ByVal objChildSessionParam As Variant, Optional ByVal strServerName As String, Optional ByVal objCache As MSIXCache) As String


    On Error GoTo ErrMgr
    
    Dim objMeter                As New COMMeterLib.Meter
    Dim objServerAccessSet      As New MTServerAccessDataSet
    Dim objServerAccess         As MTServerAccessData
    Dim objMSIXProperty         As MSIXProperty
    Dim objSession              As COMMeterLib.Session
    Dim objChildSession         As COMMeterLib.Session
    Dim objMSIXHandlerChild     As MSIXHandler
    Dim SessionChildrenType     As MSIXHandlerType
    Dim InSessionSet            As COMMeterLib.SessionSet
    
    'Debug.Assert 0
    
    If Len(strServerName) = 0 Then strServerName = MTMSIX_DEFAULT_SERVER_NAME_TO_METER
    
    objServerAccessSet.Initialize
    Set objServerAccess = objServerAccessSet.FindAndReturnObject(strServerName)
    Set objServerAccessSet = Nothing
    With objServerAccess
        objMeter.HTTPTimeout = .Timeout
        objMeter.HTTPRetries = .NumRetries
        Call objMeter.AddServer(.Priority, .ServerName, .PortNumber, .Secure, .UserName, .PassWord)
    End With
    Set objServerAccess = Nothing
    
    objMeter.Startup
    
    Set InSessionSet = objMeter.CreateSessionSet
    Set objSession = InSessionSet.CreateSession(Me.Name)
    
    InSessionSet.[_SetID] = m_strSessionSetUIDAsString
    
    ' Restore the original UID at the parent level
    objSession.[_ID] = Me.uID
        
    For Each objMSIXProperty In Me.Properties
    
        If Not IsEmpty(objMSIXProperty.Value) Then
        
            If ((objMSIXProperty.Flags And eMSIX_PROPERTY_FLAG_LOADED_FROM_MSIXDEF) = eMSIX_PROPERTY_FLAG_LOADED_FROM_MSIXDEF) And (objMSIXProperty.Flags And eMSIX_PROPERTY_FLAG_METERED) Then
            
                objSession.InitProperty objMSIXProperty.Name, objMSIXProperty.Value
            End If
        End If
    Next
    
    If IsValidObject(SessionChildrenTypes) Then

        For Each SessionChildrenType In SessionChildrenTypes

            For Each objMSIXHandlerChild In SessionChildrenType.Children
            
                Set objChildSession = objSession.CreateChildSession(objMSIXHandlerChild.Name)
                
                ' Restore the original UID at the child level
                objChildSession.[_ID] = objMSIXHandlerChild.uID
                
                For Each objMSIXProperty In objMSIXHandlerChild.Properties
                
                    If ((objMSIXProperty.Flags And eMSIX_PROPERTY_FLAG_LOADED_FROM_MSIXDEF) = eMSIX_PROPERTY_FLAG_LOADED_FROM_MSIXDEF) And (objMSIXProperty.Flags And eMSIX_PROPERTY_FLAG_METERED) Then
                    
                        If Not IsEmpty(objMSIXProperty.Value) Then
                    
                            objChildSession.InitProperty objMSIXProperty.Name, objMSIXProperty.Value
                        End If
                    End If
                Next
            Next
        Next
    End If
    
    Dim strXML As String
    strXML = InSessionSet.ToXML
    XML = strXML

TheExit:
    Set objSession = Nothing
    Set InSessionSet = Nothing
    Set objMeter = Nothing
    Exit Property
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), Me, "XML Get", LOG_ERROR
  GoTo TheExit
End Property


'Public Property Get XML(Optional ByVal MDMFolder As String, Optional ByVal strLanguage As String = "US", Optional ByVal strVersion As String = "3.5", Optional ByVal IsCompoundParentOrAtomic As Boolean = True, Optional ByVal objChildSessionParam As Variant) As String
'
'
'    On Error GoTo ErrMgr
'
'    Dim strXML              As String
'    Dim strSpace            As String
'    Dim objMSIXHandlerChild As MSIXHandler
'    Dim SessionChildrenType As MSIXHandlerType
'
'    If CBool(Me.SessionType And eMSIX_SESSION_TYPE_ATOMIC) Or CBool(Me.SessionType And eMSIX_SESSION_TYPE_PARENT) Then
'        strXML = strXML & "<msix>" & vbNewLine
'        strXML = strXML & MSIXMeteredInformation.XML
'    End If
'
'    strXML = strXML & "<beginsession>" & vbNewLine
'    strXML = strXML & MSIXSessionMeteredInformation.XML
'    strXML = strXML & Properties.XML
'    strXML = strXML & "</beginsession>" & vbNewLine
'
'    If IsValidObject(SessionChildrenTypes) Then
'
'        For Each SessionChildrenType In SessionChildrenTypes
'
'            For Each objMSIXHandlerChild In SessionChildrenType.Children
'
'                strXML = strXML & objMSIXHandlerChild.XML & vbNewLine
'            Next
'        Next
'    End If
'
'    If CBool(Me.SessionType And eMSIX_SESSION_TYPE_ATOMIC) Or CBool(Me.SessionType And eMSIX_SESSION_TYPE_PARENT) Then
'        strXML = strXML & "</msix>" & vbNewLine
'    End If
'    XML = strXML
'    Exit Property
'ErrMgr:
'  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), Me, "XML Get", LOG_ERROR
'End Property

Public Property Get MeteredSessionSet() As COMMeterLib.SessionSet
    Set MeteredSessionSet = m_PipeLine.InSessionSet
    
End Property

Public Function CleanMeteredSessionSet() As Boolean

    On Error GoTo ErrMgr
    CleanMeteredSessionSet = m_PipeLine.CleanMeteredSessionSet
    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), Me, "CleanMeteredSessionSet", LOG_ERROR
End Function

Private Function SlowConvertFromUTF8ToUnicode(s As String) As String

    Dim strXML              As String
    Dim strUniqueFileName   As String
    
    
    If InStr(s, "JPN:") Then
        Debug.Assert 0
    End If
    
    strUniqueFileName = Environ("TEMP") & "\mtmsix.msixhanlder.SlowConvertFromUTF8ToUnicode.xml"
    
    strXML = "<?xml version=""1.0"" encoding=""UTF-8""?><S>" & s & "</S>"
    
    Dim t As New cTextFile
    
    t.LogFile strUniqueFileName, strXML, True
            
    'Dim objXML As New DOMDocument30
    Dim objXML As Variant
    Set objXML = CreateObject("Msxml2.DOMDocument.4.0")
    objXML.Load strUniqueFileName
    
    If objXML.parseError.ErrorCode = 0 Then
    
        SlowConvertFromUTF8ToUnicode = objXML.selectSingleNode("/S").Text
    Else
        Err.Raise 9999, TypeName(Me), "SlowConvertFromUTF8ToUnicode cannot parse the xml file:" & strUniqueFileName
    End If
        
End Function
