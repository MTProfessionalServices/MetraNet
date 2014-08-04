  <%
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
'  Copyright 1998,2000 by MetraTech Corporation
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
'  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
' NAME		        : MetraTech Dialog Manager - VBScript Contants
' VERSION	        : 1.0
' CREATION_DATE   : 08/xx/2000
' AUTHOR	        : F.Torres.
' DESCRIPTION	    : Implement all the MDM Error messages, MTMSIX Visual Basic Enum Type and PUBLIC CONSTants.
'
' ----------------------------------------------------------------------------------------------------------------------------------------

' MDM Version
PUBLIC CONST MDM_VERSION = "4.2"

PUBLIC CONST ROLE_PROGID = "MTAuthProto.MTRole"
PUBLIC CONST SECURITY_POLICY_PROGID = "MTAuthProto.MTSecurityPolicy"
PUBLIC CONST SECURITY_CONTEXT_PROGID = "MTAuthProto.MTSecurityContext"

PRIVATE CONST LOGIN_LIB_LOGIN     = "SESSION:LOGIN_LIB_LOGIN"
PRIVATE CONST LOGIN_LIB_NAMESPACE = "SESSION:LOGIN_LIB_NAMESPACE"
PRIVATE CONST LOGIN_LIB_ACCOUNTID = "SESSION:LOGIN_LIB_ACCOUNTID"
PRIVATE CONST MDM_METERING_SERVICE_TIME_OUT = "SESSION:MDM_METERING_SERVICE_TIME_OUT"

' MDM Error messages - This error are localized in \ui\mdm\dictionary\localized\en-us\dictionary\mdm
' The XML file must be copied in the localiZed dictionary of each web app - 
' These hard coded english value are the default value is case there is nothing in the dictionary
' MDM 3.0 - fred - may 23 2002 - 
PUBLIC CONST MDM_ERROR_1000    =   "1000-MDM/ASP-WARNING-Event [EVENT], dialog [NAME] is not implemented."
PUBLIC CONST MDM_ERROR_1001    =   "1001-MDM/ASP-Service COM Instance not found. Internal Error. Consult the MTLog.txt file."
PUBLIC CONST MDM_ERROR_1002    =   "1002-MDM/ASP-WARNING-Dictionary instance not found in Session()"
PUBLIC CONST MDM_ERROR_1003    =   "1002-MDM/ASP-WARNING-Dictionary instance found in Session()"
PUBLIC CONST MDM_ERROR_1004    =   "1004-MDM/ASP-WARNING-Free from session object [NAME]"
PUBLIC CONST MDM_ERROR_1005    =   "1005-MDM/ASP-WARNING-Store in session object [NAME]"
PUBLIC CONST MDM_ERROR_1006    =   "1006-MDM/ASP-MDM Session Variable [NAME] not found"
PUBLIC CONST MDM_ERROR_1007    =   "1007-MDM/ASP-MTService.Service.Initialize() function failed"
PUBLIC CONST MDM_ERROR_1008    =   "1008-MDM/ASP-Default Form_Refresh() event was called. Form_Refresh() event is not implemented in the dialog!"
PUBLIC CONST MDM_ERROR_1009    =   "1009-MDM/ASP-Object Session Variable [NAME] not in session"
PUBLIC CONST MDM_ERROR_1010    =   "1010-MDM/ASP-WARNING-MDM Garbage collector executed"
PUBLIC CONST MDM_ERROR_1011    =   "1011-MDM/ASP-WARNING-MDM Garbage collector clear [NAME]"
PUBLIC CONST MDM_ERROR_1012    =   "1012-MDM/ASP-WARNING-MDM Clear Cache executed"
PUBLIC CONST MDM_ERROR_1013    =   "1013-MDM/ASP-"
PUBLIC CONST MDM_ERROR_1014    =   "1014-MDM/ASP-Event Form_LoadProductView() must be implemented"
PUBLIC CONST MDM_ERROR_1015    =   "1015-MDM/ASP-WARNING-Event [EVENT] failed!"
PUBLIC CONST MDM_ERROR_1016    =   "1016-MDM/ASP-Dialog Service not found in memory! Event=[EVENT]. (Do not use the back button)"
PUBLIC CONST MDM_ERROR_1017    =   "1017-MDM/ASP-Rowset type not supported columns [COLUMN]"
PUBLIC CONST MDM_ERROR_1018    =   "1018-MDM/ASP-Cache object not found in session"
PUBLIC CONST MDM_ERROR_1019    =   "1019-MDM/ASP-IIS Session Time Out"
PUBLIC CONST MDM_ERROR_1020    =   "1020-MDM/ASP-Rowset.Sort(""[PROPERTY]"") raised an error. Please look at the MTLog.txt file."
PUBLIC CONST MDM_ERROR_1021    =   "1021-MDM/ASP-MDM caugth an COM Error Event=[EVENT_NAME]; Number=[ERR_NUMBER]; Description=[ERR_DESCRIPTION]; Localization=[ERR_LOCALIZATION]"
PUBLIC CONST MDM_ERROR_1022    =   "1022-MDM/ASP-Method Service.RenderHTML() failed"
PUBLIC CONST MDM_ERROR_1023    =   "1023-MDM/ASP-Type mismatch on a filter*"
PUBLIC CONST MDM_ERROR_1024    =   "1024-MDM/ASP-The filter data is not correct.  Please Reset the filter."
PUBLIC CONST MDM_ERROR_1025    =   "1025-MDM/ASP-Cannot find dialog [FILENAME] in session"
PUBLIC CONST MDM_ERROR_1026    =   "1026-MDM/ASP-Cannot Display array property"
PUBLIC CONST MDM_ERROR_1027    =   "'[DATE]' is not a valid date"
PUBLIC CONST MDM_ERROR_1028    =   "filter value starting with a * is not supported on this release"



' MTService.XService Render Flags
PUBLIC CONST eMSIX_RENDER_FLAG_RENDER_FROM_SERVICE      = 1
PUBLIC CONST eMSIX_RENDER_FLAG_RENDER_FROM_PRODUCTVIEW  = 2
PUBLIC CONST eMSIX_RENDER_FLAG_LOCALIZE_ENUM_TYPE       = 4
PUBLIC CONST eMSIX_RENDER_FLAG_RENDER_INPUT_TAG         = 8
PUBLIC CONST eMSIX_RENDER_FLAG_RENDER_SELECT_TAG        = 16
PUBLIC CONST eMSIX_RENDER_FLAG_RENDER_TEXTAREA_TAG      = 32
PUBLIC CONST eMSIX_RENDER_FLAG_RENDER_FORM_TAG          = 64
PUBLIC CONST eMSIX_RENDER_FLAG_RENDER_IMG_TAG           = 128
PUBLIC CONST eMSIX_RENDER_FLAG_RENDER_LINK_TAG          = 256
PUBLIC CONST eMSIX_RENDER_FLAG_RENDER_LABEL_TAG         = 512
PUBLIC CONST eMSIX_RENDER_FLAG_RENDER_INSERT_JAVASCRIPT = 1024
PUBLIC CONST eMSIX_RENDER_FLAG_RENDER_GRID              = 2048 ' MDM V2
PUBLIC CONST eMSIX_RENDER_FLAG_RENDER_TABS              = 4096 ' MDM V2
PUBLIC CONST eMSIX_RENDER_FLAG_RENDER_SERVICE_PROPERTY_WITH_BRACKET = 8192 ' MDM V2 - Not by default in MDM V2
PUBLIC CONST eMSIX_RENDER_FLAG_RENDER_WIDGETS           = 16384
    
DIM   eMSIX_RENDER_FLAG_DEFAULT_VALUE   ' This one is a variable because in VBScript you cannot define a PUBLIC CONST that use others PUBLIC CONST!
DIM   eMSIX_RENDER_FLAG_DEFAULT_VALUE_VERSION_2_0 

PUBLIC CONST eMSIX_PROPERTIES_FLAG_SERVICE                     = 1
PUBLIC CONST eMSIX_PROPERTIES_FLAG_PRODUCTVIEW                 = 2
PUBLIC CONST eMSIX_PROPERTIES_FLAG_COM_OBJECT                  = 4 ' MDM V2


' Function MSIXProperties.Load()
PUBLIC CONST eMSIX_PROPERTIES_LOAD_FLAG_LOAD_PRODUCT_VIEW      = 1
PUBLIC CONST eMSIX_PROPERTIES_LOAD_FLAG_LOAD_SQL_SELECT        = 2
PUBLIC CONST eMSIX_PROPERTIES_LOAD_FLAG_INIT_FROM_ROWSET       = 4
PUBLIC CONST eMSIX_PROPERTIES_LOAD_FLAG_REMOTE_MODE            = 8

' MSIXProperty Flag. MSIXProperties.Add()
PUBLIC CONST eMSIX_PROPERTY_FLAG_NONE                  = 0
PUBLIC CONST eMSIX_PROPERTY_FLAG_METERED               = 1 ' The Property will be metered, this is the default value
PUBLIC CONST eMSIX_PROPERTY_FLAG_ACCOUNT_USAGE_TABLE   = 2 ' This mean that the property comes from table t_acc_usage for a product view
PUBLIC CONST eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET  = 4 ' Not Documented
PUBLIC CONST eMSIX_PROPERTY_FLAG_STRING_ID             = 8 ' Related to MDM, if this flag is set the following chars only will be allowed to be entered : _ ABCDEFGHIJKLMNOPQRSTVWUXYZabcdefghijklmnopqrstvwuxyz
PUBLIC CONST eMSIX_PROPERTY_FLAG_DO_NOT_STORE_CAPTION_IN_CACHE = 16  ' Do not Store the caption in the cache. Default mode store in cache. Added in MDM v2.
PUBLIC CONST eMSIX_PROPERTY_FLAG_COM_OBJECT_PROPERTY   = 32 ' Support of COM Object implementing a MTProperties Collection ' MDM V2
PUBLIC CONST eMSIX_PROPERTY_FLAG_SKIP_NEXT_METERING = 64  ' MDM 3.0 - Allow to not meter some property in the next metering without to have to alter the value
PUBLIC CONST eMSIX_PROPERTY_FLAG_LOADED_FROM_MSIXDEF = 128           ' MDM 3.0 Loaded from a service definition or product view definition

   
' MSIXProperty Event Flag - Not used in v1.0
PUBLIC CONST eMSIX_PROPERTY_EVENT_FLAG_NONE            = 0
PUBLIC CONST eMSIX_PROPERTY_EVENT_FLAG_CLICK_EVENT     = 1

' MSIXEnumType Flags
PUBLIC CONST eMSIX_ENUM_TYPE_FLAG_NONE                                  = 0  ' None, default value.
PUBLIC CONST eMSIX_ENUM_TYPE_FLAG_USE_NAME_IN_HTML_OPTIONS_TAG_AS_INDEX = 1  ' The function GetHTMLOptionTags() return the HTML OPTIONS tag for a comboxbox based on the enum type. By default the value used for the index is the enum type item first value, by setting this flag the  value used for the index will be the enum type item name . The default value is not set.


' MSIXProperties Flags - eMSIX_PROPERTIES_LOCALIZATION_FLAG - MDM V2
PUBLIC CONST eMSIX_PROPERTIES_LOCALIZATION_FLAG_LOCALIZE_DATE_WITH_TIME_ZONE_ID = 1
PUBLIC CONST eMSIX_PROPERTIES_LOCALIZATION_FLAG_RETURN_BIG5                     = 2
PUBLIC CONST eMSIX_PROPERTIES_LOCALIZATION_FLAG_RETURN_UNICODE                  = 4
DIM          eMSIX_PROPERTIES_LOCALIZATION_FLAG_DEFAULT_VALUE


' MT Logger PUBLIC CONSTants
PUBLIC CONST eLOG_TRACE    = 6
PUBLIC CONST eLOG_DEBUG    = 5
PUBLIC CONST eLOG_INFO     = 4
PUBLIC CONST eLOG_WARNING  = 3
PUBLIC CONST eLOG_ERROR    = 2
PUBLIC CONST eLOG_FATAL    = 1
PUBLIC CONST eLOG_OFF      = 0

' MDM Dialog Type - MDM V2
PUBLIC CONST MDM_STANDARD_DIALOG_TYPE   =1
PUBLIC CONST MDM_PVB_DIALOG_TYPE        =2

' Object And Variables Stored In Session
PUBLIC CONST mdm_EVENT_ARG_ERROR        = "MDM.EVENT_ARG_ERROR"
PUBLIC CONST mdm_CACHE_SESSION_NAME     = "MDM.CACHE"
PUBLIC CONST mdm_DIALOG_SESSION_NAME    = "MDM.DLG:"            ' This is just the prefix of the name
PUBLIC CONST mdm_FORM_SESSION_NAME      = "MDM.FORM:"           ' This is just the prefix of the name
PUBLIC CONST mdm_SESSION_ID             = "MDM_SESSION_ID"

PUBLIC CONST mdm_APP_LANGUAGE           = "mdm_APP_LANGUAGE" ' For these 3 ones the name and the value must be the same...
PUBLIC CONST mdm_APP_FOLDER             = "mdm_APP_FOLDER"
PUBLIC CONST mdm_LOCALIZATION_DICTIONARY= "mdm_LOCALIZATION_DICTIONARY"

' MTSQLROWSET Sort PUBLIC CONSTants
PUBLIC CONST MTSORT_ORDER_NONE       = 0 
PUBLIC CONST MTSORT_ORDER_ASCENDING  = 1
PUBLIC CONST MTSORT_ORDER_DECENDING  = 2 
PUBLIC CONST MTSORT_ORDER_DESCENDING = 2

' Product View Browser PUBLIC CONSTants
PUBLIC CONST MDM_PRODUCT_VIEW_HTML_TOOL_BAR_HTML_FILE_NAME           =   "\internal\ProductViewBrowserToolBar.htm"
PUBLIC CONST MDM_PRODUCT_VIEW_HTML_TOOL_BAR_HTML_FILE_NAME_NO_DATA   =   "\internal\ProductViewBrowserToolBar.NoData.htm"

PUBLIC MDM_PRODUCT_VIEW_TOOL_BAR_TURN_DOWN_TOOL_TIP  : MDM_PRODUCT_VIEW_TOOL_BAR_TURN_DOWN_TOOL_TIP      =   ""

PUBLIC MDM_PRODUCT_VIEW_TOOL_BAR_TURN_DOWN_HTTP_FILE_NAME  : MDM_PRODUCT_VIEW_TOOL_BAR_TURN_DOWN_HTTP_FILE_NAME      =   "/mdm/internal/images/toolbar/arrowBlueDown.gif"
PUBLIC MDM_PRODUCT_VIEW_TOOL_BAR_TURN_RIGHT_HTTP_FILE_NAME : MDM_PRODUCT_VIEW_TOOL_BAR_TURN_RIGHT_HTTP_FILE_NAME     =   "/mdm/internal/images/toolbar/arrowBlueRight.gif"

PUBLIC CONST MDM_PRODUCT_VIEW_TOOL_BAR_SORT_ASC_HTTP_FILE_NAME       =   "/mdm/internal/images/toolbar/arrowSortUp.gif"
PUBLIC CONST MDM_PRODUCT_VIEW_TOOL_BAR_SORT_DEC_HTTP_FILE_NAME       =   "/mdm/internal/images/toolbar/arrowSortDown.gif"

' Old name here for compatibility
PUBLIC CONST   CACHE_PROD_ID                 =   "MTMSIX.MSIXCache"
PUBLIC CONST   MSIXHandler_PROG_ID           =   "MTMSIX.MSIXHandler"
PUBLIC CONST   DICTIONARY_PROG_ID            =   "MTMSIX.Dictionary"
PUBLIC CONST   MTSQLROWSETSIMULATOR_PROG_ID  =   "MTMSIX.MTSQLRowsetSimulator"
PUBLIC CONST   MSIXTOOLS_PROG_ID             =   "MTMSIX.MSIXTools"

' New MDM/MTMSIX VB COM Object name
PUBLIC CONST   MSIXHandler                   =   "MTMSIX.MSIXHandler"
PUBLIC CONST   MSIXTools                     =   "MTMSIX.MSIXTools"  
PUBLIC CONST   MSIXCache                     =   "MTMSIX.MSIXCache"
PUBLIC CONST   MSIXDictionary                =   "MTMSIX.Dictionary"
PUBLIC CONST   MDMForm                       =   "MTMSIX.MDMForm"
PUBLIC CONST   MSIXFailedTransaction 	       =   "MTMSIX.MSIXFailedTransaction"
PUBLIC CONST   MSIXFailedTransactions 	     =   "MTMSIX.MSIXFailedTransactions"
PUBLIC CONST   MSIXEnumTypeEntry             =   "MTMSIX.MSIXEnumTypeEntry"
PUBLIC CONST   MSIXEnumTypeEntries           =   "MTMSIX.MSIXEnumTypeEntries"

' MDM Internal Action - Used for different purpose - DO NOT CHANGE THESES CONST BECAUSE THEY ARE HARD CODE IN SOME HTML TEMPLATE INCLUDING THE TOOLBAR TEMPLATE
PUBLIC CONST MDM_ACTION_DEFAULT        =   ""
PUBLIC CONST MDM_ACTION_ADD            =   "ADD"
PUBLIC CONST MDM_ACTION_DELETE         =   "DELETE"
PUBLIC CONST MDM_ACTION_REFRESH        =   "REFRESH" ' Redraw but reinit the data
PUBLIC CONST MDM_ACTION_REDRAW         =   "REDRAW"
PUBLIC CONST MDM_ACTION_REVERSESORT    =   "REVERSESORT"
PUBLIC CONST MDM_ACTION_OPEN_PV        =   "OPENPRODUCTVIEW"  
PUBLIC CONST MDM_ACTION_FIRSTPAGE      =   "FIRSTPAGE"
PUBLIC CONST MDM_ACTION_LASTPAGE       =   "LASTPAGE"
PUBLIC CONST MDM_ACTION_NEXTPAGE       =   "NEXTPAGE"
PUBLIC CONST MDM_ACTION_PREVIOUSPAGE   =   "PREVIOUSPAGE"
PUBLIC CONST MDM_ACTION_GOTOPAGE       =   "GOTOPAGE"
PUBLIC CONST MDM_ACTION_SORT           =   "SORT"
PUBLIC CONST MDM_ACTION_TURN_RIGHT     =   "TURNRIGHT"
PUBLIC CONST MDM_ACTION_TURN_DOWN      =   "TURNDOWN"
PUBLIC CONST MDM_ACTION_ENTER_KEY      =   "ENTERKEY"
PUBLIC CONST MDM_ACTION_ESCAPE_KEY     =   "ESCAPEKEY"    
PUBLIC CONST MDM_ACTION_PVB_FILTER_BUTTON_GO  =   "MDMPVBFILTERBUTTONGO"
PUBLIC CONST MDM_ACTION_PVB_FILTER_BUTTON_RESET  =   "MDMPVBFILTERBUTTONRESET"
PUBLIC CONST MDM_ACTION_PVB_FILTER_RESET			= "#MDMRESETFILTER"
PUBLIC CONST MDM_ACTION_EXPORT        = "EXPORT"
PUBLIC CONST MDM_ACTION_REFRESH_FROM_CLICK_FROM_OBJECT = "REFRESHFROMCLICKONOBJECT" ' Redraw but reinit the data


'PUBLIC CONST TEXT_USAGEPERIOD_THROUGH       = "through"
'PUBLIC CONST TEXT_USAGEPERIOD_THROUGHTODAY  = "through Today"
'PUBLIC CONST TEXT_INVOICE_NUMBER		        = "#invoice"

' These english consts are still used as the default value is nothing is defined in the dictionary
PUBLIC CONST MDM_PVB_INTERVAL_ID_COMBOX_BOX_FORMAT_CURRENT_MONTH              = "[START_DATE] Through today"
PUBLIC CONST MDM_PVB_INTERVAL_ID_COMBOX_BOX_FORMAT_PREVIOUS_NON_CLOSED_MONTH  = "[START_DATE] Through [END_DATE]"
PUBLIC CONST MDM_PVB_INTERVAL_ID_COMBOX_BOX_FORMAT_PREVIOUS_CLOSED_MONTH      = "[START_DATE] Through [END_DATE] #invoice:[INVOICE_NUMBER]"
PUBLIC CONST MDM_PVB_INTERVAL_ID_COMBOX_BOX_FORMAT_PREVIOUS_CLOSED_MONTH_WITH_NO_INVOICE_NUMBER = "[START_DATE] Through [END_DATE]"

PUBLIC CONST MDM_TOOL_BAR_PAGE_WORD     = "Page"
PUBLIC CONST MDM_TOOL_BAR_OF_WORD      = "Of"

' MSIX String Type
PUBLIC CONST MSIXDEF_TYPE_UNISTRING   = "UNISTRING"
PUBLIC CONST MSIXDEF_TYPE_STRING      = "STRING"
PUBLIC CONST MSIXDEF_TYPE_BOOLEAN     = "BOOLEAN"
PUBLIC CONST MSIXDEF_TYPE_FLOAT       = "FLOAT"
PUBLIC CONST MSIXDEF_TYPE_DOUBLE      = "DOUBLE"
PUBLIC CONST MSIXDEF_TYPE_DECIMAL     = "DECIMAL"
PUBLIC CONST MSIXDEF_TYPE_INT32       = "INT32"
PUBLIC CONST MSIXDEF_TYPE_TIMESTAMP   = "TIMESTAMP"
PUBLIC CONST MSIXDEF_TYPE_ENUM        = "ENUM"

' Some of the MetraTech API for property type is not compatible with the MetraTech MSIX Type properties
' this function solve the problem
PUBLIC FUNCTION mdm_ComputeMSIXHandlerPropertyTypeAsString(byval strType)

    strType = UCase(strType)
    If InStr(strTYPE,"INT")=1 Then mdm_ComputeMSIXHandlerPropertyTypeAsString = MSIXDEF_TYPE_INT32 : Exit Function
    
    If InStr(strTYPE,"VARCHAR")=1 Then mdm_ComputeMSIXHandlerPropertyTypeAsString = MSIXDEF_TYPE_STRING : Exit Function
    If InStr(strTYPE,"NVARCHAR")=1 Then mdm_ComputeMSIXHandlerPropertyTypeAsString = MSIXDEF_TYPE_STRING : Exit Function
    If InStr(strTYPE,"STRING")=1 Then mdm_ComputeMSIXHandlerPropertyTypeAsString = MSIXDEF_TYPE_STRING : Exit Function
    If InStr(strTYPE,"UNISTRING")=1 Then mdm_ComputeMSIXHandlerPropertyTypeAsString = MSIXDEF_TYPE_STRING : Exit Function
    
    If InStr(strTYPE,"NUMERIC")=1 Then mdm_ComputeMSIXHandlerPropertyTypeAsString = MSIXDEF_TYPE_DECIMAL : Exit Function
    If InStr(strTYPE,"DECIMAL")=1 Then mdm_ComputeMSIXHandlerPropertyTypeAsString = MSIXDEF_TYPE_DECIMAL : Exit Function
    
    If InStr(strTYPE,"DATETIME")=1 Then mdm_ComputeMSIXHandlerPropertyTypeAsString = MSIXDEF_TYPE_TIMESTAMP : Exit Function
    If InStr(strTYPE,"TIMESTAMP")=1 Then mdm_ComputeMSIXHandlerPropertyTypeAsString = MSIXDEF_TYPE_TIMESTAMP : Exit Function
    
    If InStr(strTYPE,"CHAR")=1 Then mdm_ComputeMSIXHandlerPropertyTypeAsString = MSIXDEF_TYPE_BOOLEAN : Exit Function
    
    mdm_ComputeMSIXHandlerPropertyTypeAsString = strType ' Default case return the input value
END FUNCTION

' To solve the HTML Check Box problem we create a hidden textbox and use this prefix for the name. See the MDM Programming Guide.
PUBLIC CONST MDM_CHECKBOX_PREFIX      = "MDM_CHECKBOX_"

' MDM Internal Event Code
PUBLIC CONST MDM_INTERNAL_EVENT_OPEN_DIALOG   = "OPENDIALOG"
PUBLIC CONST MDM_INTERNAL_EVENT_ON_OK         = "ONOK"
PUBLIC CONST MDM_INTERNAL_EVENT_ON_CANCEL     = "ONCANCEL"
PUBLIC CONST MDM_INTERNAL_EVENT_ON_CLICK      = "ONCLICK"
PUBLIC CONST MDM_INTERNAL_EVENT_ON_REFRESH    = "ONREFRESH"

PUBLIC CONST MT_OPERATOR_TYPE_NONE          = 0
PUBLIC CONST MT_OPERATOR_TYPE_LIKE          = 1
PUBLIC CONST MT_OPERATOR_TYPE_LIKE_W        = 2
PUBLIC CONST MT_OPERATOR_TYPE_EQUAL         = 3
PUBLIC CONST MT_OPERATOR_TYPE_NOT_EQUAL     = 4
PUBLIC CONST MT_OPERATOR_TYPE_GREATER       = 5
PUBLIC CONST MT_OPERATOR_TYPE_GREATER_EQUAL = 6
PUBLIC CONST MT_OPERATOR_TYPE_LESS          = 7
PUBLIC CONST MT_OPERATOR_TYPE_LESS_EQUAL    = 8
PUBLIC CONST MT_OPERATOR_TYPE_DEFAULT       = 9
PUBLIC CONST MT_OPERATOR_TYPE_BETWEEN       = 10
PUBLIC CONST MT_OPERATOR_TYPE_IN            = 10 ' in
PUBLIC CONST MT_OPERATOR_TYPE_IS_NULL       = 11 ' IS NULL
PUBLIC CONST MT_OPERATOR_TYPE_IS_NOT_NULL   = 12 ' IS NOT NULL
  
' consts for rowset mttypes
PUBLIC CONST MTTYPE_SMALL_INT = 0
PUBLIC CONST MTTYPE_INTEGER = 1
PUBLIC CONST MTTYPE_FLOAT = 2
PUBLIC CONST MTTYPE_DOUBLE = 3
PUBLIC CONST MTTYPE_VARCHAR = 4
PUBLIC CONST MTTYPE_VARBINARY = 5
PUBLIC CONST MTTYPE_DATE = 6
PUBLIC CONST MTTYPE_NULL = 7
PUBLIC CONST MTTYPE_DECIMAL = 8
PUBLIC CONST MTTYPE_W_VARCHAR = 9

' consts for rowset stored procedure parameters 
PUBLIC CONST INPUT_PARAM = 0
PUBLIC CONST OUTPUT_PARAM = 1
PUBLIC CONST IN_OUT_PARAM = 2
PUBLIC CONST RETVAL_PARAM = 3
  
PUBLIC CONST USER_ERROR_MASK = &H2C000000 ' #define USER_ERROR_MASK 0x2C000000

' MDM v2
PUBLIC CONST MDM_INTERNAL_PREFIX_TAB_INDEX_EVENT = "TABS("


PUBLIC CONST MDM_STRING_CONCAT_BUFFER_SIZE = 16384

    
PUBLIC FUNCTION mdm_InitializeConstants() ' As Boolean    

  eMSIX_RENDER_FLAG_DEFAULT_VALUE                   = eMSIX_RENDER_FLAG_RENDER_INPUT_TAG + eMSIX_RENDER_FLAG_RENDER_SELECT_TAG + eMSIX_RENDER_FLAG_RENDER_TEXTAREA_TAG + eMSIX_RENDER_FLAG_RENDER_FORM_TAG + eMSIX_RENDER_FLAG_RENDER_IMG_TAG + eMSIX_RENDER_FLAG_RENDER_LINK_TAG + eMSIX_RENDER_FLAG_RENDER_LABEL_TAG + eMSIX_RENDER_FLAG_RENDER_INSERT_JAVASCRIPT + eMSIX_RENDER_FLAG_RENDER_GRID + eMSIX_RENDER_FLAG_RENDER_TABS + eMSIX_RENDER_FLAG_RENDER_SERVICE_PROPERTY_WITH_BRACKET + eMSIX_RENDER_FLAG_RENDER_WIDGETS
  eMSIX_RENDER_FLAG_DEFAULT_VALUE_VERSION_2_0       = eMSIX_RENDER_FLAG_RENDER_INPUT_TAG + eMSIX_RENDER_FLAG_RENDER_SELECT_TAG + eMSIX_RENDER_FLAG_RENDER_TEXTAREA_TAG + eMSIX_RENDER_FLAG_RENDER_FORM_TAG + eMSIX_RENDER_FLAG_RENDER_IMG_TAG + eMSIX_RENDER_FLAG_RENDER_LINK_TAG + eMSIX_RENDER_FLAG_RENDER_LABEL_TAG + eMSIX_RENDER_FLAG_RENDER_INSERT_JAVASCRIPT + eMSIX_RENDER_FLAG_RENDER_GRID + eMSIX_RENDER_FLAG_RENDER_TABS +                                                          eMSIX_RENDER_FLAG_RENDER_WIDGETS 
  
  eMSIX_PROPERTIES_LOCALIZATION_FLAG_DEFAULT_VALUE  = eMSIX_PROPERTIES_LOCALIZATION_FLAG_LOCALIZE_DATE_WITH_TIME_ZONE_ID + eMSIX_PROPERTIES_LOCALIZATION_FLAG_RETURN_BIG5
  mdm_InitializeConstants                           = TRUE
END FUNCTION

' MDM v2.2
PUBLIC CONST MDM_FILTER_MODE_ON  = -1  ' Must be equal to TRUE(-1) for compatibility reason
PUBLIC CONST MDM_FILTER_MULTI_COLUMN_MODE_ON = -2

' MDM v3.0 - Optional MDM Support of security features
PUBLIC CONST MDM_FRAMEWORK_SECURITY_SESSION_CONTEXT_SESSION_NAME = "FRAMEWORK_SECURITY_SESSION_CONTEXT_SESSION_NAME"
PUBLIC CONST MDM_FRAMEWORK_SECURITY_SECURITY_POLICY_SESSION_NAME = "FRAMEWORK_SECURITY_SECURITY_POLICY_SESSION_NAME"

' MDM v3.5
CONST MDM_PVB_CHECKBOX_PREFIX = "MDM_CB_"

PUBLIC FUNCTION GetRowsetOperator(strOp, strType)

    Select Case strOp
        Case "EQUAL"
            GetRowsetOperator = MT_OPERATOR_TYPE_EQUAL
        Case "NOT_EQUAL"
            GetRowsetOperator = MT_OPERATOR_TYPE_NOT_EQUAL                
            
        Case "LIKE"
            If(UCase(strType)=MSIXDEF_TYPE_STRING)Then
                GetRowsetOperator = MT_OPERATOR_TYPE_LIKE
            Else
                GetRowsetOperator = MT_OPERATOR_TYPE_EQUAL
            End If
            
        Case "GREATER"
            GetRowsetOperator = MT_OPERATOR_TYPE_GREATER                    
        Case "GREATER_EQUAL"
            GetRowsetOperator = MT_OPERATOR_TYPE_GREATER_EQUAL
            
        Case "LESS"
            GetRowsetOperator = MT_OPERATOR_TYPE_LESS        
        Case "LESS_EQUAL"
            GetRowsetOperator = MT_OPERATOR_TYPE_LESS_EQUAL
            
        Case "BETWEEN"
            GetRowsetOperator = MT_OPERATOR_TYPE_BETWEEN
            
            
        Case Else
            GetRowsetOperator = MT_OPERATOR_TYPE_LIKE ' Default mode when no operator is showed to the user. 
    End Select
END FUNCTION
 
PUBLIC CONST MT_ERR_SYN_TIMEOUT = &hE1300025
PUBLIC CONST MT_ERR_SERVER_BUSY = &hE1300026


%>




