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
***************************************************************************/

#ifndef __MTACCOUNTSTATEIMPL_H__
#define __MTACCOUNTSTATEIMPL_H__
#pragma once

#include <errobj.h>
#include <NTLogger.h>
#include <loggerconfig.h>
#include <autologger.h>
#include <mtprogids.h>

#include "MTAccountStatesLogging.h"
#import <MTAccountStates.tlb> rename ("EOF", "RowsetEOF")

template<class T, const CLSID* pclsid = &CLSID_NULL>
class MTAccountStateImpl : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<T,pclsid>,
	public IDispatchImpl<IMTAccountStateInterface, &IID_IMTAccountStateInterface, &LIBID_MTACCOUNTSTATESLib>
{
protected: // data
	MTACCOUNTSTATESLib::IMTStatePtr mpBizRules;
	_bstr_t mName;

protected:
	virtual void InitializeState(MTACCOUNTSTATESLib::IMTAccountStateMetaDataPtr) = 0;
	MTAutoInstance<MTAutoLoggerImpl<aAccountStateImplLogTitle> > mLogger;

public:

	STDMETHOD(FinalConstruct)()
	{
		HRESULT hr(S_OK);
		char* buffer;

		try
		{
			// create Account State Meta Data object
			MTACCOUNTSTATESLib::IMTAccountStateMetaDataPtr mtptr;
			
			// create instance
			hr = mtptr.CreateInstance(MTPROGID_MTACCOUNTSTATEMETADATA);
			if (!SUCCEEDED(hr))
			{
    		buffer = "Unable to initialize account state meta data object";
				mLogger->LogThis(LOG_ERROR, buffer);
				return Error(buffer, IID_IMTAccountStateInterface, hr);
			}
			
			// initialize
			mtptr->Initialize();
			
			// get active state meta data
			InitializeState(mtptr);

			// store the name
			mName = mpBizRules->Name;
		}
		catch (_com_error& e)
		{
			return ReturnComError(e);
		}

		return S_OK;
	}

	//
	//
	//
	STDMETHOD(Initialize)()
	{
		return S_OK;
	}

	//
	//
	//
	STDMETHOD(GetBusinessRuleValue)(BSTR BusinessRule, VARIANT_BOOL* pVal)
	{
		if (!pVal)
			return E_POINTER;
		else
			*pVal = VARIANT_FALSE;

		try {
			_bstr_t bstrBizRule = _bstr_t(BusinessRule);
			*pVal = mpBizRules->GetBusinessRuleValue(bstrBizRule);
		}
		catch (_com_error& e) {
			return ReturnComError(e);
		}

		return S_OK;
	}

	//
	//
	//
	STDMETHOD(CanApplyRecurringCharges)(VARIANT_BOOL* pVal)
	{
		if (!pVal)
			return E_POINTER;
		else
			*pVal = VARIANT_FALSE;

		try {
			*pVal = mpBizRules->GetBusinessRuleValue("generaterc");
		}
		catch (_com_error& e) {
			return ReturnComError(e);
		}

		return S_OK;
	}

	//
	//
	//
	STDMETHOD(CanApplyNonRecurringCharges)(VARIANT_BOOL* pVal)
	{
		if (!pVal)
			return E_POINTER;
		else
			*pVal = VARIANT_FALSE;

		try {
			*pVal = mpBizRules->GetBusinessRuleValue("generatenrc");
		}
		catch (_com_error& e) {
			return ReturnComError(e);
		}
		return S_OK;
	}

	//
	//
	//
	STDMETHOD(CanApplyDiscounts)(VARIANT_BOOL* pVal)
	{
		if (!pVal)
			return E_POINTER;
		else
			*pVal = VARIANT_FALSE;

		try {
			*pVal = mpBizRules->GetBusinessRuleValue("generatediscount");
		}
		catch (_com_error& e) {
			return ReturnComError(e);
		}
		return S_OK;
	}

	//
	//
	//
	STDMETHOD(CanRateUsage)(VARIANT_BOOL* pVal)
	{
		if (!pVal)
			return E_POINTER;
		else
			*pVal = VARIANT_FALSE;

		try {
			*pVal = mpBizRules->GetBusinessRuleValue("rateusage");
		}
		catch (_com_error& e) {
			return ReturnComError(e);
		}
		return S_OK;
	}

	//
	//
	//
	STDMETHOD(CanApplyCredits)(VARIANT_BOOL* pVal)
	{
		if (!pVal)
			return E_POINTER;
		else
			*pVal = VARIANT_FALSE;

		try {
			*pVal = mpBizRules->GetBusinessRuleValue("applycredit");
		}
		catch (_com_error& e) {
			return ReturnComError(e);
		}
		return S_OK;
	}

	//
	//
	//
	STDMETHOD(CanAddCharges)(VARIANT_BOOL* pVal)
	{
		if (!pVal)
			return E_POINTER;
		else
			*pVal = VARIANT_FALSE;

		try {
			*pVal = mpBizRules->GetBusinessRuleValue("addcharge");
		}
		catch (_com_error& e) {
			return ReturnComError(e);
		}
		return S_OK;
	}

	//
	//
	//
	STDMETHOD(CanLoginToMetraView)(VARIANT_BOOL* pVal)
	{
		if (!pVal)
			return E_POINTER;
		else
			*pVal = VARIANT_FALSE;

		try {
			*pVal = mpBizRules->GetBusinessRuleValue("canlogintoMetraView");
		}
		catch (_com_error& e) {
			return ReturnComError(e);
		}
		return S_OK;
	}

	STDMETHOD(CanGenerateInvoices)(VARIANT_BOOL* pVal)
	{
		try {
			*pVal = mpBizRules->GetBusinessRuleValue("generateinvoice");
		}
		catch (_com_error& e) {
			return ReturnComError(e);
		}
		return S_OK;
	}

	//
	//
	//
	STDMETHOD(CanSubscribe)(VARIANT_BOOL* pVal)
	{
		if (!pVal)
			return E_POINTER;
		else
			*pVal = VARIANT_FALSE;

		try {
			*pVal = mpBizRules->GetBusinessRuleValue("subscribe");
		}
		catch (_com_error& e) {
			return ReturnComError(e);
		}
		return S_OK;
	}

	//
	//
	//
	STDMETHOD(CanDoSelfCare)(VARIANT_BOOL* pVal)
	{
		if (!pVal)
			return E_POINTER;
		else
			*pVal = VARIANT_FALSE;

		try {
			*pVal = mpBizRules->GetBusinessRuleValue("selfcare");
		}
		catch (_com_error& e) {
			return ReturnComError(e);
		}
		return S_OK;
	}

	STDMETHOD(CanMoveAccount)(VARIANT_BOOL* pVal)
	{
		if (!pVal)
			return E_POINTER;
		else
			*pVal = VARIANT_FALSE;

		try {
			*pVal = mpBizRules->GetBusinessRuleValue("MoveAccount");
		}
		catch (_com_error& e) {
			return ReturnComError(e);
		}
		return S_OK;
	}

	STDMETHOD(CanBeVisibleInMAM)(VARIANT_BOOL* pVal)
	{
		if (!pVal)
			return E_POINTER;
		else
			*pVal = VARIANT_FALSE;

		try {
			*pVal = mpBizRules->GetBusinessRuleValue("visibleinMAM");
		}
		catch (_com_error& e) {
			return ReturnComError(e);
		}
		return S_OK;
	}

	//
	//
	//
	STDMETHOD(get_Name)(BSTR *pVal)
	{
		*pVal = mName.copy();
		return S_OK;
	}

	//
	//
	//
	STDMETHOD(put_Name)(BSTR newVal)
	{
		mName = newVal;
		return S_OK;
	}
};

#endif //__MTACCOUNTSTATEIMPL_H__
