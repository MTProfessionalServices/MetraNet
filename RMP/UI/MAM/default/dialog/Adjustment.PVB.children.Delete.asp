<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
THIS DIALOG IS NOT USED
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


<!-- #INCLUDE FILE="../../default/Lib/CAdjustmentHelper.asp" -->
<!-- #INCLUDE FILE="../../default/Lib/CTransactionUIFinder.asp" -->

<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" -->
<%



Form.Version                      = MDM_VERSION     ' Set the dialog version

' I want only one page - we do not support the paging
Form.Page.MaxRow                  = CLng(mam_GetDictionary("PV_ROW_PER_PAGE"))/2
Form.Page.NoRecordUserMessage     = mam_GetDictionary("PRODUCT_VIEW_BROWSER_NO_RECORDS_FOUND")
Form.RouteTo                      = mam_GetDictionary("WELCOME_DIALOG")

PRIVATE AdjustmentHelper
Set AdjustmentHelper = New CAdjustmentHelper

mdm_PVBrowserMain ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: Form_Initialize
' PARAMETERS	:
' DESCRIPTION :
' RETURNS		  : Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean

  	ProductView.Clear  ' Set all the property of the service to empty or to the default value
    ProductView.Properties.Clear
   	ProductView.Properties.ClearSelection
    ProductView.Properties.Selector.Clear
    
    ProductView.Properties.Flags              = eMSIX_PROPERTIES_FLAG_PRODUCTVIEW
    Form.OnDisplayEndOfPageJavaScript         = ""    
    ProductView.Properties.Selector.ColumnID  = "SessionID" ' Specify the column id to use as the select key    
    Form_Initialize                           = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  Form_LoadProductView
' PARAMETERS:  EventArg
' DESCRIPTION: 
' RETURNS:  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_LoadProductView(EventArg) ' As Boolean
  
  Form_LoadProductView = FALSE
  
  Dim Rowset
  Set Rowset = mdm_CreateObject(MT_SQL_ROWSET_SIMULATOR_PROG_ID)
  
  Rowset.CloneFrom Session(SESSION_ADJ_CHILDREN_ROWSET),"IsPrebillAdjusted","Y"
    
  Set ProductView.Properties.RowSet = Rowset

  AdjustmentHelper.ChildrenPVBColumnSelection
    
  mdm_SetMultiColumnFilteringMode TRUE
    
  ProductView.LoadJavaScriptCode ' REQUIRED because we must generate the property type info in javascript. When the user change the property which he wants to use to do a filter we use the type of the property (JAVASCRIPT code) to show 2 textbox if it is a date else one.
    
  Form_LoadProductView = TRUE   
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :  Form_DisplayCell
' PARAMETERS    :  EventArg
' DESCRIPTION   :  
' RETURNS       :  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_DisplayCell(EventArg) ' As Boolean

    Dim objPreProcessor, strTemplateCheckBox
    
    Select Case Form.Grid.Col
    
        Case 1
              Set objPreProcessor = mdm_CreateObject(CPreProcessor)
                  
              strTemplateCheckBox = strTemplateCheckBox & "<td nowrap Class='[CLASS]'>[PREBILLADJUSTED_STATUS] [POSTBILLADJUSTED_STATUS]"
              ' 
              ' We need to have another information. because the transaction can be billed but not adjustment this mean this post bill adjustment
              ' can be deleted
              '
              If ProductView.Properties.Rowset.Value("IsPrebillTransaction")="Y" Then
                  
                  If ProductView.Properties.Rowset.Value("IsPrebillAdjusted")="Y" Then
                  
                      'strTemplateCheckBox = strTemplateCheckBox & "<BUTTON Class='clsButtonBlueMedium' Name='DeleteChildAdjustment'  OnClick='mdm_RefreshDialogUserCustom(this,""[CHILDID]"");'>[TEXT_DELETE]</BUTTON></A>"
                      strTemplateCheckBox = strTemplateCheckBox & "<INPUT Type='CheckBox' [CHECKBOX_SELECTED] Name='" & MDM_PVB_CHECKBOX_PREFIX & "[CHILDID]'>"
                  Else
                      
                  End If
                  '
                  ' If the transaction is pre bill there are no post bill adjustment
                  '          
              Else          
                  If ProductView.Properties.Rowset.Value("IsPostbillAdjusted")="Y" Then
                      '
                      ' If the adjustment has been bill we should display nothing, there is nothing left to do
                      ' this case is not supported yes
                      '
                      'strTemplateCheckBox = strTemplateCheckBox & "<BUTTON Class='clsButtonBlueMedium' Name='DeleteChildAdjustment'  OnClick='mdm_RefreshDialogUserCustom(this,""[CHILDID]"");'>[TEXT_DELETE]</BUTTON></A>"
                      strTemplateCheckBox = strTemplateCheckBox & "<INPUT Type='CheckBox' [CHECKBOX_SELECTED] Name='" & MDM_PVB_CHECKBOX_PREFIX & "[CHILDID]'>"
                  Else
                      
                  End If    
              End If              
              strTemplateCheckBox   = strTemplateCheckBox & "</td>"        
        
              objPreProcessor.Add "TEXT_DELETE"       , mam_GetDictionary("TEXT_DELETE")
              objPreProcessor.Add "CHECKBOX_SELECTED" , IIF(ProductView.Properties.Selector.IsItemSelected(ProductView.Properties("SessionID").Value),"CHECKED","") ' Select All mode
              objPreProcessor.Add "CHILDID"           , ProductView.Properties("SessionID").Value
              objPreProcessor.Add "CLASS"             , Form.Grid.CellClass
              
              objPreProcessor.Add "PREBILLADJUSTED_STATUS" , IIF(ProductView.Properties.Rowset.Value("IsPrebillAdjusted")="Y","PreBill Adjusted","")
              objPreProcessor.Add "POSTBILLADJUSTED_STATUS", IIF(ProductView.Properties.Rowset.Value("IsPostbillAdjusted")="Y","PostBill Adjusted","")              
              
              If(ProductView.Properties.Rowset.Value("IsPrebillAdjusted")="N" And ProductView.Properties.Rowset.Value("IsPostbillAdjusted")="N") Then
                  objPreProcessor.Add "PREBILLADJUSTED_STATUS" , "Not PreBill Adjusted"
              End If

              EventArg.HTMLRendered = objPreProcessor.Process(strTemplateCheckBox)
              Form_DisplayCell      = TRUE
        Case Else
            Form_DisplayCell = Inherited("Form_DisplayCell(EventArg)")
    End Select
END FUNCTION

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
PUBLIC FUNCTION Form_DisplayEndOfPage(EventArg) ' As Boolean

    Dim strEndOfPageHTMLCode, strTmp, strJavaScript
   
    Form_DisplayEndOfPageAddSelectButtons EventArg, strJavaScript, FALSE
    
    strTmp = "<br><button  name='butDeleteAdjustment' Class='clsButtonMedium' onclick='mdm_UpdateSelectedIDsAndReDrawDialog(this);'>[TEXT_DELETE]</button>" & vbNewLine
    strTmp = strTmp & "<button  name='butBack' Class='clsButtonMedium' OnClick='document.location=""[ADJUSTMENT_PVB_CHILDREN_DIALOG]""'>[TEXT_BACK]</button>" & vbNewLine
    
    strEndOfPageHTMLCode  = strEndOfPageHTMLCode & strTmp
    strEndOfPageHTMLCode  = strEndOfPageHTMLCode & "</FORM>"
    EventArg.HTMLRendered = EventArg.HTMLRendered & PreProcess(strEndOfPageHTMLCode,Array("TEXT_DELETE",mam_GetDictionary("TEXT_DELETE")))
    
    Inherited "OnDisplayEndOfPageJavaScript(EventArg)"
    
    Form_DisplayEndOfPage = TRUE
END FUNCTION

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
PRIVATE FUNCTION butDeleteAdjustment_Click(EventArg)

    Form_ChangePage EventArg,0,0 ' We need to call the event our self here so we update the ProductView.Properties.Selector

    Dim objIDs
    
    Set objIDs = ProductView.Properties.Selector.GetAllSelectedItemFromRowSet(ProductView.Properties.Rowset,"SessionID")
    
    If Not AdjustmentHelper.DeleteAdjustment(EventArg,objIDs) Then Exit Function
    
    Form.OnDisplayEndOfPageJavaScript = "document.location.href=""" & FrameWork.Dictionary.Item("ADJUSTMENT_FRAMESET_DIALOG").Value & """;"
    
    butDeleteAdjustment_Click         = TRUE
END FUNCTION

%>


