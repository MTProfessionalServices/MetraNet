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
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
'
' TODO:  * Support N number of filters - or reuse deleted ones 
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/mdm.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MomLibrary.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/FrameWork/CFrameWork.Class.asp" -->
<%
Dim m_strStep

Server.ScriptTimeout = 60 * 20

Form.Version        = MDM_VERSION
Form.RouteTo        = "BackOutRerun.BackoutStep2.asp"
Form.ErrorHandler               = TRUE  

mdm_Main ' invoke the mdm framework

' This value determines the number of 'attempts' the user gets to set the filter 
' for each filter type
Const MAX_NUMBER_OF_DYNAMIC_PROPERTIES = 15  

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION: Form_Initialize
' PARAMETERS:
' DESCRIPTION:
' RETURNS: Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean

    Framework.AssertCourseCapability "Manage Backouts and Reruns", EventArg

    Dim i
    
    Form("InitialTemplate") = Form.HTMLTemplateSource  ' Save the initial template so we can use it to render a new dynamic template later
        
    Service.Properties.Add "Description"      , MSIXDEF_TYPE_STRING   , 255 , TRUE,  Empty
    Service.Properties.Add "SelectionMethod"  , MSIXDEF_TYPE_STRING   , 255 , TRUE,  "FILTER"
    Service.Properties.Add "SessionIDs"       , MSIXDEF_TYPE_STRING   ,   0 , FALSE, Empty
    Service.Properties.Add "BeginDatetime"    , MSIXDEF_TYPE_TIMESTAMP, 0   , FALSE, Empty
    Service.Properties.Add "EndDatetime"      , MSIXDEF_TYPE_TIMESTAMP, 0   , FALSE, Empty
    Service.Properties.Add "BatchID"          , MSIXDEF_TYPE_STRING   , 255 , FALSE, Empty    
    Service.Properties.Add "IntervalID"       , MSIXDEF_TYPE_INT32  , 255 , FALSE, Empty    
    
    ' Support a MAX number of property values
    For i = 1 to MAX_NUMBER_OF_DYNAMIC_PROPERTIES 
      Service.Properties.Add "ServiceDefinition"    & i, MSIXDEF_TYPE_STRING   , 255 , FALSE, Empty
      Service.Properties.Add "ProductDefinition"    & i, MSIXDEF_TYPE_STRING   , 255 , FALSE, Empty
      Service.Properties.Add "ServiceProperty"      & i, MSIXDEF_TYPE_STRING   , 255 , FALSE, Empty
      Service.Properties.Add "ProductProperty"      & i, MSIXDEF_TYPE_STRING   , 255 , FALSE, Empty
      Service.Properties.Add "ServicePropertyValue" & i, MSIXDEF_TYPE_STRING   , 255 , FALSE, Empty
      Service.Properties.Add "ProductPropertyValue" & i, MSIXDEF_TYPE_STRING   , 255 , FALSE, Empty
      Service.Properties.Add "AccountProperty"      & i, MSIXDEF_TYPE_STRING   , 255 , FALSE, Empty
      Service.Properties.Add "AccountOperator"      & i, MSIXDEF_TYPE_STRING   , 255 , FALSE, Empty
      Service.Properties.Add "AccountValue"         & i, MSIXDEF_TYPE_STRING   , 255 , FALSE, Empty
      
      Service.Properties("ServiceProperty" & i).Tag      = "HIDE_VALUE"
      Service.Properties("ProductProperty" & i).Tag      = "HIDE_VALUE"
      Service.Properties("ServicePropertyValue" & i).Tag = "HIDE_VALUE"
      Service.Properties("ProductPropertyValue" & i).Tag = "HIDE_VALUE"
      Service.Properties("AccountValue" & i).Tag         = "HIDE_VALUE"
    Next

    ' Set Captions
    Service.Properties("Description").Caption = mom_GetDictionary("TEXT_Description1")
    Service.Properties("SelectionMethod").Caption = mom_GetDictionary("TEXT_How_will_you_identify_the_transactions_to_be_rerun") 
    Service.Properties("BatchID").Caption = mom_GetDictionary("TEXT_BatchId")
    
    LoadDynamicEnumType()

    ' Clear the page we return to
    Session("BACKOUTRERUN_CURRENT_RETURNURL")=""   

    ' Is this backout tied to the batch backout screen?
    If Len(request("batchid")) > 0 Then
      Service.Properties("BatchId").Value = request("BatchId")
      Session("BACKOUTRERUN_CURRENT_RETURNURL") = request("ReturnUrl")
      Service.Properties("Description").Value = request("batchcomment")
      If Ok_Click(EventArg) Then
        mdm_TerminateDialogAndExecuteDialog Form.RouteTo
        Form_Initialize = False
        Exit Function
      End If
    End If

    ' These form variables are used to keep track of the dynamic properties that are showing
    Form("NumberOfVisibleServiceDefs").Value  = 0
    Form("NumberOfVisibleProductDefs").Value  = 0
    Form("NumberOfVisibleAccountProps").Value = 0        

    mdm_IncludeCalendar
    Service.LoadJavaScriptCode
    
    Form_Initialize = DynamicCapabilites(EventArg) ' Load the correct template for the dynmaic properties
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  Form_Refresh
' PARAMETERS:  EventArg
' DESCRIPTION:  Loads the DynamicProperties using the initial saved template
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION Form_Refresh(EventArg) ' As Boolean
	Form_Refresh = DynamicCapabilites(EventArg)
  ProductView.LoadJavaScriptCode
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  DynamicCapabilites
' PARAMETERS:  EventArg
' DESCRIPTION:  This function determines what should be placed in the dialog template based on the atomic capabilities found
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION DynamicCapabilites(EventArg)
	Dim strHTML
  Dim nCount

  on error resume next

  ' Setup initial template
  Form.HTMLTemplateSource = Form("InitialTemplate")
	
  ' Debug info
  'strHTML = strHTML & "<span style='background-color:#ffffcc;width:150px;border:solid black 1px;padding:5px;'><b>Debug Info:</b><br>"
  'strHTML = strHTML & "# ServiceDef: " & Form("NumberOfVisibleServiceDefs").Value & "<br>"
  'strHTML = strHTML & "# ProductDef: " & Form("NumberOfVisibleProductDefs").Value & "<br>"
  'strHTML = strHTML & "# AccountProp: " & Form("NumberOfVisibleAccountProps").Value & "<br>"
  'strHTML = strHTML & "Selection Method:" & Service.Properties("SelectionMethod").Value & "<br>"    
  'strHTML = strHTML & "</span>"
  
  For nCount = 1 to CLng(Form("NumberOfVisibleProductDefs").Value)
    If Service.Properties("ProductDefinition" & nCount).Tag <> "DELETED" Then
      strHTML = strHTML & "<tr>"
      strHTML = strHTML & "  <td nowrap align='right'>" & mom_GetDictionary("TEXT_Product_View") & "&nbsp;<select onchange=""mdm_RefreshDialogUserCustom('RefreshPV','" & nCount & "');"" name='ProductDefinition" & nCount & "' class='clsInputBox'></select></td>"
      If Service.Properties("ProductProperty" & nCount).Tag <> "HIDE_VALUE" Then
        strHTML = strHTML & "  <td nowrap>&nbsp;&nbsp;" & mom_GetDictionary("TEXT_Property") & ":&nbsp;<select onchange=""mdm_RefreshDialogUserCustom('RefreshPVProperty','" & nCount & "');""  name='ProductProperty" & nCount & "' class='clsInputBox'></select></td>"
      End If     
      If Service.Properties("ProductPropertyValue" & nCount).Tag = "HIDE_VALUE" Then                    
          strHTML = strHTML & "  <td nowrap>&nbsp;</td>"      
      Else
          strHTML = strHTML & "  <td nowrap>=</td>"
      End If    
      Select Case Service.Properties("ProductPropertyValue" & nCount).PropertyType
        Case "ENUM"
          strHTML = strHTML & "  <td nowrap>" & mom_GetDictionary("TEXT_Value") & " (" & Service.Properties("ProductPropertyValue" & nCount).PropertyType &"):<select name='ProductPropertyValue" & nCount & "' class='clsInputBox'></td>" 
        Case "TIMESTAMP"
          strHTML = strHTML & "  <td nowrap>" & mom_GetDictionary("TEXT_Value") & " (" & Service.Properties("ProductPropertyValue" & nCount).PropertyType &"):<input type=text' name='ProductPropertyValue" & nCount & "' size='25' class='clsInputBox'>" 
          strHTML = strHTML & "  <a href=""#"" onClick=""getCalendarForTimeOpt(document.mdm.ProductPropertyValue" & nCount & ",'',false);return false""><img src='/mom/default/localized/en-us/images/popupcalendar.gif' width=16 height=16 border=0 alt=''></a></td>"
        Case Else
          If Service.Properties("ProductPropertyValue" & nCount).Tag = "HIDE_VALUE" Then
            strHTML = strHTML & "  <td nowrap>&nbsp;</td>"           
          Else
            strHTML = strHTML & "  <td nowrap>" & mom_GetDictionary("TEXT_Value") & " (" & Service.Properties("ProductPropertyValue" & nCount).PropertyType &"):<input type=text' name='ProductPropertyValue" & nCount & "' size='25' class='clsInputBox'></td>" 
          End If  
      End Select 
      strHTML = strHTML & "	 <td nowrap><button onclick='mdm_RefreshDialogUserCustom(this,""" & nCount & """);' name='RemovePV' Class='clsButtonBlueSmall'>" & mom_GetDictionary("TEXT_Remove") & "</button></td>"
      strHTML = strHTML & "</tr>"
      If (nCount <> CLng(Form("NumberOfVisibleProductDefs").Value)) or (CLng(Form("NumberOfVisibleAccountProps").Value) <> 0) or (CLng(Form("NumberOfVisibleServiceDefs").Value) <> 0) Then 
        strHTML = strHTML & "<tr><td colspan='8' align='center'><font color='green'>- AND -</font></td></tr>"    
      End If    
    End If
  Next		
  For nCount = 1 to CLng(Form("NumberOfVisibleServiceDefs").Value)
    If Service.Properties("ServiceDefinition" & nCount).Tag <> "DELETED" Then  
      strHTML = strHTML & "<tr>"
      strHTML = strHTML & "  <td nowrap align='right'>" & mom_GetDictionary("TEXT_Service_Definition") & "&nbsp;<select onchange=""mdm_RefreshDialogUserCustom('RefreshSD','" & nCount & "');""  name='ServiceDefinition" & nCount & "' class='clsInputBox'></select></td>"
      If Service.Properties("ServiceProperty" & nCount).Tag <> "HIDE_VALUE" Then
        strHTML = strHTML & "  <td nowrap>&nbsp;&nbsp;" & mom_GetDictionary("TEXT_Property") & ":&nbsp;<select onchange=""mdm_RefreshDialogUserCustom('RefreshSDProperty','" & nCount & "');"" name='ServiceProperty" & nCount & "' class='clsInputBox'></td>"
      End If  
      If Service.Properties("ServicePropertyValue" & nCount).Tag = "HIDE_VALUE" Then                    
          strHTML = strHTML & "  <td nowrap>&nbsp;</td>"      
      Else
          strHTML = strHTML & "  <td nowrap>=</td>"
      End If  

      Select Case Service.Properties("ServicePropertyValue" & nCount).PropertyType
        Case "ENUM"
          strHTML = strHTML & "  <td nowrap>" & mom_GetDictionary("TEXT_Value") & " (" & Service.Properties("ServicePropertyValue" & nCount).PropertyType &"):<select name='ServicePropertyValue" & nCount & "' class='clsInputBox'></td>" 
        Case "TIMESTAMP"
          strHTML = strHTML & "  <td nowrap>" & mom_GetDictionary("TEXT_Value") & " (" & Service.Properties("ServicePropertyValue" & nCount).PropertyType &"):<input type=text' name='ServicePropertyValue" & nCount & "' size='25' class='clsInputBox'>" 
          strHTML = strHTML & "  <a href=""#"" onClick=""getCalendarForTimeOpt(document.mdm.ServicePropertyValue" & nCount & ", '', false);return false""><img src='/mom/default/localized/en-us/images/popupcalendar.gif' width=16 height=16 border=0 alt=''></a></td>"
        Case Else
          If Service.Properties("ServicePropertyValue" & nCount).Tag = "HIDE_VALUE" Then
            strHTML = strHTML & "  <td nowrap>&nbsp;</td>"           
          Else
            strHTML = strHTML & "  <td nowrap>" & mom_GetDictionary("TEXT_Value") & " (" & Service.Properties("ServicePropertyValue" & nCount).PropertyType &"):<input type=text' name='ServicePropertyValue" & nCount & "' size='25' class='clsInputBox'></td>" 
          End If
      End Select  
      strHTML = strHTML & "	 <td nowrap><button onclick='mdm_RefreshDialogUserCustom(this,""" & nCount & """);' name='RemoveSD' Class='clsButtonBlueSmall'>" & mom_GetDictionary("TEXT_Remove") & "</button></td>"      
      strHTML = strHTML & "</tr>"
      If (nCount <> CLng(Form("NumberOfVisibleServiceDefs").Value)) or (CLng(Form("NumberOfVisibleAccountProps").Value) <> 0) Then 
        strHTML = strHTML & "<tr><td colspan='8' align='center'><font color='green'>- AND -</font></td></tr>"    
      End If  
    End If  
  Next		
  For nCount = 1 to CLng(Form("NumberOfVisibleAccountProps").Value)
    If Service.Properties("AccountProperty" & nCount).Tag <> "DELETED" Then    
      strHTML = strHTML & "<tr>"
      strHTML = strHTML & "  <td nowrap align='right'>" & mom_GetDictionary("TEXT_Account_Property_Name") & "&nbsp;<select onchange=""mdm_RefreshDialogUserCustom('RefreshAccountProperty','" & nCount & "');"" name='AccountProperty" & nCount & "' class='clsInputBox'></select></td>"
      strHTML = strHTML & "  <td nowrap>&nbsp;</td>"
      If Service.Properties("AccountValue" & nCount).Tag = "HIDE_VALUE" Then
        strHTML = strHTML & "  <td nowrap>&nbsp;</td><td nowrap>&nbsp;</td>"
      Else
        strHTML = strHTML & "  <td nowrap><select name='AccountOperator" & nCount & "' class='clsInputBox'></td>"
        Select Case Service.Properties("AccountValue" & nCount).PropertyType
          Case "ENUM"
            strHTML = strHTML & "  <td nowrap>" & mom_GetDictionary("TEXT_Value") & " (" & Service.Properties("AccountValue" & nCount).PropertyType &"):<select name='AccountValue" & nCount & "' class='clsInputBox'></td>" 
          Case "TIMESTAMP"
            strHTML = strHTML & "  <td nowrap>" & mom_GetDictionary("TEXT_Value") & " (" & Service.Properties("AccountValue" & nCount).PropertyType &"):<input type='text' name='AccountValue" & nCount & "' size='25' class='clsInputBox'>" 
            strHTML = strHTML & "  <a href=""#"" onClick=""getCalendarForTimeOpt(document.mdm.AccountValue" & nCount & ", '', false);return false""><img src='/mom/default/localized/en-us/images/popupcalendar.gif' width=16 height=16 border=0 alt=''></a></td>"            
          Case Else
            strHTML = strHTML & "  <td nowrap>" & mom_GetDictionary("TEXT_Value") & " (" & Service.Properties("AccountValue" & nCount).PropertyType &"):<input type='text' name='AccountValue" & nCount & "' size='25' class='clsInputBox'></td>"  
        End Select 
      End If
      strHTML = strHTML & "	 <td nowrap><button onclick='mdm_RefreshDialogUserCustom(this,""" & nCount & """);' name='RemoveAccount' Class='clsButtonBlueSmall'>" & mom_GetDictionary("TEXT_Remove") & "</button></td>"
      strHTML = strHTML & "</tr>"
      If nCount <> CLng(Form("NumberOfVisibleAccountProps").Value) Then
        strHTML = strHTML & "<tr><td colspan='8' align='center'><font color='green'>- AND -</font></td></tr>"    
      End If
    End If  
  Next		
	
  'If UCase(Service.Properties("SelectionMethod")) = "FILTER" Then
  ' Form.HTMLTemplateSource =  Replace(Form.HTMLTemplateSource, "<DYNAMIC_JAVASCRIPT/>", _
  '          "<script language='JavaScript1.2'>HideAll();document.getElementById('DivUserDefined').style.display='block';</script>")
  'End IF
	Form.HTMLTemplateSource = Replace(Form.HTMLTemplateSource, "<DYNAMIC_FILTER/>", strHTML)
  
  DynamicCapabilites = TRUE

END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : LoadDynamicEnumType
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION LoadDynamicEnumType()
    Dim objDyn, objPV, objPVS, i, defname
 
    ' Product View 
    Dim prodDefCollection
    Set prodDefCollection = CreateObject("MetraTech.Pipeline.ProductViewDefinitionCollection")
    Set objDyn = mdm_CreateObject(CVariables)    
    objDyn.Add "", "", , , " "
    For Each defname in  prodDefCollection.SortedNames
        objDyn.Add defname, defname, , ,defname    
    Next
    For i = 1 to MAX_NUMBER_OF_DYNAMIC_PROPERTIES
      Service.Properties("ProductDefinition" & i).AddValidListOfValues objDyn
    Next
       
    ' Service Def   
    Dim serviceDefCollection
    Set serviceDefCollection = CreateObject("MetraTech.Pipeline.ServiceDefinitionCollection")
    Set objDyn = mdm_CreateObject(CVariables)    
    objDyn.Add "", "", , , " "
    For Each defname in  serviceDefCollection.SortedNames
        objDyn.Add defname, defname, , ,defname    
    Next
    For i = 1 to MAX_NUMBER_OF_DYNAMIC_PROPERTIES
      Service.Properties("ServiceDefinition" & i).AddValidListOfValues objDyn
    Next
    
    ' Account Operators
		Set objDyn = mdm_CreateObject(CVariables)					
	  objDyn.Add "equal", MTDECIMALCAPABILITY_OPERATOR_TYPE_EQUAL, , , "="
	  objDyn.Add "notequal", MTDECIMALCAPABILITY_OPERATOR_TYPE_NOT_EQUAL, , , "<>"
	  objDyn.Add "greater", MTDECIMALCAPABILITY_OPERATOR_TYPE_GREATER, , , ">"
	  objDyn.Add "greaterequal", MTDECIMALCAPABILITY_OPERATOR_TYPE_GREATER_EQUAL, , , ">="
	  objDyn.Add "less", MTDECIMALCAPABILITY_OPERATOR_TYPE_LESS, , , "<"																														
	  objDyn.Add "lessequal", MTDECIMALCAPABILITY_OPERATOR_TYPE_LESS_EQUAL, , , "<="																														
    For i = 1 to MAX_NUMBER_OF_DYNAMIC_PROPERTIES
        Service.Properties("AccountOperator" & i).AddValidListOfValues objDyn	
    Next      
    
    ' Account Properties
    Set objDyn = mdm_CreateObject(CVariables)    
    Dim serviceDef
    Set serviceDef = serviceDefCollection.GetServiceDefinition(Replace(Replace(mom_GetDictionary("ACCOUNT_CREATION_MSIXDEF_FILE_NAME"),"\","/"), ".msixdef", ""))
    Dim prop
    objDyn.Add "", "", , , " "
    For Each prop in serviceDef.SortedProperties
        objDyn.Add prop.Name, prop.Name, , , prop.DisplayName 
    Next
    For i = 1 to MAX_NUMBER_OF_DYNAMIC_PROPERTIES
        Service.Properties("AccountProperty" & i).AddValidListOfValues objDyn
    Next   

    LoadDynamicEnumType = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  RemovePV_Click
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION RemovePV_Click(EventArg) ' As Boolean
	
  Dim RemoveID
	RemoveID = mdm_UIValue("mdmUserCustom")
  
  Service.Properties("ProductDefinition" & RemoveID).Tag = "DELETED"
  
	RemovePV_Click = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  RemoveSD_Click
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION RemoveSD_Click(EventArg) ' As Boolean
	
  Dim RemoveID
	RemoveID = mdm_UIValue("mdmUserCustom")
  
  Service.Properties("ServiceDefinition" & RemoveID).Tag = "DELETED"
  
	RemoveSD_Click = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  RemoveAccount_Click
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION RemoveAccount_Click(EventArg) ' As Boolean
	
  Dim RemoveID
	RemoveID = mdm_UIValue("mdmUserCustom")
  
  Service.Properties("AccountProperty" & RemoveID).Tag = "DELETED"
  
	RemoveAccount_Click = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  RefreshPV_Click
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION RefreshPV_Click(EventArg) ' As Boolean
  Dim RefreshID
  Dim colPV
  Dim PVDefinition
  Dim prop
  Dim objDyn

  RefreshID = mdm_UIValue("mdmUserCustom")
    
  If Service.Properties("ProductDefinition" & RefreshID).Value = "" Then
    Service.Properties("ProductProperty" & RefreshID).Tag = "HIDE_VALUE"
    Service.Properties("ProductProperty" & RefreshID).SetPropertyType("STRING")
    Service.Properties("ProductProperty" & RefreshID).Value = ""    
    RefreshPV_Click = TRUE
    Exit Function
  Else
    Service.Properties("ProductProperty" & RefreshID).Tag = "SHOW_VALUE"
  End If
  
  Set colPV = Server.CreateObject("MetraTech.Pipeline.ProductViewDefinitionCollection")
  Set PVDefinition = colPV.GetProductViewDefinition(Service.Properties("ProductDefinition" & RefreshID).Value)
  
  Set objDyn = mdm_CreateObject(CVariables)    
  objDyn.Add "", "", , , ".: All in Product View :."
  For Each prop in PVDefinition.SortedProperties
     objDyn.Add prop.Name, prop.Name, , , prop.DisplayName
  Next
  
  Service.Properties("ProductProperty" & RefreshID).AddValidListOfValues objDyn
  Service.Properties("ProductPropertyValue" & RefreshID).Tag = "HIDE_VALUE"
  Service.Properties("ProductPropertyValue" & RefreshID).SetPropertyType("STRING")  
  Service.Properties("ProductPropertyValue" & RefreshID).Value = ""
 
	RefreshPV_Click = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  RefreshPVProperty_Click
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION RefreshPVProperty_Click(EventArg) ' As Boolean
  Dim RefreshID
  Dim colPV
  Dim PVDefinition
  Dim prop
  Dim objDyn

  RefreshID = mdm_UIValue("mdmUserCustom")

  ' Clear value
  Service.Properties("ProductPropertyValue" & RefreshID).SetPropertyType("STRING")
  Service.Properties("ProductPropertyValue" & RefreshID).Value = ""
    
  ' Check to see if we are on .: All Properties :.
  If Service.Properties("ProductProperty" & RefreshID).Value = "" Then
    Service.Properties("ProductPropertyValue" & RefreshID).Tag = "HIDE_VALUE"
    RefreshPVProperty_Click = TRUE
    Exit Function
  End If
    
  Set colPV = Server.CreateObject("MetraTech.Pipeline.ProductViewDefinitionCollection")
  Set PVDefinition = colPV.GetProductViewDefinition(Service.Properties("ProductDefinition" & RefreshID).Value)
  
  ' Set product view definition property type in - so we know how to draw the property field
  Dim objProperty
  Set objProperty = PVDefinition.GetProperty(Service.Properties("ProductProperty" & RefreshID).Value)
  Select Case objProperty.DataType
    Case PROP_TYPE_ENUM
      Set objDyn = mdm_CreateObject(CVariables)    
      For Each prop in objProperty.Enumerators
        objDyn.Add prop.Name, prop.Name, , , prop.DisplayName
      Next
      Service.Properties("ProductPropertyValue" & RefreshID).AddValidListOfValues objDyn
      Call Service.Properties("ProductPropertyValue" & RefreshID).SetPropertyType("ENUM", objProperty.EnumSpace, objProperty.EnumType)
      
    Case PROP_TYPE_DATETIME, PROP_TYPE_TIME
      Service.Properties("ProductPropertyValue" & RefreshID).SetPropertyType("TIMESTAMP")
      Service.Properties("ProductPropertyValue" & RefreshID).Length = objProperty.Length

    Case PROP_TYPE_INTEGER
      Service.Properties("ProductPropertyValue" & RefreshID).SetPropertyType("INT32")
          
    Case PROP_TYPE_DOUBLE
      Service.Properties("ProductPropertyValue" & RefreshID).SetPropertyType("DOUBLE")
      
    Case PROP_TYPE_DECIMAL
      Service.Properties("ProductPropertyValue" & RefreshID).SetPropertyType("DECIMAL")
            
    Case Else
      Service.Properties("ProductPropertyValue" & RefreshID).SetPropertyType("STRING")
      Service.Properties("ProductPropertyValue" & RefreshID).Length = objProperty.Length
  End Select

  Service.Properties("ProductPropertyValue" & RefreshID).Tag = "SHOW_VALUE"
   
	RefreshPVProperty_Click = TRUE
END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  RefreshSD_Click
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION RefreshSD_Click(EventArg) ' As Boolean
  Dim RefreshID
  Dim colSD
  Dim ServiceDefinition
  Dim prop
  Dim objDyn

  RefreshID = mdm_UIValue("mdmUserCustom")
    
  If Service.Properties("ServiceDefinition" & RefreshID).Value = "" Then
    Service.Properties("ServiceProperty" & RefreshID).Tag = "HIDE_VALUE"
    Service.Properties("ServiceProperty" & RefreshID).SetPropertyType("STRING")
    Service.Properties("ServiceProperty" & RefreshID).Value = ""
	  RefreshSD_Click = TRUE    
    Exit Function
  Else
    Service.Properties("ServiceProperty" & RefreshID).Tag = "SHOW_VALUE"
  End If
  
  Set colSD = Server.CreateObject("MetraTech.Pipeline.ServiceDefinitionCollection")
  Set ServiceDefinition = colSD.GetServiceDefinition(Service.Properties("ServiceDefinition" & RefreshID).Value)
  
  Set objDyn = mdm_CreateObject(CVariables)    
  objDyn.Add "", "", , , ".: All in Service Definition :."    
  For Each prop in ServiceDefinition.SortedProperties
     objDyn.Add prop.Name, prop.Name, , , prop.DisplayName
  Next
  
  Service.Properties("ServiceProperty" & RefreshID).AddValidListOfValues objDyn

  Service.Properties("ServicePropertyValue" & RefreshID).Tag = "HIDE_VALUE"
  Service.Properties("ServicePropertyValue" & RefreshID).SetPropertyType("STRING")
  Service.Properties("ServicePropertyValue" & RefreshID).Value = ""

	RefreshSD_Click = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  RefreshSDProperty_Click
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION RefreshSDProperty_Click(EventArg) ' As Boolean
  Dim RefreshID
  Dim colSD
  Dim ServiceDefinition
  Dim prop
  Dim objDyn

  RefreshID = mdm_UIValue("mdmUserCustom")
  Set colSD = Server.CreateObject("MetraTech.Pipeline.ServiceDefinitionCollection")
  Set ServiceDefinition = colSD.GetServiceDefinition(Service.Properties("ServiceDefinition" & RefreshID).Value)

  ' Clear value
  Service.Properties("ServicePropertyValue" & RefreshID).SetPropertyType("STRING")    
  Service.Properties("ServicePropertyValue" & RefreshID).Value = ""
    
  ' Check to see if we are on .: All Properties :.
  If Service.Properties("ServiceProperty" & RefreshID).Value = "" Then
    Service.Properties("ServicePropertyValue" & RefreshID).Tag = "HIDE_VALUE"
    RefreshSDProperty_Click = TRUE
    Exit Function
  End If
    
  ' Set service definition property type in .tag field - so we know how to draw the property field
  Dim objProperty
  Set objProperty = ServiceDefinition.GetProperty(Service.Properties("ServiceProperty" & RefreshID).Value)
  Select Case objProperty.DataType
    Case PROP_TYPE_ENUM
      Set objDyn = mdm_CreateObject(CVariables)    
      For Each prop in objProperty.Enumerators
        objDyn.Add prop.Name, prop.Name, , , prop.DisplayName
      Next
      Service.Properties("ServicePropertyValue" & RefreshID).AddValidListOfValues objDyn
      Call Service.Properties("ServicePropertyValue" & RefreshID).SetPropertyType("ENUM", objProperty.EnumSpace, objProperty.EnumType)  

    Case PROP_TYPE_DATETIME, PROP_TYPE_TIME
      Service.Properties("ServicePropertyValue" & RefreshID).SetPropertyType("TIMESTAMP")
      Service.Properties("ServicePropertyValue" & RefreshID).Length =objProperty.Length

    Case PROP_TYPE_INTEGER
      Service.Properties("ServicePropertyValue" & RefreshID).SetPropertyType("INT32")
          
    Case PROP_TYPE_DOUBLE
      Service.Properties("ServicePropertyValue" & RefreshID).SetPropertyType("DOUBLE")
      
    Case PROP_TYPE_DECIMAL
      Service.Properties("ServicePropertyValue" & RefreshID).SetPropertyType("DECIMAL")
            
    Case Else
      Service.Properties("ServicePropertyValue" & RefreshID).SetPropertyType("STRING")
      Service.Properties("ServicePropertyValue" & RefreshID).Length = objProperty.Length
  End Select

  Service.Properties("ServicePropertyValue" & RefreshID).Tag = "SHOW_VALUE"  
        
	RefreshSDProperty_Click = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  RefreshAccountProperty_Click
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION RefreshAccountProperty_Click(EventArg) ' As Boolean
  Dim RefreshID
  Dim colSD
  Dim AccountDefinition
  Dim prop
  Dim objDyn

  RefreshID = mdm_UIValue("mdmUserCustom")

  ' Clear value
  Service.Properties("AccountValue" & RefreshID).SetPropertyType("STRING")
  Service.Properties("AccountValue" & RefreshID).Value = ""

  If Service.Properties("AccountProperty" & RefreshID).Value = "" Then
    Service.Properties("AccountProperty" & RefreshID).Tag = "HIDE_VALUE"
    RefreshAccountProperty_Click = TRUE
    Exit Function
  End If
      
  Set colSD = Server.CreateObject("MetraTech.Pipeline.ServiceDefinitionCollection")
  Set AccountDefinition = colSD.GetServiceDefinition(Replace(Replace(mom_GetDictionary("ACCOUNT_CREATION_MSIXDEF_FILE_NAME"),"\","/"), ".msixdef", ""))
  
  ' Set product view definition property type in - so we know how to draw the property field
  Dim objProperty
  Set objProperty = AccountDefinition.GetProperty(Service.Properties("AccountProperty" & RefreshID).Value)
  Select Case objProperty.DataType
    Case PROP_TYPE_ENUM
      Set objDyn = mdm_CreateObject(CVariables)    
      For Each prop in objProperty.Enumerators
        objDyn.Add prop.Name, prop.Name, , , prop.DisplayName
      Next
      Service.Properties("AccountValue" & RefreshID).AddValidListOfValues objDyn
      Call Service.Properties("AccountValue" & RefreshID).SetPropertyType("ENUM", objProperty.EnumSpace, objProperty.EnumType)

    Case PROP_TYPE_DATETIME, PROP_TYPE_TIME
      Service.Properties("AccountValue" & RefreshID).SetPropertyType("TIMESTAMP")
      Service.Properties("AccountValue" & RefreshID).Length = objProperty.Length

    Case PROP_TYPE_INTEGER
      Service.Properties("AccountValue" & RefreshID).SetPropertyType("INT32")
          
    Case PROP_TYPE_DOUBLE
      Service.Properties("AccountValue" & RefreshID).SetPropertyType("DOUBLE")
      
    Case PROP_TYPE_DECIMAL
      Service.Properties("AccountValue" & RefreshID).SetPropertyType("DECIMAL")
            
    Case Else
      Service.Properties("AccountValue" & RefreshID).SetPropertyType("STRING")
      Service.Properties("AccountValue" & RefreshID).Length = objProperty.Length
  End Select

  Service.Properties("AccountValue" & RefreshID).Tag = "SHOW_VALUE"
   
	RefreshAccountProperty_Click = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : OK_Click
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION OK_Click(EventArg) ' As Boolean

    On Error Resume Next
    Dim objReRun, objFilter, i

    OK_Click = FALSE

    m_strStep = "MTBillingReRun.Setup"
    
    ' Setup run
    Set objReRun = CreateObject(MT_BILLING_RERUN_PROG_ID)
    objReRun.Login FrameWork.SessionContext
    If Not CheckError() Then Exit Function
    ' Need to associate this backout with a batch
    if len(Service.Properties("BatchID").Value)>0 then
      objReRun.Setup "Batch[" & Service.Properties("BatchID").Value & "]"   
    else    
      objReRun.Setup Service.Properties("Description").Value   
    end if
      
    Session("BACKOUTRERUN_CURRENT_RERUNID") = objReRun.ID
    Session("BACKOUTRERUN_CURRENT_COMMENT") = Service.Properties("Description").Value
    
    If Not CheckError() Then Exit Function

    
    m_strStep = "Creating Identify Filter"
    Set objFilter = objReRun.CreateFilter() ' Get back: "MetraTech.Pipeline.ReRun.IdentificationFilter"
    If Not CheckError() Then Exit Function

    ' If the user wants to manually use SQL to identify records to be backed out - we let them
    If UCase(Service.Properties("SelectionMethod").Value) = "SQL" Then
      objReRun.Identify (objFilter), Service.Properties("Description").Value
      Form.RouteTo = "BackOutRerun.BackoutStep1.5SQL.asp"
      OK_Click = TRUE        
      Exit Function
    End If

    ' Use Session ID(s)
    If UCase(Service.Properties("SelectionMethod").Value) = "IDS" Then
      If Len(Service.Properties("SessionIDs").Value) Then  
        Dim arrIDs, nID, sTemp
        sTemp = Service.Properties("SessionIDs").Value
        sTemp = Replace(sTemp, vbCrLf, " ")
        sTemp = Replace(sTemp, vbCr, " ")
        sTemp = Replace(sTemp, vbLf, " ")
        arrIDs = Split(ltrim(rtrim(sTemp)), " ") 

        For Each nID in arrIDs
         objFilter.AddSessionID nID
        Next
      End If
      
    ' Use user defined filter  
    Else
      If Len(Service.Properties("BeginDatetime").Value) Then 
        objFilter.BeginDatetime  = Service.Properties("BeginDatetime").Value
      End If
      
      If Len(Service.Properties("EndDatetime").Value)   Then 
        objFilter.EndDatetime    = Service.Properties("EndDatetime").Value
        
        if objFilter.EndDatetime < objFilter.BeginDatetime Then
            EventArg.Error.Save "Invalid Start and End Date" 
            EventArg.Error.Description = "Invalid Start and End Date"
            Exit Function
        end if
      End If
      
      If  Len(Service.Properties("BatchID").Value) Then       
        objFilter.BatchID        = Service.Properties("BatchID").Value
        If Not CheckBatch(Service.Properties("BatchID").Value) Then 
            Exit Function  
        End If
      End If
      
      If Len(Service.Properties("IntervalID").Value)    Then 
        objFilter.IntervalID     = Service.Properties("IntervalID").Value        
        If Not CheckInterval(Service.Properties("IntervalID").Value) Then 
            Exit Function
        End If
      End If
      
      For i = 1 to Form("NumberOfVisibleServiceDefs")
        If Service.Properties("ServiceDefinition" & i).Tag <> "DELETED" Then
          If Len(Service.Properties("ServicePropertyValue" & i).Value) Then
            objFilter.AddServiceDefinitionProperty Service.Properties("ServiceDefinition"     & i).Value, _
                                                   Service.Properties("ServiceProperty"      & i).Value, _
                                                   Service.Properties("ServicePropertyValue" & i).Value
          Else
            If Len(Service.Properties("ServiceDefinition" & i).Value) Then
               objFilter.AddServiceDefinition Service.Properties("ServiceDefinition" & i).Value
            End If          
          End If                                              
        End If  
      Next

      For i = 1 to Form("NumberOfVisibleProductDefs")               
        If Service.Properties("ProductDefinition" & i).Tag <> "DELETED" Then                                                                                                 
          If Len(Service.Properties("ProductPropertyValue" & i).Value) Then
            objFilter.AddProductViewProperty Service.Properties("ProductDefinition"     & i).Value, _
                                             Service.Properties("ProductProperty"      & i).Value, _
                                             Service.Properties("ProductPropertyValue" & i).Value
          Else
            If Len(Service.Properties("ProductDefinition" & i).Value) Then
               objFilter.AddProductView Service.Properties("ProductDefinition" & i).Value
            End If
          End If
        End If  
      Next  

      'Set up the account property filter if necessary
      If Form("NumberOfVisibleAccountProps")>0 then
        Set objFilter.AccountConditions = CreateObject("MTSQLRowset.MTDataFilter")      
        For i = 1 to Form("NumberOfVisibleAccountProps")                                                                                                              
          If Service.Properties("AccountProperty" & i).Tag  <> "DELETED" Then
            If Len(Service.Properties("AccountValue" & i).Value) Then
             objFilter.AccountConditions.Add Service.Properties("AccountProperty" & i).Value, CInt(Service.Properties("AccountOperator" & i).Value), Service.Properties("AccountValue" & i).Value        
            End If
          End If  
        Next
      End If
      
    End If  
    If Not CheckError() Then Exit Function
    
    objReRun.Synchronous = false
    Session("BACKOUTRERUN_CURRENT_STATUS_MESSAGE") = mom_GetDictionary("TEXT_Identify_and_Analyze_In_Progress") 
    Session("WaitRefreshCount")=Clng(0)
    m_strStep = "MTBillingReRun.IdentifyAndAnalyze"
    objReRun.IdentifyAndAnalyze (objFilter), Service.Properties("Description").Value
    ' Testing
    'dim bIsComplete
    'bIsComplete = objReRun.IsComplete

    Dim objWinApi
    Set objWinApi = Server.CreateObject(CWindows)
    objWinApi.Sleep 1000 'If we delay a second, the operation will have a chance at being complete and we will not have to go to wait screen

    Dim bIsComplete
    bIsComplete = objReRun.IsComplete
    
    'display formatting error message, not the entire stack trace
    If(Err.number = -2146233087) Then
        Err.Description = mom_GetDictionary("TEXT_Please_reenter_search_criteria") 
    End If

    If Not CheckError() Then Exit Function
       
    OK_Click = TRUE
END FUNCTION

PRIVATE FUNCTION CheckInterval(intervalId)
  CheckInterval= FALSE
  Dim strSql
  Dim rowset
  strSql = "select id_interval from t_usage_interval where id_interval=" & intervalId
  set rowset = server.createobject("MTSQLRowset.MTSQLRowset.1")
  rowset.Init("queries\audit")
  rowset.SetQueryString(strSql)
  rowset.Execute

  if (rowset.RecordCount = 0) then
    rowset.ClearQuery()
    set rowset = nothing
    EventArg.Error.Save "Invalid Interval Id" 
    EventArg.Error.Description = mom_GetDictionary("TEXT_Invalid_Interval_Id")
    exit function
  end if  
  CheckInterval= TRUE
END FUNCTION 

PRIVATE FUNCTION CheckBatch(batchId)
  CheckBatch= FALSE
  Dim strSql
  Dim rowset
  ' ESR-4300
  strSql = "select id_batch from t_batch where tx_batch_encoded='" &  batchId & "'"
  set rowset = server.createobject("MTSQLRowset.MTSQLRowset.1")
  rowset.Init("queries\audit")
  rowset.SetQueryString(strSql)
  rowset.Execute

  if (rowset.RecordCount = 0) then
    rowset.ClearQuery()
    set rowset = nothing
    EventArg.Error.Save "Invalid Batch Id" 
    EventArg.Error.Description = mom_GetDictionary("TEXT_Invalid_Batch_Id")
    exit function
  end if  
  CheckBatch= TRUE
END FUNCTION 
' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : Cancel_Click
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Cancel_Click(EventArg) ' As Boolean
  Form.Routeto = "welcome.asp"
  Cancel_Click = TRUE
END FUNCTION

'--------------------------------------------------------------------------------------------------------------------------
' BLUE BUTTONS
'--------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : AddProductProperty_Click
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION AddProductProperty_Click(EventArg) ' As Boolean
  Form("NumberOfVisibleProductDefs").Value = Form("NumberOfVisibleProductDefs").Value + 1
END FUNCTION

' FUNCTION 		    : AddServiceProperty
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION AddServiceProperty_Click(EventArg) ' As Boolean
  Form("NumberOfVisibleServiceDefs").Value = Form("NumberOfVisibleServiceDefs").Value + 1
END FUNCTION

' FUNCTION 		    : AddAccountProperty
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION AddAccountProperty_Click(EventArg) ' As Boolean
  Form("NumberOfVisibleAccountProps").Value = Form("NumberOfVisibleAccountProps").Value + 1
END FUNCTION
    
'--------------------------------------------------------------------------------------------------------------------------
' Check for errors
'-------------------------------------------------------------------------------------------------------------------------- 
PRIVATE FUNCTION CheckError() ' As Boolean
    CheckError = FALSE
    If(Err.Number)Then 
        EventArg.Error.Save Err 
        EventArg.Error.Description = EventArg.Error.Description & "; Step=" & m_strStep
        Err.Clear 
        Exit Function
    End If        
    CheckError = TRUE
END FUNCTION

%>

