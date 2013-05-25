// MTGenericDBReader.cpp : Implementation of CMTGenericDBReader
#include "StdAfx.h"
#include "MTGenericDBExec.h"
#include "MTGenericDBReader.h"
#include <mtprogids.h>
#include <optionalvariant.h>


/////////////////////////////////////////////////////////////////////////////
// CMTGenericDBReader

STDMETHODIMP CMTGenericDBReader::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTGenericDBReader
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (::InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}



HRESULT CMTGenericDBReader::Activate()
{
	HRESULT hr = GetObjectContext(&m_spObjectContext);
	if (SUCCEEDED(hr))
		return S_OK;
	return hr;
} 

BOOL CMTGenericDBReader::CanBePooled()
{
	return FALSE;
} 

void CMTGenericDBReader::Deactivate()
{
	m_spObjectContext.Release();
} 



STDMETHODIMP CMTGenericDBReader::ExecuteStatement(BSTR aQuery, VARIANT aQueryDir, IMTSQLRowset **ppRowset)
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
