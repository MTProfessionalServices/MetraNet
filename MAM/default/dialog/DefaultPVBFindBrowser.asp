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
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../../MamIncludeMDM.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MamLibrary.asp" -->
<!-- #INCLUDE FILE="../../default/Lib/AccountLib.asp" -->
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" -->
<%
Form.Version                  = MDM_VERSION     
Form.Page.MaxRow              = CLng(mam_GetDictionary("PV_ROW_PER_PAGE"))
Form.RouteTo			            = mam_GetDictionary("WELCOME_DIALOG")
Form.Page.NoRecordUserMessage = mam_GetDictionary("PRODUCT_VIEW_BROWSER_NO_RECORDS_FOUND")
Form.ShowExportIcon           = TRUE 
    
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

    Dim item ' QueryString item
    Dim i
    Dim lngPos

    mam_AccountFound FALSE   ' Gray out subscriber
       
	  ProductView.Clear  
    ProductView.Properties.Flags = eMSIX_PROPERTIES_FLAG_PRODUCTVIEW
	  ProductView.Properties.ClearSelection
    
    ' Used by DisplayRow
    mintCount = 0
    mbRenderingRow = false
    
    ' Save query string search values in form, so we can survive a refresh
    If(Len(CStr(request.querystring("Value"))))Then
      
       ' we can not use a for each here because of a bug in the Request object 
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
    
    If Len(Request.QueryString("SearchDate")) > 0 Then
      Form("SearchDate") = CDate(Request.QueryString("SearchDate"))
    Else
      Form("SearchDate") = mam_GetHierarchyTimeWithFormat()
    End IF
 
    If Len(Request.QueryString("AccountTypeName")) > 0 Then
      ' Make sure we have the right active AccountType set
      Form("AccountTypeName") = Request.QueryString("AccountTypeName")
      dim arr, setType
      arr = Split(Form("AccountTypeName"), ",")
      setType = mid(arr(0), 2, Len(arr(0)) -2)
      Call MAM().SetActiveAccountType(setType)
    End IF
 
    Session("CustomRowCounter") = 1

	  Form_Initialize = TRUE
END FUNCTION

PRIVATE FUNCTION Form_LoadProductView(EventArg) ' As Boolean

    Dim varSubscriberFound, objMTSQLRowset, SearchFolderID, i, objMamFinder
    
    Form_LoadProductView = FALSE    
    
    Set objMAMFinder = New CMAMFinder
    
    ' Create a pre-populated filter
    Call objMAMFinder.CreateFilter(true)
    
    ' Add to filter
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

    ' Add filter on Account Types
    If Len(Form("AccountTypeName")) > 0 Then
      objMAMFinder.AccountTypes = Form("AccountTypeName") 'format: "'CORESUBSCRIBER', 'GSMSERVICEACCOUNT'"
    End If 

    ' Run find
    If objMAMFinder.Find(Form("SearchDate")) Then 
  
        If(objMAMFinder.SubscriberFound > -1) Then

            Set MAM().Subscriber.RowSet       = objMAMFinder.Rowset ' Plug the rowset into the MAM
            Set ProductView.Properties.Rowset = objMAMFinder.Rowset ' In the product view itself, like it should as a product view
            MAM().Subscriber.Flags            = eMSIX_PROPERTIES_FLAG_PRODUCTVIEW

            If MAM().Subscriber.RowSet.RecordCount = 0 then
              mdm_GetDictionary.Add "ACCOUNTS_FOUND", FALSE
            Else
              mdm_GetDictionary.Add "ACCOUNTS_FOUND", TRUE
            End If
            
            ' Only one account found so load it directly
            If MAM().Subscriber.RowSet.RecordCount = 1 then
              mdm_TerminateDialogAndExecuteDialog mam_GetDictionary("SUBSCRIBER_FOUND") & "?AccountId=" & MAM().Subscriber.RowSet.Value("_AccountId") & "&ShowBackSelectionButton=FALSE"
            End If
            
            
            ' If we get back multiple rows because of multiple contacts (multiple addresses),
            ' select the account to manage if there is only one unique account ID.
            If MAM().Subscriber.RowSet.RecordCount < 10 and MAM().Subscriber.RowSet.RecordCount > 1 then  ' I guess you don't have more than 10 contact types...right?
              
              Dim tempAccountID
              Dim bAutoSelect
              bAutoSelect = TRUE

              tempAccountID = MAM().Subscriber.RowSet.Value("_AccountId")
              MAM().Subscriber.RowSet.MoveNext
              
              Do While Not CBool(MAM().Subscriber.RowSet.EOF)
                
                If tempAccountID <> MAM().Subscriber.RowSet.Value("_AccountId") Then
                  bAutoSelect = FALSE
                  Exit Do
                End If
                
                MAM().Subscriber.RowSet.MoveNext
              Loop
              MAM().Subscriber.RowSet.MoveFirst
              
              If bAutoSelect Then
                mdm_TerminateDialogAndExecuteDialog mam_GetDictionary("SUBSCRIBER_FOUND") & "?AccountId=" & MAM().Subscriber.RowSet.Value("_AccountId") & "&ShowBackSelectionButton=FALSE"
              End If  

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
    
    '''''''''''''''''''''''''
	  if false then
	    ProductView.Properties.SelectAll
	  else
      i = 1    
      ' Selected Properties, make sure they exist for this AccountType first...
      If(ProductView.Properties.Exist("UserName"))      Then ProductView.Properties("UserName").Selected 			= i : i = i +1
      If(ProductView.Properties.Exist("FirstName"))     Then ProductView.Properties("FirstName").Selected 		= i : i = i +1
      If(ProductView.Properties.Exist("LastName"))      Then ProductView.Properties("LastName").Selected 			= i : i = i +1
      If(ProductView.Properties.Exist("PhoneNumber"))   Then ProductView.Properties("PhoneNumber").Selected 	= i : i = i +1
      If(ProductView.Properties.Exist("email"))         Then ProductView.Properties("email").Selected 	      = i : i = i +1
      If(ProductView.Properties.Exist("Company"))       Then ProductView.Properties("Company").Selected 	    = i : i = i +1
      If(ProductView.Properties.Exist("AccountType"))   Then ProductView.Properties("AccountType").Selected 	= i : i = i +1
      If(ProductView.Properties.Exist("AccountStatus")) Then ProductView.Properties("AccountStatus").Selected = i : i = i +1
      
      ' Captions 
      Call LocalizeProductView(ProductView.Properties)

    end if
        
  '  mam_Account_SetDynamicEnumType    

    ProductView.LoadJavaScriptCode
  '  ProductView.Properties("UserName").Sorted = MTSORT_ORDER_DESCENDING    
    ProductView.RenderLocalizationMode = TRUE ' We want all the enum type value to be localized while the HTML Rendering Process    
    
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: Form_DisplayCell
' PARAMETERS	:
' DESCRIPTION : Place actions in the first column
' RETURNS		  : Return TRUE / FALSE
PRIVATE FUNCTION Form_DisplayCell(EventArg) ' As Boolean

    Dim strSelectorHTMLCode
          
    Select Case Form.Grid.Col
        Case 1
                  
            strSelectorHTMLCode   = "[SYNC]<BUTTON Name='butRow[ROW]' Class='clsButtonBlueSmall' OnCLick='Javascript:getFrameMetraNet().hideHierarchy();document.location.href=""[ASP_PAGE]?AccountId=[ACCOUNTID]&ShowBackSelectionButton=TRUE""'>Select</BUTTON>"

            ' check to see if we should show the sync to hierarchy button
            If UCase(ProductView.Properties.RowSet.Value("AccountType")) = UCase("INDEPENDENTACCOUNT") or _
                ProductView.Properties.RowSet.Value("AncestorAccountID") = -1  then
              strSelectorHTMLCode   = Replace(strSelectorHTMLCode,"[SYNC]","&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;")
            Else
              strSelectorHTMLCode   = Replace(strSelectorHTMLCode,"[SYNC]","<a target='secret' Name='butSyncRow[ROW]' href='[FIND_ACCOUNT_IN_HIERARCHY_DIALOG]?ID=" & ProductView.Properties.RowSet.Value("_AccountId") & "'><img BORDER='0' LOCALIZED='true' SRC='/mam/default/localized/en-us/images/sync.gif' ALT='Find Account in Hierarchy'></a>")
            End IF
            strSelectorHTMLCode   = Replace(strSelectorHTMLCode,"[ACCOUNTID]",ProductView.Properties.RowSet.Value("_AccountId"))
            strSelectorHTMLCode   = Replace(strSelectorHTMLCode,"[ASP_PAGE]",mam_GetDictionary("SUBSCRIBER_FOUND"))
            strSelectorHTMLCode   = Replace(strSelectorHTMLCode,"[ROW]",Form.Grid.Row)
            strSelectorHTMLCode   = Replace(strSelectorHTMLCode,"[FIND_ACCOUNT_IN_HIERARCHY_DIALOG]",mam_GetDIctionary("FIND_ACCOUNT_IN_HIERARCHY_DIALOG"))
            
            EventArg.HTMLRendered = "<td  class='" & Form.Grid.CellClass & "' width=80>" & strSelectorHTMLCode & "</td>"            
            Form_DisplayCell = TRUE            
        Case Else
        
            Form_DisplayCell =  Inherited("Form_DisplayCell()") ' Call the default implementation
    End Select
    
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		:
' PARAMETERS	:
' DESCRIPTION :
' RETURNS			:
PRIVATE FUNCTION Form_DisplayBeginRow(EventArg) ' As Boolean
  mbRenderingRow = true
  
  If(Session("CustomRowCounter")  Mod 2)Then
    Form.Grid.CellClass = "TableCell"
  Else
    Form.Grid.CellClass = "TableCellAlt"
  End If        
  Form_DisplayBeginRow =  Inherited("Form_DisplayBeginRow()") ' Call the default implementation

  'Used by DisplayRow
  mbRenderingRow = false    
  
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		:
' PARAMETERS	:
' DESCRIPTION :
' RETURNS			:
PRIVATE FUNCTION Form_DisplayEndRow(EventArg) ' As Boolean
    
  Session("CustomRowCounter")  = Session("CustomRowCounter")  + 1
  Form_DisplayEndRow = Inherited("Form_DisplayEndRow()") ' Call the default implementation
    
END FUNCTION

%>

