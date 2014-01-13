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
' NAME        : PaymentServerLib.asp
' DESCRIPTION	: Functions shared by payment server dialogs
' AUTHOR	    : Kevin Boucher
' VERSION	    :
'
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION		: UsePaymentServer()
'
' DESCRIPTION	: Sets the account and UI preferred method to use payment server
' PARAMETERS	:
' RETURNS		  : TRUE if ok
PUBLIC FUNCTION UsePaymentServer

  UsePaymentServer = TRUE

  ' code to set payment method as credit or ach    
  If Session("bPaperInvoiceIsDefault") Then  
    MAM().Subscriber("PaymentMethod") = CREDITORACH

    ' Call Function to Meter account creation to update payment method  
    If( Not UpdateAccountCreation(EventArg,MAM().Subscriber, "Account")) then
      UsePaymentServer = FALSE
      MAM().Subscriber("PaymentMethod") = CASHORCHECK 'reset UI on failure
      Exit Function
    Else
      Session("bPaperInvoiceIsDefault") = False
    End If
  End If
  
END FUNCTION            
            
%>            