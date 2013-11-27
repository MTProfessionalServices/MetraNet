<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
<%
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
'  Copyright 1998 - 2002 by MetraTech Corporation
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
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' 
' DIALOG	   :  ManualPayment.asp
' DESCRIPTION:  Allows CSR to enter manual payments for an account...
' AUTHOR	   :  K. Boucher
' VERSION	   :  V3.5
'
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../../MamIncludeMDM.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MamLibrary.asp" -->
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" --> 
<%

' Page Setup
Form.Version                = MDM_VERSION     ' Set the dialog version
Form.ServiceMsixdefFileName = "metratech.com\BalanceAdjustments.msixdef"
Form.RouteTo                = mam_GetDictionary("WELCOME_DIALOG")

mdm_Main ' Invoke the MDM

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		:  Form_Initialize
' PARAMETERS	:
' DESCRIPTION :
' RETURNS		  :  Returns TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean

	  Service.Clear 	' Set all the properties of the service to empty. 
					          ' The Product view if allocated is cleared too.
    
    Service.Properties("Payer")  = mam_GetSubscriberAccountID()
    Service.Properties("Source") = "MT"    

		' Get the max amount the csr can issue
		Service.Properties.Add "MAX_AUTHORIZED_AMOUNT", "String" , 255 , False, Empty ' String because display purpose only
    'TODO: Get Manual Payment Capability max amount
  	Service.Properties("MAX_AUTHORIZED_AMOUNT").Value = FrameWork.GetDecimalCapabilityMaxAmountAsString("Issue Charges", mam_GetDictionary("SUPER_USER_ISSUE_CREDITS_MAX_AMOUNT"))
    Service.Properties("MAX_AUTHORIZED_AMOUNT").Caption = ""

    mam_IncludeCalendar         ' Include Calendar javascript    
    Service.LoadJavaScriptCode  ' This line is important to get JavaScript field validation
      
	  Form_Initialize = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 	 :  OK_Click()
' PARAMETERS :
' DESCRIPTION: 
' RETURNS		 :  Returns TRUE if ok else FALSE
PRIVATE FUNCTION Ok_Click(EventArg) ' As Boolean
    On Error Resume Next   
        
	  Service.Meter TRUE  ' Meters and waits for result
    If(CBool(Err.Number = 0)) then
      On Error Goto 0
      Form.RouteTo = mam_ConfirmDialogEncodeAllURL(mam_GetDictionary("TEXT_MANUAL_PAYMENT_TITLE"), mam_GetDictionary("TEXT_MANUAL_PAYMENT_SUCCESS"), form.routeto)
      OK_Click = TRUE
    Else        
      EventArg.Error.Save Err  
      OK_Click = FALSE
    End If    
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION   :  Cancel_Click
' PARAMETERS :  EventArg
' DESCRIPTION:
' RETURNS    :  Return TRUE if ok else FALSE
FUNCTION Cancel_Click(EventArg) ' As Boolean

  Cancel_Click = TRUE
END FUNCTION
%>

