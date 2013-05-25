Attribute VB_Name = "MTGlobal_VB_MSG"
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
' * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
'
' NAME          :   MTGlobal_VB_Msg.bas
' DESCRIPTION   :   Metratech Visual Basic Applications Error Messages and how to log errors and messages in the MTLOG.TXT file.
'
'                   Error format : An error is a string build with 3 sections:
'
'                       -   The error number - must be 5 digit. Mandatory.
'                       -   The Application/COM Object Name. Optional.
'                       -   The error message itself.
'
' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
'
' Application reserved error code.
'
'   - MTMSIX                    VB COM Object  : 01000 to 01499
'   - MTMAM                     VB COM Object  : 01500 to 01999
'   - MTPayementServerHelper    VB COM Object  : 02000 to 02499
'   - MTTabRulesetReader        VB COM Object  : 02500 to 02999
'   - MTAdminNavbar             VB COM Object  : 03000 to 03499
'   - MTVBLib                   VB COM Object  : 03500 to 03999
'   - MDM UpGrader Application                 : 04000 to 04500
'
'
'
' ****************************************************************************************************************************************************
Option Explicit


Private Const MTDEFAULTDEFAULTtLOGFileName As String = "logging"

Private m_strMTDEFAULTtLOGFileName As String

' This value define that a MT COM Error is visible by the user.
' see function IsUserVisibleMTCOMError() in the file...
Const USER_ERROR_MASK As Long = &H2C000000 ' #define USER_ERROR_MASK 0x2C000000


' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
' MTMSIX COM Object Errors
' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Public Const MTMSIX_ERROR_01000 = "String value too long for the property [PROPERTY]"
Public Const MTMSIX_ERROR_01001 = "Int32 type mismatch for the property [PROPERTY]. value = '[VALUE]'"
Public Const MTMSIX_ERROR_01002 = "Float type mismatch for the property [PROPERTY]. value = '[VALUE]'"
Public Const MTMSIX_ERROR_01003 = "Double type mismatch for the property [PROPERTY]. value = '[VALUE]'"
Public Const MTMSIX_ERROR_01004 = "Property [NAME] is required"
Public Const MTMSIX_ERROR_01005 = "WARNING-The combo box/property [NAME] is not an enum type"
Public Const MTMSIX_ERROR_01006 = "Numeric overflow for the property [PROPERTY], value '[VALUE]' (Cannot convert into DECIMAL)"
Public Const MTMSIX_ERROR_01007 = "HTML Template file [FILE] not found"
Public Const MTMSIX_ERROR_01008 = "Template Parsing Error.<br>[TAG] tag found with no name in HTML template file=[FILE]"
Public Const MTMSIX_ERROR_01009 = "[TAG] tag found with name='[NAME]' not defined in service [SERVICE]."
Public Const MTMSIX_ERROR_01010 = "Template Parsing Error.<br>HTML Syntax error in HTML template file=[FILE]<br>Text='[TEXT]'"
Public Const MTMSIX_ERROR_01011 = "ProductView Properties objects have not been intialized service [NAME]"
Public Const MTMSIX_ERROR_01012 = "File [FILE] not found"
Public Const MTMSIX_ERROR_01013 = "Tag [TAG] not found in HTML Template file [FILE]"
Public Const MTMSIX_ERROR_01014 = "E-mail [EMAIL] is not valid"
Public Const MTMSIX_ERROR_01015 = "File [FILE] not found"
Public Const MTMSIX_ERROR_01016 = "XML Tag </DialogMetaData> not found in File [FILE]"
Public Const MTMSIX_ERROR_01017 = "Dictionary entry [ENTRY] not found"
Public Const MTMSIX_ERROR_01018 = "Loading Dictionary file [NAME] failed"
Public Const MTMSIX_ERROR_01019 = "Syntax error reading asp file [FILENAME] line [LINE]"
Public Const MTMSIX_ERROR_01020 = "Error while parsing/replacing image path, HTML attribute name='[NAME]'"
Public Const MTMSIX_ERROR_01021 = "WARNING-More than one <FORM> tag found in the HTML Template file [FILE]"
Public Const MTMSIX_ERROR_01022 = "WARNING-Property [NAME] is not metered because its value is Empty/Null!"
Public Const MTMSIX_ERROR_01023 = "Enum Type [NAMESPACE]\[ENUMTYPE] not found. Language=[LANGUAGE]"
Public Const MTMSIX_ERROR_01024 = "Boolean type mismatch for the property. value = '[VALUE]'"
Public Const MTMSIX_ERROR_01025 = "Load() failed"
Public Const MTMSIX_ERROR_01026 = "[ERRORTAG] Loading Dictionary XML File [FILE] [RESULT]"
Public Const MTMSIX_ERROR_01027 = "WARNING-Dictionary entry [ENTRY] expected but not found"
Public Const MTMSIX_ERROR_01028 = "It is not possible to set a product view property [PROPERTY]. value = '[VALUE]'"
Public Const MTMSIX_ERROR_01029 = "ProductView MSIXDEF file [FILE] error,  UserVisible or FilterAble or ExportAble value is not a valid boolean"
Public Const MTMSIX_ERROR_01030 = "WARNING-Property [NAME] is not metered because it is not enabled"
Public Const MTMSIX_ERROR_01031 = "MDMError.PropertyCaption property get failed. Optional parameter is required. PropertyName=[NAME]"
Public Const MTMSIX_ERROR_01032 = "Invalid parameter [PARAMETER] value [VALUE]"
Public Const MTMSIX_ERROR_01033 = "VB Run Time Error occurred. "
Public Const MTMSIX_ERROR_01034 = "Rowset object not initialized in object Page (MDMPage)"
Public Const MTMSIX_ERROR_01035 = "WARNING-MSIXDEF Service file or MSIXDEF ProductView file not defined in the initialize() method"
Public Const MTMSIX_ERROR_01036 = "Localized string [FQN] not found. Language=[LANGUAGE]"
Public Const MTMSIX_ERROR_01037 = "Error while parsing/replacing HTML [TAG] tag , attribute Type is not defined or unknown. Name=[NAME]."
Public Const MTMSIX_ERROR_01038 = "WARNING-Remove item [NAME], type=[TYPE] from the Cache."
Public Const MTMSIX_ERROR_01039 = "Cannot convert UMT date [DATE] into a VT_DATE"
Public Const MTMSIX_ERROR_01040 = "Entry [ENTRY] not found in dictionary"
Public Const MTMSIX_ERROR_01041 = "Loading XML Menu file [NAME] failed"
Public Const MTMSIX_ERROR_01042 = "Error while parsing/replacing HTML [TAG] tag Name=[NAME]."
Public Const MTMSIX_ERROR_01043 = "Dictionary object required for localization rendering, tag [TAG] Name=[NAME]."
Public Const MTMSIX_ERROR_01044 = "Dictionary entry [NAME] not found for localization rendering. Tag [TAG]."
Public Const MTMSIX_ERROR_01045 = "Error while reading msixdef file [FILE], length is not numeric."
Public Const MTMSIX_ERROR_01046 = "WARNING-Length is not defined for the property [NAME], in service/product view [FILE]. Length is set to the max."
Public Const MTMSIX_ERROR_01047 = "Property [PROPERTY] not found in product view rowset"
Public Const MTMSIX_ERROR_01048 = "Rowset is not loaded in class MSIXProperties name=[NAME]"
Public Const MTMSIX_ERROR_01049 = "Column [NAME] not found"
Public Const MTMSIX_ERROR_01050 = "The MDM folder is required"
Public Const MTMSIX_ERROR_01051 = "The RunTime Configuration Dispenser RunQuery did not return a valid RCDLib.MTRcdFileList. StartFolder=[STARTFOLDER] ExtensionFolder=[EXTENSION] Query=[QUERY]"
Public Const MTMSIX_ERROR_01052 = "The RunTime Configuration Dispenser RunQuery did not return any files!  StartFolder=[STARTFOLDER] ExtensionFolder=[EXTENSION] Query=[QUERY]"""
Public Const MTMSIX_ERROR_01053 = "Enum type not defined, NameSpace=[NAMESPACE], EnumType=[ENUMTYPE]"
Public Const MTMSIX_ERROR_01054 = "Cannot find file [FILE] with the Runtime Configuration Dispenser object"
Public Const MTMSIX_ERROR_01055 = "Parent object is no longer valid for object [NAME]"
Public Const MTMSIX_ERROR_01056 = "Invalid value value=[VALUE]; for the enum type FQN=[FQN]; Name=[NAME]; PropertyName=[PROPERTYNAME];"
Public Const MTMSIX_ERROR_01057 = "Dictionary entry [ENTRY] not found"
Public Const MTMSIX_ERROR_01058 = "Decimal type mismatch for the property [PROPERTY]. value = '[VALUE]'"
Public Const MTMSIX_ERROR_01059 = "WARNING-Unknown language [LANGUAGE]"
Public Const MTMSIX_ERROR_01060 = "[ERRORTAG]Loading ASP Const File [FILE] [RESULT]"
Public Const MTMSIX_ERROR_01061 = "Template file [FILE] not found"
Public Const MTMSIX_ERROR_01062 = "INFO-E-mail Template Macro [NAME_VALUE]"
Public Const MTMSIX_ERROR_01063 = "Send E-mail failed."
Public Const MTMSIX_ERROR_01065 = "WARNING-SQLQUERY=[QUERY] Path=[PATH]"
Public Const MTMSIX_ERROR_01066 = "This operation is only supported by a MTSQLSimulator rowset object"
Public Const MTMSIX_ERROR_01067 = "MTXMLRowset.Execute failed"
Public Const MTMSIX_ERROR_01068 = "The MSIX property [PROPERTY] cannot be added. Check if it already exist. In the case of a product view check the file mdm\internal\AccountUsageProductView.msixdef"
Public Const MTMSIX_ERROR_01069 = "Syntax error parsing CSV list list=[LIST]"
Public Const MTMSIX_ERROR_01070 = "Syntax error reading xml file [FILE]"
Public Const MTMSIX_ERROR_01071 = "[Unicode to Big5 char conversion error]"
Public Const MTMSIX_ERROR_01072 = "Enum type entry [ENTRY] not found"
Public Const MTMSIX_ERROR_01073 = "Clearing the cache [NAME]"
Public Const MTMSIX_ERROR_01074 = "Reading Unicode to Big5 translation file : [FILE]"
Public Const MTMSIX_ERROR_01075 = "Enable to detect if the machine was the payment server. paymentserver name = [PAYMENTSERVERNAME]. ComputerName = [COMPUTER]"
Public Const MTMSIX_ERROR_01076 = "Detecting payment server machine . paymentserver name = [PAYMENTSERVERNAME]. ComputerName = [COMPUTERNAME]"
Public Const MTMSIX_ERROR_01077 = "FAILED TRANSACTION-MSIX Property type unknow Name=[PROPERTY_NAME] LongType=[PROPERTY_LONG_TYPE]"
Public Const MTMSIX_ERROR_01078 = "ItemByValue() method failed Value=[VALUE] EnumType.ToString=[TOSTRING]"
Public Const MTMSIX_ERROR_01079 = "Clearing the dictionary"
Public Const MTMSIX_ERROR_01080 = "This COM Error [ERROR] is not a COM MT Error."
Public Const MTMSIX_ERROR_01081 = "WARNING-MSIXProperty [NAME] is already existing in the service."
Public Const MTMSIX_ERROR_01082 = "WARNING-No enum value found for ID = [VALUE]."
Public Const MTMSIX_ERROR_01083 = "Grid [NAME] not found in Form.Grids collection. Template file=[FILE]"
Public Const MTMSIX_ERROR_01084 = "MDM Conditional Rendering #MDMEndIf not found."
Public Const MTMSIX_ERROR_01085 = "MDM Conditional Rendering #MDMIf syntax error."
Public Const MTMSIX_ERROR_01086 = "Filter property not defined."
Public Const MTMSIX_ERROR_01087 = "01087-Property [NAME] not found in Properties object [PROPERTIES_NAME]"
Public Const MTMSIX_ERROR_01088 = "[TAG] Name=[NAME] not found in the dictonary or the FQN database."
Public Const MTMSIX_ERROR_01089 = "FQN [FQN] not found, tag [TAG]."
Public Const MTMSIX_ERROR_01090 = "HTML template file name not defined"
Public Const MTMSIX_ERROR_01091 = "The SecurityContext object is not set in the Menu object. The menu cannot be rendered."
Public Const MTMSIX_ERROR_01092 = "Cannot create the capability instance '[CAPABILITY]'. Function call:GetCapabilityTypeByName().CreateInstance()"
Public Const MTMSIX_ERROR_01093 = "[TAG] Name=[NAME] Capaibiliies attribute not defined."
Public Const MTMSIX_ERROR_01094 = "The RunTime Configuration Dispenser RunQuery return more than 1 file! Query=[QUERY] Extension=[EXT]"
Public Const MTMSIX_ERROR_01095 = "MDMInclude CRLF end of line not found"
Public Const MTMSIX_ERROR_01096 = "MDMInclude syntax error"
Public Const MTMSIX_ERROR_01097 = "MDMInclude file name [FILENAME] not found"
Public Const MTMSIX_ERROR_01098 = "SettingEnumTypeDefaultValue service=[SERVICE] Property=[PROPERTY] Value=[VALUE]"
Public Const MTMSIX_ERROR_01099 = "Property [NAME] does not exist"
Public Const MTMSIX_ERROR_01100 = "01100-XMLDOM Parsing MSIX Failed Transaction error=[ERROR] line=[LINE] linepos=[LINEPOS] reason=[REASON] scrtext=[TEXT]"
Public Const MTMSIX_ERROR_01101 = "Cannot initialize service definition [SERVICEDEF]"
Public Const MTMSIX_ERROR_01102 = "Property [NAME] not found in service definition [SERVICE]"
Public Const MTMSIX_ERROR_01103 = "Cannot populate the MSIXHandler object from the COM Object '[OBJECTTYPE]'. Check the log file"
Public Const MTMSIX_ERROR_01104 = "']' expected"
Public Const MTMSIX_ERROR_01105 = "01105-Error parsing the MSIX Failed Transaction: Duplicate Session"
Public Const MTMSIX_ERROR_01106 = "The property '[NAME]' with a value of '[VALUE]' was truncated.  A length of [LENGTH] was expected."
Public Const MTMSIX_ERROR_01107 = "Index out of range for value in MTSQLRowsetSimulator.  Trying to access [INDEX] where size is [SIZE]."
Public Const MTMSIX_ERROR_01108 = "Index out of range for name in MTSQLRowsetSimulator.  Trying to access [INDEX] where size is [SIZE]."
Public Const MTMSIX_ERROR_01109 = "Property [NAME] has invalid value."

Public Const MTMSIX_WARNING_01200 = "No need to convert NULL Time."



' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
' MTMAM COM Object Errors
' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Public Const MTMAM_ERROR_01500 = "Loading folder menu [NAME] failed"
Public Const MTMAM_ERROR_01501 = "MAM Initialize() function failed!"
Public Const MTMAM_ERROR_01502 = "Loading dictionary folder [NAME] failed"
Public Const MTMAM_ERROR_01503 = "Initialize() [RESULT]"
Public Const MTMAM_ERROR_01504 = "Loading file [FILE] failed!"
Public Const MTMAM_ERROR_01505 = "VB Run Time Error occurred. "
Public Const MTMAM_ERROR_01506 = "WARNING-Find() - [ROWS] found."



' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
' MTPayementServerHelper COM Object
' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Public Const MTPaymentServerHelper_ERROR_02000 = "VB Run Time Error occured."
Public Const MTPaymentServerHelper_ERROR_02001 = "Query Execute error."

' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
' MTTabRulesetReader COM Object
' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Public Const MTTRReader_ERROR_02500 = "02500-The file '[META_FILE]' does not exist."
Public Const MTTRReader_ERROR_02501 = "02501-An error occurred while initializing the ruleset."
Public Const MTTRReader_ERROR_02502 = "02502-Propset error while reading the metafile '[META_FILE]'.  Propset err#[ERR_NUM] - err msg:[ERR_MSG]"
Public Const MTTRReader_ERROR_02503 = "02503-An error occurred while loading the enumerated types."
Public Const MTTRReader_ERROR_02504 = "02504-An error occurred while saving the file '[FILE_NAME]'.  err#[ERR_NUM] - err msg:[ERR_MSG]"
Public Const MTTRReader_ERROR_02505 = "02505-The object has not yet been initialized."
Public Const MTTRReader_ERROR_02506 = "02506-Error while reading the enumerated types and localization for: Language[[LANGUAGE]] - Enumspace[[ENUM_SPACE]] - EnumType[[ENUM_TYPE]].  err#[ERR_NUM] - err msg:[ERR_MSG]"
Public Const MTTRReader_ERROR_02507 = "02507-Propset error while reading the metadata from '[MTOBJ]'.  Propset err#[ERR_NUM] - err msg:[ERR_MSG]"


' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
' MTTAdminNavbar COM Object
' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Public Const MTAdminNavbar_ERROR_03000 = "03000-An error occurred while trying to create the menu from [[MENU_FILE]]."
Public Const MTAdminNavbar_ERROR_03001 = "03001-An error occurred while creating a menu item."
Public Const MTAdminNavbar_ERROR_03002 = "03002-An error occurred while creating a menu group."
Public Const MTAdminNavbar_ERROR_03003 = "03003-The xml file [[XML_FILE]] could not be parsed.  err#[ERR_NUM] - err msg: [ERR_MSG]."
Public Const MTAdminNavbar_ERROR_03004 = "03004-An error occurred while trying to create the menu from [[MENU_FILE]]."
Public Const MTAdminNavbar_ERROR_03005 = "03005-An error occurred while creating the list of dynamic web services for extension [EXTENSION_NAME]"
Public Const MTAdminNavbar_ERROR_03006 = "03006-An error occurred while creating the list of static web services for extension [EXTENSION_NAME]"
Public Const MTAdminNavbar_ERROR_03007 = "03007-An error occurred while creating the list of plugins for stage [STAGE_NAME]"
Public Const MTAdminNavbar_ERROR_03008 = "03008-An error occurred while creating the list of logging files"
Public Const MTAdminNavbar_ERROR_03009 = "03009-An error occurred while creating the list of payment server credit card logs"
Public Const MTAdminNavbar_ERROR_03010 = "03010-An error occurred while creating the list of dbaccess files"
Public Const MTAdminNavbar_ERROR_03011 = "03011-An error occurred while creating the list of ruleset metafiles for extension [EXTENSION_NAME]"
Public Const MTAdminNavbar_ERROR_03012 = "03012-An error occurred while creating the list of rule files for extension:[EXTENSION_NAME], stage:[STAGE_NAME], plugin:[PLUGIN_NAME], version:[VERSION_NAME]"
Public Const MTAdminNavbar_ERROR_03013 = "03013-An error occurred while branding menu for extension:[EXTENSION_NAME], language:[LANGUAGE]"
Public Const MTAdminNavbar_ERROR_03014 = "03014-The template file [FILE_NAME] does not exist."
Public Const MTAdminNavbar_ERROR_03015 = "03015-An error occurred while reading the template file [FILE_NAME].  err#[ERR_NUM] - err msg: [ERR_MSG]"
Public Const MTAdminNavbar_ERROR_03016 = "03016-The xml file [FILE_NAME] does not exist."
Public Const MTAdminNavbar_ERROR_03017 = "03017-An error occurred while loading the xml file [FILE_NAME].  err#[ERR_NUM] - err msg: [ERR_MSG]"
Public Const MTAdminNavbar_ERROR_03018 = "03018-An error occurred while parsing the xml file [FILE_NAME].  parse err : [ERR_MSG]"
Public Const MTAdminNavbar_ERROR_03019 = "03019-An error occurred while reading the xml file [FILE_NAME].  err#[ERR_NUM] - err msg: [ERR_MSG]"
Public Const MTAdminNavbar_ERROR_03020 = "03020-An error occurred while creating the list of payment server ACH logs"




' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
' MTVBLib -
' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Public Const MTVBLIB_ERROR_03500 = "03500-MTVBLIB-COM/XML mismatch [FILE]"
Public Const MTVBLIB_ERROR_03501 = "03501-MTVBLIB-Failed reading xml file [FILE]"
Public Const MTVBLIB_ERROR_03502 = "03502-MTVBLIB-File [FILE] not found"
Public Const MTVBLIB_ERROR_03503 = "03503-MTVBLIB-XML Parsing error File [FILE]"
Public Const MTVBLIB_ERROR_03504 = "03504-MTVBLIB-XMLDOM Parsing filename=[FILENAME] error=[ERROR] filepos=[FILEPOS] line=[LINE] linepos=[LINEPOS] reason=[REASON] scrtext=[TEXT]"
Public Const MTVBLIB_ERROR_03505 = "03505-MTVBLIB-Function Process() found a non closed bracket in the string '[STRING]'"
Public Const MTVBLIB_ERROR_03506 = "03506-MTVBLIB-Warning-Variable [NAME] not found in the variables collection."
Public Const MTVBLIB_ERROR_03507 = "03507-MTVBLIB-Error loading xml file [FILE]"
Public Const MTVBLIB_ERROR_03508 = "03508-MTVBLIB-Error parsing xml for saving in file [FILE]"
Public Const MTVBLIB_ERROR_03509 = "03509-MTVBLIB-Saveing the xml file '[FILE]' failed"





' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
' MDM UpGrader Application
' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Public Const MUM_ERROR_04500 = "VB Run Time Error occurred. "
Public Const MUM_ERROR_04501 = "[ERRORSCOUNTER] error(s) found."
Public Const MUM_ERROR_04502 = "Did you have made a back up of MAM and MOM 1.3.1 ?"
Public Const MUM_ERROR_04503 = "Process canceled"


' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
' View all rates
' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Public Const MTVIEWALLRATES_ERROR_05000 = "VB Run Time Error occured.  "


' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
' Account Hierarchy Helper
' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Public Const MTACCOUNTHIERARCHYHERLPER_ERROR_06000 = "Cannot find property [NAME] in Account Template properties collection"



























































 
Public Const MT_ERR_SYN_TIMEOUT = &HE1300025
Public Const MT_ERR_SERVER_BUSY = &HE1300026










' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
' Logging functions
' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Public g_booLogWithoutCOMLogger As Boolean  ' Default value is false, which was the default value
Public g_strLogWithoutCOMLoggerFileName As String  ' Default value is false, which was the default value

' Private m_objMTLogger   As Object ' C++ Logger object. This objects is allocated only once for the all life of the application.

Public Enum eMTGLOBAL_LOG_TRACE_MODE ' MetraTech Logger Mode

    LOG_APPLICATION_ERROR = 256 ' This is not a real MTLogger Value but an internal value, when an application
                                ' want to log an application error, this enum type item will log a warning...
    LOG_TRACE = 6
    LOG_DEBUG = 5
    LOG_INFO = 4
    LOG_WARNING = 3
    LOG_ERROR = 2
    LOG_FATAL = 1
    LOG_OFF = 0
End Enum
   

' -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :   LogMessage
' PARAMETERS    :
'                   strText            - The message
'                   enmLogLevel        - MT Logging mode, see enum type eMTGLOBAL_LOG_TRACE_MODE
' DESCRIPTION   :   Log the message strText
' RETURN        :   TRUE.
Public Sub LogMessage(Optional strText As String, Optional enmLogLevel As eMTGLOBAL_LOG_TRACE_MODE = LOG_DEBUG)

    Logger strText, enmLogLevel
End Sub

' -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :   LogError
' PARAMETERS    :
'                   strText            - Additional text to the error
'                   strModuleName      - The name of the module/class/form where the error occured.
'                   strFunctionName    - The name of the function/sub/property where the error occured.
'                   enmLogLevel        - MT Logging mode, see enum type eMTGLOBAL_LOG_TRACE_MODE
' DESCRIPTION   :   Log the message strText.
' RETURN        :   TRUE.
Public Sub LogError(Optional ByVal strText As String, Optional ByVal strModuleName As String, Optional ByVal strFunctionName As String, Optional ByVal enmLogLevel As eMTGLOBAL_LOG_TRACE_MODE = LOG_ERROR)
        
    Dim strVBErrorString As String
    
    If (Err.Number) Then
    
        strVBErrorString = GetVBErrorString() ' Let us save the VB error we must log
        TRACE strVBErrorString & strText, strModuleName, strFunctionName, enmLogLevel
    Else
        TRACE strText, strModuleName, strFunctionName, enmLogLevel
    End If
End Sub

' -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :   GetVBErrorString
' PARAMETERS    :
' DESCRIPTION   :   Return the current VB Run Time Error in a following way error=13 description=Type mismatch source=MTVbLib.CTextFile
' RETURN        :
Public Function GetVBErrorString() As String

    GetVBErrorString = "error=" & CStr(Err.Number) & " description=" & Err.Description & " source=" & Err.Source
End Function

' -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : TRACE
' PARAMETERS    :
'                   strText            - The message
'                   strModuleName      - The name of the module/class/form
'                   strFunctionName    - The name of the function/sub/property
'                   enmLogLevel        - MT Logging mode, see enum type eMTGLOBAL_LOG_TRACE_MODE
' DESCRIPTION   :   Log the message strText
' RETURN        :   TRUE.
Public Function TRACE(ByVal strText As String, Optional ByVal Module As Variant, Optional ByVal strFunctionName As String, Optional ByVal enmLogLevel As eMTGLOBAL_LOG_TRACE_MODE = LOG_DEBUG) As Boolean

    Dim strModuleTrace      As String
    Dim strFunctionTrace    As String
    Dim strAppInfo          As String
    
    If IsMissing(Module) Then Module = ""
    If IsObject(Module) Then Module = TypeName(Module)
    
    If (Len(Module)) Then Module = "Module=" & Module & ";"
    If (Len(strFunctionName)) Then strFunctionTrace = "Function=" & strFunctionName & ";"
      
    TRACE = Logger(strModuleTrace & IIf(Len(strModuleTrace), " ", "") & strFunctionTrace & IIf(Len(strFunctionTrace), " ", "") & strText & " ", enmLogLevel)
End Function

' -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Logger
' PARAMETERS    :
'                   strText            - The error message.
'                   enmLogLevel        - MT Logging mode, see enum type eMTGLOBAL_LOG_TRACE_MODE
' DESCRIPTION   :   Log the message strText
' RETURN        :   TRUE.
Private Function Logger(ByVal strText As String, Optional ByVal enmLogLevel As eMTGLOBAL_LOG_TRACE_MODE = LOG_DEBUG) As Boolean
  
    Dim objMTVBLibInfo                  As Object
    
    If (g_booLogWithoutCOMLogger) Then
    
        Set objMTVBLibInfo = CreateObject("MTVBLIB.MTVbLibInfo") ' We need to do a late binding becaused there is app that use this module but does not use mtvblib.
        Logger = LoggerWithoutCOMLogger(objMTVBLibInfo.LogFileName(), strText, enmLogLevel)
    Else
        Logger = LoggerWithCOMLogger(strText, enmLogLevel)
    End If
End Function

Private Function LoggerWithCOMLogger(ByVal strText As String, Optional ByVal enmLogLevel As eMTGLOBAL_LOG_TRACE_MODE = LOG_DEBUG) As Boolean
  
    Dim m_objMTLogger    As Object
    
    If (enmLogLevel = LOG_APPLICATION_ERROR) Then
        enmLogLevel = LOG_WARNING
        strText = "[APPLICATION_ERROR]" & strText
    End If
    
    'If (m_objMTLogger Is Nothing) Then ' Alloc the logger object is necessary
    
        Set m_objMTLogger = CreateObject("MTLogger.MTLogger.1")
        m_objMTLogger.Init MTDEFAULTtLOGFileName(), "[" & App.EXEName & ".Dll]" ' DUMMY_NAME mean that since DUMMY_NAME.XML does not exist we log into the default log file MTLOG.TXT
    'End If
    'strText = Replace(strText, vbCrLf, "")
    m_objMTLogger.LogThis CLng(enmLogLevel), strText
    LoggerWithCOMLogger = True
    Exit Function
ErrMgr:
    
End Function

Public Function LoggerWithoutCOMLogger(strFileName As String, ByVal strText As String, Optional ByVal enmLogLevel As eMTGLOBAL_LOG_TRACE_MODE = LOG_DEBUG) As Boolean

    Dim objMTVBLibInfo                  As Object
    Dim objTextFile                     As Object
    Dim MTGLOBAL_LOG_TRACE_MODE_STRING  As Variant
    
    Set objMTVBLibInfo = CreateObject("MTVBLIB.MTVbLibInfo") ' We need to do a late binding becaused there is app that use this module but does not use mtvblib.
    Set objTextFile = CreateObject("MTVBLIB.CTextFile")
    
    MTGLOBAL_LOG_TRACE_MODE_STRING = Array("OFF", "FATAL", "ERROR", "WARNING", "INFO", "DEBUG", "TRACE")
    
    ' Must be now because we always log local time
    objTextFile.LogFile strFileName, Now() & " [" & MTGLOBAL_LOG_TRACE_MODE_STRING(enmLogLevel) & "] " & strText, False
    LoggerWithoutCOMLogger = True
End Function

' -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :   RaiseError
' PARAMETERS    :
'                   strMTMDMErrorMessage            - The message. Can be formated with the 5 first digits containing the error number.
'                   strSource                       - Source error.
'                   lngDefaultErrorNumber           - Error number to raise if the error is not defined in the message.
'                   enmLogLevel                     - MT Logging mode, see enum type eMTGLOBAL_LOG_TRACE_MODE
' DESCRIPTION   :   Raise an error.  DWOOD - Changed to accept a logging level (default is ERROR).
'                                       Added this because sometimes you want the COM object to raise
'                                       an error but you do not want to log the message at ERROR level
'                                       in the log.  Remember that support gets PAGED for every ERROR
'                                       message in the log file!!
'
'                                       remark : lngDefaultErrorNumber default value used to be -1 but now that we have the flag USER_ERROR_MASK, the value must be positive...
'
' RETURN        :   TRUE.
Public Function RaiseError(ByVal strMTMDMErrorMessage As String, Optional ByVal strSource As String, Optional lngDefaultErrorNumber As Long = 1, Optional ByVal enmLogLevel As eMTGLOBAL_LOG_TRACE_MODE = LOG_ERROR) As Boolean
    
    Dim lngErrorNumber                  As Long
    Dim booErrorNumberIncluded          As Boolean
    
    TRACE strMTMDMErrorMessage, , , enmLogLevel ' Log the error first
    
    If (Len(strSource) = 0) Then strSource = App.EXEName ' Use the App object info to populate the name if not defined
        
    If (IsNumeric(Mid$(strMTMDMErrorMessage, 1, 5))) Then  ' Get the error number to raise from the message or from the parameter
    
        lngErrorNumber = CLng(Mid$(strMTMDMErrorMessage, 1, 5)) + vbObjectError
        booErrorNumberIncluded = True
    Else
        lngErrorNumber = lngDefaultErrorNumber
    End If
        
    ' If the error number is defined in the message we exclude the error number from the string before we raise
    Err.Raise lngErrorNumber, strSource, Mid$(strMTMDMErrorMessage, IIf(booErrorNumberIncluded, 6, 1)) ' let us raise

End Function

Public Function PreProcess(ByVal strMessage As String, ParamArray defines() As Variant) As String
    Dim i As Long
    
    For i = 0 To UBound(defines()) Step 2
    
        strMessage = Replace(strMessage, "[" & defines(i) & "]", CStr(defines(i + 1)))
    Next
    PreProcess = strMessage
End Function


Public Function ShowError(ByVal strErrorMessage As String, Optional strModule As Variant, Optional strFunction As String) As Boolean

    If IsMissing(strModule) Then strModule = ""
    If IsObject(strModule) Then strModule = TypeName(strModule)

    If (Len(strModule)) Then strErrorMessage = strErrorMessage & vbNewLine & "Module=" & strModule
    If (Len(strFunction)) Then strErrorMessage = strErrorMessage & vbNewLine & "Function=" & strFunction
    
    
    ' This was added to support auto-close message box for the test harness.
    ' This code is intended to run in the test harness
    ' fred 2004-12-9
    #If SHOWERROR_UNATTENDED Then
    
        frmMsgbox.OpenDialog strErrorMessage, App.EXEName
        Dim f As New cTextFile
        f.LogFile Environ("METRATECHTESTDATABASE") & "\TestHarness.Error.log", strErrorMessage
    #Else
        MsgBox Now() & " " & strErrorMessage, vbCritical + vbOKOnly
    #End If
    
    ShowError = True
End Function

Public Function IsUserVisibleMTCOMError(lngNumber As Long) As Boolean
    IsUserVisibleMTCOMError = (lngNumber And USER_ERROR_MASK) = USER_ERROR_MASK
End Function

Public Function MakeItUserVisibleMTCOMError(lngNumber As Long) As Long
    If Not IsUserVisibleMTCOMError(lngNumber) Then
        MakeItUserVisibleMTCOMError = USER_ERROR_MASK + lngNumber
    Else
        MakeItUserVisibleMTCOMError = lngNumber
    End If
End Function

Public Function UnMakeItUserVisibleMTCOMError(lngNumber As Long) As Long
    If IsUserVisibleMTCOMError(lngNumber) Then
        UnMakeItUserVisibleMTCOMError = lngNumber - USER_ERROR_MASK
    Else
        UnMakeItUserVisibleMTCOMError = lngNumber
    End If
End Function

Public Function MTNow() As Variant
    Dim objMetraTimeClient
    
    On Error GoTo ErrMgr
    Set objMetraTimeClient = CreateObject("MetraTech.MetraTimeClient")
    MTNow = objMetraTimeClient.GetMTOleTime()
    Exit Function
ErrMgr:
    TRACE GetVBErrorString(), "MTGlobal_VB_MSG.bas", "MTNow", LOG_ERROR
End Function

Public Property Get MTDEFAULTtLOGFileName() As String
    If Len(m_strMTDEFAULTtLOGFileName) Then
        MTDEFAULTtLOGFileName = m_strMTDEFAULTtLOGFileName
    Else
        MTDEFAULTtLOGFileName = MTDEFAULTDEFAULTtLOGFileName
    End If
End Property

Public Property Let MTDEFAULTtLOGFileName(ByVal vNewValue As String)
    m_strMTDEFAULTtLOGFileName = vNewValue
End Property

Public Function MTInitializeLogFileForPCImportExport() As Boolean
    MTGlobal_VB_MSG.MTDEFAULTtLOGFileName = "logging\PCImportExport"
    MTInitializeLogFileForPCImportExport = True
End Function

Public Function TRACERowset(r As Variant, strMessage) As Boolean
    Dim lngLine As Long
    Dim i       As Long
    Dim s       As String
    
    On Error GoTo ErrMgr
    
    MTGlobal_VB_MSG.TRACE "TRACERowset{" & strMessage
    r.MoveFirst
    
    For i = 0 To r.Count - 1
        s = s & r.Name(CLng(i)) & ";"
    Next
    MTGlobal_VB_MSG.TRACE "Header=" & s
    
    Do While Not r.EOF
        lngLine = lngLine + 1
        s = Format(lngLine, "00000") & " "
        For i = 0 To r.Count - 1
            s = s & r.Value(CLng(i)) & ";"
        Next
        MTGlobal_VB_MSG.TRACE s
        r.MoveNext
    Loop
    r.MoveFirst
    MTGlobal_VB_MSG.TRACE "TRACERowset}"
    TRACERowset = True
    Exit Function
ErrMgr:
'    'Debug.Assert 0
End Function



Public Function GetTestDatabaseTempFolder() As String
    Dim strFolder As String
    strFolder = Environ("METRATECHTESTDATABASETEMP")
    
    If (Len(strFolder)) Then
        GetTestDatabaseTempFolder = strFolder
    Else
        GetTestDatabaseTempFolder = Environ("METRATECHTESTDATABASE") & "\Temp"
    End If
End Function
