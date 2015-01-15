 <% 
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile: IntervalManagement.RunHistory.List.asp$
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
'  $Date: 11/14/2002 12:13:29 PM$
'  $Author: Rudi Perkins$
'  $Revision: 3$
'
' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
'
' CLASS       : 
' DESCRIPTION : 
' ---------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/mdm.asp" -->
<!-- #INCLUDE FILE="../../default/lib/momLibrary.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/FrameWork/CFrameWork.Class.asp" -->
<%
Form.Version                    = MDM_VERSION     ' Set the dialog version - we are version 2.0.
Form.ErrorHandler               = FALSE  
Form.ShowExportIcon             = TRUE
Form.Page.MaxRow                = CLng(mom_GetDictionary("PV_ROW_PER_PAGE"))
Form.Page.NoRecordUserMessage   = mom_GetDictionary("PRODUCT_VIEW_BROWSER_NO_RECORDS_FOUND")

mdm_PVBrowserMain ' invoke the mdm framework

PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean
    'BreadCrumb.SetCrumb mom_GetDictionary("TEXT_VIEW_AUDIT_LOG")
    ProductView.Clear  ' Set all the property of the service to empty or to the default value
   	ProductView.Properties.ClearSelection
    ProductView.Properties.Flags = eMSIX_PROPERTIES_FLAG_PRODUCTVIEW

    'response.write(Service.Properties.ToString)
    'response.end
    Form("RunId")=request("RunId")
	Form("IntervalId")=request("IntervalId")
	Form("BillingGroupId")=request("BillingGroupId")
	
    Form("AdapterName") = request("AdapterName")
    
	  Form_Initialize = true
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  Form_LoadProductView
' PARAMETERS:  EventArg
' DESCRIPTION: 
' RETURNS:  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_LoadProductView(EventArg) ' As Boolean

  Form_LoadProductView = FALSE
  
  if false then 
  dim objUSMInstances
	set objUSMInstances = CreateObject("MetraTech.UsageServer.RecurringEventInstanceFilter")
  objUSMInstances.UsageIntervalID = Clng(Form("IntervalId"))
  set rowset = objUSMInstances.GetEndOfPeriodRowset(true, true)    
  end if
  
  dim idRun
  idRun = Form("RunId")
  
  dim rowset, sQuery
  set rowset = server.CreateObject("MTSQLRowset.MTSQLRowset.1")
  rowset.Init "queries\mom"
  
  rowset.SetQueryTag("__GET_ADAPTER_RUN_DETAILS__")  
  rowset.AddParam "%%ID_RUN%%", Clng(idRun)
	rowset.Execute
  
  
  ' Load a Rowset from a SQL Queries and build the properties collection of the product view based on the columns of the rowset
  Set ProductView.Properties.RowSet = rowset
  ProductView.Properties.AddPropertiesFromRowset ProductView.Properties.RowSet
  ProductView.Properties.SelectAll

  ProductView.Properties("DetailType").Caption = mom_GetDictionary("TEXT_DETAIL_TYPE")
  ProductView.Properties("Detail").Caption = mom_GetDictionary("TEXT_DETAIL")
  ProductView.Properties("Timestamp").Caption = mom_GetDictionary("TEXT_TIMESTAMP")

  Service.Properties.Add "RunId", "int32", 0, False, 0, eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET
  Service.Properties("RunId").Value=idRun
  
  Service.Properties.Add "AdapterName", "string", 1024, False, 0, eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET
  Service.Properties.Add "Type", "string", 255, False, 0, eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET
  Service.Properties.Add "Status", "string", 255, False, 0, eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET
  Service.Properties.Add "StartDateTime"      , MSIXDEF_TYPE_TIMESTAMP, 0, TRUE, Empty, eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET
  Service.Properties.Add "EndDateTime"      , MSIXDEF_TYPE_TIMESTAMP, 0, TRUE, Empty, eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET
  Service.Properties.Add "SummaryDetails", "string", 2048, False, 0, eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET
  Service.Properties.Add "Machine", "string", 256, False, 0, eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET
  Service.Properties.Add "BatchCount", "int32", 0, False, 0, eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET
  Service.Properties.Add "BatchCountMessage", "string", 0, False, 0, eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET

  
  dim rowset2
  set rowset2 = server.CreateObject("MTSQLRowset.MTSQLRowset.1")
  rowset2.Init "queries\mom"
  rowset2.SetQueryTag("__GET_ADAPTER_RUN_INFORMATION__")
  rowset2.AddParam "%%ID_RUN%%", Clng(idRun)  
	rowset2.Execute
  
  Service.Properties("AdapterName").Value=Form("AdapterName")
  Service.Properties("Type").Value=rowset2.value("Type")
  Service.Properties("StartDateTime").Value=rowset2.value("Start")
  Service.Properties("EndDateTime").Value=rowset2.value("End")
  Service.Properties("Status").Value=rowset2.value("Status")
  
  Service.Properties("SummaryDetails").Value=rowset2.value("Details") 
  Service.Properties("Machine").Value=rowset2.value("Machine")
  Service.Properties("BatchCount").Value=rowset2.value("BatchCount")

  if CLng(Service.Properties("BatchCount").Value)>0 Then
    dim sTemp
    sTemp="<br><a href=""javascript:void(0)"" onclick=""window.open('BatchManagement.List.asp?Filter=AdapterRun&RerunId=" & idRun & "','', 'height=600,width=800, resizable=yes, scrollbars=yes, status=yes')"">View Details Of The Batches For This Run Of The Adapter</a>"
    if Service.Properties("Status").Value = "Failed" then
      sTemp = sTemp & "<br><a href=""javascript:void(0)"" onclick=""window.open('AdapterManagement.RunDetails.FailedAccount.List.asp?BillingGroupID=" & CLng(Form("BillingGroupId")) & "&IntervalID=" & Clng(Form("IntervalId")) & "&PopulateFromAdapterRun=" & idRun & "','', 'height=600,width=800, resizable=yes, scrollbars=yes, status=yes')"">View List Of Accounts That Had Failures</a>"
    end if
    Service.Properties("BatchCountMessage").Value = sTemp
  Else
    Service.Properties("BatchCountMessage").Value=""
  End If
  
  ' REQUIRED because we must generate the property type info in javascript. When the user change the property which he
  ' wants to use to do a filter we use the type of the property (JAVASCRIPT code) to show 2 textbox if it is a date
  ' else one.
  ProductView.LoadJavaScriptCode
  
'  ProductView.Properties.CancelLocalization
  
  Form_LoadProductView = TRUE ' Must Return TRUE To Render The Dialog
  
END FUNCTION

PRIVATE FUNCTION Form_DisplayCell(EventArg) ' As Boolean

       if Form.Grid.Col<=2 then
          if Form.Grid.Col=2 then
            EventArg.HTMLRendered     =  "<td class='" & Form.Grid.CellClass & "' nowrap>&nbsp;</td>"
          else
            Form_DisplayCell = Inherited("Form_DisplayCell(EventArg)") 
          end if
       else
         Select Case lcase(Form.Grid.SelectedProperty.Name)
         Case "detailtype"
            dim strDetailType
            strDetailType = ProductView.Properties.RowSet.Value("detailtype")
            if lcase(strDetailType)="warning" then
              strDetailType = "<img src='../localized/en-us/images/errorsmall.gif' align='absmiddle' border='0'>&nbsp;" & strDetailType 
            else
              strDetailType = "<img src='../localized/en-us/images/infosmall.gif' align='absmiddle' border='0'>&nbsp;" & strDetailType               
            end if
            
            EventArg.HTMLRendered     =  "<td class='" & Form.Grid.CellClass & "'>"  & strDetailType & "</td>" 
            
  			    Form_DisplayCell = TRUE
         Case "timestamp"
            EventArg.HTMLRendered     =  "<td class='" & Form.Grid.CellClass & "'>"  & mdm_Format(ProductView.Properties.RowSet.Value("timestamp"),mom_GetDictionary("DATE_TIME_FORMAT")) & "</td>"
            Form_DisplayCell = TRUE
  	     Case else
            Form_DisplayCell = Inherited("Form_DisplayCell(EventArg)")
      End Select
     end if

    Form_DisplayCell = true

END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :  inheritedForm_DisplayEndOfPage
' PARAMETERS    :  EventArg
' DESCRIPTION   :  Override end of table to place add button
' RETURNS       :  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_DisplayEndOfPage(EventArg) ' As Boolean

    Dim strEndOfPageHTMLCode, strTmp
    
    
    strTmp = "</table><div align=center><BR><BR><button  onclick='mdm_RefreshDialog(this); return false;' name='refresh' Class='clsOkButton'>[TEXT_REFRESH]</button><button  name='CLOSE' Class='clsOkButton' onclick='window.close(); return false;'>[TEXT_CLOSE]</button>" & vbNewLine
    strEndOfPageHTMLCode = strEndOfPageHTMLCode & strTmp
        
    strEndOfPageHTMLCode = strEndOfPageHTMLCode & "</FORM>"
    
    ' Here we must not forget to concat rather than set because we want to keep the result of the inherited event.
    EventArg.HTMLRendered = EventArg.HTMLRendered & REPLACE(strEndOfPageHTMLCode,"[LOCALIZED_IMAGE_PATH]",mom_GetLocalizeImagePath())
    
    Form_DisplayEndOfPage = TRUE
END FUNCTION

FUNCTION Refresh_Click(EventArg) ' As Boolean
  Refresh_Click=true
END FUNCTION


%>
