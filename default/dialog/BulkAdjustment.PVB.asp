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


Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../../MamIncludeMDM.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MamLibrary.asp" -->
<!-- #INCLUDE FILE="../../default/Lib/CAdjustmentHelper.asp" -->
<!-- #INCLUDE FILE="../../default/Lib/CTransactionUIFinder.asp" -->
<!-- #INCLUDE FILE="../../default/Lib/Adjustments.OverRideAble.Customization.asp" -->

<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" -->

<%

Form.Version                      = MDM_VERSION     ' Set the dialog version
Form.Page.MaxRow                  = CLng(mam_GetDictionary("PV_ROW_PER_PAGE"))
Form.Page.NoRecordUserMessage     = mam_GetDictionary("PRODUCT_VIEW_BROWSER_NO_RECORDS_FOUND")
Form.RouteTo                      = mam_GetDictionary("WELCOME_DIALOG")

'Form.Page.MaxRow                  = 2

PRIVATE AdjustmentHelper
Set AdjustmentHelper            = New CAdjustmentHelper
AdjustmentHelper.BulkMode       = FALSE
AdjustmentHelper.ParentMode     = TRUE

PRIVATE m_booComeFromInitializeEvent
m_booComeFromInitializeEvent    = FALSE

PRIVATE PreProcessor
Set PreProcessor = mdm_CreateObject(CPreProcessor)

mdm_PVBrowserMain ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: Form_Initialize
' PARAMETERS	:
' DESCRIPTION :
' RETURNS		  : Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean

  	ProductView.Clear  ' Set all the property of the service to empty or to the default value
   	ProductView.Properties.ClearSelection
    ProductView.Properties.Flags = eMSIX_PROPERTIES_FLAG_PRODUCTVIEW

    Form.ShowExportIcon           = TRUE ' Export
    Form_Initialize               = TRUE   
    m_booComeFromInitializeEvent  = TRUE
    
    ProductView.Properties.Selector.ColumnID = "SessionID" ' Specify the column id to use as the select key
    ProductView.Properties.Selector.Clear
    
'  	ProductView.Configuration.DebugMode = FALSE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  Form_LoadProductView
' PARAMETERS:  EventArg
' DESCRIPTION: 
' RETURNS:  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_LoadProductView(EventArg) ' As Boolean
  
  Dim objMamBill, PriceAbleItemType, varRetVal
  
  
  Form_LoadProductView = FALSE
  
  ' If we initialize the dialog we do not need to refresh the dialog
  If Not m_booComeFromInitializeEvent Then
      
      TransactionUIFinder.UpdateFoundRowSet ' -- Force to reload the transaction info now that we have adjusted at least one
  End If
    
  ProductView.Properties.Name = TransactionUIFinder.ProductViewFQN
  Set ProductView.Properties.RowSet = Session(SESSION_ADJ_PARENT_ROWSET)
  
  If IsValidObject(ProductView.Properties.RowSet) Then
      
      ProductView.Properties.SelectAll
   
      Form("PriceAbleItemParentFQN") = mdm_MakeName(FrameWork.GetPricteAbleItemTypeFQN(TransactionUIFinder.SelectedPriceAbleItemTypeID))
      mdm_CallFunctionIfExist Form("PriceAbleItemParentFQN") & "_Adjustment_SelectColumns(ProductView)" , varRetVal
                        
      Service.Properties.TimeZoneId                              = MAM().CSR("TimeZoneId") ' Set the TimeZone, so the dates will be printed for the CSR time zone
      Service.Properties.DayLightSaving                          = mam_GetDictionary("DAY_LIGHT_SAVING")
      
      Set Form.Grid.PropertyID = ProductView.Properties("SessionID")
      mdm_SetMultiColumnFilteringMode TRUE
      
      ProductView.LoadJavaScriptCode ' REQUIRED because we must generate the property type info in javascript. When the user change the property which he wants to use to do a filter we use the type of the property (JAVASCRIPT code) to show 2 textbox if it is a date else one.
    
      Form_LoadProductView = TRUE 
  End If
END FUNCTION



PRIVATE FUNCTION Form_DisplayCell(EventArg) ' As Boolean

    Dim HTML_LINK_EDIT,  lngChildAdjustmentCount, strTMP
    Dim objPreProcessor, strTemplateCheckBox
    Select Case Form.Grid.Col
    
        Case 1
		      Set objPreProcessor = mdm_CreateObject(CPreProcessor)
              
          strTemplateCheckBox = strTemplateCheckBox & "<td nowrap Class='[CLASS]'>"
          ' 
          ' We need to have another information. because the transaction can be billed but not adjustment this mean this post bill adjustment
          ' can be deleted
          '
          
          strTemplateCheckBox = strTemplateCheckBox & "<INPUT Type='CheckBox' [CHECKBOX_SELECTED] Name='" & MDM_PVB_CHECKBOX_PREFIX & "[CHILDID]'>"
              
          strTemplateCheckBox   = strTemplateCheckBox & "</td>"        
    
          objPreProcessor.Add "TEXT_DELETE"             , mam_GetDictionary("TEXT_DELETE")
          objPreProcessor.Add "CHECKBOX_SELECTED"       , IIF(ProductView.Properties.Selector.IsItemSelected(ProductView.Properties("SessionID").Value),"CHECKED","") ' Select All mode
          objPreProcessor.Add "CHILDID"                 , ProductView.Properties("SessionID").Value
          objPreProcessor.Add "CLASS"                   , Form.Grid.CellClass
          
          EventArg.HTMLRendered = objPreProcessor.Process(strTemplateCheckBox)
          Form_DisplayCell      = TRUE
        Case 2
          Form_DisplayCell = Inherited("Form_DisplayCell()")   
        Case 9
        'code fix for core-6775 adjustment amount shows values in timestamp 
        '****Starts here******
        'code fix for core-6775 oracle and sql DB Values Form.Grid.SelectedProperty.Name="COMPOUNDPREBILLADJAMT" ||CompoundPrebillAdjAmt
        if UCase(Form.Grid.SelectedProperty.Name)="COMPOUNDPREBILLADJAMT" then
        Form_DisplayCell = Inherited("Form_DisplayCell()")
        else
        '****End Here******
            EventArg.HTMLRendered = EventArg.HTMLRendered  & "<TD nowrap Class='[CLASS]'>"
            EventArg.HTMLRendered = EventArg.HTMLRendered  & Framework.Format(ProductView.Properties.RowSet.Value("timestamp"),FrameWork.Dictionary.Item("DATE_TIME_FORMAT").Value)
            EventArg.HTMLRendered = EventArg.HTMLRendered  &  "</TD>"
            EventArg.HTMLRendered = PreProcess(EventArg.HTMLRendered,Array("CLASS", Form.Grid.CellClass))
        
        'code fix for core-6775 adjustment amount shows values in timestamp 
        '****Starts here******
        End if 
        '****End Here******
        Case Else
              
          Select Case UCase(Form.Grid.SelectedProperty.Name)
              
              Case "STATUS"
                  EventArg.HTMLRendered = EventArg.HTMLRendered  & "<TD nowrap Class='[CLASS]'>"
  							  EventArg.HTMLRendered = EventArg.HTMLRendered  & GetStatusDescription(Form.Grid.SelectedProperty.Value) & "&nbsp;"
                  EventArg.HTMLRendered = EventArg.HTMLRendered  &  "</TD>"
                  EventArg.HTMLRendered = PreProcess(EventArg.HTMLRendered,Array("CLASS", Form.Grid.CellClass))
                  Exit Function
              Case Else
                  Form_DisplayCell = Inherited("Form_DisplayCell()")    
          End Select
	End Select
    
END FUNCTION

PUBLIC FUNCTION GetStatusDescription(status)
  Select Case UCase(status)
    Case "O"
      GetStatusDescription = "Open"
    Case "H"
      GetStatusDescription = "Hard Closed"
    Case "S"  
      GetStatusDescription = "Soft Closed"  
    Case Else 
      GetStatusDescription = status     
  End Select
END FUNCTION 

PUBLIC FUNCTION Form_DisplayEndOfPage(EventArg) ' As Boolean

    Dim strEndOfPageHTMLCode, strTmp, strJavaScript
    
    strEndOfPageHTMLCode = strEndOfPageHTMLCode & "</TABLE><br>" & vbNewLine

    strTmp = strTmp & "<div class='clsButtonBox'>"       
    strTmp = strTmp & "<button  name='butAdjustSelectedTransaction' Class='clsButtonLarge' OnClick='mdm_UpdateSelectedIDsAndReDrawDialog(this); return false;'>[TEXT_ADJUST_SELECTED_TRANSACTION]</button><br/>"
    strTmp = strTmp & mam_GetDictionary("TEXT_YOU_MAY_MAKE") & "</div>"
    strTmp = strTmp & "<br/><br/><br/><br/><br/><br/><br/>"
      
    'We do not support bulk re-assignment in pre-bill case, so we added an explination in Kona - CR13822
    strTmp = strTmp & "<div class='clsButtonBox'>"
    strTmp = strTmp & "<button  name='butAdjustRebillTransaction' Class='clsButtonLarge' OnClick='mdm_UpdateSelectedIDsAndReDrawDialog(this); return false;'>Reassign Selected Transactions</button><br/>"
    strTmp = strTmp & mam_GetDictionary("TEXT_YOU_MAY_ONLY") & "</div>"    
    strTmp = strTmp & "<br/><br/><br/><br/><br/><br/><br/>"

    strTmp = strTmp & "<div style='text-align:center'>"
    strTmp = strTmp & "<button  name='Cancel' Class='clsButtonMedium' OnClick=""window.location.href='[BULKADJUSTMENT_FINDER_DIALOG]'; return false;"">[TEXT_CANCEL]</button>" & vbNewLine
    strTmp = strTmp & "</div><br/>"
    
    strEndOfPageHTMLCode  = strEndOfPageHTMLCode & strTmp & "</FORM><BODY></HTML>"
    Form_DisplayEndOfPageAddSelectButtons EventArg, strJavaScript, FALSE
    EventArg.HTMLRendered = EventArg.HTMLRendered & strEndOfPageHTMLCode

    Form_DisplayEndOfPage = TRUE
END FUNCTION

PUBLIC FUNCTION butAdjustSelectedTransaction_Click(EventArg)

    Dim strParam

    Form_ChangePage EventArg,0,0
        
    AdjustmentHelper.SelectedIDs = ProductView.Properties.Selector.GetAllSelectedItemFromRowSetAsCSVString(ProductView.Properties.Rowset,"FailureSessionId")
    
    If Len(AdjustmentHelper.SelectedIDs) Then
		strParam = strParam & "?PITemplate=" & TransactionUIFinder.SelectedPriceAbleItemTemplateID
        mdm_TerminateDialogAndExecuteDialog FrameWork.Dictionary.Item("BULKADJUSTMENT_EDIT_DIALOG").Value & strParam 
		butAdjustSelectedTransaction_Click  = TRUE   
    Else
		EventArg.Error.Number       = 1051
        EventArg.Error.Description  = mam_GetDictionary("MAM_ERROR_1051")
		butAdjustSelectedTransaction_Click  = FALSE	
    End If    
    
END FUNCTION

PUBLIC FUNCTION butAdjustRebillTransaction_Click(EventArg)

    Dim strParam

    Form_ChangePage EventArg,0,0
        
    AdjustmentHelper.SelectedIDs = ProductView.Properties.Selector.GetAllSelectedItemFromRowSetAsCSVString(ProductView.Properties.Rowset,"FailureSessionId")
    
     If Len(AdjustmentHelper.SelectedIDs) Then
		
		strParam = strParam & "?PITemplate=" & TransactionUIFinder.SelectedPriceAbleItemTemplateID
        mdm_TerminateDialogAndExecuteDialog FrameWork.Dictionary.Item("BULKREBILL_EDIT_DIALOG").Value & strParam 
     	butAdjustRebillTransaction_Click  = TRUE   
    Else
		EventArg.Error.Number       = 1051
        EventArg.Error.Description  = mam_GetDictionary("MAM_ERROR_1051")
		butAdjustRebillTransaction_Click  = FALSE	
     End If    

END FUNCTION

%>




