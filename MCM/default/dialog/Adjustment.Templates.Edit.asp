<% 
' ---------------------------------------------------------------------------------------------------------
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
' ---------------------------------------------------------------------------------------------------------
'
' MetraTech Dialog Manager Demo
' 
' DIALOG	    : MCM Dialog
' DESCRIPTION	: 
' AUTHOR	    : F.Torres, K.Boucher
' VERSION	    : 2.0
'
' ---------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../MCMIncludes.asp" -->
<!-- #INCLUDE FILE="../lib/CMCMAdjustmentHelper.asp" -->

<%
Form.Version        = MDM_VERSION     ' Set the dialog version - we are version 2.0.
Form.ErrorHandler   = TRUE


mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------
' FUNCTION 		    : Form_Initialize
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean

  Form.Modal    = TRUE  
  Form("ID")    = Request.QueryString("ID")
  
  RefreshData  
  FrameWork.Dictionary.Add "PRICEABLEITEMDISPLAYNAME",SafeForHtml(AdjustmentTemplateHelper.PriceAbleItemDisplayName)  
  Form.Grids.Add "AdjustmentTemplateGrid", "AdjustmentTemplateGrid"
  
	Form_Initialize = Form_Refresh(EventArg)
END FUNCTION

PRIVATE FUNCTION RefreshData()

    AdjustmentTemplateHelper.Initialize Form("ID")
    RefreshData = TRUE
END FUNCTION

PRIVATE FUNCTION Form_Refresh(EventArg) ' As Boolean

    Dim lngID, lngReasonCodeID, lngAdjustmentTemplateID, objAdjustmentTemplate

    '
    ' The user added a new adjustement type
    '
    

    If UCase(mdm_UIValue("NewAdjustmentTypeMode"))="TRUE" Then
    
        lngID = mdm_UIValue("IDs")
    
        If Len(lngID) Then
    
            Set objAdjustmentTemplate = AdjustmentTemplateHelper.AddAdjustment(CLng(lngID))
            Form.JavaScriptInitialize = "javascript:window.open('[ADJUSTMENT_TEMPLATE_EDIT_DIALOG]?NextPage=[ADJUSTMENT_TEMPLATES_EDIT_DIALOG]&AdjustmentTemplateID=[ID]', '_blank', 'height=400,width=500,resizable=yes,scrollbars=yes'); return false;"
            Form.JavaScriptInitialize = FrameWork.Dictionary.PreProcess(Form.JavaScriptInitialize)
            Form.JavaScriptInitialize = PreProcess(Form.JavaScriptInitialize,Array("ID",objAdjustmentTemplate.ID))
        End If
    End If

    Set Form.Grids("AdjustmentTemplateGrid").RowSet = Nothing

    If AdjustmentTemplateHelper.TemplateAdjustments.Count Then
    
        Set Form.Grids("AdjustmentTemplateGrid").RowSet = FrameWork.CollectionToRowset(AdjustmentTemplateHelper.TemplateAdjustments,"Name,DisplayName,Id","Name,DisplayName,Id","")
        Form.Grids("AdjustmentTemplateGrid").Properties.ClearSelection
        Form.Grids("AdjustmentTemplateGrid").Properties("DisplayName").Selected     = 2
        Form.Grids("AdjustmentTemplateGrid").Properties("Name").Selected            = 1 ' Used to show reason code
        Form.Grids("AdjustmentTemplateGrid").Properties("Id").Selected              = 3 ' Button Area
        
        Form.Grids("AdjustmentTemplateGrid").Properties("Name").Caption = FrameWork.Dictionary.Item("TEXT_FIELD_NAME").Value
        Form.Grids("AdjustmentTemplateGrid").Properties("DisplayName").Caption = FrameWork.Dictionary.Item("TEXT_REASON_CODES").Value
        Form.Grids("AdjustmentTemplateGrid").Properties("Id").Caption = " "
    End If    
    Form_Refresh = TRUE
END FUNCTION

PRIVATE FUNCTION AdjustmentTemplateGrid_DisplayCell(EventArg) ' As Boolean

    Select Case LCase(EventArg.Grid.SelectedProperty.Name)
    
          Case "id"
           
            EventArg.HTMLRendered = EventArg.HTMLRendered & "<td class='" & EventArg.Grid.CellClass & "'>" & vbNewLine
            
            ' EDIT Button            
            EventArg.HTMLRendered = EventArg.HTMLRendered & "<BUTTON class='clsButtonBlueSmall' Name='EditAdjustmentTemplate[ID]' onClick=""javascript:window.open('[ADJUSTMENT_TEMPLATE_EDIT_DIALOG]?NextPage=[ADJUSTMENT_TEMPLATES_EDIT_DIALOG]&AdjustmentTemplateID=[ID]', '_blank', 'height=400,width=500,resizable=yes,scrollbars=yes'); return false;"">" & FrameWork.Dictionary.Item("TEXT_EDIT") & "</BUTTON>"  & vbNewLine
            
            ' DELETE Button                        
            'If EventArg.Grid.Properties("id").Value<>-1 Then ' If the id is -1 the item has not yet been saved...
            
                EventArg.HTMLRendered = EventArg.HTMLRendered & "<BUTTON class='clsButtonBlueSmall' Name='DeleteAdjustmentTemplate' OnClick='mdm_RefreshDialogUserCustom(this,""[ID]"");'>" & FrameWork.Dictionary.Item("TEXT_DELETE") & "</BUTTON>"
            'End If

            EventArg.HTMLRendered = EventArg.HTMLRendered & "</td>" & vbNewLine
            EventArg.HTMLRendered = PreProcess(EventArg.HTMLRendered,Array("ID",EventArg.Grid.Properties("id").Value,"ADJUSTMENT_TEMPLATES_EDIT_DIALOG",FrameWork.Dictionary.Item("ADJUSTMENT_TEMPLATES_EDIT_DIALOG").Value))  & vbNewLine            
            AdjustmentTemplateGrid_DisplayCell = TRUE
            
        Case "displayname"
            
            Dim ReasonCode,ReasonCodes, strHTMLReasonCode
            Set ReasonCodes = AdjustmentTemplateHelper.GetAdjustmentReasonCodes(EventArg.Grid.Properties("id").Value)
            
            For Each ReasonCode In ReasonCodes
                'CORE-5188 - Incorrect Value displayes when selecting Adjustment Reason Codes in "Configure adjustment" page 
                ' Replaced Name with DisplayName
                strHTMLReasonCode = strHTMLReasonCode & ReasonCode.DisplayName & "<br/>"
            Next
            
            EventArg.HTMLRendered = Empty ' Need to clear the all mess after the grid rendering
            EventArg.HTMLRendered = EventArg.HTMLRendered & "<td class='" & EventArg.Grid.CellClass & "'>" & vbNewLine            
            EventArg.HTMLRendered = EventArg.HTMLRendered & strHTMLReasonCode & vbNewLine            
            EventArg.HTMLRendered = EventArg.HTMLRendered & "</td>" & vbNewLine
            
            AdjustmentTemplateGrid_DisplayCell = TRUE
                    
        Case Else
            AdjustmentTemplateGrid_DisplayCell = Inherited("Grid_DisplayCell(EventArg)")
            
    End Select
END FUNCTION

PUBLIC FUNCTION DeleteAdjustmentTemplate_Click(EventArg)

 
    Dim lngAdjustmentTemplateID
    
    DeleteAdjustmentTemplate_Click  = FALSE
    lngAdjustmentTemplateID         = mdm_UIValue("mdmUserCustom")
    
    On Error Resume Next
    AdjustmentTemplateHelper.RemoveAdjustment(CLng(lngAdjustmentTemplateID))
    If Err.Number Then
        EventArg.Error.Save Err
        EventArg.Error.Number = EventArg.Error.Number + USER_ERROR_MASK
        Err.Clear
        Exit Function
    End If
    
    DeleteAdjustmentTemplate_Click = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------
' FUNCTION 		    : OK_Click
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Ok_Click(EventArg) ' As Boolean

    Dim s

   	Ok_Click = FALSE
        
    If Not AdjustmentTemplateHelper.CheckIfAllAdjustmentHaveReasonCode() Then
    
        EventArg.Error.Description  = FrameWork.Dictionary().Item("MCM_ERROR_1007").Value
        EventArg.Error.Number       = 1007+USER_ERROR_MASK
        Exit Function
    End If
    
    Ok_Click = SaveAll(EventArg) ' As Boolean

END FUNCTION

PRIVATE FUNCTION SaveAll(EventArg) ' As Boolean

    Dim s

   	SaveAll = FALSE
    
    On Error Resume Next
    AdjustmentTemplateHelper.Save
    If(Err.Number)Then
        EventArg.Error.Save Err
       	SaveAll = FALSE
        Err.Clear
    Else
       	SaveAll  = TRUE
    End If
END FUNCTION
%>
