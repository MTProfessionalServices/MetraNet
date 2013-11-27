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
<!-- #INCLUDE FILE="../../default/Lib/CBatchError.asp" -->

<!-- #INCLUDE FILE="../../default/Lib/CAdjustmentHelper.asp" -->
<!-- #INCLUDE FILE="../../default/Lib/CTransactionUIFinder.asp" -->
<!-- #INCLUDE FILE="../../custom\Lib\CustomCode.asp" -->
<%

PRIVATE AdjustmentHelper
Set AdjustmentHelper          = New CAdjustmentHelper
AdjustmentHelper.BulkMode     = FALSE
AdjustmentHelper.ParentMode   = FALSE

' Mandatory
Form.RouteTo = mam_GetDictionary("ADJUSTMENT_PVB_CHILDREN_DIALOG")
Form.Version = MDM_VERSION     ' Set the dialog version

mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: Form_Initialize
' PARAMETERS	:
' DESCRIPTION :
' RETURNS		  : Returns TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean

  Form("ParentSessionID")     = mdm_UIValue("SessionID")
  Form("ChildType")           = mdm_UIValue("ChildType")
  Form("ViewId")              = mdm_UIValue("ViewId")
  Form("PITemplateChildren")  = mdm_UIValue("PITemplateChildren")
    
  If Not AdjustmentHelper.LoadAdjustmentTypes(Form("PITemplateChildren"),AdjustmentHelper.SelectedIDs,Service) Then ' Pass an empty string as session id because we do not know the one selected by the user
  
      Form_Initialize = FALSE
      Exit Function
  End If

  If Not AdjType_Click(EventArg) Then Exit Function
  If Not Form_Refresh(EventArg)  Then Exit Function
  
  Service.LoadJavaScriptCode  ' This line is important to get JavaScript field validation  
  
  mam_IncludeCalendar
  
  Dim strMessage
  
  If AdjustmentHelper.CheckIfTransactionHasAlreadyAdjustment(Form("ViewId"), Form("ParentSessionID"),strMessage) Then
  
      Service.Properties("UserWarningMessage").Value = strMessage
  End If
  
  FrameWork.Dictionary().Add "Adjustment.Edit.Children.UserWarningMessage.Show", CBool(Len(strMessage))
  
  Form_Initialize = TRUE
END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    :
' PARAMETERS		  :
' DESCRIPTION 		: 
' RETURNS		      : 
PUBLIC FUNCTION ChildrenGrid_DisplayCell(EventArg)

  Select Case UCase(EventArg.Grid.SelectedProperty.Name)
  
  	  Case "SESSIONID"
      
  			  EventArg.HTMLRendered = "<td Class=" & EventArg.Grid.CellClass & " width='0'>"          
          If(GetSupportBulk())Then
              EventArg.HTMLRendered = EventArg.HTMLRendered & "<INPUT Type='checkbox' Name='ChildTrans_[SESSIONID]'>"
          Else
              EventArg.HTMLRendered = EventArg.HTMLRendered & "<INPUT Type='RADIO' Name='ChildTrans_[SESSIONID]'>"
          End If          
	  	  	EventArg.HTMLRendered     = EventArg.HTMLRendered & "</td>"
          EventArg.HTMLRendered     = PreProcess(EventArg.HTMLRendered,Array("SESSIONID",Form.Grids("ChildrenGrid").RowSet.Value("SessionID")))
		  	  Subscriptions_DisplayCell = TRUE
		Case Else
			    Subscriptions_DisplayCell = Inherited("Grid_DisplayCell(EventArg)")
	End Select
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    :
' PARAMETERS		  :
' DESCRIPTION 		: 
' RETURNS		      : 
'PRIVATE FUNCTION GetChildrenRowSet()
'
    'Dim idParent, productSlice, sessSlice 
'    
    'Set GetChildrenRowSet = Nothing ' Default Value
'    
    'Set productSlice      = CreateObject("MTHierarchyReports.ProductViewAllUsageSlice")
    'productSlice.ViewID   = GetChildViewID()
'    
    'If(productSlice.ViewID=0) Then Exit Function
'    
    'set sessSlice = CreateObject("MTHierarchyReports.SessionChildrenSlice")
'    
    ''just get the first record of the rowset
    'idParent = Form("SessionID")
    'sessSlice.ParentID = idParent
    'Set GetChildrenRowSet = TransactionUIFinder.RptHelper.GetUsageDetail(productSlice, sessSlice, TransactionUIFinder.AccSlice, TransactionUIFinder.TimeSlice, "")
'END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    :
' PARAMETERS		  :
' DESCRIPTION 		: 
' RETURNS		      : 
PRIVATE FUNCTION GetChildrenSummaryRowset()

    Dim idParent, productSlice, sessSlice 
    
    Set GetChildrenRowSet = Nothing ' Default Value
    
    Set productSlice      = CreateObject("MTHierarchyReports.ProductViewAllUsageSlice")
    productSlice.ViewID   = GetChildViewID()
    
    If(productSlice.ViewID=0) Then Exit Function
    
    set SessSlice = CreateObject("MTHierarchyReports.SessionChildrenSlice")
    
    'just get the first record of the rowset
    idParent = Form("SessionID")
    sessSlice.ParentID = idParent
    Set GetChildrenSummaryRowset = TransactionUIFinder.RptHelper.GetUsageSummary(SessSlice, TransactionUIFinder.AccSlice, TransactionUIFinder.TimeSlice)
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : OK_Click()
' PARAMETERS		  :
' DESCRIPTION 		: Implement the button Save Adjustment
' RETURNS		      : 
PRIVATE FUNCTION Ok_Click(EventArg) ' As Boolean

    Ok_Click = FALSE

    If(Not AdjustmentHelper.Save(EventArg))Then Exit Function
    
    AdjustmentHelper.SetRouteToForConfirmDialog "Children",FrameWork.Dictionary.Item("TEXT_ADJUSTMENT(s)_HAS_BEEN_APPROVED").Value
    
    OK_Click  = TRUE
END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : CANCEL_Click
' PARAMETERS		  :
' DESCRIPTION 		: 
' RETURNS		      : 
PRIVATE FUNCTION CANCEL_Click(EventArg) ' As Boolean

    Dim strParam
    


    strParam = strParam & "?SessionID=" & Form("ParentSessionID") & "&"
    strParam = strParam & "ChildType=" & Form("ChildType") & "&"
    strParam = strParam & "ViewID=" & Form("ViewId") & "&"
    strParam = strParam & "PITemplateChildren=" & Form("PITemplateChildren") & "&"
    
    Form.RouteTo = Form.RouteTo & strParam 
    
    CANCEL_Click  = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : AdjType_Click
' PARAMETERS		  :
' DESCRIPTION 		: 
' RETURNS		      : 
PUBLIC FUNCTION AdjType_Click(EventArg)

    AdjustmentHelper.SelectAdjustmentType(Service.Properties("AdjType").Value)
    AdjType_Click = TRUE
END FUNCTION

    
PRIVATE FUNCTION UpdateSelectedIDsInSelector(EventArg)

    Dim strUnSelectedIDs,strSelectedIDs, objChildrenProductView
    
    Const CHILDREN_DIALOG_ASP_FILE_NAME = "Adjustment.PVB.children.asp"
    
    UpdateSelectedIDsInSelector = FALSE

    strSelectedIDs    = Replace(mdm_UIValue("mdmSelectedIDs")  ,MDM_PVB_CHECKBOX_PREFIX,"")
    strUnSelectedIDs  = Replace(mdm_UIValue("mdmUnSelectedIDs"),MDM_PVB_CHECKBOX_PREFIX,"")

    ' Get the instance of the Service object of PVB on top
    Set objChildrenProductView = mdm_GetServiceInstanceFromID(CHILDREN_DIALOG_ASP_FILE_NAME,TRUE)
    
    If Not (objChildrenProductView Is Nothing)Then
    
        objChildrenProductView.Properties.Selector.SelecteItemsFromCSVString(strSelectedIDs)
        objChildrenProductView.Properties.Selector.UnSelecteItemsFromCSVString(strUnSelectedIDs)
        
        If objChildrenProductView.Properties.Selector.Count Then
        
            strSelectedIDs = objChildrenProductView.Properties.Selector.GetAllSelectedItemFromRowSetAsCSVString(Nothing,"")                
            AdjustmentHelper.SetTransactionIDs strSelectedIDs          
            AdjustmentHelper.CreateTransactionSet(AdjustmentHelper.GetSelectedAdjustmentType())
            
            AdjustmentHelper.PopulateReasonCodeEnumType ' We can only populate the Reason Code Enum when the user has selected some transaction
                                                        ' This occur just before it click on COMPUTE
        Else
            EventArg.Error.Number       = 1039+vbObjectError
            EventArg.Error.Description  = mam_GetDictionary("MAM_ERROR_1039")
            Exit Function
        End If
    End If
    UpdateSelectedIDsInSelector = TRUE   
END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : butCompute_Click
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      :
PRIVATE FUNCTION butCompute_Click(EventArg) ' As Boolean
    
    Dim strUnSelectedIDs,strSelectedIDs, objChildrenProductView
    Set AdjustmentHelper.SaveWarningRowset = nothing
    butCompute_Click  = FALSE    
    
    If Not Service.RequiredFieldsOK(EventArg.Error) Then Exit Function
    If Not UpdateSelectedIDsInSelector(EventArg)    Then Exit Function
    
    If(AdjustmentHelper.SessionIDs.Count)Then
        
                
        AdjustmentHelper.CalculateAndUpdateServiceProperties ' Calculate
        If AdjustmentHelper.WarningsCounter Then
         Form.JavaScriptInitialize = FrameWork.Dictionary.PreProcess("window.open('[BATCH_ERROR_LIST_FILTER_OFF_NO_BACK_DIALOG]','','height=300,width=570,resizable=yes,scrollbars=yes,status=yes');")
        End If
        butCompute_Click = TRUE
    End If
END FUNCTION


PRIVATE FUNCTION butViewDetails_Click(EventArg) ' As Boolean

    butViewDetails_Click = FALSE
    
    If AdjustmentHelper.Calculated Then
    
        Form.JavaScriptInitialize = FrameWork.Dictionary.PreProcess("window.open('[ADJUSTMENT_VIEW_OUTPUT_DETAILS_DIALOG]','','height=300,width=1000,resizable=yes,scrollbars=yes,status=yes');")
        butViewDetails_Click = TRUE
    Else
        AdjustmentHelper.NotReadyToBeSave EventArg       
    End If    
END FUNCTION

%>
