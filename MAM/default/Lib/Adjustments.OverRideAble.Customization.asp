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
' NAME		        : MAM - MetraTech Account Manager - VBScript Library
' VERSION	        : 3.5
' CREATION_DATE   : 10/09/2002
' AUTHOR	        : F.Torres.
' DESCRIPTION	    : 
'                   
' ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

' ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' AUDIO CONFERENCE CALL
' ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

  ' ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  ' FUNCTION 		: Metratech_Com_AudioConfCall_Adjustment_SelectColumns
  ' PARAMETERS	:
  ' DESCRIPTION : Customize the columns to display and their formating information for the price able item audio conf call.
  '               This function is used when we display the transactions found to be adjusted but also to display the transaction
  '               to be rebilled.
  '
  ' RETURNS		  : Returns TRUE if ok else FALSE
  PUBLIC FUNCTION Metratech_Com_AudioConfCall_Adjustment_SelectColumns(ProductViewOrGrid)

'     TO SEE ALL THE PROPERTIES AVAILABLE UN COMMENT THIS CODE AND REFRESH THE DIALOG
'     ProductViewOrGrid.Properties.SelectAll
'     Exit Function
    
      Dim i : i = 1

      Metratech_Com_AudioConfCall_Adjustment_SelectColumns = FALSE
      
      ProductViewOrGrid.Properties.ClearSelection
      
      ' Select the properties
      ProductViewOrGrid.Properties("SessionID").Selected                        = i : i=i+1
      ProductViewOrGrid.Properties("TimeStamp").Selected                        = i : i=i+1
      ProductViewOrGrid.Properties("c_ConferenceID").Selected                   = i : i=i+1  
      ProductViewOrGrid.Properties("c_AccountingCode").Selected                 = i : i=i+1
      ProductViewOrGrid.Properties("c_ServiceLevel").Selected                   = i : i=i+1  
      ProductViewOrGrid.Properties("Amount").Selected                           = i : i=i+1  
      ProductViewOrGrid.Properties("CompoundPrebillAdjAmt").Selected  = i : i=i+1  
      ProductViewOrGrid.Properties("CompoundPrebillAdjedAmt").Selected    = i : i=i+1  
      ProductViewOrGrid.Properties("status").Selected    = i : i=i+1 
            
      ' Localize the properties
      ProductViewOrGrid.Properties("status").Caption = "Status"
      ProductViewOrGrid.Properties("c_ConferenceID").Caption                    = FrameWork.GetLocalizedProperty(MAM().CSR("Language").Value,"metratech.com/audioconfcall","metratech.com","ConferenceID")
      ProductViewOrGrid.Properties("c_AccountingCode").Caption                  = FrameWork.GetLocalizedProperty(MAM().CSR("Language").Value,"metratech.com/audioconfcall","metratech.com","AccountingCode")
      ProductViewOrGrid.Properties("c_ServiceLevel").Caption                    = FrameWork.GetLocalizedProperty(MAM().CSR("Language").Value,"metratech.com/audioconfcall","metratech.com","ServiceLevel")
      ProductViewOrGrid.Properties("c_ActualNumConnections").Caption            = FrameWork.GetLocalizedProperty(MAM().CSR("Language").Value,"metratech.com/audioconfcall","metratech.com","ActualNumConnections")
      ProductViewOrGrid.Properties("c_Payer").Caption                           = FrameWork.GetLocalizedProperty(MAM().CSR("Language").Value,"metratech.com/audioconfcall","metratech.com","Payer")
      ProductViewOrGrid.Properties("c_ConferenceName").Caption                  = FrameWork.GetLocalizedProperty(MAM().CSR("Language").Value,"metratech.com/audioconfcall","metratech.com","ConferenceName")
      ProductViewOrGrid.Properties("c_ConferenceSubject").Caption               = FrameWork.GetLocalizedProperty(MAM().CSR("Language").Value,"metratech.com/audioconfcall","metratech.com","ConferenceSubject")
      ProductViewOrGrid.Properties("c_OrganizationName").Caption                = FrameWork.GetLocalizedProperty(MAM().CSR("Language").Value,"metratech.com/audioconfcall","metratech.com","OrganizationName")
      ProductViewOrGrid.Properties("c_SpecialInfo").Caption                     = FrameWork.GetLocalizedProperty(MAM().CSR("Language").Value,"metratech.com/audioconfcall","metratech.com","SpecialInfo")
      ProductViewOrGrid.Properties("c_SchedulerComments").Caption               = FrameWork.GetLocalizedProperty(MAM().CSR("Language").Value,"metratech.com/audioconfcall","metratech.com","SchedulerComments")
      ProductViewOrGrid.Properties("c_ScheduledConnections").Caption            = FrameWork.GetLocalizedProperty(MAM().CSR("Language").Value,"metratech.com/audioconfcall","metratech.com","ScheduledConnections")
      ProductViewOrGrid.Properties("c_ScheduledStartTime").Caption              = FrameWork.GetLocalizedProperty(MAM().CSR("Language").Value,"metratech.com/audioconfcall","metratech.com","ScheduledStartTime")
      ProductViewOrGrid.Properties("c_ScheduledTimeGMTOffset").Caption          = FrameWork.GetLocalizedProperty(MAM().CSR("Language").Value,"metratech.com/audioconfcall","metratech.com","ScheduledTimeGMTOffset")
      ProductViewOrGrid.Properties("c_ScheduledDuration").Caption               = FrameWork.GetLocalizedProperty(MAM().CSR("Language").Value,"metratech.com/audioconfcall","metratech.com","ScheduledDuration")
      ProductViewOrGrid.Properties("c_CancelledFlag").Caption                   = FrameWork.GetLocalizedProperty(MAM().CSR("Language").Value,"metratech.com/audioconfcall","metratech.com","CancelledFlag")
      ProductViewOrGrid.Properties("c_CancellationTime").Caption                = FrameWork.GetLocalizedProperty(MAM().CSR("Language").Value,"metratech.com/audioconfcall","metratech.com","CancellationTime")
      ProductViewOrGrid.Properties("c_TerminationReason").Caption               = FrameWork.GetLocalizedProperty(MAM().CSR("Language").Value,"metratech.com/audioconfcall","metratech.com","TerminationReason")
      ProductViewOrGrid.Properties("c_SystemName").Caption                      = FrameWork.GetLocalizedProperty(MAM().CSR("Language").Value,"metratech.com/audioconfcall","metratech.com","SystemName")
      ProductViewOrGrid.Properties("c_SalesPersonID").Caption                   = FrameWork.GetLocalizedProperty(MAM().CSR("Language").Value,"metratech.com/audioconfcall","metratech.com","SalesPersonID")
      ProductViewOrGrid.Properties("c_OperatorID").Caption                      = FrameWork.GetLocalizedProperty(MAM().CSR("Language").Value,"metratech.com/audioconfcall","metratech.com","OperatorID")
      ProductViewOrGrid.Properties("c_ActualStartTime").Caption                 = FrameWork.GetLocalizedProperty(MAM().CSR("Language").Value,"metratech.com/audioconfcall","metratech.com","ActualStartTime")
      ProductViewOrGrid.Properties("c_ActualDuration").Caption                  = FrameWork.GetLocalizedProperty(MAM().CSR("Language").Value,"metratech.com/audioconfcall","metratech.com","ActualDuration")
      ProductViewOrGrid.Properties("c_ConferenceEndTime").Caption               = FrameWork.GetLocalizedProperty(MAM().CSR("Language").Value,"metratech.com/audioconfcall","metratech.com","ConferenceEndTime")
      ProductViewOrGrid.Properties("c_ConferenceTotal").Caption                 = FrameWork.GetLocalizedProperty(MAM().CSR("Language").Value,"metratech.com/audioconfcall","metratech.com","ConferenceTotal")
      ProductViewOrGrid.Properties("c_LeaderName").Caption                      = FrameWork.GetLocalizedProperty(MAM().CSR("Language").Value,"metratech.com/audioconfcall","metratech.com","LeaderName")
      ProductViewOrGrid.Properties("c_ReservationCharges").Caption              = FrameWork.GetLocalizedProperty(MAM().CSR("Language").Value,"metratech.com/audioconfcall","metratech.com","ReservationCharges")
      ProductViewOrGrid.Properties("c_CancelCharges").Caption                   = FrameWork.GetLocalizedProperty(MAM().CSR("Language").Value,"metratech.com/audioconfcall","metratech.com","CancelCharges")
      ProductViewOrGrid.Properties("c_UnusedPortCharges").Caption               = FrameWork.GetLocalizedProperty(MAM().CSR("Language").Value,"metratech.com/audioconfcall","metratech.com","UnusedPortCharges")
      ProductViewOrGrid.Properties("c_ConnectionTotalAmount").Caption           = FrameWork.GetLocalizedProperty(MAM().CSR("Language").Value,"metratech.com/audioconfcall","metratech.com","ConnectionTotalAmount")
      ProductViewOrGrid.Properties("c_AdjustmentAmount").Caption                = FrameWork.GetLocalizedProperty(MAM().CSR("Language").Value,"metratech.com/audioconfcall","metratech.com","AdjustmentAmount")
      ProductViewOrGrid.Properties("c_OverusedPortCharges").Caption             = FrameWork.GetLocalizedProperty(MAM().CSR("Language").Value,"metratech.com/audioconfcall","metratech.com","OverusedPortCharges")

      'Format
      ProductViewOrGrid.Properties("Amount").Format = FrameWork.Dictionary.Item("AMOUNT_FORMAT").Value
      
      ' Localize and format default properties like : TimeStamp, Amount, CompoundPrebillAdjAmt, CompoundPrebillAdjedAmt
      Adjustment_SelectColumns_DefaultLocalization(ProductViewOrGrid) 

      Metratech_Com_AudioConfCall_Adjustment_SelectColumns = TRUE
  END FUNCTION
  

' ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' TEST USAGE CHARGE
' ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
  ' ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  ' FUNCTION 		: Metratech_Com_TestPi_Adjustment_SelectColumns
  ' PARAMETERS	:
  ' DESCRIPTION : Customize the columns to display and their formating information for the price able item Test Usage Charge.
  '               This function is used when we display the transactions found to be adjusted but also to display the transaction
  '               to be rebilled.
  '
  ' RETURNS		  : Returns TRUE if ok else FALSE  
  PUBLIC FUNCTION Metratech_Com_TestPi_Adjustment_SelectColumns(ProductViewOrGrid)
  
'     TO SEE ALL THE PROPERTIES AVAILABLE UN COMMENT THIS CODE AND REFRESH THE DIALOG
'     ProductViewOrGrid.Properties.SelectAll
'     Exit Function
  
      Dim i : i = 1

      Metratech_Com_TestPi_Adjustment_SelectColumns = FALSE
            
      ProductViewOrGrid.Properties.ClearSelection
      
      ProductViewOrGrid.Properties("SessionID").Selected                        = i : i=i+1
      ProductViewOrGrid.Properties("TimeStamp").Selected                        = i : i=i+1
      ProductViewOrGrid.Properties("c_units").Selected                          = i : i=i+1  
      ProductViewOrGrid.Properties("c_description").Selected                    = i : i=i+1  
      ProductViewOrGrid.Properties("Amount").Selected                           = i : i=i+1  
      ProductViewOrGrid.Properties("CompoundPrebillAdjAmt").Selected  = i : i=i+1  
      ProductViewOrGrid.Properties("CompoundPrebillAdjedAmt").Selected    = i : i=i+1  
      ProductViewOrGrid.Properties("status").Selected    = i : i=i+1 
            
      ' Localize the properties
      ProductViewOrGrid.Properties("status").Caption = "Status"
      ProductViewOrGrid.Properties("c_units").Caption                           = FrameWork.GetLocalizedProperty(MAM().CSR("Language").Value,"metratech.com/testservice","metratech.com","units")
      ProductViewOrGrid.Properties("c_description").Caption                     = FrameWork.GetLocalizedProperty(MAM().CSR("Language").Value,"metratech.com/testservice","metratech.com","description")
      
      Adjustment_SelectColumns_DefaultLocalization(ProductViewOrGrid) ' Localize some properties that are always there no matter which adjustment type we are dealing with
  
      Metratech_Com_TestPi_Adjustment_SelectColumns = TRUE  
  END FUNCTION
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  '
  ' Util Functions For The Customization
  '
    
  ' ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  ' FUNCTION 		: Adjustment_SelectColumns_DefaultLocalization
  ' PARAMETERS	:
  ' DESCRIPTION : Localize and format some properties that are generally always display as a part of a transaction that will be adjusted
  ' RETURNS		  : Returns TRUE if ok else FALSE  
  PRIVATE FUNCTION Adjustment_SelectColumns_DefaultLocalization(ProductViewOrGrid)
  
      Adjustment_SelectColumns_DefaultLocalization = FALSE
      
      ProductViewOrGrid.Properties("CompoundPrebillAdjAmt").Format      = mam_GetDictionary("AMOUNT_FORMAT")
      ProductViewOrGrid.Properties("CompoundPrebillAdjAmt").Alignment   = "right"
      
      ProductViewOrGrid.Properties("CompoundPrebillAdjedAmt").Format        = mam_GetDictionary("AMOUNT_FORMAT")
      ProductViewOrGrid.Properties("CompoundPrebillAdjedAmt").Alignment     = "right"       
      
      ProductViewOrGrid.Properties("Amount").Format                               = mam_GetDictionary("AMOUNT_FORMAT")      
      ProductViewOrGrid.Properties("Amount").Alignment                            = "right"
      
      ProductViewOrGrid.Properties("TimeStamp").Format 			                      = mam_GetDictionary("DATE_TIME_FORMAT")
      ProductViewOrGrid.Properties("TimeStamp").Sorted                            = MTSORT_ORDER_DECENDING  ' Sort
      
      ProductViewOrGrid.Properties("TimeStamp").Caption                           = FrameWork.GetLocalizedProperty(MAM().CSR("Language").Value,"metratech.com/audioconfcall","metratech.com","timestamp")      
      ProductViewOrGrid.Properties("SessionID").Caption                           = FrameWork.GetLocalizedProperty(MAM().CSR("Language").Value,"metratech.com/audioconfcall","metratech.com","SessionID")
      ProductViewOrGrid.Properties("Amount").Caption                              = FrameWork.GetLocalizedProperty(MAM().CSR("Language").Value,"metratech.com/audioconfcall","metratech.com","Amount")            
      ProductViewOrGrid.Properties("CompoundPrebillAdjAmt").Caption               = FrameWork.Dictionary().Item("TEXT_ADJUSTMENT_AMOUNT").Value
      ProductViewOrGrid.Properties("CompoundPrebillAdjedAmt").Caption             = FrameWork.Dictionary().Item("TEXT_ADJUSTED_AMOUNT").Value      
      ProductViewOrGrid.Properties("DisplayName").Caption                         = FrameWork.Dictionary().Item("TEXT_SUBSCRIBER_NAME").Value

      ProductViewOrGrid.Properties("ViewID").Caption                              = FrameWork.Dictionary().Item("TEXT_VIEW_ID").Value
      ProductViewOrGrid.Properties("Currency").Caption                            = FrameWork.Dictionary().Item("TEXT_CURRENCY").Value
      ProductViewOrGrid.Properties("AccountID").Caption                           = FrameWork.Dictionary().Item("TEXT_ACCOUNT_ID").Value
      ProductViewOrGrid.Properties("PITemplate").Caption                          = FrameWork.Dictionary().Item("TEXT_PI_TEMPLATE").Value
      ProductViewOrGrid.Properties("PIInstance").Caption                          = FrameWork.Dictionary().Item("TEXT_PI_INSTANCE").Value
      ProductViewOrGrid.Properties("SessionType").Caption                         = FrameWork.Dictionary().Item("TEXT_SESSION_TYPE").Value
      ProductViewOrGrid.Properties("TaxAmount").Caption                           = FrameWork.Dictionary().Item("TEXT_TAX_AMOUNT").Value
      ProductViewOrGrid.Properties("FederalTaxAmount").Caption                    = FrameWork.Dictionary().Item("TEXT_FEDERAL_TAX_AMOUNT").Value
      ProductViewOrGrid.Properties("StateTaxAmount").Caption                      = FrameWork.Dictionary().Item("TEXT_STATE_TAX_AMOUNT").Value
      ProductViewOrGrid.Properties("CountyTaxAmount").Caption                     = FrameWork.Dictionary().Item("TEXT_COUNTY_TAX_AMOUNT").Value
      ProductViewOrGrid.Properties("LocalTaxAmount").Caption                      = FrameWork.Dictionary().Item("TEXT_LOCAL_TAX_AMOUNT").Value
      ProductViewOrGrid.Properties("OtherTaxAmount").Caption                      = FrameWork.Dictionary().Item("TEXT_OTHER_TAX_AMOUNT").Value
      ProductViewOrGrid.Properties("AmountWithTax").Caption                       = FrameWork.Dictionary().Item("TEXT_AMOUNT_WITH_TAX").Value
      ProductViewOrGrid.Properties("IntervalID").Caption                          = FrameWork.Dictionary().Item("TEXT_INTERVAL_ID").Value
      ProductViewOrGrid.Properties("CompoundPostbillAdjAmt").Caption              = FrameWork.Dictionary().Item("TEXT_COMPOUNDPOSTBILLADJAMT").Value
      ProductViewOrGrid.Properties("CompoundPostbillAdjedAmt").Caption            = FrameWork.Dictionary().Item("TEXT_COMPOUNDPOSTBILLADJEDAMT").Value
      ProductViewOrGrid.Properties("AtomicPrebillAdjAmt").Caption                 = FrameWork.Dictionary().Item("TEXT_ATOMICPREBILLADJAMT").Value
      ProductViewOrGrid.Properties("AtomicPrebillAdjustedAmount").Caption         = FrameWork.Dictionary().Item("TEXT_ATOMICPREBILLADJUSTEDAMOUNT").Value
      ProductViewOrGrid.Properties("AtomicPostbillAdjAmt").Caption                = FrameWork.Dictionary().Item("TEXT_ATOMICPOSTBILLADJAMT").Value
      ProductViewOrGrid.Properties("AtomicPostbillAdjustedAmount").Caption        = FrameWork.Dictionary().Item("TEXT_ATOMICPOSTBILLADJUSTEDAMOUNT").Value
      ProductViewOrGrid.Properties("CompoundPreBillFedTaxAdjAmt").Caption         = FrameWork.Dictionary().Item("TEXT_COMPOUNDPREBILLFEDTAXADJAMT").Value
      ProductViewOrGrid.Properties("CompoundPrebillStateTaxAdjAmt").Caption       = FrameWork.Dictionary().Item("TEXT_COMPOUNDPREBILLSTATETAXADJAMT").Value
      ProductViewOrGrid.Properties("CompoundPrebillCntryTaxAdjAmt").Caption       = FrameWork.Dictionary().Item("TEXT_COMPOUNDPREBILLCNTRYTAXADJAMT").Value
      ProductViewOrGrid.Properties("CompoundPrebillLocalTaxAdjAmt").Caption       = FrameWork.Dictionary().Item("TEXT_COMPOUNDPREBILLLOCALTAXADJAMT").Value
      ProductViewOrGrid.Properties("CompoundPrebillOtherTaxAdjAmt").Caption       = FrameWork.Dictionary().Item("TEXT_COMPOUNDPREBILLOTHERTAXADJAMT").Value
      ProductViewOrGrid.Properties("CompoundPrebillTotalTaxAdjAmt").Caption       = FrameWork.Dictionary().Item("TEXT_COMPOUNDPREBILLTOTALTAXADJAMT").Value
      ProductViewOrGrid.Properties("CompoundPostBillFedTaxAdjAmt").Caption        = FrameWork.Dictionary().Item("TEXT_COMPOUNDPOSTBILLFEDTAXADJAMT").Value
      ProductViewOrGrid.Properties("CompoundPostbillStateTaxAdjAmt").Caption      = FrameWork.Dictionary().Item("TEXT_COMPOUNDPOSTBILLSTATETAXADJAMT").Value
      ProductViewOrGrid.Properties("CompoundPostbillCntryTaxAdjAmt").Caption      = FrameWork.Dictionary().Item("TEXT_COMPOUNDPOSTBILLCNTRYTAXADJAMT").Value
      ProductViewOrGrid.Properties("CompoundPostbillLocalTaxAdjAmt").Caption      = FrameWork.Dictionary().Item("TEXT_COMPOUNDPOSTBILLLOCALTAXADJAMT").Value
      ProductViewOrGrid.Properties("CompoundPostbillOtherTaxAdjAmt").Caption      = FrameWork.Dictionary().Item("TEXT_COMPOUNDPOSTBILLOTHERTAXADJAMT").Value
      ProductViewOrGrid.Properties("CompoundPostbillTotalTaxAdjAmt").Caption      = FrameWork.Dictionary().Item("TEXT_COMPOUNDPOSTBILLTOTALTAXADJAMT").Value
      ProductViewOrGrid.Properties("AtomicPreBillFedTaxAdjAmt").Caption           = FrameWork.Dictionary().Item("TEXT_ATOMICPREBILLFEDTAXADJAMT").Value
      ProductViewOrGrid.Properties("AtomicPrebillStateTaxAdjAmt").Caption         = FrameWork.Dictionary().Item("TEXT_ATOMICPREBILLSTATETAXADJAMT").Value
      ProductViewOrGrid.Properties("AtomicPrebillCntryTaxAdjAmt").Caption         = FrameWork.Dictionary().Item("TEXT_ATOMICPREBILLCNTRYTAXADJAMT").Value
      ProductViewOrGrid.Properties("AtomicPrebillLocalTaxAdjAmt").Caption         = FrameWork.Dictionary().Item("TEXT_ATOMICPREBILLLOCALTAXADJAMT").Value
      ProductViewOrGrid.Properties("AtomicPrebillOtherTaxAdjAmt").Caption         = FrameWork.Dictionary().Item("TEXT_ATOMICPREBILLOTHERTAXADJAMT").Value
      ProductViewOrGrid.Properties("AtomicPrebillTotalTaxAdjAmt").Caption         = FrameWork.Dictionary().Item("TEXT_ATOMICPREBILLTOTALTAXADJAMT").Value
      ProductViewOrGrid.Properties("AtomicPostBillFedTaxAdjAmt").Caption          = FrameWork.Dictionary().Item("TEXT_ATOMICPOSTBILLFEDTAXADJAMT").Value
      ProductViewOrGrid.Properties("AtomicPostbillStateTaxAdjAmt").Caption        = FrameWork.Dictionary().Item("TEXT_ATOMICPOSTBILLSTATETAXADJAMT").Value
      ProductViewOrGrid.Properties("AtomicPostbillCntryTaxAdjAmt").Caption        = FrameWork.Dictionary().Item("TEXT_ATOMICPOSTBILLCNTRYTAXADJAMT").Value
      ProductViewOrGrid.Properties("AtomicPostbillLocalTaxAdjAmt").Caption        = FrameWork.Dictionary().Item("TEXT_ATOMICPOSTBILLLOCALTAXADJAMT").Value
      ProductViewOrGrid.Properties("AtomicPostbillOtherTaxAdjAmt").Caption        = FrameWork.Dictionary().Item("TEXT_ATOMICPOSTBILLOTHERTAXADJAMT").Value
      ProductViewOrGrid.Properties("AtomicPostbillTotalTaxAdjAmt").Caption        = FrameWork.Dictionary().Item("TEXT_ATOMICPOSTBILLTOTALTAXADJAMT").Value
      ProductViewOrGrid.Properties("IsPrebillTransaction").Caption                = FrameWork.Dictionary().Item("TEXT_ISPREBILLTRANSACTION").Value
      ProductViewOrGrid.Properties("IsAdjusted").Caption                          = FrameWork.Dictionary().Item("TEXT_ISADJUSTED").Value
      ProductViewOrGrid.Properties("IsPrebillAdjusted").Caption                   = FrameWork.Dictionary().Item("TEXT_ISPREBILLADJUSTED").Value
      ProductViewOrGrid.Properties("IsPostBillAdjusted").Caption                  = FrameWork.Dictionary().Item("TEXT_ISPOSTBILLADJUSTED").Value
      ProductViewOrGrid.Properties("CanAdjust").Caption                           = FrameWork.Dictionary().Item("TEXT_CANADJUST").Value
      ProductViewOrGrid.Properties("CanRebill").Caption                           = FrameWork.Dictionary().Item("TEXT_CANREBILL").Value
      ProductViewOrGrid.Properties("CanManageAdjustments").Caption                = FrameWork.Dictionary().Item("TEXT_CANMANAGEADJUSTMENTS").Value
      ProductViewOrGrid.Properties("PrebillAdjustmentID").Caption                 = FrameWork.Dictionary().Item("TEXT_PREBILLADJUSTMENTID").Value
      ProductViewOrGrid.Properties("PostbillAdjustmentID").Caption                = FrameWork.Dictionary().Item("TEXT_POSTBILLADJUSTMENTID").Value
      ProductViewOrGrid.Properties("IsIntervalSoftClosed").Caption                = FrameWork.Dictionary().Item("TEXT_ISINTERVALSOFTCLOSED").Value
      ProductViewOrGrid.Properties("DisplayAmount").Caption                       = FrameWork.Dictionary().Item("TEXT_DISPLAYAMOUNT").Value
      
      Adjustment_SelectColumns_DefaultLocalization = TRUE
  END FUNCTION 

%>

