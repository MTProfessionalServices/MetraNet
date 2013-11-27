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
Form.ServiceMsixdefFileName       = mam_GetServiceDefForOperationAndType("Update", "SystemAccount") 
Form.RouteTo                      = mam_GetDictionary("WELCOME_DIALOG")
Form.HelpFile                     = "DEFAULTPVBUPDATECSR.hlp.htm"

mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: Form_Initialize
' PARAMETERS		:
' DESCRIPTION 		:
' RETURNS		: Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean

  Call mam_AccountEnumTypeSupportEmpty(Service.Properties)

  Service.Clear 	' Set all the property of the service to empty. 
         					' The Product view if allocated is cleared too.
     
  ' Add confirm Password property
  Service.Properties.Add "confirmPassword", "STRING", "255", TRUE, ""

  ' Set properties from row set
  MAM().CSR.CopyTo Service.Properties
 
  ' values must be set
  Service.Properties("ActionType").value = Service.Properties("ActionType").EnumType("Both")
  Service.Properties("Operation").Value  = Service.Properties("Operation").EnumType("Update")
  Service.Properties("LoginApplication").Value = Service.Properties("LoginApplication").EnumType.Entries("CSR").Value   
  'Service.Properties("ContactType").Value  = Service.Properties("ContactType").EnumType("Bill-To")

  Service.Properties("AccountStartDate").Value = Empty
  Service.Properties("hierarchy_startdate").Value = Empty          
  Service.Properties("hierarchy_enddate").Value = Empty 
            
	SetRequiredProperties(EventArg)
           
	Form_Initialize = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION   :  SetRequiredProperties
' PARAMETERS :  EventArg
' DESCRIPTION:
' RETURNS    :  Return TRUE if ok else FALSE
FUNCTION SetRequiredProperties(EventArg) ' As Boolean

  Service.Properties("confirmPassword").Required = TRUE
  Service.Properties("Password_").Required       = TRUE     
  SetRequiredProperties                          = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : Form_Ok
' PARAMETERS		:
' DESCRIPTION 		:
' RETURNS		    : Return TRUE if ok else FALSE
FUNCTION Ok_Click(EventArg) ' As Boolean

    Dim strMessage
    
    OK_Click = FALSE      
    
    If Service.Properties("password_").Value = Service.Properties("confirmPassword").Value Then
    
      mam_Account_SetToEmptyAllTheEmptyStringValue
      mam_Account_DoNotMeterAccountStateInfo service
      Service.Properties("AncestorAccountID") = Empty
      On Error Resume Next        
  	  Service.Meter TRUE ' Meter and wait for result            
      If Err.Number Then
      
         EventArg.error.Save Err
         Err.Clear
      Else        
         strMessage    = Replace(mam_GetDictionary("TEXT_CONFIRM_UPDATE_CSR"), "[ACCOUNT]", Service.Properties("UserName").Value)
         form.routeto  = mam_ConfirmDialogEncodeAllURL( mam_GetDictionary("TEXT_CONFIRM_UPDATE_CSR_TITLE"), strMessage, form.routeto )
         OK_Click      = TRUE
      End If
      On Error Goto 0      
    Else
       EventArg.Error.Number      = 1001 ' Error password not confirmed
       EventArg.Error.Description = FrameWork.GetHTMLDictionaryError("MAM_ERROR_1001")
       OK_Click                   = FALSE
    End If
END FUNCTION
%>

