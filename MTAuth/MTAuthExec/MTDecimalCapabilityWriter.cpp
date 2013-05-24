// MTDecimalCapabilityWriter.cpp : Implementation of CMTDecimalCapabilityWriter
#include "StdAfx.h"
#include "MTAuthExec.h"
#include "MTDecimalCapabilityWriter.h"

/////////////////////////////////////////////////////////////////////////////
// CMTDecimalCapabilityWriter

STDMETHODIMP CMTDecimalCapabilityWriter::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTDecimalCapabilityWriter
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

HRESULT CMTDecimalCapabilityWriter::Activate()
{
	HRESULT hr = GetObjectContext(&m_spObjectContext);
	if (SUCCEEDED(hr))
		return S_OK;
	return hr;
} 

BOOL CMTDecimalCapabilityWriter::CanBePooled()
{
	return FALSE;
} 

void CMTDecimalCapabilityWriter::Deactivate()
{
	m_spObjectContext.Release();
} 

STDMETHODIMP CMTDecimalCapabilityWriter::CreateOrUpdate(long aInstanceID, IMTSimpleCondition* aParam)
{
	HRESULT hr(S_OK);
	MTAutoContext context(m_spObjectContext);
	MTAUTHEXECLib::IMTSimpleConditionPtr paramPtr = aParam;
	try
	{
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);

		//1. Delete t_compositor mappings, in case the number of atomic
		//was changed
		rowset->SetQueryTag("__DELETE_PARAMETER__");
		rowset->AddParam("%%TABLE_NAME%%", "t_decimal_capability");
		rowset->AddParam("%%ID%%", aInstanceID);
		rowset->Execute();

		rowset->Clear();
		
		rowset->SetQueryTag("__INSERT_NUMERIC_PARAMETER__");
		rowset->AddParam("%%TABLE_NAME%%", "t_decimal_capability");
		rowset->AddParam("%%ID%%", aInstanceID);
		rowset->AddParam("%%OP%%", paramPtr->Test);
		rowset->AddParam("%%PARAM%%", paramPtr->Value);
		rowset->Execute();
		context.Complete();
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
	
	return S_OK;
}

STDMETHODIMP CMTDecimalCapabilityWriter::Remove(long aInstanceID)
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
		rowset->AddParam("%%TABLE_NAME%%", "t_decimal_capability");
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