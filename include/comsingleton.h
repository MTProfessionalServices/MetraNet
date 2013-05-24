/**************************************************************************
 * @doc COMSINGLETON
 *
 * @module |
 *
 *
 * Copyright 1998 by MetraTech Corporation
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
 * $Header$
 *
 * @index | COMSINGLETON
 ***************************************************************************/

#ifndef _COMSINGLETON_H
#define _COMSINGLETON_H

template <class Base> class CMTSingleObject;

template <class T>
class CMTSingletonFactory : public CComClassFactory
{
public:
	CMTSingletonFactory() : mpObj(NULL)
	{ }

	~CMTSingletonFactory()
	{
		// the object must have been deleted before the
		// class factory!  otherwise it's possible there
		// will be dangling pointers to other DLLs that
		// are unloading
		// ASSERT(mpObj == NULL);
	}

	// IClassFactory
	STDMETHOD(CreateInstance)(LPUNKNOWN pUnkOuter, REFIID riid, void** ppvObj);

	void DeleteObject()
	{
		// delete the object and zero the pointer
		// in one atomic step
		ASSERT_VALID_HEAP_POINTER(this);
		delete mpObj;
		mpObj = NULL;
		mObjectLock.Unlock();
	}

	void Lock() { mObjectLock.Lock(); }
	void Unlock() { mObjectLock.Unlock(); }

	CComAutoCriticalSection mObjectLock;
	CMTSingleObject<T> * mpObj;
};


template <class T>
STDMETHODIMP CMTSingletonFactory<T>::CreateInstance(LPUNKNOWN pUnkOuter,
																										REFIID riid, void** ppvObj)
{
	HRESULT hRes = E_POINTER;
	if (ppvObj != NULL)
	{
		// can't ask for anything other than IUnknown when aggregating
		_ASSERTE((pUnkOuter == NULL) || InlineIsEqualUnknown(riid));
		if ((pUnkOuter != NULL) && !InlineIsEqualUnknown(riid))
			hRes = CLASS_E_NOAGGREGATION;
		else
		{
			mObjectLock.Lock();
			
			HRESULT hr = S_OK;
			if (mpObj == NULL)
			{
				// create interface
				hr = CMTSingleObject<T>::CreateInstance(*this, &mpObj);
			}
			if(SUCCEEDED(hr)) {
				hRes = mpObj->QueryInterface(riid, ppvObj);
			}
			mObjectLock.Unlock();
			
		}
	}
	return hRes;
}


template <class Base>
class CMTSingleObject : public CComObject<Base>
{
private:
//	CMTSingleObject(void * = NULL) : CComObject<Base>(NULL)
//	{ }
public:
	CMTSingleObject(CMTSingletonFactory<Base> & arFactory) : CComObject<Base>(NULL)
	{
		mpFactory = &arFactory;
	}

	~CMTSingleObject()
	{
		// TODO: ATL version calls FinalRelease here, but this
		// causes a bug.  Do we need to do the same in this case?
	}

	static HRESULT WINAPI CreateInstance(CMTSingletonFactory<Base> & arFactory,
																			 CMTSingleObject<Base>** pp);

	//If InternalAddRef or InteralRelease is undefined then your class
	//doesn't derive from CComObjectRoot
	STDMETHOD_(ULONG, AddRef)();
	STDMETHOD_(ULONG, Release)();
	CMTSingletonFactory<Base> * mpFactory;
};

template <class Base>
HRESULT WINAPI
CMTSingleObject<Base>::CreateInstance(CMTSingletonFactory<Base> & arFactory,
																			CMTSingleObject<Base>** pp)
{
	_ASSERTE(pp != NULL);
	HRESULT hRes = E_OUTOFMEMORY;
	CMTSingleObject<Base>* p = NULL;
	ATLTRY(p = new CMTSingleObject<Base>(arFactory))
		if (p != NULL)
		{
			p->SetVoid(NULL);
			p->InternalFinalConstructAddRef();
			hRes = p->FinalConstruct();
			p->InternalFinalConstructRelease();
			if (hRes != S_OK)
			{
				delete p;
				p = NULL;
			}
		}
	*pp = p;
	return hRes;
}


template <class Base>
STDMETHODIMP_(ULONG)
CMTSingleObject<Base>::AddRef()
{
	ULONG l = CComObject<Base>::AddRef();
	return l;
}

	//If InternalAddRef or InteralRelease is undefined then your class
	//doesn't derive from CComObjectRoot
	//STDMETHOD_(ULONG, AddRef)() {return InternalAddRef();}

template <class Base>
STDMETHODIMP_(ULONG) CMTSingleObject<Base>::Release()
{
	ASSERT_VALID_HEAP_POINTER(this);
	mpFactory->Lock();
	ULONG l = InternalRelease();
	if (l == 0) {
		mpFactory->DeleteObject();
	}
	else {
	mpFactory->Unlock();
	}

	return l;
}


#endif /* _COMSINGLETON_H */
