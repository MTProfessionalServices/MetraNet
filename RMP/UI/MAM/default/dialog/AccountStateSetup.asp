<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
 <%
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile$
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
'  $Date$
'  $Author$
'  $Revision$
'
' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
'
' CLASS       : AccountStateSetup.asp
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
Form.RouteTo = mam_GetDictionary("WELCOME_DIALOG")
Form.Page.MaxRow  = CLng(mam_GetDictionary("PV_ROW_PER_PAGE"))
Form.Page.NoRecordUserMessage   = mam_GetDictionary("PRODUCT_VIEW_BROWSER_NO_RECORDS_FOUND")

mdm_PVBrowserMain ' invoke the mdm framework

PUBLIC FUNCTION Form_Initialize(EventArg) ' As Boolean
  Form_Initialize = TRUE
END FUNCTION
		
' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION     :  Form_LoadProductView
' PARAMETERS   :
' DESCRIPTION  : 
' RETURNS      :  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_LoadProductView(EventArg) ' As Boolean

  ProductView.Properties.Flags = eMSIX_PROPERTIES_FLAG_PRODUCTVIEW ' Tell the ProductView object to behave like a ProductView
   
	Set ProductView.Properties.Rowset = SubscriberYAAC().GetStateHistory()
	 
   ' Select the properties I want to print in the PV Browser   Order
 	ProductView.Properties.ClearSelection
	ProductView.Properties("status").Selected 	          = 1  
  ProductView.Properties("vt_start").Selected 			    = 2
	ProductView.Properties("vt_end").Selected 	          = 3
	
  Service.Properties("status").SetPropertyType "ENUM", FrameWork.Dictionary.Item("ACCOUNT_CREATION_SERVICE_ENUM_TYPE_LOADING").Value , "AccountStatus"
	
  ' Localize Headers
  ProductView.Properties("vt_start").Caption            = mam_GetDictionary("TEXT_START_DATE")
	ProductView.Properties("vt_end").Caption 	            = mam_GetDictionary("TEXT_END_DATE")
	ProductView.Properties("status").Caption 	            = mam_GetDictionary("TEXT_STATUS")
	
  ' Sort
  ProductView.Properties("vt_start").Sorted = MTSORT_ORDER_ASCENDING
  
  Session("MAX_END_DATE") = CDate("1/1/1970")
  
	Form_LoadProductView                      = TRUE
  
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
		        HTML_LINK_EDIT = HTML_LINK_EDIT  & "<td class='[CLASS]' Width='40'>"
            
            If CheckForUpdate(CStr(ProductView.Properties("status").value)) Then
              HTML_LINK_EDIT = HTML_LINK_EDIT  & "<A href='" & mam_GetDictionary("ACCOUNT_STATE_EDIT_DIALOG") & "?status=[STATUS]&month=[MONTH]&day=[DAY]&year=[YEAR]'><img alt='" & _
                                                mam_GetDictionary("TEXT_EDIT") & "' src='" & mam_GetImagesPath() &  "/edit.gif' Border='0'></A>&nbsp;&nbsp;"
						Else
              HTML_LINK_EDIT = HTML_LINK_EDIT  & "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" 
            End If
                                                            
						HTML_LINK_EDIT = HTML_LINK_EDIT  & "<img align='absmiddle' style='filter:alpha(opacity=50);' src='" & mam_GetImagesPath() &  "/state/" & CStr(ProductView.Properties("status").value) & ".gif' Border='0'>"						
            
            HTML_LINK_EDIT = HTML_LINK_EDIT  & "</td>"   

            
            Set m_objPP = mdm_CreateObject(CPreProcessor)
            m_objPP.Add "CLASS"       , Form.Grid.CellClass
            m_objPP.Add "STATUS"      , ProductView.Properties("status")
            m_objPP.Add "MONTH"       , Month(CDate(ProductView.Properties("vt_start")))
            m_objPP.Add "DAY"         , Day(CDate(ProductView.Properties("vt_start")))
            m_objPP.Add "YEAR"        , Year(CDate(ProductView.Properties("vt_start")))
           
            EventArg.HTMLRendered     = m_objPP.Process(HTML_LINK_EDIT)
            Form_DisplayCell          = TRUE
        Case 2
            mdm_NoTurnDownHTML EventArg ' Takes Care Of Removing the 
        case 4
            EventArg.HTMLRendered = "<td class=" & Form.Grid.CellClass & ">" & mam_GetDisplayEndDate(ProductView.Properties("VT_Start")) & "</td>"
            Form_DisplayCell = TRUE                
        case 5
            EventArg.HTMLRendered = "<td class=" & Form.Grid.CellClass & ">" & mam_GetDisplayEndDate(ProductView.Properties("VT_End")) & "</td>"
            if(ProductView.Properties("VT_End") > Session("MAX_END_DATE")) then
                Session("MAX_END_DATE") = ProductView.Properties("VT_End")
            end if
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

on error resume next
    
    '  add some code at the end of the product view UI
    Dim objTempYAAC
    'Set objTempYAAC = FrameWork.AccountCatalog.GetAccount(CLng(mam_GetSubscriberAccountID()), CDate(mam_GetDictionary("END_OF_TIME"))) 
    Set objTempYAAC = FrameWork.AccountCatalog.GetAccount(CLng(mam_GetSubscriberAccountID()), mam_ConvertToSysDate(Session("MAX_END_DATE"))) 
    
    Set Form("CurrentState") = objTempYAAC.GetAccountStateMgr().GetStateObject()                    
    
    strEndOfPageHTMLCode = "<tr><td colspan=""5"" align=""center""><br>"
    
    if(Form("CurrentState") <> NULL) then
		Select Case UCase(Form("CurrentState").Name)		
				Case "AC", "PA"
          If FrameWork.CheckCoarseCapability("Update account from active to suspended") or FrameWork.CheckCoarseCapability("Update account from active to closed") Then 
            strEndOfPageHTMLCode = strEndOfPageHTMLCode & "<button class='clsButtonLarge' name=""changestate"" onclick=""window.location.href='" & mam_GetDictionary("ACCOUNT_STATE_UPDATE_DIALOG") & "?MDMReload=TRUE" & "';return false;"">" & mam_GetDictionary("ACCOUNT_STATE_UPDATE")
          Else
            strEndOfPageHTMLCode = strEndOfPageHTMLCode & "<button disabled class='clsButtonLarge' name=""changestate"" onclick=""window.location.href='" & mam_GetDictionary("ACCOUNT_STATE_UPDATE_DIALOG") & "?MDMReload=TRUE" & "';return false;"">" & mam_GetDictionary("ACCOUNT_STATE_UPDATE")   
          End If
  			Case "SU"
          If FrameWork.CheckCoarseCapability("Update account from suspended to active") Then         
            strEndOfPageHTMLCode = strEndOfPageHTMLCode & "<button class='clsButtonLarge' name=""changestate"" onclick=""window.location.href='" & mam_GetDictionary("ACCOUNT_STATE_UPDATE_DIALOG") & "?MDMReload=TRUE" & "';return false;"">" & mam_GetDictionary("ACCOUNT_STATE_UPDATE")
          Else
            strEndOfPageHTMLCode = strEndOfPageHTMLCode & "<button disabled class='clsButtonLarge' name=""changestate"" onclick=""window.location.href='" & mam_GetDictionary("ACCOUNT_STATE_UPDATE_DIALOG") & "?MDMReload=TRUE" & "';return false;"">" & mam_GetDictionary("ACCOUNT_STATE_UPDATE")                   
          End If
        Case "PF"
          If FrameWork.CheckCoarseCapability("Update account from pending final bill to active") Then         
            strEndOfPageHTMLCode = strEndOfPageHTMLCode & "<button class='clsButtonLarge' name=""changestate"" onclick=""window.location.href='" & mam_GetDictionary("ACCOUNT_STATE_UPDATE_DIALOG") & "?MDMReload=TRUE" & "';return false;"">" & mam_GetDictionary("ACCOUNT_STATE_UPDATE")
          Else
            strEndOfPageHTMLCode = strEndOfPageHTMLCode & "<button disabled class='clsButtonLarge' name=""changestate"" onclick=""window.location.href='" & mam_GetDictionary("ACCOUNT_STATE_UPDATE_DIALOG") & "?MDMReload=TRUE" & "';return false;"">" & mam_GetDictionary("ACCOUNT_STATE_UPDATE")                
          End If
        Case Else
          strEndOfPageHTMLCode = strEndOfPageHTMLCode & "<button disabled class='clsButtonLarge' name=""changestate"" onclick=""window.location.href='" & mam_GetDictionary("ACCOUNT_STATE_UPDATE_DIALOG") & "?MDMReload=TRUE" & "';return false;"">" & mam_GetDictionary("ACCOUNT_STATE_UPDATE")                 
		End Select    
	else
        strEndOfPageHTMLCode = strEndOfPageHTMLCode & "<button disabled class='clsButtonLarge' name=""changestate"" onclick=""window.location.href='" & mam_GetDictionary("ACCOUNT_STATE_UPDATE_DIALOG") & "?MDMReload=TRUE" & "';return false;"">" & mam_GetDictionary("ACCOUNT_STATE_UPDATE")                   
    end if
    strEndOfPageHTMLCode = strEndOfPageHTMLCode    
        
    ' Here we must not forget to concat rather than set because we want to keep the result of the inherited event.
    ' CORE-4906, include the button as an additional table row and concat *before* the EventArg.HTMLRendered so that the button is contained within the </FORM></BODY></HTML> on the page. When the button used to be below the </HTML> tag, the button would jump by a few pixels on click the first time in IE.
    EventArg.HTMLRendered =  strEndOfPageHTMLCode & "</td></tr>" & EventArg.HTMLRendered

    Form_DisplayEndOfPage = TRUE
END FUNCTION

PRIVATE FUNCTION CheckForUpdate(strState)

		Select Case UCase(strState)		
        Case "PA"
          'If FrameWork.CheckCoarseCapability("Update account from pending active approval to active") Then 
            CheckForUpdate = TRUE
          'Else
          '  CheckForUpdate = FALSE
          'End If
				Case "AC"
          If FrameWork.CheckCoarseCapability("Update account from active to suspended") or FrameWork.CheckCoarseCapability("Update account from active to closed") Then 
            CheckForUpdate = TRUE
          Else
            CheckForUpdate = FALSE
          End If
  			Case "SU"
          If FrameWork.CheckCoarseCapability("Update account from suspended to active") Then         
            CheckForUpdate = TRUE
          Else
            CheckForUpdate = FALSE
          End If
        Case "PF"
         ' If FrameWork.CheckCoarseCapability("Update account from pending final bill to active") Then            
           ' CheckForUpdate = TRUE
          'Else
            CheckForUpdate = FALSE
         ' End If
        Case Else
          CheckForUpdate = FALSE
		End Select  

END FUNCTION

%>

