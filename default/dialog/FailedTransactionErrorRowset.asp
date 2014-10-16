<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
 <%
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile: BatchErrorList.asp$
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
' ---------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/mdm.asp" -->
<!-- #INCLUDE FILE="../../default/lib/momLibrary.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/FrameWork/CFrameWork.Class.asp" -->
<%
Form.Version = MDM_VERSION 

mdm_PVBrowserMain 

PUBLIC FUNCTION Form_Initialize(EventArg) ' As Boolean

  Framework.AssertCourseCapability "Update Failed Transactions", EventArg
  ProductView.Clear
  
  FrameWork.Dictionary.Add "BATCH_ERROR_DIALOG_TITLE",  FrameWork.Dictionary.Item("TEXT_ERROR_TITLE").Value
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
	
  ProductView.Properties.Flags = eMSIX_PROPERTIES_FLAG_PRODUCTVIEW 
	
  If IsEmpty(Session("FAILED_TRANSACTION_ERROR_ROWSET")) Then	
  
    Set ProductView.Properties.RowSet = server.CreateObject(MT_SQL_ROWSET_SIMULATOR_PROG_ID)
    ProductView.Properties.AddPropertiesFromRowset  ProductView.Properties.RowSet  
    
  Else
 
    Call mdm_ClearPVBFilter(Session("FAILED_TRANSACTION_ERROR_ROWSET"))
  
    ProductView.Properties.AddPropertiesFromRowset ProductView.Properties.RowSet
  
    ProductView.Properties.ClearSelection    
   
    ' Select the properties I want to print in the PV Browser   Order
    ' ProductView.Properties.SelectAll
    ProductView.Properties("tx_uid_encoded").Selected = 1
    ProductView.Properties("exception").Selected = 2
  
    ProductView.Properties("tx_uid_encoded").Caption = FrameWork.Dictionary.Item("TEXT_TX_UID_ENCODED").Value
    ProductView.Properties("exception").Caption = FrameWork.Dictionary.Item("TEXT_EXCEPTION").Value
  
    ProductView.Properties("tx_uid_encoded").Sorted = MTSORT_ORDER_ASCENDING
    Set Form.Grid.FilterProperty = ProductView.Properties("exception") ' Set the property on which to apply the filter  
 
  End If 
  
  Service.LoadJavaScriptCode 
  Form_LoadProductView = TRUE
  
END FUNCTION

    
' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION   : Form_DisplayCell
' PARAMETERS :
' DESCRIPTION :
' RETURNS    : 
PUBLIC FUNCTION Form_DisplayCell(EventArg) ' As Boolean

    Dim m_objPP, HTML_LINK_EDIT
		  
    Select Case Form.Grid.Col
    
         Case 1
	        HTML_LINK_EDIT = HTML_LINK_EDIT  & "<td class='[CLASS]' Width='16'>"
            HTML_LINK_EDIT = HTML_LINK_EDIT  & "&nbsp;</td>"   
						
            Set m_objPP = mdm_CreateObject(CPreProcessor)
            m_objPP.Add "CLASS", Form.Grid.CellClass
           
            EventArg.HTMLRendered = m_objPP.Process(HTML_LINK_EDIT)
            Form_DisplayCell = TRUE
            
        Case 2
            mdm_NoTurnDownHTML EventArg ' Takes Care Of Removing the 
            
        Case 4 ' Exception
            Dim strErrorMessage
        
            strErrorMessage = FrameWork.Dictionary.PreProcess(ProductView.Properties("exception"))
    
		    HTML_LINK_EDIT = HTML_LINK_EDIT  & "<td class='[CLASS]'>"
            HTML_LINK_EDIT = HTML_LINK_EDIT  & strErrorMessage
            HTML_LINK_EDIT = HTML_LINK_EDIT  & "</td>"   
						
            Set m_objPP = mdm_CreateObject(CPreProcessor)
            m_objPP.Add "CLASS", Form.Grid.CellClass
           
            EventArg.HTMLRendered = m_objPP.Process(HTML_LINK_EDIT)
            Form_DisplayCell = TRUE            
            
	      Case Else        
            Form_DisplayCell = Inherited("Form_DisplayCell()")
    End Select
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION   :  inheritedForm_DisplayEndOfPage
' PARAMETERS :  EventArg
' DESCRIPTION:  Override end of table to place add button
' RETURNS    :  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_DisplayEndOfPage(EventArg) ' As Boolean

    dim strEndOfPageHTMLCode
    
    Inherited("Form_DisplayEndOfPage()")

    strEndOfPageHTMLCode = "<br><div align='center'>"
    strEndOfPageHTMLCode = strEndOfPageHTMLCode & "<button class='clsButtonMedium' name=""back"" OnClick=""window.close();"">" & FrameWork.Dictionary.Item("TEXT_CLOSE").Value & "</button>&nbsp;&nbsp;&nbsp;"
    strEndOfPageHTMLCode = strEndOfPageHTMLCode & "</div>"

    EventArg.HTMLRendered = EventArg.HTMLRendered & strEndOfPageHTMLCode
    
    Form_DisplayEndOfPage = TRUE
END FUNCTION
%>

