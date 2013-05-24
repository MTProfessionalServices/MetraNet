/**************************************************************************
* Copyright 1997-2002 by MetraTech
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
* REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
* OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
* INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
* RIGHTS.
*
* Title to copyright in this software and any associated
* documentation shall at all times remain with MetraTech, and USER
* agrees to preserve the same.
*
* $Header: MTSubscriptionBase.h, 3, 10/17/2002 9:29:16 AM, David Blair$
* 
***************************************************************************/

#ifndef __MTSUBSCRIPTIONBASE_H__
#define __MTSUBSCRIPTIONBASE_H__

#include "PropertiesBase.h"

#include <list>
#include <map>

class TemporalProperty
{
public:
	struct Slice
	{
		DATE begin;
		DATE end;
		_variant_t value;

		Slice(VARIANT v, const DATE& b, const DATE& e);

		Slice(const Slice& slice);

		bool operator == (const Slice& slice) const;

    DATE GetNextStart();

    /// <remarks>
    /// Get an "end" timestamp that is adjacent to the start of this interval.
    /// This depends on the type of interval (half open or closed)
    /// as well as the time granularity (second, day, ...).
    /// </remarks>
    DATE GetPreviousEnd();

    /// <remarks>
    /// Returns true if this entry contains the start of the interval
    /// but not the whole interval.  
    /// </remarks>
    bool LeftOverlaps(const Slice& he);

    /// <remarks>
    /// Returns true if this entry contains the end of the interval he
    /// but not the whole interval.  
    /// </remarks>
    bool RightOverlaps(const Slice& he);

    /// <remarks>
    /// Returns true if this entry contains the entire interval he.
    /// </remarks>
    bool Contains(const Slice& he);

    /// <remarks>
    /// Returns true if this entry contains the timestamp date
    /// </remarks>
    bool Contains(const DATE& date);

    /// <remarks>
    /// Returns true if this entry is strictly contained in the interval he.
    /// </remarks>
    bool ContainedIn(const Slice& he);
	};

private:
	std::list<Slice> mProperties;
	
public:
	TemporalProperty()
	{
	}

	std::list<Slice>::iterator begin();

	std::list<Slice>::iterator end();
	

	// Set the value of the property to be val from the period
	// from [begin, end].  Throws an exception if the property
	// time interval is not contiguous.
	void Upsert(VARIANT val, const DATE& begin, const DATE& end);
	
};

class MTSubscriptionBase : 	
	public CMTPCBase,
	public PropertiesBase
{


public:
	MTSubscriptionBase();
	virtual ~MTSubscriptionBase();
	
// COM Methods.  Yummy
public:
	STDMETHOD(GetParamTablesAsRowset)(/*[out,retval]*/ ::IMTSQLRowset** ppRowset);
  STDMETHOD(get_ProductOfferingID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_ProductOfferingID)(/*[in]*/ long newVal);
	STDMETHOD(get_ID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_ID)(/*[in]*/ long newVal);
	STDMETHOD(RemoveICBPriceListMapping)(/*[in]*/ long aPI_ID,/*[in]*/ long aPtdID);
	STDMETHOD(SetICBPriceListMapping)(/*[in]*/ long aPrcItemID,/*[in]*/ long aParamTblID,BSTR CurrencyCode);
	STDMETHOD(GetICBPriceListMapping)(/*[in]*/ long aPrcItemID,/*[in]*/ long ParamTableID,/*[out, retval]*/ IMTPriceListMapping** ppMapping);
	STDMETHOD(SetProductOffering)(/*[in]*/ long aProductOfferingID);
	STDMETHOD(GetProductOffering)(/*[out, retval]*/ IMTProductOffering** ppProductOffering);

		// the time span for which this subscription is effective
	STDMETHOD(get_EffectiveDate)(/*[out, retval]*/ IMTPCTimeSpan* *pVal);
	STDMETHOD(put_EffectiveDate)(/*[in] */ IMTPCTimeSpan* newVal);
	STDMETHOD(get_Cycle)(IMTPCCycle** pCycle);
	STDMETHOD(put_Cycle)(IMTPCCycle* pCycle);
	STDMETHOD(get_ExternalIdentifier)(BSTR* ppGUID);
	STDMETHOD(put_ExternalIdentifier)(BSTR pGUID);

  // Set the value for a unit dependent recurring charge instance 
  STDMETHOD(SetRecurringChargeUnitValue)(/*[in]*/ long aPrcItemID,/*[in]*/ DECIMAL aUnitValue, /*[in]*/ DATE aStartDate, /*[in]*/ DATE aEndDate);

  // Get the value for a unit dependent recurring charge instance 
  STDMETHOD(GetRecurringChargeUnitValue)(/*[in]*/ long aPrcItemID, /*[in]*/ DATE aEffDate ,/*[out,retval]*/ DECIMAL* apUnitValue);

  // Get all values of unit dependent recurring charges
  STDMETHOD(GetRecurringChargeUnitValuesAsRowset)(/*[out,retval]*/ ::IMTRowSet* * apUnitValues);
  // Get all values of unit dependent recurring charges
  STDMETHOD(GetRecurringChargeUnitValuesFromMemoryAsRowset)(/*[out,retval]*/ ::IMTRowSet* * apUnitValues);

	// Returns true if altering the subscription's start date
	// could affect the derived EBCR cycle
	STDMETHOD(get_WarnOnEBCRStartDateChange)(/*[out, retval]*/ VARIANT_BOOL *pVal);

	enum subscriptionKind { SingleSubscription, GroupSubscription };
	virtual void SetSubscriptionKind() = 0;

protected: // internal methods
	subscriptionKind mSubKind;
	// Only used before the object is persisted.
	std::map<long, TemporalProperty*> mUnitValue;
};

#define DEFINE_SUBSCRIPTION_BASE_METHODS																							\
	STDMETHOD(get_ProductOfferingID)(/*[out, retval]*/ long *pVal) \
		{ return MTSubscriptionBase::get_ProductOfferingID(pVal); } \
	STDMETHOD(put_ProductOfferingID)(/*[in]*/ long newVal) \
		{ return MTSubscriptionBase::put_ProductOfferingID(newVal); } \
	STDMETHOD(get_ID)(/*[out, retval]*/ long *pVal)	\
		{ return MTSubscriptionBase::get_ID(pVal); } \
	STDMETHOD(put_ID)(/*[in]*/ long newVal) \
		{ return MTSubscriptionBase::put_ID(newVal); } \
	STDMETHOD(RemoveICBPriceListMapping)(/*[in]*/ long aPI_ID,/*[in]*/ long aPtdID) \
		{ return MTSubscriptionBase::RemoveICBPriceListMapping(aPI_ID,aPtdID); } \
	STDMETHOD(SetICBPriceListMapping)(/*[in]*/ long aPrcItemID,/*[in]*/ long aParamTblID,BSTR CurrencyCode) \
		{ return MTSubscriptionBase::SetICBPriceListMapping(aPrcItemID,aParamTblID,CurrencyCode); } \
	STDMETHOD(GetICBPriceListMapping)(/*[in]*/ long aPrcItemID,/*[in]*/ long ParamTableID,/*[out, retval]*/ IMTPriceListMapping** ppMapping) \
		{ return MTSubscriptionBase::GetICBPriceListMapping(aPrcItemID,ParamTableID,ppMapping); } \
	STDMETHOD(SetProductOffering)(/*[in]*/ long aProductOfferingID) \
		{ return MTSubscriptionBase::SetProductOffering(aProductOfferingID); } \
	STDMETHOD(GetProductOffering)(/*[out, retval]*/ IMTProductOffering** ppProductOffering) \
		{ return MTSubscriptionBase::GetProductOffering(ppProductOffering); } \
	STDMETHOD(get_EffectiveDate)(/*[out, retval]*/ IMTPCTimeSpan* *pVal) \
		{ return MTSubscriptionBase::get_EffectiveDate(pVal); } \
	STDMETHOD(put_EffectiveDate)(/*[in] */ IMTPCTimeSpan* newVal) \
		{ return MTSubscriptionBase::put_EffectiveDate(newVal); } \
	STDMETHOD(get_Cycle)(IMTPCCycle** pCycle) \
		{ return MTSubscriptionBase::get_Cycle(pCycle); } \
	STDMETHOD(put_Cycle)(IMTPCCycle* pCycle) \
		{ return MTSubscriptionBase::put_Cycle(pCycle); } \
	STDMETHOD(get_ExternalIdentifier)(BSTR* ppGUID) \
		{ return MTSubscriptionBase::get_ExternalIdentifier(ppGUID); } \
	STDMETHOD(put_ExternalIdentifier)(BSTR pGUID) \
		{ return MTSubscriptionBase::put_ExternalIdentifier(pGUID); } \
	STDMETHOD(GetParamTablesAsRowset)(::IMTSQLRowset** ppRowset) \
    { return MTSubscriptionBase::GetParamTablesAsRowset(ppRowset); } \
  STDMETHOD(SetRecurringChargeUnitValue)(/*[in]*/ long aPrcItemID,/*[in]*/ DECIMAL aUnitValue, /*[in]*/ DATE aStartDate, /*[in]*/ DATE aEndDate) \
    { return MTSubscriptionBase::SetRecurringChargeUnitValue(aPrcItemID, aUnitValue, aStartDate, aEndDate); } \
  STDMETHOD(GetRecurringChargeUnitValue)(/*[in]*/ long aPrcItemID,/*[in]*/ DATE aEffDate,/*[out,retval]*/ DECIMAL* apUnitValue) \
    { return MTSubscriptionBase::GetRecurringChargeUnitValue(aPrcItemID, aEffDate, apUnitValue); } \
  STDMETHOD(GetRecurringChargeUnitValuesAsRowset)(/*[out,retval]*/ ::IMTRowSet* * apUnitValues) \
    { return MTSubscriptionBase::GetRecurringChargeUnitValuesAsRowset(apUnitValues); } \
  STDMETHOD(GetRecurringChargeUnitValuesFromMemoryAsRowset)(/*[out,retval]*/ ::IMTRowSet* * apUnitValues) \
    { return MTSubscriptionBase::GetRecurringChargeUnitValuesFromMemoryAsRowset(apUnitValues); } \
	STDMETHOD(get_WarnOnEBCRStartDateChange)(/*[out, retval]*/ VARIANT_BOOL *pVal) \
    { return MTSubscriptionBase::get_WarnOnEBCRStartDateChange(pVal); } \


#endif //__MTSUBSCRIPTIONBASE_H__
