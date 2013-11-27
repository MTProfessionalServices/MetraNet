<%
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile: BillingGroupWarnings.asp$
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
' ---------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/mdm.asp" -->
<!-- #INCLUDE FILE="../../default/lib/momLibrary.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/FrameWork/CFrameWork.Class.asp" -->
<%

Form.RouteTo = mom_GetDictionary("WELCOME_DIALOG")

mdm_PVBrowserMain

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:    Form_Initialize
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:     Return TRUE if ok else FALSE
FUNCTION Form_Initialize(EventArg) 

  ProductView.Clear  
  ProductView.Properties.Flags = eMSIX_PROPERTIES_FLAG_PRODUCTVIEW
  
  If Len(Request.QueryString("MaterializationID")) > 0 Then
    Form("MaterializationID") = Request.QueryString("MaterializationID")
  End If

  Form_Initialize = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:    Form_LoadProductView
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:     Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_LoadProductView(EventArg) ' As Boolean
  
  Dim objUSM
  Set objUSM = mom_GetUsageServerClientObject()

  Set ProductView.Properties.RowSet = objUSM.GetMaterializationReassignmentWarnings(CLng(Form("MaterializationID")))
  ProductView.Properties.AddPropertiesFromRowset ProductView.Properties.RowSet
  ProductView.Properties.ClearSelection
  
  ' Setup columns
  dim i
  i = 1
  
	ProductView.Properties("DisplayName").Selected = i : i=i+1  
	ProductView.Properties("AccountID").Selected	 = i : i=i+1
  ProductView.Properties("UserName").Selected    = i : i=i+1
	ProductView.Properties("Namespace").Selected   = i : i=i+1
  ProductView.Properties("Description").Selected = i : i=i+1
           
	ProductView.Properties("DisplayName").Caption = "Account"  
	ProductView.Properties("AccountID").Caption		= "Account ID"
  ProductView.Properties("UserName").Caption		= "User Name"
	ProductView.Properties("Namespace").Caption	  = "Namespace"
  ProductView.Properties("Description").Caption = "Description"
  
  ProductView.Properties("DisplayName").Sorted = MTSORT_ORDER_ASCENDING
  mdm_SetMultiColumnFilteringMode TRUE 
  
  Form_LoadProductView = TRUE  

END FUNCTION  

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:    Form_DisplayCell
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:     Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_DisplayCell(EventArg) ' As Boolean
  
  Select Case Form.Grid.Col
  
    Case 2
        Form_DisplayCell = Inherited("Form_DisplayCell(EventArg)")
      
		Case else
			Form_DisplayCell = Inherited("Form_DisplayCell(EventArg)")
      
	End Select

END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:    Form_DisplayEndOfPage
' PARAMETERS:  EventArg
' DESCRIPTION: Override end of table to place add button
' RETURNS:     Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_DisplayEndOfPage(EventArg) ' As Boolean

    Dim html
    html = html & "</table><div align=center><BR><BR>"
    html = html & "<button  name='CLOSE' Class='clsOkButton' onclick='window.close();'>Close</button>"
    html = html & "</FORM></BODY></HTML>"
    
    ' Here we must not forget to concat rather than set because we want to keep the result of the inherited event.
    EventArg.HTMLRendered = EventArg.HTMLRendered & REPLACE(html,"[LOCALIZED_IMAGE_PATH]",mom_GetLocalizeImagePath())
    
    Form_DisplayEndOfPage = TRUE
END FUNCTION

%>



