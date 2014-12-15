<%
' -------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile: BillingGroups.List.asp$
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
'  Created by: Kevin A. Boucher
' -------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!--METADATA TYPE="TypeLib" NAME="MetraTech.UsageServer" UUID="{b6ad949f-25d4-4cd5-b765-3f6199ecc51c}" -->

<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/mdm.asp" -->
<!-- #INCLUDE FILE="../../default/lib/momLibrary.asp" -->
<!-- #INCLUDE FILE="../../default/lib/IntervalManagementLibrary.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/FrameWork/CFrameWork.Class.asp" -->
<%

Form.RouteTo = mom_GetDictionary("WELCOME_DIALOG")
Form.Page.MaxRow = 5

mdm_PVBrowserMain

FUNCTION Form_Initialize(EventArg) ' As Boolean

  Form("ShowAllBillingGroups") = False

  ProductView.Clear  
  ProductView.Properties.Flags = eMSIX_PROPERTIES_FLAG_PRODUCTVIEW
  
  If Len(Request.QueryString("IntervalID")) > 0 Then
    Form("IntervalID") = Request.QueryString("IntervalID")
    
    ' Get Interval - HasBeenMaterialized
    Dim objUSM
    Set objUSM = mom_GetUsageServerClientObject()
    Dim interval
    'Set interval = objUSM.GetUsageIntervalWithoutAccountStats(CLng(Form("IntervalID"))) 

    dim partitionId 
    partitionId = Session("MOM_SESSION_CSR_PARTITION_ID")
    if IsEmpty(Session("MOM_SESSION_CSR_PARTITION_ID")) then
    'show no data if the partition id is empty
    elseif (partitionId = 1) then
      Set interval = objUSM.GetUsageIntervalWithoutAccountStats(CLng(Form("IntervalID"))) 
    else
      Set interval = objUSM.GetUsageIntervalWithoutAccountStatsForPartition(CLng(Form("IntervalID")),partitionId)
    end if

    If CBool(interval.HasBeenMaterialized) Then
      mdm_GetDictionary().Add "MATERIALIZE_TEXT", mom_GetDictionary("TEXT_REMATERIALIZE")
      ' Reset the message
      Form.Page.NoRecordUserMessage = mom_GetDictionary("PRODUCT_VIEW_BROWSER_NO_RECORDS_FOUND")
    Else
      mdm_GetDictionary().Add "MATERIALIZE_TEXT", mom_GetDictionary("TEXT_MATERIALIZE")
      
      ' Set the empty rowset message to be more helpful text (only if we haven't materialized... otherwise the rowset may be empty because of a filter)
      Form.Page.NoRecordUserMessage = mom_GetDictionary("TEXT_NO_BILLING_GROUPS")   
    End If
    
    mdm_GetDictionary().Add "SHOW_HARD_CLOSE_INTERVAL_OPTION", 0
    
    If interval.Status = UsageIntervalStatus_HardClosed Then
      mdm_GetDictionary().Add "SHOW_MATERIALIZE_GROUPS_OPTION", 0
    Else
      '//Case when interval has no accounts and no billing groups indicate that we should give
      '//user option of hardclosing the interval directly instead of creating billing groups which will fail
      If interval.HasPayerAccounts Then
        mdm_GetDictionary().Add "SHOW_MATERIALIZE_GROUPS_OPTION", 1
      Else
        mdm_GetDictionary().Add "SHOW_MATERIALIZE_GROUPS_OPTION", 0
        mdm_GetDictionary().Add "SHOW_HARD_CLOSE_INTERVAL_OPTION", 1
      End If
    End If

    If Not FrameWork.CheckCoarseCapability("Manage Intervals") Then
      mdm_GetDictionary().Add "SHOW_MATERIALIZE_GROUPS_OPTION", 0
      mdm_GetDictionary().Add "SHOW_HARD_CLOSE_INTERVAL_OPTION", 0
    End If
    
    If mom_GetDictionary("SHOW_MATERIALIZE_GROUPS_OPTION") = 0 Then
      ' Reset the message
      Form.Page.NoRecordUserMessage = mom_GetDictionary("PRODUCT_VIEW_BROWSER_NO_RECORDS_FOUND")
    End If

  End If

  Form_Initialize = TRUE
END FUNCTION


PRIVATE FUNCTION Form_LoadProductView(EventArg) ' As Boolean
  
  If Len(mdm_UIValue("mdmPVBFilter")) > 0 Then
      Form("ShowAllBillingGroups") = True
  End If
  Dim objUSM, materializationID
  Set objUSM = mom_GetUsageServerClientObject()

  ' If there are reassignment warnings then display a link to see them.  
  materializationID = objUSM.GetLastMaterializationIDWithReassignmentWarnings(CLng(Form("IntervalID")))
  If materializationID <> -1 Then
    Dim htm
    htm = "<span class='clsError'>" &_
          "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;There were  <a href='#' OnClick=""window.open('BillingGroupWarnings.asp?MaterializationID=" & materializationID & "','', 'height=700,width=1000, resizable=yes, scrollbars=yes, status=yes');"">reassignment warnings</a> on the last billing group creation." &_
          "</span><br><br>"
    mdm_GetDictionary().Add "REASSIGNMENT_ERRORS", htm
  Else
    mdm_GetDictionary().Add "REASSIGNMENT_ERRORS", ""
  End If

  '  /// <summary>
  '  ///   Gets the list of Billing Groups for the interval.
  '  /// </summary>
  '  /// <param name="usageIntervalID"></param>
  '  /// <returns>
  '  ///   BillingGroupID
  '  ///   Name
  '  ///   Description
  '  ///   Status
  '  ///   MemberCount
  '  ///   AdapterCount
  '  ///   AdapterSucceededCount
  '  ///   AdapterFailedCount
  '  ///   HasChildren
  '  ///   
  '  ///   Sorted by:  Name ASC
  '  /// </returns>   

  dim partitionId 
  partitionId = Session("MOM_SESSION_CSR_PARTITION_ID")
  if IsEmpty(Session("MOM_SESSION_CSR_PARTITION_ID")) then
    'show no bill groups if the partition id is empty
  elseif (partitionId = 1) then
    Set ProductView.Properties.RowSet = objUSM.GetBillingGroupsRowset(CLng(Form("IntervalID")), CBool(Form("ShowAllBillingGroups")))  
  else
    Set ProductView.Properties.RowSet = objUSM.GetBillingGroupsForPartitionRowset(CLng(Form("IntervalID")), CLng(partitionId), CBool(Form("ShowAllBillingGroups")))
  end if

  ProductView.Properties.AddPropertiesFromRowset ProductView.Properties.RowSet
  ProductView.Properties.ClearSelection
'	ProductView.Properties.SelectAll  
  
  ' Setup columns
  dim i
  i = 1
	ProductView.Properties("Name").Selected		               = i : i=i+1
	ProductView.Properties("Status").Selected		             = i : i=i+1  
  ProductView.Properties("MemberCount").Selected           = i : i=i+1
	ProductView.Properties("AdapterCount").Selected          = i : i=i+1
  ProductView.Properties("AdapterSucceededCount").Selected = i : i=i+1
  ProductView.Properties("AdapterFailedCount").Selected    = i : i=i+1
           
	ProductView.Properties("Name").Caption			             = mom_GetDictionary("TEXT_BILLING_GROUP")
	ProductView.Properties("Status").Caption		             = mom_GetDictionary("TEXT_STATUS") 
  ProductView.Properties("MemberCount").Caption		         = mom_GetDictionary("TEXT_MEMBERS")
	ProductView.Properties("AdapterCount").Caption	         = mom_GetDictionary("TEXT_ADAPTERS")
  ProductView.Properties("AdapterSucceededCount").Caption  = mom_GetDictionary("TEXT_SUCCEED")
  ProductView.Properties("AdapterFailedCount").Caption     = mom_GetDictionary("TEXT_FAILED")
  
  ProductView.Properties("Name").Sorted = MTSORT_ORDER_ASCENDING
  mdm_SetMultiColumnFilteringMode TRUE 
  
  Form_LoadProductView = TRUE  

END FUNCTION  


PRIVATE FUNCTION Form_DisplayCell(EventArg) ' As Boolean
  
  Select Case Form.Grid.Col
  
    Case 2
      If (UCase(ProductView.Properties("HasChildren")) = "N") or (CBool(Form("ShowAllBillingGroups"))) Then
        EventArg.HTMLRendered = "<td class='" & Form.Grid.CellClass & "' align='left' nowrap>"
   		  EventArg.HTMLRendered = EventArg.HTMLRendered & ""
			  EventArg.HTMLRendered = EventArg.HTMLRendered & "</td>" 
        Form_DisplayCell = TRUE
      Else
        Form_DisplayCell = Inherited("Form_DisplayCell(EventArg)")
	    End If
		Case 3 
			EventArg.HTMLRendered = EventArg.HTMLRendered & "<td width='250px' class='" & Form.Grid.CellClass & "' align='left'>"
      dim nameLocalize
      nameLocalize = UCase(Replace(ProductView.Properties("Name").Value, " ", "_"))
			EventArg.HTMLRendered = EventArg.HTMLRendered & "<b><a target='ticketFrame' href='IntervalManagement.ViewEdit.asp?BillingGroupID=" & ProductView.Properties("BillingGroupID") & "&ID=" & Form("IntervalID") & _
                                                      "'>" & mom_GetDictionary("TEXT_BG_NAME_" & nameLocalize) & "</a></b><br>" 
      If Not (IsNull(ProductView.Properties("partition_name")) Or IsEmpty(ProductView.Properties("partition_name"))) then
        EventArg.HTMLRendered = EventArg.HTMLRendered & mom_GetDictionary("TEXT_PARTITION") & ": " & ProductView.Properties("partition_name") & "<br>"
      End If
      EventArg.HTMLRendered = EventArg.HTMLRendered & mom_GetDictionary("TEXT_BG_DESCRIPTION_" & nameLocalize) 
			EventArg.HTMLRendered = EventArg.HTMLRendered & "</td>" 
            
      Form_DisplayCell = TRUE   
      
    Case 4
    
      dim strImage
      strImage = GetIntervalStateIcon(Trim(ProductView.Properties("Status")))
      EventArg.HTMLRendered =  "<td width='150px' class='" & Form.Grid.CellClass & "'><table width='100%' border='0' cellspacing='0' cellpadding='0'><tr align='right'>"  & _
            "<td align='left'><img src='" & strImage & "' align='absmiddle'>" & mom_GetDictionary("TEXT_BG_STATUS_" & UCase(Replace(ProductView.Properties("Status"), " ", "_"))) & "</td>" & _
            "</tr></table></td>"
      
      Form_DisplayCell = TRUE   

    Case 5
      EventArg.HTMLRendered =  "<td style='text-align:right;' class='" & Form.Grid.CellClass & "'>" & FrameWork.Format(ProductView.Properties("MemberCount"),"###,###") & "</td>"
      
      Form_DisplayCell = TRUE   
          
		Case else
			Form_DisplayCell = Inherited("Form_DisplayCell(EventArg)")
      
	End Select

END FUNCTION

PRIVATE FUNCTION Form_DisplayDetailRow(EventArg) ' As Boolean

    EventArg.HTMLRendered = EventArg.HTMLRendered & "<td></td><td></td>" & vbNewLine
    EventArg.HTMLRendered = EventArg.HTMLRendered & "<td  ColSpan=" & (ProductView.Properties.Count+2) & ">" & vbNewLine
    EventArg.HTMLRendered = EventArg.HTMLRendered & "<div id='PullListDiv' style='display:inline;width:100%height:100%;'>" & _
                                                      "<iframe name='PullListIFrame' width='100%' height='100%' frameborder='0' src='BillingGroups.PullList.asp?IntervalID=" & Form("IntervalID") & "&BillingGroupID=" & ProductView.Properties("BillingGroupID")  & "'></iframe>" & _
                                                     "</div>  "

    EventArg.HTMLRendered = EventArg.HTMLRendered & "</td>" & vbNewLine
    
    Form_DisplayDetailRow = TRUE
END FUNCTION

PRIVATE FUNCTION ShowAll_Click(EventArg)
  On Error Resume Next
  
  If CBool(Form("ShowAllBillingGroups")) Then
    Form("ShowAllBillingGroups") = False
  Else
    Form("ShowAllBillingGroups") = True
  End If

  ShowAll_Click = True
END FUNCTION

PRIVATE FUNCTION Materialize_Click(EventArg)
  On Error Resume Next
  
  Dim objUSM, materializationID, interval
  Set objUSM = mom_GetUsageServerClientObject()
  Set interval = objUSM.GetUsageIntervalWithoutAccountStats(CLng(Form("IntervalID")))
    
  ' Materialize or Re-Materialize Billing Groups
  If CBool(interval.HasBeenMaterialized) Then
    materializationID = objUSM.ReMaterializeBillingGroups(Form("IntervalID"))
  Else
    materializationID = objUSM.MaterializeBillingGroups(Form("IntervalID"))
  End If
  
  ' Check for errors
  If(CBool(Err.Number = 0)) then
      On Error Goto 0
      'Form.RouteTo = "BillingGroups.List.asp?IntervalID=" & Form("IntervalID")	
      Form.JavaScriptInitialize = "parent.location = parent.location;"     
      Materialize_Click = TRUE
  Else
      EventArg.Error.Save Err 
      Materialize_Click = FALSE       
  End If

END FUNCTION

PRIVATE FUNCTION HardCloseInterval_Click(EventArg)
  On Error Resume Next
  
  Dim objUSM, materializationID, interval
  Set objUSM = mom_GetUsageServerClientObject()
  call objUSM.HardCloseUsageInterval(CLng(Form("IntervalID")), false)
  
  ' Check for errors
  If(CBool(Err.Number = 0)) then
      On Error Goto 0
      'Form.RouteTo = "BillingGroups.List.asp?IntervalID=" & Form("IntervalID")	
      Form.JavaScriptInitialize = "parent.location = parent.location;"     
      HardCloseInterval_Click = TRUE
  Else
      EventArg.Error.Save Err 
      HardCloseInterval_Click = FALSE       
  End If

END FUNCTION

PUBLIC FUNCTION Form_DisplayErrorMessage(EventArg) ' As Boolean
    '1002-MOM ERROR-A unknown error occured. Please have your administrator check the system log, and try again later
    If Len(EventArg.Error.LocalizedDescription) Then     
          WriteError(EventArg)
      ElseIf Len(EventArg.Error.Description) Then   
          WriteError(EventArg)
      Else
'          WriteError(EventArg)
      End If
End FUNCTION

PUBLIC FUNCTION WriteError(EventArg)
    Dim strPath, strDetail
    strPath = mom_GetDictionary("DEFAULT_PATH_REPLACE")
  
  ' write clsErrorText style so MDM will pick it up
  Response.write "<style>"
  Response.write ".ErrorCaptionBar{	BACKGROUND-COLOR: #FDFECF;	BORDER-BOTTOM:#9D9F0F solid 1px;	BORDER-LEFT: #9D9F0F solid 1px;	BORDER-RIGHT: #9D9F0F solid 1px;	BORDER-TOP:#9D9F0F solid 1px; COLOR: black;	FONT-FAMILY: Arial;	FONT-SIZE: 10pt;	FONT-WEIGHT: bold;	TEXT-ALIGN: left;	padding-left : 5px;	padding-right : 5px;	padding-top : 2px;	padding-bottom : 2px;}"
  Response.write "</style>"
  Response.write "  <center><BR><TABLE WIDTH=""95%"" BGCOLOR=""#FFFFC4"" BORDER=""0"" CELLSPACING=""0"" CELLPADDING=""0"" BORDERCOLOR=""Black"" style=""margin-top: 5px;"">"
  Response.write "  <TR>"
  Response.write "  <TD Class='ErrorCaptionBar'>" 
  Response.write "   <IMG SRC='" & strPath & "/images/error.gif' valign=""center"" BORDER=""0"" >&nbsp;"
  
  ' Change in MOM 3.0
  'strDetail = EventArg.Error.ToString()
  strDetail = "Number=" & EventArg.Error.Number & " (0x" & Hex(EventArg.Error.Number) & ")" & vbNewLine & "Description=" & EventArg.Error.Description & vbNewLine & "Source=" & EventArg.Error.Source
  
  strDetail = Replace(strDetail,"\","\\")
  strDetail = Replace(strDetail,vbNewLine,"\n")
  strDetail = Replace(strDetail,Chr(13),"\n")
  strDetail = Replace(strDetail,Chr(10),"")
  strDetail = Replace(strDetail,"""","\""")
  strDetail = Replace(strDetail,"'","\'")
  strDetail = Replace(strDetail,"; ","\n")
  'strDetail = Replace(strDetail,";","")
    If Len(EventArg.Error.LocalizedDescription) Then     
          Response.write  EventArg.Error.LocalizedDescription            
    ElseIf Len(EventArg.Error.Description) Then   
          Response.write EventArg.Error.Description
    End If  
    
  Response.write "<script>var strErrorMessageDetail='"& strDetail & "';</script>"
  Response.write "<BR><BR><CENTER><FONT size=2><A Name='butDetail' title='" & mom_GetDictionary("MoM_ERROR_ERROR_DETAIL_DESCRIPTION") & "' HREF='#' OnClick=""alert(strErrorMessageDetail)"">"
  Response.write mom_GetDictionary("MoM_ERROR_ERROR_DETAIL")
  Response.write "</A></CENTER>"
    
  Response.write "    </TD>"
  Response.write "    </TR>"
  Response.write "  </TABLE></center>"     
END FUNCTION


%>



