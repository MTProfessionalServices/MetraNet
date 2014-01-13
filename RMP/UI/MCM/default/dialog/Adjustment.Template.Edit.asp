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
Form.ErrorHandler   = FALSE
Form.Modal          = TRUE
Form.CallParentPopUpWithNoURLParameters = TRUE

mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------
' FUNCTION 		    : Form_Initialize
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean

  Form("ExecuteRefresh")                    = TRUE
  Form("AdjustmentTemplateID")              = mdm_UIValue("AdjustmentTemplateID")  
  FrameWork.Dictionary.Add "ADJUSTMENT_TEMPLATE_ID", Form("AdjustmentTemplateID")
  
  COMObject.Properties.Clear
  Set COMObject.Instance  = AdjustmentTemplateHelper.GetAdjustmentFromID(Form("AdjustmentTemplateID"))
  '
  ' Remove all the required unused fields
  '  
  Dim MSIXProperty
  For Each MSIXProperty In COMObject.Properties  
      MSIXProperty.Required = FALSE
  Next
  
  COMObject.Properties("Name").Required        = TRUE
  COMObject.Properties("DisplayName").Required = TRUE
  COMObject.Properties("Description").Required = TRUE
  
  Form.Grids.Add "ReasonCodesGrid"        ,"ReasonCodesGrid"

	Form_Initialize = Form_Refresh(EventArg) ' As Boolean
END FUNCTION


PRIVATE FUNCTION Form_Refresh(EventArg) ' As Boolean

    Dim lngReasonCodeID, lngAdjustmentTemplateID

    If Form("ExecuteRefresh") Then
        '
        ' The user added a new adjustement type
        '
        If UCase(mdm_UIValue("NewReasonCodeMode"))="TRUE" Then
        
            lngReasonCodeID = mdm_UIValue("IDs")
            
            If Len(lngReasonCodeID) Then
            
                  lngAdjustmentTemplateID = mdm_UIValue("AdjustmentTemplateID")
                  AdjustmentTemplateHelper.AddReasonCode lngReasonCodeID,lngAdjustmentTemplateID
            End If
        End If
          
        Dim ReasonCodes
        Set ReasonCodes = AdjustmentTemplateHelper.GetAdjustmentReasonCodes(Form("AdjustmentTemplateID"))
        'CORE-5188 - Incorrect Value displayes when selecting Adjustment Reason Codes in "Configure adjustment" page 
        ' Replaced Name with DisplayName
        Set Form.Grids("ReasonCodesGrid").RowSet = FrameWork.CollectionToRowset(ReasonCodes,"DisplayName,Id","Name,Id","")
        Form.Grids("ReasonCodesGrid").Properties.ClearSelection
        Form.Grids("ReasonCodesGrid").Properties("Name").Selected     = 1
        Form.Grids("ReasonCodesGrid").Properties("Id").Selected              = 2 ' Button Area
        
        Form.Grids("ReasonCodesGrid").Properties("Name").Caption = FrameWork.Dictionary().Item("TEXT_COLUMN_NAME").Value
        Form.Grids("ReasonCodesGrid").Properties("Id").Caption          = " "
    End If
      
    Form_Refresh = TRUE
END FUNCTION        

PRIVATE FUNCTION ReasonCodesGrid_DisplayCell(EventArg) ' As Boolean


    Select Case LCase(EventArg.Grid.SelectedProperty.Name)
    
          Case "id"
           
            EventArg.HTMLRendered = EventArg.HTMLRendered & "<td class='" & EventArg.Grid.CellClass & "'>" & vbNewLine
                 
            ' Create RS Button                                        
            EventArg.HTMLRendered = EventArg.HTMLRendered & "<BUTTON class='clsButtonBlueSmall' Name='butDeleteReasonCode' onClick='mdm_RefreshDialogUserCustom(this," & EventArg.Grid.SelectedProperty.Value & ")'>"  & FrameWork.Dictionary.Item("TEXT_DELETE") & "</BUTTON>"  & vbNewLine
            
            EventArg.HTMLRendered = EventArg.HTMLRendered & "</td>" & vbNewLine
            
            EventArg.HTMLRendered = PreProcess(EventArg.HTMLRendered,Array("ID",Form("AdjustmentTemplateID")))  & vbNewLine

            ReasonCodesGrid_DisplayCell = TRUE
                    
        Case Else
            ReasonCodesGrid_DisplayCell = Inherited("Grid_DisplayCell(EventArg)")
            
    End Select
END FUNCTION

PRIVATE FUNCTION butDeleteReasonCode_Click(EventArg) ' As Boolean

    Dim lngReasonCodeID
    lngReasonCodeID = mdm_UIValue("mdmUserCustom")
    If IsNumeric(lngReasonCodeID) And CBool(Len(lngReasonCodeID)) Then
    
        AdjustmentTemplateHelper.RemoveReasonCode lngReasonCodeID,   Form("AdjustmentTemplateID")
    End If    
    butDeleteReasonCode_Click = TRUE
END FUNCTION



PRIVATE FUNCTION Ok_Click(EventArg) ' As Boolean

    Ok_Click = FALSE
    
    Dim ReasonCodes
    Set ReasonCodes = AdjustmentTemplateHelper.GetAdjustmentReasonCodes(Form("AdjustmentTemplateID"))
    If ReasonCodes.Count = 0 Then
    
        EventArg.Error.Description  = FrameWork.Dictionary().Item("MCM_ERROR_1007").Value
        EventArg.Error.Number       = 1007+USER_ERROR_MASK
        Exit Function
    End If
    
    On Error Resume Next
    COMObject.Instance.Save    
    If(Err.Number)Then
        EventArg.Error.Save Err
        OK_Click = FALSE
        Err.Clear
    Else
        Form("ExecuteRefresh") = FALSE
        OK_Click = TRUE
    End If 
END FUNCTION

PRIVATE FUNCTION CANCEL_Click(EventArg) ' As Boolean

    Form("ExecuteRefresh") = FALSE
    CANCEL_Click = TRUE
END FUNCTION

%>

