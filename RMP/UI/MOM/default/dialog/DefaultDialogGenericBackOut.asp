<% 
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
'  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
'
' MetraTech Dialog Manager Demo
' 
' DIALOG	    : MCM Dialog
' DESCRIPTION	: 
' AUTHOR	    : F.Torres
' VERSION	    : 1.0
'
'Check out and build UI\Server\MTAdminTools\MTConfigHelper from the 3.5 Branch.
'
'Dim objConfigHelper
'Set objConfigHelper= Server.CreateObject("MTConfigHelper.ConfigHelper")
'Call objConfigHelper.Initialize(false)
'
''Get the services
'Set collServices = objConfigHelper.GetServiceCollection
'
'for each objService in collServices
'  strPath = objService.Path
'next
'
'Set collPV = objConfigHelper.GetProductViewCollection
'
'for each objPV in collPV
'  strPath = objPV.Path
'next
'
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/mdm.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MoMLibrary.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/FrameWork/CFrameWork.Class.asp" -->

<%

PRIVATE m_strStep

Form.Version        = MDM_VERSION     ' Set the dialog version - we are version 2.0.
Form.RouteTo        = mom_GetDictionary("WELCOME_DIALOG")

mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : Form_Populate()
' PARAMETERS		  : 
' DESCRIPTION 		: Check if the time for the end date was set if not we set 23:59:59.
' RETURNS		      : Returns TRUE if ok else FALSE
'PRIVATE FUNCTION Form_Populate(EventArg) ' As Boolean
'      Inherited("Form_Populate") ' First Let us call the inherited event
'      mcm_CheckEndDate EventArg, "EffectiveDate__EndDate"
'      mcm_CheckEndDate EventArg, "AvailabilityDate__EndDate"
'      Form_Populate = TRUE
'END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : Form_Initialize
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean
    
    Service.Properties.Add "ServiceDef"       , MSIXDEF_TYPE_STRING   , 255 , FALSE, Empty
    Service.Properties.Add "ProductView"      , MSIXDEF_TYPE_STRING   , 255 , FALSE, Empty
    Service.Properties.Add "Comment"          , MSIXDEF_TYPE_STRING   , 255 , TRUE,  Empty
    Service.Properties.Add "BatchID"          , MSIXDEF_TYPE_STRING   , 255 , FALSE, Empty
    Service.Properties.Add "SessionID"        , MSIXDEF_TYPE_STRING   , 255 , FALSE, Empty
    Service.Properties.Add "AdvancedBackOut"  , MSIXDEF_TYPE_BOOLEAN  , 0   , FALSE, Empty    
    Service.Properties.Add "BeginDatetime"    , MSIXDEF_TYPE_TIMESTAMP, 0   , FALSE, Empty
    Service.Properties.Add "EndDatetime"      , MSIXDEF_TYPE_TIMESTAMP, 0   , FALSE, Empty
    
    Service.Properties("BatchID").Value         = ""
    Service.Properties("AdvancedBackOut").Value = FALSE
    
    LoadDynamicEnumType()

    ' REQUIRED because we must generate the property type info in javascript. When the user change the property which he
    ' wants to use to do a filter we use the type of the property (JAVASCRIPT code) to show 2 textbox if it is a date
    ' else one.
    ProductView.LoadJavaScriptCode
    
    mdm_IncludeCalendar
  
    Form_Initialize = TRUE
END FUNCTION

PRIVATE FUNCTION LoadDynamicEnumType()

    Dim objDyn, objPV, objPVS
  
  
    Set objPVS            = FrameWork.ConfigHelper.GetProductViewCollection()
    Set objDyn            = mdm_CreateObject(CVariables)
    objDyn.Add "", "", , , " "
    For Each objPV in objPVS
        objDyn.Add objPV.Name, objPV.Name, , , objPV.Name
    Next
    Service.Properties("ProductView").AddValidListOfValues objDyn
    
    Set objPVS            = FrameWork.ConfigHelper.GetServiceCollection()
    Set objDyn            = mdm_CreateObject(CVariables)    
    objDyn.Add "", "", , , " "
    For Each objPV in objPVS    
        objDyn.Add objPV.Name, objPV.Name, , , objPV.Name
    Next
    Service.Properties("ServiceDef").AddValidListOfValues objDyn    
    
  LoadDynamicEnumType = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : OK_Click
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Ok_Click(EventArg) ' As Boolean

    OK_Click = FALSE

    On Error Resume Next
    
    Dim objReRun, objFilter

    
    m_strStep = "MTBillingReRun.Setup"
    
    Set objReRun = CreateObject(MT_BILLING_RERUN_PROG_ID)
    
    objReRun.Login FrameWork.SessionContext
    
    objReRun.Setup Service.Properties("Comment").Value ' Start with a blank comment    
    If Not CheckError() Then Exit Function
    
    Set objFilter = CreateObject(MT_BILLING_IDENTIFICATION_FILTER_ID)
    
    If Len(Service.Properties("BatchID").Value)       Then objFilter.BatchID        = Service.Properties("BatchID").Value
    If Len(Service.Properties("SessionID").Value)     Then objFilter.SessionID      = Service.Properties("SessionID").Value
    If Len(Service.Properties("BeginDatetime").Value) Then objFilter.BeginDatetime  = Service.Properties("BeginDatetime").Value
    If Len(Service.Properties("EndDatetime").Value)   Then objFilter.EndDatetime    = Service.Properties("EndDatetime").Value
    If Len(Service.Properties("ProductView").Value)   Then objFilter.AddProductView Service.Properties("ProductView").Value
    If Len(Service.Properties("ServiceDef").Value)    Then objFilter.AddService     Service.Properties("ServiceDef").Value
    
    m_strStep = "MTBillingReRun.Identify"
    objReRun.Identify objFilter , Service.Properties("Comment").Value
    If Not CheckError() Then Exit Function
    
    ' In advanced mode we let the use finish the rest of the operation manually
    If Service.Properties("AdvancedBackOut").Value Then
    
      OK_Click = TRUE        
      Exit Function
    End If
    
    m_strStep = "MTBillingReRun.Analyze"
    objReRun.Analyze Service.Properties("Comment").Value
    If Not CheckError() Then Exit Function
    
    m_strStep = "MTBillingReRun.Backout"
    objReRun.Backout Service.Properties("Comment").Value
    If Not CheckError() Then Exit Function
    
    m_strStep = "MTBillingReRun.Prepare"
    objReRun.Prepare Service.Properties("Comment").Value
    If Not CheckError() Then Exit Function
    
    m_strStep = "MTBillingReRun.Extract"
    objReRun.Extract Service.Properties("Comment").Value
    If Not CheckError() Then Exit Function
    OK_Click = TRUE
    
END FUNCTION

PRIVATE FUNCTION CheckError() ' As Boolean


    CheckError = FALSE
    If(Err.Number)Then 
        EventArg.Error.Save Err 
        EventArg.Error.Description = EventArg.Error.Description & "; Step=" & m_strStep
        Err.Clear 
        Exit Function
    End If        
    CheckError = TRUE
    
    ' Wait a second to be sure that all action hace a different dt_action
    Dim objWinApi
    Set objWinApi = Server.CreateObject(CWindows)
    objWinApi.Sleep 1
END FUNCTION

%>

