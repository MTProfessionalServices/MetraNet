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
' DIALOG	    :
' DESCRIPTION	:
' AUTHOR	    :
' VERSION	    :
'
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../../MamIncludeMDM.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MamLibrary.asp" -->
<!-- #INCLUDE FILE="../../default/Lib/AccountLib.asp" -->
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/common/mdmPicker.Library.asp" -->

<%
Form.ServiceMsixdefFileName 	    =  mam_GetAccountCreationMsixdefFileName()
Form.Page.MaxRow                  =  CLng(mam_GetDictionary("PV_ROW_PER_PAGE"))
Form.RouteTo			                =  mam_GetDictionary("WELCOME_DIALOG")
Form.Page.NoRecordUserMessage     =  mam_GetDictionary("PRODUCT_VIEW_BROWSER_NO_RECORDS_FOUND")

Private m_strDefaultNameSpace ' When this dialog is called from the quick find the QueryString("Value") return name-space:property-name
                              ' When this dialog is called from the advanced find the variable is ignored.

mdm_PVBrowserMain ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: Form_Initialize
' PARAMETERS	:
' DESCRIPTION :
' RETURNS		  : Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean     

    Dim item 'querystring item
    Dim i, j
    Dim lngPos

    ' remove required field
    Service.Configuration.CheckRequiredField = FALSE
  
    mam_AccountFound FALSE   ' Gray out subscriber
    
    'Initialize the picker dialog
    Call MDMPickerDialog.Initialize(EventArg)
    Form("MonoSelect") = true
    Form("IDColumnName") = "_AccountID"
    Form("OptionalColumn") = "UserName,FirstName,LastName"
    Form.Modal = true
    
    'Disable filtering
    Form.Grid.FilterMode = false
    
    ' Save query string search values in form, so we can survive a refresh
    
    'NOTE: we must use the item syntax and not the foreach syntax to preserve encoding
    ' For i = 1 to Request.QueryString("Value").count
    '   Form("Value" & CStr(i-1)) = CStr(Request.QueryString("Value").item(i))
    ' Next
       
    If(Len(CStr(request.querystring("Value"))))Then
      
       i = 0
       For j = 1 to Request.QueryString("Value").count
       
          Form("Value" & CStr(i)) = CStr(Request.QueryString("Value").item(j))
          i = i + 1
       Next
       
       i = 0
       For j = 1 to Request.QueryString("SearchOn").count
       
          lngPos = InStr(CStr(Request.QueryString("SearchOn").item(j)),":") ' if we find a name space defined
          If(lngPos)Then
              Form("SearchOn" & CStr(i))  = MID(CStr(Request.QueryString("SearchOn").item(j)),lngPos+1)
              m_strDefaultNameSpace       = MID(CStr(Request.QueryString("SearchOn").item(j)),1,lngPos-1)
          Else
              Form("SearchOn" & CStr(i)) = CStr(Request.QueryString("SearchOn").item(j))
          End If
          i = i + 1
       Next
       Form("Count") =  CStr(i) ' Save count value in form so we know what to loop on
    End If
    
    If Len(Request.QueryString("SearchDate")) Then
      Form("SearchDate") = Request.QueryString("SearchDate")
    Else
      Form("SearchDate") = mam_GetHierarchyTime()
    End IF
    
	  ProductView.Clear  ' Set all the property of the service to empty or to the default value
    
    ' Special case for Account because there is no product view The product view here is initialized as a service,but we converted into a product view!
    ProductView.Properties.Flags = eMSIX_PROPERTIES_FLAG_PRODUCTVIEW
	  ProductView.Properties.ClearSelection ' Select the properties we want to print in the PV Browser and the order
    i = 1    
    ProductView.Properties("_AccountID").Selected         = i : i = i +1
    ProductView.Properties("ContactType").Selected 			  = i : i = i +1
    ProductView.Properties("UserName").Selected 			    = i : i = i +1
    ProductView.Properties("FirstName").Selected 			    = i : i = i +1
    ProductView.Properties("LastName").Selected 			    = i : i = i +1
    ProductView.Properties("PhoneNumber").Selected 	      = i : i = i +1
    ProductView.Properties("email").Selected 	            = i : i = i +1
    ProductView.Properties("Company").Selected 	          = i : i = i +1
    ProductView.Properties("AccountStatus").Selected 	    = i : i = i +1
    
    mam_Account_SetDynamicEnumType    
    ProductView.RenderLocalizationMode = TRUE ' We want all the enum type value to be localized while the HTML Rendering Process    
    Session("CustomRowCounter")        = 1
    
	  Form_Initialize = TRUE
END FUNCTION

PRIVATE FUNCTION Form_LoadProductView(EventArg) ' As Boolean

    Dim varSubscriberFound, objMTSQLRowset, SearchFolderID, i, objMamFinder
    
    Form_LoadProductView = FALSE    
    
    Set objMAMFinder = New CMAMFinder
    
    'Create a pre-populated filter
    Call objMAMFinder.CreateFilter(true)
    
    For i=0 to CLng(Form("Count") -1)
    
         on error resume next 
         If CStr(LCase(Form("SearchOn" & CStr(i)))) = "_accountid" Then
           Dim AccountID
           If FrameWork.DecodeFieldID(Form("Value" & CStr(i)), AccountID) Then
              Form("Value" & CStr(i)).Value = AccountID
           Else
              EventArg.Error.number = 1037
              EventArg.Error.description = mam_GetDictionary("MAM_ERROR_1037")
              Form_LoadProductView = FALSE  
              Form.RouteTo = mam_ConfirmDialogEncodeAllURL(FrameWork.GetHTMLDictionaryError("MAM_ERROR_1015"), FrameWork.GetHTMLDictionaryError("MAM_ERROR_1037"), form.routeto)     
              Exit Function
           End IF          
         End If
         on error goto 0
        objMAMFinder.AddFilter CStr(LCase(Form("SearchOn" & CStr(i)))) , MT_OPERATOR_TYPE_DEFAULT , CStr(Form("Value" & CStr(i)))
    Next

    If(Len(m_strDefaultNameSpace))Then ' Add the name space if defined
    
        objMAMFinder.AddFilter MAM_ACCOUNT_CREATION_NAME_SPACE_PROPERTY , MT_OPERATOR_TYPE_EQUAL , CStr(m_strDefaultNameSpace)
        objMAMFinder.NameSpaceType =  "metered"
    End If

    ' 
    If objMAMFinder.Find(CDate(Form("SearchDate"))) Then 
  
        If(objMAMFinder.SubscriberFound > -1) Then
            Set ProductView.Properties.Rowset = objMAMFinder.Rowset ' In the product view itself, like it should as a product view
            MAM().Subscriber.Flags            = eMSIX_PROPERTIES_FLAG_PRODUCTVIEW
        Else
            ' Too many results found - please narrow search
            Set ProductView.Properties.Rowset = objMAMFinder.Rowset ' In the product view itself, like it should as a product view
            MAM().Subscriber.Flags            = eMSIX_PROPERTIES_FLAG_PRODUCTVIEW
            Form.Page.NoRecordUserMessage     = FrameWork.GetHTMLDictionaryError("MAM_ERROR_1007")
        End If
        Form_LoadProductView = TRUE
    Else
        Form.RouteTo = mam_ConfirmDialogEncodeAllURL(FrameWork.GetHTMLDictionaryError("MAM_ERROR_1015"), FrameWork.GetHTMLDictionaryError("MAM_ERROR_1014") & FrameWork.GetHTMLDictionaryError("MAM_ERROR_1005"), form.routeto)
    End If
END FUNCTION
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Function OK_Click(EventArg)
  OK_Click = MDMPickerDialog.OK_Click(EventArg)
End Function

%>

