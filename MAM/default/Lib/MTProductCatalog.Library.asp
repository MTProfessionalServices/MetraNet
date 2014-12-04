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
' DIALOG	    : MetraTech Product Catalog Library
' DESCRIPTION	: Define Constants and Other
' AUTHOR	    : The UI Team 2.0
' VERSION	    : 2.0
'
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

'Prototype Objects
'PUBLIC CONST MTPriceableItem      = "MTProdCatProto.MTPriceableItem"
'PUBLIC CONST MTProductCatalog     = "MTProdCatProto.MTProductCatalog"
'PUBLIC CONST MTNonRecurringCharge = "MTProdCatProto.MTNonRecurringCharge"
'PUBLIC CONST MTRecurringCharge    = "MTProdCatProto.MTRecurringCharge"
'PUBLIC CONST MTFilter             = "MTProdCatProto.MTFilter"
'PUBLIC CONST MTTimeSpan           = "MTProdCatProto.MTTimeSpan"

'Real Objects
PUBLIC CONST MTPriceableItem      = "Metratech.MTPriceableItem.1"
PUBLIC CONST MTProductCatalog     = "Metratech.MTProductCatalog.1"
PUBLIC CONST MTNonRecurringCharge = "Metratech.MTNonRecurringCharge.1"
PUBLIC CONST MTRecurringCharge    = "Metratech.MTRecurringCharge.1"
PUBLIC CONST MTFilter             = "MTSQLRowset.MTDataFilter.1"
PUBLIC CONST MTTimeSpan           = "Metratech.MTPCTimeSpan.1"
PUBLIC CONST MTGSubMember         = "MTProductCatalog.MTGSubMember.1"

PUBLIC CONST UDRC_TYPE_NAME       = "Unit Dependent Recurring Charge"

'Public Enum MTOpertorType
PUBLIC CONST OPERATOR_TYPE_LIKE         = 1             'LIKE
PUBLIC CONST OPERATOR_TYPE_LIKE_W       = 2             'LIKE that adds wildcard to value (for convenience)
PUBLIC CONST OPERATOR_TYPE_EQUAL        = 3             ' =
PUBLIC CONST OPERATOR_TYPE_NOT_EQUAL    = 4             ' !=
PUBLIC CONST OPERATOR_TYPE_GREATER      = 5             ' >
PUBLIC CONST OPERATOR_TYPE_GREATER_EQUAL= 6             ' >=
PUBLIC CONST OPERATOR_TYPE_LESS         = 7             ' <
PUBLIC CONST OPERATOR_TYPE_LESS_EQUAL   = 8             ' <=


' Public Enum MTPriceableItemType - 10,20,30,40 are weird value because they need to be unic in the data base model.
PUBLIC CONST PI_TYPE_USAGE           = 10
PUBLIC CONST PI_TYPE_RECURRING       = 20
PUBLIC CONST PI_TYPE_RECURRING_UNIT_DEPENDENT = 25
PUBLIC CONST PI_TYPE_NON_RECURRING   = 30
PUBLIC CONST PI_TYPE_DISCOUNT        = 40
PUBLIC CONST PI_TYPE_USAGE_AGGREGATE = 15


'Public Enum MTchargeIn
PUBLIC CONST CHARGE_AREARS = TRUE
PUBLIC CONST CHARGE_ADVANCE = FALSE

'Public Enum MTProrateOn
PUBLIC CONST PRORATE_ACTUAL = 210
PUBLIC CONST PRORATE_FIXED = 211

'public Enum MtRecurringchargeEvent
PUBLIC CONST SUBSCRIPTION_ACTIVATION = 310
PUBLIC CONST SUBSCRIPTION_DEACTIVATION = 311
PUBLIC CONST SUBSCRIPTION_CHANGE = 312
PUBLIC CONST BILLING_PERIOD = 313


PUBLIC CONST MTPROPERTY_EXTENDED    = TRUE

' Public Enum MTPCDateType
PUBLIC CONST PCDATE_TYPE_ABSOLUTE				= 1
PUBLIC CONST PCDATE_TYPE_SUBSCRIPTION		= 2
PUBLIC CONST PCDATE_TYPE_BILLCYCLE			= 3
PUBLIC CONST PCDATE_TYPE_NULL						= 4

' Specifies how distribution needs to be configured for a subscription based on this product offering
PUBLIC CONST DISTRIBUTION_REQUIREMENT_TYPE_NONE 									 = 1
PUBLIC CONST DISTRIBUTION_REQUIREMENT_TYPE_ACCOUNT 								 = 2
PUBLIC CONST DISTRIBUTION_REQUIREMENT_TYPE_ACCOUNT_OR_PROPORTIONAL = 3

'Pricelist Types
PUBLIC CONST PRICELIST_TYPE_ICB = 0
PUBLIC CONST PRICELIST_TYPE_REGULAR = 1
PUBLIC CONST PRICELIST_TYPE_PO = 2

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			: GetProductCatalogObject
' PARAMETERS		:
' DESCRIPTION 	:
' RETURNS			  :
PUBLIC FUNCTION GetProductCatalogObject()
'  Set GetProductCatalogObject = Server.CreateObject(MTProductCatalog)
 ' GetProductCatalogObject.SetSessionContext(Session(FRAMEWORK_SECURITY_SESSION_CONTEXT_SESSION_NAME))
'  GetProductCatalogObject.SetSessionContextAccountID( Session("SESSION:LOGIN_LIB_ACCOUNTID") )
    Set GetProductCatalogObject = FrameWork.ProductCatalog
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			: MTPriceableItemTypeString
' PARAMETERS		:
' DESCRIPTION 	:
' RETURNS			  :
PUBLIC FUNCTION GetMTPriceableItemTypeString(MTPriceableItemTypeEnumType)
  
  Select Case MTPriceableItemTypeEnumType      
    
      Case PI_TYPE_USAGE          : GetMTPriceableItemTypeString = "Usage"
      Case PI_TYPE_RECURRING      : GetMTPriceableItemTypeString = "Recurring"
      Case PI_TYPE_NON_RECURRING  : GetMTPriceableItemTypeString = "NonRecurring"
      Case PI_TYPE_DISCOUNT       : GetMTPriceableItemTypeString = "Discount"
      Case Else
                                    GetMTPriceableItemTypeString = "Unknown"
  End Select
END FUNCTION

'End Enum

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			: SetMSIXPropertyTypeToPriceableItemEnumType
' PARAMETERS		:
' DESCRIPTION 	: Set the objMSIXProperty type to enum type Usage Kind.
'                 Because the enum type does not exist yet I hard code the values.
' RETURNS			  :
PUBLIC FUNCTION SetMSIXPropertyTypeToPriceableItemEnumType(objMSIXProperty)

    Dim objPriceableItemEnumType
    
    ' Temporary Syntax
    Set objPriceableItemEnumType = mdm_CreateObject(CVariables)    
    objPriceableItemEnumType.Add "Usage"        , PI_TYPE_USAGE         , , , "Usage"
    objPriceableItemEnumType.Add "Recurring"    , PI_TYPE_RECURRING     , , , "Recurring Charge"
    objPriceableItemEnumType.Add "NonRecurring" , PI_TYPE_NON_RECURRING , , , "Non Recurring Charge"
    objPriceableItemEnumType.Add "Discount"     , PI_TYPE_DISCOUNT      , , , "Discount"        
    
    ' Associate the Cvariables object to the MSIX Properties
    objMSIXProperty.AddValidListOfValues objPriceableItemEnumType
    
    ' Pseudo Correct Syntax
    'objMSIXProperty.PropertyType("ENUM","Metratech.com","UsageKind")
    
    SetMSIXPropertyTypeToPriceableItemEnumType = TRUE
END FUNCTION



' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			: SetMSIXPropertyTypeToChargeInEnumType
' PARAMETERS		:
' DESCRIPTION 	: Set the objMSIXProperty type to enum type Usage Kind.
'                 Because the enum type does not exist yet I hard code the values.
' RETURNS			  :
PUBLIC FUNCTION SetMSIXPropertyTypeToChargeInEnumType(objMSIXProperty)

    Dim objChargeInEnumType
    
    ' Temporary Syntax
    Set  objChargeInEnumType = mdm_CreateObject(CVariables)    
     objChargeInEnumType.Add "Arears" , CHARGE_AREARS , , , "Arears"
     objChargeInEnumType.Add "Advance", CHARGE_ADVANCE, , , "Advance"
    
    ' Associate the Cvariables object to the MSIX Properties
    objMSIXProperty.AddValidListOfValues  objChargeInEnumType
    
    ' Pseudo Correct Syntax
    'objMSIXProperty.PropertyType("ENUM","Metratech.com","UsageKind")
    
    SetMSIXPropertyTypeToChargeInEnumType = TRUE
END FUNCTION



' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			: SetMSIXPropertyTypeToProrateOnEnumType
' PARAMETERS		:
' DESCRIPTION 	: Set the objMSIXProperty type to enum type Usage Kind.
'                 Because the enum type does not exist yet I hard code the values.
' RETURNS			  :
PUBLIC FUNCTION SetMSIXPropertyTypeToProrateOnEnumType(objMSIXProperty)

    Dim objProrateOnEnumType
    
    ' Temporary Syntax
    Set  objProrateOnEnumType = mdm_CreateObject(CVariables)    
     objProrateOnEnumType.Add "Actual number of days in  month" , PRORATE_ACTUAL , , , "Actual number of days in  month"
     objProrateOnEnumType.Add "Fixed number of 30 days in month", PRORATE_FIXED, , , "Fixed number of 30 days in month"
    
    ' Associate the Cvariables object to the MSIX Properties
    objMSIXProperty.AddValidListOfValues  objProrateOnEnumType
    
    ' Pseudo Correct Syntax
    'objMSIXProperty.PropertyType("ENUM","Metratech.com","UsageKind")
    
    SetMSIXPropertyTypeToProrateOnEnumType = TRUE
END FUNCTION



' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			: SetMSIXPropertyTypeToProrateOnEnumType
' PARAMETERS		:
' DESCRIPTION 	: Set the objMSIXProperty type to enum type Usage Kind.
'                 Because the enum type does not exist yet I hard code the values.
' RETURNS			  :
PUBLIC FUNCTION SetMSIXPropertyTypeToDayOfMonthEnumType(objMSIXProperty)

    Dim objEnumType,i
    

    Set  objEnumType = mdm_CreateObject(CVariables)    
    For i=1 to 31
    
         objEnumType.Add CStr(i), CLng(i), , , Cstr(i)
    Next             
    objMSIXProperty.AddValidListOfValues  objEnumType ' Associate the Cvariables object to the MSIX Properties    
    SetMSIXPropertyTypeToDayOfMonthEnumType = TRUE
END FUNCTION



' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			: SetMSIXPropertyTypeToRecurringChargeEnumType
' PARAMETERS		:
' DESCRIPTION 	: Set the objMSIXProperty type to enum type Usage Kind.
'                 Because the enum type does not exist yet I hard code the values.
' RETURNS			  :
PUBLIC FUNCTION SetMSIXPropertyTypeToRecurringChargeEnumType(objMSIXProperty)

    Dim objRecurringChargeEnumType
    
    ' Temporary Syntax
    Set  objRecurringChargeEnumType = mdm_CreateObject(CVariables)    
     objRecurringChargeEnumType.Add "Subscription Activation" , SUBSCRIPTION_ACTIVATION , , , "Subscription Activation"
     objRecurringChargeEnumType.Add "Subscription Deactivation" , SUBSCRIPTION_DEACTIVATION , , , "Subscription Deactivation"
	 objRecurringChargeEnumType.Add "Subscription Change(Switch from one to another)" , SUBSCRIPTION_CHANGE , , , "Subscription Change(Switch from one to another)"
   	 objRecurringChargeEnumType.Add "Billing Period Rollover" , BILLING_PERIOD , , , "Billing Period Rollover"

    ' Associate the Cvariables object to the MSIX Properties
    objMSIXProperty.AddValidListOfValues  objRecurringChargeEnumType
       
    SetMSIXPropertyTypeToRecurringChargeEnumType = TRUE
END FUNCTION



' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			: AddBillingCycleEnumTypeIDToDictionary
' PARAMETERS		:
' DESCRIPTION 	: 
' RETURNS			  :
PUBLIC FUNCTION BillingCycle_PreProcess()

    FrameWork.Dictionary.Add "BILLING_CYCLE_MONTHLY",       BILLING_CYCLE_MONTHLY
    FrameWork.Dictionary.Add "BILLING_CYCLE_ON_DEMAND",     BILLING_CYCLE_ON_DEMAND
    FrameWork.Dictionary.Add "BILLING_CYCLE_DAILY",         BILLING_CYCLE_DAILY
    FrameWork.Dictionary.Add "BILLING_CYCLE_WEEKLY",        BILLING_CYCLE_WEEKLY
    FrameWork.Dictionary.Add "BILLING_CYCLE_BI_WEEKLY",     BILLING_CYCLE_BI_WEEKLY
    FrameWork.Dictionary.Add "BILLING_CYCLE_SEMI_MONTHLY",  BILLING_CYCLE_SEMI_MONTHLY
    FrameWork.Dictionary.Add "BILLING_CYCLE_QUATERLY",      BILLING_CYCLE_QUATERLY
    FrameWork.Dictionary.Add "BILLING_CYCLE_ANNUALY",       BILLING_CYCLE_ANNUALY
    FrameWork.Dictionary.Add "BILLING_CYCLE_SEMIANNUALY",  BILLING_CYCLE_SEMIANNUALY
    
    AddBillingCycleEnumTypesIDToDictionary = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			: CheckEffectiveDates
' PARAMETERS		:
' DESCRIPTION 	: 
' RETURNS			  :
PUBLIC FUNCTION CheckEffectiveDates(startDate, endDate, errMessage, booSubscription)
   CheckEffectiveDates = TRUE

   '---------------------------------------------------------------------     
   ' SUBSCRIPTION CASE   
   '---------------------------------------------------------------------
   If CBool(booSubscription) Then
     ' Both Start and End dates cannot be null
     If Len(startDate) = 0 and Len(endDate) = 0 Then
       errMessage = mam_GetDictionary("MAM_ERROR_5000")
       CheckEffectiveDates = FALSE
       Exit Function
     End If
  
     ' start date cannot be null
     If Len(startDate) = 0 Then
        errMessage = mam_GetDictionary("MAM_ERROR_5001")
        CheckEffectiveDates = FALSE
        Exit Function
     End IF
 
'
'     COMMENTED BECAUSE WE CAN SUBSCRIBE IN THE PAST
'     
'     ' If end date is null, start date must be today or in the future
'     If Len(endDate) = 0 Then
'       If DateDiff("d", FrameWork.MetraTimeGMTNow(), CDate(startDate)) < 0 Then
'         errMessage = mam_GetDictionary("MAM_ERROR_5002")     
'         CheckEffectiveDates = FALSE
'         Exit Function
'       Else
'         Exit Function  
'       End If
'     End If
  
     ' 
     ' -- End date can not be before start date --
     '
     If Len(endDate) Then '  End date must be defined to do this test
     
         If DateDiff("h", CDate(startDate), CDate(endDate)) < 0 Then
         
           errMessage = mam_GetDictionary("MAM_ERROR_5003")
           CheckEffectiveDates = FALSE
           Exit Function
         End If
     End If
     
     '
     ' -- ' A subscription must be at least more than an hour... -- 
     '
     If DateDiff("h", CDate(startDate), CDate(endDate)) = 0 Then
     
         errMessage           = mam_GetDictionary("MAM_ERROR_5004")
         CheckEffectiveDates  = FALSE
         Exit Function
     End IF
   Else
    '---------------------------------------------------------------------        
    ' RATE SCHEDULE
    '---------------------------------------------------------------------     
    ' Both Start and End dates can be null
     If Len(startDate) = 0 and Len(endDate) = 0 Then
       CheckEffectiveDates = TRUE
       Exit Function
     End If
  
     ' If start date is null, end date must be after today
     If Len(startDate) = 0 Then
       If DateDiff("d", FrameWork.MetraTimeGMTNow(), CDate(endDate)) < 0 Then
         errMessage = mam_GetDictionary("MAM_ERROR_6001")
         CheckEffectiveDates = FALSE
         Exit Function
       Else
         Exit Function  
       End If
     End IF
     
     ' If end date is null, start date must be today or in the future
     If Len(endDate) = 0 Then
       If DateDiff("d", FrameWork.MetraTimeGMTNow(), CDate(startDate)) < 0 Then
         ' Now we can ICB in the past!  3-22-2002        
         'errMessage = mam_GetDictionary("MAM_ERROR_6002")     
         'CheckEffectiveDates = FALSE
         Exit Function
       Else
         Exit Function  
       End If
     End If
  
     ' End date can not be before start date
     If DateDiff("h", CDate(startDate), CDate(endDate)) < 0 Then
       errMessage = mam_GetDictionary("MAM_ERROR_6003")
       CheckEffectiveDates = FALSE
       Exit Function
     End If
     
     ' A ICB Rate must be at least more than an hour...
     'If DateDiff("h", CDate(startDate), CDate(endDate)) = 0 Then
     '  errMessage = mam_GetDictionary("MAM_ERROR_6004")
     '  CheckEffectiveDates = FALSE
     '  Exit Function
     'End If
   End If      
END FUNCTION


FUNCTION GetDateFieldString(datetype)
  Select Case CLng(datetype)
    Case PCDATE_TYPE_ABSOLUTE
      GetDateFieldString = FrameWork.GetDictionary("TEXT_ABSOLUTE_DATE_TYPE") '"Absolute"
    Case PCDATE_TYPE_SUBSCRIPTION
      GetDateFieldString = FrameWork.GetDictionary("TEXT_SUBSCRIPTIONRELATIVE_DATE_TYPE") '"Subscription Relative"
    Case PCDATE_TYPE_BILLCYCLE
      GetDateFieldString = FrameWork.GetDictionary("TEXT_BILLINGCYCLE_DATE_TYPE") '"Next Billing Cycle"
    Case Else
      GetDateFieldString = FrameWork.GetDictionary("TEXT_NONE")
  End Select
END FUNCTION

'Helper function to determine if a given type id is a UDRC type
PUBLIC FUNCTION IsTypeIdUDRC(iTypeId)
  Dim objType
  set objType = GetProductCatalogObject().GetPriceableItemType(iTypeId)
  
  IsTypeIdUDRC = IsTypeUDRC(objType)
  
END FUNCTION

'Helper function to determine if a given type object corresponds to a UDRC type
PUBLIC FUNCTION IsTypeUDRC(objType)
  if objType.Kind = PI_TYPE_RECURRING_UNIT_DEPENDENT then
   IsTypeUDRC = TRUE
  else
   IsTypeUDRC = FALSE
  end if
  
END FUNCTION

%>