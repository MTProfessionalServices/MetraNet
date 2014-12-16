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
' DIALOG	:
' DESCRIPTION	:
' AUTHOR	:
' VERSION	:
'
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Option Explicit 
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../../MamIncludeMDM.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MamLibrary.asp" -->
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" --> 
<%

Form.ServiceMsixdefFileName 	= "metratech.com\AccountCreation.msixdef"
Form.RouteTo			            = mam_GetDictionary("SUBSCRIBER_FIND_BROWSER_POPUP")
Form.ErrorHandler             = TRUE

mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: Form_Initialize
' PARAMETERS		:
' DESCRIPTION 		:
' RETURNS		: Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean
	Dim strUserName, strNameSpace
  
  Service.Clear 	' Set all the property of the service to empty. 
					        ' The Product view if allocated is cleared too.
  
  Service.Properties.Add "Invoice_Number"      , "String" , 128, TRUE, ""        ' Add invoicenumber on the fly
  Service.Properties.Add "HierarchyAccount"    , "String" , 128, TRUE, ""        
	Service.Properties.Add "hierarchyDate"       , "String" , 128, TRUE, ""   
  Service.Properties.Add "Payer"               , "String" , 128, TRUE, ""           

  ' remove required field
  Service.Configuration.CheckRequiredField = FALSE
  
  Service.Properties("Name_Space").AddValidListOfValues "__GET_PRESENTATION_NAME_SPACE_LIST__",,,,mam_GetDictionary("SQL_QUERY_STRING_RELATIVE_PATH")
  Service.Properties("Name_Space").Value = ""
  If Not IsEmpty(Session("HIERARCHY_HELPER")) Then
	  Service.Properties("hierarchyDate") = CDate(mdm_Format(mam_GetHierarchyTime(), mam_GetDictionary("DATE_FORMAT")))
  End If
  
  If Len(request.QueryString("subHierarcy")) Then
      Service.Properties("HierarchyAccount").value = mam_GetFieldIDFromAccountID(CLng(request.QueryString("subHierarcy")))
  End If
  
  'Get output type
  Call Service.Properties.Add("ReturnType", "String", 128, true, Empty)
  
  ' just to prevent localization errors in log
  Service.Properties("Invoice_Number").Caption = "dummy"
  Service.Properties("Payer").Caption = "dummy"

	Service.LoadJavaScriptCode  ' This line is important to get JavaScript field validation
	
  ' Include Calendar javascript    
  mam_IncludeCalendar
	             
  if UCase(request.queryString("Action")) = "CLOSE" then
    response.write "<script language=""Javascript"">" & vbNewline
    response.write "  window.close();" & vbNewline
    response.write "</script>" & vbNewline
  end if
               
	Form_Initialize = TRUE
END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION: Form_Ok
' PARAMETERS:
' DESCRIPTION:
' RETURNS: Return TRUE if ok else FALSE
PRIVATE FUNCTION Ok_Click(EventArg) ' As Boolean
  on error resume next
  
  Dim strRouteto, HierarchyAccountID, strDate, PayerID, strSEID
  
  strRouteto = strRouteto & AddSearchFieldToQueryString(Service.Properties("_AccountID"),               "_AccountID")   
  strRouteto = strRouteto & AddSearchFieldToQueryString(Service.Properties("USERNAME"),                 "USERNAME") 
  strRouteto = strRouteto & AddSearchFieldToQueryString(Service.Properties("NAME_SPACE"),               "NAME_SPACE") 
  strRouteto = strRouteto & AddSearchFieldToQueryString(Service.Properties("CITY"),                     "CITY") 
  strRouteto = strRouteto & AddSearchFieldToQueryString(Service.Properties("STATE"),                    "STATE") 
  strRouteto = strRouteto & AddSearchFieldToQueryString(Service.Properties("ZIP"),                      "ZIP") 
  strRouteto = strRouteto & AddSearchFieldToQueryString(Service.Properties("LASTNAME"),                 "LASTNAME") 
  strRouteto = strRouteto & AddSearchFieldToQueryString(Service.Properties("FIRSTNAME"),                "FIRSTNAME") 
  strRouteto = strRouteto & AddSearchFieldToQueryString(Service.Properties("EMAIL"),                    "EMAIL") 
  strRouteto = strRouteto & AddSearchFieldToQueryString(Service.Properties("PHONENUMBER"),              "PHONENUMBER") 
  strRouteto = strRouteto & AddSearchFieldToQueryString(Service.Properties("COMPANY"),                  "COMPANY") 
  strRouteto = strRouteto & AddSearchFieldToQueryString(Service.Properties("ADDRESS1"),                 "ADDRESS1") 
  strRouteto = strRouteto & AddSearchFieldToQueryString(Service.Properties("ADDRESS2"),                 "ADDRESS2") 
  strRouteto = strRouteto & AddSearchFieldToQueryString(Service.Properties("ADDRESS3"),                 "ADDRESS3") 
  strRouteto = strRouteto & AddSearchFieldToQueryString(Service.Properties("facsimiletelephonenumber"), "facsimiletelephonenumber") 
  strRouteto = strRouteto & AddSearchFieldToQueryString(Service.Properties("INVOICE_NUMBER"),           "INVOICE") 
    
  ' PayerID
  If FrameWork.DecodeFieldID(Service.Properties("Payer").value, PayerID) Then
    strRouteto = strRouteto & AddSearchFieldToQueryString(PayerID, "PayerID") 
  End IF
    
  ' Hierarchy
  If FrameWork.DecodeFieldID(Service.Properties("HierarchyAccount"), HierarchyAccountID) Then
    strRouteto = strRouteto & AddSearchFieldToQueryString(HierarchyAccountID, "_HierarchyAccountID") 
  End IF
    
   
  If(Len(strRouteto)=0)Then
  
      EventArg.Error.Description = FrameWork.GetHTMLDictionaryError("MAM_ERROR_1008")
  		OK_Click      = FALSE
  Else

      If Len(Service.Properties("hierarchyDate").value) = 0 Then
        strDate = mam_GetGMTEndOfTheDayFormatted()
      Else
        strDate = Service.Properties("hierarchyDate") & " " & mam_GetDictionary("END_OF_DAY")
      End If
      
      strRouteto    = mam_GetDictionary("SUBSCRIBER_FIND_BROWSER_POPUP") & "?NextPage=Dummy&SearchDate=" & CDate(strDate) & "&ShowBackSelectionButton=TRUE&AdvancedFind=TRUE" & strRouteto
      
      Form.RouteTo  = strRouteto    
      
      If(CBool(Err.Number = 0)) then
          On Error Goto 0
          OK_Click = TRUE
      Else        
          EventArg.Error.Save Err  
          OK_Click = FALSE
      End If      
  End If
  
  
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION: AddSearchFieldToQueryString
' PARAMETERS: value to search on, and type to search
' DESCRIPTION:
' RETURNS: Return query string to pass to find browser
FUNCTION AddSearchFieldToQueryString(strValue, strSearchOn) ' as string
  
  If(Len(strValue) > 0) Then
  
      AddSearchFieldToQueryString = "&Value=" & server.URLEncode(strValue)
      AddSearchFieldToQueryString = AddSearchFieldToQueryString & "&SearchOn=" & server.URLEncode(strSearchOn)
  Else
      AddSearchFieldToQueryString = ""
  End If
  
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION: Clear_Click
' PARAMETERS:
' DESCRIPTION:
' RETURNS: Return TRUE if ok else FALSE
FUNCTION Clear_Click(EventArg) ' As Boolean
  Service.clear
	Clear_Click = TRUE
END FUNCTION

FUNCTION Cancel_Click(EventArg) ' As Boolean
  Form.RouteTo			            = mam_GetDictionary("SUBSCRIBER_FIND_POPUP") & "?Action=Close"
  Cancel_Click                  = TRUE
END FUNCTION
%>


