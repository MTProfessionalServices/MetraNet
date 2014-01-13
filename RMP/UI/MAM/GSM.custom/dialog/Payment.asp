<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
<% 
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
'  Copyright 1998,2006 by MetraTech Corporation
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
' DIALOG	: Payment.asp
' DESCRIPTION	:  Send in a payment for AR (Ericsson demo)
' AUTHOR	:  Kevin A. Boucher
' VERSION	:  5.0Rel
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
' Mandatory Constants
Form.ServiceMsixdefFileName 	    = "metratech.com\Payment.msixdef" 	' Set the service definition msixdef file name
Form.RouteTo			                = mam_GetDictionary("WELCOME_DIALOG")
Form.MsixdefExtension             = "Core"

mdm_Main ' Invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: Form_Initialize
' PARAMETERS	:
' DESCRIPTION 	:
' RETURNS		: Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean

	  Service.Clear 	' Set all the property values of the service to empty.
                    ' The Product view if defined is cleared too.
			
		' Defaults	
  	Service.Properties("EventDate").Value 	          = FrameWork.MetraTimeGMTNow()
  	Service.Properties("_AccountID").Value 	          = MAM().Subscriber("_AccountId")
  	Service.Properties("Description").Value           = ""
  	Service.Properties("Source").Value 		            = "MT"
  	Service.Properties("ReasonCode").Value            = ""
    Service.Properties("PaymentMethod").Value         = ""
    Service.Properties("CCType").Value                = ""
    Service.Properties("CheckOrCardNumber").Value     = ""    
    Service.Properties("ReferenceID").Value           = ""
    'Service.Properties("TargetInterval").Value        = ""
    'Service.Properties("SessionTime").Value           = ""
    Service("PaymentMethod").SetPropertyType  "ENUM",  "metratech.com/balanceadjustments",  "PaymentMethod" 
    Service("ReasonCode").SetPropertyType  "ENUM",  "metratech.com/balanceadjustments",  "ReasonCode" 
    Service("CCType").SetPropertyType  "ENUM",  "metratech.com",  "CreditCardType" 
  
    ' Captions
  	Service.Properties("EventDate").Caption 	          = "Event Date"
  	Service.Properties("_AccountID").Caption 	          = "Account ID"
  	Service.Properties("Description").Caption           = "Payment Description"
  	Service.Properties("Source").Caption 		            = "Source"
  	Service.Properties("ReasonCode").Caption            = "Reason Code"
    Service.Properties("PaymentMethod").Caption         = "Payment Method"
    Service.Properties("CCType").Caption                = "Card Type"
    Service.Properties("CheckOrCardNumber").Caption     = "Check or Card Number"    
    Service.Properties("ReferenceID").Caption           = "Reference ID"
    Service.Properties("TargetInterval").Caption        = "Target Interval"
    Service.Properties("SessionTime").Caption           = "Session Time"
        
'for reference only    Service.Properties("Status").Value                = Service.Properties("Status").EnumType.Entries("Approved").Value
 
    ' Load the intervals
    Service.Properties.Interval.DateFormat = mam_GetDictionary("DATE_FORMAT")  ' Set the date format into the Interval Id Combo Box
    Service.Properties.Interval.DisplayInvoiceNumber = FALSE
    If (Not Service.Properties.Interval.Load(MAM().Subscriber("_AccountId"))) Then Exit Function
    mdm_pvb_DoToProductViewTheIntervalIDFieldAsEnumType MDM_ACTION_ADD, Service ' Populate the field Interval ID
    Service.Properties("mdmIntervalID").Required = TRUE
         
	  Form_Initialize = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : Form_Ok
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Ok_Click(EventArg) ' As Boolean

    Dim booTmpValue
    
    Ok_Click = FALSE
    
    Service.Properties("TargetInterval").value = Service.Properties("mdmIntervalID").value
    
    'Make sure they select an interval
    If Len(Trim(Service.Properties("TargetInterval").value)) = 0 Then
      exit function
    End If
    
    
    If Len(Trim(Service.Properties("_Amount").value)) = 0 Then
      exit function
    End If
        
    Service.Properties("_Amount").Operation "*",-1 ' Support DECIMAL
        
    On Error Resume Next

    Dim booOk
    booOK = Service.Meter(True)
    
    If(CBool(Err.Number = 0)) then
      Form.RouteTo      = mam_ConfirmDialogEncodeAllURL(mam_GetDictionary("TEXT_PAYMENT_TITLE"), mam_GetDictionary("TEXT_PAYMENT_CONFIRM"), Form.RouteTo)        
      OK_Click          = true
    Else
      Service.Properties("_Amount").Operation "*",-1 ' Support DECIMAL
      EventArg.Error.Save Err  
    End If
    On Error Goto 0
    Err.Clear
    
END FUNCTION

%>

