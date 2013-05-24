// MTCompositeCapabilityTypeWriter.cpp : Implementation of CMTCompositeCapabilityTypeWriter
#include "StdAfx.h"
#include "MTAuthExec.h"
#include "MTCompositeCapabilityTypeWriter.h"

/////////////////////////////////////////////////////////////////////////////
// CMTCompositeCapabilityTypeWriter
STDMETHODIMP CMTCompositeCapabilityTypeWriter::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTCompositeCapabilityTypeWriter
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

HRESULT CMTCompositeCapabilityTypeWriter::Activate()
{
	HRESULT hr = GetObjectContext(&m_spObjectContext);
	if (SUCCEEDED(hr))
		return S_OK;
	return hr;
} 

BOOL CMTCompositeCapabilityTypeWriter::CanBePooled()
{
	return FALSE;
} 

void CMTCompositeCapabilityTypeWriter::Deactivate()
{
	m_spObjectContext.Release();
} 



STDMETHODIMP CMTCompositeCapabilityTypeWriter::Create(IMTCompositeCapabilityType* aType, long* apID)
{
	HRESULT hr(S_OK);
	MTAutoContext context(m_spObjectContext);
	try
	{
    _variant_t vtGUID;
	  if(!MTMiscUtil::CreateGuidAsVariant(vtGUID)) {
		  return E_FAIL;
	  }
		MTAUTHEXECLib::IMTCompositeCapabilityTypePtr typePtr = aType;
		MTAUTHEXECLib::IMTCompositeCapabilityTypeWriterPtr thisPtr = this;
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);

		rowset->InitializeForStoredProc ("sp_InsertCompositeCapType");
    rowset->AddInputParameterToStoredProc ("aGuid", MTTYPE_VARBINARY, INPUT_PARAM, vtGUID);
    rowset->AddInputParameterToStoredProc ("aName", MTTYPE_VARCHAR, INPUT_PARAM, typePtr->Name);
    rowset->AddInputParameterToStoredProc ("aDesc", MTTYPE_VARCHAR, INPUT_PARAM, typePtr->Description);
    rowset->AddInputParameterToStoredProc ("aProgid", MTTYPE_VARCHAR, INPUT_PARAM, typePtr->ProgID);
    rowset->AddInputParameterToStoredProc ("aEditor", MTTYPE_VARCHAR, INPUT_PARAM, typePtr->Editor);
    rowset->AddInputParameterToStoredProc ("aCSRAssignable", MTTYPE_VARCHAR, INPUT_PARAM, MTTypeConvert::BoolToString(typePtr->CSRAssignable));
    rowset->AddInputParameterToStoredProc ("aSubAssignable", MTTYPE_VARCHAR, INPUT_PARAM, MTTypeConvert::BoolToString(typePtr->SubscriberAssignable));
    rowset->AddInputParameterToStoredProc ("aMultipleInstances", MTTYPE_VARCHAR, INPUT_PARAM, MTTypeConvert::BoolToString(typePtr->AllowMultipleInstances));
    rowset->AddInputParameterToStoredProc ("aUmbrellaSensitive", MTTYPE_VARCHAR, INPUT_PARAM, MTTypeConvert::BoolToString(typePtr->UmbrellaSensitive));
    rowset->AddOutputParameterToStoredProc ("ap_id_prop", MTTYPE_INTEGER, OUTPUT_PARAM);
    rowset->ExecuteStoredProc();
    int propid = rowset->GetParameterFromStoredProc("ap_id_prop");
    if(propid == -99)
      MT_THROW_COM_ERROR("sp_InsertCompositeCapType returned -99");
    typePtr->ID = propid;
		thisPtr->InsertCompositorMappings((MTAUTHEXECLib::IMTCompositeCapabilityType*)aType);
		(*apID) = typePtr->ID;
		context.Complete();
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
	
	return S_OK;
}

STDMETHODIMP CMTCompositeCapabilityTypeWriter::Update(IMTCompositeCapabilityType* aType, long* apID)
{
	HRESULT hr(S_OK);
	MTAutoContext context(m_spObjectContext);
	try
	{
		MTAUTHEXECLib::IMTCompositeCapabilityTypePtr typePtr = aType;
		MTAUTHEXECLib::IMTCompositeCapabilityTypeWriterPtr thisPtr = this;
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);

		//1. Delete t_compositor mappings, in case the number of atomic
		//was changed
		rowset->SetQueryTag("__DELETE_COMPOSITE_MAPPINGS__");
		rowset->AddParam("%%ID%%", typePtr->ID);
		rowset->Execute();

		rowset->Clear();
		
		rowset->SetQueryTag("__UPDATE_CCT__");
		rowset->AddParam("%%ID%%", typePtr->ID);
		rowset->AddParam("%%NAME%%", typePtr->Name);
		rowset->AddParam("%%DESC%%", typePtr->Description);
		rowset->AddParam("%%PROGID%%", typePtr->ProgID);
		rowset->AddParam("%%EDITOR%%", typePtr->Editor);
		rowset->AddParam("%%CSR%%", MTTypeConvert::BoolToString(typePtr->CSRAssignable));
		rowset->AddParam("%%SUBSCRIBER%%", MTTypeConvert::BoolToString(typePtr->SubscriberAssignable));
		rowset->AddParam("%%MULTIPLE_INSTANCES%%", MTTypeConvert::BoolToString(typePtr->AllowMultipleInstances));
    rowset->AddParam("%%UMBRELLA%%", MTTypeConvert::BoolToString(typePtr->UmbrellaSensitive));
		rowset->Execute();
		thisPtr->InsertCompositorMappings((MTAUTHEXECLib::IMTCompositeCapabilityType*)aType);
		(*apID) = typePtr->ID;
		context.Complete();
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
	
	return S_OK;
}

STDMETHODIMP CMTCompositeCapabilityTypeWriter::InsertCompositorMappings(IMTCompositeCapabilityType* aType)
{
	HRESULT hr(S_OK);
	MTAutoContext context(m_spObjectContext);
	long numAtomics = 0;
	try
	{
		MTAUTHEXECLib::IMTCompositeCapabilityTypePtr typePtr = aType;
		MTAUTHEXECLib::IMTAtomicCapabilityTypePtr atomicPtr;
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		numAtomics = typePtr->NumAtomic;
		rowset->Init(CONFIG_DIR);

		for (int i=1; i <= numAtomics; ++i)
		{
			atomicPtr = typePtr->GetAtomicCapabilityTypes()->GetItem(i);
			ASSERT(atomicPtr != NULL);
			rowset->Clear();
			rowset->SetQueryTag("__INSERT_COMPOSITE_MAPPINGS__");
			rowset->AddParam("%%COMPOSITE_ID%%", typePtr->ID);
			rowset->AddParam("%%ATOMIC_ID%%", atomicPtr->ID);
			rowset->AddParam("%%COMP_DESC%%", atomicPtr->CompositionDescription);
			rowset->AddParam("%%PROPERTY%%", atomicPtr->ParameterName);
			rowset->Execute();
			context.Complete();
		}
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
	
	return S_OK;
}


