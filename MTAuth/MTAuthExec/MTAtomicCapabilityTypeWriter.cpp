// MTAtomicCapabilityTypeWriter.cpp : Implementation of CMTAtomicCapabilityTypeWriter
#include "StdAfx.h"
#include "MTAuthExec.h"
#include "MTAtomicCapabilityTypeWriter.h"

/////////////////////////////////////////////////////////////////////////////
// CMTAtomicCapabilityTypeWriter

STDMETHODIMP CMTAtomicCapabilityTypeWriter::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTAtomicCapabilityTypeWriter
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

HRESULT CMTAtomicCapabilityTypeWriter::Activate()
{
	HRESULT hr = GetObjectContext(&m_spObjectContext);
	if (SUCCEEDED(hr))
		return S_OK;
	return hr;
} 

BOOL CMTAtomicCapabilityTypeWriter::CanBePooled()
{
	return FALSE;
} 

void CMTAtomicCapabilityTypeWriter::Deactivate()
{
	m_spObjectContext.Release();
} 

STDMETHODIMP CMTAtomicCapabilityTypeWriter::Create(IMTAtomicCapabilityType* aType, long* apID)
{
	HRESULT hr(S_OK);
	MTAutoContext context(m_spObjectContext);
	try
	{
		_variant_t vtGUID;
	  if(!MTMiscUtil::CreateGuidAsVariant(vtGUID)) {
		  return E_FAIL;
	  }

    MTAUTHEXECLib::IMTAtomicCapabilityTypePtr typePtr = aType;
		MTAUTHEXECLib::IMTAtomicCapabilityTypeWriterPtr thisPtr = this;
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);

		rowset->InitializeForStoredProc ("sp_InsertAtomicCapType");
    rowset->AddInputParameterToStoredProc ("aGuid", MTTYPE_VARBINARY, INPUT_PARAM, vtGUID);
    rowset->AddInputParameterToStoredProc ("aName", MTTYPE_VARCHAR, INPUT_PARAM, typePtr->Name);
    rowset->AddInputParameterToStoredProc ("aDesc", MTTYPE_VARCHAR, INPUT_PARAM, typePtr->Description);
    rowset->AddInputParameterToStoredProc ("aProgid", MTTYPE_VARCHAR, INPUT_PARAM, typePtr->ProgID);
    rowset->AddInputParameterToStoredProc ("aEditor", MTTYPE_VARCHAR, INPUT_PARAM, typePtr->Editor);
    rowset->AddOutputParameterToStoredProc ("ap_id_prop", MTTYPE_INTEGER, OUTPUT_PARAM);
    rowset->ExecuteStoredProc();
    typePtr->ID = rowset->GetParameterFromStoredProc("ap_id_prop");
		(*apID) = typePtr->ID;
		context.Complete();
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
	
	return S_OK;
}

STDMETHODIMP CMTAtomicCapabilityTypeWriter::Update(IMTAtomicCapabilityType* aType, long* apID)
{
	HRESULT hr(S_OK);
	MTAutoContext context(m_spObjectContext);
	try
	{
		MTAUTHEXECLib::IMTAtomicCapabilityTypePtr typePtr = aType;
		MTAUTHEXECLib::IMTAtomicCapabilityTypeWriterPtr thisPtr = this;
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		rowset->SetQueryTag("__UPDATE_ACT__");
		rowset->AddParam("%%ID%%", typePtr->ID);
		rowset->AddParam("%%NAME%%", typePtr->Name);
		rowset->AddParam("%%DESC%%", typePtr->Description);
		rowset->AddParam("%%PROGID%%", typePtr->ProgID);
		rowset->AddParam("%%EDITOR%%", typePtr->Editor);
		rowset->Execute();
		(*apID) = typePtr->ID;
		context.Complete();
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
	
	return S_OK;
}