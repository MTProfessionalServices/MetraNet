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
'  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
'
' NAME        : QuickFind.asp
' DESCRIPTION	: Added GSMServiceAccount
'               Implement the QuickFind dialog. If you want customize the list of field on which you can do a quick find
'               you must first duplicate this file in the folder mam\custom\dialog. Then change the function ReadQuickSearchFields()!
' AUTHOR	    :
' VERSION	    :
'
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Option Explicit 
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../../MamIncludeMDM.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MamLibrary.asp" -->
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" --> 
<%
' Mandatory
Form.RouteTo = mam_GetDictionary("WELCOME_DIALOG")

mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		  : Form_Initialize
' PARAMETERS		:
' DESCRIPTION 	:
' RETURNS		    : Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean

	Service.Clear
  Service.Configuration.DebugMode = FALSE ' We never want to see the debug info
  Service.JavaScriptCode = ""             ' We do not want the java script in that dialog because the interception of the key
                                          ' Enter and Escape give us trouble because they invoke directly
 
  Call FrameWork.Dictionary().Add("SERIALIZED_CONTEXT", FrameWork.SessionContext.ToXML)

  ' Add properties on the fly
  Service.Properties.Add "SearchOn", "String", 0, True, Empty
  Service.Properties.Add "Value", "String", 0, False, Empty
  
  Service.Properties.Add "SearchOnSystemUser", "String", 0, True, Empty
  Service.Properties.Add "ValueSystemUser", "String", 0, False, Empty
  
  Service.Properties.Add "SearchOnGSM", "String", 0, True, Empty
  Service.Properties.Add "ValueGSM", "String", 0, False, Empty

  ' Add search on drop down fields, from dictionary
  Call ReadQuickSearchFields(mam_GetDictionary("QUICK_FIND_SEARCH_FIELDS_LIST"), "SearchOn", "metratech.com\AccountCreation.msixdef")
	Call ReadQuickSearchFields(mam_GetDictionary("QUICK_FIND_SYSTEM_USER_SEARCH_FIELDS_LIST"), "SearchOnSystemUser", "metratech.com\SystemAccountCreation.msixdef")
	Call ReadQuickSearchFields(mam_GetDictionary("QUICK_FIND_GSM_FIELDS_LIST"), "SearchOnGSM", "metratech.com\GSMCreate.msixdef")

  ' Recent Account List
  Call FrameWork.Dictionary().Add("RECENT_ACCOUNT_LIST", "<span style='color:white;'>None.</span>")
  Dim recentAccounts
  Dim icon
  icon = "<img src='/mam/default/localized/en-us/images/icon.gif'>"
  If ((FrameWork.CheckCoarseCapability("Manage Account Hierarchies") or FrameWork.CheckCoarseCapability("Manage independent accounts")) and (Not IsEmpty(Session("COL_RECENT_ACCOUNTS")))) Then 
     If mam_GetSubscriberAccountID() <> 0 or Not IsEmpty(Session("COL_RECENT_ACCOUNTS")) Then
        Dim node
        recentAccounts = ""
        For Each node in Session("COL_RECENT_ACCOUNTS")
          recentAccounts = recentAccounts & icon & "<a class='clsAdvancedFind' style='dragable:true;' dragID='" & node & "' href='#' OnClick=""JavaScript:getFrameMetraNet().main.location = '" &  mam_GetDictionary("SUBSCRIBER_FOUND") & "?AccountId=" & node & "&ForceLoad=TRUE';parent.showMenu();"">" & mam_GetFieldIDFromAccountID(node) & "</a><br>"
        Next
     End If                          
    Call FrameWork.Dictionary().Add("RECENT_ACCOUNT_LIST", recentAccounts)
  End If
	
	Form_Initialize = TRUE
END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			: ReadQuickSearchFields
' PARAMETERS		: strFieldList, strProperty, strServiceDef
' DESCRIPTION 	: This function define the list of fields supported for the quick find.
' RETURNS			  :
PRIVATE FUNCTION ReadQuickSearchFields(strFieldList, strProperty, strServiceDef) ' As Boolean

    Dim objQuickSearchList
    Dim objAccountCreationService
    Dim objField
    Dim lngPos
   
    Set objQuickSearchList        = mdm_CreateObject(CVariables)
    Set objAccountCreationService = mdm_CreateObject(MSIXHandler)
    
    ' Read the service definition to get the property localization    
    objAccountCreationService.Initialize  strServiceDef,,"" & MAM().CSR("Language").Value,,,mdm_InternalCache
    
    ' Convert the CSV format into a collection of CVariables(name/value). 
    ' Name and value have the same value : name-space:property name
    objQuickSearchList.LoadCSVString CStr(strFieldList)

    ' Remove the name space : from the name property because we use the name as a look up in AccountCreation
    ' Property collection
    For Each objField In objQuickSearchList
        lngPos = InStr(objField.Name,":")
        If(lngPos)Then
            objField.Name = Mid(objField.Name,lngPos+1)
        End If
    Next

    ' Replace in the collection the property name with the localized property name
    For Each objField In objQuickSearchList
        If(objAccountCreationService.Properties.Exist(objField.Name))Then
          objQuickSearchList.Item(objField.Value).Caption = objAccountCreationService.Properties(objField.Name).Caption
        Else
          If (UCase(objField.Value) = "INVOICE") Then
            objQuickSearchList.Item(objField.Value).Caption =  "Invoice"
          Else  
          
            ' If the property is not found among the AccountCreation Service property 
            ' this means we want to search on username=xxxxx and on a specific name space
            ' with a specific label : like metratech.com/external:QuickFindSearchOnMapping.
            
            ' Get the localization string to display for the item
            If UCase(objField.Name) = "QUICKFINDALIAS1" Then
              objQuickSearchList.Item(objField.Value).Caption = mdm_GetDictionaryValue(objField.Name,objField.Name)
              objField.Value = Replace(objField.Value,objField.Name,MAM_QUICK_FIND_ALIAS_PROPERTY) ' Internally we replace the keyword used (QuickFindSearchOnMapping) by username because this the property used to perform the find
            End If
              
          End If            
        End If
    Next    
    ' Add the objQuickSearchList as an Dynamic Enum Type
    Service.Properties(strProperty).AddValidListOfValues objQuickSearchList
    
    ReadQuickSearchFields = TRUE
END FUNCTION

%>
