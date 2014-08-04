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
' DIALOG	    : DefaultPVBCreditRequest.asp
' DESCRIPTION	:
'  For some historical reasons the property status and reason of the service AccountCreditRequest and AccountCredit,are NOT set as enum type in the service definition.
'  So the DataAccessor.GetProductView does not return the localization string. Plus the MDM localize enum type coming only from MTSQLRowSet
'  or MTSQLRowSetSimulator object. A DataAccessor returns ICOMProductView rowset object.
'  So it is not possible to display localization of the reason and the status in the Credit Request Product View Browser.
'  Once the service will be updated the localization will show up automatically...
'  Note : the Enum type and the localization already existing but they are not linked to the 2 services.
'  In the dialog DefaultDialogIssueCredit.asp and DefaultDialogIssueCreditFromRequest.asp we set the property as enum type
'  dynamically so we have the MDM combox box support (Localization and metering.)
'  Note : This will affect also MPS Credit Request Dialog and MPS Credit Product View Browser.
'  Because the MAM 1.3 supports only the english language, it is acceptable.
'
' AUTHOR	    : F.Torres.
' VERSION	    :
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
Form.ProductViewMsixdefFileName 	  =  "metratech.com\AccountCreditRequest.msixdef"
Form.RouteTo			                  =  mam_GetDictionary("WELCOME_DIALOG")
Form.Page.MaxRow                    =  CLng(mam_GetDictionary("PV_ROW_PER_PAGE"))
Form.Page.NoRecordUserMessage       =  mam_GetDictionary("PRODUCT_VIEW_BROWSER_NO_RECORDS_FOUND")
Form.ShowExportIcon                 =  TRUE

mdm_PVBrowserMain ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		  : Form_Initialize
' PARAMETERS	  :
' DESCRIPTION 	:
' RETURNS		  : Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean

    Form_Initialize = FALSE
   
	  ProductView.Clear  ' Set all the property of the service to empty or to the default value
    
    Service.Properties.TimeZoneId              = MAM().CSR("TimeZoneId")           ' Set the TimeZone, so the dates will be printed for the CSR time zone  
    Service.Properties.DayLightSaving          = mam_GetDictionary("DAY_LIGHT_SAVING")
    
    ProductView.Properties.Interval.DateFormat = mam_GetDictionary("DATE_FORMAT")  ' Set the date format into the Interval Id Combo Box
      
    ' Load the interval id rowset - The MDM PVBrowser
    If (Not ProductView.Properties.Interval.Load(GLOBAL_CSR_METERED_ACCOUNT_ID)) Then Exit Function
    
    ' Select the properties I want to print in the PV Browser   Order
	  ProductView.Properties.ClearSelection
    ProductView.Properties("TimeStamp").Selected 			      = 1
	  ProductView.Properties("SubscriberAccountID").Selected 	= 2
    ProductView.Properties("Description").Selected 		      = 3
    ProductView.Properties("Status").Selected 			        = 4
    ProductView.Properties("Currency").Selected 			      = 6
    ProductView.Properties("Amount").Selected 		          = 7
	  ProductView.Properties("CreditAmount").Selected 		    = 8
 
    ProductView.Properties("SubscriberAccountID").Caption 		   = mam_GetDictionary("TEXT_ACCOUNT_ID")
    
    ' Sort
    ProductView.Properties("Status").Sorted                  = MTSORT_ORDER_DECENDING
        
    ' Amount Format        
    ProductView.Properties("Amount").Format                  = mam_GetDictionary("AMOUNT_FORMAT")
    ProductView.Properties("CreditAmount").Format            = mam_GetDictionary("AMOUNT_FORMAT")
    
    ProductView.Properties("TimeStamp").Format 			         = mam_GetDictionary("DATE_TIME_FORMAT")
    
    ' Store an instance of the XService because the next dialog which
    ' is DefaultDialogIssueCreditFromRequest.tpl.asp will retreive it
    ' and free it at the end... 
    Set Session("ProductViewCreditRequests")                    = ProductView

    ProductView.RenderLocalizationMode = TRUE ' We want all the enum type value to be localized while the HTML Rendering Process

    Set Form("PreProcessor") = CreateObject(CPreProcessor) ' We need PreProcessor object

    ProductView.Properties.Interval.DisplayInvoiceNumber  = FALSE    

	  Form_Initialize = TRUE
END FUNCTION

PRIVATE FUNCTION Form_LoadProductView(EventArg) ' As Boolean
    
    Form_LoadProductView  = ProductView.Properties.Load()    
END FUNCTION

CONST HTML_LINK_EDIT = "<td class='[CLASS]' width=20><A HREF='[ASP_PAGE]?SessionId=[SESSIONID]&IntervalId=[INTERVALID]&AccountId=[ACCOUNTID]&Auto=[AUTO]'><img Alt='[ALT]' src='[IMAGE]' Border='0'></A></td>"

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: Form_DisplayCell
' PARAMETERS	:
' DESCRIPTION : I implement this event so i can customize the 1 col which
'               is the action column, where i put my link!
' RETURNS		  : Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_DisplayCell(EventArg) ' As Boolean

    Dim strSelectorHTMLCode
    Dim m_objPP
    Dim strAuto
    
    Select Case Form.Grid.Col
    
        Case 1
            
            'Set m_objPP = ProductView.Tools.Cache.GetObject(CPreProcessor)
            Set m_objPP = Form("PreProcessor")
          
            ' Get the MSIXProperty object
            
            m_objPP.Add "SESSIONID" , ProductView.Properties.RowSet.Value("SessionId")            ' Here this is the session id if the credit request
            m_objPP.Add "CLASS"     , Form.Grid.CellClass
            
            ' This is the interval id of the credit request
            m_objPP.Add "INTERVALID", ProductView.Properties.Interval.Id
            m_objPP.Add "ACCOUNTID" , ProductView.Properties.RowSet.Value("SubscriberAccountId")
        
            ' This is not a enum type yet that why i have the constante
            If(ProductView.Properties("Status") = eCREDIT_REQUEST_PENDING_STATUS)Then
            
                m_objPP.Add "IMAGE"       , Application("APP_HTTP_PATH") & "/default/localized/en-us/images/edit.gif"
                m_objPP.Add "ASP_PAGE"    , mam_GetDictionary("ISSUE_CREDIT_FROM_REQUEST")
                m_objPP.Add "ALT"         , mam_GetDictionary("TEXT_EDIT")
                EventArg.HTMLRendered   = m_objPP.Process(HTML_LINK_EDIT)                
            Else            
                If(ProductView.Tools.BooleanValue(strAuto))Then
                  
                      ' If the credit request was automatically approved it is not possible to retreive the credit
                      ' from the credit request; so in that case we do not add any link to the credit...
                      Form_DisplayCell =  inheritedForm_DisplayCell(EventArg)
                Else                                
                      m_objPP.Add "IMAGE"       , Application("APP_HTTP_PATH") & "/default/localized/en-us/images/view.gif"
                      m_objPP.Add "ASP_PAGE"    , mam_GetDictionary("VIEW_CREDIT_FROM_REQUEST")
                      m_objPP.Add "ALT"         , mam_GetDictionary("TEXT_VIEW")
                      EventArg.HTMLRendered   = m_objPP.Process(HTML_LINK_EDIT)
                End If
            End If
            Form_DisplayCell = TRUE

        Case ProductView.Properties("SubscriberAccountID").Selected + 2
        
              strSelectorHTMLCode = ProductView.Properties.RowSet.Value("SubscriberAccountId") & " - " & GetUserNameFromAccountID(ProductView.Properties.RowSet.Value("SubscriberAccountId"))
              EventArg.HTMLRendered = EventArg.HTMLRendered & "<td class='" & Form.Grid.CellClass & "'>" & strSelectorHTMLCode & "</td>"
              Form_DisplayCell = TRUE
             
        Case Else
        
           Form_DisplayCell =  Inherited("Form_DisplayCell()") ' Call the default implementation           
    End Select
END FUNCTION


%>
