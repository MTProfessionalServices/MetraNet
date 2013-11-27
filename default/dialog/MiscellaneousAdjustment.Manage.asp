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
' MetraTech Dialog Manager Framework ASP Dialog Template
'
' DIALOG	    :
' DESCRIPTION	:
' AUTHOR	    :
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

' The dialog requires to work under MDM 1.3 API
'Form.Version                      = MDM_VERSION     ' Set the dialog version

Form.Page.MaxRow                  = CLng(mam_GetDictionary("PV_ROW_PER_PAGE"))
Form.Page.NoRecordUserMessage     = mam_GetDictionary("PRODUCT_VIEW_BROWSER_NO_RECORDS_FOUND")
Form.RouteTo                      = mam_GetDictionary("WELCOME_DIALOG")
Form.ProductViewMsixdefFileName 	= "metratech.com\AccountCreditRequest.msixdef"

mdm_PVBrowserMain ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: Form_Initialize
' PARAMETERS	:
' DESCRIPTION :
' RETURNS		  : Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean

    Form("MaxAuthorizedAmount") = -1


  	ProductView.Clear ' Set all the property of the service to empty or to the default value
   	ProductView.Properties.ClearSelection
    ProductView.Properties.Flags = eMSIX_PROPERTIES_FLAG_PRODUCTVIEW
    
    ProductView.Properties.Selector.ColumnID        = "SessionID" ' Specify the column id to use as the select key
    ProductView.Properties.Selector.Clear
    
    Service.Properties.TimeZoneId              = MAM().CSR("TimeZoneId")           ' Set the TimeZone, so the dates will be printed for the CSR time zone  
    Service.Properties.DayLightSaving          = mam_GetDictionary("DAY_LIGHT_SAVING")
    
    ProductView.Properties.Interval.DateFormat = mam_GetDictionary("DATE_FORMAT")  ' Set the date format into the Interval Id Combo Box
      
    ' Load the interval id rowset - The MDM PVBrowser
    If (Not ProductView.Properties.Interval.Load(GLOBAL_CSR_METERED_ACCOUNT_ID)) Then Exit Function
    
    ProductView.RenderLocalizationMode = TRUE ' We want all the enum type value to be localized while the HTML Rendering Process

    ProductView.Properties.Interval.DisplayInvoiceNumber = FALSE

    Form.ShowExportIcon   = TRUE ' Export
    Form_Initialize       = TRUE   

END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  Form_LoadProductView
' PARAMETERS:  EventArg
' DESCRIPTION: 
' RETURNS:  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_LoadProductView(EventArg) ' As Boolean
    
    Dim i, objRowsetfilter, strSQLExtension
    Form_LoadProductView = FALSE

    strSQLExtension = " and c_Status = 'PENDING' "
    
    If Not ProductView.Properties.Load(,strSQLExtension) Then Exit Function 'Optional lngAccountID As Long, Optional ByVal strSQLExtensionOrQueryTag As String, Optional ByVal eFlags As eMSIX_PROPERTIES_LOAD_FLAG = eMSIX_PROPERTIES_LOAD_FLAG_LOAD_PRODUCT_VIEW, Optional ByVal strQueryTagRelativePathFromConfig As String, Optional ByVal strRemoteVirtualDirectory As String, Optional ByVal strRemoteServerName As String        
    
    ProductView.Properties.ClearSelection ' Select the properties I want to print in the PV Browser   Order

    i=1
    ProductView.Properties("TimeStamp").Selected 			      = i : i = i + 1
    ProductView.Properties("SubscriberAccountID").Selected 	= i : i = i + 1
    ProductView.Properties("Description").Selected 		      = i : i = i + 1
'    ProductView.Properties("Status").Selected 			        = i : i = i + 1
    ProductView.Properties("Currency").Selected 			      = i : i = i + 1
    ProductView.Properties("Amount").Selected 		          = i : i = i + 1
    ProductView.Properties("CreditAmount").Selected 		    = i : i = i + 1

    mdm_SetMultiColumnFilteringMode TRUE    
    ProductView.LoadJavaScriptCode    
    Form_LoadProductView = TRUE
END FUNCTION



PRIVATE FUNCTION Form_DisplayCell(EventArg) ' As Boolean

    DIM PreProcessor, HTML_LINK_EDIT, lngID
  
    Select Case Form.Grid.Col    
    
        Case 1
      
            Set PreProcessor = mdm_CreateObject(CPreProcessor)
        
            HTML_LINK_EDIT = HTML_LINK_EDIT & "<td class='[CLASS]'>"
            HTML_LINK_EDIT = HTML_LINK_EDIT & "<INPUT Type='CheckBox' [CHECKBOX_SELECTED] Name='" & MDM_PVB_CHECKBOX_PREFIX & "[SESSION_ID]'>"
            HTML_LINK_EDIT = HTML_LINK_EDIT & "</td>"
            
            PreProcessor.Clear
            lngID = ProductView.Properties.Rowset.Value("SessionID")
            PreProcessor.Add "SESSION_ID"         , lngID
            PreProcessor.Add "CHECKBOX_SELECTED"  , IIF(ProductView.Properties.Selector.IsItemSelected(lngID),"CHECKED","") ' Select All mode
            PreProcessor.Add "CLASS"              , Form.Grid.CellClass
            
            EventArg.HTMLRendered           = PreProcessor.Process(HTML_LINK_EDIT)
            Form_DisplayCell                = TRUE
            Exit Function
            
      Case 4
           EventArg.HTMLRendered = EventArg.HTMLRendered & "<td class='" & Form.Grid.CellClass & "'>" & mam_GetFieldIDFromAccountID(ProductView.Properties.RowSet.Value("SubscriberAccountId")) & "</td>"
           Form_DisplayCell = TRUE
           Exit Function
    End Select
    
    ' Default BeHavior
    Form_DisplayCell =  Inherited("Form_DisplayCell()") ' Call the default implementation
END FUNCTION

PUBLIC FUNCTION Form_DisplayEndOfPage(EventArg) ' As Boolean

    Dim strEndOfPageHTMLCode, strTmp
    
    Form_DisplayEndOfPageAddSelectButtons EventArg, "", FALSE ' No Javascript and do not close the tag form
    
    strTmp = "<BR><button  name='butApprove' Class='clsButtonBlueMedium' onclick='mdm_UpdateSelectedIDsAndReDrawDialog(this);'>" & FrameWork.Dictionary.Item("TEXT_APPROVE") & "</button>" & vbNewLine
    strEndOfPageHTMLCode = strEndOfPageHTMLCode & strTmp
    
    strTmp = "<button  name='butDelete' Class='clsButtonBlueMedium'  onclick='mdm_UpdateSelectedIDsAndReDrawDialog(this);'>" & FrameWork.Dictionary.Item("TEXT_DELETE") & "</button>" & vbNewLine
    strEndOfPageHTMLCode  = strEndOfPageHTMLCode & strTmp
        
    strEndOfPageHTMLCode  = strEndOfPageHTMLCode & "</FORM></BODY>"
     
    EventArg.HTMLRendered = EventArg.HTMLRendered & strEndOfPageHTMLCode
    
    Form_DisplayEndOfPage = TRUE
END FUNCTION

PRIVATE FUNCTION PerformActionOnSelectedSession(EventArg,strAction)

    Dim booNoActionTaken, objIDs, objID, lngErrorCount
    
    PerformActionOnSelectedSession = FALSE
    lngErrorCount = 0
    
    Form_ChangePage EventArg,0,0 ' We need to call the event our self here so we update the ProductView.Properties.Selector
  
    Set objIDs = ProductView.Properties.Selector.GetAllSelectedItemFromRowSet(ProductView.Properties.Rowset,"id_sess")
    
    If objIDs.Count=0 Then 
    
        EventArg.Error.Description = FrameWork.Dictionary.Item("MAM_ERROR_1047").Value
        EventArg.Error.Number      = 1047
        Exit Function
    End If
    
    For Each objID In objIDs
    
        If Not MeterCredit(EventArg,objID,strAction) Then
        
            lngErrorCount = lngErrorCount + 1
        End If
    Next
    If lngErrorCount Then
        ' TODO:
    End If
    ProductView.Properties.Selector.Clear ' We need to clear the selection else the selection remain active
END FUNCTION

PUBLIC FUNCTION MeterCredit(EventArg, objID, strAction)

    Dim CreditService, strServiceMsixDefFile
    
    MeterCredit = FALSE
    
    strServiceMsixDefFile = "metratech.com\AccountCredit.msixdef"
    
    Set CreditService = mdm_CreateServiceInstance(strServiceMsixDefFile,"")
    
    ' Find the record in the rowset
    If Not ProductView.Properties.Find("SessionID",objID) Then Exit Function
            
    CreditService.Properties("_Amount").Value 	            = ProductView.Properties("Amount").Value
    CreditService.Properties("InvoiceComment").Value 	      = ProductView.Properties("Description").Value
    CreditService.Properties("Reason").Value 	              = GetEnumValueFromLocalizedString(ProductView.Properties("Reason").Value,"metratech.com", "SubscriberCreditAccountRequestReason")
    CreditService.Properties("CreditTime").Value 	          = FrameWork.MetraTimeGMTNow()
    CreditService.Properties("_AccountID").Value 	          = ProductView.Properties("SubscriberAccountID").Value
    CreditService.Properties("_Currency").Value 	          = ProductView.Properties("Currency").Value
    CreditService.Properties("Issuer").Value 		            = MAM().CSR("_AccountId").Value
    CreditService.Properties("RequestID").Value             = objID ' this mean that the credit has credit request...
    CreditService.Properties("RequestAmount").Value 	      = CreditService.Properties("_Amount").Value
    CreditService.Properties("CreditAmount").Value 	        = CreditService.Properties("_Amount").Value
    CreditService.Properties("ContentionSessionID").Value   = "-"   ' Old stuff from 1.2
    CreditService.Properties("ReturnCode").Value            = 0     ' Old stuff from 1.2     
    CreditService.Properties("GuideIntervalID").value       = Service.Properties("GuideIntervalID").Value  
    
    mam_SetTemporaryEnumTypeForAccountCredit          ' Set the enum type on the fly while waiting for boris
    
    If strAction="APPROVE" Then
        CreditService.Properties("Status").Value = Service.Properties("Status").EnumType.Entries("Approved").Value
    Else
        CreditService.Properties("Status").Value = Service.Properties("Status").EnumType.Entries("Denied").Value
    End If
    
    On Error Resume Next
    CreditService.Meter TRUE
    
    If(Not CBool(Err.Number = 0)) then
        
        ' We not test when the csr does not have the Amount Capability
        EventArg.Error.Save Err          
        Exit Function        
    End If
    Err.Clear
    MeterCredit = TRUE
END FUNCTION

PRIVATE FUNCTION butApprove_Click(EventArg)
    butApprove_Click = PerformActionOnSelectedSession(EventArg,"APPROVE")
END FUNCTION

PRIVATE FUNCTION butDelete_Click(EventArg)
    butDelete_Click = PerformActionOnSelectedSession(EventArg,"DENIED")
END FUNCTION

FUNCTION GetEnumValueFromLocalizedString(sLocalizedName,sEnumspace, sEnumtype)

dim objLocaleTranslator
set objLocaleTranslator = server.CreateObject("MetraTech.COMLocaleTranslator.1")

objLocaleTranslator.Init "US"
objLocaleTranslator.LanguageCode = "US"

dim rowset
Set rowset = objLocaleTranslator.GetLocaleListForEnumTypes("US", sEnumspace, sEnumtype) ' get the localized strings

Do While Not rowset.EOF
  if rowset.value("localizedstring")=sLocalizedName then
    GetEnumValueFromLocalizedString = rowset.value("enumerator")
    exit do
  end if
  rowset.MoveNext
Loop

END FUNCTION
%>
