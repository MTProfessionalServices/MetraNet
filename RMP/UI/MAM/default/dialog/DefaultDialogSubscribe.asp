<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
 <%
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile: DefaultDialogSubscribe.asp$
' 
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
'  Created by: K.Boucher
' 
'  $Date: 11/12/2002 2:00:01 PM$
'  $Author: Kevin Boucher$
'  $Revision: 26$
'
' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
'
' CLASS       : DefaultDialogSubscribe.asp
' DESCRIPTION : 
' 
' PICKER INTERFACE : A Picker ASP File Interface is based on the QueryString Name/Value.
'                    NextPage : The url to execute if a user click a one item. This url must accept a querystring
'                    parameter ID. ID will contains this id of the Item.
' ---------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../../MamIncludeMDM.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MamLibrary.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/common/mdmPicker.Library.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MTProductCatalog.Library.asp" -->
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" --> 
<%
Form.Version                    = MDM_VERSION     ' Set the dialog version - we are version 2.0.
Form.RouteTo                    = mam_GetDictionary("SETUP_SUBSCRIPTIONS_DIALOG") 
Form.Page.MaxRow                = CLng(mam_GetDictionary("PV_ROW_PER_PAGE"))
Form.Page.NoRecordUserMessage   = mam_GetDictionary("PRODUCT_VIEW_BROWSER_NO_RECORDS_FOUND")

mdm_PVBrowserMain ' invoke the mdm framework

PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean
  session("SUBS_DATE_CANCEL_ROUTETO") = request.serverVariables("URL") & "?" & request.serverVariables("QUERY_STRING")
  
  Form.Clear
  ProductView.Clear  ' Set all the property of the service to empty or to the default value
  ProductView.Properties.Clear
  ProductView.Properties.Flags = eMSIX_PROPERTIES_FLAG_PRODUCTVIEW
    
  Form_Initialize = MDMPickerDialog.Initialize(EventArg)
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION        :  Form_LoadProductView
' PARAMETERS      :
' DESCRIPTION     : 
' RETURNS         :  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_LoadProductView(EventArg) ' As Boolean

  Dim objMTProductCatalog , MTAccountReference, acctID
  
  Form_LoadProductView = FALSE

  ' Init view date
  If IsEmpty(Form("datStartDate")) Then
      Form("datStartDate") = mam_GetHierarchyDate()
  End If
      
  Set objMTProductCatalog = GetProductCatalogObject

  acctID = mam_GetSubscriberAccountID()
  
 ' Get account reference
  Set MTAccountReference = objMTProductCatalog.GetAccount(acctID)

  ' Get subscription rowset
  Set ProductView.Properties.RowSet = MTAccountReference.FindSubscribableProductOfferingsAsRowset(,Form("datStartDate").Value)  
  
  ' Add Change Date
  Service.Properties.Add "mdm_PVBChangeDate", "TIMESTAMP", 0, FALSE, Empty, eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET  
  Service.Properties("mdm_PVBChangeDate").Value = Form("datStartDate").value  
  
  ProductView.Properties.ClearSelection    
 ' ProductView.Properties.SelectAll  
 ' Select the properties I want to print in the PV Browser   Order
  ProductView.Properties("nm_display_name").Selected          = 1
  ProductView.Properties("nm_desc").Selected                  = 2
  ProductView.Properties("b_recurringcharge").Selected        = 3  
  ProductView.Properties("b_discount").Selected               = 4  
  
  ProductView.Properties("nm_display_name").Caption      = mam_GetDictionary("TEXT_SUBSCRIPTION")   
  ProductView.Properties("nm_desc").Caption              = mam_GetDictionary("TEXT_SUBSCRIPTION_DESCRIPTION")   
  ProductView.Properties("b_recurringcharge").Caption    = mam_GetDictionary("TEXT_RECURRING_CHARGE")   
  ProductView.Properties("b_discount").Caption           = mam_GetDictionary("TEXT_DISCOUNT")   
      
  ProductView.Properties("nm_display_name").Sorted      = MTSORT_ORDER_ASCENDING
  Set Form.Grid.FilterProperty                          = ProductView.Properties("nm_display_name") ' Set the property on which to apply the filter  

  Service.LoadJavaScriptCode  ' This line is important to get JavaScript field validation
 
  ' Include Calendar javascript    
  mam_IncludeCalendar
    
  Form_LoadProductView = TRUE
  
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : 
' PARAMETERS    :
' DESCRIPTION   :
' RETURNS       : Return TRUE if ok else FALSE
PRIVATE FUNCTION mdm_PVBChangeDateRefresh_Click(EventArg) ' As Boolean

    Form("datStartDate") =  Service.Properties("mdm_PVBChangeDate").Value 
    mdm_PVBChangeDateRefresh_Click = TRUE
END FUNCTION 
   
' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION       : 
' PARAMETERS    :
' DESCRIPTION   :
' RETURNS        : Return TRUE if ok else FALSE
PRIVATE FUNCTION OK_Click(EventArg) ' As Boolean
    OK_Click = MDMPickerDialog.OK_Click(EventArg)
END FUNCTION  

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION   : Form_DisplayCell
' PARAMETERS :
' DESCRIPTION :
' RETURNS    : 
PUBLIC FUNCTION Form_DisplayCell(EventArg) ' As Boolean
    Dim url
    Dim m_objPP, strCheckStatus, strID,HTML_LINK_EDIT
    
    Select Case Form.Grid.Col
    
         Case 1
            HTML_LINK_EDIT = HTML_LINK_EDIT  & "<td class='[CLASS]' Width='16'>"
            HTML_LINK_EDIT = HTML_LINK_EDIT  & "<INPUT Type='[CONTROL_TYPE]' Name='PickerItem' value='I[ID]' [CHECK_STATUS] [ON_CLICK] >"

            HTML_LINK_EDIT = HTML_LINK_EDIT  & "</td>"        
            
            Set m_objPP = mdm_CreateObject(CPreProcessor)
            m_objPP.Add "CLASS"       , Form.Grid.CellClass
            
            m_objPP.Add "CONTROL_TYPE"  , IIF(Form("MonoSelect"),"Radio","CheckBox")
            m_objPP.Add "ON_CLICK"      , IIF(Form("MonoSelect"),"","OnClick='mdm_RefreshDialog(this);'")
            m_objPP.Add "ID"            , ProductView.Properties.Rowset.Value("id_po") ' is this correct?
            
            strID = "I" & CStr(ProductView.Properties.Rowset.Value("id_po"))
            If(Form("SelectedIDs").Exist(strID))Then
                strCheckStatus   =  IIF(Form("SelectedIDs").Item(strID).Value=1,"CHECKED",Empty)
            Else
                strCheckStatus  = Empty ' Not Selected
            End If
            
            If(Form("MonoSelect"))THen
              If(Form("SelectedIDs").Count=0)and(Form.Grid.Row = 1)Then
                  strCheckStatus   =  "CHECKED"
              End If
            End If
            
            m_objPP.Add "CHECK_STATUS" , strCheckStatus
            
            EventArg.HTMLRendered     = m_objPP.Process(HTML_LINK_EDIT)
            Form_DisplayCell          = TRUE
        Case 2
            mdm_NoTurnDownHTML EventArg ' Takes Care Of Removing the TurnDown

        Case 3
            EventArg.HTMLRendered  =  EventArg.HTMLRendered  & "<td nowrap class='" & Form.Grid.CellClass & "' align='" & Form.Grid.SelectedProperty.Alignment & "'>"
            
            On Error Resume Next
            url = ProductView.Properties.Rowset.Value("t_ep__c_InternalInformationURL")
            
            If Len(Trim(url)) Then
              EventArg.HTMLRendered  = EventArg.HTMLRendered & "<a href=""JavaScript:Info('" & url & "')""><img border='0' src='../localized/en-us/images/info.gif'></a>&nbsp;" 
            End If
            On Error Goto 0            

            EventArg.HTMLRendered  =  EventArg.HTMLRendered & Form.Grid.SelectedProperty.Value & "</td>"
            Form_DisplayCell = TRUE               

        case 5,6  '   "b_recurringcharge"
            If UCase(Form.Grid.SelectedProperty.value) = "N" then
              EventArg.HTMLRendered     =  "<td class=" & Form.Grid.CellClass & " align='center'>--&nbsp;</td>"
            Else
              EventArg.HTMLRendered     =  "<td class=" & Form.Grid.CellClass & " align='center'><img src='../localized/en-us/images/check.gif'></td>"
            End If
            
            Form_DisplayCell = TRUE                        
        Case Else        
           Form_DisplayCell =  Inherited("Form_DisplayCell()") ' Call the default implementation
    End Select
END FUNCTION

%>

