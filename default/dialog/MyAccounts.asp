<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
 <%
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile: MyAccounts.asp$
' 
'  Copyright 1998,2004 by MetraTech Corporation
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
'  $Date: 11/15/04 12:00:08 PM$
'  $Author: $
'  $Revision: 1$
'
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../../MamIncludeMDM.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MamLibrary.asp" -->
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" --> 
<%
PUBLIC CONST VIEW_HINT_DIRECT = 0
PUBLIC CONST VIEW_HINT_DIRECET_DESCENDENTS = 1
PUBLIC CONST VIEW_HINT_All_DESCENDENTS = 2

Form.Version = MDM_VERSION  
Form.RouteTo = mam_GetDictionary("WELCOME_DIALOG")
Form.Page.MaxRow  = CLng(mam_GetDictionary("PV_ROW_PER_PAGE"))
Form.Page.NoRecordUserMessage   = mam_GetDictionary("PRODUCT_VIEW_BROWSER_NO_RECORDS_FOUND")

mdm_PVBrowserMain ' Invoke the mdm framework

PUBLIC FUNCTION Form_Initialize(EventArg) ' As Boolean
  Form.Grid.FilterMode = TRUE
  Form_Initialize = TRUE
END FUNCTION
    
' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION     :  Form_LoadProductView
' PARAMETERS   :
' DESCRIPTION  : 
' RETURNS      :  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_LoadProductView(EventArg) ' As Boolean

  Form_LoadProductView = FALSE
  on error resume next
  ProductView.Properties.Flags = eMSIX_PROPERTIES_FLAG_PRODUCTVIEW 
    
  ' Get Ownership manager and list of owned acounts as rowset - based on the time in the UserHierarchy
  Dim mgr
  If not IsEmpty(Session("CURRENT_SYSTEM_USER")) Then
    Set mgr = Session("CURRENT_SYSTEM_USER").GetOwnershipMgr()
  Else
    Set mgr = FrameWork.AccountCatalog.GetAccount(CLng(MAM().CSR("_AccountID").Value), mam_ConvertToSysDate(mam_GetSystemUserHierarchyTime())).GetOwnershipMgr() 
  End If
  Set ProductView.Properties.RowSet = mgr.GetOwnedAccountsHierarchicalAsRowset(CLng(VIEW_HINT_All_DESCENDENTS))
  CheckAndWriteError
  ProductView.Properties.AddPropertiesFromRowset ProductView.Properties.RowSet

  ProductView.Properties.ClearSelection    
 
 '  Select the properties I want to print in the PV Browser   Order
 '  ProductView.Properties.SelectAll
 '  {NL}id_owner   {NL}id_owned   {NL}id_relation_type   {NL}n_percent   
 '  {NL}vt_start   {NL}vt_end   {NL}RelationType   {NL}DirectOwner   {NL}OwnerName   {NL}OwnedName  

  ProductView.Properties("OwnedName").Selected = 1
  ProductView.Properties("n_percent").Selected = 2
  ProductView.Properties("RelationType").Selected = 3
  ProductView.Properties("VT_Start").Selected = 4
  ProductView.Properties("VT_End").Selected   = 5
  ProductView.Properties("DirectOwner").Selected = 6
  ProductView.Properties("OwnerName").Selected = 7
    
  ProductView.Properties("OwnedName").Caption = mam_GetDictionary("TEXT_OWNED_HIERARCHYNAME")
  ProductView.Properties("RelationType").Caption = mam_GetDictionary("TEXT_OWNED_RELATION_TYPE")
  ProductView.Properties("n_percent").Caption = mam_GetDictionary("TEXT_PERCENT_OWNERSHIP")
  ProductView.Properties("DirectOwner").Caption = mam_GetDictionary("TEXT_DIRECT_OWNER")
  ProductView.Properties("VT_Start").Caption = mam_GetDictionary("TEXT_EFFECTIVE_START_DATE")  
  ProductView.Properties("VT_End").Caption   = mam_GetDictionary("TEXT_EFFECTIVE_END_DATE")   
  ProductView.Properties("RelationType").Caption = mam_GetDictionary("TEXT_OWNED_RELATION_TYPE")
  ProductView.Properties("OwnerName").Caption = mam_GetDictionary("TEXT_OWNER_ACCOUNT")  
        
  ProductView.Properties("OwnedName").Sorted = MTSORT_ORDER_ASCENDING
  mdm_SetMultiColumnFilteringMode TRUE
  Set Form.Grid.FilterProperty = ProductView.Properties("OwnedName") ' Set the property on which to apply the filter    

  CheckAndWriteError
  on error goto 0
  Form_LoadProductView = TRUE
  
END FUNCTION

    
' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION    : 
' PARAMETERS  :
' DESCRIPTION :
' RETURNS     : Return TRUE if ok else FALSE
PRIVATE FUNCTION OK_Click(EventArg) ' As Boolean

    OK_Click = TRUE
END FUNCTION  

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION   : Form_DisplayCell
' PARAMETERS :
' DESCRIPTION :
' RETURNS    : 
PUBLIC FUNCTION Form_DisplayCell(EventArg) ' As Boolean   
    Dim m_objPP, HTML_LINK_EDIT
    Dim strHTML
    Dim strMsgBox

    Select Case Form.Grid.Col
    
         Case 1
            HTML_LINK_EDIT = HTML_LINK_EDIT  & "<td nowrap class='[CLASS]' Width='36'>"
           
            If FrameWork.CheckCoarseCapability("Manage Owned Accounts") Then
              HTML_LINK_EDIT = HTML_LINK_EDIT  & "<A href='#' onclick='JavaScript:parent.getFrameMetraNet().Account.ShowHierarchyTab(" & ProductView.Properties("id_owned") & ");'><img alt='" & mam_GetDictionary("TEXT_FIND_IN_HIERARCHY") & "' src='" & mam_GetImagesPath() &  "/sync.gif' Border='0'></A>"						

              ' View online bill
              If FrameWork.CheckCoarseCapability("View Online Bill") Then  
              HTML_LINK_EDIT = HTML_LINK_EDIT  & "<A href='JavaScript:parent.getFrameMetraNet().Account.LoadPage(" & ProductView.Properties("id_owned") & ", ""/MetraNet/ViewOnlineBill.aspx"");'><img alt='" & mam_GetDictionary("TEXT_VIEW_ONLINE_BILL") & "' src='" & mam_GetImagesPath() &  "/web.gif' Border='0'></A>"					
              End If
          
            End If
                          
            HTML_LINK_EDIT = HTML_LINK_EDIT  & "</td>"        
            
            Set m_objPP = mdm_CreateObject(CPreProcessor)
            m_objPP.Add "CLASS"       , Form.Grid.CellClass
           
            EventArg.HTMLRendered     = m_objPP.Process(HTML_LINK_EDIT)
            Form_DisplayCell          = TRUE
        Case 2
            mdm_NoTurnDownHTML EventArg ' Takes Care Of Removing the 
        
        Case 3
            HTML_LINK_EDIT = HTML_LINK_EDIT  & "<td nowrap class='" & Form.Grid.CellClass & "'>"
            HTML_LINK_EDIT = HTML_LINK_EDIT & mam_GetNameIDLink(Empty, ProductView.Properties("id_owned"), ProductView.Properties("OwnedName"), TRUE)
            HTML_LINK_EDIT = HTML_LINK_EDIT  & "</td>"
            EventArg.HTMLRendered = HTML_LINK_EDIT            
            Form_DisplayCell = TRUE
                    
        case 6
            EventArg.HTMLRendered = "<td nowrap class=" & Form.Grid.CellClass & ">" & mam_GetDisplayEndDate(ProductView.Properties("VT_Start")) & "</td>"
            Form_DisplayCell = TRUE                
        case 7
            EventArg.HTMLRendered = "<td nowrap class=" & Form.Grid.CellClass & ">" & mam_GetDisplayEndDate(ProductView.Properties("VT_End")) & "</td>"
            Form_DisplayCell = TRUE                
              
        case 8
            If ProductView.Properties("DirectOwner").value <> "1" then
              EventArg.HTMLRendered     =  "<td nowrap class=" & Form.Grid.CellClass & " align='center'>--&nbsp;</td>"
            Else
              EventArg.HTMLRendered     =  "<td nowrap class=" & Form.Grid.CellClass & " align='center'><img src='" & mam_GetImagesPath() &  "/check.gif'></td>"
            End If        
            Form_DisplayCell = TRUE  
                        
        Case Else        
            Form_DisplayCell =  Inherited("Form_DisplayCell()") ' Call the default implementation
    End Select
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION   :  inheritedForm_DisplayEndOfPage
' PARAMETERS :  EventArg
' DESCRIPTION:  Override end of table to place add button
' RETURNS    :  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_DisplayEndOfPage(EventArg) ' As Boolean

    dim strEndOfPageHTMLCode
    
    ' Call the inherited event so we close the ProductVIew Browser as it should be
    ' Becare full this function is setting     EventArg.HTMLRendered
    Inherited("Form_DisplayEndOfPage()")
    
    '  add some code at the end of the product view UI
    strEndOfPageHTMLCode = "<br><div align='center'>"
    strEndOfPageHTMLCode = strEndOfPageHTMLCode & "</div>"
        
    ' Here we must not forget to concat rather than set because we want to keep the result of the inherited event.
    EventArg.HTMLRendered = EventArg.HTMLRendered & strEndOfPageHTMLCode
    
    Form_DisplayEndOfPage = TRUE
END FUNCTION
%>

