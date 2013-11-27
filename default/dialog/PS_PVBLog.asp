<% 
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
'  Copyright 1998-2003 by MetraTech Corporation
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
' DIALOG	    : Payment Server Generic Product View Browser!
' DESCRIPTION	:
' AUTHOR	    : F.Torres
' VERSION	    :
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/mdm.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MoMLibrary.asp" -->
<%
Const CHECKBOX_PREFIX = "CHKTRANS"

Form.RouteTo			                  =  mdm_UIValueDefault("RouteTo",mom_GetDictionary("WELCOME_DIALOG"))
Form.Page.MaxRow                    =  mdm_UIValueDefault("MaxRowPerPage",CLng(mom_GetDictionary("PV_ROW_PER_PAGE")))
Form.ProductViewMsixdefFileName 	  =  mdm_UIValueDefault("ProductViewMSIXDefFile","")

mdm_PVBrowserMain ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: Form_Initialize
' PARAMETERS	:
' DESCRIPTION :
' RETURNS		  : Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean

    mdm_GetDictionary().Add "PVBGENERIC_TITLE", ProductView.Name
    
    Form("Status")                          =   mdm_UIValue("Status")
    Form("ShowButtonRetry")                 =   mdm_UIValueDefault("ShowButtonRetry"      ,FALSE)
    Form("booShowButtonInvestigate")        =   mdm_UIValueDefault("ShowButtonInvestigate",FALSE)
    Form("booShowButtonArchive")            =   mdm_UIValueDefault("ShowButtonArchive"    ,FALSE)
    Form("booShowButtonSelectAll")          =   mdm_UIValueDefault("ShowButtonSelectAll"  ,FALSE)
    Form("ShowCheckBox")                    =   Form("ShowButtonRetry")
    Form("SelectAll")                       =   FALSE
    
    ' Localize Date
    ProductView.Properties.TimeZoneId       = mom_GetCSRTimeZoneID()
    ProductView.Properties.DayLightSaving   = mom_GetDictionary("DAY_LIGHT_SAVING")

   
    If (Not ProductView.Properties.Interval.Load(GLOBAL_CSR_METERED_ACCOUNT_ID)) Then
        
        Exit Function
    End If
    Form_Initialize = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: Form_LoadProductView
' PARAMETERS	:
' DESCRIPTION : Act as a generic function!
' RETURNS		  : Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_LoadProductView(EventArg) ' As Boolean
       
  Dim strProcID, strDicEntryID 
  
  strProcID             = mdm_MakeID(ProductView.Name) & "_LoadProductView(EventArg)"
  Form_LoadProductView  = Eval(strProcID)
    
  If(ProductView.Properties.Exist("TimeStamp"))Then ' Set by default the sort on the TimeStamp if it exist
  
      ProductView.Properties("TimeStamp").Sorted = MTSORT_ORDER_DECENDING
  End If

 ProductView.Properties.Interval.DateFormat = mom_GetDictionary("DATE_FORMAT")  ' Set the date format into the Interval Id Combo Box
  
  strDicEntryId = "TEXT_SYSTEM_LOG_PS_" & mdm_MakeID(ProductView.Name) & "_TITLE"
  
  If(Form.Exist("Status"))Then
      mdm_GetDictionary().Add "PVBGENERIC_TITLE", mom_GetDictionary(strDicEntryId) & " " & Form("Status")
  Else  
      mdm_GetDictionary().Add "PVBGENERIC_TITLE", mom_GetDictionary(strDicEntryId)
  End If  
END FUNCTION

' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
'
'  Credit Card Section
'
' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
PRIVATE FUNCTION metratech_com_ps_cc_credit_LoadProductView(EventArg) ' As Boolean

    Dim i
    metratech_com_ps_cc_credit_LoadProductView  = FALSE
    
    If(ProductView.Properties.Load())Then
    
        ProductView.Properties.ClearSelection
        ProductView.Properties.SelectAll mom_GetDictionary("PS_metratech_com_ps_cc_credit_PROPERTY_LIST")
        metratech_com_ps_cc_credit_LoadProductView  = TRUE
    End If        
END FUNCTION

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
PRIVATE FUNCTION metratech_com_ps_cc_postauth_LoadProductView(EventArg) ' As Boolean
    Dim i
    metratech_com_ps_cc_postauth_LoadProductView  = FALSE
                                                 
    If(ProductView.Properties.Load())Then
    
        ProductView.Properties.ClearSelection
        ProductView.Properties.SelectAll mom_GetDictionary("PS_metratech_com_ps_cc_postauth_PROPERTY_LIST")
        metratech_com_ps_cc_postauth_LoadProductView  = TRUE
    End If    
END FUNCTION

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
PRIVATE FUNCTION metratech_com_ps_cc_preauth_LoadProductView(EventArg) ' As Boolean
    Dim i
    metratech_com_ps_cc_preauth_LoadProductView = FALSE
                                                 
    If(ProductView.Properties.Load())Then
    
        ProductView.Properties.ClearSelection
        ProductView.Properties.SelectAll mom_GetDictionary("PS_metratech_com_ps_cc_preauth_PROPERTY_LIST")
        metratech_com_ps_cc_preauth_LoadProductView = TRUE        
    End If    
END FUNCTION

' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
'
'  ACH Section
'
' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
PRIVATE FUNCTION metratech_com_ps_ach_prenote_LoadProductView(EventArg) ' As Boolean
    Dim i
    
    metratech_com_ps_ach_prenote_LoadProductView  = FALSE
    
    If(ProductView.Properties.Load())Then
    
        ProductView.Properties.ClearSelection                
        ProductView.Properties.SelectAll mom_GetDictionary("PS_metratech_com_ps_ach_prenote_PROPERTY_LIST")
        metratech_com_ps_ach_prenote_LoadProductView  = TRUE        
    End If        
END FUNCTION

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
PRIVATE FUNCTION metratech_com_ps_ach_credit_LoadProductView(EventArg) ' As Boolean
    Dim i
    metratech_com_ps_ach_credit_LoadProductView = FALSE

    If(ProductView.Properties.Load())Then
    
        ProductView.Properties.ClearSelection        
        ProductView.Properties.SelectAll mom_GetDictionary("PS_metratech_com_ps_ach_credit_PROPERTY_LIST")
        metratech_com_ps_ach_credit_LoadProductView= TRUE        
    End If
END FUNCTION

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
PRIVATE FUNCTION metratech_com_ps_ach_debit_LoadProductView(EventArg) ' As Boolean

    Dim i
    metratech_com_ps_ach_debit_LoadProductView = FALSE

    If(ProductView.Properties.Load())Then
    
        ProductView.Properties.ClearSelection
        ProductView.Properties.SelectAll mom_GetDictionary("PS_metratech_com_ps_ach_debit_PROPERTY_LIST")
        metratech_com_ps_ach_debit_LoadProductView = TRUE
    End If    
END FUNCTION

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
PRIVATE FUNCTION metratech_com_ps_paymentscheduler_LoadProductView(EventArg) ' As Boolean
    Dim i
    Dim lngStatusEnumTypeInternalDBID
    Dim strStatus
    
    metratech_com_ps_paymentscheduler_LoadProductView = FALSE
    
    strStatus = Form("Status")
    
    lngStatusEnumTypeInternalDBID = ProductView.Properties("CurrentStatus").EnumType.GetDatabaseInternalID(strStatus)

    If(ProductView.Properties.Load(," and c_currentstatus=" & lngStatusEnumTypeInternalDBID))Then
    
        ProductView.Properties.ClearSelection
        ProductView.Properties.SelectAll mom_GetDictionary("PS_metratech_com_ps_paymentscheduler_PROPERTY_LIST")
        metratech_com_ps_paymentscheduler_LoadProductView = TRUE
    End If    
END FUNCTION


'PRIVATE FUNCTION metratech_com_AccountCreditRequest_LoadProductView(EventArg) ' As Boolean
'
'    Dim i
'
'CONST PAYMENT_SERVER_CLIENT_RELATIVE_QUERIES_PATH       = "\paymentsvrclient\config\PaymentServer"
'CONST PAYMENT_SERVER_CLIENT_SERVER_NAME_IN_SERVERS_XML  = "paymentserver"
'CONST PAYMENT_SERVER_SERVER_VIRTUAL_DIRECTORY           = "paymentsvr"    
'
'    ' Load a Remote Product View - WE DO NOT SUPPORT GET REMOTE PRODUCT VIEW - But I keep the code.
'    'If(ProductView.Properties.Load(,, _
'    '                              eMSIX_PROPERTIES_LOAD_FLAG_LOAD_PRODUCT_VIEW +eMSIX_PROPERTIES_LOAD_FLAG_REMOTE_MODE, _ 
'    '                              PAYMENT_SERVER_CLIENT_RELATIVE_QUERIES_PATH, _
'    '                              PAYMENT_SERVER_SERVER_VIRTUAL_DIRECTORY, _
'    '                              PAYMENT_SERVER_CLIENT_SERVER_NAME_IN_SERVERS_XML _
'    '                              ))Then
'                                  
'    If(ProductView.Properties.Load())Then                                  
'    
'        ProductView.Properties.ClearSelection
'        ProductView.Properties.SelectAll
'    End If
'    metratech_com_AccountCreditRequest_LoadProductView  = TRUE
'END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :  Form_DisplayEndOfPage
' PARAMETERS    : 
' DESCRIPTION   : 
' RETURNS       :  
PRIVATE FUNCTION Form_DisplayEndOfPage(EventArg) ' As Boolean

    dim strEndOfPageHTMLCode
    
    ' Call the inherited event so we close the ProductVIew Browser as it should be
    ' Becare full this function is setting     EventArg.HTMLRendered
    ' Inherited("Form_DisplayEndOfPage()")
    
    '  add some code at the end of the product view UI
    strEndOfPageHTMLCode = "</TABLE><br>"
    
    ' Add button export and delete

    If(Form("booShowButtonSelectAll"))Then
    
      strEndOfPageHTMLCode = strEndOfPageHTMLCode & "<BUTTON Class='clsOkButton' onclick='mdm_RefreshDialog(this)' NAME='SELECTALL'>Select All</BUTTON>&nbsp;&nbsp;&nbsp;"
    End If
    
    If(Form("ShowButtonRetry"))Then
    
        strEndOfPageHTMLCode = strEndOfPageHTMLCode & "<BUTTON Class='clsOkButton' onclick='mdm_RefreshDialog(this)' NAME='RETRY'>Retry</BUTTON>&nbsp;&nbsp;&nbsp;"
    End If
    If(Form("booShowButtonInvestigate"))Then
    
        strEndOfPageHTMLCode = strEndOfPageHTMLCode & "<BUTTON Class='clsOkButton' onclick='mdm_RefreshDialog(this)' NAME='INVESTIGATE' >Investigate</BUTTON>&nbsp;&nbsp;&nbsp;"
    End If
    
    If(Form("booShowButtonArchive"))Then
    
        strEndOfPageHTMLCode = strEndOfPageHTMLCode & "<BUTTON Class='clsOkButton' onclick='mdm_RefreshDialog(this)' NAME='ARCHIVE' >Archive</BUTTON>&nbsp;&nbsp;&nbsp;"
    End If
           
    strEndOfPageHTMLCode = strEndOfPageHTMLCode & "</FORM>"
    
    ' Here we must not forget to concat rather than set because we want to keep the result of the inherited event.
    EventArg.HTMLRendered = EventArg.HTMLRendered &  REPLACE(strEndOfPageHTMLCode,"[LOCALIZED_IMAGE_PATH]",mom_GetLocalizeImagePath())
    
    Form_DisplayEndOfPage = TRUE
END FUNCTION

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
PRIVATE FUNCTION INVESTIGATE_Click(EventArg)
  
  INVESTIGATE_Click = PerformChangeStatusOnSelectedTransaction(EventArg,"Investigate")
END FUNCTION

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
PRIVATE FUNCTION ARCHIVE_Click(EventArg)

  ARCHIVE_Click = PerformChangeStatusOnSelectedTransaction(EventArg,"Archive")
  'ARCHIVE_Click = PerformChangeStatusOnSelectedTransaction(EventArg,"Failed")
END FUNCTION

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
PRIVATE FUNCTION RETRY_Click(EventArg)

  RETRY_Click = PerformChangeStatusOnSelectedTransaction(EventArg,"Retry")
END FUNCTION

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
PRIVATE FUNCTION SELECTALL_Click(EventArg)

    Form("SelectAll") = Not Form("SelectAll")
    SELECTALL_Click   = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :  Form_DisplayCell
' PARAMETERS    :  EventArg
' DESCRIPTION   :  
' RETURNS       :  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_DisplayCell(EventArg) ' As Boolean

    Dim strSelectorHTMLCode
    Dim objPreProcessor
    DIM strTemplateEdit   
    Dim strTemplateCheckBox
    
    Set objPreProcessor = mdm_CreateObject(CPreProcessor)
    
    strTemplateCheckBox = "<INPUT Type='CheckBox' [CHECKBOX_SELECTED] Name='" & CHECKBOX_PREFIX & "[PAYMENTSERVICETRANSACTIONID]:[ACCOUNTID]|[INTERVALID]'>"
    
    Select Case Form.Grid.Col
    
        Case 1
        
            If(Form("ShowCheckBox"))Then
            
                objPreProcessor.Add "CHECKBOX_SELECTED", IIF(Form("SelectAll"),"CHECKED","") ' Select All mode
                objPreProcessor.Add "PAYMENTSERVICETRANSACTIONID" , "" & ProductView("paymentservicetransactionid")
                objPreProcessor.Add "ACCOUNTID"                   , ProductView("originalaccountid")
            		objPreProcessor.Add "INTERVALID"                  , ProductView("originalintervalid")
                
                strSelectorHTMLCode   = objPreProcessor.Process(strTemplateEdit+strTemplateCheckBox)
                EventArg.HTMLRendered = "<TD Class='" & Form.Grid.CellClass & "'>" & strSelectorHTMLCode & "</TD>"
                Form_DisplayCell      = TRUE ' Cancel the turn down            
            Else                
            
                Form_DisplayCell =  Inherited("Form_DisplayCell()") ' Call the default implementation
            End If
            
        Case Else
            Form_DisplayCell =  Inherited("Form_DisplayCell()") ' Call the default implementation
    End Select    
END FUNCTION

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
PRIVATE FUNCTION PerformChangeStatusOnSelectedTransaction(EventArg,strNewStatus)
	Dim itm
	Dim strItm
  Dim objUIItems          ' AS CVariables
  Dim strPaymentServiceTransactionID
  Dim strS
  Dim lngDColonPos
  Dim lngAccountId
  Dim lngIntervalID 
  
  mdm_BuildQueryStringCollectionPlusFormCollection objUIItems

	For Each itm In objUIItems
  
  		strItm = UCase(itm.Name)
      
      If(Mid(strItm,1,Len(CHECKBOX_PREFIX))=CHECKBOX_PREFIX)Then ' We found a session to delete/Export     
          
          
          ' Retreive the TransactionID and the account id stored this way <INPUT Type='CheckBox'  Name='CHKTRANS21:769|1000'>          
          strS                            = Mid(itm.name,Len(CHECKBOX_PREFIX)+1)
          lngDColonPos                    = InStr(strS,":")
          strPaymentServiceTransactionID  = Mid(strS,1,lngDColonPos-1) ' Get the TransID

	        strS				                    = Mid(strS,lngDColonPos+1) ' Get the AccountId|IntervalId
          lngDColonPos                    = InStr(strS,"|")
      	  lngAccountID			              = Mid(strS,1,lngDColonPos-1) ' Get the Account id
      	  lngIntervalID			              = Mid(strS,lngDColonPos+1)   ' Get the IntervalId

          If(Not UpdateTransactionStatus (EventArg,strPaymentServiceTransactionID, strNewStatus, lngIntervalID, lngAccountId))Then
              
              strS = Replace(mom_GetDictionary("TEXT_SYSTEM_LOG_PS_ERROR_OCCUR_CHANGING_THE_STATUS"),"[TRANSACTIONID]",strPaymentServiceTransactionID)
              Response.Redirect mdm_MsgBoxOk(mom_GetDictionary("TEXT_SYSTEM_LOG_PS_ERROR"), strS, Request.ServerVariables("URL"),empty) ' As String
          End If
      End If
	Next
  Form("SelectAll") = FALSE
  PerformChangeStatusOnSelectedTransaction = TRUE
END FUNCTION


' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : UpdateTransactionStatus
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
PRIVATE FUNCTION UpdateTransactionStatus(EventArg,strPaymentServiceTransactionID,strStatus,lngIntervalID,lngAccountID) ' As Boolean
   
    ProductView.log "UPDATE ACH TRANS " & strPaymentServiceTransactionID & " " & strStatus & " " & lngIntervalID
    
    Dim objService
    Set objService = mdm_CreateObject(MSIXHandler)
    
    
    ' Read the service definition to get the property localization
    If(objService.Initialize("metratech.com\ps_updschpaymentstatus.msixdef",,MOM_LANGUAGE,,,mdm_InternalCache))Then
          
          objService("_IntervalID")                   = lngIntervalID ' We use the internal MDM Interval Id property
          objService("_AccountID")                    = lngAccountID ' We use the internal MDM Interval Id property
          objService("paymentservicetransactionid")   = strPaymentServiceTransactionID
          objService("status")                        = strStatus
          
          
          On Error Resume Next
          objService.Meter(TRUE)
          If(Err.Number=0)Then
              UpdateTransactionStatus = TRUE
          Else
              EventArg.Error.Save Err
              UpdateTransactionStatus = FALSE
          End If
    Else
          EventArg.Error.Description  = mom_GetDictionary("TEXT_TELL_USER_SYSTEM_ERROR_OCCUR_TRY_LATER")
          UpdateTransactionStatus     = FALSE
    End If
END FUNCTION
%>