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
<!-- #INCLUDE FILE="../../default/Lib/Adjustments.OverRideAble.Customization.asp" -->
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" -->
<%

Form.Version                      = MDM_VERSION     ' Set the dialog version
Form.Page.MaxRow                  = CLng(mam_GetDictionary("PV_ROW_PER_PAGE"))
Form.Page.NoRecordUserMessage     = mam_GetDictionary("PRODUCT_VIEW_BROWSER_NO_RECORDS_FOUND")
Form.RouteTo                      = mam_GetDictionary("ADJUSTMENT_PVB_DIALOG")


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
    ProductView.Properties.Flags = eMSIX_PROPERTIES_FLAG_PRODUCTVIEW
    
    ProductView.Properties.Selector.ColumnID = "SessionID" ' Specify the column id to use as the select key
    
    Form("SessionID")           = mdm_UIValue("SessionID")
    Form("ChildType")           = mdm_UIValue("ChildType")
    Form("ChildViewID")         = mdm_UIValue("ViewID")
    Form("PITemplate")          = mdm_UIValue("PITemplate")
    Form("PITemplateChildren")  = mdm_UIValue("PITemplateChildren")    
    Form_Initialize             = TRUE
    
    ProductView.Properties.Selector.Clear
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  Form_LoadProductView
' PARAMETERS:  EventArg
' DESCRIPTION: 
' RETURNS:  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_LoadProductView(EventArg) ' As Boolean
  
  Form_LoadProductView = FALSE
    
  RefreshChildrenGrid
    
  mdm_SetMultiColumnFilteringMode TRUE
    
  ProductView.LoadJavaScriptCode ' REQUIRED because we must generate the property type info in javascript. When the user change the property which he wants to use to do a filter we use the type of the property (JAVASCRIPT code) to show 2 textbox if it is a date else one.
    
  Form_LoadProductView = TRUE   
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    :
' PARAMETERS		  :
' DESCRIPTION 		: 
' RETURNS		      : 
PRIVATE FUNCTION RefreshChildrenGrid()

    Dim i
    RefreshChildrenGrid = TRUE

    Set ProductView.Properties.RowSet = AdjustmentHelper.GetTransactionChildrenRowSet(Form("ChildViewID"),Form("SessionID"))
    
    If IsValidObject(ProductView.Properties.RowSet) Then
        
        ProductView.Properties.SelectAll
     
        Dim varRetVal
        If Not mdm_CallFunctionIfExist(Form("ChildType") & "_Adjustment_SelectColumns(ProductView)" , varRetVal) Then
          AdjustmentHelper.ChildrenPVBColumnSelection
        End If
     
    End If
    
    Set Session(SESSION_ADJ_CHILDREN_ROWSET) = ProductView.Properties.RowSet
    
    RefreshChildrenGrid = TRUE    
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
                  Else
                      strTemplateCheckBox = strTemplateCheckBox & "<INPUT Type='CheckBox' [CHECKBOX_SELECTED] Name='" & MDM_PVB_CHECKBOX_PREFIX & "[CHILDID]'>"
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
                  Else
                      strTemplateCheckBox = strTemplateCheckBox & "<INPUT Type='CheckBox' [CHECKBOX_SELECTED] Name='" & MDM_PVB_CHECKBOX_PREFIX & "[CHILDID]'>"
                  End If    
              End If              
              strTemplateCheckBox   = strTemplateCheckBox & "</td>"        
        
              objPreProcessor.Add "TEXT_DELETE"             , mam_GetDictionary("TEXT_DELETE")
              objPreProcessor.Add "CHECKBOX_SELECTED"       , IIF(ProductView.Properties.Selector.IsItemSelected(ProductView.Properties("SessionID").Value),"CHECKED","") ' Select All mode
              objPreProcessor.Add "CHILDID"                 , ProductView.Properties("SessionID").Value
              objPreProcessor.Add "CLASS"                   , Form.Grid.CellClass
              objPreProcessor.Add "PREBILLADJUSTED_STATUS"  , IIF(ProductView.Properties.Rowset.Value("IsPrebillAdjusted")="Y","PreBill Adjusted","")
              objPreProcessor.Add "POSTBILLADJUSTED_STATUS" , IIF(ProductView.Properties.Rowset.Value("IsPostbillAdjusted")="Y","PostBill Adjusted","")

              EventArg.HTMLRendered = objPreProcessor.Process(strTemplateCheckBox)
              Form_DisplayCell      = TRUE
        Case Else
            Form_DisplayCell = Inherited("Form_DisplayCell(EventArg)")
    End Select
END FUNCTION



PUBLIC FUNCTION Form_DisplayEndOfPage(EventArg) ' As Boolean

    Dim strEndOfPageHTMLCode, strTmp, strJavaScript
    
    strEndOfPageHTMLCode = strEndOfPageHTMLCode & "</TABLE><br>" & vbNewLine
    
    Form_DisplayEndOfPageAddSelectButtons EventArg, strJavaScript, FALSE
    
    strTmp = "<br><button  name='butAdjustSelectedTransaction' Class='clsButtonLarge' OnClick='mdm_UpdateSelectedIDsAndReDrawDialog(this); return false;'>[TEXT_ADJUST_SELECTED_TRANSACTION]</button>" & vbNewLine
    strEndOfPageHTMLCode  = strEndOfPageHTMLCode & strTmp

'    If FrameWork.CheckCoarseCapability("Manage Adjustments") Then
 '   
  '      strTmp = "<button  name='butDeleteAdjustment' Class='clsButtonLarge' OnClick='document.location.href=""[ADJUSTMENT_DELETE_CHILDREN_ADJUSTMENT_DIALOG]"";'>[TEXT_DELETE_ADJUSTED_TRANSACTION]</button>" & vbNewLine
 '       strEndOfPageHTMLCode  = strEndOfPageHTMLCode & strTmp
  '  End If
    
    strTmp = "<button  name=""Cancel"" Class=""clsButtonLarge"" onclick=""mdm_RefreshDialog(this)"" type=""button"">[TEXT_CANCEL]</button>" & vbNewLine
    strEndOfPageHTMLCode  = strEndOfPageHTMLCode & strTmp
    
    strEndOfPageHTMLCode  = strEndOfPageHTMLCode & "</FORM>"
    EventArg.HTMLRendered = EventArg.HTMLRendered & FrameWork.Dictionary.PreProcess(strEndOfPageHTMLCode)

    Form_DisplayEndOfPage = TRUE
END FUNCTION

PRIVATE FUNCTION Cancel_Click(EventArg) ' As Boolean

  Form.Modal   = FALSE
  Cancel_Click = TRUE
END FUNCTION

PUBLIC FUNCTION butAdjustSelectedTransaction_Click(EventArg)

    Dim strParam

    Form_ChangePage EventArg,0,0
        
    AdjustmentHelper.SelectedIDs = ProductView.Properties.Selector.GetAllSelectedItemFromRowSetAsCSVString(ProductView.Properties.Rowset,"FailureSessionId")
    
    If Len(AdjustmentHelper.SelectedIDs) Then
    
        strParam = strParam & "?SessionID=" & Form("SessionID") & "&"
        strParam = strParam & "ChildType=" & Form("ChildType") & "&"
        strParam = strParam & "ViewID=" & Form("ChildViewID") & "&"
        strParam = strParam & "PITemplateChildren=" & Form("PITemplateChildren") & "&"        
        mdm_TerminateDialogAndExecuteDialog FrameWork.Dictionary.Item("ADJUSTMENT_EDIT_CHILDREN_DIALOG").Value & strParam 
    End If    
    butAdjustSelectedTransaction_Click  = TRUE
END FUNCTION

%>


