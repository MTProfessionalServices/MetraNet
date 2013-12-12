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
<%
Form.ServiceMsixdefFileName 	    =  mam_GetAccountCreationMsixdefFileNameForSystemAccount()
Form.Page.MaxRow                  =  CLng(mam_GetDictionary("PV_ROW_PER_PAGE"))
Form.RouteTo			                =  mam_GetDictionary("WELCOME_DIALOG")
Form.Page.NoRecordUserMessage     =  mam_GetDictionary("PRODUCT_VIEW_BROWSER_NO_RECORDS_FOUND")

Private m_strDefaultNameSpace ' When this dialog is called from the quick find the QueryString("Value") return name-space:property-name
                              ' When this dialog is called from the advanced find the variable is ignored.

Dim mintCount
Dim mbRenderingRow
Dim mbDisplayCurrent
Dim marrIDs()


mdm_PVBrowserMain ' invoke the mdm framework


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: Form_Initialize
' PARAMETERS	:
' DESCRIPTION :
' RETURNS		  : Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean     

    Dim item 'querystring item
    Dim i
    Dim lngPos

    mam_AccountFound FALSE   ' Gray out subscriber
    
    'Used by DisplayRow(...)
    mintCount = 0
    mbRenderingRow = false
    
    ' Save query string search values in form, so we can survive a refresh

    If(Len(CStr(request.querystring("Value"))))Then
      
     '  i = 0
     '  For Each item In Request.QueryString("Value")
     '  
     '     Form("Value" & CStr(i)) = CStr(item)
     '     i = i + 1
     '  Next
     '  i = 0
     '  For Each item In Request.QueryString("SearchOn")
     '  
     '     lngPos = InStr(CStr(item),":") ' if we find a name space defined
     '     If(lngPos)Then
     '         Form("SearchOn" & CStr(i))  = MID(CStr(item),lngPos+1)
     '         m_strDefaultNameSpace       = MID(CStr(item),1,lngPos-1)
     '     Else
     '         Form("SearchOn" & CStr(i)) = CStr(item)
     '     End If
     '     i = i + 1
     '  Next
       For i = 1 to Request.QueryString("Value").count
          Form("Value" & CStr(i-1)) = CStr(Request.QueryString("Value").item(i))
       Next
      
       i = 0
       For Each item In Request.QueryString("SearchOn")
       
          lngPos = InStr(CStr(item),":") ' if we find a name space defined
          If(lngPos)Then
              Form("SearchOn" & CStr(i))  = MID(CStr(item),lngPos+1)
              m_strDefaultNameSpace       = MID(CStr(item),1,lngPos-1)
          Else
              Form("SearchOn" & CStr(i)) = CStr(item)
          End If
          i = i + 1
       Next 

       Form("Count") =  CStr(i) ' Save count value in form so we know what to loop on
    End If
    
    If Len(Request.QueryString("SearchDate")) Then
      Form("SearchDate") = CDate(Request.QueryString("SearchDate"))
    Else
      Form("SearchDate") = mam_GetHierarchyTime()
    End IF
    
	  ProductView.Clear  ' Set all the property of the service to empty or to the default value
    
    ' Special case for Account because there is no product view The product view here is initialized as a service,but we converted into a product view!
    ProductView.Properties.Flags = eMSIX_PROPERTIES_FLAG_PRODUCTVIEW
	  ProductView.Properties.ClearSelection ' Select the properties we want to print in the PV Browser and the order
    i = 1    
    ProductView.Properties("ContactType").Selected 			  = i : i = i +1
    ProductView.Properties("UserName").Selected 			    = i : i = i +1
    ProductView.Properties("FirstName").Selected 			    = i : i = i +1
    ProductView.Properties("LastName").Selected 			    = i : i = i +1
    ProductView.Properties("PhoneNumber").Selected 	      = i : i = i +1
    ProductView.Properties("email").Selected 	            = i : i = i +1
    ProductView.Properties("Company").Selected 	          = i : i = i +1
    ProductView.Properties("AccountStatus").Selected 	    = i : i = i +1

    Call LocalizeProductView(ProductView.Properties)
      
  '  mam_Account_SetDynamicEnumType    
    Dim objDyn
    Set objDyn = mdm_CreateObject(CVariables)    
    objDyn.Add "system_user", "system_user", , ,"system_user"
    Service.Properties("Name_Space").AddValidListOfValues objDyn
    
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

  '  If(Len(m_strDefaultNameSpace))Then ' Add the name space if defined
        objMAMFinder.AddFilter MAM_ACCOUNT_CREATION_NAME_SPACE_PROPERTY , MT_OPERATOR_TYPE_EQUAL , "system_user"
        objMAMFinder.NameSpaceType =  "system_user"
  '  End If

    ' 
    If objMAMFinder.Find(Form("SearchDate")) Then 
  
        If(objMAMFinder.SubscriberFound > -1) Then
				
            Set MAM().Subscriber.RowSet       = objMAMFinder.Rowset ' Plug the rowset into the MAM
            Set ProductView.Properties.Rowset = objMAMFinder.Rowset ' In the product view itself, like it should as a product view
            MAM().Subscriber.Flags            = eMSIX_PROPERTIES_FLAG_PRODUCTVIEW
            
            If MAM().Subscriber.RowSet.RecordCount = 1 then
              mdm_TerminateDialogAndExecuteDialog mam_GetDictionary("SYSTEM_USER_FOUND_DIALOG") & "?AccountId=" & MAM().Subscriber.RowSet.Value("_AccountId") & "&ShowBackSelectionButton=FALSE"
            End If
        Else
            ' Too many results found - please narrow search
            Set MAM().Subscriber.RowSet       = objMAMFinder.Rowset ' Plug the rowset into the MAM
            Set ProductView.Properties.Rowset = objMAMFinder.Rowset ' In the product view itself, like it should as a product view
            MAM().Subscriber.Flags            = eMSIX_PROPERTIES_FLAG_PRODUCTVIEW
            Form.Page.NoRecordUserMessage     = FrameWork.GetHTMLDictionaryError("MAM_ERROR_1007")
        End If
        Form_LoadProductView = TRUE
    Else
        Form.RouteTo = mam_ConfirmDialogEncodeAllURL(FrameWork.GetHTMLDictionaryError("MAM_ERROR_1015"), FrameWork.GetHTMLDictionaryError("MAM_ERROR_1014") & FrameWork.GetHTMLDictionaryError("MAM_ERROR_1005"), form.routeto)
    End If
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: Form_DisplayCell
' PARAMETERS	:
' DESCRIPTION 	: I implement this event so i can customize the 1 col which
'                 is the action column, where i put my link!
' RETURNS		: Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_DisplayCell(EventArg) ' As Boolean

    Dim strSelectorHTMLCode
    
    ' Only display Bill-To Rows
    If DisplayRow(EventArg) Then
            
      Select Case Form.Grid.Col
          Case 1
                    
              strSelectorHTMLCode   = "[SYNC]<BUTTON Name='butRow[ROW]' Class='clsButtonBlueSmall' OnCLick='Javascript:parent.hideHierarchy();document.location.href=""[ASP_PAGE]?IsSystemUser=TRUE&AccountId=[ACCOUNTID]&ShowBackSelectionButton=TRUE""'>Select</BUTTON>"

             ' check to see if we should show the sync to hierarchy button
             ' If ProductView.Properties.RowSet.Value("AncestorAccountID") = 1 and ((UCase(ProductView.Properties.RowSet.Value("Folder")) = "0") or (UCase(ProductView.Properties.RowSet.Value("Folder")) = "FALSE")) then
             '   strSelectorHTMLCode   = Replace(strSelectorHTMLCode,"[SYNC]","&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;")
             ' Else
                strSelectorHTMLCode   = Replace(strSelectorHTMLCode,"[SYNC]","<a target='secret' Name='butSyncRow[ROW]' href='[FIND_ACCOUNT_IN_HIERARCHY_DIALOG]?IsSystemUser=TRUE&ID=" & ProductView.Properties.RowSet.Value("_AccountId") & "'><img BORDER='0' LOCALIZED='true' SRC='/mam/default/localized/en-us/images/sync.gif' ALT='Find Account in Hierarchy'></a>")
             ' End IF
              strSelectorHTMLCode   = Replace(strSelectorHTMLCode,"[ACCOUNTID]",ProductView.Properties.RowSet.Value("_AccountId"))
              strSelectorHTMLCode   = Replace(strSelectorHTMLCode,"[ASP_PAGE]",mam_GetDictionary("SYSTEM_USER_FOUND_DIALOG"))
              strSelectorHTMLCode   = Replace(strSelectorHTMLCode,"[ROW]",Form.Grid.Row)
              strSelectorHTMLCode   = Replace(strSelectorHTMLCode,"[FIND_ACCOUNT_IN_HIERARCHY_DIALOG]",mam_GetDIctionary("FIND_ACCOUNT_IN_HIERARCHY_DIALOG"))
              
              
              EventArg.HTMLRendered = "<td  class='" & Form.Grid.CellClass & "' width=80>" & strSelectorHTMLCode & "</td>"            
              Form_DisplayCell = TRUE        
                  
          Case Else
          
              Form_DisplayCell =  Inherited("Form_DisplayCell()") ' Call the default implementation
      End Select
    End if 
    
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		:
' PARAMETERS	:
' DESCRIPTION :
' RETURNS			:
PRIVATE FUNCTION Form_DisplayBeginRow(EventArg) ' As Boolean
  mbRenderingRow = true
  
  If(DisplayRow(EventArg))Then
    If(Session("CustomRowCounter")  Mod 2)Then
      Form.Grid.CellClass = "TableCell"
    Else
      Form.Grid.CellClass = "TableCellAlt"
    End If        
    Form_DisplayBeginRow =  Inherited("Form_DisplayBeginRow()") ' Call the default implementation
  End If

  'Used by DisplayRow
  mbRenderingRow = false    
  
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		:
' PARAMETERS	:
' DESCRIPTION :
' RETURNS			:
PRIVATE FUNCTION Form_DisplayEndRow(EventArg) ' As Boolean
   
    If(DisplayRow(EventArg))Then
    
        Session("CustomRowCounter")  = Session("CustomRowCounter")  + 1
        Form_DisplayEndRow = Inherited("Form_DisplayEndRow()") ' Call the default implementation
    End If
    
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		:  DisplayRow()
' PARAMETERS	:
' DESCRIPTION :  Return true is the current row must be displayed! This is in fact no more used but we keep the 
'                function!
' RETURNS			:  True, False
PRIVATE FUNCTION DisplayRow(EventArg) ' As Boolean
  Dim i
  Dim intSub
  
  DisplayRow = True
    
  'Only display 1 row for an account -- Sometimes the search for SE by connected account
  'returns multiple rows
  if mbRenderingRow then
    for i = 0 to mintCount - 1
      if CLng(marrIDs(i)) = CLng(service.properties("_AccountID").value) then
        mbDisplayCurrent = false
        DisplayRow = False
        Exit Function    
      end if
    next

    mbDisplayCurrent = true
  
    'If we didn't find it, add it
    if mintCount > 0 then
      redim preserve marrIDs(mintCount)
    else
      redim marrIDs(mintCount)
    end if
     
    marrIDs(mintCount) = Service.Properties("_AccountID").value
    mintCount = mintCount + 1
    
  else
    DisplayRow = mbDisplayCurrent
  end if
    
    'If (ProductView.Properties("ContactType").value(true,false) = ProductView.Properties("ContactType").EnumType("Bill-To"))  Or _
    '   (Len(ProductView.Properties("ContactType").value(true,false))=0) Then
    '    
    '   DisplayRow = True
    'Else
    '   DisplayRow = False
    'End If
END FUNCTION

%>

