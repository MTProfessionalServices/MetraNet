 <% 
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile$
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
'  $Date$
'  $Author$
'  $Revision$
'
' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
'
' CLASS       : 
' DESCRIPTION : 
' ---------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../MCMIncludes.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/common/mdmList.Library.asp" -->
<!-- #INCLUDE FILE="../lib/ScriptIncludes.html" -->
<%

' If passoword is expiring soon, redirect to change password page
If Session("IsPasswordExpiringSoon") = TRUE Then
  Response.Redirect "DefaultDialogChangePassWord.asp"
End If

Form.Version        = MDM_VERSION     ' Set the dialog version - we are version 2.0.
Form.ErrorHandler   = FALSE

mdm_PVBrowserMain ' invoke the mdm framework

PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean
	  Form_Initialize = MDMListDialog.Initialize(EventArg)
    
    'SECENG: Encoding added
    Form("FIND_NAME") = SafeForHtml(request("FIND_NAME"))
    Form("FIND_DISPLAYNAME") = SafeForHtml(request("FIND_DISPLAYNAME"))
    Form("FIND_DESCRIPTION") = SafeForHtml(request("FIND_DESCRIPTION"))
    
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  Form_LoadProductView
' PARAMETERS:  EventArg
' DESCRIPTION: 
' RETURNS:  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_LoadProductView(EventArg) ' As Boolean

  Dim objMTProductCatalog, b_delete, objMTFilter
  Form_LoadProductView = FALSE
  
	b_delete = false 'Deleting PO has moved to actions on PO screen -- FrameWork.CheckCoarseCapability("Delete Product Offerings")
	
  Set objMTProductCatalog = GetProductCatalogObject
	
  ' Load a Rowset from a SQL Queries and build the properties collection of the product view based on the columns of the rowset
  Set objMTFilter = mdm_CreateObject("MTSQLRowset.MTDataFilter.1")
  objMTFilter.Add "Hidden", OPERATOR_TYPE_EQUAL, "N"
  'objMTFilter.Add "currency", OPERATOR_TYPE_EQUAL, "USD"
  
  '//Set filter criteria based on search values passed in
  Form("FIND_NAME") = mcm_DefaultFilterValueHandler(Form("FIND_NAME"))
  Form("FIND_DISPLAYNAME") = mcm_DefaultFilterValueHandler(Form("FIND_DISPLAYNAME"))
  Form("FIND_DESCRIPTION") = mcm_DefaultFilterValueHandler(Form("FIND_DESCRIPTION"))
  
  dim strFilterMessage
  if len(Form("FIND_NAME"))>0 then
    objMTFilter.Add "Name", MT_OPERATOR_TYPE_LIKE, Cstr(Form("FIND_NAME"))
    strFilterMessage= strFilterMessage & "Where name is '" & Form("FIND_NAME") & "'"
  end if

  if len(Form("FIND_DISPLAYNAME"))>0 then
    objMTFilter.Add "DisplayName", MT_OPERATOR_TYPE_LIKE, Cstr(Form("FIND_DISPLAYNAME"))
    strFilterMessage= strFilterMessage & "Where display name is '" & Form("FIND_DISPLAYNAME") & "'"
  end if

  if len(Form("FIND_DESCRIPTION"))>0 then
    objMTFilter.Add "Description", MT_OPERATOR_TYPE_LIKE, Cstr(Form("FIND_DESCRIPTION"))
    strFilterMessage= strFilterMessage & "Where description is '" & Form("FIND_DESCRIPTION") & "'"
  end if
  
  Set ProductView.Properties.RowSet = objMTProductCatalog.FindProductOfferingsAsRowset(objMTFilter)

  if ProductView.Properties.RowSet.RecordCount = 1 then
    'mdm_TerminateDialogAndExecuteDialog mam_GetDictionary("SUBSCRIBER_FOUND") & "?AccountId=" & MAM().Subscriber.RowSet.Value("_AccountId") & "&ShowBackSelectionButton=FALSE"
  end if
  
  
  ProductView.Properties.ClearSelection                       ' Select the properties I want to print in the PV Browser   Order
  'ProductView.Properties.SelectAll
  ProductView.Properties("nm_name").Selected 			      = 1
  ProductView.Properties("nm_desc").Selected 	          = 2
  ProductView.Properties("nm_currency_code").Selected 	= 3
	If b_delete Then
		ProductView.Properties("n_name").Selected 			    = 4
	End If

  ProductView.Properties("nm_name").Caption 		        = FrameWork.GetDictionary("TEXT_COLUMN_NAME")
  ProductView.Properties("nm_desc").Caption 	          = FrameWork.GetDictionary("TEXT_COLUMN_DESCRIPTION")
  ProductView.Properties("nm_currency_code").Caption 	  = FrameWork.GetDictionary("TEXT_CURRENCY")
	If b_delete Then	
 		ProductView.Properties("n_name").Caption 	         	= FrameWork.GetDictionary("TEXT_COLUMN_OPTIONS")
	End If
   
  ProductView.Properties("nm_name").Sorted              = MTSORT_ORDER_ASCENDING

  '//Add filter message if used
  ProductView.Properties.Add "FilterMessage", "string", 0, False, 0, eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET
  ProductView.Properties("FilterMessage").Value = strFilterMessage
  
  'Set Form.Grid.FilterProperty                          = ProductView.Properties("nm_name") ' Set the property on which to apply the filter  
  Form.Grid.FilterMode=false
  
  Form_LoadProductView                                  = TRUE ' Must Return TRUE To Render The Dialog
  
END FUNCTION


PUBLIC FUNCTION LinkColumnMode_DisplayCell(EventArg) ' As Boolean

	Dim m_objPP, HTML_LINK_EDIT , strValue , strFormat, lngPos, strParameter 
	  
  Select Case Form.Grid.Col
  	Case 1,2
      mdm_NoTurnDownHTML EventArg ' Takes Care Of Removing the TurnDown
			
		Case 3 ' We need to explicitly tell the method how to display the link
			Inherited("Form_DisplayCell()")
			lngPos                = InStr(EventArg.HTMLRendered,">") ' Find the first >
			EventArg.HTMLRendered = MDMListDialog.Tools.InsertAStringAt(EventArg.HTMLRendered,"<A Name='Link[ID]' HREF='[URL]?ID=[ID][PARAMETERS]' target='ticketFrame'>",lngPos+1) ' Insert after >
			EventArg.HTMLRendered = Replace(EventArg.HTMLRendered,"</td>","</a></td>")
            
			MDMListDialog.PreProcessor.Clear
			MDMListDialog.PreProcessor.Add "URL" , Form("NextPage")
			MDMListDialog.PreProcessor.Add "ID"  , ProductView.Properties.Rowset.Value(MDMListDialog.GetIDColumnName())
			EventArg.HTMLRendered = MDMListDialog.PreProcess(EventArg.HTMLRendered)			
	
		Case 6
			HTML_LINK_EDIT = ""
			HTML_LINK_EDIT = HTML_LINK_EDIT & "<td nowrap align='center' class='[CLASS]'>"
			HTML_LINK_EDIT = HTML_LINK_EDIT & "<button name='delete[ID]' class='clsButtonBlueMedium' onclick=""OpenDialogWindow('[DELETE_POPUP]?ID=[ID]','_blank', 'height=50,width=100,resizable=yes,scrollbars=yes');"">[DELETE_BUTTON]</button>"
			HTML_LINK_EDIT = HTML_LINK_EDIT & "</td>"
	
			MDMListDialog.PreProcessor.Clear
			MDMListDialog.PreProcessor.Add "CLASS"						, Form.Grid.CellClass        
			MDMListDialog.PreProcessor.Add "DELETE_POPUP"			, FrameWork.GetDictionary("PRODUCTOFFERING_DELETE_DIALOG")
			MDMListDialog.PreProcessor.Add "DELETE_BUTTON"		, FrameWork.GetDictionary("TEXT_DELETE")
			MDMListDialog.PreProcessor.Add "ID"								, ProductView.Properties.Rowset.Value("id_prop")
			EventArg.HTMLRendered = MDMListDialog.PreProcess(HTML_LINK_EDIT)
			
			LinkColumnMode_DisplayCell        = TRUE
		Case else
			LinkColumnMode_DisplayCell =  Inherited("Form_DisplayCell()") ' Call the default implementation
			
	End Select
	
END FUNCTION

%>
