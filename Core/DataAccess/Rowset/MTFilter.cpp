/**************************************************************************
* Copyright 1997-2001 by MetraTech
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
* $Header: c:\development35\Core\DataAccess\Rowset\MTFilter.cpp, 10, 7/15/2002 4:51:37 PM, Derek Young$
* 
***************************************************************************/

#include "StdAfx.h"
#include "Rowset.h"
#include "MTFilterImpl.h"
#include <metra.h>
#include <mtcom.h>
#include <comutil.h>
#include <mtcomerr.h>
#include <mtprogids.h>

#import <Rowset.tlb> rename ("EOF", "RowsetEOF") 
using namespace MTFilterNamespace;

/////////////////////////////////////////////////////////////////////////////
// CMTilter


STDMETHODIMP CMTFilter::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTDataFilter
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

STDMETHODIMP CMTFilter::get_Item(long aIndex,IMTFilterItem **pVal)
{
	ASSERT(pVal);
	if(!pVal) return E_POINTER;

	m_coll[aIndex].CopyTo(pVal);
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     	
// Arguments:     
//                
// Return Value:  
// Errors Raised: 
// Description:   
// ----------------------------------------------------------------

STDMETHODIMP CMTFilter::Add(BSTR propName, VARIANT aOperator, VARIANT Value)
{
	try {
		// step 1: create a filter item
		ROWSETLib::IMTFilterItemPtr aFilterItem(__uuidof(MTFilterItem));
		// step 2: populate it
        // ESR-3281 and ESR-3315,(Revert CORE-1778) if using a data access method that supports UniCode,(i.e ADO.NET record sets) then "Escape" the string with ("N"), (ADO disconnected record sets DO NOT support unicode)
		aFilterItem->PutEscapeString(mEscapeString);
		aFilterItem->PutIsWhereClause(mIsWhereClause);
		aFilterItem->PutPropertyName(propName);
    aFilterItem->PutIsOracle(mIsOracle);
		_variant_t vtOperator(aOperator);

		switch(vtOperator.vt) {
			case VT_BSTR:
				aFilterItem->PutOperatorAsString(_bstr_t(vtOperator)); break;
			case VT_I2:
			case VT_I4:
			case VT_UI2:
			case VT_UI4:
			case VT_INT:
			case VT_UINT:
				aFilterItem->PutOperator((ROWSETLib::MTOperatorType)(long)vtOperator); break;
			default:
			return Error("Unsupported variant type for operator");
		}
		
		aFilterItem->PutValue(Value);
		// step 3: add it to the collection
		CComPtr<IMTFilterItem> aTempPtr = reinterpret_cast<IMTFilterItem*>(aFilterItem.GetInterfacePtr());
		m_coll.push_back(aTempPtr);
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     	
// Arguments:     
//                
// Return Value:  
// Errors Raised: 
// Description:   
// ----------------------------------------------------------------

#pragma warning(disable :4018)
STDMETHODIMP CMTFilter::Remove(long aIndex)
{
	FilterProp::iterator it= m_coll.begin();

	if(aIndex < 0 || aIndex >= m_coll.size()) {
		return Error("Not a valid index");
	}

	for(int i=0;i<aIndex;i++,it++);
	m_coll.erase(it);
	long size = m_coll.size();
	return S_OK;
}
#pragma warning(default : 4018)

STDMETHODIMP CMTFilter::Clear()
{
	m_coll.clear();
	return S_OK;
}


// ----------------------------------------------------------------
// Name:    CreateMergedFilter 	
// Arguments:     
//                
// Return Value:  
// Errors Raised: 
// Description:   
// ----------------------------------------------------------------

STDMETHODIMP CMTFilter::CreateMergedFilter(IMTDataFilter *pFilter,MTMergeAction aMergeAction,IMTDataFilter **pMergedFilter)
{
	ASSERT(pFilter && pMergedFilter);
	if(!(pFilter && pMergedFilter)) return E_POINTER;

	try {

		_bstr_t NewMergeFilterStr;
		// step 1: get the count of the first filter.  If it not 0, get the string
		ROWSETLib::IMTDataFilterPtr aInFilter(pFilter);
		if(aInFilter->GetCount() > 0) {
			NewMergeFilterStr += "(";
			NewMergeFilterStr += aInFilter->GetFilterString();
			NewMergeFilterStr += ") ";
		}

		switch(aMergeAction) {
			case ROWSETLib::MERGE_AND:
				NewMergeFilterStr += " AND "; break;
			case ROWSETLib::MERGE_OR:
				NewMergeFilterStr += " OR "; break;
		default:
			ASSERT("Unknown type");
			return Error("Unknown merge type");
		}

		// step 2: get the count of the objects filter, if it is not 0, get the string
		if(m_coll.size() > 0 || mFilterString.length() != 0) {
			NewMergeFilterStr += "(";
			BSTR aTempBstr;
			get_FilterString(&aTempBstr);
			NewMergeFilterStr += _bstr_t(aTempBstr,false); // temporary object deallocates BSTR
			NewMergeFilterStr += ") ";
		}

		// step 3: combine them together with the appropriate AND or OR clause
		ROWSETLib::IMTDataFilterPtr aOutputFilter(__uuidof(MTDataFilter));
		aOutputFilter->PutFilterString(NewMergeFilterStr);
		*pMergedFilter = reinterpret_cast <IMTDataFilter*>(aOutputFilter.Detach());
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     	get_FilterString
// Arguments:   pFilterStr (output)
//                
// Return Value:  S_OK
// Errors Raised: exception on building filter string
// Description:   Iterate through the list of filters and combine them with the 'AND' operator
// ----------------------------------------------------------------

STDMETHODIMP CMTFilter::get_FilterString(BSTR* pFilterStr)
{
	try {

		ASSERT(pFilterStr);
		if(!pFilterStr) return E_POINTER;
		// step 1: iterate through all the filters and combine them together
		_bstr_t aFilterStr = mFilterString;

		FilterProp::iterator it= m_coll.begin();
		while(it != m_coll.end()) {
				ROWSETLib::IMTFilterItemPtr aFilterItem = (IMTFilterItem*)(*it);
				it++;

				// copy in the where clause flag again since it might have changed since the filter was created
				aFilterItem->PutIsWhereClause(mIsWhereClause);
				aFilterStr += aFilterItem->GetFilterString();
				if(it != m_coll.end()) {
					aFilterStr += " AND ";
				}
		}
		*pFilterStr = aFilterStr.copy();
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
	return S_OK;
}

STDMETHODIMP CMTFilter::put_FilterString(BSTR pFilterStr)
{
	ASSERT(pFilterStr);
	if(!pFilterStr) return E_POINTER;
	mFilterString = pFilterStr;
	return S_OK;
}

STDMETHODIMP CMTFilter::AddIsNull(BSTR propName)
{
	try {
		// step 1: create a filter item
		ROWSETLib::IMTFilterItemPtr aFilterItem(__uuidof(MTFilterItem));
		// step 2: populate it
		aFilterItem->PutPropertyName(propName);
		aFilterItem->PutOperator(ROWSETLib::OPERATOR_TYPE_IS_NULL);
    _variant_t vNull;
    vNull.ChangeType(VT_NULL);
		aFilterItem->PutValue(vNull);
		// step 3: add it to the collection
		CComPtr<IMTFilterItem> aTempPtr = reinterpret_cast<IMTFilterItem*>(aFilterItem.GetInterfacePtr());
		m_coll.push_back(aTempPtr);
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
	return S_OK;
}

STDMETHODIMP CMTFilter::AddIsNotNull(BSTR propName)
{
	try {
		// step 1: create a filter item
		ROWSETLib::IMTFilterItemPtr aFilterItem(__uuidof(MTFilterItem));
		// step 2: populate it
		aFilterItem->PutPropertyName(propName);
		aFilterItem->PutOperator(ROWSETLib::OPERATOR_TYPE_IS_NOT_NULL);
    _variant_t vNull;
    vNull.ChangeType(VT_NULL);
		aFilterItem->PutValue(vNull);
		// step 3: add it to the collection
		CComPtr<IMTFilterItem> aTempPtr = reinterpret_cast<IMTFilterItem*>(aFilterItem.GetInterfacePtr());
		m_coll.push_back(aTempPtr);
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
	return S_OK;
}

STDMETHODIMP CMTFilter::put_IsWhereClause(/*[in]*/ VARIANT_BOOL isWhere)
{
	mIsWhereClause = isWhere;
	return S_OK;
}

STDMETHODIMP CMTFilter::get_IsWhereClause(/*[out, retval]*/ VARIANT_BOOL *val)
{
	*val = mIsWhereClause;
	return S_OK;
}
STDMETHODIMP CMTFilter::put_IsOracle(/*[in]*/ VARIANT_BOOL newVal)
{
	mIsOracle = newVal;
	return S_OK;
}

STDMETHODIMP CMTFilter::get_IsOracle(/*[out, retval]*/ VARIANT_BOOL *pVal)
{
	*pVal = mIsOracle;
	return S_OK;
}
// ESR-3281 and ESR-3315,(Revert CORE-1778) if using a data access method that supports UniCode,(i.e ADO.NET record sets)
// then "Escape" the string with ("N"), (ADO disconnected record sets DO NOT support unicode)
STDMETHODIMP CMTFilter::put_EscapeString(/*[in]*/ VARIANT_BOOL newVal)
{
	mEscapeString = newVal;
	return S_OK;
}

// ESR-3281 and ESR-3315,(Revert CORE-1778) if using a data access method that supports UniCode,(i.e ADO.NET record sets)
// then "Escape" the string with ("N"), (ADO disconnected record sets DO NOT support unicode)
STDMETHODIMP CMTFilter::get_EscapeString(/*[out, retval]*/ VARIANT_BOOL *pVal)
{
	*pVal = mEscapeString;
	return S_OK;
}