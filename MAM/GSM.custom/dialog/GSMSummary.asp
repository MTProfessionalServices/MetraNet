<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
<%
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
'  Copyright 1998,2005 by MetraTech Corporation
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
' DIALOG	    :  GSMSummary.asp
' DESCRIPTION	:  GSM Summary
' AUTHOR	    :  Kevin A. Boucher
' VERSION	    :  5.0
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../../MamIncludeMDM.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MamLibrary.asp" -->
<!-- #INCLUDE FILE="../../default/Lib/AccountLib.asp" -->
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" --> 
<%

Form.ServiceMsixdefFileName = mam_GetServiceDefForOperation("ADD") 
Form.RouteTo = mam_GetDictionary("WELCOME_DIALOG")

mdm_Main ' Invoke the MDM framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: Form_Initialize
' PARAMETERS	:
' DESCRIPTION :
' RETURNS		  : Return TRUE if ok else FALSE  `
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean
	Service.Clear 	

	' Save the initial template so we can use it to render a new dynamic template later
  Form("InitialTemplate") = Form.HTMLTemplateSource  

  ' Get Subscriber properties
  MAM().Subscriber.CopyTo Service.Properties
  	
  ' Include Calendar javascript    
  mam_IncludeCalendar
  Service.LoadJavaScriptCode 

  ' Set Title
	mdm_GetDictionary().add "TEXT_GENERIC_SUMMARY_TITLE", Session("SubscriberYAAC").AccountType & " Summary"
	          
 ' Form_Initialize = DynamicTemplate(EventArg) 
  Form_Initialize = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION    :  DynamicTemplate
' PARAMETERS  :  EventArg
' DESCRIPTION :  This function determines what should be placed in the dialog template based on the service def properties
' RETURNS     :  Return TRUE if ok else FALSE
FUNCTION DynamicTemplate(EventArg)
	Dim strHTML
	Dim prop
  Dim strCaptionClass

  ' Setup initial template
  Form.HTMLTemplateSource = Form("InitialTemplate")
  
  Dim nCount
  nCount = 0
  For Each prop in Service.Properties
   
   If prop.Required Then
     strCaptionClass = "captionEWRequired"
   Else
     strCaptionClass = "captionEW"
   End If
   
    If nCount = 0 Then
      strHTML = strHTML & "<TR>"
    End If

    If UCase(prop.name) = "ACTIONTYPE" or _
       UCase(prop.name) = "PASSWORD_" or _
       UCase(prop.name) = "LOGINAPPLICATION" or _       
       UCase(prop.name) = "APPLYDEFAULTSECURITYPOLICY" or _       
       UCase(prop.name) = "APPLYACCOUNTTEMPLATE" or _       
       UCase(prop.name) = "TRUNCATEOLDSUBSCRIPTIONS" or _       
       UCase(prop.name) = "TRANSACTIONCOOKIE" or _       
       UCase(prop.name) = "OPERATION" Then
       ' Skip these properties
       nCount = nCount - 1
            'strHTML = strHTML & "<TD class='"& strCaptionClass &"'><LABEL Name='" & prop.name & "' Type='Caption'>z</LABEL>:</td>"
            'strHTML = strHTML & "<TD><LABEL type='LocalizedValue' class='field' name='" & prop.name & "'></LABEL></TD>"      
    Else   
      Select Case UCase(prop.PropertyType)
        Case "STRING"
            strHTML = strHTML & "<TD class='"& strCaptionClass &"'><LABEL Name='" & prop.name & "' Type='Caption'>z</LABEL>:</td>"
            strHTML = strHTML & "<TD><LABEL type='value' class='field' name='" & prop.name & "'></LABEL></TD>"
        
        Case "ENUM"
            strHTML = strHTML & "<TD class='"& strCaptionClass &"'><LABEL Name='" & prop.name & "' Type='Caption'>z</LABEL>:</td>"
            strHTML = strHTML & "<TD><LABEL type='LocalizedValue' name='" & prop.name & "'></LABEL></TD>"      
        
        Case "INT32"
            strHTML = strHTML & "<TD class='"& strCaptionClass &"'><LABEL Name='" & prop.name & "' Type='Caption'>z</LABEL>:</td>"
            strHTML = strHTML & "<TD><LABEL type='value'  class='field' name='" & prop.name & "'></LABEL></TD>" 
            
        Case "DOUBLE", "DECIMAL"
            strHTML = strHTML & "<TD class='"& strCaptionClass &"'><LABEL Name='" & prop.name & "' Type='Caption'>z</LABEL>:</td>"
            strHTML = strHTML & "<TD><LABEL type='value' class='field' name='" & prop.name & "'></LABEL></TD>" 
            
        Case "TIMESTAMP"
            strHTML = strHTML & "<td class='"& strCaptionClass &"'><label name='" & prop.name & "' type='Caption'>z</label>:</td>"
            strHTML = strHTML & "<td><LABEL type='value' class='field'  name='" & prop.name & "' size='25'></LABEL></td>"
            
        Case "BOOLEAN"
            strHTML = strHTML & "<TD class='captionEW'><LABEL type='Caption' name='" & prop.name & "'></LABEL></td>"
            strHTML = strHTML & "<td><LABEL type='LocalizedValue' class='"& strCaptionClass &"' name='" & prop.name & "'></LABEL></td>"
            
        Case Else
            strHTML = strHTML & prop.name & " - " & prop.PropertyType & "<br>"
      End Select
    End If
    
    nCount = nCount + 1
    If nCount = 2 Then
      strHTML = strHTML & "</TR>"
      nCount = 0
    End If

  Next
	
	'response.write strHTML
	'response.end
	Form.HTMLTemplateSource = Replace(Form.HTMLTemplateSource, "<DYNAMIC_TEMPLATE />", strHTML)
  
  DynamicTemplate = TRUE

END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION    :  Form_Refresh
' PARAMETERS  :  EventArg
' DESCRIPTION :  Loads the DynamicTemplate using the initial saved template
' RETURNS     :  Return TRUE if ok else FALSE
FUNCTION Form_Refresh(EventArg) ' As Boolean
	Form_Refresh = DynamicTemplate(EventArg)
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : Cancel_Click
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
FUNCTION Cancel_Click(EventArg) ' As Boolean
  Form.RouteTo = mam_GetDictionary("WELCOME_DIALOG")
  Cancel_Click = TRUE
END FUNCTION
%>

