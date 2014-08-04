<!-- #INCLUDE FILE="../../MCMIncludes.asp" -->
<%
  Response.write "<SCRIPT language='JavaScript' src='/mpte/shared/browsercheck.js'></SCRIPT>"
  Response.write "<SCRIPT language='JavaScript' src='/mdm/internal/mdm.JavaScript.lib.js'></SCRIPT>"
	  Dim objMTProductCatalog1, objMTPriceableItem1,objMTProductOffering1, targetPage

    ' See if we need to Add a recurring charge
    If len(Request("AddItem")) <> 0 Then
        'response.write("Adding recurring charge<BR>")
        dim intRecurringChargeId1
        intRecurringChargeId1 = Clng(Request("AddItem"))
  
        Set objMTProductCatalog1 = GetProductCatalogObject
        Set objMTProductOffering1  = objMTProductCatalog1.GetProductOffering(Request.QueryString("ID"))
        
        Set objMTPriceableItem1 = objMTProductCatalog1.GetPriceableItem(intRecurringChargeId1)
        
				On Error Resume Next
        objMTProductOffering1.AddPriceableItem objMTPriceableItem1
						If(Err.number)Then
    							EventArg.Error.Save Err
									Set Session(mdm_EVENT_ARG_ERROR) =  EventArg ' UnDocumented way to pass an error to the next dialog
						End If
				
        mcmTriggerUpdateOfPONavigationPane
        
				 On Error Resume Next		                  
	        objMTProductOffering1.Save
         If(err.number)Then
						EventArg.Error.Save Err
						Set Session(mdm_EVENT_ARG_ERROR) = EventArg ' UnDocumented way to pass an error to the next dialog
				 End If        
	  End If
	
		If(Session("POMode") = "1") Then
			targetPage = FrameWork.GetDictionary("PRODUCT_OFFERING_VIEW_EDIT_ITEMS_DIALOG")
		Else
			targetPage = FrameWork.GetDictionary("PRODUCTOFFERING_VIEW_EDIT_DIALOG")
		End If	
		
	' java script refresh parent		
		Response.write "<SCRIPT language='JavaScript'>"
		Response.write "window.opener.location = AddToQueryString('" + targetPage + "' ,'mdmAction=Refresh');"
		Response.write "window.close();" & vbCRLF
		Response.write "</SCRIPT>" 


%>