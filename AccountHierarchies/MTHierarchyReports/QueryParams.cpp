/**************************************************************************
* Copyright 2004 by MetraTech
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

#include "StdAfx.h"
#include "MTHierarchyReports.h"
#include "QueryParams.h"

/////////////////////////////////////////////////////////////////////////////
// CQueryParams
STDMETHODIMP CQueryParams::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IQueryParams
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

STDMETHODIMP CQueryParams::get_TopRows(long* plVal)
{
  (*plVal) = m_lTopRows;
	return S_OK;
}

STDMETHODIMP CQueryParams::put_TopRows(long lVal)
{
  m_lTopRows = lVal;
	return S_OK;
}

STDMETHODIMP CQueryParams::get_SingleProductSlice(ISingleProductSlice **pProductSlice)
{
  if(!pProductSlice) 
		return E_POINTER;

  MTHIERARCHYREPORTSLib::ISingleProductSlice* pSlice = m_ptrProductSlice;
  (*pProductSlice) = reinterpret_cast<ISingleProductSlice *>(pSlice);
  pSlice->AddRef();
	return S_OK;
}

STDMETHODIMP CQueryParams::put_SingleProductSlice(ISingleProductSlice* pProductSlice)
{
  m_ptrProductSlice = pProductSlice;
	return S_OK;
}

STDMETHODIMP CQueryParams::get_SessionSlice(IViewSlice **pSessionSlice)
{
	if(!pSessionSlice) 
		return E_POINTER;

  MTHIERARCHYREPORTSLib::IViewSlice* pSlice = m_ptrSessionSlice;;
  (*pSessionSlice) = reinterpret_cast<IViewSlice*>(pSlice);
  pSlice->AddRef();
	return S_OK;
}

STDMETHODIMP CQueryParams::put_SessionSlice(IViewSlice* pSessionSlice)
{
  m_ptrSessionSlice = pSessionSlice;
	return S_OK;
}

STDMETHODIMP CQueryParams::get_AccountSlice(IAccountSlice **pAccountSlice)
{
	if(!pAccountSlice) 
		return E_POINTER;

  MTHIERARCHYREPORTSLib::IAccountSlice* pSlice = m_ptrAccountSlice;
  (*pAccountSlice) = reinterpret_cast<IAccountSlice*>(pSlice);
  pSlice->AddRef();
	return S_OK;
}

STDMETHODIMP CQueryParams::put_AccountSlice(IAccountSlice* pAccountSlice)
{
  m_ptrAccountSlice = pAccountSlice;
	return S_OK;
}

STDMETHODIMP CQueryParams::get_TimeSlice(ITimeSlice **pTimeSlice)
{
	if(!pTimeSlice) 
		return E_POINTER;

  MTHIERARCHYREPORTSLib::ITimeSlice* pSlice = m_ptrTimeSlice;
  (*pTimeSlice) = reinterpret_cast<ITimeSlice*>(pSlice);
  pSlice->AddRef();
	return S_OK;
}

STDMETHODIMP CQueryParams::put_TimeSlice(ITimeSlice* pTimeSlice)
{
  m_ptrTimeSlice = pTimeSlice;
	return S_OK;
}

STDMETHODIMP CQueryParams::get_Extension(BSTR *pbstrExtension)
{
  (*pbstrExtension) = m_bstrExtension.copy();
	return S_OK;
}

STDMETHODIMP CQueryParams::put_Extension(BSTR bstrExtension)
{
  m_bstrExtension = bstrExtension;
	return S_OK;
}

//-- EOF --