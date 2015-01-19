 <% 
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile: BatchManagement.List.asp$
' 
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
'  Created by: Rudi
' 
'  $Date: 11/13/2002 5:53:18 PM$
'  $Author: Rudi Perkins$
'  $Revision: 7$
'
' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
'
' CLASS       : 
' DESCRIPTION : 
' ---------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/mdm.asp"          -->
<!-- #INCLUDE VIRTUAL="/mdm/FrameWork/CFrameWork.Class.asp" -->
<!-- #INCLUDE FILE="../../default/lib/momLibrary.asp"                   -->
<!-- #INCLUDE VIRTUAL="/mdm/common/mdmList.Library.asp" -->
<%
Form.Version                    = MDM_VERSION     ' Set the dialog version - we are version 2.0.
Form.ErrorHandler               = TRUE  
Form.ShowExportIcon             = TRUE
'Form.Page.MaxRow                = CLng(FrameWork.GetDictionary("MAX_ROW_PER_LIST_PAGE"))
Form.Page.NoRecordUserMessage   = FrameWork.GetDictionary("PRODUCT_VIEW_BROWSER_NO_RECORDS_FOUND")

mdm_PVBrowserMain ' invoke the mdm framework

public iState

PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean

    Framework.AssertCourseCapability "Manage Batches", EventArg

    ProductView.Clear  ' Set all the property of the service to empty or to the default value
   	ProductView.Properties.ClearSelection
    ProductView.Properties.Flags = eMSIX_PROPERTIES_FLAG_PRODUCTVIEW

    'response.write(Service.Properties.ToString)
    'response.end
    Form("Filter")=request("Filter")
    Form("RerunId")=request("RerunId") 'Used only if we are showing the list of batches for a particular adapter run
    
    MDMListDialog.Initialize EventArg
    Form("NextPage")  = mom_GetDictionary("BATCH_MANAGEMENT_DIALOG")
    Form("LinkColumnMode")        = TRUE
    Form("IDColumnName")          = "BatchTableId"
    
	  Form_Initialize = true
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  Form_LoadProductView
' PARAMETERS:  EventArg
' DESCRIPTION: 
' RETURNS:  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_LoadProductView(EventArg) ' As Boolean

  Form_LoadProductView = FALSE
  
  dim rowset
  set rowset = server.CreateObject("MTSQLRowset.MTSQLRowset.1")
	rowset.Init "queries\mom"
  
  select case Form("Filter")
  case "Past24Hours"
    rowset.SetQueryTag("__GET_BATCH_MANANAGEMENT_LIST_LAST_24_HOURS__")
    mdm_GetDictionary().Add "INTERVAL_MANANAGEMENT_PAGE_TITLE", mdm_GetDictionary().Item("TEXT_INTERVAL_MANANAGEMENT_HARDCLOSED")
  case "Past7Days"    
    rowset.SetQueryTag("__GET_BATCH_MANANAGEMENT_LIST_LAST_7_DAYS__")
    mdm_GetDictionary().Add "INTERVAL_MANANAGEMENT_PAGE_TITLE", mdm_GetDictionary().Item("TEXT_INTERVAL_MANANAGEMENT_HARDCLOSED")
  case "ActiveFailed"
     rowset.SetQueryTag("__GET_BATCH_MANANAGEMENT_LIST_ACTIVE_FAILED__")
     mdm_GetDictionary().Add "INTERVAL_MANANAGEMENT_PAGE_TITLE", mdm_GetDictionary().Item("TEXT_INTERVAL_MANANAGEMENT_EXPIRED")
  case "Completed"
     rowset.SetQueryTag("__GET_BATCH_MANANAGEMENT_LIST_COMPLETED__")
     mdm_GetDictionary().Add "INTERVAL_MANANAGEMENT_PAGE_TITLE", mdm_GetDictionary().Item("TEXT_INTERVAL_MANANAGEMENT_EXPIRED")
  case "Dismissed"
     rowset.SetQueryTag("__GET_BATCH_MANANAGEMENT_LIST_DISMISSED__")
     mdm_GetDictionary().Add "INTERVAL_MANANAGEMENT_PAGE_TITLE", mdm_GetDictionary().Item("TEXT_INTERVAL_MANANAGEMENT_EXPIRED")
  case "Internal"
     rowset.SetQueryTag("__GET_BATCH_MANANAGEMENT_LIST_INTERNAL__")
     mdm_GetDictionary().Add "INTERVAL_MANANAGEMENT_PAGE_TITLE", mdm_GetDictionary().Item("TEXT_INTERVAL_MANANAGEMENT_EXPIRED")
  case "AdapterRun"
     rowset.SetQueryTag("__GET_BATCH_MANANAGEMENT_LIST_FOR_ADAPTER_RUN__")
     rowset.AddParam "%%ID_RUN%%", CLng(Form("RerunId"))
     mdm_GetDictionary().Add "INTERVAL_MANANAGEMENT_PAGE_TITLE", mdm_GetDictionary().Item("TEXT_INTERVAL_MANANAGEMENT_EXPIRED")
  case else
    rowset.SetQueryTag("__GET_BATCH_MANANAGEMENT_LIST__")
    mdm_GetDictionary().Add "INTERVAL_MANANAGEMENT_PAGE_TITLE", mdm_GetDictionary().Item("TEXT_INTERVAL_MANANAGEMENT")
  end select
            
	rowset.Execute

  
  ' Load a Rowset from a SQL Queries and build the properties collection of the product view based on the columns of the rowset
  Set ProductView.Properties.RowSet = rowset
  ProductView.Properties.AddPropertiesFromRowset rowset
  
  if false then
  ProductView.Properties.SelectAll
  else
  ProductView.Properties.ClearSelection ' Select the properties I want to print in the PV Browser Order
  
  dim i
  i = 1
  
  ProductView.Properties("Name").Selected          = i : i=i+1 
  ProductView.Properties("Status").Selected          = i : i=i+1
  ProductView.Properties("Namespace").Selected = i : i=i+1
  ProductView.Properties("Source").Selected       = i : i=i+1  
  ProductView.Properties("Sequence").Selected          = i : i=i+1
  ProductView.Properties("Completed").Selected          = i : i=i+1
  'ProductView.Properties("Successful").Selected          = i : i=i+1
  ProductView.Properties("Failed").Selected          = i : i=i+1
  ProductView.Properties("Dismissed").Selected          = i : i=i+1
  ProductView.Properties("Expected").Selected          = i : i=i+1
  ProductView.Properties("Creation").Selected          = i : i=i+1
  'ProductView.Properties("Recent").Selected          = i : i=i+1

  ProductView.Properties("Creation").Sorted               = MTSORT_ORDER_DESCENDING
  end if

  ProductView.Properties("Name").Caption            = mom_GetDictionary("TEXT_NAME")
  ProductView.Properties("Status").Caption          = mom_GetDictionary("TEXT_Status")
  ProductView.Properties("Namespace").Caption       = mom_GetDictionary("TEXT_NAMESPACE")
  ProductView.Properties("Source").Caption          = mom_GetDictionary("TEXT_Source")
  ProductView.Properties("Sequence").Caption        = mom_GetDictionary("TEXT_Sequence")
  ProductView.Properties("Completed").Caption       = mom_GetDictionary("TEXT_Completed")  
  ProductView.Properties("Failed").Caption          = mom_GetDictionary("TEXT_Failed")
  ProductView.Properties("Dismissed").Caption       = mom_GetDictionary("TEXT_Dismissed")
  ProductView.Properties("Expected").Caption        = mom_GetDictionary("TEXT_Expected")
  ProductView.Properties("Creation").Caption        = mom_GetDictionary("TEXT_Creation")  

  'ProductView.Properties.CancelLocalization

  mdm_SetMultiColumnFilteringMode TRUE  

 
  'Set Form.Grid.FilterProperty         = ProductView.Properties("UserName") ' Set the property on which to apply the filter  

  ' REQUIRED because we must generate the property type info in javascript. When the user change the property which he
  ' wants to use to do a filter we use the type of the property (JAVASCRIPT code) to show 2 textbox if it is a date
  ' else one.
  ProductView.LoadJavaScriptCode
        
  Form_LoadProductView                                  = TRUE ' Must Return TRUE To Render The Dialog
  
END FUNCTION


PRIVATE FUNCTION Form_DisplayCell(EventArg) ' As Boolean

    'EventArg.HTMLRendered     =  "<td class='" & Form.Grid.CellClass & "'>" & ProductView.Properties.RowSet.Value("State") & "</td>"

       if Form.Grid.Col<=3 then
          Form_DisplayCell = LinkColumnMode_DisplayCell(EventArg)
       else
         Select Case lcase(Form.Grid.SelectedProperty.Name)
         Case "status"
            dim strImage
            
            Select Case lcase(ProductView.Properties.RowSet.Value("status"))
            Case "completed"
              strImage= "../localized/en-us/images/batch_complete.gif"
              iState=0
            Case "failed"
              strImage= "../localized/en-us/images/batch_fail.gif"
              iState=1
            Case "active"
              strImage= "../localized/en-us/images/batch_active.gif"
              iState=2
            Case "dismissed"
              strImage= "../localized/en-us/images/batch_dismissed.gif"
              iState=2              
            Case "backed out"
              strImage= "../localized/en-us/images/batch_backedout.gif"
              iState=2              
            Case Else
              strImage= "../localized/en-us/images/batch.gif"
              iState=-1
            End Select
              
            
            dim strEditStateButton
            EventArg.HTMLRendered     =  "<td class='" & Form.Grid.CellClass & "'><table width='100%' border='0' cellspacing='0' cellpadding='0'><tr align='right'>"  & _
                  "<td align='left'><img src='" & strImage & "' align='absmiddle'>&nbsp;<nobr>" & mom_GetDictionary("TEXT_Completed") & "</nobr></td>" & _
                  "<td align='right'>" & strEditStateButton & "</td>" & _
                  "</tr></table></td>"
                  
                  ' Info for FredRunner Smoke Test                  
                  EventArg.HTMLRendered=EventArg.HTMLRendered & "<INPUT Name='[NAME].Completed' Type='Hidden' Value='[COMPLETED]'>"
                  EventArg.HTMLRendered=EventArg.HTMLRendered & "<INPUT Name='[NAME].Failed' Type='Hidden' Value='[FAILED]'>"
                  EventArg.HTMLRendered=PreProcess(EventArg.HTMLRendered,Array("NAME",ProductView.Properties.RowSet.Value("Name"),"COMPLETED",ProductView.Properties.RowSet.Value("Completed"),"FAILED",ProductView.Properties.RowSet.Value("Failed")))
  			    Form_DisplayCell = TRUE
         Case "failed"
           EventArg.HTMLRendered     =  "<td class='" & Form.Grid.CellClass & "' align='right'>"
           dim nFailedTransactions
           nFailedTransactions = ProductView.Properties.RowSet.Value("failed")
           if nFailedTransactions = 0 then
             EventArg.HTMLRendered = EventArg.HTMLRendered & nFailedTransactions
           else
             'EventArg.HTMLRendered = EventArg.HTMLRendered & "<A title=""Click To View List Of Failed Transactions For This Batch"" href=""javascript:void(0);"" onclick=""window.open('FailedTransaction.List.asp?BatchView_ID=" & Server.UrlEncode(ProductView.Properties.RowSet.Value("BatchId")) & "','', 'height=600,width=800, resizable=yes, scrollbars=yes, status=yes')"">" & nFailedTransactions & "</A>"
              EventArg.HTMLRendered = EventArg.HTMLRendered & "<A title="""& mom_GetDictionary("TEXT_Click_To_View") & """ href=""javascript:void(0);"" onclick=""window.open('/MetraNet/MetraControl/FailedTransactions/FailedTransactionViewFromBatch.aspx?Filter_FailedTransactionList_BatchId=" & Server.UrlEncode(ProductView.Properties.RowSet.Value("BatchId")) & "&PageTitle=" & Server.UrlEncode(mdm_GetDictionary().Item("TEXT_FAILED_TRANSACTIONS_FOR_BATCH") & " " & ProductView.Properties.RowSet.Value("BatchId")) & "','', 'height=600,width=800, resizable=yes, scrollbars=yes, status=yes')"">" & nFailedTransactions & "</A>"
			end if
           EventArg.HTMLRendered = EventArg.HTMLRendered & "</td>"

  			   Form_DisplayCell = TRUE
  			    
         Case "creation"
           dim creationDateTime
           dim dateTimeFormat

           creationDateTime = ProductView.Properties.RowSet.Value("Creation")
           dateTimeFormat = Framework.GetDictionary("DATE_TIME_FORMAT")

           EventArg.HTMLRendered     =  "<td class='" & Form.Grid.CellClass & "' align='left'>" & Framework.Format(creationDateTime, dateTimeFormat) & "</td>"

  		   Form_DisplayCell = TRUE

  	     Case else
            Form_DisplayCell = Inherited("Form_DisplayCell(EventArg)")
      End Select
     end if

    Form_DisplayCell = true

END FUNCTION



%>
