<%
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile: IntervalManagement.ViewEdit.asp$
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
'  Created by: Kevin A. Boucher
' 
'  $Date: 11/14/2002 12:13:30 PM$
'  $Author: Rudi Perkins$
'  $Revision: 9$
' ---------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/mdm.asp" -->
<!-- #INCLUDE FILE="../../default/lib/momLibrary.asp" -->
<!-- #INCLUDE FILE="../../default/lib/IntervalManagementLibrary.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/FrameWork/CFrameWork.Class.asp" -->
<%

Form.RouteTo = mom_GetDictionary("INTERVAL_MANAGEMENT_LIST_DIALOG") & "?MDMAction=" & MDM_ACTION_REFRESH

mdm_Main 

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:    Form_Initialize
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:     Return TRUE if ok else FALSE
FUNCTION Form_Initialize(EventArg) ' As Boolean

  Form("IntervalID") = request.querystring("IntervalID")
  Form("BillingGroupID") = request.querystring("BillingGroupID")

	Service.Clear 
  Form.Grids.Add "BillingGroups", "BillingGroups" 
 
	Form_Initialize = Form_Refresh(EventArg)
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:    Form_Refresh
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:     Return TRUE if ok else FALSE
FUNCTION Form_Refresh(EventArg)

  Dim objUSM
  Set objUSM = mom_GetUsageServerClientObject()
  Set Form.Grids("BillingGroups").Rowset = objUSM.GetDescendantBillingGroupsRowset(CLng(Form("BillingGroupID")))
  
  Form.Grids("BillingGroups").Width = "100%"	
  Form.Grids("BillingGroups").Properties.ClearSelection
	'Form.Grids("BillingGroups").Properties.SelectAll

  ' Setup columns
  dim i
  i = 1
	Form.Grids("BillingGroups").Properties("Name").Selected		               = i : i=i+1
	Form.Grids("BillingGroups").Properties("Status").Selected		             = i : i=i+1  
  Form.Grids("BillingGroups").Properties("MemberCount").Selected           = i : i=i+1
	Form.Grids("BillingGroups").Properties("AdapterCount").Selected          = i : i=i+1
  Form.Grids("BillingGroups").Properties("AdapterSucceededCount").Selected = i : i=i+1
  Form.Grids("BillingGroups").Properties("AdapterFailedCount").Selected    = i : i=i+1
           
	Form.Grids("BillingGroups").Properties("Name").Caption			             = mom_GetDictionary("TEXT_BILLING_GROUP")
	Form.Grids("BillingGroups").Properties("Status").Caption		             = mom_GetDictionary("TEXT_STATUS")
  Form.Grids("BillingGroups").Properties("MemberCount").Caption		         = mom_GetDictionary("TEXT_MEMBERS")
	Form.Grids("BillingGroups").Properties("AdapterCount").Caption	         = mom_GetDictionary("TEXT_ADAPTERS")
  Form.Grids("BillingGroups").Properties("AdapterSucceededCount").Caption  = mom_GetDictionary("TEXT_SUCCEED")
  Form.Grids("BillingGroups").Properties("AdapterFailedCount").Caption     = mom_GetDictionary("TEXT_FAILED")

  Form.Grids("BillingGroups").Properties("Name").Sorted = MTSORT_ORDER_ASCENDING

  Form_Refresh = TRUE

END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:    BillingGroups_DisplayCell
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:     Return TRUE if ok else FALSE
PRIVATE FUNCTION BillingGroups_DisplayCell(EventArg)

  Select Case UCase(EventArg.Grid.SelectedProperty.Name)
  
		Case "NAME" 
			EventArg.HTMLRendered = EventArg.HTMLRendered & "<td width='237px' class='" & EventArg.Grid.CellClass & "' align='left'>"
			EventArg.HTMLRendered = EventArg.HTMLRendered & "<b><a target='fmeMain' href='IntervalManagement.ViewEdit.asp?BillingGroupID=" & EventArg.Grid.Rowset.Value("BillingGroupID") & "&ID=" & Form("IntervalID") & _
                                                      "'>" & EventArg.Grid.Rowset.Value("Name") & "</a></b><br>" & EventArg.Grid.Rowset.Value("Description")
			EventArg.HTMLRendered = EventArg.HTMLRendered & "</td>" 
            
      BillingGroups_DisplayCell = TRUE   
      
    Case "STATUS"
      dim strImage
      strImage = GetIntervalStateIcon(Trim(EventArg.Grid.Rowset.Value("Status")))
      EventArg.HTMLRendered =  "<td width='150px' class='" & EventArg.Grid.CellClass & "'><table width='100%' border='0' cellspacing='0' cellpadding='0'><tr align='right'>"  & _
            "<td align='left'><img src='" & strImage & "' align='absmiddle'>" & mom_GetDictionary("TEXT_BG_STATUS_" & UCase(Replace(EventArg.Grid.Rowset.Value("Status"), " ", "_"))) & "</td>" & _
            "</tr></table></td>"
      BillingGroups_DisplayCell = TRUE   

    Case "MEMBERCOUNT"
      EventArg.HTMLRendered =  "<td style='text-align:right;' class='" & EventArg.Grid.CellClass & "'>" & FrameWork.Format(EventArg.Grid.Rowset.Value("MemberCount"),"###,###") & "</td>"
      
      BillingGroups_DisplayCell = TRUE   
          
		Case else
			BillingGroups_DisplayCell = Inherited("Grid_DisplayCell(EventArg)")
      
	End Select
	 
END FUNCTION



%>



