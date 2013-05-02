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
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" --> 
<%

' Mandatory
Form.ServiceMsixdefFileName       = "metratech.com\AddCharge.msixdef"
Form.RouteTo                      = mam_GetDictionary("WELCOME_DIALOG")

mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: Form_Initialize
' PARAMETERS	:
' DESCRIPTION :
' RETURNS		  : Returns TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean


	  Service.Clear 	' Set all the properties of the service to empty. 
					          ' The Product view if allocated is cleared too.

    ' Set the TimeZone for the service, so the date will be printed for the CSR time zone                      
    Service.Properties.TimeZoneId                   = MAM().CSR("TimeZoneId")
    Service.Properties.DayLightSaving               = mam_GetDictionary("DAY_LIGHT_SAVING")
  
	  Service.Properties("_AccountId").Value 	        = MAM().Subscriber("_AccountId")    
  	Service.Properties("_currency").Value 	        = MAM().Subscriber("currency")
    Service.Properties("issuer").Value 		          = MAM().CSR("_AccountId")
    
    Service.Properties("ChargeDate").Value 	        = FrameWork.MetraTimeGMTNow()
    Service.Properties("ChargeDate").Format         = mam_GetDictionary("DATE_TIME_FORMAT")

    If(Service.Tools.BooleanValue(MAM().Subscriber("TaxExempt")))Then ' The user is Tax Exempted
        Service.Properties("TaxType").Value   = FALSE ' Say not tax for the charge
        Service.Properties("TaxType").Enabled = FALSE ' The CSR cannot change the check box
    Else        
        Service.Properties("TaxType").Value   = TRUE  ' The change should be taxed, this can be changed by the csr
    End If
	
		Service.Properties.Add "MAX_AUTHORIZED_AMOUNT"  , "String" , 255 , False, Empty ' String because display purpose only
		
		' Get the max amount of credit the csr can issue
  	Service.Properties("MAX_AUTHORIZED_AMOUNT").Value = FrameWork.GetDecimalCapabilityMaxAmountAsString("Issue Charges",mam_GetDictionary("SUPER_USER_ISSUE_CREDITS_MAX_AMOUNT"))
    Service.Properties("MAX_AUTHORIZED_AMOUNT").Caption = ""
    
	  Form_Initialize = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : Form_Populate()
' PARAMETERS		  : 
' DESCRIPTION 		: This event is called by the MDM before it will populate the service MSIXHandler instance...
'                   So we can change some bad value... Here we use it to associate a CHECKBOX with a INT32 property:
'                   By default the MDM does not support it; it support only CHECKBOX and boolean; but with this event
'                   we can make it...  
' RETURNS		      : Returns TRUE if ok else FALSE
PRIVATE FUNCTION Form_Populate(EventArg) ' As Boolean
    
      inherited("Form_Populate") ' First Let us call the inherited event      
      
      ' If the parameter TaxType is defined in the collection this mean the value is true
      ' If it is not this mean the value is false; this is how HTML Processes check box...
      ' ABS(TRUE) is 1, ABS(FALSE) is 0;
      
      If(EventArg.UIParameters.Exist("TaxType"))Then 
          EventArg.UIParameters("TaxType").Value = 1
      Else
          EventArg.UIParameters.Add "TaxType"
          EventArg.UIParameters("TaxType").Value = 0
      End If
      Form_Populate = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : OK_Click()
' PARAMETERS		  :
' DESCRIPTION 		: 
' RETURNS		      : Returns TRUE if ok else FALSE
PRIVATE FUNCTION Ok_Click(EventArg) ' As Boolean

    Service.Properties("TaxType").Value = ABS(CBOOL(Service.Properties("TaxType").Value)) ' Convert the value - ABS(TRUE) is 1, ABS(FALSE) is 0;
        
    Service.Properties("TaxType").Enabled = TRUE ' Reset to true so the value can be metered...
        
    
    On Error Resume Next   
        
	  Service.Meter TRUE  ' Meters and waits for result
    If(Err.Number)Then
        EventArg.Error.Save Err
        OK_Click = FALSE
        Err.Clear
    Else
        Form.RouteTo = mam_ConfirmDialogEncodeAllURL(mam_GetDictionary("TEXT_CONFIRM_ADD_CHARGE_TITLE"), mam_GetDictionary("TEXT_CONFIRM_ADD_CHARGE"), form.routeto)
        OK_Click = TRUE
    End If
END FUNCTION

%>

