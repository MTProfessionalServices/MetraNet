// MTSearchResultCollection.cpp : Implementation of CMTSearchResultCollection
#include "StdAfx.h"
#include "MTAccount.h"
#include "MTSearchResultCollection.h"

/////////////////////////////////////////////////////////////////////////////
// CMTSearchResultCollection


STDMETHODIMP CMTSearchResultCollection::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTSearchResultCollection
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}


STDMETHODIMP CMTSearchResultCollection::Add(IMTAccountPropertyCollection *pAccPropColl)
{
	m_coll.push_back(CAdapt<CComPtr<IMTAccountPropertyCollection> >(pAccPropColl));
	
	return S_OK;
}

STDMETHODIMP CMTSearchResultCollection::Count(long* apSize)
{
	(*apSize) = m_coll.size();
	
	return S_OK;
}

STDMETHODIMP CMTSearchResultCollection::Clear()
{
	m_coll.clear();
	return S_OK;
}

STDMETHODIMP CMTSearchResultCollection::Append(IMTSearchResultCollection *apSRC)
{
	HRESULT hr(S_OK);
	if(!apSRC) return E_POINTER;
	MTACCOUNTLib::IMTSearchResultCollectionPtr ptr = apSRC;
	SetIterator<MTACCOUNTLib::IMTSearchResultCollectionPtr, MTACCOUNTLib::IMTAccountPropertyCollectionPtr> it;
	hr = it.Init(ptr);
	ASSERT(SUCCEEDED(hr));

	while(true)
	{
		MTACCOUNTLib::IMTAccountPropertyCollectionPtr APCPtr = it.GetNext();
		if(APCPtr == NULL) break;
		m_coll.push_back(CAdapt<CComPtr<IMTAccountPropertyCollection> >((IMTAccountPropertyCollection*)APCPtr.GetInterfacePtr()));
	}
	return S_OK;
}


