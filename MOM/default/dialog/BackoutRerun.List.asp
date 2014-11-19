 <% 
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile: BackoutRerun.List.asp$
' 
'  Copyright 1998-2003 by MetraTech Corporation
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
'  Created by: Rudi
' 
'  $Date: 11/14/2002 7:18:41 PM$
'  $Author: Rudi Perkins$
'  $Revision: 3$
'
' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
'
' CLASS       : 
' DESCRIPTION : 
' ---------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/mdm.asp"          -->
<!-- #INCLUDE FILE="../../default/lib/momLibrary.asp"                   -->
<!-- #INCLUDE VIRTUAL="/mdm/FrameWork/CFrameWork.Class.asp" -->
<%

Form.Version                    = MDM_VERSION     ' Set the dialog version - we are version 2.0.
Form.ErrorHandler               = TRUE
Form.ShowExportIcon             = TRUE
Form.Page.MaxRow                = CLng(mom_GetDictionary("PV_ROW_PER_PAGE"))
Form.Page.NoRecordUserMessage   = mom_GetDictionary("PRODUCT_VIEW_BROWSER_NO_RECORDS_FOUND")

mdm_PVBrowserMain ' invoke the mdm framework

PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean

    Framework.AssertCourseCapability "Manage Backouts and Reruns", EventArg
    
    ProductView.Clear  ' Set all the property of the service to empty or to the default value
   	ProductView.Properties.ClearSelection
    ProductView.Properties.Flags = eMSIX_PROPERTIES_FLAG_PRODUCTVIEW

    Form("Filter") =  Request.QueryString("Filter")    
	  Form_Initialize   = TRUE
END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  Form_LoadProductView
' PARAMETERS:  EventArg
' DESCRIPTION: 
' RETURNS:  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_LoadProductView(EventArg) ' As Boolean

  Form_LoadProductView = FALSE

  Dim Rowset, i
  
  Set Rowset = Server.CreateObject("MTSQLRowset.MTSQLRowset.1")
	Rowset.Init "queries\mom"
  

  if Form("Filter")="Completed" then
    rowset.SetQueryTag("__GET_BACKOUT_RERUN_COMPLETED_LIST__")
    'mdm_GetDictionary().Add "BACKOUT_RERUN_MANANAGEMENT_PAGE_TITLE", mdm_GetDictionary().Item("TEXT_BACKOUTRERUN_MANANAGEMENT_COMPLETED")
  else if Form("Filter")="InProgress" then
    rowset.SetQueryTag("__GET_BACKOUT_RERUN_INPROGRESS_LIST__")
    'mdm_GetDictionary().Add "BACKOUT_RERUN_MANANAGEMENT_PAGE_TITLE", mdm_GetDictionary().Item("TEXT_BACKOUTRERUN_MANANAGEMENT_INPROGESS")
  else
    rowset.SetQueryTag("__GET_BACKOUT_RERUN_LIST__")
    'mdm_GetDictionary().Add "BACKOUT_RERUN_MANANAGEMENT_PAGE_TITLE", mdm_GetDictionary().Item("TEXT_BACKOUTRERUN_MANANAGEMENT")
  end if
  end if
  
  Rowset.execute
  
  ' Load a Rowset from a SQL Queries and build the properties collection of the product view based on the columns of the rowset
  Set ProductView.Properties.RowSet = Rowset
  
  'ProductView.Properties.SelectAll
  
  ProductView.Properties.ClearSelection ' Select the properties I want to print in the PV Browser Order
  i = 1
  ProductView.Properties("RerunId").Selected     = i : i=i+1
  ProductView.Properties("Filter").Selected      = i : i=i+1
  ProductView.Properties("Tag").Selected         = i : i=i+1
  ProductView.Properties("LastAction").Selected  = i : i=i+1
  ProductView.Properties("Time").Selected        = i : i=i+1
  ProductView.Properties("Time").Format          = mom_GetDictionary("DATE_TIME_FORMAT")
  ProductView.Properties("UserName").Selected    = i : i=i+1
  ProductView.Properties("Comment").Selected     = i : i=i+1
  
  ProductView.Properties("RerunId").Caption     = mom_GetDictionary("TEXT_RerunId1")
  ProductView.Properties("Filter").Caption      = mom_GetDictionary("TEXT_Filter1")
  ProductView.Properties("Tag").Caption         = mom_GetDictionary("TEXT_Tag1")
  ProductView.Properties("LastAction").Caption  = mom_GetDictionary("TEXT_LastAction1")
  ProductView.Properties("Time").Caption        = mom_GetDictionary("TEXT_Time1")  
  ProductView.Properties("UserName").Caption    = mom_GetDictionary("TEXT_UserName1")
  ProductView.Properties("Comment").Caption     = mom_GetDictionary("TEXT_Comment1")

  'ProductView.Properties.CancelLocalization
 
  ' REQUIRED because we must generate the property type info in javascript. When the user change the property which he
  ' wants to use to do a filter we use the type of the property (JAVASCRIPT code) to show 2 textbox if it is a date
  ' else one.
  ProductView.LoadJavaScriptCode
  
  mdm_SetMultiColumnFilteringMode TRUE
        
  Form_LoadProductView = TRUE ' Must Return TRUE To Render The Dialog
  
END FUNCTION


PRIVATE FUNCTION Form_DisplayDetailRow(EventArg) ' As Boolean

    Dim Rowset, HistoryGrid, TmpEventArg, lngReRunId

    lngReRunId             = ProductView.Properties.Rowset.Value("RerunId")
    Set HistoryGrid        = Server.CreateObject("MTMSIX.MDMGrid")
    Set TmpEventArg        = Server.CreateObject("MTMSIX.MDMEvent")
    HistoryGrid.Name       = "HistoryGrid"
    HistoryGrid.Caption    = "History"
    
    EventArg.HTMLRendered = EventArg.HTMLRendered & "<td></td><td></td>" & vbNewLine
    'EventArg.HTMLRendered = EventArg.HTMLRendered & "<td ColSpan=" & (ProductView.Properties.Count+2) & ">" & vbNewLine
    EventArg.HTMLRendered = EventArg.HTMLRendered & "<td ColSpan=9>" & vbNewLine


    Set Rowset = Server.CreateObject("MTSQLRowset.MTSQLRowset.1")
	  Rowset.Init "queries\mom"
    Rowset.SetQueryTag("__GET_BACKOUT_RERUN_HISTORY_LIST__")
    Rowset.AddParam "%%ID_RERUN%%", lngReRunId

    Rowset.execute

    EventArg.HTMLRendered = EventArg.HTMLRendered & "<TABLE width='100%' border=0 cellpadding=1 cellspacing=0>" & vbNewLine
    
    'id_rerun dt_action   tx_action   id_acc   tx_comment  
    EventArg.HTMLRendered = EventArg.HTMLRendered & "<tr class='TableHeader' style='background-color=#688ABA'><td align='left' colspan='5'>" 
    EventArg.HTMLRendered = EventArg.HTMLRendered & mom_GetDictionary("TEXT_Backout_Rerun_History") & "</td></tr>"    
    EventArg.HTMLRendered = EventArg.HTMLRendered & "<tr class='TableHeader' style='background-color=#688ABA'><td align='left'>"
    EventArg.HTMLRendered = EventArg.HTMLRendered & mom_GetDictionary("TEXT_Time1") & "</td><td align='left'>"
    EventArg.HTMLRendered = EventArg.HTMLRendered & mom_GetDictionary("TEXT_Action1") & "</td><td align='left'>" 
    EventArg.HTMLRendered = EventArg.HTMLRendered & mom_GetDictionary("TEXT_Comment1") & "</td><td align='left'>" & mom_GetDictionary("TEXT_UserName1") & "</td></tr>"    

    if rowset.eof then
      EventArg.HTMLRendered = EventArg.HTMLRendered & "<tr class='TableDetailCell'><td colspan='4'>" & mom_GetDictionary("TEXT_NO_EVENTS1") & "</td></tr>"
    else  
      do while not rowset.eof 
          dim sToolTip
          'sToolTip = rowset.value("Details")
          EventArg.HTMLRendered = EventArg.HTMLRendered & "<tr class='TableDetailCell' title='" & sToolTip & "'><td style='vertical-align: top'>" & rowset.value("Time") & "</td>"
          EventArg.HTMLRendered = EventArg.HTMLRendered & "<td style='vertical-align: top'>" & rowset.value("Action") & "</td>"  
          EventArg.HTMLRendered = EventArg.HTMLRendered & "<td width='350px' style='vertical-align: top'>" & rowset.value("Details") & "&nbsp;</td>"
          EventArg.HTMLRendered = EventArg.HTMLRendered & "<td style='vertical-align: top'>" & rowset.value("UserName") & "&nbsp;</td></tr>"    
          rowset.movenext
      loop 
    end if
    
    EventArg.HTMLRendered = EventArg.HTMLRendered & "</TABLE><BR>" & vbNewLine
    
    rowset.MoveLast
        
    Select Case UCase(rowset.Value("Action"))        
      Case "CREATE"
      Case "END IDENTIFY"
          EventArg.HTMLRendered = EventArg.HTMLRendered & GetHTMLCodeForButton(mom_GetDictionary("TEXT_Resume_Backout"),"Analyze",lngReRunId)          
          EventArg.HTMLRendered = EventArg.HTMLRendered & GetHTMLCodeForButton(mom_GetDictionary("TEXT_Abandon_Backout"),"Abandon",lngReRunId)          
      Case "END ANALYZE"
          EventArg.HTMLRendered = EventArg.HTMLRendered & GetHTMLCodeForButton(mom_GetDictionary("TEXT_Resume_Backout"),"Analyze",lngReRunId)          
          EventArg.HTMLRendered = EventArg.HTMLRendered & GetHTMLCodeForButton(mom_GetDictionary("TEXT_Abandon_Backout"),"Abandon",lngReRunId)          
      'For these cases, do nothing
      Case "END BACKOUT/DELETE"
      Case "END BACKOUT/RESUBMIT"
      Case "END PREPARE"
      Case "END EXTRACT"
      Case "END ABANDON"

      Case else
          EventArg.HTMLRendered = EventArg.HTMLRendered & "<div class='clsError'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" & mom_GetDictionary("TEXT_BACK_OUT_OPERATION_IS_NOT_COMPLETE") & "<br><br>"
          EventArg.HTMLRendered = EventArg.HTMLRendered & GetHTMLCodeForButton(mom_GetDictionary("TEXT_Resume_Backout"),"Analyze",lngReRunId)          
          EventArg.HTMLRendered = EventArg.HTMLRendered & GetHTMLCodeForButton(mom_GetDictionary("TEXT_Abandon_Backout"),"Abandon",lngReRunId) & "</div>"
       
    End Select    
    EventArg.HTMLRendered = EventArg.HTMLRendered & "<br><br></td>" & vbNewLine
    Form_DisplayDetailRow = TRUE
END FUNCTION

PRIVATE FUNCTION GetHTMLCodeForButton(strDisplayName,strName,lngReRunID)

   if len(strDisplayName)>20 then
    GetHTMLCodeForButton = PreProcess("&nbsp;&nbsp;<button class='clsButtonBlueXXLarge' name='but[NAME]' OnClick='mdm_RefreshDialogUserCustom(this,""[RERUNID]""); return false;'>[DISPLAYNAME]</button>[CRLF]",Array("DISPLAYNAME",strDisplayName,"NAME",strName,"RERUNID",lngReRunID,"CRLF",vbNewLine))
   else
    GetHTMLCodeForButton = PreProcess("&nbsp;&nbsp;<button class='clsButtonBlueXLarge' name='but[NAME]' OnClick='mdm_RefreshDialogUserCustom(this,""[RERUNID]""); return false;'>[DISPLAYNAME]</button>[CRLF]",Array("DISPLAYNAME",strDisplayName,"NAME",strName,"RERUNID",lngReRunID,"CRLF",vbNewLine))
   end if 
END FUNCTION

PRIVATE FUNCTION RetreiveReRunObject(lngReRunId)

    Dim objReRun
    
    lngReRunId              = CLng(lngReRunId)
    Set objReRun            = Server.CreateObject(MT_BILLING_RERUN_PROG_ID)
    objReRun.Login FrameWork.SessionContext
    objReRun.ID             = lngReRunId
    Set RetreiveReRunObject = objReRun
END FUNCTION

PRIVATE FUNCTION butAnalyze_Click(EventArg)
    'RetreiveReRunObject(mdm_UIValue("mdmUserCustom")).Analyze "GMT Time " & FrameWork.MetraTimeGMTNow()
    dim strBackoutUrl
    strBackoutUrl = "BackoutRerun.BackoutStep2.asp?Rerunid=" & mdm_UIValue("mdmUserCustom")
    mdm_TerminateDialogAndExecuteDialog strBackoutUrl
    butAnalyse_Click = TRUE
END FUNCTION

PRIVATE FUNCTION butBackOut_Click(EventArg)
    RetreiveReRunObject(mdm_UIValue("mdmUserCustom")).BackOut "GMT Time " & FrameWork.MetraTimeGMTNow()    
    butBackOut_Click = TRUE
END FUNCTION

PRIVATE FUNCTION butPrepare_Click(EventArg)
    RetreiveReRunObject(mdm_UIValue("mdmUserCustom")).Prepare "GMT Time " & FrameWork.MetraTimeGMTNow()    
    butPrepare_Click = TRUE
END FUNCTION

PRIVATE FUNCTION butExtract_Click(EventArg)
    RetreiveReRunObject(mdm_UIValue("mdmUserCustom")).Extract "GMT Time " & FrameWork.MetraTimeGMTNow()
    butExtract_Click = TRUE
END FUNCTION

PRIVATE FUNCTION butReSubmit_Click(EventArg)
    RetreiveReRunObject(mdm_UIValue("mdmUserCustom")).ReRun "GMT Time " & FrameWork.MetraTimeGMTNow()
    mdm_TerminateDialogAndExecuteDialog "BackoutRerun.List.asp?Filter=Completed"
    butReSubmit_Click = TRUE
END FUNCTION

PRIVATE FUNCTION butDelete_Click(EventArg)
    RetreiveReRunObject(mdm_UIValue("mdmUserCustom")).Delete "GMT Time " & FrameWork.MetraTimeGMTNow()
    mdm_TerminateDialogAndExecuteDialog "BackoutRerun.List.asp?Filter=Completed"
    butDelete_Click = TRUE
END FUNCTION

PRIVATE FUNCTION butAbandon_Click(EventArg)
    RetreiveReRunObject(mdm_UIValue("mdmUserCustom")).Abandon "GMT Time " & FrameWork.MetraTimeGMTNow()
    mdm_TerminateDialogAndExecuteDialog "BackoutRerun.List.asp?Filter=Completed"
    butDelete_Click = TRUE
END FUNCTION

PRIVATE FUNCTION Form_DisplayCell(EventArg) ' As Boolean

    Dim strImageHTMLAttributeName, strComment, lngPos, strSessionID
    Const TAG = "BATCHID:"
    
    Select Case Form.Grid.Col
        Case 2

            Form_DisplayCell            = Inherited("Form_DisplayCell")
            strImageHTMLAttributeName   = "TurnDown(" & Form.Grid.Row & ")"
            
            ' Special code for unit test
            strComment = ProductView.Properties("Comment").Value
            lngPos     = InStr(strComment,TAG)
            
            If lngPos Then
        
                strSessionID          = Mid(strComment,lngPos+Len(TAG))
                EventArg.HTMLRendered = Replace(EventArg.HTMLRendered,strImageHTMLAttributeName,"TurnDown:" & strSessionID)
            End If
            Form_DisplayCell = TRUE
        Case 7:
            EventArg.HTMLRendered     =  "<td class='" & Form.Grid.CellClass & "'>"  & mdm_Format(ProductView.Properties.RowSet.Value("time"),mom_GetDictionary("DATE_TIME_FORMAT")) & "</td>"
            Form_DisplayCell = TRUE
        Case Else
            Form_DisplayCell = Inherited("Form_DisplayCell")
    End Select
END FUNCTION

%>

