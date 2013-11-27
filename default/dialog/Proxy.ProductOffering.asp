<!-- #INCLUDE FILE="../../MCMIncludes.asp" -->
<%
  Response.Buffer = TRUE
  
     Dim objMTProductCatalog1, objMTPriceableItem1,objMTProductOffering1
     dim strPickerIDs1, arrPickerIDs1
	 dim i1
	 
	 if len(request("UpdateAccountRestrictions"))<>0 then
 	 '//Update Product Offering by adding subscription restrictions
		If len(Request("PICKERIDS")) <> 0 Then
	    
			'Dim objMTProductCatalog1, objMTPriceableItem1,objMTProductOffering1

			'mcmTriggerUpdateOfPONavigationPane
	  
			Set objMTProductCatalog1 = GetProductCatalogObject
			Set objMTProductOffering1  = objMTProductCatalog1.GetProductOffering(Request.QueryString("POID"))

			'dim strPickerIDs1, arrPickerIDs1
			strPickerIDs1 = request("PICKERIDS")
			arrPickerIDs1 = Split(strPickerIDs1, ",", -1, 1)
			'dim intPriceableItemId1
			'dim i1
			for i1=0 to ubound(arrPickerIDs1)
			  'response.write("Eventually UpdateAccountRestrictions on this PO with id [" & CLng(arrPickerIDs1(i1)) & "]")			
			  objMTProductOffering1.AddSubscribableAccountType CLng(arrPickerIDs1(i1))
			next 
	        
			On Error Resume Next
			'objMTProductOffering1.Save
		else
		 '//Nothing specified
		 
		end if
		'response.end
		response.redirect("ProductOffering.Viewedit.SubscriptionRestrictions.asp?Tab=2&ID=" & request.querystring("POID"))

	 else
	 '//Update Product Offering by adding priceable items
		If len(Request("PICKERIDS")) <> 0 Then
	    

			mcmTriggerUpdateOfPONavigationPane
	  
			Set objMTProductCatalog1 = GetProductCatalogObject
			Set objMTProductOffering1  = objMTProductCatalog1.GetProductOffering(Request.QueryString("POID"))

			'dim strPickerIDs1, arrPickerIDs1
			strPickerIDs1 = request("PICKERIDS")
			arrPickerIDs1 = Split(strPickerIDs1, ",", -1, 1)
			dim intPriceableItemId1
			'dim i1
			for i1=0 to ubound(arrPickerIDs1)
								intPriceableItemId1 = CLng(arrPickerIDs1(i1))
								'response.write("Adding PI [" & intPriceableItemId & "]<BR>")
								set objMTPriceableItem1 = objMTProductCatalog1.GetPriceableItem(intPriceableItemId1)
					          
								On Error Resume Next
								objMTProductOffering1.AddPriceableItem objMTPriceableItem1
								If(Err.number)Then
	              
										EventArg.Error.Save Err
										Set Session(mdm_EVENT_ARG_ERROR) =  EventArg ' UnDocumented way to pass an error to the next dialog
										response.redirect("ProductOffering.Viewedit.Items.asp?ID=" & request.querystring("POID"))
								End If                  
				next 
	        
			On Error Resume Next
			objMTProductOffering1.Save
			If(err.number)Then
				EventArg.Error.Save Err
				Set Session(mdm_EVENT_ARG_ERROR) = EventArg ' UnDocumented way to pass an error to the next dialog
			End If        
		End If
	    
		response.redirect("ProductOffering.Viewedit.Items.asp?Tab=1&ID=" & request.querystring("POID"))
	End If
	
%>