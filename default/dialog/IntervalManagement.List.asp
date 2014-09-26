 <% 
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile: IntervalManagement.List.asp$
' 
'  Copyright 1998-2005 by MetraTech Corporation
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
'  Created by: Rudi, Kevin
' ---------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!--METADATA TYPE="TypeLib" NAME="MetraTech.UsageServer.dll" UUID="{b6ad949f-25d4-4cd5-b765-3f6199ecc51c}" -->

<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/mdm.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/FrameWork/CFrameWork.Class.asp" -->
<!-- #INCLUDE FILE="../../default/lib/momLibrary.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/common/mdmList.Library.asp" -->
<!-- #INCLUDE FILE="../../default/lib/IntervalManagementLibrary.asp" -->
<%
Form.Version = MDM_VERSION   
Form.ErrorHandler = TRUE  
Form.ShowExportIcon = TRUE
Form.Page.NoRecordUserMessage = FrameWork.GetDictionary("PRODUCT_VIEW_BROWSER_NO_RECORDS_FOUND")

mdm_PVBrowserMain 

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:    Form_Initialize
' PARAMETERS:  EventArg
' DESCRIPTION: Initialize the form, set link mode, and check capabilities
' RETURNS:     Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean
Framework.AssertCourseCapability "Manage EOP Adapters", EventArg

    ProductView.Clear  
   	ProductView.Properties.ClearSelection
    ProductView.Properties.Flags = eMSIX_PROPERTIES_FLAG_PRODUCTVIEW

    MDMListDialog.Initialize EventArg
    Form("NextPage") = FrameWork.GetDictionary("INTERVAL_MANAGEMENT_SELECT_DIALOG")
    Form("LinkColumnMode") = TRUE
    Form("IDColumnName") = "IntervalID"
    Form("Intervals") = Request.QueryString("Intervals")
    
	  Form_Initialize = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:    Form_LoadProductView
' PARAMETERS:  EventArg
' DESCRIPTION: Loads the usage intervals rowset
' RETURNS:     Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_LoadProductView(EventArg) ' As Boolean
  Form_LoadProductView = FALSE
   
  Dim objUSM, objIntervals
  Set objUSM = mom_GetUsageServerClientObject()
  Set objIntervals = Server.CreateObject("MetraTech.UsageServer.UsageIntervalFilter")

  Select Case Form("Intervals")
    Case "Completed"
       objIntervals.Status = UsageIntervalStatus_Completed
       FrameWork.Dictionary().Add "INTERVAL_MANANAGEMENT_PAGE_TITLE", "Completed Intervals"
    Case "Active" 
       objIntervals.Status = UsageIntervalStatus_Active
       FrameWork.Dictionary().Add "INTERVAL_MANANAGEMENT_PAGE_TITLE", "Active Intervals"       
    Case "Billable"
       objIntervals.Status = UsageIntervalStatus_Billable
       FrameWork.Dictionary().Add "INTERVAL_MANANAGEMENT_PAGE_TITLE", "Billable Intervals"       
    Case Else
       objIntervals.Status = UsageIntervalStatus_All
       FrameWork.Dictionary().Add "INTERVAL_MANANAGEMENT_PAGE_TITLE", "All Intervals"
  End Select

  '/// <summary>
  '///   Gets a rowset containing all usage intervals with the given status
  '/// </summary>
  '/// <returns>
  '///   IntervalID
  '///   CycleType
  '///   StartDate
  '///   EndDate
  '///   TotalGroupCount
  '///   OpenGroupCount
  '///   SoftClosedGroupCount
  '///   HardClosedGroupCount
  '///   Progress:  0 - 100
  '///    
  '///   Default sort:  EndDate DESC  
  Set ProductView.Properties.RowSet = objUSM.GetUsageIntervalsRowsetRedux((objIntervals))
  ProductView.Properties.AddPropertiesFromRowset ProductView.Properties.RowSet

  ProductView.Properties.ClearSelection 
  
  Dim i
  i = 1
  
  ProductView.Properties("IntervalId").Selected              = i : i=i+1
  ProductView.Properties("Status").Selected          = i : i=i+1  
  ProductView.Properties("CycleType").Selected               = i : i=i+1    
  ProductView.Properties("StartDate").Selected               = i : i=i+1
  ProductView.Properties("EndDate").Selected                 = i : i=i+1  
  ProductView.Properties("TotalGroupCount").selected         = i : i=i+1 
  'ProductView.Properties("OpenGroupCount").Selected          = i : i=i+1  
  'ProductView.Properties("SoftClosedGroupCount").Selected    = i : i=i+1  
  'ProductView.Properties("HardClosedGroupCount").Selected    = i : i=i+1  
  'ProductView.Properties("OpenUnassignedAccountsCount").Selected = i : i=i+1 
  'ProductView.Properties("Progress").Selected                = i : i=i+1  
  
  ProductView.Properties("IntervalId").Caption = FrameWork.GetDictionary("TEXT_BG_INTERVALID")
  ProductView.Properties("IntervalId").Alignment = "LEFT"
  ProductView.Properties("Status").Caption = "Status" 'FrameWork.GetDictionary("TEXT_BG_CYCLE_TYPE")
  ProductView.Properties("CycleType").Caption = FrameWork.GetDictionary("TEXT_BG_CYCLE_TYPE")
  ProductView.Properties("StartDate").Caption = FrameWork.GetDictionary("TEXT_BG_START")
  ProductView.Properties("EndDate").Caption = FrameWork.GetDictionary("TEXT_BG_END")
  ProductView.Properties("TotalGroupCount").Caption = FrameWork.GetDictionary("TEXT_BG_TOTAL_GROUP_COUNT") 
  'ProductView.Properties("OpenGroupCount").Caption = FrameWork.GetDictionary("TEXT_BG_OPEN_BILLING_GROUP_COUNT")
  'ProductView.Properties("SoftClosedGroupCount").Caption = FrameWork.GetDictionary("TEXT_BG_SOFT_CLOSED_GROUP_COUNT")
  'ProductView.Properties("HardClosedGroupCount").Caption = FrameWork.GetDictionary("TEXT_BG_HARD_CLOSED_GROUP_COUNT") 
  'ProductView.Properties("OpenUnassignedAccountsCount").Caption = FrameWork.GetDictionary("TEXT_BG_UNASSIGNED") 
  'ProductView.Properties("Progress").Caption = FrameWork.GetDictionary("TEXT_BG_PROGRESS") 
            
  ProductView.Properties("EndDate").Sorted = MTSORT_ORDER_ASCENDING
  mdm_SetMultiColumnFilteringMode TRUE 
          
  Form_LoadProductView = TRUE
  
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:    Form_DisplayCell
' PARAMETERS:  EventArg
' DESCRIPTION: Custom rendering for progress, and numbers
' RETURNS:     Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_DisplayCell(EventArg)

       If Form.Grid.Col <= 3 Then
          Form_DisplayCell = LinkColumnMode_DisplayCell(EventArg)
       Else
         Select Case lcase(Form.Grid.SelectedProperty.Name)

          Case "totalgroupcount", "opengroupcount", "softclosedgroupcount", "hardclosedgroupcount", "unassignedaccountscount"
          
             EventArg.HTMLRendered = "<td style='text-align:right;width:10px;' class='" & Form.Grid.CellClass & "'>" & _
                                     Form.Grid.SelectedProperty.Value & _
                                     "</td>"
            
             Form_DisplayCell = TRUE
            
          'Case "progress"
          '  Dim percent
          '  percent = Form.Grid.SelectedProperty.Value
          '  EventArg.HTMLRendered = "<td nowrap class='" & Form.Grid.CellClass & "'>" & _
          '                            "<span id=progressContainer>" & _
          '                            "  <span id=progressIndicator style='width:" & percent & "px;'><span id=progressAmount>" & percent & "%</span></span>" & _
          '                            "</span>&nbsp;" & _
          '                            "</td>"
          '  Form_DisplayCell = TRUE   
                               
          Case "status"
                dim sDisplayValue
                if Trim(ProductView.Properties("Status")) = "O"  OR Trim(ProductView.Properties("Status")) = "B" Then
                  sDisplayValue = "Open"
                else
                  if Trim(ProductView.Properties("Status")) = "H" Then
                    sDisplayValue = "Hard Closed"
                  else
                    sDisplayValue = "UNKNOWN"
                  end if
                end if
                dim strImage
                strImage = GetIntervalStateIcon(sDisplayValue)
                EventArg.HTMLRendered =  "<td width='150px' class='" & Form.Grid.CellClass & "'><table width='100%' border='0' cellspacing='0' cellpadding='0'><tr align='right'>"  & _
            "<td align='left'><img src='" & strImage & "' align='absmiddle'>" & sDisplayValue & "</td>" & _
            "</tr></table></td>"
      
                Form_DisplayCell = TRUE   

          Case "startdate"
          dim startdate 
          startdate = mdm_Format(ProductView.Properties("StartDate"),mom_GetDictionary("DATE_FORMAT"))

                EventArg.HTMLRendered =  "<td width='150px' class='" & Form.Grid.CellClass & "'><table width='100%' border='0' cellspacing='0' cellpadding='0'><tr align='right'>"  & _
            "<td align='left'>" & startdate & "</td></tr></table></td>"
      
                Form_DisplayCell = TRUE 

          Case "enddate"
          dim enddate 
          enddate = mdm_Format(ProductView.Properties("EndDate"),mom_GetDictionary("DATE_TIME_FORMAT"))

                EventArg.HTMLRendered =  "<td width='250px' class='" & Form.Grid.CellClass & "'><table width='100%' border='0' cellspacing='0' cellpadding='0'><tr align='right'>"  & _
            "<td align='left'>" & enddate & "</td></tr></table></td>"
      
                Form_DisplayCell = TRUE 
                                  
          Case else
            Form_DisplayCell = Inherited("Form_DisplayCell(EventArg)")
        End Select
     End If

    Form_DisplayCell = TRUE

END FUNCTION

%>
