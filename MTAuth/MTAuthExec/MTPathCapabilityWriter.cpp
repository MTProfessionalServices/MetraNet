// MTPathCapabilityWriter.cpp : Implementation of CMTPathCapabilityWriter
#include "StdAfx.h"
#include "MTAuthExec.h"
#include "MTPathCapabilityWriter.h"

/////////////////////////////////////////////////////////////////////////////
// CMTPathCapabilityWriter

STDMETHODIMP CMTPathCapabilityWriter::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTPathCapabilityWriter
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

HRESULT CMTPathCapabilityWriter::Activate()
{
	HRESULT hr = GetObjectContext(&m_spObjectContext);
	if (SUCCEEDED(hr))
		return S_OK;
	return hr;
} 

BOOL CMTPathCapabilityWriter::CanBePooled()
{
	return FALSE;
} 

void CMTPathCapabilityWriter::Deactivate()
{
	m_spObjectContext.Release();
} 


STDMETHODIMP CMTPathCapabilityWriter::CreateOrUpdate(long aInstanceID, BSTR aParam)
{
	HRESULT hr(S_OK);
	MTAutoContext context(m_spObjectContext);
	try
	{
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);

		//1. Delete t_compositor mappings, in case the number of atomic
		//was changed
		rowset->SetQueryTag("__DELETE_PARAMETER__");
		rowset->AddParam("%%TABLE_NAME%%", "t_path_capability");
		rowset->AddParam("%%ID%%", aInstanceID);
		rowset->Execute();

		rowset->Clear();
		
		rowset->SetQueryTag("__INSERT_STRING_PARAMETER__");
		rowset->AddParam("%%TABLE_NAME%%", "t_path_capability");
		rowset->AddParam("%%ID%%", aInstanceID);
		rowset->AddParam("%%PARAM%%", aParam);
		rowset->Execute();
		context.Complete();
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
	
	return S_OK;
}

STDMETHODIMP CMTPathCapabilityWriter::Remove(long aInstanceID)
{
	HRESULT hr(S_OK);
	MTAutoContext context(m_spObjectContext);
	try
	{
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);

		//1. Delete t_compositor mappings, in case the number of atomic
		//was changed
		rowset->SetQueryTag("__DELETE_PARAMETER__");
		rowset->AddParam("%%TABLE_NAME%%", "t_path_capability");
		rowset->AddParam("%%ID%%", aInstanceID);
		rowset->Execute();
		context.Complete();
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
	return S_OK;
}

