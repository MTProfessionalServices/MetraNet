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
* $Header$
* 
***************************************************************************/

#ifndef __STLENUM_H__
#define __STLENUM_H__

// template class from MSDN used to create an STL enumerator

template <class EnumType, class CollType>
HRESULT CreateSTLEnumerator(IUnknown** ppUnk, IUnknown* pUnkForRelease, CollType& collection)
{
    if (ppUnk == NULL)
        return E_POINTER;
    *ppUnk = NULL;

    CComObject<EnumType>* pEnum = NULL;
    HRESULT hr = CComObject<EnumType>::CreateInstance(&pEnum);

    if (FAILED(hr))
        return hr;

    hr = pEnum->Init(pUnkForRelease, collection);

    if (SUCCEEDED(hr))
        hr = pEnum->QueryInterface(ppUnk);

    if (FAILED(hr))
        delete pEnum;

    return hr;

} // CreateSTLEnumerator


#endif //__STLENUM_H__