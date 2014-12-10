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

'Would we like to use the prototype objects or the real objects?

'PUBLIC CONST MTProductCatalog     = "MTProdCatProto.MTProductCatalog"
PUBLIC CONST UDRC_RATING_TYPE_TIERED  = 0
PUBLIC CONST UDRC_RATING_TYPE_TAPERED = 1


PUBLIC CONST MTProductCatalog     = "Metratech.MTProductCatalog"
PUBLIC CONST MTProductCatalogMTPCycle     = "Metratech.MTPCCycle.1"
PUBLIC CONST MTFilter             = "MTSQLRowset.MTDataFilter"

PUBLIC CONST MTPriceableItem      = "MTProdCatProto.MTPriceableItem"
PUBLIC CONST MTNonRecurringCharge = "MTProdCatProto.MTNonRecurringCharge"
PUBLIC CONST MTRecurringCharge    = "MTProdCatProto.MTRecurringCharge"

PUBLIC CONST MTTimeSpan           = "MTProdCatProto.MTTimeSpan"

'Public Enum MTOpertorType
PUBLIC CONST OPERATOR_TYPE_LIKE          = 1             'LIKE
PUBLIC CONST OPERATOR_TYPE_LIKE_W        = 2             'LIKE that adds wildcard to value (for convenience)
PUBLIC CONST OPERATOR_TYPE_EQUAL         = 3             ' =
PUBLIC CONST OPERATOR_TYPE_NOT_EQUAL     = 4             ' !=
PUBLIC CONST OPERATOR_TYPE_GREATER       = 5             ' >
PUBLIC CONST OPERATOR_TYPE_GREATER_EQUAL = 6             ' >=
PUBLIC CONST OPERATOR_TYPE_LESS          = 7             ' <
PUBLIC CONST OPERATOR_TYPE_LESS_EQUAL    = 8             ' <=


' Public Enum MTPriceableItemType - 10,20,30,40 are weird value because they need to be unic in the data base model.
PUBLIC CONST PI_TYPE_USAGE          = 10
PUBLIC CONST PI_TYPE_RECURRING      = 20
PUBLIC CONST PI_TYPE_RECURRING_UNIT_DEPENDENT = 25
PUBLIC CONST PI_TYPE_NON_RECURRING  = 30
PUBLIC CONST PI_TYPE_DISCOUNT       = 40
PUBLIC CONST PI_TYPE_USAGE_AGGREGATE = 15

' Public Enum MTPCDateType
PUBLIC CONST PCDATE_TYPE_NO_DATE        = 0
PUBLIC CONST PCDATE_TYPE_ABSOLUTE       = 1
PUBLIC CONST PCDATE_TYPE_SUBSCRIPTION   = 2
PUBLIC CONST PCDATE_TYPE_BILLCYCLE      = 3
PUBLIC CONST PCDATE_TYPE_NULL           = 4

'Public Enum MTchargeIn
PUBLIC CONST CHARGE_AREARS = FALSE
PUBLIC CONST CHARGE_ADVANCE = TRUE

'Public Enum MTProrateOn
PUBLIC CONST PRORATE_ACTUAL = 210
PUBLIC CONST PRORATE_FIXED = 211


'Public Enum MTProrateLength
PUBLIC CONST PRORATE_ACTUAL_LENGTH = FALSE
PUBLIC CONST PRORATE_FIXED_LENGTH = TRUE

PUBLIC CONST PRICELIST_TYPE_ICB = 0
PUBLIC CONST PRICELIST_TYPE_REGULAR = 1
PUBLIC CONST PRICELIST_TYPE_PO = 2


'PUBLIC CONST BILLING_PERIOD = 0

'// ----------------------------------------------------------------
'// Enum:        MTNonRecurringEventType
'// Description: type of event, causing a non-recurring charge.
'typedef [uuid(EDA93BBE-209C-48d5-A566-409DCC587767), version(1.0)]
'enum{' NREVENT_TYPE_MIN = 0,
'    NREVENT_TYPE_UNKNOWN = 0,
'    NREVENT_TYPE_SUBSCRIBE = 1,
'    NREVENT_TYPE_UNSUBSCRIBE = 2,
'    NREVENT_TYPE_CHANGE_SUBSCRIPTION = 3,
' NREVENT_TYPE_MAX = 3
'} MTNonRecurringEventType
'
PUBLIC CONST NREVENT_TYPE_UNKNOWN 				= 0
PUBLIC CONST NREVENT_TYPE_SUBSCRIBE 			= 1
PUBLIC CONST NREVENT_TYPE_UNSUBSCRIBE 			= 2
'PUBLIC CONST NREVENT_TYPE_CHANGE_SUBSCRIPTION 	= 3
 
PUBLIC CONST MTPROPERTY_EXTENDED    = TRUE

PUBLIC CONST CounterType_PARAM_PRODUCT_VIEW_PROPERTY = 0
PUBLIC CONST CounterType_PARAM_PRODUCT_VIEW = 1
PUBLIC CONST CounterType_PARAM_CONST = 2  ' This may not be valid in the future

' We will integrate all the function in this class after the mile stone.
' Since I needed to add a new function a I did it in the class cause, I like it.


PUBLIC ProductCatalogHelper

Set ProductCatalogHelper = New CProductCatalogHelper

  CLASS CProductCatalogHelper
  
    PUBLIC FUNCTION GetUDRCRatingTypeDescription(lngRatingType)
      
        Select Case CLNG(lngRatingType)
            Case UDRC_RATING_TYPE_TIERED  : GetUDRCRatingTypeDescription = FrameWork.GetDictionary("TEXT_TIERED")        
            Case UDRC_RATING_TYPE_TAPERED : GetUDRCRatingTypeDescription = FrameWork.GetDictionary("TEXT_TAPERED")
            Case Else
                GetUDRCRatingTypeDescription = "Unknown"
        End Select
    END FUNCTION

    PUBLIC FUNCTION UpdateForUDRC(EventArg)
        Dim EnumArray,e,ee, lngTypeError
        
        UpdateForUDRC = FALSE
        EnumArray     = Split(COMObject.Properties("UDRCUnitValueEnumeration").Value," ")        
        lngTypeError  = 0

        ' Delete all        
        Do While COMObject.Instance.GetUnitValueEnumerations.Count
           COMObject.Instance.RemoveUnitValueEnumeration COMObject.Instance.GetUnitValueEnumerations.Item(1)
        Loop
        
        ' Add All
        For Each e in EnumArray
        
            ee = Trim(e)            
            If Len(ee) Then
            
                If IsNumeric(ee) Then
                    COMObject.Instance.AddUnitValueEnumeration "" & ee
                Else                
                    lngTypeError = lngTypeError + 1                    
                End If
            End If
        Next        
        If(lngTypeError) Then
            EventArg.Error.Number = Service.Tools.MakeItUserVisibleMTCOMError(1006)
            EventArg.Error.Description = FrameWork.Dictionary.Item("MCM_ERROR_1006").Value
            Exit Function
        End If
        UpdateForUDRC = TRUE
    END FUNCTION
    
    PUBLIC FUNCTION CheckAndInitializeForUDRC(booEditMode)
        ' -- UDRC Support --
        FrameWork.Dictionary().Add "IsUDRC", IIF(ProductCatalogHelper.IsRecurringChargeTemplateUDRC(COMObject.Instance),TRUE,FALSE)
        
        If Not COMObject.Properties.Exist("UDRCUnitValueEnumeration") Then
            COMObject.Properties.Add "UDRCUnitValueEnumeration", MSIXDEF_TYPE_STRING,0,FALSE, Empty
        End If
        COMObject.Properties("UDRCUnitValueEnumeration").Caption = FrameWork.Dictionary.Item("TEXT_UDRC_UNIT_VALUE_ENUMERATION")
        COMObject.Properties("UDRCUnitValueEnumeration").Value   = ProductCatalogHelper.GetUDRCUnitValueEnumerationAsString
        
        If Not COMObject.Properties("RatingType").IsEnumType Then 
            COMObject.Properties("RatingType").AddValidListOfValues Array(UDRC_RATING_TYPE_TIERED,UDRC_RATING_TYPE_TAPERED),Array(FrameWork.Dictionary.Item("TEXT_TIERED"),FrameWork.Dictionary.Item("TEXT_TAPERED"))
        End If
        
        COMObject.Properties("UDRCUnitValueEnumeration").Caption  = FrameWork.Dictionary.Item("TEXT_UDRC_UNIT_VALUE_ENUMERATION")        
        COMObject.Properties("IntegerUnitValue").Caption          = FrameWork.Dictionary.Item("TEXT_UDRCIntegerUnitValue")
        COMObject.Properties("MinUnitValue").Caption              = FrameWork.Dictionary.Item("TEXT_UDRCMinUnitValue")
        COMObject.Properties("MaxUnitValue").Caption              = FrameWork.Dictionary.Item("TEXT_UDRCMaxUnitValue")
        
        CheckAndInitializeForUDRC = TRUE
    END FUNCTION  
    
    PUBLIC FUNCTION GetUDRCUnitValueEnumerationAsString()
        Dim e, strEnum

        For Each e In COMObject.Instance.GetUnitValueEnumerations
            strEnum = strEnum & e & " "
        Next    
        If Len(strEnum) Then 
            GetUDRCUnitValueEnumerationAsString = Mid(strEnum,1,Len(strEnum)-1)
        End If
    END FUNCTION
  
    PUBLIC FUNCTION IsRecurringChargeTemplateUDRC(objRCTemplate)
        IsRecurringChargeTemplateUDRC = CBool ( IsTypeUDRC(objRCTemplate.PriceAbleItemType) ) 
    END FUNCTION
    
    
    PUBLIC FUNCTION IsTypeIdUDRC(iTypeId)
      Dim objType
      set objType = GetProductCatalogObject().GetPriceableItemType(iTypeId)
      
      IsTypeIdUDRC = IsTypeUDRC(objType)
      
    END FUNCTION

    PUBLIC FUNCTION IsTypeUDRC(objType)
      
      if objType.Kind = PI_TYPE_RECURRING_UNIT_DEPENDENT then
       IsTypeUDRC = TRUE
      else
       IsTypeUDRC = FALSE
      end if
      
    END FUNCTION
    
    'Shortcut method to determine if Kind is one of the recurring charge types    
    PUBLIC FUNCTION IsRecurringChargeKind(iKindId)
    
      If iKindId = PI_TYPE_RECURRING OR iKindId = PI_TYPE_RECURRING_UNIT_DEPENDENT then
        IsRecurringChargeKind = TRUE
      Else
        IsRecurringChargeKind = FALSE
      End If
      
    END FUNCTION
    
    ' ---------------------------------------------------------------------------------------------------------------------------------------
    ' FUNCTION 		    : CheckPCInstanceAttributesForUI
    ' PARAMETERS		  :
    ' DESCRIPTION 		: Check and apply rules for each MTProperties attribute editable and overrideable. In the end set 
    '                   the MSIXHandler COMObject propertie Enabled to false to true. Support Compound COM Object like
    '                   RecurringCharge.Cycle. The compound com object property name convention is : for
    '
    '                     RecurringCharge.Name        - Name
    '                     RecurringCharge.Cycle.ID    - Cycle__ID
    '
    ' RETURNS		      :
    PUBLIC FUNCTION CheckAttributesForUI(objMSIXCOMObject,objPCInstance,booIsInstance,strMSIXCOMObjectPropertyPrefix)
    
      Dim objMSIXProperty, objMTProperty, objMTAttribute, objSubInstance, strTmpPropertyName, objMTProperty2,objMTProperty3

      For Each objMTProperty In objPCInstance.Properties

        'If objMTProperty.Name="UnitValueEnumeration" Then ' This Property is implemted as a collection so is still an object but does not implement IProperties        
        '   stop
        'end if
      
        If objMTProperty.Attributes("editable").value Then
  
            If (Not objMTProperty.Attributes("overrideable").value)And(booIsInstance) Then
            
              If UCase(objMTProperty.DataTypeAsString)="OBJECT" Then
      
                        ' If this property is a sub object, then we will assume that all the attributes are set the same as the parent
                        ' Eventually if a sub object attributes set differently than the parent we can call this routine recursively          
                        Set objSubInstance = Eval("objPCInstance." & objMTProperty.Name)
                        
                        If UCase(Typename(objSubInstance))="IMTCOLLECTION" Then ' Support case UDRC Unit property UnitValueEnumeration which is an
                                                                                ' object but one that does not implement IMTProperties interfce
                                                                                ' so make a case to treat the property as a regular property
                                                                              
                            ' HARD CODE - Case for the property since  UnitValueEnumeration value is instance of a MTCOLLECTION
                            ' I cannot put it in a HTML file so I created a string property called UDRCUnitValueEnumeration.
                            ' So here it is UDRCUnitValueEnumeration that has not be enbaled = false.                          
                            If objMTProperty.Name="UnitValueEnumeration" Then COMObject.Properties("UDRCUnitValueEnumeration").Enabled = FALSE                                                                                
                                                                                
                            strTmpPropertyName = objMTProperty.Name
                            If(objMSIXCOMObject.Properties.Exist(strTmpPropertyName))Then objMSIXCOMObject.Properties.Item(strTmpPropertyName).Enabled = FALSE ' Set the cannot edit the property in any cases                                                                                                        
                        Else
                                            
                            For Each objMTProperty2 In objMSIXCOMObject.Properties
                            
                                  If InStr(UCase(objMTProperty2.Name),UCase(objMTProperty.Name & "@"))= 1 Then
                                  
                                      objMTProperty2.Enabled = FALSE ' Set the cannot edit the property in any cases
                                  End If
                                  If InStr(UCase(objMTProperty2.Name),UCase(objMTProperty.Name & "__"))= 1 Then
                                  
                                      objMTProperty2.Enabled = FALSE ' Set the cannot edit the property in any cases
                                  End If                                
                            Next                        
                        End If
                  Else                    
                        strTmpPropertyName = objMTProperty.Name
                        If(objMSIXCOMObject.Properties.Exist(strTmpPropertyName))Then objMSIXCOMObject.Properties.Item(strTmpPropertyName).Enabled = FALSE ' Set the cannot edit the property in any cases
                End If
            Else
                ' We keep the enabled status set by the programmer
            End If
        Else
            objMSIXCOMObject.Properties.Item(objMTProperty.Name).Enabled = FALSE ' Set the cannot edit the property in any cases
        End if

      Next  
      
      ' % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
      '
      ' H O R R I B L E   H A C K
      '
      ' Process the case of alias property that is to say property that contains a @ in their name - see file CProductCatalogBillingCycle.class.asp
      ' 
      ' To solve the probleme correctly I like to rename of the property name of the sub dialog billing cycle.
      ' I am not going to do so now because of the mile stone.
      '
      ' So What I do is that property that contains  @ are the alias property of the billing cycle and set ENABLED=FALSE
      ' because that will produce the right behavior
      '
      ' % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
   '   If(IsEmpty(strMSIXCOMObjectPropertyPrefix))THen
    '      
     '     For Each objMSIXProperty In objMSIXCOMObject.Properties
      '    
       '       If(InStr(objMSIXProperty.Name,"@"))Then
        '          If booIsInstance Then
         '         
'                      objMSIXProperty.Enabled = FALSE
 '                 End If
  '            End If              
   '       Next
    '  End If

      CheckAttributesForUI = TRUE
    END FUNCTION
    
END CLASS

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			: GetProductCatalogObject
' PARAMETERS		:
' DESCRIPTION 	:
' RETURNS			  :
PUBLIC FUNCTION GetProductCatalogObject
  Set GetProductCatalogObject = Server.CreateObject(MTProductCatalog)
  GetProductCatalogObject.SetSessionContext(Session("FRAMEWORK_SECURITY_SESSION_CONTEXT_SESSION_NAME"))
  'GetProductCatalogObject.SetSessionContextAccountID( session("SESSION:LOGIN_LIB_ACCOUNTID") )
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
     objChargeInEnumType.Add "Arrears" , CHARGE_AREARS , , , FrameWork.GetDictionary("TEXT_ADVANCE")
     objChargeInEnumType.Add "Advance", CHARGE_ADVANCE, , , FrameWork.GetDictionary("TEXT_ARREARS")
    
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
' FUNCTION 			: SetMSIXPropertyTypeToProrationLengthOnEnumType
' PARAMETERS		:
' DESCRIPTION 	: Set the objMSIXProperty type to enum type prorationlength.
'                 
' RETURNS			  :
PUBLIC FUNCTION SetMSIXPropertyTypeToProrationLengthOnEnumType(objMSIXProperty)

    Dim objProrateOnEnumType
    
    ' Temporary Syntax
    Set  objProrateOnEnumType = mdm_CreateObject(CVariables)    
     objProrateOnEnumType.Add "Actual" , PRORATE_ACTUAL_LENGTH , , , "Actual"
     objProrateOnEnumType.Add "Fixed", PRORATE_FIXED_LENGTH, , , "Fixed"
    
    ' Associate the Cvariables object to the MSIX Properties
    objMSIXProperty.AddValidListOfValues  objProrateOnEnumType
    
    ' Pseudo Correct Syntax
    'objMSIXProperty.PropertyType("ENUM","Metratech.com","UsageKind")
    
    SetMSIXPropertyTypeToProrationLengthOnEnumType = TRUE
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
    For i=1 to 27
      objEnumType.Add CStr(i), CLng(i), , , Cstr(i)
    Next             
	  objEnumType.Add "31", "31", , , "End Of Month"
	
    objMSIXProperty.AddValidListOfValues  objEnumType ' Associate the Cvariables object to the MSIX Properties    
    SetMSIXPropertyTypeToDayOfMonthEnumType = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			: SetMSIXPropertyTypeToProrateOnEnumType
' PARAMETERS		:
' DESCRIPTION 	: Set the objMSIXProperty type to enum type Usage Kind.
'                 Because the enum type does not exist yet I hard code the values.
' RETURNS			  :
PUBLIC FUNCTION SetMSIXPropertyTypeToDayOfQuarterlyEnumType(objMSIXProperty)

    Dim objEnumType,i

    Set  objEnumType = mdm_CreateObject(CVariables)    
    For i=1 to 27
    
         objEnumType.Add CStr(i), CLng(i), , , Cstr(i)
    Next             
	
    objMSIXProperty.AddValidListOfValues  objEnumType ' Associate the Cvariables object to the MSIX Properties    
    SetMSIXPropertyTypeToDayOfQuarterlyEnumType = TRUE
END FUNCTION




' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			: SetMSIXPropertyTypeToProrateOnEnumType
' PARAMETERS		:
' DESCRIPTION 	: Set the objMSIXProperty type to enum type Usage Kind.
'                 Because the enum type does not exist yet I hard code the values.
' RETURNS			  :
PUBLIC FUNCTION SetMSIXPropertyTypeToFullDayOfMonthEnumType(objMSIXProperty)

    Dim objEnumType,i

    Set  objEnumType = mdm_CreateObject(CVariables)    
    For i=1 to 31
    
         objEnumType.Add CStr(i), CLng(i), , , Cstr(i)
    Next             
	
    objMSIXProperty.AddValidListOfValues  objEnumType ' Associate the Cvariables object to the MSIX Properties    
    SetMSIXPropertyTypeToFullDayOfMonthEnumType = TRUE
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
     objRecurringChargeEnumType.Add "Subscription" , NREVENT_TYPE_SUBSCRIBE , , , "Subscription"
     objRecurringChargeEnumType.Add "UnSubscription" , NREVENT_TYPE_UNSUBSCRIBE , , , "UnSubscription"
	   'objRecurringChargeEnumType.Add "Subscription Change" , NREVENT_TYPE_CHANGE_SUBSCRIPTION , , , "Subscription Change"
'   	 objRecurringChargeEnumType.Add "Billing Period Rollover" , BILLING_PERIOD , , , "Billing Period Rollover"

	 
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
    FrameWork.Dictionary.Add "BILLING_CYCLE_ANNUALLY",       BILLING_CYCLE_ANNUALLY
    FrameWork.Dictionary.Add "BILLING_CYCLE_SEMIANNUALLY",       BILLING_CYCLE_SEMIANNUALLY
   
    AddBillingCycleEnumTypesIDToDictionary = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			: GetEffectiveDateTextByType
' PARAMETERS		:
' DESCRIPTION 	: 
' RETURNS			  :
PUBLIC FUNCTION GetEffectiveDateTextByType(a_type, dt_date, int_offset, bStart)
  Dim strText
  strText = ""
  
  Select Case Clng(a_type)
  Case PCDATE_TYPE_NULL
    if bStart then
      strText = strText & FrameWork.GetDictionary("TEXT_NULL_START_DATE_TYPE")
    else
  	  strText = strText & FrameWork.GetDictionary("TEXT_NULL_END_DATE_TYPE")
    end if
  Case PCDATE_TYPE_ABSOLUTE
  	strText = strText & FrameWork.GetDictionary("TEXT_ABSOLUTE_DATE_TYPE") & " " & dt_date
  Case PCDATE_TYPE_SUBSCRIPTION
  	strText = strText & CStr(int_offset) & " " & FrameWork.GetDictionary("TEXT_SUBSCRIPTIONRELATIVE_DATE_TYPE")
  Case PCDATE_TYPE_BILLCYCLE
  	strText = strText & FrameWork.GetDictionary("TEXT_BILLINGCYCLE_DATE_TYPE") & " " & dt_date
  End Select
  
  GetEffectiveDateTextByType = strText
  
END FUNCTION

PUBLIC FUNCTION mcmGetPriceableItemKindDisplayName(iPriceableItemKind)
    Select Case iPriceableItemKind 
    Case PI_TYPE_USAGE 
      mcmGetPriceableItemKindDisplayName = FrameWork.GetDictionary("TEXT_KEYTERM_USAGE_CHARGE")
    Case PI_TYPE_RECURRING
      mcmGetPriceableItemKindDisplayName = FrameWork.GetDictionary("TEXT_KEYTERM_RECURRING_CHARGE")
    Case PI_TYPE_NON_RECURRING
      mcmGetPriceableItemKindDisplayName = FrameWork.GetDictionary("TEXT_KEYTERM_NON_RECURRING_CHARGE")
    Case PI_TYPE_DISCOUNT
      mcmGetPriceableItemKindDisplayName = FrameWork.GetDictionary("TEXT_KEYTERM_DISCOUNT")
    Case PI_TYPE_USAGE_AGGREGATE
      mcmGetPriceableItemKindDisplayName = FrameWork.GetDictionary("TEXT_KEYTERM_USAGE_CHARGE_AGGREGATE")
    End Select
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			: mcmGetFilterForPriceableItemKind
' PARAMETERS		:
' DESCRIPTION 	: Retrieve an MTFilter object that will return priceable items of the given kind.
'                 Eases the case in which the kind is either usage or recurring charges and there are multiple 
'                 Kinds that need to be returned (filter does not do 'OR')
' RETURNS			  : MTFilter object
PUBLIC FUNCTION mcmGetFilterForPriceableItemKind(iPriceableItemKind)
      dim objMTFilter
      Set objMTFilter = mdm_CreateObject(MTFilter)
      If iPriceableItemKind = PI_TYPE_USAGE then
        '// Ugly hack because usage can be kind = 10 or kind = 15 and filter does not do 'or'
        '// Thank you, DeMorgan, may you rest in peace
        objMTFilter.Add "Kind", OPERATOR_TYPE_NOT_EQUAL, CLng(PI_TYPE_RECURRING)
        objMTFilter.Add "Kind", OPERATOR_TYPE_NOT_EQUAL, CLng(PI_TYPE_RECURRING_UNIT_DEPENDENT)
        objMTFilter.Add "Kind", OPERATOR_TYPE_NOT_EQUAL, CLng(PI_TYPE_NON_RECURRING)
        objMTFilter.Add "Kind", OPERATOR_TYPE_NOT_EQUAL, CLng(PI_TYPE_DISCOUNT)
      else
        If iPriceableItemKind = PI_TYPE_RECURRING then
          '// Ugly hack because recurring can be kind = 20 or kind = 25 and filter does not do 'or'
          '// Thank you, DeMorgan, may you rest in peace
          objMTFilter.Add "Kind", OPERATOR_TYPE_NOT_EQUAL, CLng(PI_TYPE_USAGE)
          objMTFilter.Add "Kind", OPERATOR_TYPE_NOT_EQUAL, CLng(PI_TYPE_USAGE_AGGREGATE)
          objMTFilter.Add "Kind", OPERATOR_TYPE_NOT_EQUAL, CLng(PI_TYPE_NON_RECURRING)
          objMTFilter.Add "Kind", OPERATOR_TYPE_NOT_EQUAL, CLng(PI_TYPE_DISCOUNT)
        else
          objMTFilter.Add "Kind", OPERATOR_TYPE_EQUAL, iPriceableItemKind
        end if
      end if
      
      set mcmGetFilterForPriceableItemKind = objMTFilter
END FUNCTION

%>
        
