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
' DIALOG	    :  GSMUpdate.asp
' DESCRIPTION	:  GSM Update Account
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

Form.ServiceMsixdefFileName = mam_GetServiceDefForOperation("Update") 
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
  
  ' Set common update properties
  Service.Properties("ActionType").value = Service.Properties("ActionType").EnumType.Entries("Both").Value
  Service.Properties("Operation").Value = Service.Properties("Operation").EnumType.Entries("Update").Value
    
  ' Include Calendar javascript    
  mam_IncludeCalendar
  Service.LoadJavaScriptCode 

  ' Set Title
	mdm_GetDictionary().add "TEXT_GENERIC_UPDATE_ACCOUNT_TITLE", Session("MAM_DYNAMIC_TITLE")
	          
  'Form_Initialize = DynamicTemplate(EventArg) 
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
	
  ' Set Title
	mdm_GetDictionary().add "TEXT_GENERIC_UPDATE_ACCOUNT_TITLE", Session("MAM_DYNAMIC_TITLE")

  Dim nCount
  nCount = 0
  For Each prop in Service.Properties

   If nCount = 0 Then
     strHTML = strHTML & "<TR>"
   End If
       
   If prop.Required Then
     strCaptionClass = "captionEWRequired"
   Else
     strCaptionClass = "captionEW"
   End If
  
    If UCase(prop.name) = "ACTIONTYPE" or _
       UCase(prop.name) = "OPERATION" or _
       UCase(prop.name) = "_ACCOUNTID" or _      
       UCase(prop.name) = "ACCOUNTTYPE" Then
            ' Properties for display only
            strHTML = strHTML & "<TD class='"& strCaptionClass &"'><LABEL Name='" & prop.name & "' Type='Caption'>z</LABEL>:</td>"
            strHTML = strHTML & "<TD><LABEL type='LocalizedValue' class='field' name='" & prop.name & "'></LABEL></TD>"      
    Else 
      Select Case UCase(prop.PropertyType)
        Case "STRING"
            strHTML = strHTML & "<TD class='"& strCaptionClass &"'><LABEL Name='" & prop.name & "' Type='Caption'>z</LABEL>:</td>"
          If UCase(prop.name) = "PASSWORD_" Then
            strHTML = strHTML & "<TD><INPUT type='password' class='field' name='" & prop.name & "'></TD>"          
          Else
            strHTML = strHTML & "<TD><INPUT type='text' class='field' name='" & prop.name & "'></TD>"
          End IF
        
        Case "ENUM"
            strHTML = strHTML & "<TD class='"& strCaptionClass &"'><LABEL Name='" & prop.name & "' Type='Caption'>z</LABEL>:</td>"
            strHTML = strHTML & "<TD><select name='" & prop.name & "'></select></TD>"      
        
        Case "INT32"
            strHTML = strHTML & "<TD class='"& strCaptionClass &"'><LABEL Name='" & prop.name & "' Type='Caption'>z</LABEL>:</td>"
            strHTML = strHTML & "<TD><INPUT type='text' class='field' name='" & prop.name & "'></TD>" 
            
        Case "DOUBLE", "DECIMAL"
            strHTML = strHTML & "<TD class='"& strCaptionClass &"'><LABEL Name='" & prop.name & "' Type='Caption'>z</LABEL>:</td>"
            strHTML = strHTML & "<TD><INPUT type='text' class='field' name='" & prop.name & "'></TD>" 
            
        Case "TIMESTAMP"
            strHTML = strHTML & "<td class='"& strCaptionClass &"'><label name='" & prop.name & "' type='Caption'>z</label>:</td>"
            strHTML = strHTML & "<td><input class='field' type='Text' name='" & prop.name & "' size='25'>"
            strHTML = strHTML & "<a href='#' onClick=""getCalendarForTimeOpt(document.mdm." & prop.name & ", '', false);return false;""><img src='/mam/default/localized/en-us/images/popupcalendar.gif' width='16' height='16' border='0' alt=''></a></td>"
            
        Case "BOOLEAN"
            strHTML = strHTML & "<TD class='captionEW'></td>"
            strHTML = strHTML & "<td><input type='CheckBox' name='" & prop.name & "'><label class='"& strCaptionClass &"' name='" & prop.name & "' type='Caption'>z:</label></td>"
            
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
' FUNCTION 		: OK_Click
' PARAMETERS	:
' DESCRIPTION :
' RETURNS		  : Return TRUE if ok else FALSE
FUNCTION OK_Click(EventArg) ' As Boolean

    OK_Click = FALSE
  
    mam_Account_SetToEmptyAllTheEmptyStringValue
      
    On Error Resume Next        
    Service.Meter TRUE
    If Err.Number Then
      
        mdm_MeteringTimeOutManager  Service , _
                              FrameWork.Dictionary.Item("METERING_TIME_OUT_MANAGER_DIALOG").Value , _
                              FrameWork.Dictionary.Item("TEXT_METERING_TIME_OUT_OPERATION_TIME_OUT").Value , _
                              FrameWork.Dictionary.Item("TEXT_METERING_TIME_OUT_OPERATION_SUCCEEDED").Value , _
                              FrameWork.Dictionary.Item("TEXT_METERING_TIME_OUT_OPERATION_WILL_BE_EXECUTED_LATED").Value , _
                              Form.RouteTo    
    
        EventArg.error.Save Err
        Err.Clear
    Else
        
        ' Success
        Form.RouteTo = mam_ConfirmDialogEncodeAllURL(Session("MAM_DYNAMIC_TITLE") & " " & mam_GetDictionary("TEXT_SUCCESSFUL"), mam_GetDictionary("TEXT_INFO_SUCCEFULLY_UPDATED"), mam_GetDictionary("SUBSCRIBER_FOUND") & "?AccountID=" & Service.Properties("_AccountID"))
         
        OK_Click = TRUE
    End If
    On Error Goto 0      

END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: Cancel_Click
' PARAMETERS	:
' DESCRIPTION :
' RETURNS		  : Return TRUE if ok else FALSE
FUNCTION Cancel_Click(EventArg) ' As Boolean
  Form.RouteTo = mam_GetDictionary("WELCOME_DIALOG")
  Cancel_Click = TRUE
END FUNCTION
%>

