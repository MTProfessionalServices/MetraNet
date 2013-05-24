// MTGenDbWriter.cpp : Implementation of CMTGenDbWriter
#include "StdAfx.h"
#include "MTYAACExec.h"
#include "MTGenDbWriter.h"

/////////////////////////////////////////////////////////////////////////////
// CMTGenDbWriter

STDMETHODIMP CMTGenDbWriter::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTGenDbWriter
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (::InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}


HRESULT CMTGenDbWriter::Activate()
{
	HRESULT hr = GetObjectContext(&m_spObjectContext);
	if (SUCCEEDED(hr))
		return S_OK;
	return hr;
} 

BOOL CMTGenDbWriter::CanBePooled()
{
	return TRUE;
} 

void CMTGenDbWriter::Deactivate()
{
	m_spObjectContext.Release();
} 


STDMETHODIMP CMTGenDbWriter::ExecuteStatement(BSTR aQuery,VARIANT aQueryDir)
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
		aRowset->Execute();
	}
	catch(_com_error& err) {
		return ReturnComError(err);
	}
	ctx.Complete();
	return S_OK;
}
