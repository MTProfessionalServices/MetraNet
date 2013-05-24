// MTEnumTypeCapabilityWriter.cpp : Implementation of CMTEnumTypeCapabilityWriter
#include "StdAfx.h"
#include "MTAuthExec.h"
#include "MTEnumTypeCapabilityWriter.h"

/////////////////////////////////////////////////////////////////////////////
// CMTEnumTypeCapabilityWriter

STDMETHODIMP CMTEnumTypeCapabilityWriter::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTEnumTypeCapabilityWriter
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

HRESULT CMTEnumTypeCapabilityWriter::Activate()
{
	HRESULT hr = GetObjectContext(&m_spObjectContext);
	if (SUCCEEDED(hr))
		return S_OK;
	return hr;
} 

BOOL CMTEnumTypeCapabilityWriter::CanBePooled()
{
	return FALSE;
} 

void CMTEnumTypeCapabilityWriter::Deactivate()
{
	m_spObjectContext.Release();
} 

STDMETHODIMP CMTEnumTypeCapabilityWriter::CreateOrUpdate(long aInstanceID, VARIANT aParam)
{
	HRESULT hr(S_OK);
	MTAutoContext context(m_spObjectContext);
	_variant_t vtNull;
	vtNull.ChangeType(VT_NULL);
	try
	{
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);

		//1. Delete t_compositor mappings, in case the number of atomic
		//was changed
		rowset->SetQueryTag("__DELETE_PARAMETER__");
		rowset->AddParam("%%TABLE_NAME%%", "t_enum_capability");
		rowset->AddParam("%%ID%%", aInstanceID);
		rowset->Execute();

		rowset->Clear();
		
		rowset->SetQueryTag("__INSERT_NUMERIC_PARAMETER__");
		rowset->AddParam("%%TABLE_NAME%%", "t_enum_capability");
		rowset->AddParam("%%ID%%", aInstanceID);
		rowset->AddParam("%%OP%%", L"=");
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

STDMETHODIMP CMTEnumTypeCapabilityWriter::Remove(long aInstanceID)
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
		rowset->AddParam("%%TABLE_NAME%%", "t_enum_capability");
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