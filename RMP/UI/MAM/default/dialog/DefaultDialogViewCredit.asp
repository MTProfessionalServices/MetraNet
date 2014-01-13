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
<!-- #INCLUDE FILE="../../default/lib/MamCreditLibrary.asp" -->
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" --> 
<%
Form.ServiceMsixdefFileName 	    = "metratech.com\AccountCredit.msixdef" 	' Set the service definition msixdef file name
Form.RouteTo			                = mam_GetDictionary("CREDIT_REQUESTS_BROWSER")

mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		  : Form_Initialize
' PARAMETERS	  :
' DESCRIPTION 	:
' RETURNS		    : Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean

  Dim objMTSQLRowset
  
  Service.Clear 	
  Set objMTSQLRowset = mdm_CreateObject(MTSQLRowset)
  
  ' Make the sql call
  If(Service.Tools.ExecSQL(mam_GetDictionary("SQL_QUERY_STRING_RELATIVE_PATH"),"__GET_CREDIT_FROM_CREDIT_REQUEST__",objMTSQLRowset,"REQUEST_ID",Request.QueryString("SessionId")))Then
  
      ' Populate the value of the service with the rowset value - not the querie return 1 row
      ' the function SetPropertiesFromRowset use the current row only
      If objMTSQLRowset.RecordCount Then

        Service("_Amount")    = objMTSQLRowset.Value("amount")
        Service("_currency")  = objMTSQLRowset.Value("am_currency")
        Form_Initialize       = Service.Properties.SetPropertiesFromRowset(objMTSQLRowset)
      Else
        EventArg.Error.Description = FrameWork.GetHTMLDictionaryError("MAM_ERROR_1016")
        Form_DisplayErrorMessage EventArg
        
        Form_Initialize = FALSE
        Response.end  
            
      End If
  End If	
  
  Service("_Amount").Format                  = mam_GetDictionary("AMOUNT_FORMAT")
  Service("RequestAmount").Format            = mam_GetDictionary("AMOUNT_FORMAT")
  
END FUNCTION


%>

