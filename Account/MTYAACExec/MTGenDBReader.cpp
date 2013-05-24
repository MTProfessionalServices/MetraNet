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

#include "StdAfx.h"
#include "MTYAACExec.h"
#include "MTGenDBReader.h"
#include <mtprogids.h>
#include <optionalvariant.h>



/////////////////////////////////////////////////////////////////////////////
// CMTGenDBReader
STDMETHODIMP CMTGenDBReader::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTGenDBReader
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (::InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

HRESULT CMTGenDBReader::Activate()
{
	HRESULT hr = GetObjectContext(&m_spObjectContext);
	if (SUCCEEDED(hr))
		return S_OK;
	return hr;
} 

BOOL CMTGenDBReader::CanBePooled()
{
	return TRUE;
} 

void CMTGenDBReader::Deactivate()
{
	m_spObjectContext.Release();
} 


STDMETHODIMP CMTGenDBReader::ExecuteStatement(BSTR aQuery,VARIANT aQueryDir,IMTSQLRowset **ppRowset)
{
	MTAutoContext ctx(m_spObjectContext);
	try {
	
		_variant_t queryDir;

		ROWSETLib::IMTSQLRowsetPtr aRowset(MTPROGID_SQLROWSET);
		if(OptionalVariantConversion(aQueryDir,VT_BSTR,queryDir)) {
			aRowset->Init((_bstr_t)queryDir);
		}
		else {
			aRowset->Init(DATABASE_CONFIGDIR);
		}

		aRowset->SetQueryString(aQuery);
		aRowset->ExecuteDisconnected();
		*ppRowset = reinterpret_cast<IMTSQLRowset*>(aRowset.Detach());
	}
	catch(_com_error& err) {
		return ReturnComError(err);
	}
	ctx.Complete();
	return S_OK;
}
