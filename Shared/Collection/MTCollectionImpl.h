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

#pragma once

#include <vector>
#include <algorithm>
#include <metra.h>
#include <comutil.h>
#include <mtcomerr.h>

#pragma warning (disable : 4530)


namespace Coll
{
	// We always need to provide the following information
	typedef std::vector<CComVariant>						ContainerType;
	typedef VARIANT															ExposedType;
	typedef IEnumVARIANT												EnumeratorInterface;

	//typedef VCUE::GenericCopy<ExposedType, ContainerType::value_type>		CopyType;
	typedef _Copy<VARIANT>		CopyType;

	// Now we have all the information we need to fill in the template arguments on the implementation classes
	typedef CComEnumOnSTL< EnumeratorInterface, &__uuidof(EnumeratorInterface), ExposedType,
							CopyType, ContainerType > EnumeratorType;

};

using namespace Coll;
#import <GenericCollection.tlb>

/////////////////////////////////////////////////////////////////////////////
// class definitions
/////////////////////////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////////////////////
// MTSortOperation
class MTSortOperation 
{
public:
	bool operator()(const CComVariant& pObj1, const CComVariant& pObj2) 
		{	
			HRESULT hr = S_OK;

			GENERICCOLLECTIONLib::IMTSortPropertyPtr sortobjPtr = pObj1.punkVal;
			GENERICCOLLECTIONLib::IMTSortPropertyPtr sortobj2Ptr = pObj2.punkVal;
	
			return sortobjPtr->Compare(sortobj2Ptr) == VARIANT_TRUE ? true : false;
		}
};

//
// Generic Read-Only collecton class
// 

template<class T,const IID* piid, const GUID* plibid>
class MTCollectionReadOnlyImpl : public IDispatchImpl<
ICollectionOnSTLImpl< T, ContainerType, ExposedType,
							CopyType, EnumeratorType > ,piid,plibid>
{
public:
	STDMETHOD(Sort)();

protected:

	// this function is necessary to convert any 
	// values that are passed by ref from VBScript (the mother of all evil)
	// Unfortunately, the WIN32 API call CopyVariant does not call
	// addref if the value is passed by ref.  We must call 
	// addref in this case.
	VARIANT ConvertVariant(VARIANT aItem)
	{
		_variant_t vtTemp;

		if(aItem.vt == (VT_DISPATCH | VT_BYREF) 
			|| aItem.vt == (VT_UNKNOWN | VT_BYREF)
			|| aItem.vt == (VT_VARIANT | VT_BYREF)
			) {
				vtTemp = aItem.pvarVal;
        if(aItem.vt == (VT_DISPATCH | VT_BYREF)) {
			    try {
				    IUnknownPtr pUnk = vtTemp;
				    pUnk->AddRef();
			    }
			    catch(_com_error&) {
				    // well, shit!  Probably not a big issue... some yokel
				    // is trying to pass something by ref which we can't convert
				    // to an IUnknown pointer.  bizarre!
			    }
        }
		  return vtTemp;
		}
		return aItem;
	}

	virtual void InternalAdd(VARIANT aItem) 
	{ 	
		//CComVariant collection enforces storing a copy 
		m_coll.push_back(ConvertVariant(aItem));
	}
	virtual void InternalInsert(VARIANT aItem, long aIndex)
	{
		//CComVariant collection enforces storing a copy 
		m_coll.insert (m_coll.begin() + aIndex - 1, ConvertVariant(aItem));
	}
};

//
// generic collection class
// 

template<class T,const IID* piid, const GUID* plibid>
class MTCollectionImpl : public MTCollectionReadOnlyImpl<T,piid,plibid>
{
public:

	MTCollectionImpl() {}
	virtual ~MTCollectionImpl() {}

	STDMETHOD(Add)(VARIANT aItem);
	STDMETHOD(Insert)(VARIANT Item, long aIndex);
	STDMETHOD(Remove)(long aIndex);

};

template<class T,const IID* piid, const GUID* plibid>
class MTCollectionImplEx : public MTCollectionImpl<T,piid,plibid>
{
public:
	MTCollectionImplEx() {}
	virtual ~MTCollectionImplEx() {}

	STDMETHOD(get_Exists)(VARIANT vtKey,VARIANT_BOOL* pBool);
	STDMETHOD(Clear)();
	STDMETHOD(ToString)(BSTR* pStr);

};

/////////////////////////////////////////////////////////////////////////////
// MTCollectionReadOnlyImpl method implementations
/////////////////////////////////////////////////////////////////////////////

template<class T,const IID* piid, const GUID* plibid>
STDMETHODIMP MTCollectionReadOnlyImpl<T,piid,plibid>::Sort()
{ 
	ContainerType::iterator it = m_coll.begin();
	if(it != m_coll.end())
	{
		CComVariant cvar = *it;
		GENERICCOLLECTIONLib::IMTSortPropertyPtr sortobjPtr = cvar.punkVal; 
		if (sortobjPtr != NULL)
		{
			std::sort(m_coll.begin(),m_coll.end(),MTSortOperation());
			return S_OK;
		}
		else
		{
			// The collection is empty, or the object does not implement the IMTSortProperty interface
			return E_FAIL;
		}
	}
	else
	{
		return E_FAIL;
	}
}


/////////////////////////////////////////////////////////////////////////////
// MTCollectionImpl method implementations
/////////////////////////////////////////////////////////////////////////////


template<class T,const IID* piid, const GUID* plibid>
STDMETHODIMP MTCollectionImpl<T,piid,plibid>::Add(VARIANT aItem)
{
	InternalAdd(aItem);
	return S_OK;
}

template<class T,const IID* piid, const GUID* plibid>
STDMETHODIMP MTCollectionImpl<T,piid,plibid>::Insert(VARIANT aItem, long aIndex)
{
	InternalInsert(aItem,aIndex);
	return S_OK;
}

template<class T,const IID* piid, const GUID* plibid>
STDMETHODIMP MTCollectionImpl<T,piid,plibid>::Remove(long aIndex)
{
	// index is 1 based!
	
	if (aIndex < 1 || aIndex > (long) m_coll.size())
		return E_INVALIDARG;

	m_coll.erase (m_coll.begin() + aIndex - 1);
	return S_OK;
}

/////////////////////////////////////////////////////////////////////////////
// MTCollectionImpl method implementations
/////////////////////////////////////////////////////////////////////////////


template<class T,const IID* piid, const GUID* plibid>
STDMETHODIMP MTCollectionImplEx<T,piid,plibid>::get_Exists(VARIANT vtKey,VARIANT_BOOL* pBool)
{
	VARIANT vtVal;
	HRESULT hr = MTCollectionImpl<T,piid,plibid>::get_Item(_variant_t(vtKey),&vtVal);
	if(SUCCEEDED(hr)) {
		// free the variant
		_variant_t vtCleanup(vtVal,false);
	}
	return hr;
}

template<class T,const IID* piid, const GUID* plibid>
STDMETHODIMP MTCollectionImplEx<T,piid,plibid>::Clear()
{
	// XXX should we lock the collection?
	m_coll.erase(m_coll.begin(),m_coll.end());
	return S_OK;
}

template<class T,const IID* piid, const GUID* plibid>
STDMETHODIMP MTCollectionImplEx<T,piid,plibid>::ToString(BSTR* pStr)
{
  _bstr_t retvalStr;
  try {
	  long count;
    get_Count(&count);

	  for(long i=1;i<=count;i++) {
      // convert the variant to a string.  Does this work for all types?
      VARIANT value;
      ::VariantInit(&value);
      HRESULT hr = get_Item(i,&value);
      if(SUCCEEDED(hr)) {
        _bstr_t val = _variant_t(value,false);
        retvalStr += val;
		    if(i != count) {
			    retvalStr += ",";
		    }
      }
	  }
  }
  catch(_com_error& err) {
    return ReturnComError(err);
  }
  *pStr = retvalStr.copy();
  return S_OK;
}
