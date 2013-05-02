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
<!-- #INCLUDE FILE="../../default/Lib/CBatchError.asp" -->

<!-- #INCLUDE FILE="../../default/Lib/CAdjustmentHelper.asp" -->
<!-- #INCLUDE FILE="../../default/Lib/CTransactionUIFinder.asp" -->

<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" -->
<%

Form.Version                      = MDM_VERSION     ' Set the dialog version
Form.Page.MaxRow                  = CLng(mam_GetDictionary("PV_ROW_PER_PAGE"))
Form.Page.NoRecordUserMessage     = mam_GetDictionary("PRODUCT_VIEW_BROWSER_NO_RECORDS_FOUND")
Form.RouteTo                      = mam_GetDictionary("WELCOME_DIALOG")
Form.OnDisplayEndOfPageJavaScript = ""
PRIVATE AdjustmentHelper
Set AdjustmentHelper = New CAdjustmentHelper

mdm_PVBrowserMain ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: Form_Initialize
' PARAMETERS	:
' DESCRIPTION :
' RETURNS		  : Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean

    Form("SessionID")           = mdm_UIValue("SessionID")
    Form("IdPiTemplate")        = mdm_UIValue("IdPiTemplate")
    
    Form("Orphan")              = UCase(mdm_UIValue("Orphan"))              = "TRUE"
    Form("ShowBackButton")      = UCase(mdm_UIValue("ShowBackButton"))      = "TRUE"
    Form("UpdateFinderObjects") = UCase(mdm_UIValue("UpdateFinderObjects")) = "TRUE"
    
    FrameWork.Dictionary().Add "TITLE_Adjustment.Manage", IIF( Form("Orphan"),FrameWork.Dictionary().Item("TEXT_MANAGE_ORPHAN_ADJUSTMENTS").Value,FrameWork.Dictionary().Item("TEXT_MANAGE_ADJUSTMENTS").Value)

  	ProductView.Clear  ' Set all the property of the service to empty or to the default value
   	ProductView.Properties.ClearSelection
    ProductView.Properties.Flags = eMSIX_PROPERTIES_FLAG_PRODUCTVIEW
    
    If Form("Orphan") Then
        ProductView.Properties.Selector.ColumnID        = "id_adj_trx" ' Specify the column id to use as the select key
        Form.HelpFile                                   = "Orphan.Manage.hlp.htm" ' Set the help file name    
    Else
        ProductView.Properties.Selector.ColumnID        = "id_sess" ' Specify the column id to use as the select key
        Form.HelpFile                                   = Empty
    End If
    ProductView.Properties.Selector.Clear
    Form.ShowExportIcon   = TRUE ' Export
    Form_Initialize       = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  Form_LoadProductView
' PARAMETERS:  EventArg
' DESCRIPTION: 
' RETURNS:  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_LoadProductView(EventArg) ' As Boolean

  Dim i : i = 1
  
  Dim objMamBill

  Form_LoadProductView = FALSE
  
  ' We Check if SessionID is empty and Support ORPHAN mode
  Set ProductView.Properties.RowSet = AdjustmentHelper.GetManagableAdjustmentsAsRowset(Form("SessionID"),Form("IdPiTemplate")) 

  ' too many properies in turndown to localize all of them
	ProductView.Properties.CancelLocalization

  If IsValidObject(ProductView.Properties.RowSet) Then

      ProductView.Properties.ClearSelection
      
      If Form("Orphan") Then
  
          ProductView.Properties("id_adj_trx").Selected                     = i : i=i+1
          ProductView.Properties("dt_crt").Selected                         = i : i=i+1
          ProductView.Properties("tx_desc").Selected                        = i : i=i+1
          ProductView.Properties("c_status").Selected                       = i : i=i+1
          ProductView.Properties("id_acc_payer").Selected                   = i : i=i+1
          ProductView.Properties("ReasonCodeDisplayName").Selected          = i : i=i+1
          ProductView.Properties("AdjustmentTemplateDisplayName").Selected  = i : i=i+1
          ProductView.Properties("AdjustmentAmount").Selected               = i : i=i+1      
          
          ProductView.Properties("AdjustmentAmount").Format                 = mam_GetDictionary("AMOUNT_FORMAT")
          ProductView.Properties("dt_crt").Format                           = mam_GetDictionary("DATE_TIME_FORMAT")
          
          
          ProductView.Properties("id_adj_trx").Caption                      = FrameWork.Dictionary.Item("TEXT_SESSION_ID").Value
          ProductView.Properties("dt_crt").Caption                          = FrameWork.Dictionary.Item("TEXT_TIMESTAMP").Value
          ProductView.Properties("tx_desc").Caption                         = FrameWork.Dictionary.Item("TEXT_DESCRIPTION").Value
          ProductView.Properties("c_status").Caption                        = FrameWork.Dictionary.Item("TEXT_STATUS").Value
          ProductView.Properties("ReasonCodeDisplayName").Caption           = FrameWork.Dictionary.Item("TEXT_REASON_CODE").Value
          ProductView.Properties("AdjustmentTemplateDisplayName").Caption   = FrameWork.Dictionary.Item("TEXT_ADJUSTMENT").Value
          ProductView.Properties("AdjustmentAmount").Caption                = FrameWork.Dictionary.Item("TEXT_AMOUNT").Value          
          ProductView.Properties("id_acc_payer").Caption                    = FrameWork.Dictionary.Item("TEXT_PAYER").Value
          
      Else      
          ProductView.Properties("AdjustmentCreationDate").Selected           = i : i=i+1
          ProductView.Properties("id_sess").Selected                          = i : i=i+1
          ProductView.Properties("tx_desc").Selected                          = i : i=i+1
          'ProductView.Properties("tx_default_desc").Selected                  = i : i=i+1
          ProductView.Properties("AdjustmentStatus").Selected                 = i : i=i+1
          ProductView.Properties("UserNamePayer").Selected                    = i : i=i+1
          ProductView.Properties("UserNamePayee").Selected                    = i : i=i+1
          ProductView.Properties("PITemplateDisplayName").Selected            = i : i=i+1          
          ProductView.Properties("Amount").Selected                           = i : i=i+1          
          ProductView.Properties("PendingPrebillAdjAmt").Selected   = i : i=i+1          
          ProductView.Properties("PendingPostbillAdjAmt").Selected  = i : i=i+1          
          ProductView.Properties("PrebillAdjAmt").Selected          = i : i=i+1
          ProductView.Properties("PostbillAdjAmt").Selected         = i : i=i+1      
          
          ProductView.Properties("Amount").Format                           = mam_GetDictionary("AMOUNT_FORMAT")
          ProductView.Properties("PrebillAdjAmt").Format          = mam_GetDictionary("AMOUNT_FORMAT")
          ProductView.Properties("PostbillAdjAmt").Format         = mam_GetDictionary("AMOUNT_FORMAT")
          ProductView.Properties("AdjustmentCreationDate").Format           = mam_GetDictionary("DATE_TIME_FORMAT")                
          ProductView.Properties("PendingPrebillAdjAmt").Format   = mam_GetDictionary("AMOUNT_FORMAT")
          ProductView.Properties("PendingPostbillAdjAmt").Format  = mam_GetDictionary("AMOUNT_FORMAT")
          
          ProductView.Properties("id_sess").Caption                         = FrameWork.Dictionary.Item("TEXT_SESSION_ID").Value
          ProductView.Properties("tx_desc").Caption                         = FrameWork.Dictionary.Item("TEXT_DESCRIPTION").Value
          ProductView.Properties("tx_default_desc").Caption                 = FrameWork.Dictionary.Item("TEXT_ADJUSTMENT_DEFAULT_DESCRIPTION").Value          
          ProductView.Properties("AdjustmentCreationDate").Caption          = FrameWork.Dictionary.Item("TEXT_TIMESTAMP").Value
          ProductView.Properties("AdjustmentStatus").Caption                = FrameWork.Dictionary.Item("TEXT_STATUS").Value
          ProductView.Properties("UserNamePayer").Caption                   = FrameWork.Dictionary.Item("ACCOUNT_FINDER_ACCOUNT_TYPE_FOR_SEARCH(1)").Value
          ProductView.Properties("UserNamePayee").Caption                   = FrameWork.Dictionary.Item("ACCOUNT_FINDER_ACCOUNT_TYPE_FOR_SEARCH(2)").Value
          ProductView.Properties("PITemplateDisplayName").Caption           = FrameWork.Dictionary.Item("TEXT_KEYTERM_PRICEABLE_ITEM").Value
          ProductView.Properties("Amount").Caption                          = FrameWork.Dictionary.Item("TEXT_AMOUNT").Value
          ProductView.Properties("PrebillAdjAmt").Caption         = FrameWork.Dictionary.Item("TEXT_PREBILL_ADJUSTMENT_AMOUNT").Value
          ProductView.Properties("PostbillAdjAmt").Caption        = FrameWork.Dictionary.Item("TEXT_POSTBILL_ADJUSTMENT_AMOUNT").Value
          ProductView.Properties("PendingPrebillAdjAmt").Caption  = FrameWork.Dictionary.Item("TEXT_PENDING_PREBILL_ADJUSTMENT_AMOUNT").Value
          ProductView.Properties("PendingPostbillAdjAmt").Caption = FrameWork.Dictionary.Item("TEXT_PENDING_POSTBILL_ADJUSTMENT_AMOUNT").Value                    
      End If
      
'      ProductView.Properties.ClearSelection
 '    ProductView.Properties.SelectAll
      
      ProductView.Properties("id_Parent_Sess").Sorted             = MTSORT_ORDER_DECENDING  ' Sort             
      
      Service.Properties.TimeZoneId                               = MAM().CSR("TimeZoneId") ' Set the TimeZone, so the dates will be printed for the CSR time zone
      Service.Properties.DayLightSaving                           = mam_GetDictionary("DAY_LIGHT_SAVING")
      
      mdm_SetMultiColumnFilteringMode TRUE
      
      ' REQUIRED because we must generate the property type info in javascript. When the user change the property which he
      ' wants to use to do a filter we use the type of the property (JAVASCRIPT code) to show 2 textbox if it is a date
      ' else one.
      ProductView.LoadJavaScriptCode
        
      Form_LoadProductView = TRUE 
  End If
END FUNCTION

PRIVATE FUNCTION Form_DisplayCell(EventArg) ' As Boolean

    DIM PreProcessor, HTML_LINK_EDIT, lngID, strValue
    
    Select Case Form.Grid.Col
    
        Case 1
      
            Set PreProcessor = mdm_CreateObject(CPreProcessor)
        
            HTML_LINK_EDIT = HTML_LINK_EDIT & "<td class='[CLASS]'>"
            HTML_LINK_EDIT = HTML_LINK_EDIT & "<INPUT Type='CheckBox' [CHECKBOX_SELECTED] Name='" & MDM_PVB_CHECKBOX_PREFIX & "[SESSION_ID]'>"
            HTML_LINK_EDIT = HTML_LINK_EDIT & "</td>"
            
            PreProcessor.Clear
            
            If Form("Orphan") Then                
                lngID = ProductView.Properties.Rowset.Value("id_adj_trx")            
            Else
                lngID = ProductView.Properties.Rowset.Value("id_sess")                            
            End If
            PreProcessor.Add "SESSION_ID"         , lngID
            PreProcessor.Add "CHECKBOX_SELECTED"  , IIF(ProductView.Properties.Selector.IsItemSelected(lngID),"CHECKED","") ' Select All mode
            PreProcessor.Add "CLASS"              , Form.Grid.CellClass
            
            EventArg.HTMLRendered           = PreProcessor.Process(HTML_LINK_EDIT)
            Form_DisplayCell                = TRUE
            Exit Function
            
        Case 2
                    
        Case Else                
        
              If IsValidObject(Form.Grid.SelectedProperty) Then ' Skip column 1 and 2
              
                  Select Case UCase(Form.Grid.SelectedProperty.Name)
                      
                      Case "ID_ACC_PAYER","ID_PAYEE"
                      
                          EventArg.HTMLRendered = "<TD Class='[CLASS]'>" & mam_GetFieldIDFromAccountID(Form.Grid.SelectedProperty.Value) & "</TD>"
                          EventArg.HTMLRendered = PreProcess(EventArg.HTMLRendered,Array("CLASS", Form.Grid.CellClass))
                          Exit Function
                      
                      Case "ADJUSTMENTSTATUS"
                          EventArg.HTMLRendered = EventArg.HTMLRendered  & "<TD NoWrap Class='[CLASS]'>"

  												EventArg.HTMLRendered = EventArg.HTMLRendered  & Form.Grid.SelectedProperty.Value & "-" & AdjustmentHelper.GetAdjustmentStatusDescription(Form.Grid.SelectedProperty.Value) & "&nbsp;"
                          
                          'EventArg.HTMLRendered = EventArg.HTMLRendered  & IIF(ProductView.Properties("IsPrebillAdjusted").Value="Y",FrameWork.Dictionary.Item("TEXT_PREBILL") & "&nbsp;","") 
  												'EventArg.HTMLRendered = EventArg.HTMLRendered  & IIF(ProductView.Properties("IsPostbillAdjusted").Value="Y",FrameWork.Dictionary.Item("TEXT_POSTBILL") & "&nbsp;","")   												
                          
                          EventArg.HTMLRendered = EventArg.HTMLRendered  &  "</TD>"
                          
                          EventArg.HTMLRendered = PreProcess(EventArg.HTMLRendered,Array("CLASS", Form.Grid.CellClass))
                          Exit Function
                  End Select
            End If
    End Select
    ' Default BeHavior
    Form_DisplayCell =  Inherited("Form_DisplayCell()") ' Call the default implementation
END FUNCTION

PUBLIC FUNCTION Form_DisplayEndOfPage(EventArg) ' As Boolean

    Dim strEndOfPageHTMLCode, strTmp
    
    Form_DisplayEndOfPageAddSelectButtons EventArg, "", FALSE ' No Javascript and do not close the tag form
    
    strTmp = "<BR><button  name='butApprove' Class='clsButtonBlueMedium' onclick='mdm_UpdateSelectedIDsAndReDrawDialog(this);'>" & FrameWork.Dictionary.Item("TEXT_APPROVE") & "</button>" & vbNewLine
    strEndOfPageHTMLCode = strEndOfPageHTMLCode & strTmp
    
    strTmp = "<button  name='butDelete' Class='clsButtonBlueMedium'  onclick='mdm_UpdateSelectedIDsAndReDrawDialog(this);'>" & FrameWork.Dictionary.Item("TEXT_DELETE") & "</button>" & vbNewLine
    strEndOfPageHTMLCode  = strEndOfPageHTMLCode & strTmp
    
    If Form("ShowBackButton") Then 
        strTmp = "<BR><BR><CENTER><button  name='butBack' Class='clsButtonMedium' onclick='document.location.href=""[ADJUSTMENT_PVB_DIALOG]"";'>" & FrameWork.Dictionary.Item("TEXT_BACK") & "</button></CENTER>" & vbNewLine
        strEndOfPageHTMLCode  = strEndOfPageHTMLCode & strTmp
    End If

    EventArg.HTMLRendered = EventArg.HTMLRendered & FrameWork.Dictionary.PreProcess(strEndOfPageHTMLCode & "</FORM></BODY>")
    
    Inherited "OnDisplayEndOfPageJavaScript(EventArg)"
    
    Form_DisplayEndOfPage = TRUE
END FUNCTION

PRIVATE FUNCTION PerformActionOnSelectedSession(EventArg,strAction)

    Dim booNoActionTaken, objIDs
    
    PerformActionOnSelectedSession = FALSE

    Form_ChangePage EventArg,0,0 ' We need to call the event our self here so we update the ProductView.Properties.Selector
  
    Set objIDs = ProductView.Properties.Selector.GetAllSelectedItemFromRowSet(ProductView.Properties.Rowset,"id_sess")

    If objIDs.Count=0 Then 
    
        EventArg.Error.Description = FrameWork.Dictionary.Item("MAM_ERROR_1047").Value
        EventArg.Error.Number      = 1047
        Exit Function
    End If
    
    Select Case UCase(strAction)
      
        Case "DELETE"  :

            PerformActionOnSelectedSession = AdjustmentHelper.DeleteAdjustment(EventArg,objIDs)
            If AdjustmentHelper.IsThereDeletedAdjustmentErrors() Then
                
                Form.OnDisplayEndOfPageJavaScript = "window.open('[BATCH_ERROR_LIST_DIALOG]&WarningMode=TRUE&Close=TRUE&FilterOff=TRUE&PopUpWindowMode=TRUE','','height=300,width=570,resizable=yes,scrollbars=yes,status=yes');"
                Form.OnDisplayEndOfPageJavaScript = FrameWork.Dictionary.PreProcess(Form.OnDisplayEndOfPageJavaScript )
            End If

        Case "APPROVE" : 

            PerformActionOnSelectedSession = AdjustmentHelper.ApproveAdjustment(EventArg,objIDs)
            If AdjustmentHelper.IsThereApprovedAdjustmentErrors() Then
                
                Form.OnDisplayEndOfPageJavaScript = "window.open('[BATCH_ERROR_LIST_DIALOG]&WarningMode=TRUE&Close=TRUE&FilterOff=TRUE&PopUpWindowMode=TRUE','','height=300,width=570,resizable=yes,scrollbars=yes,status=yes');"
                Form.OnDisplayEndOfPageJavaScript = FrameWork.Dictionary.PreProcess(Form.OnDisplayEndOfPageJavaScript)
            End If
    End Select
    ProductView.Properties.Selector.Clear ' We need to clear the selection else the selection remain active and
                                          ' The just approved adjustment could be deleted... 
END FUNCTION

PRIVATE FUNCTION butApprove_Click(EventArg)

    butApprove_Click = FALSE
    
    If PerformActionOnSelectedSession(EventArg,"APPROVE") Then
    
        UpDateTransactionFinderInfoIfNeeded
        butApprove_Click = TRUE
    End If
END FUNCTION

PRIVATE FUNCTION butDelete_Click(EventArg)
    
    butDelete_Click = FALSE
    
    If PerformActionOnSelectedSession(EventArg,"DELETE") Then 
    
        butDelete_Click = TRUE
        UpDateTransactionFinderInfoIfNeeded()  
    End If
END FUNCTION

PRIVATE FUNCTION UpDateTransactionFinderInfoIfNeeded()

    If Form("UpdateFinderObjects") Then
        TransactionUIFinder.UpdateFoundRowSet
    End If
    UpDateTransactionFinderInfoIfNeeded = TRUE
END FUNCTION



%>
