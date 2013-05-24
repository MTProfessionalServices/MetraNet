/**************************************************************************
* Copyright 1997-2000 by MetraTech
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
* Created by: Boris Partensky
* $Header$
* 
***************************************************************************/

// MTEnumerator.cpp : Implementation of CMTEnumerator
#include "StdAfx.h"
#include "MTEnumConfig.h"
#include "EnumConfig.h"
#include "MTEnumerator.h"

HRESULT CMTEnumerator::FinalConstruct()
{
	return CoCreateFreeThreadedMarshaler(
		GetControllingUnknown(), &m_pUnkMarshaler.p);
}


/////////////////////////////////////////////////////////////////////////////
// CMTEnumerator

// ----------------------------------------------------------------
// Arguments:     
// Return Value:  
// Raised Errors:
// Description:  AUTO GENERATED
// ----------------------------------------------------------------

STDMETHODIMP CMTEnumerator::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTEnumerator
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}



// ----------------------------------------------------------------
// Name:     			get_Name
// Arguments:     
// Return Value:  BSTR* val - enumerator name
// Raised Errors:
// Description:  Returns name for this enumerator
// ----------------------------------------------------------------
STDMETHODIMP CMTEnumerator::get_Name(BSTR *pVal)
{
	*pVal = mEnumerator.GetEnumName().copy();
	return S_OK;
}


// ----------------------------------------------------------------
// Name:     			put_Name
// Arguments:     BSTR val - enumerator name
// Return Value:  
// Raised Errors:
// Description:		sets a name for this enumerator
// ----------------------------------------------------------------

STDMETHODIMP CMTEnumerator::put_Name(BSTR newVal)
{
	_bstr_t val = newVal;
	mEnumerator.SetEnumName(val);
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     			get_DisplayName
// Arguments:     
// Return Value:  BSTR* val - enumerator display name
// Raised Errors:
// Description:  Returns display name for this enumerator
// ----------------------------------------------------------------
STDMETHODIMP CMTEnumerator::get_DisplayName(BSTR *pVal)
{
	*pVal = mEnumerator.GetEnumName().copy();
	return S_OK;
}


// ----------------------------------------------------------------
// Name:     			put_DisplayName
// Arguments:     BSTR val - enumerator display name
// Return Value:  
// Raised Errors:
// Description:		sets a display name for this enumerator
// ----------------------------------------------------------------

STDMETHODIMP CMTEnumerator::put_DisplayName(BSTR newVal)
{
	// TODO: deal with localization issues here
	return E_NOTIMPL;
}

// ----------------------------------------------------------------
// Name:     			AddValue
// Arguments:     BSTR val - value
// Return Value:  
// Raised Errors:
// Description:		adds a value to this enumerator
// ----------------------------------------------------------------

STDMETHODIMP CMTEnumerator::AddValue(BSTR value)
{
	_bstr_t val = value;
	mEnumerator.AddValue(val);
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     			ClearValue
// Arguments:     BSTR val - value
// Return Value:  
// Raised Errors:
// Description:		removes a value from this enumerator
// ----------------------------------------------------------------

STDMETHODIMP CMTEnumerator::ClearValue(BSTR value)
{
	_bstr_t val = value;
	mEnumerator.RemoveValue(val);
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     			ClearValues
// Arguments:     
// Return Value:  
// Raised Errors:
// Description:		removes all values from this enumerator
// ----------------------------------------------------------------

STDMETHODIMP CMTEnumerator::ClearValues()
{
	mEnumerator.Clear();
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     			get_EnumSpace
// Arguments:     
// Return Value:  BSTR* val - enumspace name
// Raised Errors:
// Description:  Returns name for enum space this enumerator belongs to
// ----------------------------------------------------------------

STDMETHODIMP CMTEnumerator::get_EnumSpace(BSTR *pVal)
{
	*pVal = mEnumerator.GetEnumSpace().copy();
	return S_OK;
}


// ----------------------------------------------------------------
// Name:     			put_EnumSpace
// Arguments:     BSTR val - enumspace name
// Return Value:  
// Raised Errors:
// Description:  INTERNAL USE ONLY
// ----------------------------------------------------------------

STDMETHODIMP CMTEnumerator::put_EnumSpace(BSTR newVal)
{
	_bstr_t val = newVal;
	mEnumerator.SetEnumSpace(val);
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     			get_EnumType
// Arguments:     
// Return Value:  BSTR* val - enumtype name
// Raised Errors:
// Description:  Returns name for enum type this enumerator belongs to
// ----------------------------------------------------------------

STDMETHODIMP CMTEnumerator::get_EnumType(BSTR *pVal)
{
	*pVal = mEnumerator.GetEnumType().copy();
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     			put_EnumType
// Arguments:     BSTR val - enumtype name
// Return Value:  
// Raised Errors:
// Description:  INTERNAL USE ONLY
// ----------------------------------------------------------------

STDMETHODIMP CMTEnumerator::put_EnumType(BSTR newVal)
{
	_bstr_t val = newVal;
	mEnumerator.SetEnumType(val);
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     			WriteSet
// Arguments:     
// Return Value:  
// Raised Errors:
// Description:  INTERNAL USE ONLY
// ----------------------------------------------------------------

STDMETHODIMP CMTEnumerator::WriteSet(IMTConfigPropSet *apPropSet)
{
	HRESULT hr = S_OK;

  try
	{
		mLogger->LogVarArgs(	LOG_DEBUG, "In CMTEnumerator::WriteSet");
		mLogger->LogVarArgs(	LOG_DEBUG, "Writing configuration for enumerator %s",
													(char* )mEnumerator.GetEnumName());
	
	
		MTConfigLib::IMTConfigAttribSetPtr pAttrib(MTPROGID_CONFIG_ATTRIB_SET);
	
		//have to initialize it
		pAttrib->Initialize(); 
	
		string procName = "CMTEnumerator::WriteSet";

		if (apPropSet == NULL)
			return E_POINTER;

		MTConfigLib::IMTConfigPropSetPtr pSet(apPropSet);
	
		//create attribute pair
		hr = pAttrib->AddPair(ATTRIB_TAG_NAME, mEnumerator.GetEnumName());
	
		if(!SUCCEEDED(hr)) return hr;
		MTConfigLib::IMTConfigPropSetPtr pEnumeratorSet = pSet->InsertSet(ENUM_ENTRY_TAG_NAME);
		hr = pEnumeratorSet->put_AttribSet(pAttrib);
	
		if(!SUCCEEDED(hr)) return hr;
	
	

		if (pEnumeratorSet == NULL)
		{
			hr = E_FAIL;
			return (hr);
		}
		//insert description tag
		//_variant_t desc;
		_variant_t value;
	
		//desc.SetString(mEnumerator.GetEnumDescription().c_str());
		//pEnumeratorSet->InsertProp(DESC_ENUM_TAG, MTConfigLib::PROP_TYPE_STRING, desc.lVal);
		EnumValueList* pValues = mEnumerator.GetValues();
		
		for (unsigned int i=0;i<pValues->size();)
		{
			value = variant_t((pValues->at(i++)).c_str());
			pEnumeratorSet->InsertProp(ENUM_VALUE_TAG_NAME, MTConfigLib::PROP_TYPE_STRING, value);
		}
	}
	catch(_com_error err)
	{
		mLogger->LogVarArgs(LOG_ERROR, "CMTEnumerator::WriteSet failed with error <%s>!",
				err.Description());
		return ReturnComError(err);
	}

	return hr;
}

// ----------------------------------------------------------------
// Name:     			NumValues
// Arguments:     
// Return Value:  int* - num of values
// Raised Errors:
// Description:		Returns a number of values in this enumerator
// ----------------------------------------------------------------

STDMETHODIMP CMTEnumerator::NumValues(int *count)
{
	HRESULT nRet = S_OK;
	*count = mEnumerator.NumValues();
	return nRet;
}

// ----------------------------------------------------------------
// Name:     			ElementAt
// Arguments:     int pos	-	position index
// Return Value:  BSTR*	-	value at this position
// Raised Errors:
// Description:		Returns a value at a specified position
// ----------------------------------------------------------------

STDMETHODIMP CMTEnumerator::ElementAt(int pos, BSTR *pValue)
{
	HRESULT nRet = S_OK;
	try
	{
		*pValue = mEnumerator.ValueAt(pos).copy();
	}
	catch(_com_error err)
	{
		//Should never get here
	}
	return nRet;
}

// ----------------------------------------------------------------
// Name:     			get_FQN
// Arguments:     
// Return Value:  BSTR* val - FQN for this enumerator
// Raised Errors:
// Description:  INTERNAL USE ONLY
// ----------------------------------------------------------------

STDMETHODIMP CMTEnumerator::get_FQN(BSTR *pVal)
{
	(*pVal) = _bstr_t(mEnumerator.GetFQNString().c_str()).copy();

	return S_OK;
}
