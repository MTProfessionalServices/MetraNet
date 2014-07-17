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
' DIALOG	    : CBillingCycle object
' DESCRIPTION	: This class is a wrapper for all the thing the application need to do with a MetraTech Billing Cycle Notion
'               A ProductCatalogBillingCycle Instance of CProductCatalogBillingCycle in created automatically by the file.
' AUTHOR	    : Frederic Torres.
' VERSION	    : 2.0
' DEPENDENCY  : This class use the file MTProductCatalog.Library.asp 
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

' Public Billing Cycle Type Const - These value match the enum type metratech.com/billingcycle usagecycletype.
PUBLIC CONST BILLING_CYCLE_MONTHLY        = 1
PUBLIC CONST BILLING_CYCLE_ON_DEMAND      = 2
PUBLIC CONST BILLING_CYCLE_DAILY          = 3
PUBLIC CONST BILLING_CYCLE_WEEKLY         = 4
PUBLIC CONST BILLING_CYCLE_BI_WEEKLY      = 5
PUBLIC CONST BILLING_CYCLE_SEMI_MONTHLY   = 6
PUBLIC CONST BILLING_CYCLE_QUATERLY       = 7
PUBLIC CONST BILLING_CYCLE_ANNUALLY        = 8
PUBLIC CONST BILLING_CYCLE_SEMIANNUALLY  = 9

PUBLIC CONST COUNTER_QUALIFIER = 10
PUBLIC CONST COUNTER_TARGET = 20

PUBLIC CONST BIWEEKLY_STARTMONTH = 1
PUBLIC CONST BIWEEKLY_STARTYEAR = 2001

PUBLIC CONST DISCOUNT_VALUE_TYPE_UNKNOWN = 0
PUBLIC CONST DISCOUNT_VALUE_TYPE_FLAT = 1
PUBLIC CONST DISCOUNT_VALUE_TYPE_PERCENTAGE = 2

PUBLIC CONST CYCLE_MODE_FIXED			      = 0
PUBLIC CONST CYCLE_MODE_BCR				      = 1
PUBLIC CONST CYCLE_MODE_BCR_CONSTRAINED = 2
PUBLIC CONST CYCLE_MODE_EBCR			      = 3

PRIVATE CONST BILLING_CYCLE_HTML_SUB_TEMPLATE_TAG = "[BILLING_CYCLE_HTML_SUB_TEMPLATE]"

PUBLIC  ProductCatalogBillingCycle
Set     ProductCatalogBillingCycle = New CProductCatalogBillingCycle

CLASS CProductCatalogBillingCycle

    ' ---------------------------------------------------------------------------------------------------------------------------------------
    ' FUNCTION 			: PreProcessIDs
    ' PARAMETERS		:
    ' DESCRIPTION 	: Because we do not want to hard the billing cycle enum type id in the HTML template file. 
    ' RETURNS			  :
    PRIVATE FUNCTION PreProcessIDs(strHTML) ' as String
    
        Dim objPreProcessor
        
        Set objPreProcessor = mdm_CreateObject(CPreProcessor)
        objPreProcessor.Add "BILLING_CYCLE_MONTHLY",       BILLING_CYCLE_MONTHLY
        objPreProcessor.Add "BILLING_CYCLE_ON_DEMAND",     BILLING_CYCLE_ON_DEMAND
        objPreProcessor.Add "BILLING_CYCLE_DAILY",         BILLING_CYCLE_DAILY
        objPreProcessor.Add "BILLING_CYCLE_WEEKLY",        BILLING_CYCLE_WEEKLY
        objPreProcessor.Add "BILLING_CYCLE_BI_WEEKLY",     BILLING_CYCLE_BI_WEEKLY
        objPreProcessor.Add "BILLING_CYCLE_SEMI_MONTHLY",  BILLING_CYCLE_SEMI_MONTHLY
        objPreProcessor.Add "BILLING_CYCLE_QUATERLY",      BILLING_CYCLE_QUATERLY
        objPreProcessor.Add "BILLING_CYCLE_ANNUALLY",       BILLING_CYCLE_ANNUALLY
        objPreProcessor.Add "BILLING_CYCLE_SEMIANNUALLY",       BILLING_CYCLE_SEMIANNUALLY
        
        PreProcessIDs = objPreProcessor.Process(strHTML)
    END FUNCTION
    
    ' ---------------------------------------------------------------------------------------------------------------------------------------
    ' FUNCTION 			: 
    ' PARAMETERS		:
    ' DESCRIPTION 	: 
    ' RETURNS			  :
    PRIVATE FUNCTION InsertInHTMLTemplateTheBillingCycleHTMLSubTemplate(strHTML) ' as String  
      
        Dim objTextFile, strS
        Set objTextFile = mdm_CreateObject(CTextFile)
        
        If(objTextFile.ExistFile(GetBillingCycleHTMLSubTemplateFileName()))Then
        
            strS = objTextFile.LoadFile(GetBillingCycleHTMLSubTemplateFileName())
        Else
            strS = "BILLING CYCLE ERROR - File Not Found " & GetBillingCycleHTMLSubTemplateFileName()
        End If
        InsertInHTMLTemplateTheBillingCycleHTMLSubTemplate = Replace(strHTML,BILLING_CYCLE_HTML_SUB_TEMPLATE_TAG,strS)
    END FUNCTION
    
    PUBLIC FUNCTION ClearInsertTag(objForm) ' as Boolean
        objForm.HTMLTemplateSource = Replace(objForm.HTMLTemplateSource,"[BILLING_CYCLE_HTML_SUB_TEMPLATE]","")
        ClearInsertTag = TRUE
    END FUNCTION
    
    ' ---------------------------------------------------------------------------------------------------------------------------------------
    ' FUNCTION 			:
    ' PARAMETERS		:
    ' DESCRIPTION 	: 
    ' RETURNS			  :
    PUBLIC FUNCTION Form_Initialize(objForm) ' as Boolean
    
    If COMObject.Instance.Kind = 20 Or COMObject.Instance.Kind = 25 Then ' For recurring charges we will enable the EBCR Mode, meaning you will see a new cycle option on the cycle section
      mdm_GetDictionary().Add "ShowExtendedBillingCycleOption", TRUE
    Else
      mdm_GetDictionary().Add "ShowExtendedBillingCycleOption", FALSE
    End If

      objForm.HTMLTemplateSource = InsertInHTMLTemplateTheBillingCycleHTMLSubTemplate(objForm.HTMLTemplateSource)
      objForm.HTMLTemplateSource = PreProcessIDs(objForm.HTMLTemplateSource)
      
    COMObject.Properties("Cycle__Mode").Value = COMObject.Instance.Cycle.Mode ' This is a workaround for a funny problem
    
      ' In IMTPCCycle object the property EndDayOfMonth is used in the cycle : monthly and semi-monthly.
	  ' This cause a display problem to the MDM renderer, because both representation of the combox box will be enabled and set
	  ' with the same value. To avoid this we create temp property with uniq name.
    
	  COMObject.Properties.Add "CycleMode"          					  ,MSIXDEF_TYPE_INT32, 0, FALSE, 1 ' This is the main selection property.
	  ' You can pick "Fixed", "Billing Cycle Relative, "Constrained Billing Cycle relative" or "Extended Billing Cycle relative".
	  
    COMObject.Properties.Add "Cycle@EndDayOfMonth_Monthly"          	,MSIXDEF_TYPE_INT32 ,0 ,FALSE , 1
	  COMObject.Properties.Add "Cycle@EndDayOfMonth_SemiMonthly"        ,MSIXDEF_TYPE_INT32 ,0 ,FALSE , 1
	  COMObject.Properties.Add "Cycle@StartMonth_BiWeekLy"          		,MSIXDEF_TYPE_INT32 ,0 ,FALSE , 1
	  COMObject.Properties.Add "Cycle@StartDay_BiWeekLy"          			,MSIXDEF_TYPE_INT32 ,0 ,FALSE , 1	      
	  COMObject.Properties.Add "Cycle@StartMonth_Quarterly"          		,MSIXDEF_TYPE_INT32 ,0 ,FALSE , 1
	  COMObject.Properties.Add "Cycle@StartDay_Quarterly"          			,MSIXDEF_TYPE_INT32 ,0 ,FALSE , 1    
	  COMObject.Properties.Add "Cycle@StartMonth_Annual"            		,MSIXDEF_TYPE_INT32 ,0 ,FALSE , 1
	  COMObject.Properties.Add "Cycle@StartDay_Annual"            			,MSIXDEF_TYPE_INT32 ,0 ,FALSE , 1    
	  COMObject.Properties.Add "Cycle@StartMonth_SemiAnnual"         		,MSIXDEF_TYPE_INT32 ,0 ,FALSE , 1
	  COMObject.Properties.Add "Cycle@StartDay_SemiAnnual"         			,MSIXDEF_TYPE_INT32 ,0 ,FALSE , 1    
    COMObject.Properties.Add "Cycle@BiWeeklyComBox"          			    ,MSIXDEF_TYPE_STRING,0 ,FALSE , 1    
    COMObject.Properties.Add "Cycle@BillingCycleTypeID"          			,MSIXDEF_TYPE_INT32,0 ,FALSE , 1
    COMObject.Properties.Add "Cycle@EBCRBillingCycleTypeID"          	,MSIXDEF_TYPE_INT32,0 ,FALSE , 1
    COMObject.Properties.Add "ConstrainBillingCycle"          	      ,MSIXDEF_TYPE_BOOLEAN,0 ,FALSE , 1
    
    'We don't really want these combo boxes to have the blank option
    COMObject.Properties("Cycle@EndDayOfMonth_Monthly").Required = TRUE
    COMObject.Properties("Cycle@EndDayOfMonth_SemiMonthly").Required = TRUE    
    COMObject.Properties("Cycle@StartMonth_BiWeekLy").Required = TRUE
    COMObject.Properties("Cycle@StartDay_BiWeekLy").Required = TRUE
    COMObject.Properties("Cycle@StartMonth_Quarterly").Required = TRUE
    COMObject.Properties("Cycle@StartDay_Quarterly").Required = TRUE
    COMObject.Properties("Cycle@StartMonth_Annual").Required = TRUE
    COMObject.Properties("Cycle@StartDay_Annual").Required = TRUE
    COMObject.Properties("Cycle@StartMonth_SemiAnnual").Required = TRUE
    COMObject.Properties("Cycle@StartDay_SemiAnnual").Required = TRUE
    COMObject.Properties("Cycle@BiWeeklyComBox").Required = TRUE
    COMObject.Properties("Cycle__EndDayOfMonth2").Required = TRUE
    COMObject.Properties("Cycle__EndDayOfWeek").Required = TRUE
    COMObject.Properties("Cycle@BillingCycleTypeID").Required = TRUE
    COMObject.Properties("Cycle@EBCRBillingCycleTypeID").Required = TRUE
    
    ' I think this property is not used but we are so close from the mile stone
    COMObject.Properties.Add "Cycle@Proration"          			        ,MSIXDEF_TYPE_INT32 ,0 ,FALSE , 1
    
    SetMSIXPropertyTypeToDayOfMonthEnumType     COMObject.Properties("Cycle@EndDayOfMonth_Monthly")
	  SetMSIXPropertyTypeToDayOfMonthEnumType     COMObject.Properties("Cycle@EndDayOfMonth_SemiMonthly")
	  SetMSIXPropertyTypeToDayOfQuarterlyEnumType     COMObject.Properties("Cycle@StartDay_Quarterly")
	  SetMSIXPropertyTypeToFullDayOfMonthEnumType COMObject.Properties("Cycle@StartDay_Annual")
	  SetMSIXPropertyTypeToFullDayOfMonthEnumType COMObject.Properties("Cycle@StartDay_SemiAnnual")		
    SetMSIXPropertyTypeToDayOfMonthEnumType     COMObject.Properties("Cycle@StartDay_BiWeekly")
    
	  ' Cycle__EndDayOfMonth2 this is the real property used only for semi monthly so we do not need a uniq name
	  ' but we need to set the enum type values...
	  SetMSIXPropertyTypeToDayOfMonthEnumType     COMObject.Properties("Cycle__EndDayOfMonth2")
    
	  COMObject.Properties("Cycle@EndDayOfMonth_Monthly").value		  =	COMObject.Properties("Cycle__EndDayOfMonth").value
	  COMObject.Properties("Cycle@EndDayOfMonth_SemiMonthly").value	=	COMObject.Properties("Cycle__EndDayOfMonth").value
	  COMObject.Properties("Cycle@StartMonth_Quarterly").value		  =	COMObject.Properties("Cycle__StartMonth").value
	  COMObject.Properties("Cycle@StartDay_Quarterly").value		    =	COMObject.Properties("Cycle__StartDay").value

	  COMObject.Properties("Cycle@StartMonth_Annual").value		  =	COMObject.Properties("Cycle__StartMonth").value
	  COMObject.Properties("Cycle@StartDay_Annual").value		    =	COMObject.Properties("Cycle__StartDay").value
	  COMObject.Properties("Cycle@StartMonth_SemiAnnual").value		  =	COMObject.Properties("Cycle__StartMonth").value
	  COMObject.Properties("Cycle@StartDay_SemiAnnual").value		    =	COMObject.Properties("Cycle__StartDay").value
    COMObject.Properties("Cycle@BillingCycleTypeID").Value      = 1 ' Default this prop to monthly - later it might get overriden
    COMObject.Properties("Cycle@EBCRBillingCycleTypeID").Value  = 1 ' Default this prop to monthly - later it might get overriden
    
    'We need to properly pre-populate the mode selection (top level radiobutton) and also configure some UI elements
    'Here we are just properly setting the initial radiobutton option according to the value of the Mode property
    'This is pretty much the vanilla configuration - after this block we will handle the case where the PI Kind forbids an "unconstrained" BCR cycle
    If COMObject.Properties("Cycle__Mode").Value = CYCLE_MODE_BCR_CONSTRAINED Then
      ' BCR Constrained
      COMObject.Properties("CycleMode").Value = 1 ' BCR and BCR constrained modes share the same radiobutton on the UI
      COMObject.Properties("ConstrainBillingCycle").Value = true
      COMObject.Properties("Cycle@BillingCycleTypeID").Value = COMObject.Properties("Cycle__CycleTypeID").Value
    ElseIf COMObject.Properties("Cycle__Mode").Value = CYCLE_MODE_BCR Then
      ' BCR not constrained
      COMObject.Properties("CycleMode").Value = 1 ' BCR and BCR constrained modes share the same radiobutton on the UI
      COMObject.Properties("ConstrainBillingCycle").Value = false
    COMObject.Properties("Cycle@BillingCycleTypeID").Value    = COMObject.Properties("Cycle__CycleTypeID").Value
    ElseIf COMObject.Properties("Cycle__Mode").Value = CYCLE_MODE_EBCR Then
      ' "Extended" billing cycle relative
      COMObject.Properties("CycleMode").Value = 3 ' The corresponding value on the radiobutton for fixed
      COMObject.Properties("Cycle@EBCRBillingCycleTypeID").Value = COMObject.Properties("Cycle__CycleTypeID").Value
    ElseIf COMObject.Properties("Cycle__Mode").Value = CYCLE_MODE_FIXED Then
      ' Fixed
      COMObject.Properties("CycleMode").Value = 0 ' The corresponding value on the radiobutton for fixed
    End If
    
    'Ok so we have handled the general case. But what if the PI Kind forces that all BCR cycles be constrained
    'Then we really want to hide the the checkbox. Not showing the checkbox means we *are* constraining the cycle.
    If COMObject.Instance.PriceableItemType.ConstrainSubscriberCycle Then
      FrameWork.Dictionary().Add "ShowConstrainBillingCycleCheckbox", FALSE
      COMObject.Properties("ConstrainBillingCycle").Value = True ' just a safeguard
    Else
      FrameWork.Dictionary().Add "ShowConstrainBillingCycleCheckbox", TRUE
    End If
    
	  ' REMEMBER WE SKIPPED THE BI-WEEKLY
	  
    ' Create BCR select options according to enum type
    COMObject.Properties("Cycle@BillingCycleTypeID").SetPropertyType "ENUM", "metratech.com/billingcycle", "UsageCycleType"
   
    ' Create EBCR select options according to enum type, but restrict it so it does not have daily and semi-monthly (unsuported)
    COMObject.Properties("Cycle@EBCRBillingCycleTypeID").SetPropertyType "ENUM", "metratech.com/billingcycle", "UsageCycleType"
    COMObject.Properties("Cycle@EBCRBillingCycleTypeID").EnumType.Entries.remove "semi-monthly"
    COMObject.Properties("Cycle@EBCRBillingCycleTypeID").EnumType.Entries.remove "daily"
    
    ' ON-DEMAND does not exist in 3.0 last days
    'COMObject.Properties("Cycle@BillingCycleTypeID").EnumType.Entries.Remove "On-Demand"
    'COMObject.Properties("Cycle@BillingCycleTypeID").EnumType.Entries.Add "NONE", 0, " "
    
    COMObject.Properties("Cycle__EndDayOfWeek").SetPropertyType         "ENUM",  "global" ,  "DayOfTheWeek"
    COMObject.Properties("Cycle@StartMonth_Quarterly").SetPropertyType  "ENUM",  "global" ,  "MonthOfTheYearByQuarter"	  
    COMObject.Properties("Cycle@StartMonth_Annual").SetPropertyType     "ENUM",  "global" ,  "MonthOfTheYear"	  
    COMObject.Properties("Cycle@StartMonth_SemiAnnual").SetPropertyType "ENUM",  "global" ,  "MonthOfTheYear"	  
    COMObject.Properties("Cycle@StartMonth_BiWeekLy").SetPropertyType   "ENUM",  "global" ,  "MonthOfTheYearByQuarter"
		
    'SetBiWeekLyComboBoxEnumType COMObject.Properties("Cycle@BiWeeklyComBox")
    
    ComputeAndStoreBiWeeklyCycle COMObject.Properties("Cycle@BiWeeklyComBox")
	  
    'COMObject.Properties("Cycle__CycleTypeID").SetPropertyType   			"ENUM",  "metratech.com/billingcycle",  "UsageCycleType"
      
      Form_Initialize = TRUE
            
    END FUNCTION
    
    
    PRIVATE FUNCTION SetBiWeekLyComboBoxEnumType(objMSIXProperty)
            
        Dim objEnumType,i
    
        Set  objEnumType = mdm_CreateObject(CVariables)    
        
        For i=1 to 14
        
             objEnumType.Add CStr(i), CLng(i), , , "Periode " & i
        Next             
        objMSIXProperty.AddValidListOfValues  objEnumType ' Associate the Cvariables object to the MSIX Properties    
        
    END FUNCTION    
    
    ' ---------------------------------------------------------------------------------------------------------------------------------------
    ' FUNCTION 			: 
    ' PARAMETERS		:
    ' DESCRIPTION 	: 
    ' RETURNS			  :    
    PRIVATE FUNCTION GetBillingCycleHTMLSubTemplateFileName()
    
        GetBillingCycleHTMLSubTemplateFileName = FrameWork.ApplicationPath & "\" & FrameWork.Dictionary().Item("PRODUCT_CATALOG_BILLING_CYCLE_HTML_SUB_TEMPLATE_FILENAME").Value ' " Home Site Bug
    END FUNCTION 
    
    ' ---------------------------------------------------------------------------------------------------------------------------------------
    ' FUNCTION 		    : UpdateProperties
    ' PARAMETERS		  :
    ' DESCRIPTION 		: Set enabled all the combox box for the current billing cycle! And also updatethe property DayOfMonth1
    ' RETURNS		      :
    PUBLIC FUNCTION UpdateProperties() ' As Boolean
    
        Dim i , obj
        UpdateProperties = FALSE
    		If(Not COMObject.Properties.Enabled) Then 
    		
    				UpdateProperties = TRUE
    				Exit Function 
    		End If	
    		
    		' The mapping between the cycle mode selected and the com object is not 1 to 1.
    		' The COM object has 4 "modes": BRC, BCR "constrained", EBCR, FIXED
        if ComObject.Properties("CycleMode").value = 1 then ' The BCR pick
          if COMObject.Properties("ConstrainBillingCycle").Value then
            COMObject.Instance.Cycle.CycleTypeID = COMObject.Properties("Cycle@BillingCycleTypeID").Value
            COMObject.Instance.Cycle.Mode = CYCLE_MODE_BCR_CONSTRAINED
          else
            COMObject.Instance.Cycle.CycleTypeID = 0
            COMObject.Instance.Cycle.Mode = CYCLE_MODE_BCR
          end if  
    		
        elseif ComObject.Properties("CycleMode").value = 3 Then ' The EBCR pick
			    COMObject.Instance.Cycle.Mode = CYCLE_MODE_EBCR
			    COMObject.Instance.Cycle.CycleTypeID = COMObject.Properties("Cycle@EBCRBillingCycleTypeID").Value
        
        else ' The "fixed" pick
    		  COMObject.Instance.Cycle.Mode = CYCLE_MODE_FIXED
            Select Case CLng(COMObject.Properties("Cycle__CycleTypeID").Value)
            
                Case BILLING_CYCLE_MONTHLY
                       COMObject.Instance.Cycle.EndDayOfMonth = COMObject.Properties("Cycle@EndDayOfMonth_Monthly").value
                       
                Case BILLING_CYCLE_ON_DEMAND
                
                Case BILLING_CYCLE_DAILY        
                
                Case BILLING_CYCLE_WEEKLY
                
                Case BILLING_CYCLE_BI_WEEKLY                
                    i                                     = COMObject.Properties("Cycle@BiWeeklyComBox").Value
                    Set obj                               = Form("BI-WEEKLY.CycleType" & i)
                    obj.CopyTo COMObject.Instance.Cycle
                
                Case BILLING_CYCLE_SEMI_MONTHLY
            
                  	If (ComObject.Properties("cycle__CycleTypeID")) = BILLING_CYCLE_SEMI_MONTHLY then
                    
                  		If(ComObject.Properties("Cycle@EndDayOfMonth_SemiMonthly").Value>=ComObject.Properties("cycle__EndDayOfMonth2").Value)Then
                      
            	            EventArg.Error.Description = FrameWork.GetDictionary("MCM_ERROR_1000")
    			                Exit Function
    		              End If
    	             End if            
                   COMObject.Instance.Cycle.EndDayOfMonth = COMObject.Properties("Cycle@EndDayOfMonth_SemiMonthly").value	
                       
                Case BILLING_CYCLE_QUATERLY
                       COMObject.Instance.Cycle.StartMonth	= COMObject.Properties("Cycle@StartMonth_Quarterly").value
                       COMObject.Instance.Cycle.StartDay 	= COMObject.Properties("Cycle@StartDay_Quarterly").value
                       				
                Case BILLING_CYCLE_ANNUALLY
    							     COMObject.Instance.Cycle.StartMonth	= COMObject.Properties("Cycle@StartMonth_Annual").value
                       COMObject.Instance.Cycle.StartDay 	= COMObject.Properties("Cycle@StartDay_Annual").value
                Case BILLING_CYCLE_SEMIANNUALLY
    							     COMObject.Instance.Cycle.StartMonth	= COMObject.Properties("Cycle@StartMonth_SemiAnnual").value
                       COMObject.Instance.Cycle.StartDay 	= COMObject.Properties("Cycle@StartDay_SemiAnnual").value
    							
            End Select
          end if
          
       UpdateProperties = TRUE
    END FUNCTION  

    
    ' ---------------------------------------------------------------------------------------------------------------------------------------
    ' FUNCTION 		    : ComputeAndStoreBiWeeklyCycle
    ' PARAMETERS		  :
    ' DESCRIPTION 		:
    ' RETURNS		      :
    PRIVATE FUNCTION ComputeAndStoreBiWeeklyCycle(objMSIXProperty) ' As Boolean    
    
        Dim objCycle , objTimeSpan, i, objEnumType, strCurrentBiWeeklyPropertyString, strTMP

        Set  objEnumType = mdm_CreateObject(CVariables)            
        
        'First, handle the bi-weekly dates properly
        'OLD CODE: 'If(Not COMObject.Instance.Cycle.Relative)Then
        If (COMObject.Instance.Cycle.Mode = CYCLE_MODE_FIXED) Then
          COMObject.Instance.Cycle.ComputeCycleIDFromProperties
          Set objTimeSpan = COMObject.Instance.Cycle.GetTimeSpan(Date())
          strCurrentBiWeeklyPropertyString = "" & objTimeSpan.StartDate & " - " & objTimeSpan.EndDate
        End If
        
        For i = 1 to 14
        
            Set objCycle = mdm_CreateObject(MTProductCatalogMTPCycle)
      
            objCycle.CycleTypeID = BILLING_CYCLE_BI_WEEKLY
            objCycle.StartMonth  = BIWEEKLY_STARTMONTH 
            objCycle.StartDay    = CLng(i)
            objCycle.StartYear   = BIWEEKLY_STARTYEAR 
            objCycle.ComputeCycleIDFromProperties      
            Set objTimeSpan      = objCycle.GetTimeSpan(Date())
            
            strTMP = "" & objTimeSpan.StartDate & " - " & objTimeSpan.EndDate
            objEnumType.Add CStr(i), CLng(i), , , strTMP 
            
            ' Set the value
            If(UCase(strTMP)=UCase(strCurrentBiWeeklyPropertyString))Then
            
                objMSIXProperty.Value = i
            End If
            
            Set Form("BI-WEEKLY.CycleType" & i) = objCycle
        Next                     
        objMSIXProperty.AddValidListOfValues  objEnumType ' Associate the Cvariables object to the MSIX Properties
        ComputeAndStoreBiWeeklyCycle = TRUE        
    END FUNCTION


END CLASS
%>
