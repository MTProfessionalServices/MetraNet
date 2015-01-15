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
Form.ServiceMsixdefFileName       = "metratech.com\ps_archiveauthorization.msixdef"
Form.RouteTo                      = mam_GetDictionary("PAYMENT_METHODS_DIALOG")
Form.Localize                     = FALSE
mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION   :  Form_Initialize
' PARAMETERS :  EventArg
' DESCRIPTION:
' RETURNS    :  Return TRUE if ok else FALSE
FUNCTION Form_Initialize(EventArg) ' As Boolean
  Dim Rowset
  Dim PS
  
	Service.Clear 	' Set all the property of the service to empty. 
					        ' The Product view if allocated is cleared too.

    '<dn>_AccountID * </dn>
    '<dn>routingnumber *</dn>
    '<dn>lastfourdigits *</dn>
    '<dn>bankaccounttype *</dn>
    '<dn>creditcardtype *</dn>
    '<dn>paymenttype</dn>
    '<dn>effectivedate</dn>
    '<dn>_Amount</dn>
    '<dn>username</dn>
    '<dn>password_</dn>
    '<dn>description</dn>
  
  ' Query for existing credit card information, and populate rowset 
  '-------------------------------------------------------------------------------------------------
  set PS = CreateObject("MTPaymentServerHelper.PaymentServer")

  set Rowset = PS.GetACHUpdateRowset("__GET_ACH_PAYMENT_DETAILS__",  MAM().Subscriber("_AccountId"), request.QueryString("Account_Number"), request.QueryString("Account_Type"), request.QueryString("Routing_Number"))

'0 nm_customer
'1 nm_routingnumber
'2 nm_accountnumber
'3 id_accounttype
'4 id_acc
'5 nm_primary
'6 nm_enabled
'7 nm_authreceived
'8 nm_validated
'9 nm_address
'10 nm_city
'11 nm_state
'12 nm_zip
'13 nm_country 
'14 nm_bankname
'15 nm_lastfourdigits
'16 nm_reserved1
'17 nm_reserved2                             

  Service.Properties("username").Value         = Rowset.value("nm_customer")
  Service.Properties("routingnumber").Value    = Rowset.value("nm_routingnumber")
  Service.Properties("bankaccounttype").Value  = request.QueryString("Account_Type")
  Service.Properties("_AccountID").Value       = Rowset.value("id_acc")
  Service.Properties("lastfourdigits").Value   = Rowset.value("nm_lastfourdigits")
  Service.Properties("paymenttype").Value      = "ACH"
  Service.Properties("_Amount").Value          = 0
    
	Form_Initialize = TRUE
END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION   :  OK_Click
' PARAMETERS :  EventArg
' DESCRIPTION:
' RETURNS    :  Return TRUE if ok else FALSE
FUNCTION OK_Click(EventArg) ' As Boolean

    On Error Resume Next
    
    ' Meter
	  Service.Meter True, , mam_getDictionary("PAYMENT_SERVER_NAME_IN_SERVERS_XML") 'async.
    If(CBool(Err.Number = 0)) then

       On Error Goto 0
       OK_Click = TRUE

    Else        
        Err.description = mam_GetDictionary("TEXT_AUTH_FAILURE") 
        EventArg.Error.Save Err  
        Service.Log mam_GetDictionary("TEXT_AUTH_FAILURE"), eLOG_ERROR
        OK_Click = FALSE
    End If
    Err.Clear   
END FUNCTION

%>

