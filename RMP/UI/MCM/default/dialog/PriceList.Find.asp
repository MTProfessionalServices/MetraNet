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
' MetraTech Dialog Manager Demo
' 
' DIALOG	    : MCM Dialog
' DESCRIPTION	: 
' AUTHOR	    : F.Torres
' VERSION	    : 1.0
'
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../MCMIncludes.asp" -->

<%
Form.Version        = MDM_VERSION     ' Set the dialog version - we are version 2.0.
FOrm.ErrorHandler   = TRUE
Form.RouteTo        = FrameWork.GetDictionary("PRODUCT_OFFERING_LIST_DIALOG")

mdm_Main ' invoke the mdm framework


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : Form_Initialize
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean

	Service.Clear 	' Set all the property of the service to empty. 
					        ' The Product view if allocated is cleared too.
                  
  Service.Properties.Add "FIND_NAME"     , "string", 0, False , Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "FIND_DESCRIPTION"     , "string", 0, False , Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "FIND_CURRENCY"     , "string", 0, False , Empty, eMSIX_PROPERTY_FLAG_NONE
	Service.Properties("FIND_CURRENCY").SetPropertyType "ENUM","Global/SystemCurrencies","SystemCurrencies"
	Service.Properties("FIND_CURRENCY").Value = ""

  Service.Properties.Add "FIND_PARAMTABLEID"     , "string", 5, False , Empty, eMSIX_PROPERTY_FLAG_NONE

  Service.Properties.Add "InitiallyExpanded"     , "string", 50, False , Empty, eMSIX_PROPERTY_FLAG_NONE
  
  '//Used to set the correct javascript on the page
  if (request("State")="Collapsed") then
    Service.Properties("InitiallyExpanded").Value = "false"
  else
    Service.Properties("InitiallyExpanded").Value = "true"
  end if
  
  'Service.Properties.Add "tx_desc"      , "string", 255, TRUE, Empty, eMSIX_PROPERTY_FLAG_NONE
  'Service.Properties.Add "tx_typ_space" , "string", 40 , TRUE , Empty, eMSIX_PROPERTY_FLAG_NONE

  Service.JavaScriptCode  = "" ' We do not want the java script in that dialog because the interception of the key
                               ' Enter and Escape give us trouble because they invoke directly


  Form_Initialize = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : OK_Click
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Ok_Click(EventArg) ' As Boolean
  On Error Resume Next

    Dim booRetVal   
    
    Session("FIND_PL_NAME") =  Service("FIND_NAME")
    Session("FIND_PL_DESCRIPTION") =  Service("FIND_DESCRIPTION")
    Session("FIND_PL_CURRENCY") =  Service("FIND_CURRENCY")
    Session("FIND_PL_PARAMTABLEID") =  Service("FIND_PARAMTABLE_ID")
    
    If(booRetVal) then
        
        OK_Click = TRUE
    Else            
        'EventArg.Error.Description = mom_GetDictionary("MOM_ERROR_1006")
        OK_Click = FALSE
    End If
    Err.Clear   
    
END FUNCTION

%>



