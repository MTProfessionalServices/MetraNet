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
' AUTHOR	    : F.Torres
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

  Form.Modal                      = TRUE
  Form("PriceAbleItemInstanceID") = mdm_UIValue("ID")
  Form("POID")                    = mdm_UIValue("POID")
  
  RefreshData

  FrameWork.Dictionary.Add "PRICEABLEITEMDISPLAYNAME",SafeForHtml(AdjustmentTemplateHelper.PriceAbleItemDisplayName)
  
  Form.Grids.Add "AdjustmentInstanceGrid", "AdjustmentInstanceGrid"
  
  Form.Grids("AdjustmentInstanceGrid").Width ="100%"
  
	Form_Initialize = Form_Refresh(EventArg)
END FUNCTION

PRIVATE FUNCTION RefreshData()

    AdjustmentTemplateHelper.InitializeInstance Form("PriceAbleItemInstanceID"), Form("POID")
    RefreshData = TRUE
END FUNCTION

PRIVATE FUNCTION Form_Refresh(EventArg) ' As Boolean

    Dim lngID, lngReasonCodeID, lngAdjustmentTemplateID

    Set Form.Grids("AdjustmentInstanceGrid").RowSet = Nothing ' Clear the grid

    If AdjustmentTemplateHelper.InstanceAdjustments.Count Then    
      Dim adj, displayName
      For Each adj In AdjustmentTemplateHelper.InstanceAdjustments 
            For Each displayName In adj.DisplayNames
                if displayName.LanguageCode = "US" And displayName.Value <> "" Then adj.DisplayName = displayName.Value End If 
            Next
      Next
      Set Form.Grids("AdjustmentInstanceGrid").RowSet = FrameWork.CollectionToRowset(AdjustmentTemplateHelper.InstanceAdjustments,"DisplayName,Id","DisplayName,Id","")
      
      Form.Grids("AdjustmentInstanceGrid").Properties.ClearSelection
      'Form.Grids("AdjustmentInstanceGrid").Properties("Name").Selected            = 1
      Form.Grids("AdjustmentInstanceGrid").Properties("DisplayName").Selected     = 1
      Form.Grids("AdjustmentInstanceGrid").Properties("ID").Selected              = 2
      
      Form.Grids("AdjustmentInstanceGrid").Properties("Id").Caption               = " "
      Form.Grids("AdjustmentInstanceGrid").Properties("DisplayName").Caption = FrameWork.Dictionary.Item("TEXT_FIELD_DISPLAY_NAME").Value
      
      FrameWork.Dictionary.Add  "Adjustment.Instances.Edit.USER_MESSAGE", FrameWork.Dictionary.Item("TEXT_CONFIGURED_ADJUSTMENTS").Value
    Else
        FrameWork.Dictionary.Add  "Adjustment.Instances.Edit.USER_MESSAGE", FrameWork.Dictionary.Item("TEXT_PRICEABLE_ITEM_DOES_NOT_SUPPORT_ADJUSTMENT").Value        
    End If
    Form_Refresh = TRUE
END FUNCTION

PRIVATE FUNCTION AdjustmentInstanceGrid_DisplayCell(EventArg) ' As Boolean

    Select Case LCase(EventArg.Grid.SelectedProperty.Name)
    
          Case "id"
           
            EventArg.HTMLRendered = EventArg.HTMLRendered & "<td class='" & EventArg.Grid.CellClass & "'>" & vbNewLine

            ' EDIT Button            
            
            EventArg.HTMLRendered = EventArg.HTMLRendered & "<BUTTON class='clsButtonBlueSmall' Name='EditAdjustmentTemplate[ID]' " & _
            "onClick=""javascript:window.open('[ADJUSTMENT_INSTANCE_EDIT_DIALOG]?NextPage=[ADJUSTMENT_INSTANCES_EDIT_DIALOG]&AdjustmentInstanceID=[ID]', '_blank', 'height=130,width=500,resizable=yes,scrollbars=yes'); return false;"">" & FrameWork.Dictionary.Item("TEXT_EDIT") & "</BUTTON>"  & vbNewLine
            
            EventArg.HTMLRendered = EventArg.HTMLRendered & "</td>" & vbNewLine
            EventArg.HTMLRendered = PreProcess(EventArg.HTMLRendered,Array(  _
                                                                            "ID",EventArg.Grid.Properties("id").Value,_
                                                                            "ADJUSTMENT_TEMPLATES_EDIT_DIALOG",FrameWork.Dictionary.Item("ADJUSTMENT_TEMPLATES_EDIT_DIALOG").Value _
                                                                            ))  & vbNewLine
            AdjustmentInstanceGrid_DisplayCell = TRUE
            

                    
        Case Else
            AdjustmentInstanceGrid_DisplayCell = Inherited("Grid_DisplayCell(EventArg)")
            
    End Select
END FUNCTION

PUBLIC FUNCTION DeleteAdjustmentTemplate_Click(EventArg)
    
 
    Dim lngAdjustmentTemplateID
    lngAdjustmentTemplateID = mdm_UIValue("mdmUserCustom")
    AdjustmentTemplateHelper.RemoveAdjustment(CLng(lngAdjustmentTemplateID))
    
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

    On Error Resume Next
    AdjustmentTemplateHelper.Save
    If(Err.Number)Then
        EventArg.Error.Save Err
        OK_Click = FALSE
        Err.Clear
    Else
        OK_Click = TRUE
    End If
END FUNCTION
%>
