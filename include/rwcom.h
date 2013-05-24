/**************************************************************************
 * @doc RWCOM
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
 * Created by: Derek Young
 *
 * $Date$
 * $Author$
 * $Revision$
 *
 * @index | RWCOM
 ***************************************************************************/

#ifndef _RWCOM_H
#define _RWCOM_H

//
// enumeration over RogueWave like collections.
// similar in usage to CComEnumOnSTL from ATL.
//

/********************************************* IEnumOnRWImpl ***/

//
// The guts of CComEnum.  A C++ object to manage a roguewave collection
// and provide IEnumXXXX like semantics.
//
template <class Base, const IID* piid, class T, class Copy,
	class CollType, class IterType>
class ATL_NO_VTABLE IEnumOnRWImpl : public Base
{
public:
	IEnumOnRWImpl() : mpIter(NULL)
	{ }

	// delete the iterator when we're finished
	virtual ~IEnumOnRWImpl()
	{
		delete mpIter;
		mpIter = NULL;
	}

	// initialize 
	HRESULT Init(IUnknown * apOwner, CollType & arCollection)
	{
		mpOwner = apOwner;
		mpCollection = &arCollection;
		mpIter = new IterType(*mpCollection);
		return S_OK;
	}

	// retrieve more elements
	STDMETHOD(Next)(ULONG celt, T* rgelt, ULONG* pceltFetched);

	// skip some elements
	STDMETHOD(Skip)(ULONG celt);

	// reset to the first element
	STDMETHOD(Reset)(void)
	{
		if (mpCollection == NULL)
			return E_FAIL;
		mpIter->reset();
		return S_OK;
	}
	STDMETHOD(Clone)(Base** ppEnum);

public:
	// the owner of the container.  maintain a reference so the owner
	// doesn't disappear before we do
	CComPtr<IUnknown> mpOwner;

	// the collection
	CollType* mpCollection;

	// the iterator
	IterType* mpIter;
};

template <class Base, const IID* piid, class T, class Copy,
	class CollType, class IterType>
STDMETHODIMP IEnumOnRWImpl<Base, piid, T, Copy,
	CollType, IterType>::Next(ULONG celt, T* rgelt, ULONG* pceltFetched)
{
	if (rgelt == NULL || (celt != 1 && pceltFetched == NULL))
		return E_POINTER;
	if (mpCollection == NULL)
		return E_FAIL;

	// iterate through the desired number of elements
	ULONG nActual = 0;
	HRESULT hr = S_OK;
	T* pelt = rgelt;
	while (SUCCEEDED(hr) && nActual < celt && (*mpIter)())
	{
		// copy them.  See VARIANTCopyUtils for an implementation of the class
		// TODO: does ::init have to be called before the copy?
		hr = Copy::copy(pelt, mpIter->key());
		if (FAILED(hr))
		{
			while (rgelt < pelt)
				Copy::destroy(rgelt++);
			nActual = 0;
		}
		else
		{
			pelt++;
			nActual++;
		}
	}
	if (pceltFetched)
		*pceltFetched = nActual;

	// S_FALSE is returned if it succeeded but there are no more elements
	if (SUCCEEDED(hr) && (nActual < celt))
		hr = S_FALSE;
	return hr;
}

template <class Base, const IID* piid, class T, class Copy,
	class CollType, class IterType>
STDMETHODIMP IEnumOnRWImpl<Base, piid, T, Copy,
	CollType, IterType>::Skip(ULONG celt)
{
	HRESULT hr = S_OK;
	// iterate past the desired number of elements
	while (celt--)
	{
		if ((*mpIter)() == NULL)
		{
			hr = S_FALSE;
			break;
		}
	}
	return hr;
}

template <class Base, const IID* piid, class T, class Copy,
	class CollType, class IterType>
STDMETHODIMP IEnumOnRWImpl<Base, piid, T, Copy,
	CollType, IterType>::Clone(Base** ppEnum)
{
	typedef CComObject<CComEnumOnRW<Base, piid, T, Copy, CollType, IterType> > _class;
	HRESULT hRes = E_POINTER;
	if (ppEnum != NULL)
	{
		// create another object of the same type
		*ppEnum = NULL;
		_class* p;
		hRes = _class::CreateInstance(&p);
		if (SUCCEEDED(hRes))
		{
			hRes = p->Init(mpOwner, *mpCollection);
			if (SUCCEEDED(hRes))
			{
				p->mpIter = mpIter;
				hRes = p->_InternalQueryInterface(*piid, (void**)ppEnum);
			}
			if (FAILED(hRes))
				delete p;
		}
	}
	return hRes;
}

/********************************************** CComEnumOnRW ***/

//
// COM interface for iterating over a rogue wave collection
//
template <class Base, const IID* piid, class T, class Copy,
	class CollType, class IterType, class ThreadModel = CComObjectThreadModel>
class ATL_NO_VTABLE CComEnumOnRW :
	public IEnumOnRWImpl<Base, piid, T, Copy, CollType, IterType>,
	public CComObjectRootEx< ThreadModel >
{
public:
	typedef CComEnumOnRW<Base, piid, T, Copy, CollType, IterType, ThreadModel > _CComEnum;
	typedef IEnumOnRWImpl<Base, piid, T, Copy, CollType, IterType > _CComEnumBase;
	BEGIN_COM_MAP(_CComEnum)
		COM_INTERFACE_ENTRY_IID(*piid, _CComEnumBase)
	END_COM_MAP()
};

/******************************************** GetNewEnumOnRW ***/

//
// helper function for use in GetNewEnum
//
template<class COMType, class CPPType, class IterType, class CollType >
HRESULT GetNewEnumOnRW(IUnknown * apOwner, CollType & arCollection, IUnknown ** apUnk)
{
	if (!apUnk)
		return E_POINTER;

	*apUnk = NULL;
	typedef CComEnumOnRW<IEnumVARIANT, &IID_IEnumVARIANT, VARIANT,
		VARIANTCopyUtils<COMType, CPPType>,
		CollType, IterType > EnumType;

	// create the enumerator type
	CComObject<EnumType> * enumObj;
	HRESULT hr = CComObject<EnumType>::CreateInstance(&enumObj);
	if (SUCCEEDED(hr))
	{
		// initialize the enumerator
		hr = enumObj->Init(apOwner, arCollection);

		// pass back an IUnknown
		if (hr == S_OK)
			hr = enumObj->QueryInterface(IID_IUnknown, (void**) apUnk);
	}
	if (FAILED(hr))
		delete enumObj;

	return hr;
}

template<class COMType, class CPPType, class CollType >
HRESULT GetNewEnumOnSTL(IUnknown * apOwner, CollType & arCollection, IUnknown ** apUnk)
{
	if (!apUnk)
		return E_POINTER;

	*apUnk = NULL;
	typedef CComEnumOnSTL<IEnumVARIANT, &IID_IEnumVARIANT, VARIANT,
		VARIANTCopyUtils<COMType, CPPType>,
		CollType> EnumType;

	// create the enumerator type
	CComObject<EnumType> * enumObj;
	HRESULT hr = CComObject<EnumType>::CreateInstance(&enumObj);
	if (SUCCEEDED(hr))
	{
		// initialize the enumerator
		hr = enumObj->Init(apOwner, arCollection);

		// pass back an IUnknown
		if (hr == S_OK)
			hr = enumObj->QueryInterface(IID_IUnknown, (void**) apUnk);
	}
	if (FAILED(hr))
		delete enumObj;

	return hr;
}


/*********************************************** GetItemOnRW ***/
// allows the user to specify a CopyClass used by CComEnumOnRW

/***************************************************************/

template<class IterType, class CollType, class CopyClass >
HRESULT GetNewEnumWithCopyClassOnRW(IUnknown * apOwner, CollType & arCollection, IUnknown ** apUnk)
{
	if (!apUnk)
		return E_POINTER;

	*apUnk = NULL;
	typedef CComEnumOnRW<IEnumVARIANT, &IID_IEnumVARIANT, VARIANT,
		CopyClass,
		CollType, IterType > EnumType;

	// create the enumerator type
	CComObject<EnumType> * enumObj;
	HRESULT hr = CComObject<EnumType>::CreateInstance(&enumObj);
	if (SUCCEEDED(hr))
	{
		// initialize the enumerator
		hr = enumObj->Init(apOwner, arCollection);

		// pass back an IUnknown
		if (hr == S_OK)
			hr = enumObj->QueryInterface(IID_IUnknown, (void**) apUnk);
	}
	if (FAILED(hr))
		delete enumObj;

	return hr;
}


/********************************************** GetCountOnRW ***/

template<class CollType>
HRESULT GetCountOnSTL(CollType & arCollection, long * apVal)
{
	if (apVal == NULL)
		return E_POINTER;

	*apVal = arCollection.size();
	return S_OK;
}

/*********************************************** GetItemOnRW ***/

//
// helper function for use in get_Item
//
template<class COMType, class CPPType, class CollType>
HRESULT GetItemOnSTL(CollType & arCollection, long aIndex, VARIANT * apVar)
{
	if (apVar == NULL)
		return E_POINTER;

	// NOTE: Index is 1-based!
	aIndex--;

	if (aIndex >= (long) arCollection.size())
		return E_FAIL;

	CPPType * cppObj = arCollection[aIndex];
	return VARIANTCopyUtils<COMType, CPPType>::copy(apVar, &cppObj);
}

template<class COMType, class CPPType>
HRESULT ObjectFromItem(CPPType * aCPPObj, VARIANT * apVar)
{
	if (apVar == NULL)
		return E_POINTER;

	return VARIANTCopyUtils<COMType, CPPType>::copy(apVar, aCPPObj);
}


/****************************************** VARIANTCopyUtils ***/

//
// Copy template class.
// Used by IEnumOnRWImpl to perform the conversion from the C++ type to a VARIANT
//
// This class calls Initialize, a global you have to define.  The prototype
// will be HRESULT Initialize(CComObject<COMType> * apObj, CPPType * apCPPObj);
//

template<class COMType, class CPPType>
class VARIANTCopyUtils
{
public:
	// create a variant from the C++ type
	static HRESULT copy(VARIANT * apVariant, const CPPType * const * apPropVal)
	{
		CComObject<COMType> * comObj;
		return VARIANTInit(apVariant, &comObj, *apPropVal);
	}

	// initialize the variant
	static void init(VARIANT * p)
	{ ::VariantInit(p); }

	// destroy the variant
	static void destroy(VARIANT * p)
	{ ::VariantClear(p); }

private:

	static HRESULT VARIANTInit(VARIANT * apVar, CComObject<COMType> * * apCOMObj,
														 const CPPType * apCPPObj)
	{
		if (!apCOMObj)
			return E_POINTER;

		// create the COM object
		HRESULT hr = CComObject<COMType>::CreateInstance(apCOMObj);
		if (FAILED(hr))
			return hr;

		//
		// call the custom Initialize function
		// This must be defined for your type 
		//
		hr = Initialize(*apCOMObj, const_cast<CPPType*>(apCPPObj));
		if (FAILED(hr))
		{
			delete *apCOMObj;
			return hr;
		}

		// copy in the object as an IDispatch
		IDispatch * idisp = NULL;
		hr = (*apCOMObj)->QueryInterface(IID_IDispatch,
																	reinterpret_cast<void**>(&idisp));
		if (FAILED(hr))
		{
			delete *apCOMObj;
			return hr;
		}

		// copy the variant
		_variant_t var(idisp);
		*apVar = var;
		return S_OK;
	}
};

/***************************************** CComContainerCopy ***/

//
// COM object to hold the container for the duration of the iterator
// This just adds an IUnknown to the container so that it can be "owned"
// by the IEnumOnRWImpl class.
//

template <class CollType, class ThreadingModel = CComObjectThreadModel>
class CComContainerCopy : public CComObjectRootEx<ThreadingModel>,
													public IUnknown	// only needs to be derived from IUnknown
{
public:
	// optionally copy another container in
	void Copy(const CollType & arColl)
	{
		mColl = arColl;
	}

// we implement IUnknown
BEGIN_COM_MAP(CComContainerCopy)
	COM_INTERFACE_ENTRY(IUnknown)
END_COM_MAP()

	CollType & GetContainer()
	{ return mColl; }

	// container
	CollType mColl;
};



#endif /* _RWCOM_H */
