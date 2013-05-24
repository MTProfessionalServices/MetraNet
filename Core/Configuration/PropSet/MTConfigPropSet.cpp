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
* Created by: 
* $Header$
* 
***************************************************************************/

/*

MTConfigPropSet is a collection of configuration properties (MTConfigProp objects).
Along with being a container for these objects, this class also provides various
ways to iterate through the collection and to search for a specific configuration
property contained within it.

*/


// MTConfigPropSet.cpp : Implementation of CMTConfigPropSet

// disable identifier was truncated to '255' characters in the debug information
#pragma warning(disable : 4786)

#include "StdAfx.h"

#include "PropSet.h"
#include "MTConfigPropSet.h"

#include "MTConfigProp.h"

#include <comdef.h>
#include <mtcom.h>
#include <comutil.h>

#include <fstream>

#include <win32net.h>

#include <mtcomerr.h>

#include <mtglobal_msg.h>
#include <MTUtil.h>

#include "ClassMTConfig.h"
#include "MTConfigAttribSet.h"
#include <XMLParser.h>

#import <MTConfigLib.tlb>


STDMETHODIMP CMTConfigPropSet::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTConfigPropSet,
	};
	for (int i=0;i<sizeof(arr)/sizeof(arr[0]);i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}


// ----------------------------------------------------------------
// Arguments:     N/A
// Return Value:  N/A
// Errors Raised: N/A
// Description:   default constructor
// ----------------------------------------------------------------
CMTConfigPropSet::CMTConfigPropSet()
{
	mpPropSet = NULL;

	mChecksumSwitch = FALSE;
}


// ----------------------------------------------------------------
// Arguments:     N/A
// Return Value:  N/A
// Errors Raised: N/A
// Description:   destructor
// ----------------------------------------------------------------
CMTConfigPropSet::~CMTConfigPropSet()
{
	if (mpPropSet)
	{
		if (mSetOwner)
			delete mpPropSet;
		mpPropSet = NULL;
	}
}


// ----------------------------------------------------------------
// Arguments:     XMLConfigPropSet * apSet - ???
//                BOOL aSetOwner - ???
// Return Value:  N/A    
// Errors Raised: N/A
// Description:   ???
// ----------------------------------------------------------------
void CMTConfigPropSet::SetPropSet(XMLConfigPropSet * apSet, BOOL aSetOwner)
{
	mSetOwner = aSetOwner;
	mpPropSet = apSet;

	mIterator = apSet->GetContents().begin();
	mBeginIterator = apSet->GetContents().begin();
	mEndIterator = apSet->GetContents().end();
}

#pragma warning(push)
#pragma warning(disable : 4700)


// ----------------------------------------------------------------
// Arguments:     XMLObject * apObject - ???
// Return Value:  IMTConfigProp * * apProp - ???
// Errors Raised: N/A
// Description:   ???
// ----------------------------------------------------------------
HRESULT CMTConfigPropSet::SetPropObj(XMLObject * apObject, IMTConfigProp * * apProp)
{
	if (!apProp)
		return E_POINTER;

	// end of iteration.  Return OK, but set the interface to NULL
	if (!apObject)
	{
		*apProp = NULL;
		return S_OK;
	}

	CComObject<CMTConfigProp> * prop;
	CComObject<CMTConfigProp>::CreateInstance(&prop);
	if (!prop)
		return E_OUTOFMEMORY;

	// have to AddRef or the count will be 0
	HRESULT hr =
		prop->QueryInterface(IID_IMTConfigProp,
												 reinterpret_cast<void**>(apProp));

	if (FAILED(hr))
	{
		delete prop;
		return hr;
	}

	XMLConfigNameVal * nameval = ConvertUserObject(apObject, nameval);
	if (nameval)
	{
		// the prop object is only valid for the lifetime of the prop set
		prop->SetNameValue(nameval);
	}
	else
	{
		XMLConfigPropSet * subset = ConvertUserObject(apObject, subset);
		if (!subset)
			return E_FAIL;	// unrecognized type - possible caused by a parse error
		prop->SetPropSet(subset);
	}
	return S_OK;
}
#pragma warning(pop)


// ----------------------------------------------------------------
// Arguments:     N/A
// Return Value:  IMTConfigProp * * apProp - the next property
// Errors Raised: N/A
// Description:   Returns the next property in the set.
// ----------------------------------------------------------------
STDMETHODIMP CMTConfigPropSet::Next(IMTConfigProp * * apProp)
{
	if (!apProp)
		return E_POINTER;
	
	if (mIterator == mEndIterator)
		return SetPropObj(NULL, apProp);

	XMLObject * obj = *mIterator;
	mIterator++;
	return SetPropObj(obj, apProp);
}


// ----------------------------------------------------------------
// Arguments:     N/A
// Return Value:  IMTConfigProp * * apProp - the previous property    
// Errors Raised: N/A
// Description:   Returns the previous property in the set.
// ----------------------------------------------------------------
STDMETHODIMP CMTConfigPropSet::Previous(IMTConfigProp * * apProp)
{
	if (!apProp)
		return E_POINTER;

	if (mIterator == mBeginIterator)
		return SetPropObj(NULL, apProp);

	--mIterator;
	XMLObject * obj = *mIterator;
	return SetPropObj(*mIterator, apProp);
}


// ----------------------------------------------------------------
// Arguments:     N/A
// Return Value:  N/A    
// Errors Raised: N/A
// Description:   Sets the property set back to its original state.
//                Calling Next after this call will return the first
//                property in the set.
// ----------------------------------------------------------------
STDMETHODIMP CMTConfigPropSet::Reset()
{
	if (!mpPropSet)
		return E_FAIL;

	mBeginIterator = mpPropSet->GetContents().begin();
	mIterator = mBeginIterator;
	mEndIterator = mpPropSet->GetContents().end();

	return S_OK;
}


// ----------------------------------------------------------------
// Arguments:     BSTR aName - the name of the property
// Return Value:  IMTConfigProp * * apProp - the property
// Errors Raised: N/A
// Description:   Gets the next property with the given name 
// ----------------------------------------------------------------
STDMETHODIMP CMTConfigPropSet::NextWithName(BSTR aName, IMTConfigProp * * apProp)
{
	if (!apProp)
		return E_POINTER;

	_bstr_t bstrname(aName);
	const char * name = bstrname;

	XMLConfigObject * obj;
	while (TRUE)
	{
		if (mIterator == mEndIterator)
			break;

		obj = *mIterator;
		mIterator++;
		if (!obj)
			break;

		if (0 == (stricmp(obj->GetName(), name)))
			return SetPropObj(obj, apProp);
	}

	*apProp = NULL;
	return S_FALSE;
}


// ----------------------------------------------------------------
// Arguments:     BSTR aPropName - the property's name
//                PropValType aType - the property's type
// Return Value:  VARIANT_BOOL * apMatch - was a match found?    
// Errors Raised: N/A
// Description:   Searches forward in the set to check whether
//                there is a property which matches the name
//                and the type given. The cursor is returned
//	              back to the original position.
// ----------------------------------------------------------------
STDMETHODIMP
CMTConfigPropSet::NextMatches(/*[in]*/ BSTR aPropName,
															/*[in]*/ PropValType aType,
															/*[out, retval]*/ VARIANT_BOOL * apMatch)
{
	if (!apMatch)
		return E_POINTER;

	IMTConfigProp * prop = NULL;
	HRESULT hr = Next(&prop);

  *apMatch = VARIANT_FALSE;
	BOOL endOfIteration = FALSE;

  do {

    if (!(SUCCEEDED(hr) && prop))
		{
			endOfIteration = TRUE;
			break;
		}

    BSTR name;
    hr = prop->get_Name(&name);

    if(FAILED(hr)) break;

    _bstr_t nameBstr(name, false);
    _bstr_t propNameBstr = aPropName;

    if (0 != wcsicmp((const wchar_t *) nameBstr,
								    (const wchar_t *) propNameBstr))
		    break;


    PropValType type;
    hr = prop->get_PropType(&type);
    if(FAILED(hr)) break;
    *apMatch = (aType == PROP_TYPE_UNKNOWN || type == aType) ? VARIANT_TRUE : VARIANT_FALSE;

  } while(false);

	if (endOfIteration == FALSE)
	{
		// bring the set back to the position it was in before
		IMTConfigProp * previousProp = NULL;
		hr = Previous(&previousProp);
		if (SUCCEEDED(hr) && previousProp)
		{
			previousProp->Release();
			previousProp = NULL;
		}
	}

	if (prop)
	{
		prop->Release();
		prop = NULL;
	}

	if (FAILED(hr))
		*apMatch = VARIANT_FALSE;

	return hr;
}


// ----------------------------------------------------------------
// Arguments:     BSTR aName - the name of the property
// Return Value:  long * apVal - the value of the property     
// Errors Raised: "No long found with name"
// Description:   Gets the next property of type long with 
//                the given name and returns its value.
// ----------------------------------------------------------------
STDMETHODIMP CMTConfigPropSet::NextLongWithName(BSTR aName, long * apVal)
{
	IMTConfigProp * prop;
	HRESULT hr = NextWithName(aName, &prop);
	if (FAILED(hr))
		return hr;

	if (!prop)
	{
		std::wstring errormsg(L"No long found with name ");
		errormsg += aName;
		return Error(errormsg.c_str());
	}

	PropValType type;
	VARIANT val;
	// try to get the long value
	hr = prop->get_Value(&type, &val);

	// release the property now whether it was the correct type or not
	prop->Release();

	HRESULT retCode = S_OK;

	if (FAILED(hr))
		retCode = hr;
	else
	{
		if (type != PROP_TYPE_INTEGER && type != PROP_TYPE_ENUM) {
			_bstr_t errorstr = "value in XML ";
			errorstr += _bstr_t(_variant_t(val));
			errorstr += " does not match requested type";
			retCode = Error((const wchar_t*)errorstr,IID_IMTConfigPropSet,E_INVALIDARG);
		}

		else
		{
			try
			{
				_variant_t var(val);
				*apVal = var;
				retCode = S_OK;
			}
			catch (_com_error err)
			{
				retCode = err.Error();
			}
		}
	}
	VariantClear(&val);
	return retCode;
}


// ----------------------------------------------------------------
// Arguments:     BSTR aName - the name of the property
// Return Value:  BSTR * apVal - the value of the property     
// Errors Raised: "No string found with name"
// Description:   Gets the next property of type string with
//                the given name and returns its value.
// ----------------------------------------------------------------
STDMETHODIMP CMTConfigPropSet::NextStringWithName(BSTR aName, BSTR * apVal)
{
	IMTConfigProp * prop;
	HRESULT hr = NextWithName(aName, &prop);
	if (FAILED(hr))
		return hr;

	if (!prop)
	{
		*apVal = NULL;

		std::wstring errormsg(L"No string found with name ");
		errormsg += aName;
		return Error(errormsg.c_str());
	}

	PropValType type;
	VARIANT val;
	hr = prop->get_Value(&type, &val);

	// release the property now whether it was the correct type or not
	prop->Release();

	if (FAILED(hr))
		return hr;

	if (type != PROP_TYPE_STRING)
		return E_INVALIDARG;

	HRESULT retCode = S_OK;
	try
	{
		_variant_t var(val);
		// TODO: do we need this copy?
		_bstr_t bstr(var);
		*apVal = bstr.copy();
		retCode = S_OK;
	}
	catch (_com_error err)
	{
		retCode = err.Error();
	}
	VariantClear(&val) ;
	return S_OK;

}


// ----------------------------------------------------------------
// Arguments:     BSTR aName - the name of the property
// Return Value:  VARIANT_BOOL * apVal - the value of the property     
// Errors Raised: "No boolean found with name"
// Description:   Gets the next property of type boolean with
//                the given name and returns its value.
// ----------------------------------------------------------------
STDMETHODIMP CMTConfigPropSet::NextBoolWithName(BSTR aName, VARIANT_BOOL * apVal)
{
	IMTConfigProp * prop;
	HRESULT hr = NextWithName(aName, &prop);
	if (FAILED(hr))
		return hr;

	if (!prop)
	{
		std::wstring errormsg(L"No boolean found with name ");
		errormsg += aName;
		return Error(errormsg.c_str());
	}

	PropValType type;
	VARIANT val;
	hr = prop->get_Value(&type, &val);

	// release the property now whether it was the correct type or not
	prop->Release();

	HRESULT retCode = S_OK;

	if (FAILED(hr))
		retCode = hr;
	else
	{
		if (type != PROP_TYPE_BOOLEAN)
			retCode = E_INVALIDARG;
		else
		{
			try
			{
				_variant_t var(val);
				*apVal = (((bool) var) == true) ? VARIANT_TRUE : VARIANT_FALSE;
				retCode = S_OK;
			}
			catch (_com_error err)
			{
				retCode = err.Error();
			}
		}
	}
	VariantClear(&val);
	return retCode;

}


// ----------------------------------------------------------------
// Arguments:     BSTR aName - the name of the property
// Return Value:  PropValType *apType - the type of the variant
//                VARIANT * apVal - the value of the property     
// Errors Raised: "No variant found with name"
// Description:   Gets the next property of type variant with
//                the given name and returns its type and value.
// ----------------------------------------------------------------
STDMETHODIMP CMTConfigPropSet::NextVariantWithName(BSTR aName, PropValType * apType, VARIANT * apVal)
{
	IMTConfigProp * prop;
	HRESULT hr = NextWithName(aName, &prop);
	if (FAILED(hr))
		return hr;

	if (!prop)
	{
		std::wstring errormsg(L"No variant found with name ");
		errormsg += aName;
		return Error(errormsg.c_str());
	}

	hr = prop->get_Value(apType, apVal);

	switch (*apType)
	{
		case PROP_TYPE_DATETIME:
		case PROP_TYPE_TIME:
		{
			long tTime = apVal->lVal;

			DATE  dateVal;
			OleDateFromTimet(&dateVal, tTime);
		
			_variant_t var;
			var = dateVal;

			::VariantCopy(apVal, &var);

			break;
		}
	
		default:
		{
			break;
		}

	}

	// release the property now whether it was the correct type or not
	prop->Release();

	if (FAILED(hr))
		return hr;

	return S_OK;
}


// ----------------------------------------------------------------
// Arguments:     BSTR aName - the name of the property
// Return Value:  double * apVal - the value of the property     
// Errors Raised: "No double found with name"
// Description:   Gets the next property of type double with
//                the given name and returns its value.
// ----------------------------------------------------------------
STDMETHODIMP CMTConfigPropSet::NextDoubleWithName(BSTR aName, double * apVal)
{
	IMTConfigProp * prop;
	HRESULT hr = NextWithName(aName, &prop);
	if (FAILED(hr))
		return hr;

	if (!prop)
	{
		std::wstring errormsg(L"No double found with name ");
		errormsg += aName;
		return Error(errormsg.c_str());
	}

	PropValType type;
	VARIANT val;
	// try to get the double value
	hr = prop->get_Value(&type, &val);

	// release the property now whether it was the correct type or not
	prop->Release();

	HRESULT retCode = S_OK;

	if (FAILED(hr))
		retCode = hr;
	else
	{
		if (type != PROP_TYPE_DOUBLE)
			retCode = E_INVALIDARG;
		else
		{
			try
			{
				_variant_t var(val);
				*apVal = var;
				retCode = S_OK;
			}
			catch (_com_error err)
			{
				retCode = err.Error();
			}
		}
	}
	VariantClear(&val);
	return retCode;
}

// ----------------------------------------------------------------
// Arguments:     BSTR aName - the name of the property
// Return Value:  DECIMAL * apVal - the value of the property     
// Errors Raised: "No decimal found with name"
// Description:   Gets the next property of type decimal with
//                the given name and returns its value.
// ----------------------------------------------------------------
STDMETHODIMP CMTConfigPropSet::NextDecimalWithName(BSTR aName, VARIANT * apVal)
{
	IMTConfigProp * prop;
	HRESULT hr = NextWithName(aName, &prop);
	if (FAILED(hr))
		return hr;

	if (!prop)
	{
		std::wstring errormsg(L"No decimal found with name ");
		errormsg += aName;
		return Error(errormsg.c_str());
	}

	PropValType type;
	VARIANT val;
	// try to get the decimal value
	hr = prop->get_Value(&type, &val);

	// release the property now whether it was the correct type or not
	prop->Release();

	HRESULT retCode = S_OK;

	if (FAILED(hr))
		retCode = hr;
	else
	{
		if (type != PROP_TYPE_DECIMAL)
			retCode = E_INVALIDARG;
		else
		{
			try
			{
				_variant_t var(val);
				*apVal = var;
				retCode = S_OK;
			}
			catch (_com_error err)
			{
				retCode = err.Error();
			}
		}
	}
	VariantClear(&val);
	return retCode;
}


// ----------------------------------------------------------------
// Arguments:     BSTR aName - the name of the property
// Return Value:  __int64 * apVal - the value of the property     
// Errors Raised: "No long long found with name"
// Description:   Gets the next property of type long long with 
//                the given name and returns its value.
// ----------------------------------------------------------------
STDMETHODIMP CMTConfigPropSet::NextLongLongWithName(BSTR aName, __int64 * apVal)
{
	IMTConfigProp * prop;
	HRESULT hr = NextWithName(aName, &prop);
	if (FAILED(hr))
		return hr;

	if (!prop)
	{
		std::wstring errormsg(L"No long long found with name ");
		errormsg += aName;
		return Error(errormsg.c_str());
	}

	PropValType type;
	VARIANT val;
	// try to get the long value
	hr = prop->get_Value(&type, &val);

	// release the property now whether it was the correct type or not
	prop->Release();

	HRESULT retCode = S_OK;

	if (FAILED(hr))
		retCode = hr;
	else
	{
		if (type != PROP_TYPE_INTEGER && type != PROP_TYPE_ENUM && type != PROP_TYPE_BIGINTEGER) {
			_bstr_t errorstr = "value in XML ";
			errorstr += _bstr_t(_variant_t(val));
			errorstr += " does not match requested type";
			retCode = Error((const wchar_t*)errorstr,IID_IMTConfigPropSet,E_INVALIDARG);
		}

		else
		{
			try
			{
				_variant_t var(val);
				*apVal = var;
				retCode = S_OK;
			}
			catch (_com_error err)
			{
				retCode = err.Error();
			}
		}
	}
	VariantClear(&val);
	return retCode;
}


// ----------------------------------------------------------------
// Arguments:     BSTR aName - the name of the property set
// Return Value:  IMTConfigPropSet * * apSet - the property set     
// Errors Raised: E_INVALIDARG if the next value with this name is not a set.
// Description:   Gets the next property set with the given name.
// ----------------------------------------------------------------
STDMETHODIMP CMTConfigPropSet::NextSetWithName(BSTR aName, IMTConfigPropSet * * apSet)
{
	IMTConfigProp * prop;
	HRESULT hr = NextWithName(aName, &prop);
	if (FAILED(hr))
		return hr;

	if (!prop)
	{
		// no more sets
		*apSet = NULL;
		return S_FALSE;
	}

	PropValType type;
	VARIANT val;
	hr = prop->get_Value(&type, &val);

	// release the property now whether it was the correct type or not
	prop->Release();

	// TODO: verify that this doesn't cause an interface leak.
	if (FAILED(hr))
		return hr;

	if (type != PROP_TYPE_SET)
		return E_INVALIDARG;

	try
	{
		_variant_t var(val, FALSE);
		IUnknown * unknown = var;

		unknown->QueryInterface(IID_IMTConfigPropSet,
														reinterpret_cast<void**>(apSet));

		// the query interface causes the ref count to be one too high.
		(*apSet)->Release();
		return S_OK;
	}
	catch (_com_error err)
	{
		return ReturnComError(err);
	}

	return S_OK;
}


// ----------------------------------------------------------------
// Arguments:     BSTR aName - the name of the property set
//                IMTConfigPropSet * * apNewSet - the set to be
//                                                inserted
// Return Value:  N/A    
// Errors Raised: N/A
// Description:   Adds a subset into the current property set.
// ----------------------------------------------------------------
STDMETHODIMP CMTConfigPropSet::InsertSet(BSTR aName, IMTConfigPropSet * * apNewSet)
{
	ASSERT(mpPropSet);
	if (!mpPropSet)
		return Error("Object not properly initialized");

	_bstr_t bstr(aName);
	XMLConfigPropSet * set = new XMLConfigPropSet(bstr);

	CComObject<CMTConfigPropSet> * setobj;
	CComObject<CMTConfigPropSet>::CreateInstance(&setobj);

	// the set object doesn't own the propset.  this set the propset since it
	// points to it.
	setobj->SetPropSet(set, FALSE);

  if (mIterator != mEndIterator)
  {
    ++mIterator;
  }
	mIterator = mpPropSet->GetContents().insert(mIterator, set);

	// have to AddRef or the count will be 0
	return setobj->QueryInterface(IID_IMTConfigPropSet,
																reinterpret_cast<void**>(apNewSet));
}


// ----------------------------------------------------------------
// Arguments:     IMTConfigPropSet* apNewSet - the prop set to be 
//                added
// Return Value:  N/A
// Errors Raised: N/A
// Description:   This is a recursive function which adds an existing
//                propset to a new propset.
// ----------------------------------------------------------------
STDMETHODIMP CMTConfigPropSet::AddSubSet(IMTConfigPropSet* apNewSet)
{
  ASSERT(apNewSet);
  if(!apNewSet) return E_FAIL;

	// check for self!
	if(static_cast<IMTConfigPropSet*>(this) == apNewSet) {
		return Error("AddSubSet was called with an argument of itself.");
	}



  MTConfigLib::IMTConfigPropPtr aPtr;
  MTConfigLib::IMTConfigPropSetPtr aChild = apNewSet;
  MTConfigLib::PropValType aType;
  _bstr_t name;
  _variant_t aVariant;

  while((aPtr = aChild->Next())!= NULL) {
    
    aType = aPtr->GetPropType();
    name = aPtr->GetName();

    if(aType == MTConfigLib::PROP_TYPE_SET) {
      MTConfigLib::IMTConfigPropSet* pProp;

			// query for the propset interface
      MTConfigLib::IMTConfigPropSetPtr aPropSet = aPtr->GetPropValue();
			ASSERT(aPropSet != NULL);
			MTConfigLib::IMTConfigAttribSetPtr aAttribSet = aPropSet->GetAttribSet();

      InsertSet(name,(IMTConfigPropSet**)&pProp);
      if(pProp) {
				// add the extended attributes if necessary
				if(aAttribSet) {
					pProp->put_AttribSet(aAttribSet.GetInterfacePtr());
				}
        pProp->AddSubSet(aPropSet.GetInterfacePtr());
				pProp->Release();
      }
    }

    else {
      InsertConfigProp((IMTConfigProp*)aPtr.GetInterfacePtr());
    }
  }
  return S_OK;
}


// ----------------------------------------------------------------
// Arguments:     BSTR aName - the name of the property
//                PropValType aType - the type of the property
//                VARIANT aVal - the value of the property
// Return Value:  N/A
// Errors Raised: N/A
// Description:   Creates and inserts a new property into the set
//                immediately after the current property.
// ----------------------------------------------------------------
STDMETHODIMP CMTConfigPropSet::InsertProp(BSTR aName, PropValType aType, VARIANT aVal)
{
	_bstr_t name(aName);
	_variant_t var(aVal);
	MTDecimalVal dv;


	XMLConfigNameVal * nameval = new XMLConfigNameVal;
	nameval->SetName(name);

	// TODO: use the same enum to avoid remapping
	switch (aType)
	{
	case PROP_TYPE_INTEGER:
		nameval->InitInt((int) (long) var);
		break;
	case PROP_TYPE_BIGINTEGER:
		nameval->InitBigInt((__int64) var);
		break;
	case PROP_TYPE_DOUBLE:
		nameval->InitDouble((double) var);
		break;
	case PROP_TYPE_STRING:
		nameval->InitString((_bstr_t) var);
		break;
	case PROP_TYPE_DATETIME:
		{
			time_t aTime;
			if(aVal.vt == VT_DATE) {
				TimetFromOleDate(&aTime,var);
			}
			else {
				aTime = (long)var;
			}
			nameval->InitDateTime(aTime);
		}
		break;
	case PROP_TYPE_TIME:
		nameval->InitTime((int) (long) var);
		break;
	case PROP_TYPE_BOOLEAN:
		nameval->InitBool((bool) var);
		break;
	case PROP_TYPE_ENUM:
		nameval->InitEnum((_bstr_t) var);
		break;
	case PROP_TYPE_DECIMAL:
		if(!dv.SetValue((const wchar_t*) _bstr_t(var)))
			return E_INVALIDARG; //TODO: Probably not good (return Error?)
		nameval->InitDecimal(dv);
		break;
	case PROP_TYPE_OPAQUE:
		//type = ValType::TYPE_OPAQUE;
		//nameval->InitOpaque((_bstr_t) var);
		//break;
		ASSERT(0);
		// FALL THROUGH!
	default:
		// not good
		delete nameval;
		return E_INVALIDARG;
	}

  if (mIterator != mEndIterator)
  {
    ++mIterator;
  }
	mIterator = mpPropSet->GetContents().insert(mIterator, nameval);

	return S_OK;
}


// ----------------------------------------------------------------
// Arguments:     IMTConfigProp *pProp - the property to be inserted
// Return Value:  N/A
// Errors Raised: "Can't query for CMTConfigProp C++ object"
// Description:   Inserts the given property into the set immediately
//                after the current property.
// ----------------------------------------------------------------
STDMETHODIMP CMTConfigPropSet::InsertConfigProp(IMTConfigProp *pProp)
{
	ASSERT(pProp);
	if(!pProp) return E_POINTER;

	CMTConfigProp* Prop;
	HRESULT hr;

	hr = pProp->QueryInterface(IID_NULL,(void**)&Prop);
	if(hr == E_NOINTERFACE) {
		// we are probably in this situation due to some wierd MS threading
		// model issue
		hr = Error("Can't query for CMTConfigProp C++ object");
	}
	else {
		XMLConfigNameVal* nameval = new XMLConfigNameVal;
		XMLConfigNameVal* pNewNameVal = Prop->GetNameVal();

		*nameval = *pNewNameVal;

    if (mIterator != mEndIterator)
    {
      ++mIterator;
    }
		mIterator = mpPropSet->GetContents().insert(mIterator, nameval);
	}

	return hr;
}


// ----------------------------------------------------------------
// Arguments:     BSTR aFilename - the name of the file to write to
// Return Value:  N/A
// Errors Raised: N/A
// Description:   Writes the given property set as XML to the given filename.
// ----------------------------------------------------------------
STDMETHODIMP CMTConfigPropSet::Write(BSTR aFilename)
{
	XMLWriter writer;
	writer.SetPrettyPrint(TRUE);
	mpPropSet->TopLevelOutput(writer, NULL);

	int length;
	const char * data;
	writer.GetData(&data, length);

	_bstr_t filename = aFilename;
	FILE * fp = fopen(filename, "w");
	if (!fp)
	{
		std::string buffer("Unable to open file ");
		buffer += filename;
		return Error(buffer.c_str());
	}

	size_t written = fwrite(data, length, 1, fp);
	if (written != 1)
	{
		std::string buffer("Unable to write to file ");
		buffer += filename;
		return Error(buffer.c_str());
	}
		
	fclose(fp);
	return S_OK;
}


// ----------------------------------------------------------------
// Arguments:     N/A
// Return Value:  N/A
// Errors Raised: N/A
// Description:   recalculates the checksum after a property set is modified.
// ----------------------------------------------------------------
STDMETHODIMP CMTConfigPropSet::ChecksumRefresh()
{
	mpPropSet->ChecksumRefresh(mChecksum);

	return S_OK;
}


// ----------------------------------------------------------------
// Arguments:     BSTR aFilename - the name of the file to write to
// Return Value:  N/A
// Errors Raised: N/A
// Description:   Writes the property set as XML to the given filename, with
//                a checksum at the top of the file.
// ----------------------------------------------------------------
STDMETHODIMP CMTConfigPropSet::WriteWithChecksum(BSTR aFilename)
{
	XMLWriter writer;
	writer.SetPrettyPrint(TRUE);
	mpPropSet->TopLevelOutput(writer, mChecksum.c_str());

	int length;
	const char * data;
	writer.GetData(&data, length);

	_bstr_t filename = aFilename;
	FILE * fp = fopen(filename, "w");
	if (!fp)
	{
		std::string buffer("Unable to open file ");
		buffer += filename;
		return Error(buffer.c_str());
	}

	size_t written = fwrite(data, length, 1, fp);
	if (written != 1)
	{
		std::string buffer("Unable to write to file ");
		buffer += filename;
		return Error(buffer.c_str());
	}
		
	fclose(fp);
	return S_OK;
}


// ----------------------------------------------------------------
// Arguments:     BSTR aHostName - the host name 
//                BSTR aRelativePath - the relative path
//                BSTR aUsername - the username
//                BSTR aPassword - the password associated with
//                                 the username
//                VARIANT_BOOL aSecure - if true will use SSL 
//                VARIANT_BOOL aChecksum - <argument description>
// Return Value:  N/A
// Errors Raised: CORE_ERR_BAD_HTTP_RESPONSE if a bad HTTP response is returned.
// Description:   Writes the given property set as XML to a remote host.
// ----------------------------------------------------------------
STDMETHODIMP CMTConfigPropSet::WriteToHost(BSTR aHostName, BSTR aRelativePath,
										   BSTR aUsername, BSTR aPassword,
										   VARIANT_BOOL aSecure, VARIANT_BOOL aChecksum)
{
	ASSERT(0);
	return E_NOTIMPL;

#if 0
	Win32NetStream netstream;
	if (!netstream.Init())
	{
		const ErrorObject * err = netstream.GetLastError();
		return err->GetCode();
	}

	// compose file part of URL
	std::string url("/admin/nph-uploadconfig.exe?relativepath=");

	_bstr_t relativePath(aRelativePath);
	// TODO: do we have to escape the characters in the path?
	url += relativePath;


	_bstr_t server(aHostName);
	_bstr_t username(aUsername);
	_bstr_t password(aPassword);
	VARIANT_BOOL secureFlag = aSecure;

	// if the secure flag is FALSE, we will try to use the default value in MTConfig
	if (secureFlag == VARIANT_FALSE)
	{
		secureFlag = CMTConfig::mSecureFlag;
		if ((username.length() == 0) || (password.length() == 0) )
		{
			username = CMTConfig::mUsername;
			password = CMTConfig::mPassword;
		}
	}

	MTMemBufferPrettyprint aBuffer;
	StringXMLWriter stringWrite(aBuffer);
	mpPropSet->TopLevelOutput(stringWrite,NULL);

	std::string postData(aBuffer);

	char header[256];
	wsprintfA(header, "Content-Type: x-metratech/xmlconfig\n"
						"Content-Length: %d\n", postData.length());

	// open the connection
 	NetStreamConnection * conn = NULL;
	if (secureFlag == VARIANT_TRUE)
	{
		conn = netstream.OpenSslHttpConnection("POST", server, url.c_str(),
																					 FALSE, username, password, header);
	}
	else
	{
		conn = netstream.OpenHttpConnection("POST", server, url.c_str(),
																				FALSE, username, password, header);
	}

	if (!conn)
	{
		const ErrorObject * err = netstream.GetLastError();
		return HRESULT_FROM_WIN32(err->GetCode());
	}

	if (!conn->SendBytes(postData.c_str(), postData.length()))
	{
		const ErrorObject * err = conn->GetLastError();
		HRESULT code = HRESULT_FROM_WIN32(err->GetCode());
		delete conn;
		return code;
	}

	if (!conn->EndRequest())
	{
		const ErrorObject * err = conn->GetLastError();
		return err->GetCode();
	}

	HttpResponse response = conn->GetResponse();
	if (!response.IsSuccessful())
	{
		delete conn;
		std::string errorBuffer("Bad HTTP response (");
		char buffer[20];
		_itoa((int) response, buffer, 10);
		errorBuffer += buffer;
		errorBuffer += ") returned from host ";
		errorBuffer += server;
		errorBuffer += " path ";
		errorBuffer += url;
		return Error(errorBuffer.c_str(), IID_IMTConfig, CORE_ERR_BAD_HTTP_RESPONSE);
	}

	// read an ignore the response from the server
	char buffer[256];
	int nread = 0;
	do
	{
		if (!conn->ReceiveBytes(buffer, sizeof(buffer), &nread))
		{
			const ErrorObject * err = conn->GetLastError();
			HRESULT code = HRESULT_FROM_WIN32(err->GetCode());
			delete conn;
			return code;
		}
    if (nread < sizeof(buffer))
      break;
	} while (nread > 0);

	delete conn;
#endif

	return S_OK;
}


// ----------------------------------------------------------------
// Arguments:     N/A
// Return Value:  BSTR* apVal - a buffer
// Errors Raised: 
// Description:   write property set as XML to a buffer
// ----------------------------------------------------------------
STDMETHODIMP CMTConfigPropSet::WriteToBuffer(BSTR* apVal)
{
	if (apVal == NULL)
		return E_POINTER;

	XMLWriter stringWrite;
	stringWrite.SetPrettyPrint(TRUE);
	mpPropSet->TopLevelOutput(stringWrite,NULL);

	HRESULT retCode = S_OK;
	try
	{
		// CR 6318: The previous code used to bstr_t class to convert the string.
		// Unfortunately, the implementers of the bstr_t and data_t class 
		// were a little too clever and decided that it would be nice and
		// dandy to allocate memory off the stack (perhaps through some obscure WIN32 call
		// or assembly) instead of the heap.  Of course, this raises an
		// exception if the stack space is too small!! (which is very likely with 
		// large strings)

		USES_CONVERSION;
		// convert the string to a BSTR
		const char * data;
		int length;
		stringWrite.GetData(&data, length);
		*apVal = A2BSTR(data);
	}
	catch (_com_error & err)
	{
		ReturnComError(err);
	}

	return retCode;
}


// ----------------------------------------------------------------
// Arguments:     BSTR aName - the name of the property
// Return Value:  DATE * pDate - the value of the property     
// Errors Raised: "No date found with name"
// Description:   Gets the next property of type date with
//                the given name and returns its value.
// ----------------------------------------------------------------
STDMETHODIMP CMTConfigPropSet::NextDateWithName(BSTR aName, DATE* pDate)
{
	IMTConfigProp * prop;
	HRESULT hr = NextWithName(aName, &prop);
	if (FAILED(hr))
		return hr;

	if (!prop)
	{
		std::wstring errormsg(L"No Date found with name ");
		errormsg += aName;
		return Error(errormsg.c_str());
	}

	PropValType type;
	VARIANT val;
	// try to get the long value
	hr = prop->get_Value(&type, &val);
	_variant_t var(val, false);

	// release the property now whether it was the correct type or not
	prop->Release();

	HRESULT retCode = S_OK;

	if (FAILED(hr))
		retCode = hr;
	else
	{
		if (type != PROP_TYPE_DATETIME)
			retCode = E_INVALIDARG;
		else
		{
			try
			{
        OleDateFromTimet(pDate,(long)var);
				retCode = S_OK;
			}
			catch (_com_error & err)
			{
				retCode = err.Error();
			}
		}
	}
	return retCode;
}


// ----------------------------------------------------------------
// Arguments:     N/A
// Return Value:  BSTR* bName - the name of the propset
// Errors Raised: N/A
// Description:   Gets the name of this propset.
// ----------------------------------------------------------------
STDMETHODIMP CMTConfigPropSet::get_Name(BSTR* bName)
{
	ASSERT(bName);
	if(!bName) return E_POINTER;
	ASSERT(mpPropSet);

	_bstr_t bstrName = mpPropSet->GetName();
	*bName = bstrName.copy();
	return S_OK;
}


// ----------------------------------------------------------------
// Arguments:     N/A
// Return Value:  IMTConfigAttribSet** ppSet - set of XML attributes
// Errors Raised: N/A
// Description:   Gets the XML attributes for this property set.
// ----------------------------------------------------------------
STDMETHODIMP CMTConfigPropSet::get_AttribSet(IMTConfigAttribSet** ppSet)
{
	ASSERT(ppSet);
	if(!ppSet) return E_POINTER;
	HRESULT hr = S_OK;

	ASSERT(mpPropSet);
	XMLNameValueMap aMap = mpPropSet->GetMap();
	*ppSet = NULL;

	if(aMap.GetObject() != NULL) {
		CComObject<CMTConfigAttribSet> * pAttribSet;
		CComObject<CMTConfigAttribSet>::CreateInstance(&pAttribSet);
		if (!pAttribSet)
			return E_OUTOFMEMORY;

		// have to AddRef or the count will be 0
		HRESULT hr =
			pAttribSet->QueryInterface(IID_IMTConfigAttribSet,
													 reinterpret_cast<void**>(ppSet));
		if(SUCCEEDED(hr)) {
			pAttribSet->SetMap(aMap);
		}
	}
	
	return hr;
}


// ----------------------------------------------------------------
// Arguments:     IMTConfigAttribSet* pSet - set of XML attributes
// Return Value:  N/A
// Errors Raised: N/A
// Description:   sets the XML attributes of this tag.
// ----------------------------------------------------------------
STDMETHODIMP CMTConfigPropSet::put_AttribSet(IMTConfigAttribSet* pSet)
{
	if(pSet) {
		CComObject<CMTConfigAttribSet> *pAttribSet = (CComObject<CMTConfigAttribSet>*)pSet;
		mpPropSet->PutMap(pAttribSet->GetMap());
	}
	return S_OK;
}


// ----------------------------------------------------------------
// Arguments:     N/A
// Return Value:  BSTR *pVal - the DTD of the XML document, if it exists
// Errors Raised: N/A
// Description:   Gets the DTD of the XML document, if it exists
// ----------------------------------------------------------------
STDMETHODIMP CMTConfigPropSet::get_DTD(BSTR *pVal)
{
	AutoDTD aDTD = mpPropSet->GetEntity();

	if(aDTD) {
		_bstr_t aTempStr = aDTD->GetLocation().c_str();
		*pVal = aTempStr.copy();
	}
	else {
		*pVal = NULL;
	}
	return S_OK;
}


// ----------------------------------------------------------------
// Arguments:     BSTR newVal - the new DTD of the XML document
// Return Value:  N/A
// Errors Raised: N/A
// Description:   Sets the DTD of the XML document
// ----------------------------------------------------------------
STDMETHODIMP CMTConfigPropSet::put_DTD(BSTR newVal)
{
	ASSERT(newVal);
	if(!newVal) return E_POINTER;

	AutoDTD aDTD = mpPropSet->GetEntity();

	_bstr_t aTemp = newVal;
	if(aDTD) {
		aDTD->PutLocation((const char*)aTemp);
	}
	else {
		aDTD = new XMLEntity((const wchar_t*)aTemp);
		aDTD->PutSetName(mpPropSet->GetName());
		mpPropSet->PutEntity(aDTD);
	}
	return S_OK;
}


// ----------------------------------------------------------------
// Arguments:     N/A
// Return Value:  BSTR* pChecksum - the checksum
// Errors Raised: N/A
// Description:   Gets the checksum of the property set
// ----------------------------------------------------------------
STDMETHODIMP CMTConfigPropSet::get_Checksum(BSTR* pChecksum)
{
	_bstr_t aChecksum = mChecksum.c_str();
	*pChecksum = aChecksum.copy();
	return S_OK;
}

