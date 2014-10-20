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
<!-- #INCLUDE FILE="../../default/lib/MTProductCatalog.Library.asp" -->
<!-- #INCLUDE FILE="../../default/Lib/CTransactionUIFinder.asp" -->
<!-- #INCLUDE FILE="../../default/Lib/CAdjustmentHelper.asp" -->

<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" -->
<%

' Mandatory
Form.Version = MDM_VERSION     ' Set the dialog version
Form.RouteTo = mam_GetDictionary("WELCOME_DIALOG")

mdm_Main ' invoke the mdm framework


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: Form_Initialize
' PARAMETERS	:
' DESCRIPTION :
' RETURNS		  : Returns TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean

  Form_Initialize = FALSE
  Form("BulkAdjust") = mdm_UIValue("BulkAdjust")
  ProductView.Properties.Interval.DateFormat = mam_GetDictionary("DATE_FORMAT")  ' Set the date format into the Interval Id Combo Box
    
  If Not TransactionUIFinder.Initialize() Then Exit Function
  
  If Len(mdm_UIValue("PriceAbleItemTemplateID"))Then ' Optimization to select the PriceAbleItem Template ID, If go back to the dialog
      Service.Properties("PriceAbleItem").Value = CLng(mdm_UIValue("PriceAbleItemTemplateID"))
  Else
      Service.Properties("PriceAbleItem").Value = 0
  End If
  PriceAbleItem_Click EventArg ' Force to clean some stuff
  
  ' Set the default date value
  Service.Properties("StartDate") = mam_FormatDate(CDate(FrameWork.RemoveTime(FrameWork.MetraTimeGMTBeginOfCurrentMonth())), mam_GetDictionary("DATE_FORMAT"))
  Service.Properties("EndDate") = mam_FormatDate(CDate(FrameWork.RemoveTime(FrameWork.MetraTimeGMTEndOfCurrentMonth()) & " " & FrameWork.Dictionary.Item("END_OF_DAY").Value), mam_GetDictionary("DATE_FORMAT"))

  Service.Properties.Add "FixedPeriod", "int32", 0, False, Empty
  Service.Properties("FixedPeriod").Value = 0
  
  Call Service.Properties.Add("BulkAdjust","String",255, false, empty)
    
  mam_IncludeCalendar
  
  Service.LoadJavaScriptCode  ' This line is important to get JavaScript field validation
  
	Form_Initialize = Form_Refresh(EventArg)
END FUNCTION

PUBLIC FUNCTION PriceAbleItem_Click(EventArg) ' As Boolean

    If Len(Service.Properties("PriceAbleItem").Value)=0 Then
        FrameWork.Dictionary.Add "ADJUSTMENT_FINDER_PRICE_ABLE_ITEM_SUB_TEMPLATE", "<MDMHTML>"
    End If
    PriceAbleItem_Click = TRUE
END FUNCTION

PRIVATE FUNCTION Form_Refresh(EventArg) ' As Boolean
 
    Dim lngPriceAbleItemTemplateID, strPriceAbleItemTemplateName
  
    lngPriceAbleItemTemplateID    = Service.Properties("PriceAbleItem").Value
  
    If lngPriceAbleItemTemplateID>0 Then
    
        strPriceAbleItemTemplateName  = Service.Properties("PriceAbleItem").EnumType.Entries.ItemByValue(lngPriceAbleItemTemplateID).Name   

        If Not TransactionUIFinder.ReInitialize() Then 
        End If

        If(TransactionUIFinder.InitializePriceAbleItem(strPriceAbleItemTemplateName,lngPriceAbleItemTemplateID,Service.Properties("StartDate").Value,Service.Properties("EndDate").Value,TRUE))Then        
        End If
    End If    
   
    Form_Refresh = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : OK_Click()
' PARAMETERS		  :
' DESCRIPTION 		: 
' RETURNS		      : Returns TRUE if ok else FALSE
PRIVATE FUNCTION Ok_Click(EventArg) ' As Boolean

      Dim lngTransactionCounter, lngPriceAbleItemTemplateID, strPriceAbleItemTemplateName
     
      lngTransactionCounter      = -1 ' Error
      OK_Click                   = FALSE
      lngPriceAbleItemTemplateID = Service.Properties("PriceAbleItem").Value

      '//Check to make sure either dates are passed or an interval is passed
      if Service.Properties("FixedPeriod").Value=1 then
        if len(Service.Properties("StartDate").Value)=0 AND len(Service.Properties("StartDate").Value)=0 then
          EventArg.Error.Description=FrameWork.Dictionary().Item("MAM_ERROR_1050").Value
          Exit Function
        end if
        '//Set the Interval ID to 0 so downstream processing knows we are date based
        Service.Properties("mdmIntervalID").Value = ""
      else
        if len(Service.Properties("mdmIntervalId").Value) = 0 then
          EventArg.Error.Description=FrameWork.Dictionary().Item("MAM_ERROR_1050").Value
          Exit Function
        end if
      end if
         
      If lngPriceAbleItemTemplateID<>0 Then  
          
          strPriceAbleItemTemplateName  = Service.Properties("PriceAbleItem").EnumType.Entries.ItemByValue(lngPriceAbleItemTemplateID).Name
        
          If(TransactionUIFinder.InitializePriceAbleItem(strPriceAbleItemTemplateName,lngPriceAbleItemTemplateID,Service.Properties("StartDate").Value,Service.Properties("EndDate").Value,FALSE))Then
          
                lngTransactionCounter = TransactionUIFinder.Find(EventArg)
                
                If(lngTransactionCounter=-1)Then
                
                ElseIf(lngTransactionCounter=0)Then
                
                    EventArg.Error.Number       = 1038
                    EventArg.Error.Description  = mam_GetDictionary("MAM_ERROR_1038")
                    Form_DisplayErrorMessage EventArg
                    Response.End

                Else                
                    TransactionUIFinder.SelectedPriceAbleItemTemplateID   = Service.Properties("PriceAbleItem").Value
                    if UCase(Form("BulkAdjust")) = "TRUE" then
						Form.RouteTo = mam_GetDictionary("BULKADJUSTMENT_PVB_DIALOG")	
                    else
						Form.RouteTo = mam_GetDictionary("ADJUSTMENT_PVB_DIALOG")
                    end if
                    OK_Click                                              = TRUE
                End If
          End If      
      Else
          EventArg.Error.Description = PreProcess(FrameWork.Dictionary().Item("MAM_ERROR_1044").Value,Array("ITEM",Service.Properties("PriceAbleItem").Caption))
      End If
END FUNCTION
%>

