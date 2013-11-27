<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
<%
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
'http://localhost/mam/default/dialog/AudioConf.Adjustment.asp?PIType=AudioConfConn&IdSession=10005
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
<!-- #INCLUDE FILE="../../default/lib/MTProductCatalog.Library.asp" -->
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" -->

<%

' Mandatory

Form.RouteTo			  =  "DefaultPVBAdjustment2.asp"
'Form.Modal = TRUE

mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: Form_Initialize
' PARAMETERS	:
' DESCRIPTION :
' RETURNS		  : Returns TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean

    Form("InitialTemplate") = Form.HTMLTemplateSource  ' Save the initial template so we can use it to render a new dynamic template later
    
    'mdm_GetDictionary().Add "TEXT_ADJUSTMENT_DIALOG_TITLE","Adjustment " & Request.QueryString("PIType") & " " &  Request.QueryString("IdSession")
    
    On Error Resume Next    
    LoadAdjustmentInstances Request.QueryString("PIType"), Request.QueryString("IdSession")
    If Err.Number Then
        EventArg.Error.Save Err
        Form_DisplayErrorMessage(EventArg) ' As Boolean
        mdm_TerminateDialog
        Response.End
    End If 
    LoadMSIXPropertyFromAdjutmentInputs
    CopyAdjustmentInstanceValuesToService
    Service.LoadJavaScriptCode
    
    Form("Calculated") = FALSE
	  Form_Initialize    = Form_Refresh(EventArg) 
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  Form_Refresh
' PARAMETERS:  EventArg
' DESCRIPTION:  Loads the DynamicCapabilities using the initial saved template
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION Form_Refresh(EventArg) ' As Boolean

    Form.HTMLTemplateSource = Replace(Form("InitialTemplate"),"[ADJUSTMENT_HTML]",RenderAdjustmentHTMLSnippet())
    Form_Refresh           = TRUE
END FUNCTION

PUBLIC FUNCTION OK_Click(EventArg)

  OK_Click = TRuE
  Service.Properties.Enabled = FALSE
END FUNCTION


PRIVATE FUNCTION LoadAdjustmentInstances(strPriceAbleItemName,strIDSessionCSVList)

  LoadAdjustmentInstances = FALSE
  
  Dim AdjustmentCol, PC, Col, IdSessionArray, IdSession, AdjustmentInstances, SupportedTypes, AdjustmentType, PIType, objAdjInstanceProp
  
  Set AdjustmentCol = CreateObject("MetraTech.MTAdjustmentTypeCol")
  set PC            = GetProductCatalogObject()  
  Set PIType        = PC.GetPriceableItemByName(strPriceAbleItemName)
  Set Col           = CreateObject("MetraTech.MTCollectionEx")
  IdSessionArray    = Split(strIDSessionCSVList,",")
  
  For Each IdSession In IdSessionArray
      Col.Add(CLng(IdSession))
  Next
  
  Set AdjustmentInstances = AdjustmentCol.CreateAdjustmentInstance(Col,PIType.ID)  
  set SupportedTypes      = AdjustmentInstances(0).SupportedAdjustmentTypes

  Service.log "The following adjustment types are supported:"
  For Each AdjustmentType in SupportedTypes
      Service.log AdjustmentType.name & " - " & AdjustmentType.Description
  Next
  
  ' Defaulting to first adjustment type
  set AdjustmentType = AdjustmentInstances(0).SupportedAdjustmentTypes(0)

  ' populate the properties on the instance
  AdjustmentType.PopulateInstanceProps(AdjustmentInstances)
  
  Set Form("AdjustmentInstances") = AdjustmentInstances
  Set Form("AdjustmentType")      = AdjustmentType
  
  Form("AdjustmentInstances").Item(0).Inputs("Minutes").Value = 0
  
  LoadAdjustmentInstances = TRUE
END FUNCTION

PUBLIC FUNCTION CopyAdjustmentInstanceValuesToService()
  
  Dim objAdjInstanceProp
  
  CopyAdjustmentInstanceValuesToService = FALSE
  
  For Each objAdjInstanceProp In Form("AdjustmentInstances").Item(0).Inputs
  
      If objAdjInstanceProp.PropertyGroup <> "internal" Then 
      
        If Service.Properties.Exist(objAdjInstanceProp.Name) Then
        
            Service(objAdjInstanceProp.Name).Value = objAdjInstanceProp.Value
        End If
      End If        
  Next
  
  For Each objAdjInstanceProp In Form("AdjustmentInstances").Item(0).Outputs
  
      If objAdjInstanceProp.PropertyGroup <> "internal" Then 
      
        If Service.Properties.Exist(objAdjInstanceProp.Name) Then
            On Error Resume Next
            Service(objAdjInstanceProp.Name).Value = objAdjInstanceProp.Value
            Err.Clear
            On Error Goto 0
        End If
      End If        
  Next  
  CopyAdjustmentInstanceValuesToService = TRUE
END FUNCTION


PUBLIC FUNCTION CopyServiceValuesToAdjustmentInstance()
  
  Dim objMSIXProperty
  
  CopyServiceValuesToAdjustmentInstance = FALSE
  
  For Each objMSIXProperty In Service.Properties
  
      If objMSIXProperty.Tag="Input" Then
      
          Form("AdjustmentInstances").Item(0).Inputs(objMSIXProperty.Name).Value = objMSIXProperty.Value
      End If
  Next
  CopyServiceValuesToAdjustmentInstance = TRUE
END FUNCTION

PUBLIC FUNCTION RenderAdjustmentHTMLSnippet()
  
  Dim objAdjInstanceProp, strHTML, objPreProcessor

  CONST INPUT_PROPERTY_HTML  = "<TD><MDMLABEL Name='[PROPERTY_NAME]' Type='Caption'></MDMLABEL> : </TD><TD><INPUT type='text' class='clsInputBox' size='10' Name='[PROPERTY_NAME]'></TD>[CRLF]"
  CONST OUTPUT_PROPERTY_HTML = "<TD><MDMLABEL Name='[PROPERTY_NAME]' Type='Caption'></MDMLABEL> : </TD><TD><MDMLABEL Name='[PROPERTY_NAME]' Type='Value'></MDMLABEL></TD>[CRLF]"
  
  Set objPreProcessor = mdm_CreateObject(CPreProcessor)
  objPreProcessor.Add "CRLF" , vbNewLine
  
  For Each objAdjInstanceProp In Form("AdjustmentInstances").Item(0).Inputs
  
      objPreProcessor.Add "PROPERTY_NAME"   , objAdjInstanceProp.Name
      If objAdjInstanceProp.PropertyGroup <> "internal" then
          strHTML = strHTML & objPreProcessor.Process(INPUT_PROPERTY_HTML,"[","]")
      Else
          Select Case UCASE(objAdjInstanceProp.Name)
            Case "++"
              strHTML = strHTML & objPreProcessor.Process(OUTPUT_PROPERTY_HTML,"[","]")
          End Select         
      End If
  Next
  
  For Each objAdjInstanceProp In Form("AdjustmentInstances").Item(0).OutPuts
  
      If objAdjInstanceProp.PropertyGroup <> "internal" then

          objPreProcessor.Add "PROPERTY_NAME"   , objAdjInstanceProp.Name
          strHTML = strHTML & objPreProcessor.Process(OUTPUT_PROPERTY_HTML,"[","]")
      End If
  Next  
  RenderAdjustmentHTMLSnippet = strHTML 
END FUNCTION  


PUBLIC FUNCTION LoadMSIXPropertyFromAdjutmentInputs()
  
  Dim objAdjInstanceProp, strHTML, objPreProcessor
  
  LoadMSIXPropertyFromAdjutmentInputs = FALSE
  
  For Each objAdjInstanceProp In Form("AdjustmentInstances").Item(0).Inputs

      If objAdjInstanceProp.PropertyGroup <> "internal" then 
          Service.Properties.Add objAdjInstanceProp.Name, "String" , 255 , False, ""
          Service.Properties(objAdjInstanceProp.Name).Tag = "Input"
      End If          
  Next
  
  For Each objAdjInstanceProp In Form("AdjustmentInstances").Item(0).OutPuts
  
      If objAdjInstanceProp.PropertyGroup <> "internal" then 
      
          Service.Properties.Add objAdjInstanceProp.Name, "String" , 255 , False, ""
          Service.Properties(objAdjInstanceProp.Name).Tag = "Output"
      End If
  Next
  LoadMSIXPropertyFromAdjutmentInputs = TRUE
END FUNCTION  


PUBLIC FUNCTION Calculate_Click(EventArg) ' As Boolean)

    CopyServiceValuesToAdjustmentInstance
    Form("AdjustmentType").Calculate Form("AdjustmentInstances")
    CopyAdjustmentInstanceValuesToService
    Form("Calculated") = TRUE
    Calculate_Click = TRUE
END FUNCTION


PUBLIC FUNCTION OK_Click(EventArg) ' As Boolean)
    
    Calculate_Click EventArg ' Calculate in case
    
    'Form("AdjustmentType").SaveAdjustments Form("AdjustmentInstances")
    OK_Click = TRUE
END FUNCTION

%>

