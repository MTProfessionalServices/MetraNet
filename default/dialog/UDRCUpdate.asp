<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
<%
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile: C:\builds\v3.5\Development\UI\MAM\default\dialog\UDRCUpdate.asp$
' 
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
'  Created by: Kevin A. Boucher
' 
'  $Date: 11/01/2002 3:26:49 PM$
'  $Author: Kevin Boucher$
'  $Revision: 1$
' ---------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../../MamIncludeMDM.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MamLibrary.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MTProductCatalog.Library.asp" -->
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" --> 
<%
    
' Mandatory
Form.Version        = MDM_VERSION     ' Set the dialog version - we are version 2.0.
Form.RouteTo        = session("UDRC_CANCEL_ROUTETO")

mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION    : Form_Initialize
' PARAMETERS  :
' DESCRIPTION :
' RETURNS     : Return TRUE if ok else FALSE
FUNCTION Form_Initialize(EventArg) ' As Boolean
	Service.Clear 	' Set all the property of the service to empty. 
					        ' The Product view if allocated is cleared too.

  Form("InitialTemplate") = Form.HTMLTemplateSource  ' Save the initial template so we can use it to render a new dynamic template later
  Form("StartDate")       = Request.QueryString("StartDate")
  Form("EndDate")         = Request.QueryString("EndDate")
                      
  ' Add dialog properties
  Service.Properties.Add "StartDate", "STRING", 0, FALSE, Empty    
  Service.Properties.Add "EndDate", "STRING", 0, FALSE, Empty    	
    
  Service.LoadJavaScriptCode  ' This line is important to get JavaScript field validation

  ' Include Calendar javascript    
  mam_IncludeCalendar

	Form_Initialize = DynamicTemplate(EventArg)
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  DynamicTemplate
' PARAMETERS:  EventArg
' DESCRIPTION:  
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION DynamicTemplate(EventArg)

	Dim objYAAC, strName
  Dim id_prop
  Dim objMTProductCatalog
  Dim udrcType
  Dim po         
  Dim udrcInstances
  Dim udrcInstance
  Dim objAccount
  Dim objSubscription
	Dim strHTML

'  on error resume next

  ' Setup initial template
  Form.HTMLTemplateSource = Form("InitialTemplate")
  id_prop = request.QueryString("id_prop")
  
  Set objMTProductCatalog = GetProductCatalogObject()
  Set udrcType = objMTProductCatalog.GetPriceableItemTypeByName("Unit Dependent Recurring Charge")
  
  Set objAccount = objMTProductCatalog.GetAccount(mam_GetSubscriberAccountID())
  Form("Subscription") = objAccount.GetSubscription(CLng(request.QueryString("id_sub")))
  Set po = objMTProductCatalog.GetProductOffering(Form("Subscription").ProductOfferingID)
    
    dim objPriceableItems
    set objPriceableItems = po.GetPriceableItems
    
    dim objPI
    for each objPI in objPriceableItems
      If IsTypeUDRC(objPI.PriceAbleItemType) then
        set udrcInstance = objPi
        If CStr(udrcInstance.ID) = CStr(id_prop) Then
          ' Save instance
          Form("UDRCInstance") = udrcInstance
          
          Dim enums
          Set enums = udrcInstance.GetUnitValueEnumerations()
          If enums.Count > 0 Then
            Dim e, objDyn
            Set objDyn = mdm_CreateObject(CVariables)    
            For Each e In enums
              objDyn.Add e, e, , ,e
            Next
            Service.Properties.Add "UDRCValue", "STRING", 255, TRUE, EMPTY
            Service.Properties("UDRCValue").Caption = udrcInstance.UnitName
            Service.Properties("UDRCValue").AddValidListOfValues objDyn
            strHTML = strHTML & "   <tr>"
	          strHTML = strHTML & "     <td class='captionEWRequired'><MDMLABEL Name='UDRCValue' type='Caption'>Value</MDMLABEL>:&nbsp;&nbsp;</td>"
            strHTML = strHTML & "     <td class='clsStandardText'><select class='fieldRequired' name='UDRCValue'></select></td>"
	          strHTML = strHTML & "   </tr>"
          Else
             If CBool(udrcInstance.IntegerUnitValue) Then
               Service.Properties.Add "UDRCValue", "INT32", 0, TRUE, 0
             Else
               Service.Properties.Add "UDRCValue", "DECIMAL", 0, TRUE, 0
             End If
             Service.Properties("UDRCValue").Caption = udrcInstance.UnitName
    	       strHTML = strHTML & "   <tr>"
   		       strHTML = strHTML & "     <td class='captionEWRequired'><MDMLABEL Name='UDRCValue' type='Caption'>Value</MDMLABEL>:&nbsp;&nbsp;</td>"
             strHTML = strHTML & "     <td class='clsStandardText'><input class='fieldRequired' size='10' type='text' name='UDRCValue'></td>"
  		       strHTML = strHTML & "   </tr>"
          End If  
          
          ' Set Values
          If FrameWork.IsMinusInfinity(Form("StartDate")) Then
            Service.Properties("StartDate").Value = ""
          Else
            Service.Properties("StartDate").Value = Form("StartDate")
          End If
          If FrameWork.IsInfinity(Form("EndDate")) Then
            Service.Properties("EndDate").Value = ""      
          Else
  	        Service.Properties("EndDate").Value   = FrameWork.RemoveTime(Form("EndDate")) & " " & FrameWork.Dictionary().Item("END_OF_DAY").Value
          End If

  	      Service.Properties("UDRCValue").Value = Request.QueryString("Value")
      
  	      ' Set Captions 
          Service.Properties("UDRCValue").Caption = udrcInstance.UnitName 
  	      Service.Properties("StartDate").Caption = mam_GetDictionary("TEXT_START_DATE")
          Service.Properties("EndDate").Caption = mam_GetDictionary("TEXT_END_DATE")	
        End If 
      End If
    Next        
    
	Form.HTMLTemplateSource = Replace(Form.HTMLTemplateSource, "<DYNAMIC_UDRC />", strHTML)
  
  Service.LoadJavaScriptCode  ' This line is important to get JavaScript field validation  
  
  DynamicTemplate = TRUE

END FUNCTION
  
' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  Form_Refresh
' PARAMETERS:  EventArg
' DESCRIPTION:  Loads the DynamicTemplate
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION Form_Refresh(EventArg) ' As Boolean
	Form_Refresh = DynamicTemplate(EventArg)
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  OK_Click
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION OK_Click(EventArg) ' As Boolean

	 On Error Resume Next

   Dim datEndDate
   If Service.Properties("StartDate").Value = "" Then
     Service.Properties("StartDate").Value = FrameWork.GetMinDate()
   End If
				 
   If Service.Properties("EndDate").Value = "" Then
     Service.Properties("EndDate").Value = FrameWork.RCD().GetMaxDate()
     datEndDate = FrameWork.RCD().GetMaxDate()
   Else
     datEndDate   = CDate(Service.Properties("EndDate").Value)
     datEndDate   = FrameWork.RemoveTime(datEndDate)
     datEndDate   = datEndDate & " " & FrameWork.Dictionary().Item("END_OF_DAY").Value
   End If

Call Form("Subscription").SetRecurringChargeUnitValue(Form("UDRCInstance").ID, Service.Properties("UDRCValue").Value, Service.Properties("StartDate").Value, CDate(datEndDate)) 
   
   If(CBool(Err.Number = 0)) then
        On Error Goto 0
        OK_Click = TRUE
   Else        
        EventArg.Error.Save Err  
        OK_Click = FALSE
   End If
END FUNCTION
%>

