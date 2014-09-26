 <% 
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile: IntervalManagement.Statistics.Render.asp$
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
'  Created by: Rudi
' 
'  $Date: 11/15/2002 12:36:18 PM$
'  $Author: Rudi Perkins$
'  $Revision: 2$
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
<!-- #INCLUDE FILE="../../default/lib/IntervalManagementLibrary.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/FrameWork/CFrameWork.Class.asp" -->

<%
Form.Version                    = MDM_VERSION     ' Set the dialog version - we are version 2.0.
Form.ErrorHandler               = FALSE  
Form.ShowExportIcon             = TRUE
'Form.Page.MaxRow                = CLng(FrameWork.GetDictionary("MAX_ROW_PER_LIST_PAGE"))
'Form.Page.NoRecordUserMessage   = FrameWork.GetDictionary("PRODUCT_VIEW_BROWSER_NO_RECORDS_FOUND")

mdm_PVBrowserMain ' invoke the mdm framework

PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean
    'BreadCrumb.SetCrumb FrameWork.GetDictionary("TEXT_VIEW_AUDIT_LOG")
    Framework.AssertCourseCapability "Manage EOP Adapters", EventArg
    ProductView.Clear  ' Set all the property of the service to empty or to the default value
   	ProductView.Properties.ClearSelection
    ProductView.Properties.Flags = eMSIX_PROPERTIES_FLAG_PRODUCTVIEW

    '//Save the parameters passed to us
    Form("QueryTag") = request("QueryTag")
    Form("QueryTitle") = request("QueryTitle")    
    Form("IntervalId") = request("IntervalId")
    Form("BillingGroupId") = request("BillingGroupId")
    Form("LanguageId") = request("LanguageId")
    
    Form_Initialize = true
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  Form_LoadProductView
' PARAMETERS:  EventArg
' DESCRIPTION: 
' RETURNS:  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_LoadProductView(EventArg) ' As Boolean

  Form_LoadProductView = FALSE
  
  dim rowset
  set rowset = server.CreateObject("MTSQLRowset.MTSQLRowset.1")
  rowset.Init "queries\statistics"
  rowset.SetQueryTag(Form("QueryTag"))  
  rowset.AddParam "%%ID_INTERVAL%%", Clng(Form("IntervalId"))
  
  '//If this is a billing group query, then we must specify the billing group id (not optional)
  if (len(Form("BillingGroupId"))>0) then
      rowset.AddParam "%%ID_BILLINGGROUP%%", Clng(Form("BillingGroupId"))
  end if
  
  '//ID_LANG_CODE is optional
  if InStr(rowset.GetRawQueryString(true),"%%ID_LANG_CODE%%")<>0 then
    rowset.AddParam "%%ID_LANG_CODE%%", Clng(Form("LanguageId"))
  end if
  
  rowset.Execute

  
  '// Filter out everything except product catalog events
  If false Then
    dim objMTFilter
    Set objMTFilter = mdm_CreateObject(MTFilter)
    objMTFilter.Add "EntityType", OPERATOR_TYPE_EQUAL, 2
    set rowset.filter = objMTFilter
  End If
 

  
  ' Load a Rowset from a SQL Queries and build the properties collection of the product view based on the columns of the rowset
  Set ProductView.Properties.RowSet = rowset
  ProductView.Properties.AddPropertiesFromRowset rowset
  
  ProductView.Properties.SelectAll

  ProductView.Properties.CancelLocalization
  
  Service.Properties.Add "QueryTitle", "string", 255, False, 0, eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET
  Service.Properties("QueryTitle").Value=Form("QueryTitle")
  
  Service.Properties.Add "QueryTag", "string", 255, False, 0, eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET
  Service.Properties("QueryTag").Value=Form("QueryTag")

  Service.Properties.Add "QueryParamIntervalId", "int32", 0, False, 0, eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET
  Service.Properties("QueryParamIntervalId").Value=Form("IntervalId")

  Service.Properties.Add "QueryParamLanguageId", "int32", 0, False, 0, eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET
  Service.Properties("QueryParamLanguageId").Value=Form("LanguageId")

  Service.Properties.Add "QueryString", "string", 4096, False, 0, eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET
  Service.Properties("QueryString").Value=rowset.GetQueryString()
  
        
  Form_LoadProductView                                  = TRUE ' Must Return TRUE To Render The Dialog
  
END FUNCTION


PRIVATE FUNCTION Form_DisplayCell(EventArg) ' As Boolean

       if Form.Grid.Col = 2 then
          EventArg.HTMLRendered     =  "<td class='" & Form.Grid.CellClass & "'>&nbsp;</td>"
          Form_DisplayCell = true
       else
          Form_DisplayCell = Inherited("Form_DisplayCell(EventArg)")
       end if

END FUNCTION

PRIVATE FUNCTION xForm_DisplayDetailRow(EventArg) ' As Boolean

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
        
        If(UCase(objProperty.Name)<>"MDMINTERVALID") And ((objProperty.Flags And eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET)=0) Then
        
          If(objProperty.UserVisible)Then
          
              strHTMLAttributeName  = "TurnDown." & objProperty.Name & "(" & Form.Grid.Row & ")"
              EventArg.HTMLRendered = EventArg.HTMLRendered & "<tr>" & vbNewLine
              EventArg.HTMLRendered = EventArg.HTMLRendered & "<td Class='TableDetailCell' nowrap>" & objProperty.Caption & "</td>" & vbNewLine
              
              'strValue = TRIM("" & objProperty.NonLocalizedValue)
              strValue = TRIM("" & objProperty.Value)
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

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :  inheritedForm_DisplayEndOfPage
' PARAMETERS    :  EventArg
' DESCRIPTION   :  Override end of table to place add button
' RETURNS       :  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_DisplayEndOfPage(EventArg) ' As Boolean

    Dim strEndOfPageHTMLCode, strTmp
    
    strEndOfPageHTMLCode = strEndOfPageHTMLCode & "</FORM>"

    strTmp = "</table><br><div id='DebugInfo' style='visibility:hidden;position:relative; left: 10px;'><table border='0' cellpadding='1' cellspacing='0' width='95%' style='background-color:WhiteSmoke;font-size:10px; font-family: Tahoma, Verdana, Arial, Helvetica, sans-serif; color:black; BORDER-BOTTOM: black solid 1px;	BORDER-LEFT: gray solid 1px;	BORDER-RIGHT: black solid 1px; BORDER-TOP: gray solid 1px;'><tr><td>&nbsp;</td><td style='BORDER-BOTTOM: black solid 1px;'><strong><font style='font-size:10px'>Query Information:</font></strong>&nbsp;<td width='14px' height='18px'><a href='#' onClick='hideDebugInfo();'><img src='/mom/default/localized/en-us/images/hide.gif' border='0' alt='Close' onMouseOver='showBorder(this);' onMouseOut='hideBorder(this);'></a></td><br><tr><td>&nbsp;</td><td style='font-size:10px'><strong>Query Tag:</strong> " & Service.Properties("QueryTag").Value & "<br><strong>Interval Id:</strong> " & Service.Properties("QueryParamIntervalId") & "<br><strong>Language Id:</strong> " & Service.Properties("QueryParamLanguageId") & "<br><strong>Query:</strong><br>" & Service.Properties("QueryString") & "<br></td><td>&nbsp;</td></tr></table><br></div>"
    strEndOfPageHTMLCode = strEndOfPageHTMLCode & strTmp
    strTmp = "<div id='ShowDebugInfo' style='vertical-align: top;position: relative; top: -100px; left: 10px'><a href='#' onClick='showDebugInfo();' title='Show Detailed Database Query Information'><img style='vertical-align: middle;' src='/mom/default/localized/en-us/images/infosmall.gif' border='0' alt='Show Detailed Database Query Information'></a> <a href='#' onClick='showDebugInfo();' title='Show Detailed Database Query Information'><font style='vertical-align: middle;font:10px'>Show Query Information</font></a></div>"
    strEndOfPageHTMLCode = strEndOfPageHTMLCode & strTmp
    strTmp = "<script>function showDebugInfo(){  document.all.DebugInfo.style.visibility='visible';  document.all.ShowDebugInfo.style.visibility='hidden';}function hideDebugInfo(){  document.all.DebugInfo.style.visibility='hidden';  document.all.ShowDebugInfo.style.visibility='visible';  }function showBorder(item){  item.style.borderWidth='1px';  item.style.borderLeftColor='white';  item.style.borderTopColor='white';  item.style.borderRightColor='black';  item.style.borderBottomColor='black';} function hideBorder(item){ item.style.borderWidth='0px';}</script></center>"
    strEndOfPageHTMLCode = strEndOfPageHTMLCode & strTmp

    ' Here we must not forget to concat rather than set because we want to keep the result of the inherited event.
    EventArg.HTMLRendered = EventArg.HTMLRendered & REPLACE(strEndOfPageHTMLCode,"[LOCALIZED_IMAGE_PATH]",mom_GetLocalizeImagePath())

    Form_DisplayEndOfPage = TRUE
END FUNCTION


%>
