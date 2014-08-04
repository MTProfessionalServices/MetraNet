<% 
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile: ReasonCode.List.asp$
' 
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
'  Created by: F.Torres
' 
'  $Date: 11/20/2002 2:16:30 PM$
'  $Author: Frederic Torres$
'  $Revision: 2$
'
' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
'
' CLASS       : DefaultDialogAddNameSpace.asp
' DESCRIPTION : Note that this dialog hit the SQL Server directly through MTSQLRowset Object and some query file.
'               We do not use MT Service or MT Product View. The Rowset is viewed as a product view.
'
'
' ---------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>

<!-- #INCLUDE FILE="../../MCMIncludes.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/common/mdmList.Library.asp" -->
<!-- #INCLUDE FILE="../lib/ScriptIncludes.html" -->

<%
Form.Version        = MDM_VERSION     ' Set the dialog version - we are version 2.0.
Form.ErrorHandler   = FALSE

mdm_PVBrowserMain ' invoke the mdm framework

PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean

  Form_Initialize = MDMListDialog.Initialize(EventArg)
    
  Form("IDColumnName") = "ReasonCodeID"
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION        :  Form_LoadProductView
' PARAMETERS      :  EventArg
' DESCRIPTION     : 
' RETURNS         :  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_LoadProductView(EventArg) ' As Boolean

  Form_LoadProductView = FALSE
   
  ' Load a Rowset from a SQL Queries and build the properties collection of the product view based on the columns of the rowset
  Set ProductView.Properties.RowSet = FrameWork.AdjustmentCatalog.GetReasonCodesAsRowset()
  
  ProductView.Properties.SelectAll

  Dim i : i = 1
  
  ProductView.Properties.ClearSelection
  
  ProductView.Properties("ReasonCodeName").Selected = i              : i=i+1
  ProductView.Properties("ReasonCodeDescription").Selected = i       : i=i+1
  ProductView.Properties("ReasonCodeDisplayName").Selected = i       : i=i+1  
  ProductView.Properties("ReasonCodeName").Caption = FrameWork.GetDictionary("TEXT_COLUMN_NAME")
  ProductView.Properties("ReasonCodeDescription").Caption = FrameWork.GetDictionary("TEXT_COLUMN_DESCRIPTION")
  ProductView.Properties("ReasonCodeDisplayName").Caption = FrameWork.GetDictionary("TEXT_COLUMN_DISPLAY_NAME")

  ProductView.Properties("ReasonCodeName").Sorted = MTSORT_ORDER_ASCENDING  ' Sort  
  Set Form.Grid.FilterProperty                    = ProductView.Properties("ReasonCodeName")
  Form_LoadProductView                            = TRUE ' Must Return TRUE To Render The Dialog
END FUNCTION

PUBLIC FUNCTION ViewEditMode_DisplayCell(EventArg) ' As Boolean

	Dim HTML_LINK_EDIT
	  
  Select Case Form.Grid.Col
  	Case 1
      	HTML_LINK_EDIT = HTML_LINK_EDIT & "<td class='[CLASS]' width='5'>"
        
        
        HTML_LINK_EDIT = HTML_LINK_EDIT & "<A Name='RS[ID]' HREF=""javascript:editSelectedItem('[ASP_PAGE]&ID=[ID]');""><img Alt='[ALT_EDIT]' src='[IMAGE_EDIT]' Border='0'></A>"
  			HTML_LINK_EDIT = HTML_LINK_EDIT & "</td>"
  			
  			MDMListDialog.PreProcessor.Clear
  			MDMListDialog.PreProcessor.Add "CLASS"       , Form.Grid.CellClass        
  			MDMListDialog.PreProcessor.Add "ASP_PAGE"    , FrameWork.GetDictionary("ADJUSTMENT_REASON_CODE_EDIT_DIALOG")
  			MDMListDialog.PreProcessor.Add "IMAGE_EDIT"  , Application("APP_HTTP_PATH") & "/default/localized/en-us/images/edit.gif"
  			MDMListDialog.PreProcessor.Add "ALT_EDIT"    , mdm_GetDictionary().Item("TEXT_EDIT").Value
  			MDMListDialog.PreProcessor.Add "ID"	    	   , ProductView.Properties.Rowset.Value("ReasonCodeID")
  			
  			EventArg.HTMLRendered           = MDMListDialog.PreProcess(HTML_LINK_EDIT)
  			ViewEditMode_DisplayCell        = TRUE
  			
    Case 2
        mdm_NoTurnDownHTML EventArg ' Takes Care Of Removing the TurnDown
	
		Case else
  			ViewEditMode_DisplayCell =  Inherited("Form_DisplayCell()") ' Call the default implementation			
	End Select
	
END FUNCTION


%>

