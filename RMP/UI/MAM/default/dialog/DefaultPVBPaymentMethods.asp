<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
<% 
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile: DefaultPVBPaymentMethods.asp$
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
'  $Date: 04/16/2002 5:37:27 PM$
'  $Author: Kevin Boucher$
'  $Revision: 36$
' ---------------------------------------------------------------------------------------------------------------------------------------
Option Explicit

%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../../MamIncludeMDM.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MamLibrary.asp" -->
<!-- #INCLUDE FILE="../../default/lib/AccountLib.asp" -->
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" --> 
<%
Form.ServiceMsixdefFileName = mam_GetMAMFolder() & "\default\class\PaymentMethods.mdmdlg"
Form.Page.MaxRow                = CLng(mam_GetDictionary("PV_ROW_PER_PAGE"))
Form.RouteTo			              = mam_GetDictionary("WELCOME_DIALOG")
Form.Page.NoRecordUserMessage   = mam_GetDictionary("PRODUCT_VIEW_BROWSER_NO_RECORDS_FOUND")
'Form.Localize                   = FALSE
mdm_PVBrowserMain ' invoke the mdm framework

'------------------------------------
' Constants for column headers
'------------------------------------
CONST ID_ACTION_ICONS     = 1
CONST ID_TURNDOWN         = 2
CONST ID_PREFERED_PAYMENT = 3
CONST ID_PAYMENT_TYPE     = 4
CONST ID_BANK             = 5
CONST ID_ACCOUNT_TYPE     = 6
CONST ID_ACCOUNT_NUMBER   = 7 
CONST ID_EXPIRATION       = 8
CONST ID_ROUTING_NUMBER   = 9
'CONST ID_STATUS           = 9

'------------------------------------
' Constants for Credit Card graphics
' g. cieplik 12/12/07 added new credit card type of MAESTRO
'------------------------------------
CONST ID_VISA                                = "1"
CONST ID_MASTERCARD                          = "2"
CONST ID_AMERICAN_EXPRESS                    = "3"
CONST ID_DISCOVER                            = "4"
CONST ID_JCB                                 = "5"
CONST ID_DINERS_CLUB                         = "6" 
CONST ID_PURCHASE_CARD_START                 = "7"
CONST ID_VISA_PURCHASE_CARD                  = "7"
CONST ID_MASTERCARD_PURCHASE_CARD            = "8"
CONST ID_AMERICAN_EXPRESS_PURCHASE_CARD      = "9"
CONST ID_VISA_PURCHASE_CARD_INTL             = "10"
CONST ID_MASTERCARD_PURCHASE_CARD_INTL       = "11"
CONST ID_AMERICAN_EXPRESS_PURCHASE_CARD_INTL = "12"
CONST ID_MAESTRO                             = "13"


'----------------------------------------------
' Constants for access into the merged rowset
'----------------------------------------------
CONST ID_ACCOUNT_TYPE_ROWSET   = 3
CONST ID_ACCOUNT_NUMBER_ROWSET = 4
'CONST ID_ACCOUNT_STATUS_ROWSET = 6
CONST ID_ROUTING_NUMBER_ROWSET = 7

'----------------------------------------------
' Constants for comparisons for custom actions
'----------------------------------------------
CONST ID_PAPER_INVOICE = "Paper Invoice"
CONST ID_CREDIT_CARD   = "Credit Card"
CONST ID_ACH           = "ACH"

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION   :  Form_Initialize
' PARAMETERS :  EventArg
' DESCRIPTION:
' RETURNS    :  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean

	ProductView.Clear  ' Set all the property of the service to empty or to the default value
	ProductView.Properties.ClearSelection
  ProductView.Properties.Flags = eMSIX_PROPERTIES_FLAG_PRODUCTVIEW

  ' Select the properties I want to print in the PV Browser   Order  
  ProductView.Properties("Default_Payment").Selected           = 1
	ProductView.Properties("Payment_Type").Selected 	           = 2
	ProductView.Properties("Bank").Selected 	                   = 3
  ProductView.Properties("Account_Type").Selected              = 4
  ProductView.Properties("Account_Number").Selected 	         = 5
  ProductView.Properties("Expiration").Selected 	             = 6
  ProductView.Properties("Routing_Number").Selected            = 7
 ' ProductView.Properties("Status").Selected 	                 = 7
 
  ' Localize Headers
  ProductView.Properties("Default_Payment").Caption            = mam_GetDictionary("TEXT_DEFAULT_PAYMENT") 
	ProductView.Properties("Payment_Type").Caption 	             = mam_GetDictionary("TEXT_PAYMENT_TYPE") 
	ProductView.Properties("Bank").Caption 	                     = mam_GetDictionary("TEXT_BANK") 
  ProductView.Properties("Account_Type").Caption               = mam_GetDictionary("TEXT_ACCOUNT_TYPE") 
  ProductView.Properties("Account_Number").Caption 	           = mam_GetDictionary("TEXT_ACCOUNT_NUMBER") 
  ProductView.Properties("Expiration").Caption 	               = mam_GetDictionary("TEXT_EXPIRATION") 
  ProductView.Properties("Routing_Number").Caption 	           = mam_GetDictionary("TEXT_ROUTING_NUMBER") 
  
  ProductView.Properties("Status").Caption 	                   = "not used" 'prevent localizatioin error
      
	Form_Initialize = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  Form_LoadProductView
' PARAMETERS:  EventArg
' DESCRIPTION: 
' RETURNS:  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_LoadProductView(EventArg) ' As Boolean
  Dim CreditRowset
  Dim ACHRowset
  Dim Rowset
  Dim rcd
  Dim PS
  Dim i 
  
  On Error Resume Next
  
  set PS = CreateObject("MTPaymentServerHelper.PaymentServer")
   
  '--------------------------------------------------------------------------------------- 
  ' load list of payment methods
  '---------------------------------------------------------------------------------------
  set CreditRowset = PS.GetPaymentServerRowset("__SELECT_ALL_CC_PAYMENT_METHODS__",  MAM().Subscriber("_AccountId"), "paymentsvr")
  
  if err then
    Call EventArg.error.Save(Err)
    Call Err.Clear()  
    Form_LoadProductView = false
  	Form_DisplayErrorMessage EventArg
   	Response.End
  end if

  
  set ACHRowset    = PS.GetPaymentServerRowset("__SELECT_ALL_ACH_PAYMENT_METHODS__", MAM().Subscriber("_AccountId"))
  
  if err then
    Call EventArg.error.Save(Err)
    Call Err.Clear()  
    Form_LoadProductView = false
  	Form_DisplayErrorMessage EventArg
   	Response.End
  end if
  
  '
  ' We detect that the 2 recordset are valid by testing that they have at least one columns...
  '  
  If (CreditRowset.Count=0)Or(ACHRowset.Count=0) Then
  
      If (CreditRowset.Count=0)  Then
      	  	EventArg.Error.Description = FrameWork.GetHTMLDictionaryError("MAM_ERROR_1023")
        	EventArg.Error.Number = 1023
      Else
        	EventArg.Error.Description = FrameWork.GetHTMLDictionaryError("MAM_ERROR_1024")
        	EventArg.Error.Number = 1024
      End If
    	Form_DisplayErrorMessage EventArg
    	Response.End
  End If
  
  
  ' Get merged rowset
  set Rowset = PS.JoinPaymentServerRowsets(mam_GetMAMFolder() & "\default\class\PaymentMethods.mdmdlg", CreditRowset, ACHRowset)
  
  ' Get correct enum values
  ' OLD CODE:  set Rowset = PS.SetRowsetColumnEnumValueByID(Rowset, ID_ACCOUNT_TYPE_ROWSET)  
  
  ' support multiple databases
  set Rowset = PS.SetRowsetColumnEnumValueByFQN(Rowset, ID_ACCOUNT_TYPE_ROWSET)  
    
  ' set rowset
  set ProductView.Properties.RowSet = Rowset
  
  ' Get Subscriber Invoice Method
  If(MAM().Subscriber("PaymentMethod") = "2") Then         
    Session("bPaperInvoiceIsDefault") = True
  Else
    Session("bPaperInvoiceIsDefault") = False
  End If
  
  if err then
    Call EventArg.error.Save(Err)
    Call Err.Clear()  
    Form_LoadProductView = false
  	Form_DisplayErrorMessage EventArg
   	Response.End
  end if
   
  Form_LoadProductView = TRUE 

END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION   :  Form_DisplayHeaderCell
' PARAMETERS :
' DESCRIPTION: I implement this event so i can customize the 2 columns which
'              are is the turn down column! We do not want it so I make it small...
'              For the other colunms I call the inherited event!
' RETURNS    :  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_DisplayHeaderCell(EventArg) ' As Boolean
    
    Select Case Form.Grid.Col
        Case ID_ACTION_ICONS
            EventArg.HTMLRendered = EventArg.HTMLRendered & "<td width='50' class='TableHeader' nowrap>" & mam_GetDictionary("TEXT_ACTION_ICONS") & "</td>"
            Form_DisplayHeaderCell= TRUE
        Case ID_TURNDOWN
            EventArg.HTMLRendered = EventArg.HTMLRendered 
            Form_DisplayHeaderCell= TRUE

        Case Else        
            Form_DisplayHeaderCell  = inherited("Form_DisplayHeaderCell()")
    End Select    
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION   :  Form_DisplayCell
' PARAMETERS :  EventArg
' DESCRIPTION: I implement this event so i can customize the 1,2 columns which
'              are the action column and the turn down column (I do not want it), 
'              where i put my link! For the other colunms I call the inherited event!
' RETURNS    :  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_DisplayCell(EventArg) ' As Boolean

    Dim strSelectorHTMLCode
    Dim strMsgBox
    
    Select Case Form.Grid.Col

       Case ID_TURNDOWN       
         EventArg.HTMLRendered = Empty        
         EventArg.HTMLRendered = EventArg.HTMLRendered ' & "<td width=1></td>"
         Form_DisplayCell      = TRUE
          
       '---------------------------------------------------------------------------
       ' Action Icons
       '---------------------------------------------------------------------------
       Case ID_ACTION_ICONS
            EventArg.HTMLRendered = Empty        

            '---------------------------------------------------------------------------
            ' Based on the type of the current payment method build link
            ' to UPDATE ach, credit, purchase card,  or invoice
            '---------------------------------------------------------------------------

            '---------------------------------------------------------------------------                        
            ' CREDIT CARD
            '---------------------------------------------------------------------------            
            If 	ProductView.Properties("Payment_Type") = ID_CREDIT_CARD then
              If ( ProductView.Properties("Account_Type") >= ID_PURCHASE_CARD_START) then
                strSelectorHTMLCode = "<A HRef='" & mam_GetDictionary("UPDATE_PURCHASE_CARD_DIALOG") & GetParams & "'><img align='absmiddle' src='" & mam_GetImagesPath() &  "/edit.gif' Border='0'></A>"
                strSelectorHTMLCode = strSelectorHTMLCode & "&nbsp;&nbsp;&nbsp;"
              Else
                strSelectorHTMLCode = "<A HRef='" & mam_GetDictionary("UPDATE_CREDIT_CARD_DIALOG") & GetParams & "'><img align='absmiddle' src='" & mam_GetImagesPath() &  "/edit.gif' Border='0'></A>"
                strSelectorHTMLCode = strSelectorHTMLCode & "&nbsp;&nbsp;&nbsp;"
              End If
              
              
              ' Credit / Debit Account
              ' This functionality may be added in the future if you need to turn it on see development
              'If (UCase(mam_GetDictionary("CREDIT_DEBIT_DIRECTLY_ON")) = "TRUE") Then
              '  strSelectorHTMLCode = strSelectorHTMLCode  &  "<A HRef='" & mam_GetDictionary("CREDIT_CREDIT_CARD_DIALOG") & GetParams & "'><img src='" & mam_GetImagesPath() &  "/credit.jpg' Border='0'></A>"
              '  strSelectorHTMLCode = strSelectorHTMLCode & "&nbsp;&nbsp;&nbsp;"
              '
              '  strSelectorHTMLCode = strSelectorHTMLCode  &  "<A HRef='" & mam_GetDictionary("DEBIT_CREDIT_CARD_DIALOG") & GetParams & "'><img src='" & mam_GetImagesPath() &  "/debit.jpg' Border='0'></A>"
              '  strSelectorHTMLCode = strSelectorHTMLCode & "&nbsp;&nbsp;&nbsp;"
              'End If
              
              ' Allow delete if we are not the default payment method or if it is the only one left besides the paper invoice
              If  ((Not CBool(ProductView.Properties("Default_Payment"))) or (ProductView.Properties.RowSet.recordcount <= 2)) Then
                strMsgBox = Replace(mam_GetDictionary("TEXT_CONFIRM_DELETE_CREDIT_CARD"),"[DIGITS]",Service.Properties.RowSet.Value(ID_ACCOUNT_NUMBER_ROWSET))

                strSelectorHTMLCode = strSelectorHTMLCode & "<A href='Javascript:msgBox("""
                strSelectorHTMLCode = strSelectorHTMLCode & strMsgBox
                strSelectorHTMLCode = strSelectorHTMLCode & """,""" & mam_GetDictionary("DELETE_CREDIT_CARD_DIALOG") & "?lastfourdigits="
                strSelectorHTMLCode = strSelectorHTMLCode &  ProductView.Properties.RowSet.Value(ID_ACCOUNT_NUMBER_ROWSET)
                strSelectorHTMLCode = strSelectorHTMLCode &  "&creditcardtype=" & ProductView.Properties.RowSet.Value(ID_ACCOUNT_TYPE_ROWSET) & """);'>"
                strSelectorHTMLCode = strSelectorHTMLCode  &  "<img align='absmiddle' src='" & mam_GetImagesPath() &  "/delete.gif' Border='0'></A>"
              End If
              

              
            End If       
            
            '---------------------------------------------------------------------------            
            ' ACH
            '---------------------------------------------------------------------------            
            If 	ProductView.Properties("Payment_Type") = ID_ACH then
              strSelectorHTMLCode = "<A HRef='" & mam_GetDictionary("UPDATE_ACH_DIALOG") & GetParams  & "'><img align='absmiddle' src='" & mam_GetImagesPath() &  "/edit.gif' Border='0'></A>"
              strSelectorHTMLCode = strSelectorHTMLCode & "&nbsp;&nbsp;&nbsp;"
    
              ' Credit / Debit Account
              ' This functionality may be added in the future if you need to turn it on see development
              'If (UCase(mam_GetDictionary("CREDIT_DEBIT_DIRECTLY_ON")) = "TRUE") Then
              '  strSelectorHTMLCode = strSelectorHTMLCode  &  "<A HRef='" & mam_GetDictionary("CREDIT_ACH_DIALOG") & GetParams & "'><img src='" & mam_GetImagesPath() &  "/credit.jpg' Border='0'></A>"
              '  strSelectorHTMLCode = strSelectorHTMLCode & "&nbsp;&nbsp;&nbsp;"
              ' 
              '  strSelectorHTMLCode = strSelectorHTMLCode  &  "<A HRef='" & mam_GetDictionary("DEBIT_ACH_DIALOG") & GetParams & "'><img src='" & mam_GetImagesPath() &  "/debit.jpg' Border='0'></A>"
              '  strSelectorHTMLCode = strSelectorHTMLCode & "&nbsp;&nbsp;&nbsp;"
              'End If
                                
              ' Allow delete if we are not the default payment method or if it is the only one left besides the paper invoice
              If  ((Not CBool(ProductView.Properties("Default_Payment"))) or (ProductView.Properties.RowSet.recordcount <= 2)) Then
               strMsgBox = Replace(mam_GetDictionary("TEXT_CONFIRM_DELETE_ACH"),"[DIGITS]",Service.Properties.RowSet.Value(ID_ACCOUNT_NUMBER_ROWSET))

                strSelectorHTMLCode = strSelectorHTMLCode & "<A href='Javascript:msgBox("""
                strSelectorHTMLCode = strSelectorHTMLCode & strMsgBox
                strSelectorHTMLCode = strSelectorHTMLCode & """,""" & mam_GetDictionary("DELETE_ACH_DIALOG") & "?lastfourdigits="
                strSelectorHTMLCode = strSelectorHTMLCode &  ProductView.Properties.RowSet.Value(ID_ACCOUNT_NUMBER_ROWSET)
                strSelectorHTMLCode = strSelectorHTMLCode &  "&routingnumber=" & ProductView.Properties.RowSet.Value(ID_ROUTING_NUMBER_ROWSET)
                strSelectorHTMLCode = strSelectorHTMLCode &  "&bankaccounttype=" & ProductView.Properties.RowSet.Value(ID_ACCOUNT_TYPE_ROWSET) & """);'>"
                strSelectorHTMLCode = strSelectorHTMLCode  &  "<img align='absmiddle' src='" & mam_GetImagesPath() &  "/delete.gif' Border='0'></A>"
              End If
            End If       
            
            '---------------------------------------------------------------------------                        
            ' PAPER INVOICE
            '---------------------------------------------------------------------------            
            If 	ProductView.Properties("Payment_Type") = ID_PAPER_INVOICE then
              
              If ProductView.Properties.Rowset.RecordCount > 1 Then
                  If Session("bPaperInvoiceIsDefault")Then
                    strSelectorHTMLCode = "&nbsp;" 
                   Else
                    strSelectorHTMLCode = "<A HRef='" & mam_GetDictionary("UPDATE_PAPER_INVOICE_DIALOG")  & "'><img align='absmiddle' src='" & mam_GetImagesPath() &  "/edit.gif' Border='0'></A>"                
                  End If  
              Else
                  strSelectorHTMLCode = "&nbsp;" 

                  ' If there are no electronic payment methods force cash/check if we are not already
                  If Not Session("bPaperInvoiceIsDefault") Then
                    ' CR: 8688 - let the user know that they do not have a payment method setup
                    ' CR: 9652 - allow deleting last payment methodd
                    EventArg.Error.Description = FrameWork.GetHTMLDictionaryError("MAM_ERROR_1046")
                  	EventArg.Error.Number = 1046

                    'MAM().Subscriber.Flags = eMSIX_PROPERTIES_FLAG_SERVICE
                    MAM().Subscriber("PaymentMethod") = CASHORCHECK
                    'MAM().Subscriber.Flags = eMSIX_PROPERTIES_FLAG_PRODUCTVIEW
                    
                    ' Call Function to Meter account creation to update payment method  
                    If( Not UpdateAccountCreation(EventArg,MAM().Subscriber, "Account")) then
                      Form_DisplayCell = FALSE
                      Exit Function
                    Else
                      Session("bPaperInvoiceIsDefault") = True
                    End If
                  End If
                  
              End If
              strSelectorHTMLCode = strSelectorHTMLCode & "&nbsp;&nbsp;&nbsp;"
              
            End If       
            
            EventArg.HTMLRendered = EventArg.HTMLRendered & "<td class='" & Form.Grid.CellClass & "' nowrap>" & strSelectorHTMLCode & "</td>"
            
            Form_DisplayCell = TRUE

       '---------------------------------------------------------------------------
       ' Prefered Payment Method
       '---------------------------------------------------------------------------
       Case ID_PREFERED_PAYMENT
            '---------------------------------------------------------------------------
            ' Check to see if the current payment method is the default
            ' if it is display icon
            '---------------------------------------------------------------------------        
            EventArg.HTMLRendered = Empty        
            
            If (ProductView.Properties("Payment_Type") = ID_PAPER_INVOICE) then            
              If CBool(Session("bPaperInvoiceIsDefault")) then
                strSelectorHTMLCode = strSelectorHTMLCode & "<img align='absmiddle' src='" & mam_GetImagesPath() &  "/check.gif' Border='0'>" & mam_GetDictionary("TEXT_SELECTED")
              End If
            End If  
            
            If ((CBool(ProductView.Properties("Default_Payment")) and (not CBool(Session("bPaperInvoiceIsDefault"))))) then
              strSelectorHTMLCode = strSelectorHTMLCode & "<img align='absmiddle' src='" & mam_GetImagesPath() &  "/check.gif' Border='0'>" & mam_GetDictionary("TEXT_SELECTED")
            End If
              
            EventArg.HTMLRendered = EventArg.HTMLRendered & "<td class='" & Form.Grid.CellClass & "' nowrap>&nbsp;" & strSelectorHTMLCode & "</td>"
            Form_DisplayCell = TRUE

       '---------------------------------------------------------------------------
       ' Payment Type Cell
       '---------------------------------------------------------------------------
        case ID_PAYMENT_TYPE 

            If (ProductView.Properties("Payment_Type") = ID_PAPER_INVOICE) then
              strSelectorHTMLCode = strSelectorHTMLCode & mam_GetDictionary("TEXT_PAPER_INVOICE")
              
              EventArg.HTMLRendered = EventArg.HTMLRendered & "<td class='" & Form.Grid.CellClass & "'>" & strSelectorHTMLCode & "</td>"
              Form_DisplayCell = TRUE
            ElseIf ( ProductView.Properties("Account_Type") >= ID_PURCHASE_CARD_START) then
              strSelectorHTMLCode = strSelectorHTMLCode & mam_GetDictionary("TEXT_PURCHASE_CARD")
              
              EventArg.HTMLRendered = EventArg.HTMLRendered & "<td class='" & Form.Grid.CellClass & "'>" & strSelectorHTMLCode & "</td>"
              Form_DisplayCell = TRUE
            Else
              Form_DisplayCell =  Inherited("Form_DisplayCell()")
            End If
       
       '---------------------------------------------------------------------------
       ' Account Type Icon 
       ' g. cieplik 12/12/07 added ID_MAESTRO type Credit Card 
       '---------------------------------------------------------------------------
       case ID_ACCOUNT_TYPE

          If 	ProductView.Properties("Payment_Type") = ID_CREDIT_CARD then    
            ProductView.Properties("Account_Type").SetPropertyType "ENUM","metratech.com/paymentserver","CreditCardType"                           
            Select Case ProductView.Properties("Account_Type")
              Case ID_VISA, ID_VISA_PURCHASE_CARD, ID_VISA_PURCHASE_CARD_INTL
                strSelectorHTMLCode = strSelectorHTMLCode &  "<img align='absmiddle' src='" & mam_GetImagesPath() &  "/visa.gif' Border='0'>&nbsp;&nbsp;" & ProductView.Properties("Account_Type").LocalizedValue 
                EventArg.HTMLRendered = EventArg.HTMLRendered & "<td class='" & Form.Grid.CellClass & "'>" & strSelectorHTMLCode & "</td>"
                Form_DisplayCell = TRUE
            
              Case ID_MASTERCARD, ID_MASTERCARD_PURCHASE_CARD, ID_MASTERCARD_PURCHASE_CARD_INTL
                strSelectorHTMLCode = strSelectorHTMLCode &  "<img align='absmiddle' src='" & mam_GetImagesPath() &  "/mastercard.gif' Border='0'>&nbsp;&nbsp;" & ProductView.Properties("Account_Type").LocalizedValue
                EventArg.HTMLRendered = EventArg.HTMLRendered & "<td class='" & Form.Grid.CellClass & "'>" & strSelectorHTMLCode & "</td>"
                Form_DisplayCell = TRUE
            
              Case ID_AMERICAN_EXPRESS, ID_AMERICAN_EXPRESS_PURCHASE_CARD, ID_AMERICAN_EXPRESS_PURCHASE_CARD_INTL
                strSelectorHTMLCode = strSelectorHTMLCode &  "<img align='absmiddle' src='" & mam_GetImagesPath() &  "/americanexpress.gif' Border='0'>&nbsp;&nbsp;" & ProductView.Properties("Account_Type").LocalizedValue 
                EventArg.HTMLRendered = EventArg.HTMLRendered & "<td class='" & Form.Grid.CellClass & "'>" & strSelectorHTMLCode & "</td>"
                Form_DisplayCell = TRUE
  
              Case ID_DISCOVER  
                strSelectorHTMLCode = strSelectorHTMLCode &  "<img align='absmiddle' src='" & mam_GetImagesPath() &  "/discover.gif' Border='0'>&nbsp;&nbsp;" & ProductView.Properties("Account_Type").LocalizedValue
                EventArg.HTMLRendered = EventArg.HTMLRendered & "<td class='" & Form.Grid.CellClass & "'>" & strSelectorHTMLCode & "</td>"
                Form_DisplayCell = TRUE
    
              Case ID_JCB  
                strSelectorHTMLCode = strSelectorHTMLCode &  "<img align='absmiddle' src='" & mam_GetImagesPath() &  "/jcb.gif' Border='0'>&nbsp;&nbsp;" & ProductView.Properties("Account_Type").LocalizedValue 
                EventArg.HTMLRendered = EventArg.HTMLRendered & "<td class='" & Form.Grid.CellClass & "'>" & strSelectorHTMLCode & "</td>"
                Form_DisplayCell = TRUE  
    
              Case ID_DINERS_CLUB  
                strSelectorHTMLCode = strSelectorHTMLCode &  "<img align='absmiddle' src='" & mam_GetImagesPath() &  "/dinersclub.gif' Border='0'>&nbsp;&nbsp;" & ProductView.Properties("Account_Type").LocalizedValue
                EventArg.HTMLRendered = EventArg.HTMLRendered & "<td class='" & Form.Grid.CellClass & "'>" & strSelectorHTMLCode & "</td>"
                Form_DisplayCell = TRUE  

              Case ID_MAESTRO
                strSelectorHTMLCode = strSelectorHTMLCode &  "<img align='absmiddle' src='" & mam_GetImagesPath() &  "/Maestro.gif' Border='0'>&nbsp;&nbsp;" & ProductView.Properties("Account_Type").LocalizedValue
                EventArg.HTMLRendered = EventArg.HTMLRendered & "<td class='" & Form.Grid.CellClass & "'>" & strSelectorHTMLCode & "</td>"
                Form_DisplayCell = TRUE
           
              Case Else  

                Form_DisplayCell =  Inherited("Form_DisplayCell()")
            End Select
          End If              

          If 	ProductView.Properties("Payment_Type") = ID_ACH then      
                'switch to ach enum type 
                ProductView.Properties("Account_Type").SetPropertyType "ENUM","metratech.com/paymentserver","BankAccountType"                     
                strSelectorHTMLCode = strSelectorHTMLCode &  "<img align='absmiddle' src='" & mam_GetImagesPath() &  "/ach.gif' Border='0'>&nbsp;&nbsp;" & ProductView.Properties("Account_Type").LocalizedValue 
                EventArg.HTMLRendered = EventArg.HTMLRendered & "<td class='" & Form.Grid.CellClass & "'>" & strSelectorHTMLCode & "</td>"
                
                Form_DisplayCell = TRUE
 
          End If
          
          If ProductView.Properties("Payment_Type") = ID_PAPER_INVOICE then
                EventArg.HTMLRendered = EventArg.HTMLRendered & "<td class='" & Form.Grid.CellClass & "'>&nbsp;</td>"
                Form_DisplayCell = TRUE
'              Form_DisplayCell =  Inherited("Form_DisplayCell()")
          End if 
          
       '---------------------------------------------------------------------------
       ' Account number
       '---------------------------------------------------------------------------          
        case ID_ACCOUNT_NUMBER
              ' Handle this case so we can right align the account number
              strSelectorHTMLCode = strSelectorHTMLCode & ProductView.Properties("Account_Number")
              EventArg.HTMLRendered = EventArg.HTMLRendered & "<td class='" & Form.Grid.CellClass & "' align='right'>&nbsp;" & strSelectorHTMLCode & "</td>"
              Form_DisplayCell = TRUE
          
       '---------------------------------------------------------------------------
       ' Expiration Date (format)
       '---------------------------------------------------------------------------
        case ID_EXPIRATION 
            If (Len(ProductView.Properties("Expiration")) > 0) then
              strSelectorHTMLCode = strSelectorHTMLCode & Left(ProductView.Properties("Expiration"), 2) & "/" & Right(ProductView.Properties("Expiration"), 4)
              EventArg.HTMLRendered = EventArg.HTMLRendered & "<td class='" & Form.Grid.CellClass & "' align='right'>" & strSelectorHTMLCode & "</td>"
              Form_DisplayCell = TRUE
            Else
              Form_DisplayCell =  Inherited("Form_DisplayCell()")
            End If
       '---------------------------------------------------------------------------
       ' Routing Number
       '---------------------------------------------------------------------------
        case ID_ROUTING_NUMBER
          If (Len(ProductView.Properties("Routing_Number")) > 0) then
              strSelectorHTMLCode = strSelectorHTMLCode & ProductView.Properties("Routing_Number")
              EventArg.HTMLRendered = EventArg.HTMLRendered & "<td class='" & Form.Grid.CellClass & "' align='right'>" & strSelectorHTMLCode & "</td>"
              Form_DisplayCell = TRUE
          Else
              Form_DisplayCell =  Inherited("Form_DisplayCell()")
          End If
                        
        Case Else        
            ' Call the default implementation
            Form_DisplayCell =  Inherited("Form_DisplayCell()")
    End Select    
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION   :  GetParams
' PARAMETERS :  
' DESCRIPTION:  Creates querystring parameters for update
' RETURNS    :  Return querstring as string
PRIVATE FUNCTION GetParams
  GetParams = GetParams & "?" & "Default_Payment=" & server.URLEncode(ProductView.Properties("Default_Payment"))
  GetParams = GetParams & "&" & "Payment_Type=" & server.URLEncode(ProductView.Properties("Payment_Type"))
  GetParams = GetParams & "&" & "Bank=" & server.URLEncode("" & ProductView.Properties("Bank"))
  GetParams = GetParams & "&" & "Account_Type=" & server.URLEncode(ProductView.Properties("Account_Type"))
  GetParams = GetParams & "&" & "Account_Number=" & ProductView.Properties("Account_Number")
  GetParams = GetParams & "&" & "Routing_Number=" & ProductView.Properties("Routing_Number")
  GetParams = GetParams & "&" & "Expiration=" & ProductView.Properties("Expiration")
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION   :  inheritedForm_DisplayEndOfPage
' PARAMETERS :  EventArg
' DESCRIPTION:  Override end of table to place add button
' RETURNS    :  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_DisplayEndOfPage(EventArg) ' As Boolean

    dim strEndOfPageHTMLCode
    
    ' Call the inherited event so we close the ProductVIew Browser as it should be
    ' Becare full this function is setting     EventArg.HTMLRendered
    Inherited("Form_DisplayEndOfPage()")
    
    '  add some code at the end of the product view UI
        
    ' Place Add Credit card and ach buttons at the bottom of the page  
    strEndOfPageHTMLCode = "<br><div align='center'>"
    
    ' ADD CREDIT CARD 
    'strEndOfPageHTMLCode = strEndOfPageHTMLCode & "<A HRef='" & mam_GetDictionary("ADD_CREDIT_CARD_DIALOG") & "'><img src='" & mam_GetImagesPath() &  "/addcreditcard.gif' Border='0'></A>&nbsp;&nbsp;&nbsp;"
    strEndOfPageHTMLCode = strEndOfPageHTMLCode & "<button class='clsButtonLarge' name=""CREDIT"" onclick=""window.location.href='" & mam_GetDictionary("ADD_CREDIT_CARD_DIALOG") & "'"">" & mam_getDictionary("TEXT_ADD_CREDIT_CARD") & "</button>&nbsp;&nbsp;&nbsp;"

    ' ADD PURCHASE CARD 
  '  strEndOfPageHTMLCode = strEndOfPageHTMLCode & "<A HRef='" & mam_GetDictionary("ADD_PURCHASE_CARD_DIALOG") & "'><img src='" & mam_GetImagesPath() &  "/addpurchasecard.gif' Border='0'></A>&nbsp;&nbsp;&nbsp;"
    strEndOfPageHTMLCode = strEndOfPageHTMLCode & "<button class='clsButtonLarge' name=""PURCHASE"" onclick=""window.location.href='" & mam_GetDictionary("ADD_PURCHASE_CARD_DIALOG") & "'"">" & mam_getDictionary("TEXT_ADD_PURCHASE_CARD") & "</button>&nbsp;&nbsp;&nbsp;"    

    ' ADD ACH
 '   strEndOfPageHTMLCode = strEndOfPageHTMLCode & "<A HRef='" & mam_GetDictionary("ADD_ACH_DIALOG") & "'><img src='" & mam_GetImagesPath() &  "/addach.gif' Border='0'></A>&nbsp;&nbsp;&nbsp;"
    strEndOfPageHTMLCode = strEndOfPageHTMLCode & "<button class='clsButtonLarge' name=""ACH"" onclick=""window.location.href='" & mam_GetDictionary("ADD_ACH_DIALOG") & "'"">" & mam_getDictionary("TEXT_ADD_ACH") & "</button>&nbsp;&nbsp;&nbsp;"

    ' Scheduler
    If (UCase(mam_GetDictionary("PAYMENT_SCHEDULER_ON")) = "TRUE") Then
'      strEndOfPageHTMLCode = strEndOfPageHTMLCode & "<A HRef='" & mam_GetDictionary("PAYMENT_METHODS_SCHEDULER_DIALOG") & "'><img src='" & mam_GetImagesPath() &  "/scheduler.gif' Border='0'></A>&nbsp;&nbsp;&nbsp;"
      strEndOfPageHTMLCode = strEndOfPageHTMLCode & "<button class='clsButtonLarge' name=""SCHEDULER"" onclick=""window.location.href='" & mam_GetDictionary("PAYMENT_METHODS_SCHEDULER_DIALOG") & "'"">" & mam_getDictionary("TEXT_PAYMENT_METHODS_SCHEDULER") & "</button>&nbsp;&nbsp;&nbsp;"
    End If
    
    strEndOfPageHTMLCode =  strEndOfPageHTMLCode & "</div>"
        
    ' Here we must not forget to concat rather than set because we want to keep the result of the inherited event.
    EventArg.HTMLRendered = EventArg.HTMLRendered & strEndOfPageHTMLCode
    
    Form_DisplayEndOfPage = TRUE
END FUNCTION
%>
