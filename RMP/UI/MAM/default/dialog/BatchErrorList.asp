<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
 <%
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile: BatchErrorList.asp$
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
'  $Date: 11/6/2002 4:48:25 PM$
'  $Author: Frederic Torres$
'  $Revision: 14$
'
' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
'
' CLASS       : BatchErrorList.asp
' DESCRIPTION : 
' 
' ---------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../../MamIncludeMDM.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MamLibrary.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MTProductCatalog.Library.asp" -->
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" --> 
<%
Form.Version = MDM_VERSION     ' Set the dialog version - we are version 2.0.
Form.Page.MaxRow               =  CLng(mam_GetDictionary("PV_ROW_PER_PAGE"))
Form.Page.NoRecordUserMessage  =  mam_GetDictionary("PRODUCT_VIEW_BROWSER_NO_RECORDS_FOUND")

If IsEmpty(Session("BATCH_ERROR_RETURN_PAGE")) Then
  Session("BATCH_ERROR_RETURN_PAGE") = mam_GetDictionary("WELCOME_DIALOG")
End If

mdm_PVBrowserMain ' invoke the mdm framework

PUBLIC FUNCTION Form_Initialize(EventArg) ' As Boolean
  ProductView.Clear 
 	ProductView.Properties.ClearSelection
  ProductView.Properties.Flags = eMSIX_PROPERTIES_FLAG_PRODUCTVIEW

  If UCase(mdm_UIValue("WarningMode"))="TRUE" Then  
      FrameWork.Dictionary.Add "BATCH_ERROR_DIALOG_TITLE",  FrameWork.Dictionary.Item("TEXT_WARNING_TITLE").Value
  Else
      FrameWork.Dictionary.Add "BATCH_ERROR_DIALOG_TITLE",  FrameWork.Dictionary.Item("TEXT_ERROR_TITLE").Value
  End If

  Form("Close") = UCase(request.QueryString("CLOSE")) = "TRUE"     
  Form.ShowExportIcon = TRUE
                   
  Form_Initialize = TRUE
END FUNCTION
		
' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION     :  Form_LoadProductView
' PARAMETERS   :
' DESCRIPTION  : 
' RETURNS      :  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_LoadProductView(EventArg) ' As Boolean

  Form_LoadProductView = FALSE

  ProductView.Properties.Flags = eMSIX_PROPERTIES_FLAG_PRODUCTVIEW 
	
  If IsEmpty(Session("LAST_BATCH_ERRORS")) Then	
  
    Set ProductView.Properties.RowSet = server.CreateObject(MT_SQL_ROWSET_SIMULATOR_PROG_ID)
  Else
  
    Set ProductView.Properties.RowSet = Session("LAST_BATCH_ERRORS")

    ' Ensure the filter is cleared out when refresh is clicked
    if Len(mdm_UIValue("mdmPVBFilter")) = 0 and UCase(mdm_UIValue("mdmAction")) = "REFRESH" then
        dim objRowsetfilter  
		    Set objRowsetfilter = mdm_CreateObject(MTSQLRowsetFilter)
		    objRowsetfilter.Clear
		    Set ProductView.Properties.RowSet.Filter = objRowsetfilter
    end if

    ProductView.Properties.ClearSelection    
   
    ' Select the properties I want to print in the PV Browser   Order
    ' ProductView.Properties.SelectAll
    ProductView.Properties("id_acc").Selected = 1
    ProductView.Properties("accountname").Selected = 2
    ProductView.Properties("description").Selected = 3
  
    ProductView.Properties("id_acc").Caption = mam_GetDictionary("TEXT_ACCOUNT_ID")			
    ProductView.Properties("accountname").Caption = mam_GetDictionary("TEXT_ACCOUNT_NAME")		
    ProductView.Properties("description").Caption = mam_GetDictionary("TEXT_ERROR_DESCRIPTION")
     
    ProductView.Properties("id_acc").Sorted = MTSORT_ORDER_ASCENDING

    mdm_SetMultiColumnFilteringMode TRUE
    ProductView.LoadJavaScriptCode
  End If 

  Form_LoadProductView = TRUE
  
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
		        HTML_LINK_EDIT = HTML_LINK_EDIT  & "<td class='[CLASS]' Width='16'>"
            HTML_LINK_EDIT = HTML_LINK_EDIT  & "&nbsp;</td>"   
						
            Set m_objPP = mdm_CreateObject(CPreProcessor)
            m_objPP.Add "CLASS"       , Form.Grid.CellClass
           
            EventArg.HTMLRendered     = m_objPP.Process(HTML_LINK_EDIT)
            Form_DisplayCell          = TRUE
        Case 2
            mdm_NoTurnDownHTML EventArg ' Takes Care Of Removing the turndown 
				Case 4
						HTML_LINK_EDIT = HTML_LINK_EDIT  & "<td class='" & Form.Grid.CellClass & "'>"
            If Len(ProductView.Properties("accountname").Value) Then
    						HTML_LINK_EDIT = HTML_LINK_EDIT & mam_GetNameIDLink(ProductView.Properties("accountname"), ProductView.Properties("id_acc"), Empty, Empty)  
            End If
						HTML_LINK_EDIT = HTML_LINK_EDIT  & "</td>"
						EventArg.HTMLRendered = HTML_LINK_EDIT						
						Form_DisplayCell = TRUE			 	            
            
        Case 5 ' Error Description
            Dim strErrorMessage
        
            strErrorMessage = Session("objMAM").Dictionary.PreProcess(ProductView.Properties("description"))
    
		        HTML_LINK_EDIT = HTML_LINK_EDIT  & "<td class='[CLASS]'>"
            HTML_LINK_EDIT = HTML_LINK_EDIT  & strErrorMessage
            HTML_LINK_EDIT = HTML_LINK_EDIT  & "</td>"   
						
            Set m_objPP = mdm_CreateObject(CPreProcessor)
            m_objPP.Add "CLASS", Form.Grid.CellClass
           
            EventArg.HTMLRendered     = m_objPP.Process(HTML_LINK_EDIT)
            Form_DisplayCell          = TRUE            
            
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

    If Len(Session("BATCH_ERROR_RETURN_PAGE")) = 0  or CBool(Form("CLOSE")) Then
      Session("BATCH_ERROR_RETURN_PAGE") = mam_GetDictionary("WELCOME_DIALOG")
    End If  

    '  add some code at the end of the product view UI
    If Form("Close") = FALSE Then
    
        strEndOfPageHTMLCode = "<br><div align='center'>"
        strEndOfPageHTMLCode = strEndOfPageHTMLCode & "<button class='clsButtonMedium' name=""back"" onclick=""document.location = '" & Session("BATCH_ERROR_RETURN_PAGE") &"';"">" & "Back" & "</button>&nbsp;&nbsp;&nbsp;"
        strEndOfPageHTMLCode = strEndOfPageHTMLCode & "</div>"
    Else
        strEndOfPageHTMLCode = "<br><div align='center'>"
        
        If UCase(mdm_UIValue("PopUpWindowMode"))="TRUE" Then  
          
            strEndOfPageHTMLCode = strEndOfPageHTMLCode & "<button class='clsButtonMedium' name=""back"" OnClick=""window.close();"">" & FrameWork.Dictionary.Item("TEXT_CLOSE").Value & "</button>&nbsp;&nbsp;&nbsp;"
        Else
            strEndOfPageHTMLCode = strEndOfPageHTMLCode & "<button class='clsButtonMedium' name=""back"" onclick=""parent.hideGuide();document.location = '" & Session("BATCH_ERROR_RETURN_PAGE") &"';"">" & FrameWork.Dictionary.Item("TEXT_CLOSE").Value  & "</button>&nbsp;&nbsp;&nbsp;"
        End If
        strEndOfPageHTMLCode = strEndOfPageHTMLCode & "</div>"
    End If    
    
   ' If UCase(mdm_UIValue("PopUpWindowMode"))<>"TRUE" Then    
   '       strEndOfPageHTMLCode = strEndOfPageHTMLCode & "<script language=""JavaScript1.2"">getFrameMetraNet().showGuide();</script>"
   ' End If
    
    ' Here we must not forget to concat rather than set because we want to keep the result of the inherited event.
    EventArg.HTMLRendered = EventArg.HTMLRendered & strEndOfPageHTMLCode
    
    Form_DisplayEndOfPage = TRUE
END FUNCTION


%>

