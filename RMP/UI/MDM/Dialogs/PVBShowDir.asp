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
' DIALOG	:
' DESCRIPTION	:
' AUTHOR	:
' VERSION	:
'
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/mdm.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MamLibrary.asp" -->
<%
Form.RouteTo			                  =  mam_GetDictionary("WELCOME_DIALOG")
Form.Page.MaxRow                    =  CLng(mam_GetDictionary("PV_ROW_PER_PAGE"))

mdm_PVBrowserMain ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: Form_Initialize
' PARAMETERS	:
' DESCRIPTION 	:
' RETURNS		: Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean  

    Service.Properties.Add "FileName"     , "String" , 255 , False,   ""
    Service.Properties.Add "FullFileName" , "String" , 255 , False,   ""
    
    ' Select the properties I want to print in the PV Browser   Order
	  ProductView.Properties.ClearSelection
    ProductView.Properties("FileName").Selected 			      = 1
	  ProductView.Properties("FullFileName").Selected 	      = 2    
    
    Form_Initialize = TRUE
END FUNCTION    


PRIVATE FUNCTION Form_LoadProductView(EventArg) ' As Boolean
    
    Set ProductView.Properties.Rowset = mdm_CreateObject(MTSQLROWSETSIMULATOR_PROG_ID)
    ProductView.Properties.Rowset.LoadFolder "c:\temp", "*.*"    
    ProductView.Properties.Flags      = eMSIX_PROPERTIES_FLAG_PRODUCTVIEW
    Form_LoadProductView = TRUE
END FUNCTION


%>
