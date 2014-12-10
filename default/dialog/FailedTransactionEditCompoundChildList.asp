 <% 
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile: s:\UI\MOM\default\dialog\FailedTransactionEditCompoundChildList.asp$
' 
'  Copyright 1998-2003 by MetraTech Corporation
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
'  Created by: F.Torres
' 
'  $Date: 9/4/2002 2:19:05 PM$
'  $Author: Rudi Perkins$
'  $Revision: 1$
'
' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
'
' CLASS       : 
' DESCRIPTION : 
' ---------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/mdm.asp"          -->
<!-- #INCLUDE FILE="../../default/lib/momLibrary.asp"                   -->
<!-- #INCLUDE VIRTUAL="/mdm/FrameWork/CFrameWork.Class.asp" -->

<%
Form.Version                    = MDM_VERSION     ' Set the dialog version - we are version 2.0.
Form.ErrorHandler               = FALSE 'TRUE  
Form.ShowExportIcon             = FALSE
'Form.Page.MaxRow                = CLng(FrameWork.GetDictionary("MAX_ROW_PER_LIST_PAGE"))
'Form.Page.NoRecordUserMessage   = FrameWork.GetDictionary("PRODUCT_VIEW_BROWSER_NO_RECORDS_FOUND")

mdm_PVBrowserMain ' invoke the mdm framework

PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean
    'BreadCrumb.SetCrumb FrameWork.GetDictionary("TEXT_VIEW_AUDIT_LOG")
    'ProductView.Clear  ' Set all the property of the service to empty or to the default value
    
    
    Framework.AssertCourseCapability "Update Failed Transactions", EventArg
   	ProductView.Properties.ClearSelection
    ProductView.Properties.Flags = eMSIX_PROPERTIES_FLAG_PRODUCTVIEW

    Form("ChildServiceName") = mdm_UIValue("Service")

	Form_Initialize = true
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  Form_LoadProductView
' PARAMETERS:  EventArg
' DESCRIPTION: 
' RETURNS:  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_LoadProductView(EventArg) ' As Boolean

  Form_LoadProductView = FALSE
  
  dim bChildrenExist
  
  bChildrenExist = true
  
  if len(Form("ChildServiceName"))=0 then
    'set service def with error
    if not session("FailedTransaction_Compound_Parent").SessionChildrenTypes(session("FailedTransaction_ServiceNameWithError")) is nothing then 
      '// We weren't passed a child to display, so display the child type that has the error if it exists
      Form("ChildServiceName") = session("FailedTransaction_ServiceNameWithError")
    else
      '// The child type with the error doesn't exist, just display the first one by default
      if session("FailedTransaction_Compound_Parent").SessionChildrenTypes.Count>0 then
        Form("ChildServiceName") = session("FailedTransaction_Compound_Parent").SessionChildrenTypes(1).Name
      else
        '// There are no children of any type
        Form("ChildServiceName") = ""
        bChildrenExist = false
      end if
    end if
  end if

  mdm_GetDictionary().Add "TEXT_CHILD_TRANSACTION_LIST_SERVICE",  Form("ChildServiceName")   
  mdm_GetDictionary().Add "CHILD_TRANSACTION_LIST_SERVICE",       Form("ChildServiceName")   
  
  
  '// Build the child type selection drop down
  dim sHTML, sTempChildServiceName
  if bChildrenExist then
    sHTML = "<select name=""mdmChildSelect"" id=""mdmChildSelect"""
    if session("FailedTransaction_Compound_Parent").SessionChildrenTypes.Count <=1 then
      sHTML = sHTML & " disabled"
    end if
    sHTML =sHTML & " onChange=""window.location='FailedTransactionEditCompoundChildList.asp?Service=' + this.options[this.selectedIndex].value;"">" 
    Dim objChildrenType 'As MSIXHandlerType
    For Each objChildrenType In session("FailedTransaction_Compound_Parent").SessionChildrenTypes
      sTempChildServiceName = ucase(objChildrenType.Name)
      if Form("ChildServiceName") = sTempChildServiceName then
        sHTML = sHTML & "<option value='" & sTempChildServiceName & "' selected>" & sTempChildServiceName & " (" & objChildrenType.Children.Count & ")</option>" & vbNewLine
      else
        sHTML = sHTML & "<option value='" & sTempChildServiceName & "'>" & sTempChildServiceName & " (" & objChildrenType.Children.Count & ")</option>" & vbNewLine
      end if
      'sHTML = sHTML & objChildrenType.Name & " " & objChildrenType.Children.Count
    '    if len(sChildServiceToShowInitially)=0 then
    '        sChildServiceToShowInitially=objChildrenType.Name
    '    else
    '        if lcase(objChildrenType.Name) = Service.Properties("ServiceNameWithError").Value then
    '            sChildServiceToShowInitially = Service.Properties("ServiceNameWithError").Value
    '        end if
    '    end if
    '    strTempLink   = "FailedTransactionEditCompoundChildList.asp?Service=" & server.urlencode(objChildrenType.Name)
    '    htmlChildList = htmlChildList & "<TR style='background-color:white;'><TD><A href='" & strTempLink & "' target='EditChildList'><IMG BORDER=0 alt='' SRC='/newsamplesite/us/images/icons/genericProduct.gif'></A></TD><TD>" & objChildrenType.Name & "</TD><TD> " & objChildrenType.Children.Count & "</TD></TR>"  & vbNewLine    
    Next  
    sHTML = sHTML & "</select>"
    mdm_GetDictionary().Add "FAILED_TRANSACTION_CHILDREN_EXIST", 1
  else
    sHTML = "<span style='font-size:10px;'>No Child Transactions</span>"
    mdm_GetDictionary().Add "FAILED_TRANSACTION_CHILDREN_EXIST", 0
  end if
  
  mdm_GetDictionary().Add "FAILED_TRANSACTION_CHILD_TYPE_SELECT", sHTML
  
  Dim serviceFailedTransaction
  Set serviceFailedTransaction = Session("FailedTransaction_Compound_Parent")
  
  Dim Rowset
  Set Rowset = serviceFailedTransaction.GetChildrenAsRowset(Form("ChildServiceName"), True, mdm_GetDictionary.Item("TEXT_FAILED_TRANSACTION_FAILURE_ID").Value)
  
  If IsValidObject(Rowset) Then
  
      ' Load a Rowset from a SQL Queries and build the properties collection of the product view based on the columns of the rowset
      Set ProductView.Properties.RowSet = Rowset
  
      ProductView.Properties.SelectAll , "{NL}_ReSubmit,_ReSubmit,_ChildKey,{NL}ServiceName,{NL}ErrorMessage" & GetMeterFlagPropertyLeftAsCSVString()            
      ProductView.Properties.CancelLocalization

      
      ProductView.Properties("_Error").Caption      =  mom_GetDictionary("TEXT_ERROR")      

  Else
      Set Rowset = mdm_CreateObject(MT_SQL_ROWSET_SIMULATOR_PROG_ID)           
      Rowset.Initialize 0,1
      Rowset.Name(0) = "Property"      
      Set ProductView.Properties.RowSet = Rowset
  End If   
  Form_LoadProductView = TRUE  
END FUNCTION

PRIVATE FUNCTION GetMeterFlagPropertyLeftAsCSVString()

      Dim objMSIXProperty,s
      
      For Each objMSIXProperty in ProductView.Properties
      
          If InStr(LCase(objMSIXProperty.Name),"{nl}meterflag" )=1 Then
          
              s = s   + objMSIXProperty.Name & ","
          End If
      Next    
      If Len(s)>1 Then
          If Mid(s,Len(s),1)="," Then
             s = "," & Mid(s,1,Len(s)-1) 
          End If
      End If
      GetMeterFlagPropertyLeftAsCSVString = s
END FUNCTION      

PRIVATE FUNCTION Form_DisplayCell(EventArg) ' As Boolean
       
       if Form.Grid.Col<3 then
       
           Select Case Form.Grid.Col
      
             Case 1
                Dim HTML_LINK_EDIT, PreProcessor
                set PreProcessor = CreateObject(CPreProcessor)

                HTML_LINK_EDIT = HTML_LINK_EDIT & "<td nowrap class='[CLASS]' width='50'>" & vbNewLine
                
                HTML_LINK_EDIT = HTML_LINK_EDIT & "<span style='cursor: pointer;' onClick='javascript:window.open(""[ASP_PAGE]?ID=[ID]&ServiceName=[SERVICE_NAME_ENCODED]&ChildKey=[CHILD_KEY_ID]&EditMode=True&MDMReload=True"", ""FailedTransactionChildWindow"");'><img Alt='[ALT_EDIT]' src='[IMAGE_EDIT]' Border='0'></span>&nbsp;" & vbNewLine
                
                HTML_LINK_EDIT = HTML_LINK_EDIT & "<span style='cursor: pointer;' onClick='DeleteChild(""[SERVICE_NAME]"",""[CHILD_KEY_ID]"");'><img Alt='Delete' src='[IMAGE_DELETE]' Border='0'></span>&nbsp;" & vbNewLine
                
                HTML_LINK_EDIT = HTML_LINK_EDIT & "</td>" & vbNewLine
               
                PreProcessor.Clear
              
                PreProcessor.Add "ID"          , "1" 'ProductView.Properties.Rowset.Value(GetIDColumnName())
                PreProcessor.Add "CHILD_KEY_ID", ProductView.Properties.Rowset.Value("_ChildKey")
                PreProcessor.Add "SERVICE_NAME_ENCODED", server.urlencode(mdm_GetDictionary().Item("TEXT_CHILD_TRANSACTION_LIST_SERVICE"))                
                PreProcessor.Add "SERVICE_NAME", mdm_GetDictionary().Item("TEXT_CHILD_TRANSACTION_LIST_SERVICE")
                PreProcessor.Add "CLASS"       , Form.Grid.CellClass        
                PreProcessor.Add "ASP_PAGE"    , "FailedTransactionEditCompoundProperties.asp"
                PreProcessor.Add "IMAGE_EDIT"  , Application("APP_HTTP_PATH") & "/default/localized/en-us/images/edit.gif"
                PreProcessor.Add "IMAGE_DELETE"  , Application("APP_HTTP_PATH") & "/default/localized/en-us/images/delete.gif"
                PreProcessor.Add "IMAGE_VIEW"  , Application("APP_HTTP_PATH") & "/default/localized/en-us/images/icons/view.gif"
                PreProcessor.Add "ALT_VIEW"    , mdm_GetDictionary().Item("TEXT_VIEW").Value
                PreProcessor.Add "ALT_EDIT"    , mdm_GetDictionary().Item("TEXT_EDIT").Value
                
                
                EventArg.HTMLRendered           = PreProcessor.Process(HTML_LINK_EDIT)
                Form_DisplayCell        = TRUE
             case else
                Form_DisplayCell = Inherited("Form_DisplayCell(EventArg)")
           end select
       else
         Select Case lcase(Form.Grid.SelectedProperty.Name)
         Case "_error"
            EventArg.HTMLRendered     =  "<td class='" & Form.Grid.CellClass & "' style='text-align:center'>&nbsp;"
            
            if lcase(ProductView.Properties.RowSet.Value("_Error"))="true" then
              EventArg.HTMLRendered = EventArg.HTMLRendered  & "<img src='../localized/en-us/images/errorSmall.gif' alt='" & mdm_GetDictionary.Item("TEXT_FAILED_TRANSACTION_ERROR_MESSAGE").Value & "' border='0'>"
            end if
            EventArg.HTMLRendered = EventArg.HTMLRendered  & "</td>"
              '  ProductView.Properties.RowSet.Value("State") & "<button class='clsButtonBlueSmall' name='EditMapping' onclick=""window.open('protoIntervalManagement.asp?','', 'height=100,width=100, resizable=yes, scrollbars=yes, status=yes')"">" & "Change" &  "</button></td>" 
            Form_DisplayCell = TRUE

         Case "xstate"
            EventArg.HTMLRendered     =  "<td class='" & Form.Grid.CellClass & "'>" & _
              ProductView.Properties.RowSet.Value("State") & "&nbsp;&nbsp;<a href=''><img src='../localized/en-us/images/edit.gif' width='11' height='17' alt='' border='0'></a></td>"
              '  ProductView.Properties.RowSet.Value("State") & "<button class='clsButtonBlueSmall' name='EditMapping' onclick=""window.open('protoIntervalManagement.asp?','', 'height=100,width=100, resizable=yes, scrollbars=yes, status=yes')"">" & "Change" &  "</button></td>" 
         
  			    Form_DisplayCell = TRUE
  	     Case else
            'In the case of embedded symbols, escape out the HTML
            If (IsDate(Form.Grid.SelectedProperty.Value)) Then 
              EventArg.HTMLRendered = "<td Class='" & Form.Grid.CellClass & "'>" & Server.HTMLEncode(mom_FormatDateTime(Form.Grid.SelectedProperty.Value, "")) & "</td>"
            Else
              EventArg.HTMLRendered = "<td Class='" & Form.Grid.CellClass & "'>" & Server.HTMLEncode(Form.Grid.SelectedProperty.Value) & "</td>"
            End If
            Form_DisplayCell = TRUE 'Inherited("Form_DisplayCell(EventArg)")
      End Select
     end if
    Form_DisplayCell = true

END FUNCTION

PUBLIC FUNCTION DeleteChild_Click(EventArg)
    Dim strChildTypeName,strChildKey
    strChildTypeName = mdm_UIValue("ChildTypeName")
    strChildKey      = mdm_UIValue("ChildKey")
    
    dim strUID
    strUID = Session("FailedTransaction_Compound_Parent").SessionChildrenTypes.Item(strChildTypeName).Children.Item(strChildKey).uid

    Session("FailedTransaction_Compound_Parent").SessionChildrenTypes.Item(strChildTypeName).Children.Remove strChildKey
    If Session("FailedTransaction_Compound_Parent").SessionChildrenTypes.Item(strChildTypeName).Children.Count = 0 Then
        Session("FailedTransaction_Compound_Parent").SessionChildrenTypes.Remove strChildTypeName
        Form("ChildServiceName") = ""
    End If
    
    '//We need to record that this child was deleted so that we can pass the list to the backend when we save
    Session("ChildSessionsToDeleteCollection").Add strUID
    'Form.JavaScriptInitialize = "parent.EditParent.ChildDialogAskForRefresh();"
 
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			:
' PARAMETERS		:
' DESCRIPTION 		:
' RETURNS			:
PRIVATE FUNCTION Form_DisplayDetailRow(EventArg) ' As Boolean

    Dim objProperty
    Dim strSelectorHTMLCode
    Dim strValue
    Dim strCurrency
    Dim strHTMLAttributeName

    'Set objProperty = ProductView.Properties.Item(Form.Grid.PropertyName)
    EventArg.HTMLRendered = EventArg.HTMLRendered & "<td></td><td></td>" & vbNewLine
    EventArg.HTMLRendered = EventArg.HTMLRendered & "<td ColSpan=" & (ProductView.Properties.Count+2) & " width=20>" & vbNewLine
    
    EventArg.HTMLRendered = EventArg.HTMLRendered & "<TABLE  width='100%' border=0 cellpadding=1 cellspacing=0>" & vbNewLine
    
    For Each objProperty In ProductView.Properties
        
        If(UCase(objProperty.Name)<>"MDMINTERVALID") And ((objProperty.Flags And eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET)=0) And Not CBool(InStr(LCase(objProperty.Name),"{nl}meterflag" )=1) And LCase(objProperty.Name)<>"{nl}servicename" And LCase(objProperty.Name)<>"{nl}errormessage" And LCase(objProperty.Name)<>"{nl}_resubmit" Then
        
          If(objProperty.UserVisible)Then
          
              strHTMLAttributeName  = "TurnDown." & objProperty.Name & "(" & Form.Grid.Row & ")"
              EventArg.HTMLRendered = EventArg.HTMLRendered & "<tr>" & vbNewLine
              EventArg.HTMLRendered = EventArg.HTMLRendered & "<td Class='TableDetailCell' nowrap>" & objProperty.Caption & "</td>" & vbNewLine
              
              'strValue = TRIM("" & objProperty.NonLocalizedValue)
              
              If IsArray(objProperty.Value) Then
                  strValue = MDM_ERROR_1026
              Else
                  strValue = SafeForHtml(TRIM("" & objProperty.Value))
              End If
              If(Len(strValue)=0)Then
                  strValue  = "&nbsp;"
              End If
              EventArg.HTMLRendered = EventArg.HTMLRendered & "<td Name='" & strHTMLAttributeName & "' Class='TableDetailCell' nowrap>" & strValue & " </td>" & vbNewLine
              EventArg.HTMLRendered = EventArg.HTMLRendered & "</tr>" & vbNewLine
          End If
        End If        
    Next
    EventArg.HTMLRendered = EventArg.HTMLRendered & "</TABLE>" & vbNewLine
    EventArg.HTMLRendered = EventArg.HTMLRendered & "</td>" & vbNewLine
    
    Form_DisplayDetailRow = TRUE
END FUNCTION

%>










