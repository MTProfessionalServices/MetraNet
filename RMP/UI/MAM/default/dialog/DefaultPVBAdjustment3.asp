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
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" -->
<%

PUBLIC CONST ADJUSTMENT_ROWSET_SESSION_NAME = "ADJUSTMENT_ROWSET_SESSION_NAME"

Form.Version                      = MDM_VERSION     ' Set the dialog version
Form.Page.MaxRow                  = CLng(mam_GetDictionary("PV_ROW_PER_PAGE"))
Form.Page.NoRecordUserMessage     = mam_GetDictionary("PRODUCT_VIEW_BROWSER_NO_RECORDS_FOUND")
Form.RouteTo                      = mam_GetDictionary("WELCOME_DIALOG")

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
    
    Form.Grids.Add "ChildrenGridTTrans"
    
    Session(ADJUSTMENT_ROWSET_SESSION_NAME) = Empty
    Form.ShowExportIcon   = TRUE ' Export
    Form_Initialize       = TRUE
    
    Form("ComputedSessionID") =""
    Form("SavedSessionID") =""
    Form("AdjustmentType")=0
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
    
  If IsEmpty(Session(ADJUSTMENT_ROWSET_SESSION_NAME)) Then    
  
      Set Session(ADJUSTMENT_ROWSET_SESSION_NAME) = mdm_CreateObject("MTMAM.CMAMSubscriberBill")
      
      Session(ADJUSTMENT_ROWSET_SESSION_NAME).Initialize Session("SubscriberYAAC")
      Session(ADJUSTMENT_ROWSET_SESSION_NAME).LoadSummary
  End If
  
  Set objMamBill = Session(ADJUSTMENT_ROWSET_SESSION_NAME)
  Set ProductView.Properties.RowSet = objMamBill.LoadProductViewData("AudioConfCall")      
  
  If IsValidObject(ProductView.Properties.RowSet) Then
      
      ProductView.Properties.SelectAll
      ProductView.Properties.ClearSelection
      
      ProductView.Properties("TimeStamp").Selected = i              : i=i+1
      ProductView.Properties("SessionID").Selected = i              : i=i+1
      ProductView.Properties("c_ConferenceName").Selected = i       : i=i+1  
      ProductView.Properties("c_ConferenceID").Selected = i         : i=i+1  
      ProductView.Properties("DisplayName").Selected = i       : i=i+1  
      ProductView.Properties("c_AccountingCode").Selected = i       : i=i+1  
      ProductView.Properties("c_ServiceLevel").Selected = i         : i=i+1  
      ProductView.Properties("c_ActualNumConnections").Selected = i : i=i+1  
      ProductView.Properties("Amount").Selected = i                 : i=i+1  
      
      ProductView.Properties("Amount").Format                    = mam_GetDictionary("AMOUNT_FORMAT")
      ProductView.Properties("Amount").Alignment                 = "right"
    
      ProductView.Properties("TimeStamp").Format 			           = mam_GetDictionary("DATE_TIME_FORMAT")
      ProductView.Properties("TimeStamp").Sorted                 = MTSORT_ORDER_DECENDING  ' Sort
             
      Service.Properties.TimeZoneId                              = MAM().CSR("TimeZoneId") ' Set the TimeZone, so the dates will be printed for the CSR time zone
      Service.Properties.DayLightSaving                          = mam_GetDictionary("DAY_LIGHT_SAVING")
      'ProductView.Properties.SelectAll
          
          mdm_SetMultiColumnFilteringMode TRUE
        
          ' REQUIRED because we must generate the property type info in javascript. When the user change the property which he
          ' wants to use to do a filter we use the type of the property (JAVASCRIPT code) to show 2 textbox if it is a date
          ' else one.
          ProductView.LoadJavaScriptCode
        
          Form_LoadProductView = TRUE 
  End If          
END FUNCTION

'ProductOfferingName,PriceableItemName,PriceableItemInstanceName,ProductOfferingId,PriceableItemInstanceId,PriceableItemTemplateId,PriceableItemParentId,ViewID,ViewType,DescriptionID,Currency,Amount,TaxAmount,AmountWithTax,Count,
PRIVATE FUNCTION Form_DisplayEndRow(EventArg) ' As Boolean

    Dim strGridHTML, objMamBill, objPerTypeDetailRowset, strChildServiceName

    If CLng(mdm_UIValue("ShowTransDetail"))=CLng(ProductView.Properties.Rowset.Value("SessionID")) Then

'        
        
        Set objMamBill             = Session(ADJUSTMENT_ROWSET_SESSION_NAME)
        Set objPerTypeDetailRowset = objMamBill.GetChildrenTYPESDetailAsRowSet()
        
        Do While Not objPerTypeDetailRowset.EOF
        
           strChildServiceName = objPerTypeDetailRowset.Value("PriceableItemName")
            
            Set Form.Grids("ChildrenGridTTrans").RowSet = objMamBill.GetChildrenDetailAsRowSet(objPerTypeDetailRowset,"")
            Form.Grids("ChildrenGridTTrans").Properties.SelectAll
            
            If mdm_RenderGrid(EventArg,Form.Grids("ChildrenGridTTrans"))  Then
                strGridHTML =  strGridHTML & "<b>" & strChildServiceName & "</b><br>" & Form.Grids("ChildrenGridTTrans").HTMLRendered & "<BR>"
            Else
                strGridHTML =  "error rendering grid" & "<BR>"
            End If
            
      
            
            objPerTypeDetailRowset.MoveNext
        Loop
        
        EventArg.HTMLRendered = "" ' The mdm_RenderGrid add some code that I do not want
        EventArg.HTMLRendered = EventArg.HTMLRendered  & "</tr>" ' Close the regular row
        EventArg.HTMLRendered = EventArg.HTMLRendered  & "<tr>" ' open a new row
        EventArg.HTMLRendered = EventArg.HTMLRendered  & "<td></td><td></td><td>"
        EventArg.HTMLRendered = EventArg.HTMLRendered  & strGridHTML
        EventArg.HTMLRendered = EventArg.HTMLRendered  & "</td></tr>" ' Close 

    Else
        Form_DisplayEndRow  =  Inherited("Form_DisplayEndRow()") ' Call the default implementation           
    End If
END FUNCTION


PRIVATE FUNCTION childrenGridTTrans_DisplayEndRow(EventArg) ' As Boolean

      On Error goto 0
      Dim strAspPage, strPIType, strIDSession

      EventArg.HTMLRendered = "</TR>" & vbNewLine  

      If Len(Request.QueryString("ChildIdSession")) Then
      
          If CStr(Request.QueryString("ChildIdSession")) = CStr(Form.Grids("ChildrenGridTTrans").RowSet.Value("SessionID")) Then
                
                strPIType     = "AudioConfConn"
                strIDSession  = Form.Grids("ChildrenGridTTrans").RowSet.Value("SessionID")
                strAspPage    = "AudioConf.Adjustment.asp"
                
                CONST HTML_TEMPLATE = "</tr><tr><td></td><td></td><td colspan=41><iframe src='[ASP_PAGE]?PIType=[PITYPE]&IdSession=[SESSION_ID]' hspace=2 vspace=0 frameborder=0 marginheight=0 marginwidth=1 width=600 height=70 scrolling=no></iframe></td></tr>"
                
                EventArg.HTMLRendered = EventArg.HTMLRendered  & PreProcess(HTML_TEMPLATE,Array("ASP_PAGE",strAspPage,"PITYPE",strPIType,"SESSION_ID",strIDSession))
          End If
      End If
END FUNCTION

PRIVATE FUNCTION childrenGridTTrans_DisplayCell(EventArg) ' As Boolean
    
    Dim HTML_LINK_EDIT, PreProcessor, strHREF
    
    Select Case EventArg.Grid.SelectedProperty.Name
    
        Case "ViewID"
          
            strHREF = "DefaultPVBAdjustment.asp?ShowTransDetail=" & mdm_UIValue("ShowTransDetail") & "&ChildIdSession=" & EventArg.Grid.Rowset.Value("SessionID")
            EventArg.HTMLRendered           = "<td>Adjust : <SELECT Name='AdjustType' OnChange=""alert(1);document.location.href='" & strHREF & "'""><OPTION Value=''></OPTION><OPTION Value='Minutes'>Minutes</OPTION></SELECT></td>"
            Form_DisplayCell                = TRUE
        Case Else
        
            ChildrenGridTTrans_DisplayCell = Inherited("Grid_DisplayCell(EventArg)")
    End Select    
    
END FUNCTION

PRIVATE FUNCTION Form_DisplayCell(EventArg) ' As Boolean

    Dim HTML_LINK_EDIT, PreProcessor
    
    Select Case Form.Grid.Col
    
        Case 11111
        
            Set PreProcessor = mdm_CreateObject(CPreProcessor)
        
            HTML_LINK_EDIT = HTML_LINK_EDIT & "<td class='[CLASS]' width='40'>"
            HTML_LINK_EDIT = HTML_LINK_EDIT & "<A Name='Session[ID]' HREF='[ASP_PAGE]?mdmPageAction=REFRESH&ShowTransDetail=[ID]&'><img Alt='[ALT_ADJUST]' src='[IMAGE_EDIT]' Border='0'></A>&nbsp;"
            HTML_LINK_EDIT = HTML_LINK_EDIT & "</td>"
            
            PreProcessor.Clear
            PreProcessor.Add "ID"          , ProductView.Properties.Rowset.Value("SessionID")
            PreProcessor.Add "CLASS"       , Form.Grid.CellClass
            PreProcessor.Add "ASP_PAGE"    , "DefaultPVBAdjustment.asp"
            PreProcessor.Add "IMAGE_EDIT"  , Application("APP_HTTP_PATH") & "/default/localized/en-us/images/edit.gif"
            PreProcessor.Add "ALT_ADJUST"  , "Adjust" ' mdm_GetDictionary().Item("TEXT_VIEW").Value
            
            EventArg.HTMLRendered           = PreProcessor.Process(HTML_LINK_EDIT)
            Form_DisplayCell                = TRUE
            
        Case Else
        
           Form_DisplayCell =  Inherited("Form_DisplayCell()") ' Call the default implementation           
    End Select
    
END FUNCTION    


PRIVATE FUNCTION Form_DisplayEndOfPage(EventArg) ' As Boolean

    dim strEndOfPageHTMLCode, strTmp
    
    ' Call the inherited event so we close the ProductVIew Browser as it should be
    ' Becare full this function is setting     EventArg.HTMLRendered
    ' Inherited("Form_DisplayEndOfPage()")
    
    '  add some code at the end of the product view UI
    strEndOfPageHTMLCode = "</TABLE><br>"
        
'    strTmp = "<br><button  name='SELECTALL' class='clsButtonBlueLarge' onclick='mdm_RefreshDialog(this)'>Open All Adjustments</button>" & vbNewLine
 '   strEndOfPageHTMLCode = strEndOfPageHTMLCode & strTmp
    
  '  strTmp = "&nbsp;&nbsp;&nbsp;<button  name='SELECTALL' class='clsButtonBlueMedium' onclick='mdm_RefreshDialog(this)'>Save Now</button>" & vbNewLine
   ' strEndOfPageHTMLCode = strEndOfPageHTMLCode & strTmp    
    
    


    strEndOfPageHTMLCode = strEndOfPageHTMLCode & "</FORM>"
    
    ' Here we must not forget to concat rather than set because we want to keep the result of the inherited event.
    ' EventArg.HTMLRendered = EventArg.HTMLRendered & REPLACE(strEndOfPageHTMLCode,"[LOCALIZED_IMAGE_PATH]",mom_GetLocalizeImagePath())
    EventArg.HTMLRendered = strEndOfPageHTMLCode
    
    Form_DisplayEndOfPage = TRUE
END FUNCTION


   


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			:
' PARAMETERS		:
' DESCRIPTION 		:
' RETURNS			:
PRIVATE FUNCTION Form_DisplayDetailRow(EventArg) ' As Boolean

    Dim objProperty,     strButtonComputeName
    Dim strSelectorHTMLCode
    Dim strValue, strAttr 
    Dim strCurrency
    Dim strHTMLAttributeName,     strTmp 

    'Set objProperty = ProductView.Properties.Item(Form.Grid.PropertyName)
    EventArg.HTMLRendered = EventArg.HTMLRendered & "<td></td><td></td>" & vbNewLine
    EventArg.HTMLRendered = EventArg.HTMLRendered & "<td ColSpan=" & (ProductView.Properties.Count+2) & " width=20>" & vbNewLine
    
    EventArg.HTMLRendered = EventArg.HTMLRendered & "<TABLE  width='100%' border=0 cellpadding=1 cellspacing=0>" & vbNewLine
    EventArg.HTMLRendered = EventArg.HTMLRendered & "<tr>" & vbNewLine
    EventArg.HTMLRendered = EventArg.HTMLRendered & "<td Class='TableDetailCell' nowrap>" & vbNewLine
    
    DisplayDetailRow EventArg
    
    EventArg.HTMLRendered = EventArg.HTMLRendered & "</td>" & vbNewLine
    EventArg.HTMLRendered = EventArg.HTMLRendered & "</tr>" & vbNewLine
              
    EventArg.HTMLRendered = EventArg.HTMLRendered & "</TABLE>" & vbNewLine
    
    EventArg.HTMLRendered = EventArg.HTMLRendered & "<br><br></td>" & vbNewLine
    
    Form_DisplayDetailRow = TRUE
END FUNCTION           


PRIVATE FUNCTION DisplayDetailRow(EventArg) ' As Boolean

    Dim AdjustmentTypes, lngSelectedAdjustmentTypes, strAdjustmentTypesHTMLOption, i, booSupportBulk, booCanAdjustChildren,              BULK_SELECTOR_CONNECTION, BULK_SELECTOR_FEATURE
    
    AdjustmentTypes = Array("None","Conf Call setup charge","Connection minutes","Feature Setup Charge")
    
    If IsNumeric(mdm_UIValue("cboAdjustmentTypes")) Then Form("AdjustmentType") = mdm_UIValue("cboAdjustmentTypes")
    
    lngSelectedAdjustmentTypes = CLng(Form("AdjustmentType"))
    
    For i=0 to UBound(AdjustmentTypes)
    
        If i=lngSelectedAdjustmentTypes Then
            strAdjustmentTypesHTMLOption = strAdjustmentTypesHTMLOption & "<option selected value=" & i & ">" & AdjustmentTypes(i) & "</option>"
        Else
            strAdjustmentTypesHTMLOption = strAdjustmentTypesHTMLOption & "<option value=" & i & ">" & AdjustmentTypes(i) & "</option>"
        End If
    Next
    
'0. None
'1. Conf Call setup charge adjustment ($) -- Call
'2. Connection minutes adjustment (minutes) -- Connection (SupportsBulk)
'3. Feature Setup Charge ($) -- Feature (Does not support Bulk)

    EventArg.HTMLRendered = EventArg.HTMLRendered & "<TABLE  idth='100%' border=1 cellpadding=1 cellspacing=0>" & vbNewLine
    
    EventArg.HTMLRendered = EventArg.HTMLRendered & "<tr><td nowrap>Adjustment Type :</td><td><select OnChange='mdm_RefreshDialogUserCustom(this,""[SESSIONID]"");' class='clsInputBox' name='cboAdjustmentTypes'>[ADJUSTMENTS_CBO_OPTION]</select></td></tr>" & vbNewLine
    
    Select Case lngSelectedAdjustmentTypes 
        Case 1:
              EventArg.HTMLRendered = EventArg.HTMLRendered & "<tr><td nowrap></td><td>Amount :<input class='clsInputBox' type=text name='Amount'>" & vbNewLine
        Case 2:
              EventArg.HTMLRendered = EventArg.HTMLRendered & "<tr><td nowrap></td><td>Minutes :<input class='clsInputBox' type=text name='Amount'>" & vbNewLine
              EventArg.HTMLRendered = EventArg.HTMLRendered & "<input type=checkbox>Adjust on all the connections<br>" & vbNewLine
              BULK_SELECTOR_CONNECTION = "<input type=checkbox>"

        Case 3:
              EventArg.HTMLRendered = EventArg.HTMLRendered & "<tr><td nowrap></td><td>Amount :<input class='clsInputBox' type=text name='Amount'>" & vbNewLine
              EventArg.HTMLRendered = EventArg.HTMLRendered & "<b>You must select at least one feature</b><br>" & vbNewLine
              BULK_SELECTOR_FEATURE = "<input type=checkbox>"
    End Select
    
    If(lngSelectedAdjustmentTypes >0) Then
        EventArg.HTMLRendered = EventArg.HTMLRendered & "<Button Name='butCompute' class='clsButtonBlueMedium' OnClick='mdm_RefreshDialogUserCustom(this,""[SESSIONID]"");'>Compute</button>"
        EventArg.HTMLRendered = EventArg.HTMLRendered & "<Button disabled Name='butCompute' class='clsButtonBlueMedium' OnClick='mdm_RefreshDialogUserCustom(this,""[SESSIONID]"");'>Save</button>"
    End If
    
    EventArg.HTMLRendered = EventArg.HTMLRendered & "</td></tr>"

    EventArg.HTMLRendered = EventArg.HTMLRendered & "<tr><td>AudioConfConn :</td><td>$90.00</td></tr>" & vbNewLine
    EventArg.HTMLRendered = EventArg.HTMLRendered & "<tr><td></td><td nowrap>[BULK_SELECTOR_CONNECTION]Connection 127382163 :</td><td>$45.00</td></tr>" & vbNewLine
    EventArg.HTMLRendered = EventArg.HTMLRendered & "<tr><td></td><td nowrap>[BULK_SELECTOR_CONNECTION]Connection 32133 :</td><td>$45.00</td></tr>" & vbNewLine
    
    EventArg.HTMLRendered = EventArg.HTMLRendered & "<tr><td>AudioConfFeature :</td><td>$3.00</td></tr>" & vbNewLine
    EventArg.HTMLRendered = EventArg.HTMLRendered & "<tr><td></td><td nowrap>[BULK_SELECTOR_FEATURE]Feature XXX :</td><td>$3.00</td></tr>" & vbNewLine
    EventArg.HTMLRendered = EventArg.HTMLRendered & "<tr><td></td><td nowrap>[BULK_SELECTOR_FEATURE]Feature TYY :</td><td>$1.00</td></tr>" & vbNewLine
    
    EventArg.HTMLRendered = EventArg.HTMLRendered & "<tr><td>Overused Port :</td><td>$10.00</td></tr>" & vbNewLine
    EventArg.HTMLRendered = EventArg.HTMLRendered & "<tr><td>Tax :</td><td>$0.00</td></tr>" & vbNewLine
    
    EventArg.HTMLRendered = PreProcess(EventArg.HTMLRendered,Array("SESSIONID",ProductView.Properties("SessionID").Value,"ADJUSTMENTS_CBO_OPTION",strAdjustmentTypesHTMLOption,"BULK_SELECTOR_CONNECTION", BULK_SELECTOR_CONNECTION,"BULK_SELECTOR_FEATURE", BULK_SELECTOR_FEATURE))
              
    EventArg.HTMLRendered = EventArg.HTMLRendered & "</TABLE>" & vbNewLine
END FUNCTION

PRIVATE FUNCTION cboAdjustmentTypes_Click(EventArg) ' As Boolean

    cboAdjustmentTypes_Click = TRUE
END FUNCTION

PRIVATE FUNCTION DisplayDetailRowAdjustment(EventArg) ' As Boolean
    Dim objProperty,     strButtonComputeName
    Dim strSelectorHTMLCode
    Dim strValue, strAttr 
    Dim strCurrency
    Dim strHTMLAttributeName,     strTmp 

    If IsSaved(ProductView.Properties("SessionID").Value) Then
      strAttr = " disabled "
    End If
    
    EventArg.HTMLRendered = EventArg.HTMLRendered & "Type : <select [ATTR] class='clsInputBox' name='adjType'><option name='adjTypeMinute'>Minute</option></select>&nbsp;&nbsp;" & vbNewLine
    EventArg.HTMLRendered = EventArg.HTMLRendered & "Reason Code : <select [ATTR] class='clsInputBox' name='adjReasonCode'><option name='Bad Connection'>Bad Connection</option><option name='Bankcruptcy'>Bankcruptcy</option></select>&nbsp;&nbsp;" & vbNewLine
    EventArg.HTMLRendered = EventArg.HTMLRendered & "Minutes : <input [ATTR] class='clsInputBox' type=text name='minute'>&nbsp;&nbsp;" & vbNewLine
    EventArg.HTMLRendered = EventArg.HTMLRendered & "Internal Reason : <input [ATTR] class='clsInputBox' size=50 type=text name='InternalReason'>&nbsp;&nbsp;" & vbNewLine
    
    EventArg.HTMLRendered = PreProcess(EventArg.HTMLRendered,Array("ATTR",strAttr))
    
    If IsSaved(ProductView.Properties("SessionID").Value) Then
  
         EventArg.HTMLRendered = EventArg.HTMLRendered & "<BR><BR><B>Transaction adjusted - New Amount : $100<B>" & vbNewLine
        ' Delete Button
        strTmp = "&nbsp;<Button Name='butDelete' class='clsButtonBlueMedium' OnClick='mdm_RefreshDialogUserCustom(this,""[SESSIONID]"");'>Delete</button>" & vbNewLine    
        strTmp = PreProcess(strTmp,Array("SESSIONID",ProductView.Properties("SessionID").Value))    
        EventArg.HTMLRendered = EventArg.HTMLRendered & strTmp           
    else
        ' Compute Button
        strTmp = "&nbsp;<Button Name='butCompute' class='clsButtonBlueMedium' OnClick='mdm_RefreshDialogUserCustom(this,""[SESSIONID]"");'>Compute</button>" & vbNewLine    
        strTmp = PreProcess(strTmp,Array("SESSIONID",ProductView.Properties("SessionID").Value))    
        EventArg.HTMLRendered = EventArg.HTMLRendered & strTmp 
        
        If IsComputed(ProductView.Properties("SessionID").Value) Then
        
            EventArg.HTMLRendered = EventArg.HTMLRendered & "<BR><BR><B>New Amount : $100<B>" & vbNewLine
            
            ' Save button
            strTmp = "&nbsp;<Button Name='butSave' class='clsButtonBlueMedium' OnClick='mdm_RefreshDialogUserCustom(this,""[SESSIONID]"");'>Save</button>" & vbNewLine
            strTmp = PreProcess(strTmp,Array("SESSIONID",ProductView.Properties("SessionID").Value))    
            EventArg.HTMLRendered = EventArg.HTMLRendered & strTmp             
        
        Else        
            EventArg.HTMLRendered = EventArg.HTMLRendered & "<br>(*) The transaction is adjustable" & vbNewLine    
        End If
    End If
    
    DisplayDetailRowAdjustment = TRUE
END FUNCTION

PRIVATE FUNCTION butCompute_Click(EventArg) ' As Boolean

  Dim lngSessionID
  
  lngSessionID                = mdm_UIValue("mdmUserCustom")   
  Form("ComputedSessionID")   = Form("ComputedSessionID") & "," & lngSessionID & ","  
  butCompute_Click            = TRUE
  
END FUNCTION

PRIVATE FUNCTION butSave_Click(EventArg) ' As Boolean

  Dim lngSessionID
  
  lngSessionID                = mdm_UIValue("mdmUserCustom")   
  Form("SavedSessionID")      = Form("SavedSessionID") & "," & lngSessionID & ","  
  butSave_Click           = TRUE
  
END FUNCTION

PRIVATE FUNCTION butDelete_Click(EventArg) ' As Boolean

  Dim lngSessionID
  
  lngSessionID = mdm_UIValue("mdmUserCustom")   
  DeleteAdjustment lngSessionID  
  butDelete_Click = TRUE
 
END FUNCTION


PRIVATE FUNCTION DeleteAdjustment(lngSessionID)
    Form("ComputedSessionID") = Replace(Form("ComputedSessionID"), "," & lngSessionID & ",",",")
    Form("SavedSessionID") = Replace(Form("SavedSessionID"), "," & lngSessionID & ",",",")
END FUNCTION

PRIVATE FUNCTION IsComputed(lngSessionID)
    IsComputed = InStr(Form("ComputedSessionID"), "," & lngSessionID & ",") <> 0
END FUNCTION
PRIVATE FUNCTION IsSaved(lngSessionID)
    IsSaved = InStr(Form("SavedSessionID"), "," & lngSessionID & ",") <> 0
END FUNCTION

%>
