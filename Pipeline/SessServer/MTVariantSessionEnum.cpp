/**************************************************************************
 * @doc MTSESSION
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
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#include "StdAfx.h"
#include "SessServer.h"
#include "MTSessionDef.h"
#include "MTVariantSessionEnum.h"

/******************************************* error interface ***/
STDMETHODIMP CMTVariantSessionEnum::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IEnumVARIANT,
	};
	for (int i=0;i<sizeof(arr)/sizeof(arr[0]);i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}


/********************************** construction/destruction ***/
CMTVariantSessionEnum::CMTVariantSessionEnum()
	:	mpVariantSessionEnumBase(NULL),
		mlPos(0)
{
}

HRESULT CMTVariantSessionEnum::FinalConstruct()
{
	return S_OK;
}

void CMTVariantSessionEnum::FinalRelease()
{
	ASSERT(mpVariantSessionEnumBase);
	if (mpVariantSessionEnumBase)
	{
		delete mpVariantSessionEnumBase;
		mpVariantSessionEnumBase = NULL;
	}
}

//----- Automation methods
STDMETHODIMP CMTVariantSessionEnum::Next(unsigned long cElements,
										 VARIANT * pvar,
										 unsigned long * pcElementFetched)
{
	if (!pvar)
		return E_POINTER;

	try
	{
		if (pcElementFetched != NULL)
			*pcElementFetched = 0;

		unsigned int count = 0;
		while(count < cElements)
		{
			//----- Get the next Session object.
			CMTSessionBase* pSession = NULL;
			if (mInitialState)
			{
				mpVariantSessionEnumBase->First(mlPos, &pSession);
				mInitialState = FALSE;
			}
			else
				mpVariantSessionEnumBase->Next(mlPos, &pSession);

			if (pSession == NULL)
				// that's it
				break;

			std::auto_ptr<CMTSessionBase> tmpPtr(pSession);

			//----- Create a COM prapper for session object.
			CComObject<CMTSession>* sessObj;
			HRESULT hr = CComObject<CMTSession>::CreateInstance(&sessObj);
			if (FAILED(hr))
				return hr;

			IDispatch* idisp;
			hr = sessObj->QueryInterface(IID_IDispatch, (void**) &idisp);
			if (FAILED(hr))
				break;

			//----- Set the session object into COM wrapper.
			sessObj->SetSession(tmpPtr.release());

			// TODO: it would be nice to do this in place
			//       instead of making this copy
			_variant_t var;
			var = idisp;
			pvar[count] = var;

			count++;
		}
		
		//----- Return the count
		if (pcElementFetched)
			*pcElementFetched = count;

		return (count < cElements) ? ResultFromScode(S_FALSE) : S_OK;
	}
	catch (HRESULT hr)
	{
		return hr;
	}
	catch (_com_error err)
	{
		return err.Error();
	}
}

STDMETHODIMP CMTVariantSessionEnum::Skip(ULONG cElements)
{
	return E_NOTIMPL;
}

STDMETHODIMP CMTVariantSessionEnum::Reset()
{
	mlPos = 0;
	mInitialState = TRUE;
	return E_NOTIMPL;
}

STDMETHODIMP CMTVariantSessionEnum::Clone(IEnumVARIANT * * ppEnum)
{
	return E_NOTIMPL;
}

//-- EOF --