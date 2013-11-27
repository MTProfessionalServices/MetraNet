<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
<%
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile: DefaultPVBMapping.asp$
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
'  $Date: 5/11/00 12:00:08 PM$
'  $Author: Kevin A. Boucher$
'  $Revision: 1$
' ---------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../../MamIncludeMDM.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MamLibrary.asp" -->
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" --> 
<%

' Mandatory
Form.ServiceMsixdefFileName       = "metratech.com\ps_updateaccount.msixdef"
Form.RouteTo                      = Mam().dictionary("PAYMENT_METHODS_DIALOG")

mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION   :  Form_Initialize
' PARAMETERS :  EventArg
' DESCRIPTION:
' RETURNS    :  Return TRUE if ok else FALSE
FUNCTION Form_Initialize(EventArg) ' As Boolean
  Dim PS
  Dim Rowset
  
	Service.Clear 	' Set all the property of the service to empty. 
					        ' The Product view if allocated is cleared too.

  ' Query for existing PS Account information, and populate rowset 
  '-------------------------------------------------------------------------------------------------
  set PS = CreateObject("MTPaymentServerHelper.PaymentServer")

  set Rowset = PS.GetPaymentServerRowset("__GET_ACCOUNT_INFORMATION__",  MAM().Subscriber("_AccountId"))

  On Error Resume Next
  If IsValidObject(Rowset.Value(0)) Then
    EventArg.Error.Description = mam_getDictionary("TEXT_SETUP_PAYMENT_METHOD")
    Form_DisplayErrorMessage EventArg
    Response.end
  End If  
  On Error GoTo 0
  
  ' Setup service properties
  Service.Properties("_AccountID").Value       = Rowset.Value("id_acc")
  Service.Properties("email").Value            = Rowset.Value("nm_email")
  Service.Properties("retaincardinfo").Value   = Rowset.Value("id_retaincardinfo")
  Service.Properties("retryonfailure").Value   = Rowset.Value("nm_retryonfailure")
  Service.Properties("numberretries").Value    = Rowset.Value("id_numberretries")
  Service.Properties("confirmrequested").Value = Rowset.Value("nm_confirmrequested")
  Service.Properties("delay").Value            = Rowset.Value("id_delay")
  Service.Properties("billearly").Value        = Rowset.Value("nm_billearly")
  Service.Properties("testsession").Value      = 0
  
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
     
      ' Turn INT32 properties into boolean
      If(EventArg.UIParameters.Exist("confirmrequested"))Then
          EventArg.UIParameters("confirmrequested") = 1
      Else
          EventArg.UIParameters.add "confirmrequested"
          EventArg.UIParameters("confirmrequested") = 0
      End if

      Form_Populate = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION   :  OK_Click
' PARAMETERS :  EventArg
' DESCRIPTION:
' RETURNS    :  Return TRUE if ok else FALSE
FUNCTION OK_Click(EventArg) ' As Boolean

    On Error Resume Next
           
    ' Meter
	  Service.Meter TRUE, , mam_getDictionary("PAYMENT_SERVER_NAME_IN_SERVERS_XML")
    If(CBool(Err.Number = 0)) then

       On Error Goto 0
       OK_Click = TRUE

    Else        
        EventArg.Error.Save Err  
        OK_Click = FALSE
    End If
    Err.Clear   
END FUNCTION


%>

