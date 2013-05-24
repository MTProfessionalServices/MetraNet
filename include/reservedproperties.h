/**************************************************************************
 * @doc RESERVEDPROPERTIES
 *
 * @module |
 *
 *
 * Copyright 1999 by MetraTech Corporation
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
 * NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech Corporation MAKES NO
 * REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
 * PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
 * DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
 * COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech Corporation,
 * and USER agrees to preserve the same.
 *
 * Created by: David McCowan
 *
 * $Date$
 * $Author$
 * $Revision$
 *
 * @index | RESERVEDPROPERTIES
 ***************************************************************************/

#ifndef _RESERVEDPROPERTIES_H
#define _RESERVEDPROPERTIES_H

/* 
	 "Reserved" properties are properites that have special
	 meaning to the pipeline. They begin with an underscore.

	 "Special" properties are reserved properties that can be metered
	 in any session even if they aren't in the service definition.
*/


// special properties
// NOTE: if you add any new special properties add it to the list below!  Thank you very much.
#define MT_PROFILESTAGE_PROP_A   "_ProfileStage"
#define MT_NEWPARENTID_PROP_A		 "_NewParentID"
#define MT_NEWPARENTINTERNALID_PROP_A  "_NewParentInternalID"
#define MT_COLLECTIONID_PROP_A         "_CollectionID"
#define MT_TRANSACTIONCOOKIE_PROP_A "_TransactionCookie"


// reserved properties
#define MT_ACCOUNTID_PROP        L"_AccountID"
#define MT_CURRENCY_PROP         L"_Currency"
#define MT_AMOUNT_PROP           L"_Amount"
#define MT_TIMESTAMP_PROP        L"_Timestamp"
#define MT_TIMESTAMP_PROP_A        "_Timestamp"
#define MT_METEREDTIMESTAMP_PROP L"_MeteredTimestamp"
#define MT_PRODUCTVIEWID_PROP    L"_ProductViewID"
#define MT_PRODUCTID_PROP        L"_ProductID"
#define MT_SERVICEID_PROP        L"_ServiceID"
#define MT_FEEDBACKMETERID_PROP  L"_FeedbackMeterID"
#define MT_IPADDRESS_PROP        L"_IPAddress"
#define MT_FEDTAX_PROP           L"_FedTax"
#define MT_STATETAX_PROP         L"_StateTax"
#define MT_COUNTYTAX_PROP        L"_CountyTax"
#define MT_LOCALTAX_PROP         L"_LocalTax"
#define MT_OTHERTAX_PROP         L"_OtherTax"
#define MT_PROFILESTAGE_PROP     L"_ProfileStage"
#define MT_INTERVALID_PROP       L"_IntervalId"
#define MT_INTERVALID_PROP_A     "_IntervalId"
#define MT_NEWPARENTID_PROP			 L"_NewParentID"
#define MT_NEWPARENTINTERNALID_PROP L"_NewParentInternalID"
#define MT_COLLECTIONID_PROP     L"_CollectionID"
#define MT_TRANSACTIONCOOKIE_PROP L"_TransactionCookie"
#define MT_ERRORSTRING_PROP			 L"_ErrorString"
#define MT_ERRORCODE_PROP			   L"_ErrorCode"
#define MT_NEXTSTAGE_PROP        L"_NextStage"
#define MT_NEXTSTAGE_PROP_A      "_NextStage"
#define MT_PRICEABLEITEMINSTANCEID_PROP L"_PriceableItemInstanceID"
#define MT_PRICEABLEITEMTEMPLATEID_PROP L"_PriceableItemTemplateID"
#define MT_PRICEABLEITEMNAMEID_PROP     L"_PriceableItemName"
#define MT_PRODUCTOFFERINGID_PROP L"_ProductOfferingID"
#define MT_TRANSACTION_OBJECT_PROP L"_TransactionObject"
#define MT_SUBSCRIPTIONID_PROP    L"_SubscriptionID"
#define MT_ACCOUNTPRICELIST_PROP  L"_AccountPriceList"
#define MT_PAYINGACCOUNT_PROP_A "_PayingAccount"
#define MT_PAYINGACCOUNT_PROP L"_PayingAccount"
#define MT_EXECUTEPLUGIN_PROP L"_ExecutePlugin"
#define MT_ACCOUNTSTATE_PROP L"_AccountState"
#define MT_SUBSCRIPTIONENTITY_PROP L"_SubscriptionEntity"
#define MT_SESSIONID_PROP        L"_SessionID"
#define MT_RESUBMIT_PROP         L"_Resubmit"
#define MT_RESUBMIT_PROP_A       "_Resubmit"
#define MT_SESSIONSETID_PROP     L"_SessionSetID"
#define MT_EXTERNALSESSIONID_PROP L"_ExternalSessionID"
#define MT_DIVISIONCURRENCY_PROP L"_DivisionCurrency"
#define MT_DIVISIONAMOUNT_PROP L"_DivisionAmount"
#define MT_TAXINCLUSIVE_PROP L"_TaxInclusive"
#define MT_TAXCALCULATED_PROP L"_TaxCalculated"
#define MT_TAXINFORMATIONAL_PROP L"_TaxInformational"

//Product View Reserved Properties
#define MT_PVVIEWID						L"VIEWID"
#define MT_PVSESSIONID					L"SESSIONID"
#define MT_PVAMOUNT						L"AMOUNT"
#define MT_PVDISPLAYAMOUNT				L"DISPLAYAMOUNT"
#define MT_PVPREBILLADJUSTMENTAMOUNT    L"PREBILLADJUSTMENTAMOUNT"
#define MT_PVPOSTBILLADJUSTMENTAMOUNT   L"POSTBILLADJUSTMENTAMOUNT"
#define MT_PVTAXAMOUNT					L"TAXAMOUNT"
#define MT_PVAMOUNTWITHTAX				L"AMOUNTWITHTAX"
#define MT_PVCURRENCY					L"CURRENCY"
#define MT_PVACCOUNTID					L"ACCOUNTID"
#define MT_PVPAYEEDISPLAYNAME			L"PAYEEDISPLAYNAME"
#define MT_PVTIMESTAMP					L"TIMESTAMP"
#define MT_PVSEDISPLAYNAME				L"SEDISPLAYNAME"

#ifdef I_WANT_WONDERFUL_STATIC_LIST_OF_GREAT_RESERVED_PROPS

const char* ListOfSpecialProps[] = {
	MT_PROFILESTAGE_PROP_A,
	MT_NEWPARENTID_PROP_A,
	MT_NEWPARENTINTERNALID_PROP_A,
	MT_COLLECTIONID_PROP_A,
	MT_TRANSACTIONCOOKIE_PROP_A,
	MT_RESUBMIT_PROP_A,
	"" // keep this at the end
};

#endif // I_WANT_WONDERFUL_STATIC_LIST_OF_GREAT_RESERVED_PROPS


#endif /* _RESERVEDPROPERTIES_H */
