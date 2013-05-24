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

#include "StdAfx.h"
#include "MTProductCatalog.h"
#include "MTGSubMember.h"
#include "MTProductCatalogMetaData.h"
#include <metra.h>
#include <mtcomerr.h>
#include <mttime.h>
#include <optionalvariant.h>


/////////////////////////////////////////////////////////////////////////////
// CMTGSubMember

STDMETHODIMP CMTGSubMember::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTGSubMember
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

HRESULT CMTGSubMember::FinalConstruct()
{
	try {
		LoadPropertiesMetaData(PCENTITY_TYPE_GSUBMEMBER);

		PutPropertyValue("OldStartDate",getMinMTOLETime());
		PutPropertyValue("OldEndDate",getMinMTOLETime());

		return CoCreateFreeThreadedMarshaler(
			GetControllingUnknown(), &m_pUnkMarshaler.p);
	}
	catch (_com_error & err) { 
		return LogAndReturnComError(PCCache::GetLogger(),err); 
	}
}


STDMETHODIMP CMTGSubMember::get_AccountID(long *pVal)
{
	return GetPropertyValue("Account ID", pVal);
}

STDMETHODIMP CMTGSubMember::put_AccountID(long newVal)
{
	return PutPropertyValue("Account ID", newVal);
}

STDMETHODIMP CMTGSubMember::get_StartDate(DATE *pVal)
{
	return GetPropertyValue("StartDate",pVal);
}

STDMETHODIMP CMTGSubMember::put_StartDate(DATE newVal)
{
	return PutPropertyValue("StartDate",newVal);
}

STDMETHODIMP CMTGSubMember::get_EndDate(DATE *pVal)
{
	return GetPropertyValue("EndDate",pVal);
}

STDMETHODIMP CMTGSubMember::get_OldEndDate(DATE *pVal)
{
	return GetPropertyValue("OldEndDate",pVal);
}


STDMETHODIMP CMTGSubMember::get_OldStartDate(DATE *pVal)
{
	return GetPropertyValue("OldStartDate",pVal);
}


STDMETHODIMP CMTGSubMember::put_EndDate(DATE newVal)
{
	mbEndDateNotSpecified = false;
	return PutPropertyValue("EndDate",newVal);
}

STDMETHODIMP CMTGSubMember::get_EndDateNotSpecified(VARIANT_BOOL *pVal)
{
	ASSERT(pVal);
	if(!pVal) return E_POINTER;

	*pVal = mbEndDateNotSpecified ? VARIANT_TRUE : VARIANT_FALSE;
	return S_OK;
}


STDMETHODIMP CMTGSubMember::get_OldEndDateNotSpecified(VARIANT_BOOL *pVal)
{
	*pVal = mbOldEndDateNotSpecified ? VARIANT_TRUE : VARIANT_FALSE;
	return S_OK;
}


STDMETHODIMP CMTGSubMember::NewDateRange(DATE aNewStartDate, VARIANT aNewEndDate)
{
	try {
		MTPRODUCTCATALOGLib::IMTGSubMemberPtr subMemberPtr(this);

		DATE oldStart = subMemberPtr->GetStartDate();
		PutPropertyValue("OldStartDate",oldStart);

		if(!mbEndDateNotSpecified) {
			DATE oldEnd = subMemberPtr->GetEndDate();
			mbOldEndDateNotSpecified = false;
			PutPropertyValue("OldEndDate",oldEnd);
		}

		subMemberPtr->PutStartDate(_variant_t(aNewStartDate,VT_DATE));

		_variant_t realEndDate;

		if(OptionalVariantConversion(aNewEndDate,VT_DATE,realEndDate)) {
			subMemberPtr->PutEndDate(realEndDate);
		}
		else {
			// reset the boolean value that indicates if the end date is specified or not
			mbEndDateNotSpecified = true;
		}
	}
	catch(_com_error& err) {
		return LogAndReturnComError(PCCache::GetLogger(),err); 
	}
	return S_OK;
}




STDMETHODIMP CMTGSubMember::get_AccountName(BSTR *pVal)
{
	return GetPropertyValue("AccountName",pVal);
}

STDMETHODIMP CMTGSubMember::put_AccountName(BSTR newVal)
{
	return PutPropertyValue("AccountName",newVal);
}

STDMETHODIMP CMTGSubMember::Validate()
{
	try {
    ValidateProperties();
	}
	catch(_com_error& err) {
		return LogAndReturnComError(PCCache::GetLogger(),err); 
	}
	return S_OK;
}
