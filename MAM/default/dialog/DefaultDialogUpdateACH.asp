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
<!-- #INCLUDE FILE="../../default/lib/AccountLib.asp" -->
<!-- #INCLUDE FILE="../../default/lib/PaymentServerLib.asp" -->
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" --> 
<%

' Mandatory
Form.ServiceMsixdefFileName       = "metratech.com\ps_ach_updatepaymentmethod.msixdef"
Form.RouteTo                      = mam_GetDictionary("PAYMENT_METHODS_DIALOG")
Form.Localize                     = FALSE
mdm_Main ' invoke the mdm framework


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION   :  Form_Paint
' PARAMETERS :  EventArg
' DESCRIPTION:
' RETURNS    :  Return TRUE if ok else FALSE
FUNCTION Form_Paint(EventArg) ' As Boolean

  If Service.Properties("defaultpayment") Then
    ' If we are the payment server preferred and cash/check is set, let the user check this as preferred
    If Session("bPaperInvoiceIsDefault") Then 
      Service.Properties("defaultpayment") = False
      EventArg.HTMLRendered = Replace(EventArg.HTMLRendered,"[DEFAULT_PAYMENT_CONTROL]","<input type=checkbox name='defaultpayment'>")
    Else
      EventArg.HTMLRendered = Replace(EventArg.HTMLRendered,"[DEFAULT_PAYMENT_CONTROL]", mam_GetDictionary("TEXT_SELECTED_ELECTRONIC"))
    End If
  Else
    EventArg.HTMLRendered = Replace(EventArg.HTMLRendered,"[DEFAULT_PAYMENT_CONTROL]","<input type=checkbox name='defaultpayment'>")
  End if
  

  If Service.Properties("authreceived") Then
    EventArg.HTMLRendered = Replace(EventArg.HTMLRendered,"[AUTHRECEIVED_CONTROL]", mam_GetDictionary("TEXT_AUTHRECEIVED_CONTROL"))
  Else
    EventArg.HTMLRendered = Replace(EventArg.HTMLRendered,"[AUTHRECEIVED_CONTROL]","<input type=checkbox name='authreceived'>")
  End if
  
  If Service.Properties("validated") Then
    EventArg.HTMLRendered = Replace(EventArg.HTMLRendered,"[VALIDATED_CONTROL]", mam_GetDictionary("TEXT_VALIDATED_YES"))
  Else
    EventArg.HTMLRendered = Replace(EventArg.HTMLRendered,"[VALIDATED_CONTROL]", mam_GetDictionary("TEXT_VALIDATED_NO"))
  End if

  
End Function  

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

  ' Add internal properties that are used to build the UI logic.  These properties will not be metered.
  Service.Properties.Add "defaultpayment", "Boolean",  0, False, TRUE  ' Add the default payment flag on the fly

  Service.Properties("defaultpayment") = CBool(request.QueryString("Default_Payment"))
  
  ' Setup Enums 
  Service("Country").SetPropertyType "ENUM","global","CountryName"
  
  ' Query for existing credit card information, and populate rowset 
  '-------------------------------------------------------------------------------------------------
  set PS = CreateObject("MTPaymentServerHelper.PaymentServer")

  set Rowset = PS.GetACHUpdateRowset("__GET_ACH_PAYMENT_DETAILS__",  MAM().Subscriber("_AccountId"), request.QueryString("Account_Number"), request.QueryString("Account_Type"), request.QueryString("Routing_Number"))

  On Error Resume Next
  If IsValidObject(Rowset.Value(0)) Then
    EventArg.Error.Description = mam_getDictionary("TEXT_ERROR_ROWSET")
    Form_DisplayErrorMessage EventArg
    Response.end
  End If  
  On Error GoTo 0
  
  Service.Properties("customername").Value     = Rowset.value("nm_customer")
  Service.Properties("routingnumber").Value    = Rowset.value("nm_routingnumber")
  Service.Properties("bankaccounttype").Value  = request.QueryString("Account_Type")
  Service.Properties("_AccountID").Value       = Rowset.value("id_acc")
  Service.Properties("primary").Value          = Rowset.value("nm_primary")
  Service.Properties("enabled").Value          = Rowset.value("nm_enabled")
  Service.Properties("authreceived").Value     = Rowset.value("nm_authreceived")
  Service.Properties("validated").Value        = Rowset.value("nm_validated")
  Service.Properties("address").Value          = Rowset.value("nm_address")
  Service.Properties("city").Value             = Rowset.value("nm_city")
  Service.Properties("state").Value            = Rowset.value("nm_state")
  Service.Properties("zip").Value              = Rowset.value("nm_zip")
  Service.Properties("country").Value          = Rowset.value("nm_country")
  Service.Properties("bankname").Value         = Rowset.value("nm_bankname")
  Service.Properties("lastfourdigits").Value   = Rowset.value("nm_lastfourdigits")
  Service.Properties("reserved1").Value        = 0
  Service.Properties("reserved2").Value        = 0
  Service.Properties("testsession").Value      = 0  
  
  Form("authreceived")      = Service.Properties("authreceived").Value
  Form("validated")         = Service.Properties("validated").Value 
  Form("defaultpayment")    = Service.Properties("defaultpayment").Value 
      
  SetRequiredProperties(EventArg) 

  Service.Properties("bankaccounttype").Caption = mam_GetDictionary("TEXT_BANK_ACCOUNT_TYPE")
  Service.Properties("bankname").Caption = mam_GetDictionary("TEXT_BANK_NAME")
  Service.Properties("customername").Caption   = mam_GetDictionary("TEXT_CUSTOMER_NAME_ACH")
  Service.Properties("address").Caption        = mam_GetDictionary("TEXT_ADDRESS")
  Service.Properties("city").Caption           = mam_GetDictionary("TEXT_CITY")
  Service.Properties("state").Caption          = mam_GetDictionary("TEXT_STATE")
  Service.Properties("zip").Caption            = mam_GetDictionary("TEXT_ZIP")
  Service.Properties("COUNTRY").Caption        = mam_GetDictionary("TEXT_COUNTRY")
    
  Form_Initialize = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION   :  SetRequiredProperties
' PARAMETERS :  EventArg
' DESCRIPTION:
' RETURNS    :  Return TRUE if ok else FALSE
FUNCTION SetRequiredProperties(EventArg) ' As Boolean

  Service.Properties("bankaccounttype").Required = TRUE
  Service.Properties("bankname").Required       = TRUE
  Service.Properties("customername").Required   = TRUE
  Service.Properties("address").Required        = TRUE
  Service.Properties("city").Required           = TRUE
  Service.Properties("state").Required          = TRUE
  Service.Properties("zip").Required            = TRUE
  Service.Properties("COUNTRY").Required        = TRUE
  Service.Properties("routingnumber").Required = TRUE

  SetRequiredProperties = TRUE 
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
      'If(EventArg.UIParameters.Exist("enabled"))Then
      '    EventArg.UIParameters("enabled") = 1
      'Else
      '    EventArg.UIParameters.add "enabled"
      '    EventArg.UIParameters("enabled") = 0
      'End if

      If(EventArg.UIParameters.Exist("authreceived"))Then
          EventArg.UIParameters("authreceived") = 1
      Else
          EventArg.UIParameters.add "authreceived"
          EventArg.UIParameters("authreceived") = 0
      End If
      IF(CBool(Form("authreceived")) = True)Then
          EventArg.UIParameters.add "authreceived"
          EventArg.UIParameters("authreceived") = 1
      End If
      
      If(EventArg.UIParameters.Exist("validated"))Then
          EventArg.UIParameters("validated") = 1
      Else
          EventArg.UIParameters.add "validated"
          EventArg.UIParameters("validated") = 0
      End if
      IF(CBool(Form("validated")) = True)Then
          EventArg.UIParameters.add "validated"
          EventArg.UIParameters("validated") = 1
      End If
                 
      Form_Populate = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION   :  OK_Click
' PARAMETERS :  EventArg
' DESCRIPTION:
' RETURNS    :  Return TRUE if ok else FALSE
FUNCTION OK_Click(EventArg) ' As Boolean

    On Error Resume Next

    ' If Auth received status has changed go to auth. received page
    If (CBool(Form("authreceived")) = False) and (CBool(Service.Properties("authreceived").Value) = True) then
         Dim strRouteTo
         strRouteTo = mam_GetDictionary("PAYMENT_METHODS_AUTH_RECEIVED_DIALOG") & "?Account_Number=" & server.URLEncode(Service.Properties("lastfourdigits")) & "&Account_Type="   & server.URLEncode(Service.Properties("bankaccounttype")) & "&Routing_Number=" & server.URLEncode(Service.Properties("routingnumber")) 
         Form.RouteTo = strRouteTo
    End If    
    
    ' Meter
	  Service.Meter TRUE, , mam_getDictionary("PAYMENT_SERVER_NAME_IN_SERVERS_XML")
    If(CBool(Err.Number = 0)) then

       On Error Goto 0
       OK_Click = TRUE

       If (CBool(Form("defaultpayment")) = False) and (CBool(Service.Properties("defaultpayment").Value) = True) then
            OK_Click = SetAsPrimary(EventArg)
       End If
       If (CBool(Form("defaultpayment")) = True) and (CBool(Service.Properties("defaultpayment").Value) = True) Then
          OK_Click = UsePaymentServer
       End If 
       
       If Not OK_Click Then
         EventArg.Error.Save Err  
       End If
  
    Else        
        EventArg.Error.Save Err  
        OK_Click = FALSE
    End If
    Err.Clear   
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION   :  SetAsPrimary
' PARAMETERS :  EventArg
' DESCRIPTION:  Set as primary payment method
' RETURNS    :  Return TRUE if ok else FALSE
PRIVATE FUNCTION SetAsPrimary(EventArg) ' As Boolean
  Dim PrimaryService
  Dim strServiceMsixDefFile
  
    strServiceMsixDefFile = "metratech.com\ps_ach_updateprimaryindicator.msixdef"
    SetAsPrimary          = FALSE
    Set PrimaryService    = mdm_CreateObject(MSIXHandler_PROG_ID)
    
    If(PrimaryService.Initialize(strServiceMsixDefFile,,mdm_GetSessionVariable("mdm_APP_LANGUAGE"),mdm_GetSessionVariable("mdm_APP_FOLDER"),mdm_GetMDMFolder(),mdm_InternalCache))Then
  
        PrimaryService.Properties("_AccountID")            = Service("_AccountID")
        PrimaryService.Properties("routingnumber").Value   = Service("routingnumber")
        PrimaryService.Properties("lastfourdigits").Value  = Service("lastfourdigits")
        PrimaryService.Properties("bankaccounttype").Value = Service("bankaccounttype")
        PrimaryService.Properties("testsession").Value     = Service("testsession")
        
        On Error Resume Next
        PrimaryService.Meter TRUE, , mam_getDictionary("PAYMENT_SERVER_NAME_IN_SERVERS_XML")
        If(Err.Number)Then
            EventArg.Error.Save Err
            Service.Log EventArg.Error.ToString,eLOG_ERROR
        Else
            SetAsPrimary = UsePaymentServer
        End If
        On Error Goto 0      
    End If

END FUNCTION
%>

