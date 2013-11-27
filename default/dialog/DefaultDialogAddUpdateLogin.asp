<%
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
'  Copyright 1998-2003 by MetraTech Corporation
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
' 
' DIALOG	    : DefaultDialogAddUpdateLogin.asp
' DESCRIPTION	: Allow to add any kind of application login to the MetraTech Plateform.
'               This dialog was designed to be called from the MOM application or as a stand alone
'               dialog.
'               General Optional Parameters:
'                   DEFAULT_TITLE                           - Define the title. Default value is Add Login.
'                   ROUTE_TO_PAGE                           - Define the route to page.
'                   DEFAULT_TIME_ZONE_ID                    - Time zone id when the dialog is open. The default value is 18 - USA Estern Time US CANADA. See global\timezone enum type.
'                   DEFAULT_COUNTRY_ID                      - Country when the dialog is open. The default value is 208 - US - See global\countryname enum type.
'                   DEFAULT_LANGUAGE_ID                     - Language when the dialog is open. The default value is 0-US. See global\language enum type.                  
'                   DEFAULT_NAME_SPACE_QUERY_NAME           - The SQL Query name used to populate the name_space combobox. The default value is __GET_NAME_SPACE_LIST_FOR_LOGIN__.
'                   DEFAULT_NAME_SPACE_QUERY_RELATIVE_PATH  - The SQL Query relative path where to read the the SQL query file. The default value "queries\mom".
'
'               Stand Alone Mandatory Parameters:
'                   DEFAULT_CSR_ID = The CSR-ID
'
' AUTHOR	    :
' VERSION	    :
'
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/mdm.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MomLibrary.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/FrameWork/CFrameWork.Class.asp" -->
<%
Form.ServiceMsixdefFileName = "metratech.com/SystemAccountCreation.msixdef" 'mom_GetAccountCreationMsixdefFileName()

mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		  : Form_Initialize
' PARAMETERS		:
' DESCRIPTION 	:
' RETURNS		    : Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean
	
	  Service.Clear 	' Set all the property of the service to empty.  The Product view if allocated is cleared too.
    
    Service.Properties.Add "ConfirmPassword", "STRING", "255", TRUE, "" ' Add confirm Password property    
    Service.Properties("ConfirmPassword").Caption = mom_GetDictionary("TEXT_ADD_UPDATE_LOGIN_CONFIRM_PASSWORD")
    
    Service.Properties.Add "ApplyDefaultSecurityPolicy"  , "Boolean" , 0 , False, Empty
    Service.Properties("ApplyDefaultSecurityPolicy").Value   = TRUE
    Service.Properties("ApplyDefaultSecurityPolicy").Enabled = FALSE

    Form.RouteTo = mdm_MsgBoxOk(mom_GetDictionary("TEXT_ADD_UPDATE_LOGIN_TITLE"), mom_GetDictionary("TEXT_SUCCESS"), mom_GetDictionary("ADD_LOGIN_DIALOG"), Empty)
    
    mdm_GetDictionary.Add "TEXT_ADD_UPDATE_LOGIN_TITLE",GetParameter("DEFAULT_TITLE",mom_GetDictionary("TEXT_ADD_UPDATE_LOGIN_TITLE"))
    
    'LoginApplication
    'Service("LoginApplication").EnumType.Entries.Remove ACCOUNT_TYPE_SUB ' -- We cannot add subscriber account --
    
    ' -- Set properties before the dialog pops up --
    Service("ActionType")               = Service("ActionType").EnumType("Account")
    Service("Operation")                = Service("Operation").EnumType("Add")
    Service("ContactType")              = Service("ContactType").EnumType("Bill-To")
    'Service("UsageCycleType")           = Service("UsageCycleType").EnumType("Monthly")
    Service("AccountStatus")            = Service("AccountStatus").EnumType("Active")
    	  
    Service("AccountType")              = "SystemAccount"
	Service("Name_Space")               = ""
    Service("timezoneoffset")           = -5
    Service("DayOfMonth")               = 1
    Service("transactioncookie")        = ""
    Service("city")                     =   "waltham"
    Service("state")                    =   "ma"
    Service("zip")                      =   "02452"
    
    Service("TimeZoneId")               = GetParameter("DEFAULT_TIME_ZONE_ID"  , 18  )
    Service("Country")                  = GetParameter("DEFAULT_COUNTRY_ID"    , 208 )
    Service("Language")                 = GetParameter("DEFAULT_LANGUAGE_ID"   , 0   )
    Service("_AccountId") 	            = GetParameter("DEFAULT_CSR_ID"        , FrameWork.AccountID)    
    Service("Name_Space")               = mom_DEFAULT_NAME_SPACE
    Service("Currency")                 = "USD"
    
    'Service("AccountType").EnumType.Entries.Remove "CSR"
    'Service("AccountType").EnumType.Entries.Remove "SYS"
    'Service("AccountType").EnumType.Entries.Remove "IND"
    'Service("AccountType").Required = TRUE

    'SetNameSpaceComboBox

	  Form_Initialize = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : Ok_Click
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Ok_Click(EventArg) ' As Boolean

    Dim strMessage
    
    If(Service("password_") = Service("confirmPassword"))Then
    
        On Error Resume Next
    	  Service.Meter TRUE ' Meter and wait for result!
        If(Err.Number)Then
            EventArg.error.Save Err
            OK_Click = FALSE
            Err.Clear
        Else
            OK_Click = TRUE ' Goto to route to page
            
        End If
        On Error Goto 0
    Else
          EventArg.Error.Description = mom_GetDictionary("TEXT_ADD_UPDATE_LOGIN_ERROR_CONFIRM_PASSWORD_DOES_NOT_MATCH")
          OK_Click                   = FALSE
    End If
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : Cancel_Click
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Cancel_Click(EventArg) ' As Boolean
   Form.RouteTo = mom_GetDictionary("WELCOME_DIALOG")
   Cancel_Click = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : GetParameter
' PARAMETERS		  :
' DESCRIPTION 		: Internal dialog entry function to read command line parameter. The implementation may
'                   vary according how we pass the command line parameter
' RETURNS		      :
PRIVATE FUNCTION GetParameter(strName,strDefaultValue)

    GetParameter = mdm_UIValueDefault(strName,strDefaultValue)
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : SetNameSpaceComboBox
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION SetNameSpaceComboBox() ' As Boolean

    Dim strQueryName
    Dim strQueryRelativPath
    
    strQueryName        = GetParameter("DEFAULT_NAME_SPACE_QUERY_NAME"          , "__GET_NAME_SPACE_LIST_FOR_LOGIN__")
    strQueryRelativPath = GetParameter("DEFAULT_NAME_SPACE_QUERY_RELATIVE_PATH" , mom_GetDictionary("SQL_QUERY_STRING_RELATIVE_PATH") )
    
    Service("Name_Space").AddValidListOfValues strQueryName,,,,strQueryRelativPath
    SetNameSpaceComboBox = TRUE
END FUNCTION

%>
