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
' DIALOG	    : PVBGeneric - Product View Browser Generic
' DESCRIPTION	:
' AUTHOR	    : F.Torres
' VERSION	    : 
'
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
'Option Explicit
'<!-- #INCLUDE VIRTUAL="/mdm/mdm.asp" -->

%>

<%
Form.RouteTo			                  =  mdm_UIValueDefault("RouteTo",Empty)
Form.Page.MaxRow                    =  mdm_UIValueDefault("MaxRowPerPage",40)
Form.ProductViewMsixdefFileName 	  =  mdm_UIValueDefault("ProductViewMSIXDefFile","")
Form.HTMLTemplateFileName           =  "PVBGeneric.htm"


mdm_PVBrowserMain ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: Form_Initialize
' PARAMETERS	:
' DESCRIPTION :
' RETURNS		  : Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean

    mdm_GetDictionary().Add "PVBGENERIC_TITLE", mdm_UIValueDefault("Title",Form.ProductViewMsixdefFileName)
    
    Form("ACCOUNTID") = mdm_UIValueDefault("AccountID",123)

    Form_Initialize = PVBGeneric_Initialize(EventArg) ' call the customized event
END FUNCTION

PRIVATE FUNCTION Form_LoadProductView(EventArg) ' As Boolean
    
    Form_LoadProductView = FALSE
    
    ' Load the interval id rowset - The MDM PVBrowser
    If (Not ProductView.Properties.Interval.Load(Clng(Form("ACCOUNTID")))) Then Exit Function

    Form_LoadProductView  = ProductView.Properties.Load()
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: PVBGeneric_Initialize
' PARAMETERS	:
' DESCRIPTION : Default event in case it is not implemented; Implement both event to support inheritance...
' RETURNS		  : Return TRUE if ok else FALSE
PUBLIC FUNCTION inheritedPVBGeneric_Initialize(EventArg) ' As Boolean

    ProductView.Properties.SelectAll
    
    If(ProductView.Properties.Exist("mdmIntervalId"))Then
    
        ProductView.Properties("mdmIntervalId").Selected = 0 ' Never selected
    End If    
    inheritedPVBGeneric_Initialize = TRUE
END FUNCTION

PUBLIC FUNCTION PVBGeneric_Initialize(EventArg) ' As Boolean

    PVBGeneric_Initialize = inheritedPVBGeneric_Initialize(EventArg)
END FUNCTION


FUNCTION PVBGeneric_ConvertNameIntoFunction(strFName) ' as String

  Dim strName
  
  strName = strFName
  strName = Replace(strName,".","_")
  strName = Replace(strName,"\","_")
  strName = Replace(strName,"/","_")
  
  PVBGeneric_ConvertNameIntoFunction =   strName
END FUNCTION


%>
