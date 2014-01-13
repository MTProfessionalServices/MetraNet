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
<!-- #INCLUDE FILE="../../default/lib/AdjustmentLib.asp" -->
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" -->
<%

Form.Version                      = MDM_VERSION     ' Set the dialog version
Form.Page.MaxRow                  = CLng(mam_GetDictionary("PV_ROW_PER_PAGE"))/2
Form.Page.NoRecordUserMessage     = mam_GetDictionary("PRODUCT_VIEW_BROWSER_NO_RECORDS_FOUND")
Form.RouteTo                      = mam_GetDictionary("WELCOME_DIALOG")

mdm_PVBrowserMain ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: Form_Initialize
' PARAMETERS	:
' DESCRIPTION :
' RETURNS		  : Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean

  	ProductView.Clear  ' Set all the property of the service to empty or to the default value
   	ProductView.Properties.ClearSelection
    ProductView.Properties.Flags = eMSIX_PROPERTIES_FLAG_PRODUCTVIEW

    Form.ShowExportIcon   = TRUE ' Export
    Form_Initialize       = TRUE
    
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  Form_LoadProductView
' PARAMETERS:  EventArg
' DESCRIPTION: 
' RETURNS:  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_LoadProductView(EventArg) ' As Boolean

  Dim i : i = 1  
  Dim objMamBill
  
  Form_LoadProductView = FALSE
    
  Set ProductView.Properties.RowSet = Session(SESSION_ADJUTSMENT_ROWSET)
  
  If IsValidObject(ProductView.Properties.RowSet) Then
      
      ProductView.Properties.SelectAll
      ProductView.Properties.ClearSelection
      
      ProductView.Properties("TimeStamp").Selected = i              : i=i+1
      ProductView.Properties("SessionID").Selected = i              : i=i+1
      ProductView.Properties("c_ConferenceName").Selected = i       : i=i+1  
      ProductView.Properties("c_ConferenceID").Selected = i         : i=i+1  
      ProductView.Properties("PayeeDisplayName").Selected = i       : i=i+1  
      ProductView.Properties("c_AccountingCode").Selected = i       : i=i+1  
      ProductView.Properties("c_ServiceLevel").Selected = i         : i=i+1  
      ProductView.Properties("c_ActualNumConnections").Selected = i : i=i+1  
      ProductView.Properties("Amount").Selected = i                 : i=i+1  
      
      ProductView.Properties("Amount").Format                    = mam_GetDictionary("AMOUNT_FORMAT")
      ProductView.Properties("Amount").Alignment                 = "right"
    
      ProductView.Properties("TimeStamp").Format 			           = mam_GetDictionary("DATE_TIME_FORMAT")
      ProductView.Properties("TimeStamp").Sorted                 = MTSORT_ORDER_DECENDING  ' Sort
             
      Service.Properties.TimeZoneId                              = MAM().CSR("TimeZoneId") ' Set the TimeZone, so the dates will be printed for the CSR time zone
      Service.Properties.DayLightSaving                          = mam_GetDictionary("DAY_LIGHT_SAVING")
      
      Form.Grid.SelectRowMode  = true ' Turn On The MDM Selected Row Mode
      Set Form.Grid.PropertyID = ProductView.Properties("SessionID")
          
      mdm_SetMultiColumnFilteringMode TRUE
        
      ' REQUIRED because we must generate the property type info in javascript. When the user change the property which he
      ' wants to use to do a filter we use the type of the property (JAVASCRIPT code) to show 2 textbox if it is a date
      ' else one.
      ProductView.LoadJavaScriptCode
        
      Form_LoadProductView = TRUE 
  End If          
END FUNCTION



%>


