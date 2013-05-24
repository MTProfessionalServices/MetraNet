/**************************************************************************
 * @doc MTOBJECTCOLLECTION
 *
 * @module |
 *
 *
 * Copyright 2001 by MetraTech Corporation
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
 * Created by: Derek Young
 *
 * $Date$
 * $Author$
 * $Revision$
 *
 * @index | MTOBJECTCOLLECTION
 ***************************************************************************/

#ifndef _MTOBJECTCOLLECTION_H
#define _MTOBJECTCOLLECTION_H

#include <Atlbase.h>
#include <algorithm>
#include <autocritical.h>

struct IMTCollection;

template<class T>
class MTObjectCollection
{
public:
	MTObjectCollection<T>()
	{ }

	HRESULT Add(T * element);
	HRESULT Insert(T * element, long aIndex);
	HRESULT Remove(long aIndex);
	HRESULT Item(long index, T** var);
	HRESULT Count(long * count);
	HRESULT Sort();
	IMTCollection* Detach()
	{
		return mCollection.Detach();
	}

	HRESULT CopyTo(IMTCollection * * apCollection);
	MTObjectCollection<T> & operator = (IMTCollection* arIPtr);
	
	IMTCollection** operator&()
	{
		Create();
		return &mCollection.p;
	}
	
	void Clear()
	{ mCollection = NULL; }

	// don't copy the thread lock in copy constructor
	// or operator =
	MTObjectCollection<T>(MTObjectCollection<T> &coll)
		:
		mCollection(coll.mCollection)
	{ 
	}

  MTObjectCollection<T> & operator = (const MTObjectCollection<T>& coll)
	{
		mCollection = coll.mCollection;
		return *this;
	}

private:
	HRESULT Create();
	HRESULT Create(IMTCollection* aPtr);
	CComPtr<IMTCollection> mCollection;
	NTThreadLock mLock;

};

template<class T>
MTObjectCollection<T> & MTObjectCollection<T>::operator = (IMTCollection* arIPtr)
{
	AutoCriticalSection lock(&mLock);
	Create(arIPtr);
	return *this;
}

/*
template<class T>
IMTCollection** MTObjectCollection<T>::operator &()
{
	Create();
	return &mCollection;
}
*/
template<class T>
HRESULT MTObjectCollection<T>::Add(T * element)
{
	AutoCriticalSection lock(&mLock);
	HRESULT hr = Create();
	if (FAILED(hr))
		return hr;

//	CComPtr<T> obj(element);

	IDispatch * disp = NULL;
	hr = element->QueryInterface(IID_IDispatch, (void**) &disp);


//	hr = obj.QueryInterface(&disp);
	if (FAILED(hr))
		return hr;

	// attach to the pointer
	CComVariant var(disp);
	disp->Release();

	return mCollection->Add(var);
}

template<class T>
HRESULT MTObjectCollection<T>::Insert(T * element, long aIndex)
{
	AutoCriticalSection lock(&mLock);
	HRESULT hr = Create();
	if (FAILED(hr))
		return hr;

//	CComPtr<T> obj(element);

	IDispatch * disp = NULL;
	hr = element->QueryInterface(IID_IDispatch, (void**) &disp);


//	hr = obj.QueryInterface(&disp);
	if (FAILED(hr))
		return hr;

	// attach to the pointer
	CComVariant var(disp);
	disp->Release();

	return mCollection->Insert(var, aIndex);
}

template<class T>
HRESULT MTObjectCollection<T>::Remove(long aIndex)
{
	AutoCriticalSection lock(&mLock);
	HRESULT hr = Create();
	if (FAILED(hr))
		return hr;

	return mCollection->Remove(aIndex);
}

template<class T>
HRESULT MTObjectCollection<T>::Item(long index, T ** element)
{
	AutoCriticalSection lock(&mLock);
	_variant_t var;
	CComPtr<T> ptr;

	HRESULT hr = Create();
	if (FAILED(hr))
		return hr;

	hr = mCollection->get_Item(index, &var);
	if (FAILED(hr))
		return hr;

	hr = var.pdispVal->QueryInterface(__uuidof(T), (void**) &ptr);
	if (FAILED(hr))
		return hr;

	(*element) = ptr.Detach();
	return hr;
}

template<class T>
HRESULT MTObjectCollection<T>::Count(long * count)
{
	AutoCriticalSection lock(&mLock);
	HRESULT hr = Create();
	if (FAILED(hr))
		return hr;

	return mCollection->get_Count(count);
}

template<class T>
HRESULT MTObjectCollection<T>::CopyTo(IMTCollection * * apCollection)
{
	AutoCriticalSection lock(&mLock);
	if (!apCollection)
		return E_POINTER;

	HRESULT hr = Create();
	if (FAILED(hr))
		return hr;

	return mCollection.CopyTo(apCollection);
}

template<class T>
HRESULT MTObjectCollection<T>::Create()
{
	if (mCollection == NULL)
		return mCollection.CoCreateInstance(L"Metratech.MTCollection.1");
	return S_OK;
}

template<class T>
HRESULT MTObjectCollection<T>::Create(IMTCollection* arIPtr)
{
	Create();
	mCollection = arIPtr;
	return S_OK;
}

template<class T>
HRESULT MTObjectCollection<T>::Sort()
{
	AutoCriticalSection lock(&mLock);
	HRESULT hr = Create();
	if (FAILED(hr))
		return hr;
	
	mCollection->Sort();
	return S_OK;
}

#endif /* _MTOBJECTCOLLECTION_H */




