<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
<%
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile$
' 
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
'  Created by: Kevin A. Boucher
' 
'  $Date$
'  $Author$
'  $Revision$
' ---------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../../MamIncludeMDM.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MamLibrary.asp" -->
<!-- #INCLUDE FILE="../../default/lib/AccountLib.asp" -->
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" --> 
<%

' Mandatory
Form.RouteTo = mam_GetDictionary("PAYMENT_METHODS_DIALOG")
Form.Localize = FALSE

mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION   :  Form_Initialize
' PARAMETERS :  EventArg
' DESCRIPTION:
' RETURNS    :  Return TRUE if ok else FALSE
FUNCTION Form_Initialize(EventArg) ' As Boolean
  
	Service.Clear 	' Set all the property of the service to empty. 
					        ' The Product view if allocated is cleared too.
  
  Service.Properties.Add "PaymentMethod", "string",  0, False, 0  
  Service.Properties("PaymentMethod").SetPropertyType "ENUM", FrameWork.Dictionary.Item("ACCOUNT_CREATION_SERVICE_ENUM_TYPE_LOADING").Value , "PaymentMethod"
 
  MAM().Subscriber("PaymentMethod").Tag     = MAM().Subscriber("PaymentMethod").Value 'save value for failure case  
  Service.Properties("PaymentMethod").Value = MAM().Subscriber("PaymentMethod").Value

  ' Add internal properties that are used to build the UI logic.  These properties will not be metered.
  Service.Properties.Add "defaultpayment", "Boolean",  0, FALSE, TRUE  ' Add the default payment flag on the fly
  
  If Service.Properties("PaymentMethod") = Service.Properties("PaymentMethod").EnumType.Entries("CreditOrACH") Then
     Service.Properties("defaultpayment") = False
  Else
     Service.Properties("defaultpayment") = True
  End If
     
	Form_Initialize = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION   :  OK_Click
' PARAMETERS :  EventArg
' DESCRIPTION:
' RETURNS    :  Return TRUE if ok else FALSE
FUNCTION OK_Click(EventArg) ' As Boolean
    
    If Service.Properties("defaultpayment") Then
         MAM().Subscriber("PaymentMethod") = Service.Properties("PaymentMethod").EnumType.Entries("CashOrCheck")
    Else
         MAM().Subscriber("PaymentMethod") = Service.Properties("PaymentMethod").EnumType.Entries("CreditOrACH")  
    End If
           
    ' Call Function to Meter account creation   
    If(UpdateAccountCreation(EventArg,MAM().Subscriber, "Account")) then
       'On Error Goto 0
       OK_Click = TRUE
    Else      
        EventArg.Error.Save Err            
        Err.Clear   
        MAM().Subscriber("PaymentMethod") = MAM().Subscriber("PaymentMethod").Tag ' restore old value on failure
       OK_Click = FALSE
    End If    
      
END FUNCTION

%>