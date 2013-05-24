/**************************************************************************
 * @doc CLASSOBJECT
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
 * Created by: 
 *
 * $Date$
 * $Author$
 * $Revision$
 *
 * @index | CLASSOBJECT
 ***************************************************************************/

#ifndef _CLASSOBJECT_H
#define _CLASSOBJECT_H

#include <mtcomerr.h>

template<class T>
class ClassObject
{
public:
	HRESULT Init(const wchar_t * apProgID);

	T CreateInstance();

private:
	IClassFactoryPtr mFactory;
};


template<class T>
HRESULT ClassObject<T>::Init(const wchar_t * apProgID)
{
	CLSID clsid;
	HRESULT hr = CLSIDFromProgID(apProgID, &clsid);
	if (FAILED(hr))
		return hr;

	IClassFactory * factory = NULL;
	hr = ::CoGetClassObject(clsid,
													CLSCTX_ALL,	// context for running executable code
													NULL,	// pointer to machine on which the object is
																// to be instantiated
													IID_IClassFactory,
													(void **) &factory);
	if (FAILED(hr))
		return hr;

	ASSERT(factory);
	mFactory = factory;
	factory->Release();
	factory = NULL;

	return S_OK;
}

template<class T>
T ClassObject<T>::CreateInstance()
{
	T newinterface;
	HRESULT hr = mFactory->CreateInstance(NULL,	// controlling IUnknown
																				__uuidof(T),
																				(void **) &newinterface);

	// TODO: is this the write IID to pass in?
	if (FAILED(hr))
		MT_THROW_COM_ERROR(__uuidof(T), hr);

	return newinterface;
}																				


#endif /* _CLASSOBJECT_H */
