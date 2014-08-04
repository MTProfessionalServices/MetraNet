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
' DIALOG	    :  GenericFind.asp
' DESCRIPTION	:  Generic Find Account
' AUTHOR	    :  Kevin A. Boucher
' VERSION	    :  5.0
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../../MamIncludeMDM.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MamLibrary.asp" -->
<!-- #INCLUDE FILE="../../default/Lib/MTProductCatalog.Library.asp" -->
<!-- #INCLUDE FILE="../../default/Lib/AccountLib.asp" -->
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" --> 
<%

Form.RouteTo = mam_GetDictionary("WELCOME_DIALOG")

mdm_Main ' Invoke the MDM framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: Form_Initialize
' PARAMETERS	:
' DESCRIPTION :
' RETURNS		  : Return TRUE if ok else FALSE  `
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean
	Service.Clear 	
	Service.Properties.Clear
	
	' Save the initial template so we can use it to render a new dynamic template later
  Form("InitialTemplate") = Form.HTMLTemplateSource  

  ' Remove required field
  Service.Configuration.CheckRequiredField = FALSE
  
  ' Get account type, and load the properties
  Dim strAccountType
  If Len(mdm_UIValue("AccountType")) Then
    strAccountType = mdm_UIValueDefault("AccountType", "IndependentAccount")
    Session("MAM_CURRENT_ACCOUNT_TYPE") = strAccountType    
  End IF

  Call Service.Properties.LoadAccountType(strAccountType)
  Call LocalizeProductView(Service.Properties)
            
  ' Remove some props
  Service.Properties.Remove("ActionType")
  Service.Properties.Remove("Operation")
  Service.Properties.Remove("applydefaultsecuritypolicy")
  Service.Properties.Remove("applyaccounttemplate")
  Service.Properties.Remove("truncateoldsubscriptions")

  If Service.Properties.Exist("Currency") and Service.Properties.Exist("PRICELIST") Then  
    PopulateDefaultAccountPricelist
  End If  
  
  ' Clear properties
  Dim prop1
  For Each prop1 in Service.Properties
    If UCase(prop1.PropertyType) = "TIMESTAMP" Then
      prop1.Value = Empty
    ElseIf UCase(prop1.PropertyType) = "BOOLEAN" Then 
        Dim strProp
        strProp = prop1.Name
        
        Dim strCaption
        strCaption = Service.Properties(strProp).Caption
        
        Call Service.Properties.Remove(strProp)

        Dim objDyn 
        Set objDyn = mdm_CreateObject(CVariables)
				objDyn.Add "1", "1", , , "[TEXT_YES]"
				objDyn.Add "0", "0", , , "[TEXT_NO]"
					
 		    Service.Properties.Add strProp, "STRING", 0, FALSE, ""
			  Service.Properties(strProp).AddValidListOfValues objDyn	
        
        Service.Properties(strProp).Value = ""
        Service.Properties(strProp).Caption = strCaption

    Else  
      prop1.Value = ""
    End If  
    
    ' No search properties are required
    prop1.Required = FALSE
  Next
  
  ' Include Calendar javascript    
  mam_IncludeCalendar
  Service.LoadJavaScriptCode 
          
  Form_Initialize = DynamicTemplate(EventArg) 
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
	mdm_GetDictionary().add "TEXT_GENERIC_FIND_TITLE", "Advanced Find for " & Session("MAM_CURRENT_ACCOUNT_TYPE")

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
  
    Select Case UCase(prop.PropertyType)
      Case "STRING"
          strHTML = strHTML & "<TD class='"& strCaptionClass &"'><LABEL Name='" & prop.name & "' Type='Caption'>z</LABEL>:</td>"
          strHTML = strHTML & "<TD><INPUT type='text' class='field' name='" & prop.name & "'></TD>"
      
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
          strHTML = strHTML & prop.name & " - " & prop.PropertyType & "<br>"
          'strHTML = strHTML & "<TD class='"& strCaptionClass &"'><LABEL Name='" & prop.name & "' Type='Caption'>z</LABEL>:</td>"
          'strHTML = strHTML & "<TD><select name='" & prop.name & "'></select></TD>"            
          'strHTML = strHTML & "<TD class='captionEW'></td>"
          'strHTML = strHTML & "<td><input type='CheckBox' name='" & prop.name & "'><label class='"& strCaptionClass &"' name='" & prop.name & "' type='Caption'>z:</label></td>"
          
      Case Else
          strHTML = strHTML & prop.name & " - " & prop.PropertyType & "<br>"
    End Select

    nCount = nCount + 1
    If nCount = 2 Then
      strHTML = strHTML & "</TR>"
      nCount = 0
    End If
  Next
	
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
' FUNCTION: Form_Ok
' PARAMETERS:
' DESCRIPTION:
' RETURNS: Return TRUE if ok else FALSE
PRIVATE FUNCTION Ok_Click(EventArg) ' As Boolean
  on error resume next
  Dim strRouteto, strDate, prop, strAccountTypeName
  
  ' Account Types
  strAccountTypeName = "AccountTypeName='" & Session("MAM_CURRENT_ACCOUNT_TYPE") & "'"
      
  For Each prop in Service.Properties
    If UCase(prop.name) = "PRICELIST" Then
      strRouteto = strRouteto & AddSearchFieldToQueryString(Service.Properties(prop.name), "PricelistName")   
    Else
      strRouteto = strRouteto & AddSearchFieldToQueryString(Service.Properties(prop.name), prop.name)   
    End If
  Next  
   
  If(Len(strRouteto)=0)Then
    EventArg.Error.Description = FrameWork.GetHTMLDictionaryError("MAM_ERROR_1008")
    OK_Click      = FALSE
  Else
    strDate = mam_GetGMTEndOfTheDayFormatted()
    strRouteto = mam_GetDictionary("SUBSCRIBER_FIND_BROWSER") & "?" & strAccountTypeName & "&SearchDate=" & CDate(strDate) & "&ShowBackSelectionButton=TRUE&AdvancedFind=TRUE" & strRouteto
    
    Form.RouteTo = strRouteto    
    
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
' FUNCTION 		    : Cancel_Click
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
FUNCTION Cancel_Click(EventArg) ' As Boolean
  Form.RouteTo = mam_GetDictionary("WELCOME_DIALOG")
  Cancel_Click = TRUE
END FUNCTION
%>

