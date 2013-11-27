<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
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
'
' MetraTech Dialog Manager Framework ASP Dialog Template
' 
' DIALOG	    :
' DESCRIPTION	:
' AUTHOR	    :
' VERSION	    :
'
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../../MamIncludeMDM.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MamLibrary.asp" -->
<!-- #INCLUDE FILE="../../default/Lib/AccountLib.asp" -->
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" --> 
<%

' Mandatory
Form.ServiceMsixdefFileName = mam_GetAccountCreationMsixdefFileNameForSystemAccount()
Form.RouteTo = mam_GetDictionary("FIND_CSR_DIALOG")
Form.HelpFile = "DEFAULTPVBUPDATECSR.hlp.htm"

mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: Form_Initialize
' PARAMETERS	:
' DESCRIPTION 	:
' RETURNS		: Return TRUE if ok else FALSE

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: Form_Initialize
' PARAMETERS		:
' DESCRIPTION 		:
' RETURNS		: Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean

   	Service.Clear 	' Set all the property of the service to empty.   The Product view if allocated is cleared too.

    Call mam_AccountEnumTypeSupportEmpty(Service.Properties)
    
    ' Tell the enum type to use the enum type item name rather that value as index because in the all MAM application we use the name and not the value                
    Service.Properties("Language").EnumType.Flags = eMSIX_ENUM_TYPE_FLAG_USE_NAME_IN_HTML_OPTIONS_TAG_AS_INDEX
 
    If CBool(mam_LoadTempCSRAccount(mam_GetSystemUser().AccountID)) Then
    
      Service.Properties.Add "ConfirmPassword", "STRING", "255", TRUE, "" ' Add confirm Password property
      
      mam_Account_SetDynamicEnumType()
      
      MAM().TempAccount.CopyTo Service.Properties

      Service.Properties("ActionType").value = Service.Properties("ActionType").EnumType("Both")
      Service.Properties("Operation").Value  = Service.Properties("Operation").EnumType("Update")
      Service.Properties("ContactType").Value  = Service.Properties("ContactType").EnumType("Bill-To")

    End IF
      
	  Form_Initialize = TRUE
END FUNCTION


%>

