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
'
' Fields described below can be used 
'
' 1.	When customizing information displayed on adjustment screens in MAM
' 2.	As non-required properties on Adjustment formula
'
' Field Name	Description
' CompoundPrebillAdjAmt	
'     Parent and children PreBill adjustments for a compound transaction
'
' AtomicPrebillAdjAmt	
'     Parent PreBill adjustments for a compound transaction. 
'     For an atomic transactionCompoundPrebillAdjAmt always equals AtomicPrebillAdjAmt
'
' CompoundPrebillAdjedAmt	
'     Usage Amount + CompoundPrebillAdjAmt
'
' AtomicPrebillAdjedAmt	
'     Charge amount + parent PreBill adjustments for a compound transaction. 
'     For an atomic transactionCompoundPrebillAdjedAmt always equals AtomicPrebillAdjedAmt
'
' CompoundPostbillAdjAmt	
'     Parent and children PostBill adjustments for a compound transaction
'
' AtomicPostbillAdjAmt	
'     Parent PostBill adjustments for a compound transaction. 
'     For an atomic transactionCompoundPostbillAdjAmt always equals AtomicPostbillAdjAmt
'
' CompoundPostbillAdjedAmt	
'     Charge Amount + CompoundPrebillAdjAmt + CompoundPostbillAdjAmt
'
' AtomicPostbillAdjedAmt	
'     Charge amount + parent PreBill adjustments for a compound transaction   + parent PostBill adjustments for a compound transaction. 
'     For an atomic transactionAtomicPostbillAdjustedAmount always equals CompoundPostbillAdjedAmt
'
' PrebillAdjustmentID	
'     Return Adjustment Transaction IDs for PreBill adjustment (or -1 if none):
'
' PostbillAdjustmentID	
'       Return Adjustment Transaction IDs for PostBill adjustment (or -1 if none):
'
' PrebillAdjustmentTemplateID	
'     Return Adjustment Template IDs for PreBill adjustment (or -1 if none):
'
' PostbillAdjustmentTemplateID	
'       Return Adjustment Template IDs for PostBill adjustment (or -1 if none):
'
' PrebillAdjustmentInstanceID	
'     Return Adjustment Instance IDs for PreBill adjustment (or -1 if none):
'
' PostbillAdjustmentInstanceID	
'     Return Adjustment Instance IDs for PostBill adjustment (or -1 if none):
'
' PrebillAdjustmentReasonCodeID	
'     Return Adjustment Reason Code IDs for PreBill adjustment (or -1 if none):
'
' PostbillAdjustmentReasonCodeID	
'     Return Adjustment Reason Code IDs for PostBill adjustment (or -1 if none):
'
' PrebillAdjustmentDescription	
'       Return Adjustment Description IDs for PostBill adjustment (or empty string if none):
'
' PostbillAdjustmentDescription	
'     Return Adjustment Description IDs for PostBill adjustment (or empty string if none):
'
' AdjustmentStatus	
'     Return Adjustment Status as following: If transaction interval is either open or soft closed, 
'     return PreBill adjustment status or 'NA' if none;If transaction interval is hard closed, return post bill adjustment status or 'NA' if none
'
' IsAdjusted	
'     Transactions are not considered to be adjusted if adjustment status is not 'A'Return 'Y' if adjustment status is 'A' or 'N' otherwise
'
' IsPrebillAdjusted	
'     Return 'Y' if transaction was PreBill Adjusted and adjustment status is 'A' (Approved) or 'N' otherwise
'
' IsPostbillAdjusted	
'     Return 'Y' if transaction was Postbill Adjusted and adjustment status is 'A' (Approved) or 'N' otherwise
'
' IsPreBill	
'     Return 'Y' if usage transaction belongs to usage interval that is in Open state
'
' CanAdjust	
'     Return 'N' if one of the 3 below conditions for the usage transactions are met:1. In soft closed interval2. 
'     If transaction is PreBill and it was already PreBill adjusted3.	If transaction is Post bill and it was already PostBill adjustedOtherwise return 'Y'
'
' CanRebill	
'   Return 'N' if one of the 4 below conditions for the usage transactions are met:1. If they are child transactions2. 
'   In soft closed interval3. If transaction is PreBill and it (or it's children) have already been adjusted (need to delete adjustments first)4. 
'   If transaction is PostBill and it (or it's children) have already been adjusted (need to delete adjustments first)
'
' CanManageAdjustments
'   Return 'N' if one of the 3 below conditions for the usage transactions are met:1. 
'   If transaction interval is Open AND no PreBill Adjustments in 'P' or 'A' state were entered against this transaction2. 
'   Transaction has been PreBill adjusted but transaction interval is already closed3. 
'   If transaction interval is hard Closed AND If no PostBill Adjustments in 'P' or 'A' state were entered against this transaction4.	
'   Transaction has been PostBill adjusted but payer's interval is already closed5. If the transaction usage interval is in soft closed state
'

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
  
  ' Check to see if items have been filtered and inform the user
  If ProductView.Properties.RowSet.RecordCount >= 1000 Then
    mdm_GetDictionary().Add "SHOW_ROWSET_FILTERED_MESSAGE", TRUE
  ELSE
    mdm_GetDictionary().Add "SHOW_ROWSET_FILTERED_MESSAGE", FALSE      
  End If
      
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

PRIVATE FUNCTION GenerateHTMLIconManage(ByRef HTML_LINK_EDIT)

        If FrameWork.CheckCoarseCapability("Manage Adjustments") Then
            HTML_LINK_EDIT = HTML_LINK_EDIT & "<a target=""MainContentIframe"" href=""/MetraNet/Adjustments/ManageAdjustments.aspx?SessionId=[ID]""><img border=0 Name='ViewParentAdjustment[ID]' Style='cursor:hand;' Alt='[TEXT_MANAGE_ADJUSTMENT]' Src='[IMAGE_PATH]/logs.gif' Border=0></a>&nbsp;" & vbNewLine
        Else
            HTML_LINK_EDIT = HTML_LINK_EDIT & "<IMG Alt='[TEXT_YOU_DO_NOT_HAVE_ADJUSTMENT_MANAGMENT_CAPABILITY]' Src='[IMAGE_PATH]/log.gif' Border=0>&nbsp;" & vbNewLine
        End If
END FUNCTION											 

PRIVATE FUNCTION GenerateHTMLIconManageGrayed(ByRef HTML_LINK_EDIT)

		HTML_LINK_EDIT = HTML_LINK_EDIT & "<IMG Name='AdjustParent[ID]' Alt='[TEXT_CANNOT_ADJUST_MANAGE_ADJUSTMENT_BECAUSE_ALREADY_BUILD]' Src='[IMAGE_PATH]/LogGrayed.gif' Border=0>"
END FUNCTION

PRIVATE FUNCTION GenerateHTMLIconAdjust(ByRef HTML_LINK_EDIT)

		HTML_LINK_EDIT = HTML_LINK_EDIT & "<IMG Name='AdjustParent[ID]' Style='cursor:hand;' Alt='[TEXT_ADJUST]' OnClick='document.location.href=""[ADJUSTMENT_EDIT_PARENT_DIALOG]?SessionID=[ID]&PITemplate=[PITEMPLATE]"";' Src='[IMAGE_PATH]/Adjust.gif' Border=0>"
END FUNCTION

PRIVATE FUNCTION GenerateHTMLIconAdjustGrayed(ByRef HTML_LINK_EDIT)

		HTML_LINK_EDIT = HTML_LINK_EDIT & "<IMG Name='AdjustParent[ID]' Alt='[TEXT_CANNOT_ADJUST_MANAGE_ADJUSTMENT_IN_SOFT_CLOSE]' REMOVEDOnClick='document.location.href=""[ADJUSTMENT_EDIT_PARENT_DIALOG]?SessionID=[ID]&PITemplate=[PITEMPLATE]"";' Src='[IMAGE_PATH]/AdjustGrayed.gif' Border=0>"
END FUNCTION

PRIVATE FUNCTION GenerateAdjustKidsGrayed(ByRef HTML_LINK_EDIT)

		HTML_LINK_EDIT = HTML_LINK_EDIT & "<IMG Name='AdjustParent[ID]' Alt='[TEXT_CANNOT_ADJUST_MANAGE_ADJUSTMENT_IN_SOFT_CLOSE]' REMOVEDOnClick='document.location.href=""[ADJUSTMENT_EDIT_PARENT_DIALOG]?SessionID=[ID]&PITemplate=[PITEMPLATE]"";' Src='[IMAGE_PATH]/arrowBlueRightAdjustGrayed.gif' Border=0>"
END FUNCTION


PRIVATE FUNCTION GenerateHTMLIconReBill(ByRef HTML_LINK_EDIT)

  HTML_LINK_EDIT = HTML_LINK_EDIT & "<IMG Name='ReBill[ID]' Style='cursor:hand;' Alt='[TEXT_REBILL]' OnClick='document.location.href=""[REBILL_EDIT_DIALOG]?SessionID=[ID]&PITemplate=[PITEMPLATE]&PreBill=[PREBILL]"";' Src='[IMAGE_PATH]/ReBill.gif' Border=0>&nbsp;[CRLF]"
END FUNCTION

PRIVATE FUNCTION GenerateHTMLIconReBillGrayed(ByRef HTML_LINK_EDIT, strToolTip)

    HTML_LINK_EDIT = HTML_LINK_EDIT & "<IMG Name='ReBill[ID]' Alt='[" & strToolTip & "]' Src='[IMAGE_PATH]/ReBillGrayed.gif' Border=0>[CRLF]"
END FUNCTION

PRIVATE FUNCTION GetAsBool(strName)

    GetAsBool = CBool(ProductView.Properties.Rowset.Value(strName)="Y")
END FUNCTION  



PRIVATE FUNCTION Form_DisplayCell(EventArg) ' As Boolean

    Dim HTML_LINK_EDIT,  lngChildAdjustmentCount, strTMP
    
    Select Case Form.Grid.Col
    
        Case 1
            GenerateHTML EventArg, HTML_LINK_EDIT
     
            
            PreProcessor.Clear
            
            PreProcessor.Add "CRLF"                       , vbNewLine
            PreProcessor.Add "IMAGE_PATH"                 , mam_GetImagesPath()
            PreProcessor.Add "PREBILL"                    , ProductView.Properties.Rowset.Value("IsPrebillTransaction")="Y"
            PreProcessor.Add "ID"                         , ProductView.Properties.Rowset.Value("SessionID")
            PreProcessor.Add "PITEMPLATE"                 , ProductView.Properties.Rowset.Value("PITemplate")            
            PreProcessor.Add "CLASS"                      , Form.Grid.CellClass
            PreProcessor.Add "IMAGE_EDIT"                 , Application("APP_HTTP_PATH") & "/default/localized/en-us/images/edit.gif"
            PreProcessor.Add "PREBILLADJUSTED_STATUS"     , IIF(ProductView.Properties.Rowset.Value("IsPrebillAdjusted")="Y" ,mam_GetDictionary("TEXT_PREBILL_ADJUSTED") ,"")
            PreProcessor.Add "POSTBILLADJUSTED_STATUS"    , IIF(ProductView.Properties.Rowset.Value("IsPostbillAdjusted")="Y",mam_GetDictionary("TEXT_POSTBILL_ADJUSTED"),"")
            
            strTMP = IIF(lngChildAdjustmentCount=1,"[TEXT_CHILD_ADJUSTED]","[TEXT_CHILDREN_ADJUSTED]")
            PreProcessor.Add "HOW_MANY_CHILDREN"  , lngChildAdjustmentCount & strTMP & "[CRLF][TEXT_MANAGE_ADJUSTMENT]"
            
            EventArg.HTMLRendered = PreProcessor.Process(HTML_LINK_EDIT)
            EventArg.HTMLRendered = FrameWork.Dictionary.PreProcess(EventArg.HTMLRendered)
            Form_DisplayCell      = TRUE

        Case 2
        
            Dim booIsCompound
            booIsCompound = Not CBool(("" & ProductView.Properties.Rowset.Value("SessionType"))="Atomic")
            If  booIsCompound Then                
                Form_DisplayCell      =  Inherited("Form_DisplayCell()") ' Call the default implementation
            Else
                EventArg.HTMLRendered = "<td class=" & Form.Grid.CellClass & "></td>"                
            End If
         Case 9
            'code fix for core-6775 adjustment amount shows values in timestamp 
             '****Starts here******
            'code fix for core-6775 oracle and sql DB Values Form.Grid.SelectedProperty.Name="COMPOUNDPREBILLADJAMT" ||CompoundPrebillAdjAmt
            If Form.Grid.SelectedProperty.Name="COMPOUNDPREBILLADJAMT" Then
            Form_DisplayCell =  Inherited("Form_DisplayCell()") ' Call the default implementation 
            
            PreProcessor.Clear
            PreProcessor.Add "ID"                         , ProductView.Properties.Rowset.Value("SessionID")            
            PreProcessor.Add "COLUMN_NAME"                , Form.Grid.SelectedProperty.Name
            PreProcessor.Add "VALUE"                      , "" & Form.Grid.SelectedProperty.Value
            EventArg.HTMLRendered = EventArg.HTMLRendered  & vbNewLine & PreProcessor.Process("<input type=hidden name='_ST_[COLUMN_NAME][ID]' Value='[VALUE]'>") & vbNewLine
            
            
            Else
            '****Ends here******
            Form_DisplayCell =  Inherited("Form_DisplayCell()") ' Call the default implementation 
            
            PreProcessor.Clear
            PreProcessor.Add "ID"                         , ProductView.Properties.Rowset.Value("SessionID")            
            PreProcessor.Add "COLUMN_NAME"                , Form.Grid.SelectedProperty.Name
            PreProcessor.Add "VALUE"                      , "" & Form.Grid.SelectedProperty.Value
            EventArg.HTMLRendered = "<td class='" & Form.Grid.CellClass & "'>"  & Framework.Format(ProductView.Properties.RowSet.Value("timestamp"),FrameWork.Dictionary.Item("DATE_TIME_FORMAT").Value) & "</td>"  & vbNewLine & PreProcessor.Process("<input type=hidden name='_ST_[COLUMN_NAME][ID]' Value='[VALUE]'>") & vbNewLine
            
            'code fix for core-6775 adjustment amount shows values in timestamp 
             '****Starts here******
            End if
            '****Ends here******
        Case 68
            Form_DisplayCell =  Inherited("Form_DisplayCell()") ' Call the default implementation 
            
            PreProcessor.Clear
            PreProcessor.Add "ID"                         , ProductView.Properties.Rowset.Value("SessionID")            
            PreProcessor.Add "COLUMN_NAME"                , Form.Grid.SelectedProperty.Name
            PreProcessor.Add "VALUE"                      , "" & Form.Grid.SelectedProperty.Value
            EventArg.HTMLRendered = "<td class='" & Form.Grid.CellClass & "'>"  & Framework.Format(ProductView.Properties.RowSet.Value("c_ordertime"),FrameWork.Dictionary.Item("DATE_TIME_FORMAT").Value) & "</td>"  & vbNewLine & PreProcessor.Process("<input type=hidden name='_ST_[COLUMN_NAME][ID]' Value='[VALUE]'>") & vbNewLine
        Case Else
        
            Form_DisplayCell =  Inherited("Form_DisplayCell()") ' Call the default implementation 
            
            PreProcessor.Clear
            PreProcessor.Add "ID"                         , ProductView.Properties.Rowset.Value("SessionID")            
            PreProcessor.Add "COLUMN_NAME"                , Form.Grid.SelectedProperty.Name
            PreProcessor.Add "VALUE"                      , "" & Form.Grid.SelectedProperty.Value
            EventArg.HTMLRendered = EventArg.HTMLRendered  & vbNewLine & PreProcessor.Process("<input type=hidden name='_ST_[COLUMN_NAME][ID]' Value='[VALUE]'>") & vbNewLine
    End Select
    
END FUNCTION

PRIVATE FUNCTION Form_DisplayDetailRow(EventArg) ' As Boolean

    Dim objProperty, strButtonComputeName, strSelectorHTMLCode, strValue, strAttr, strHTMLAttributeName,     strTmp , strCurrency, strHTML

    EventArg.HTMLRendered = EventArg.HTMLRendered & "<td></td><td></td>" & vbNewLine
    EventArg.HTMLRendered = EventArg.HTMLRendered & "<td class='TableDetailCell' ColSpan=" & (ProductView.Properties.Count+2) & " width=20>" & vbNewLine
    EventArg.HTMLRendered = EventArg.HTMLRendered & GetHTMLTransactionDetail(ProductView.Properties("SessionID").Value)
    EventArg.HTMLRendered = EventArg.HTMLRendered & "</td>" & vbNewLine
    
    Form_DisplayDetailRow = TRUE
END FUNCTION

PRIVATE FUNCTION GetHTMLTransactionDetail(lngSessionID)

    Dim strHTML, strChildType, strHTMLCustom, Rowset, ChildrenSummaryRowset, i

    
    Set Rowset = ProductView.Properties.Rowset
    
    strHTML = strHTML & "<TABLE Width='100%' border=0 cellpadding=1 cellspacing=1>" & vbNewLine
    strHTML = strHTML & "<TR>"

    strHTML = strHTML & "<TD valign=top>" & vbNewLine
    
    '
    ' Display the parent amount
    '
    If CDbl(ProductView.Properties.Rowset.Value("AtomicPrebillAdjAmt"))<>0 Then    
    
        strHTML = strHTML & FrameWork.Dictionary().Item("TEXT_PARENT_PREBILL_ADJUSTMENT").Value & " : "  & FrameWork.FormatAmount(ProductView.Properties.Rowset.Value("AtomicPrebillAdjAmt")) & "<br>"
    End If
    If CDbl(ProductView.Properties.Rowset.Value("AtomicPostbillAdjAmt"))<>0 Then    
    
        strHTML = strHTML & FrameWork.Dictionary().Item("TEXT_PARENT_POSTBILL_ADJUSTMENT").Value & " : "  & FrameWork.FormatAmount(ProductView.Properties.Rowset.Value("AtomicPostbillAdjAmt")) & "<br>"
    End If    
    
    '
    ' Display children detail
    '        
    Form.Grids.Add "G"
    Set Form.Grids("G").Rowset = GetChildrenSummaryRowset(lngSessionID)
    
    Form.Grids("G").Properties.ClearSelection
    i = 1
    Form.Grids("G").Properties("ViewID").Selected                           = i : i=i+1  ' Place holder
    Form.Grids("G").Properties("PriceableItemInstanceName").Selected        = i : i=i+1
    Form.Grids("G").Properties("Currency").Selected                         = i : i=i+1
    Form.Grids("G").Properties("Amount").Selected                           = i : i=i+1
    Form.Grids("G").Properties("CompoundPrebillAdjAmt").Selected  = i : i=i+1
    Form.Grids("G").Properties("CompoundPrebillAdjedAmt").Selected    = i : i=i+1
    Form.Grids("G").Properties("ProductOfferingId").Selected                = i : i=i+1
    
'    Form.Grids("G").Properties.SelectAll
    
    Form.Grids("G").Properties("Amount").Format                             = FrameWork.Dictionary.Item("AMOUNT_FORMAT").Value
    Form.Grids("G").Properties("Amount").Alignment                          = "Right"
    Form.Grids("G").Properties("ProductOfferingId").Alignment               = "Right"
    
    Form.Grids("G").Properties("PriceableItemInstanceName").Caption         = FrameWork.Dictionary.Item("TEXT_CHILD_NAME").Value
    Form.Grids("G").Properties("Currency").Caption                          = FrameWork.Dictionary.Item("TEXT_CURRENCY").Value
    Form.Grids("G").Properties("Amount").Caption                            = FrameWork.Dictionary.Item("TEXT_AMOUNT").Value
    Form.Grids("G").Properties("CompoundPrebillAdjAmt").Caption   = FrameWork.Dictionary().Item("TEXT_ADJUSTMENT_AMOUNT").Value
    Form.Grids("G").Properties("CompoundPrebillAdjedAmt").Caption     = FrameWork.Dictionary().Item("TEXT_ADJUSTED_AMOUNT").Value
    
    Form.Grids("G").Properties("CompoundPrebillAdjAmt").Format    = FrameWork.Dictionary.Item("AMOUNT_FORMAT").Value
    Form.Grids("G").Properties("CompoundPrebillAdjAmt").Alignment = "Right"
    
    Form.Grids("G").Properties("CompoundPrebillAdjedAmt").Format      = FrameWork.Dictionary.Item("AMOUNT_FORMAT").Value
    Form.Grids("G").Properties("CompoundPrebillAdjedAmt").Alignment   = "Right"
    
    Form.Grids("G").Properties("ViewID").Caption                            = " "
    Form.Grids("G").Properties("ProductOfferingId").Caption                 = FrameWork.Dictionary().Item("TEXT_NUMBER_OF_ADJUSTMENTS").Value

    Set Form.Grids("G").PropertyID = Form.Grids("G").Properties("PriceableItemInstanceName")
    Form.Grids("G").LabelID        = lngSessionID

    mdm_RenderGrid EventArg, Form.Grids("G")
    strHTML = strHTML & Form.Grids("G").HTMLRendered
    
    strHTML = strHTML & "</TD></TR>"  & vbNewLine
    strHTML = strHTML & "</TABLE>"    & vbNewLine

    For i=0 To Rowset.Count-1    
        strHTML = Replace(strHTML,"[" & UCase(Rowset.Name(i)) &  "]", "" & Rowset.Value(i))
    Next
    
    strHTML = Replace(strHTML,"[CHILD_ASP]","Adjustment.Edit.Children.asp?SessionID=" & lngSessionID)
    Form.Grids.Remove "G"
    
    GetHTMLTransactionDetail = strHTML
END FUNCTION

PRIVATE FUNCTION G_DisplayCell(EventArg) ' As Boolean

    Dim HTML_LINK_EDIT, lngChildAdjustmentCount, lngMaxChild, booIsThereSomeThingToAdjust, strMAX_CHILD_MSG

    Select Case UCase(EventArg.Grid.SelectedProperty.Name)

        Case "VIEWID" ' First Column

            lngMaxChild                 = CLng(Form.Grids("G").Rowset.Value("Count"))
            lngChildAdjustmentCount     = CLng(GetChildAdjustmentCount(ProductView.Properties.Rowset.Value("SessionID"),Form.Grids("G").Rowset.Value("PriceableItemTemplateId"),GetAsBool("IsPrebillTransaction")))
            booIsThereSomeThingToAdjust = CBool((lngMaxChild>lngChildAdjustmentCount) and Not GetAsBool("IsIntervalSoftClosed"))

            HTML_LINK_EDIT = HTML_LINK_EDIT & "<TD NoWrap Class='[CLASS]'>" & vbNewLine            
            
            If (booIsThereSomeThingToAdjust) Then
                
				'grey out child adjustment icons if transaction has been reassigned
				If (Not GetAsBool("CanManageAdjustments") And GetAsBool("IsPostBillAdjusted")) Then
					HTML_LINK_EDIT = HTML_LINK_EDIT & "<IMG Alt='[TEXT_CANNOT_ADJUST_MANAGE_ADJUSTMENT_BECAUSE_REASSIGNED][CRLF][TEXT_ADJUST]'      Src='[IMAGE_PATH]/[ADJUST_GIF]Grayed.gif'      Border=0 >&nbsp;" & vbNewLine
					HTML_LINK_EDIT = HTML_LINK_EDIT &"<IMG Alt='[TEXT_CANNOT_ADJUST_MANAGE_ADJUSTMENT_BECAUSE_REASSIGNED][CRLF][TEXT_ADJUST_BULK]' Src='[IMAGE_PATH]/[ADJUST_BULK_GIF]Grayed.gif' Border=0 >" & vbNewLine                
				Else
					'normal case
					HTML_LINK_EDIT = HTML_LINK_EDIT & "<IMG Style='cursor:hand;' Alt='[TEXT_ADJUST]'      Src='[IMAGE_PATH]/[ADJUST_GIF].gif'      Border=0 OnClick='document.location.href=""[ADJUSTMENT_PVB_CHILDREN_DIALOG]?SessionID=[SESSIONID]&ChildType=[CHILDTYPE]&ViewId=[VIEWID]&PITemplate=[PITEMPLATE]&PITemplateChildren=[PITEMPLATECHILD]"";'>&nbsp;" & vbNewLine
					HTML_LINK_EDIT = HTML_LINK_EDIT & "<IMG Style='cursor:hand;' Alt='[TEXT_ADJUST_BULK]' Src='[IMAGE_PATH]/[ADJUST_BULK_GIF].gif' Border=0 OnClick='document.location.href    =""[ADJUSTMENT_EDIT_CHILDREN_BULK_DIALOG]?SessionID=[SESSIONID]&ChildType=[CHILDTYPE]&ViewId=[VIEWID]&PITemplate=[PITEMPLATE]&PITemplateChildren=[PITEMPLATECHILD]"";'>" & vbNewLine
				
				End If
				
            Else  
				'All children are adjusted
				If (lngMaxChild <= lngChildAdjustmentCount) Then              
					HTML_LINK_EDIT = HTML_LINK_EDIT & "<IMG Alt='[TEXT_ALL_CHILDREN_ARE_ADJUSTED][CRLF][TEXT_ADJUST]'      Src='[IMAGE_PATH]/[ADJUST_GIF]Grayed.gif'      Border=0 >&nbsp;" & vbNewLine
					HTML_LINK_EDIT = HTML_LINK_EDIT & "<IMG Alt='[TEXT_ALL_CHILDREN_ARE_ADJUSTED][CRLF][TEXT_ADJUST_BULK]' Src='[IMAGE_PATH]/[ADJUST_BULK_GIF]Grayed.gif' Border=0 >" & vbNewLine                
				
				'Interval is soft closed
				ElseIf(GetAsBool("IsIntervalSoftClosed")) Then
					HTML_LINK_EDIT = HTML_LINK_EDIT & "<IMG Alt='[TEXT_CANNOT_ADJUST_MANAGE_ADJUSTMENT_IN_SOFT_CLOSE][CRLF][TEXT_ADJUST]'      Src='[IMAGE_PATH]/[ADJUST_GIF]Grayed.gif'      Border=0 >&nbsp;" & vbNewLine
					HTML_LINK_EDIT = HTML_LINK_EDIT & "<IMG Alt='[TEXT_CANNOT_ADJUST_MANAGE_ADJUSTMENT_IN_SOFT_CLOSE][CRLF][TEXT_ADJUST_BULK]' Src='[IMAGE_PATH]/[ADJUST_BULK_GIF]Grayed.gif' Border=0 >" & vbNewLine                				
				End If
            
            End If

            strMAX_CHILD_MSG = ""
            
            If lngChildAdjustmentCount<>0 Then

                If FrameWork.CheckCoarseCapability("Manage Adjustments") Then               
                    strMAX_CHILD_MSG = "<a target=""MainContentIframe"" href=""/MetraNet/Adjustments/ManageAdjustments.aspx?ParentSessionId=[SESSIONID]""><img border=0 Name='ViewChildrenAdjustent[SESSIONID]' Style='cursor:hand;' Alt='[TEXT_MANAGE_ADJUSTMENT_CHILDREN]' Src='[IMAGE_PATH]/logs.gif' Border=0></a>&nbsp;"
                Else
                    strMAX_CHILD_MSG = "<IMG Alt='[TEXT_YOU_DO_NOT_HAVE_ADJUSTMENT_MANAGMENT_CAPABILITY]' Src='[IMAGE_PATH]/logs.gif' Border=0>&nbsp;" & vbNewLine
                End If
            End If

            HTML_LINK_EDIT = HTML_LINK_EDIT & "[MAX_CHILD_MSG]</TD>" & vbNewLine

            EventArg.HTMLRendered = PreProcess(HTML_LINK_EDIT,Array( _                                                             
                                                  "ADJUST_GIF"                            , "Adjust", _ 
                                                  "ADJUST_BULK_GIF"                       , "BulkAdjust", _
                                                  "CRLF"                                  , vbNewLine, _
                                                  "MAX_CHILD_MSG"                         , strMAX_CHILD_MSG, _
                                                  "IMAGE_PATH"                            , mam_GetImagesPath(), _
                                                  "CLASS"                                 , EventArg.Grid.CellClass, _
                                                  "SESSIONID"                             , ProductView.Properties.Rowset.Value("SessionID"), _
                                                  "VIEWID"                                , Form.Grids("G").Rowset.Value("ViewID"), _
                                                  "CHILDIDPITEMPLATE"                     , Form.Grids("G").Rowset.Value("PriceableItemTemplateId"), _
                                                  "PITEMPLATE"                            , ProductView.Properties.Rowset.Value("PITemplate"), _
                                                  "PITEMPLATECHILD"                       , Form.Grids("G").Rowset.Value("PriceableItemTemplateId"), _                                                                                                    
                                                  "CHILDTYPE"                             , Form.Grids("G").Rowset.Value("PriceableItemName") _
                                                  ))
                                                  

            EventArg.HTMLRendered = FrameWork.Dictionary.PreProcess(EventArg.HTMLRendered)
            G_DisplayCell = TRUE
            
        Case "PRODUCTOFFERINGID"

            lngMaxChild             = Form.Grids("G").Rowset.Value("Count")
            lngChildAdjustmentCount = GetChildAdjustmentCount(ProductView.Properties.Rowset.Value("SessionID"),Form.Grids("G").Rowset.Value("PriceableItemTemplateId"),GetAsBool("IsPrebillTransaction"))
            
            HTML_LINK_EDIT = HTML_LINK_EDIT & "<TD Class='[CLASS]' Align='[ALIGN]'>" & vbNewLine
            HTML_LINK_EDIT = HTML_LINK_EDIT & "[CHILD_ADJUSTMENT]&nbsp;/&nbsp;[MAX_CHILDREN]"
            HTML_LINK_EDIT = HTML_LINK_EDIT & "</TD>" & vbNewLine
            EventArg.HTMLRendered   = PreProcess(HTML_LINK_EDIT,Array( _
                                                  "ALIGN"                                 , EventArg.Grid.SelectedProperty.Alignment, _
                                                  "CLASS"                                 , EventArg.Grid.CellClass, _
                                                  "CHILD_ADJUSTMENT"                      , lngChildAdjustmentCount, _ 
                                                  "MAX_CHILDREN"                          , lngMaxChild _ 
                                                  ))
        Case Else

            G_DisplayCell = Inherited("Grid_DisplayCell(EventArg)")
    End Select
END FUNCTION

' With child type
PUBLIC FUNCTION GetChildAdjustmentCount(lngParentSessionID, lngPriceAbleItemTemplateID,booIsPreBill)

    Dim strSQL
	
    If booIsPreBill Then
				strSQL = "select * from t_adjustment_transaction ajt inner join t_adjustment aj ON ajt.id_aj_template  = aj.id_prop  where id_parent_sess = [PARENTSESSIONID] AND aj.id_pi_template = [PITEMPLATEID] AND ajt.c_status IN ('A', 'P') and n_adjustmenttype=0"
    Else
				strSQL = "select * from t_adjustment_transaction ajt inner join t_adjustment aj ON ajt.id_aj_template  = aj.id_prop  where id_parent_sess = [PARENTSESSIONID] AND aj.id_pi_template = [PITEMPLATEID] AND ajt.c_status IN ('A', 'P') and n_adjustmenttype=1"
    End If		

    GetChildAdjustmentCount = "UnKnown"
    If FrameWork.ExecuteSQLQuery(FrameWork.Dictionary.Item("SQL_QUERY_STRING_RELATIVE_PATH").Value,strSQL,Array("PARENTSESSIONID",lngParentSessionID,"PITEMPLATEID",lngPriceAbleItemTemplateID)) Then
        GetChildAdjustmentCount = FrameWork.LastRowset.RecordCount
    End If
END FUNCTION

' All type
PUBLIC FUNCTION GetAdjustmentCount(lngParentSessionID)

    Dim strSQL

		strSQL = "select * from t_adjustment_transaction ajt where id_parent_sess = [PARENTSESSIONID] AND ajt.c_status IN ('A', 'P') "
		
    GetAdjustmentCount = "UnKnown"
    If FrameWork.ExecuteSQLQuery(FrameWork.Dictionary.Item("SQL_QUERY_STRING_RELATIVE_PATH").Value,strSQL,Array("PARENTSESSIONID",lngParentSessionID)) Then
    
        GetAdjustmentCount = FrameWork.LastRowset.RecordCount
    End If
END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    :
' PARAMETERS		  :
' DESCRIPTION 		: 
' RETURNS		      : 
PRIVATE FUNCTION GetChildrenSummaryRowset(lngSessioID)

  Dim idParent, productSlice, sessSlice 
  
  Set GetChildrenSummaryRowset = Nothing ' Default Value
  
  Set sessSlice = CreateObject("MTHierarchyReports.SessionChildrenSlice")
  sessSlice.ParentID = lngSessioID
  
  Set GetChildrenSummaryRowset = TransactionUIFinder.RptHelper.GetUsageSummary2(sessSlice, TransactionUIFinder.AccSlice, TransactionUIFinder.TimeSlice, false)
END FUNCTION

PUBLIC FUNCTION Form_DisplayEndOfPage(EventArg) ' As Boolean

    Dim strEndOfPageHTMLCode, strTmp
    
    strTmp = strTmp & "</TABLE>"   
    strTmp = strTmp & "<BR><BR><CENTER><button  name='butBack' Class='clsButtonMedium' onclick='document.location.href=""[ADJUSTMENT_FINDER_DIALOG]?PriceAbleItemTemplateID=" & TransactionUIFinder.SelectedPriceAbleItemTemplateID & """; return false;'>" & FrameWork.Dictionary.Item("TEXT_BACK") & "</button></CENTER>" & vbNewLine    
    strTmp = strTmp & "</FORM></BODY>"
    
    EventArg.HTMLRendered = FrameWork.Dictionary.PreProcess(strTmp)
    
    ' New MDM 3.5
    Inherited "OnDisplayEndOfPageJavaScript(EventArg)"
    
    Form_DisplayEndOfPage = TRUE
END FUNCTION

PUBLIC FUNCTION DeleteParentAdjustment_Click(EventArg)

    Dim lngTransactionID

    lngTransactionID = mdm_UIValue("mdmUserCustom")
    AdjustmentHelper.DeleteAdjustment EventArg, FrameWork.GetMTCollectionFromCSVID("" & lngTransactionID)
    
    TransactionUIFinder.UpdateFoundRowSet ' -- Force to reload the transaction info now that we have adjusted at least one
    
    DeleteParentAdjustment_Click = TRUE
END FUNCTION

PRIVATE FUNCTION GenerateHTML(EventArg, ByRef HTML_LINK_EDIT) ' As Boolean

    Dim   lngChildAdjustmentCount, strTMP
    

        
		lngChildAdjustmentCount = GetAdjustmentCount(ProductView.Properties.Rowset.Value("SessionID"))        
    HTML_LINK_EDIT          = HTML_LINK_EDIT & "<td nowrap class='[CLASS]'>"
    '
    ' REBILL ICON
    '
    If TransactionUIFinder.SelectedPriceAbleItemTypeSupportReBill() Then
    
        If GetAsBool("CanReBill") Then

            GenerateHTMLIconReBill HTML_LINK_EDIT
        Else                      
            GenerateHTMLIconReBillGrayed HTML_LINK_EDIT, "TEXT_CANNOT_REBILL_ADJUSTMENT"
        End If
    Else
        GenerateHTMLIconReBillGrayed HTML_LINK_EDIT, "TEXT_REBILL_IS_NOT_SUPPORTED_BY_PRICEABLEITEM"
    End If            
    '
    ' ADJUST PARENT ICON
    '
    If GetAsBool("CanAdjust") Then
    
        GenerateHTMLIconAdjust  HTML_LINK_EDIT ' we only can apply adjustment if transaction became post-bill
        
    ElseIf GetAsBool("CanManageAdjustments") Then
    
        GenerateHTMLIconManage HTML_LINK_EDIT ' We have post-bill adjustment        
    Else
        If GetAsBool("IsIntervalSoftClosed") Then

            GenerateHTMLIconAdjustGrayed HTML_LINK_EDIT
        Else
            If GetAsBool("IsPostbillAdjusted") Then
            
                GenerateHTMLIconManageGrayed HTML_LINK_EDIT
            Else
                HTML_LINK_EDIT = "<br>" & FrameWork.Dictionary.Item("MAM_ERROR_1048").Value & "<br>"
            End If
        End If
    End If
    HTML_LINK_EDIT = HTML_LINK_EDIT & "</td>"
    
 
    '
    ' SET THE TURN DOWN ICON
    '
    If lngChildAdjustmentCount Then
    
        MDM_PRODUCT_VIEW_TOOL_BAR_TURN_RIGHT_HTTP_FILE_NAME     =   "/mam/default/localized/en-us/images/arrowBlueRightAdjustManage.gif"
        MDM_PRODUCT_VIEW_TOOL_BAR_TURN_DOWN_HTTP_FILE_NAME      =   "/mdm/internal/images/toolbar/arrowBlueDown.gif"
        MDM_PRODUCT_VIEW_TOOL_BAR_TURN_DOWN_TOOL_TIP            =   FrameWork.Dictionary().Item("TEXT_ADJUST_OR_MANAGE_ADJUSTMENT_CHILDREN").Value                
    Else
        MDM_PRODUCT_VIEW_TOOL_BAR_TURN_RIGHT_HTTP_FILE_NAME     =   "/mam/default/localized/en-us/images/arrowBlueRightAdjust.gif"
        MDM_PRODUCT_VIEW_TOOL_BAR_TURN_DOWN_HTTP_FILE_NAME      =   "/mdm/internal/images/toolbar/arrowBlueDown.gif"
        MDM_PRODUCT_VIEW_TOOL_BAR_TURN_DOWN_TOOL_TIP            =   FrameWork.Dictionary().Item("TEXT_ADJUST_ADJUSTMENT_CHILDREN").Value
    End If    
END FUNCTION

%>




