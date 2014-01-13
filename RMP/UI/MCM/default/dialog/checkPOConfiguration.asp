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
Form.ErrorHandler   = TRUE

mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : Form_Initialize
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean

  Dim objMTProductCatalog, objMTProductOffering
  
  If(Not IsEmpty(Request.QueryString("ID")))Then
    Form("ID") = CLng(Request.QueryString("ID"))
  End if
  
  GetProductOffering TRUE
  
  Set objMTProductCatalog                         = Server.CreateObject(MTProductCatalog)
  Set objMTProductOffering                        = objMTProductCatalog.GetProductOffering(Form("ID"))
  'SECENG: Fixing problems with output encoding
  Service.Properties.Add "checkPoConf_name", "String",  1024, FALSE, TRUE
  Service.Properties("checkPoConf_name") = SafeForHtml(COMObject.Instance.Name)
  
  ' Check to see if this PO is complete
  Dim configurationErrors
  Set configurationErrors = objMTProductOffering.CheckConfiguration()
  If configurationErrors.count > 0 Then
  
    Dim strErrorList
    Dim strError
    Dim i
    
    ' Build error string
    For i = 1 to configurationErrors.count
      strErrorList = strErrorList & configurationErrors.item(i) & "<br>"
    Next
    
    COMObject.Properties.Add "ERROR_STRING", "string", 65536, FALSE, ""
    COMObject.Properties("ERROR_STRING").Value = strErrorList
    
    mdm_GetDictionary().Add "CONFIGURATION_NOT_COMPLETE", "TRUE"

  Else
    COMObject.Properties.Add "ERROR_STRING", "string", 0, FALSE, ""
    COMObject.Properties("ERROR_STRING").Value = FrameWork.GetDictionary("TEXT_GOOD_CONFIGURATION")
    
    mdm_GetDictionary().Add "CONFIGURATION_NOT_COMPLETE", "FALSE"  
  End If

  Form_Initialize = TRUE
END FUNCTION


PRIVATE FUNCTION GetProductOffering(booFromInitializeEvent) ' As Boolean

    Dim objMTProductCatalog, objMTProductOffering
  
    Set objMTProductCatalog                         = Server.CreateObject(MTProductCatalog)
    Set objMTProductOffering                        = objMTProductCatalog.GetProductOffering(Form("ID"))
    Set COMObject.Instance(booFromInitializeEvent)  = objMTProductOffering 
    GetProductOffering                              = TRUE
END FUNCTION

%>
