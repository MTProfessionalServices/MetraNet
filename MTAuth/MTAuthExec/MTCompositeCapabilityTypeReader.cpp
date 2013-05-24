// MTCompositeCapabilityTypeReader.cpp : Implementation of CMTCompositeCapabilityTypeReader
#include "StdAfx.h"
#include "MTAuthExec.h"
#include "MTCompositeCapabilityTypeReader.h"

/////////////////////////////////////////////////////////////////////////////
// CMTCompositeCapabilityTypeReader

STDMETHODIMP CMTCompositeCapabilityTypeReader::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTCompositeCapabilityTypeReader
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}


HRESULT CMTCompositeCapabilityTypeReader::Activate()
{
	HRESULT hr = GetObjectContext(&m_spObjectContext);
	if (SUCCEEDED(hr))
		return S_OK;
	return hr;
} 


BOOL CMTCompositeCapabilityTypeReader::CanBePooled()
{
	return FALSE;
} 

void CMTCompositeCapabilityTypeReader::Deactivate()
{
	m_spObjectContext.Release();
} 


STDMETHODIMP CMTCompositeCapabilityTypeReader::Get(long aTypeID, IMTCompositeCapabilityType **apNewType)
{
	HRESULT hr(S_OK);
	MTAutoContext context(m_spObjectContext);
	MTAUTHEXECLib::IMTCompositeCapabilityTypeReaderPtr thisPtr = this;
	bool bFirstRow(TRUE);

	if (!apNewType)
		return E_POINTER;

	*apNewType = NULL;

	try
	{
		ROWSETLib::IMTSQLRowsetPtr rowset = thisPtr->GetAsRowset(aTypeID);
		MTAUTHLib::IMTCompositeCapabilityTypePtr cctPtr(__uuidof(MTAUTHLib::MTCompositeCapabilityType));

		while(rowset->GetRowsetEOF().boolVal == VARIANT_FALSE)
		{
			if (bFirstRow)
			{
				cctPtr->ID = rowset->GetValue("id_cap_type");
				cctPtr->GUID = MTMiscUtil::GetString(rowset->GetValue("tx_guid"));
				cctPtr->Name = MTMiscUtil::GetString(rowset->GetValue("tx_name"));
				cctPtr->Description = MTMiscUtil::GetString(rowset->GetValue("tx_desc"));
				cctPtr->ProgID = MTMiscUtil::GetString(rowset->GetValue("tx_progid"));
				cctPtr->Editor = MTMiscUtil::GetString(rowset->GetValue("tx_editor"));
				cctPtr->CSRAssignable = MTTypeConvert::StringToBool(MTMiscUtil::GetString(rowset->GetValue("csr_assignable")));
				cctPtr->SubscriberAssignable = MTTypeConvert::StringToBool(MTMiscUtil::GetString(rowset->GetValue("subscriber_assignable")));
				cctPtr->AllowMultipleInstances = MTTypeConvert::StringToBool(MTMiscUtil::GetString(rowset->GetValue("multiple_instances")));
        cctPtr->UmbrellaSensitive = MTTypeConvert::StringToBool(MTMiscUtil::GetString(rowset->GetValue("umbrella_sensitive")));
			}
			MTAUTHLib::IMTAtomicCapabilityTypePtr actPtr(__uuidof(MTAUTHLib::MTAtomicCapabilityType));
			//if next value is null, then this composite has 0 atomics, just return
			_variant_t atomicProgID = rowset->GetValue("atomic_tx_progid");
			if(V_VT(&atomicProgID) == VT_NULL)
			{
				(*apNewType) = reinterpret_cast<IMTCompositeCapabilityType*>(cctPtr.Detach());
				context.Complete();
				return S_OK;
			}
			actPtr->ProgID = (_bstr_t)atomicProgID;
			actPtr->ID = rowset->GetValue("atomic_id_cap_type");
			actPtr->CompositionDescription = MTMiscUtil::GetString(rowset->GetValue("CompositionDescription"));
			actPtr->ParameterName = MTMiscUtil::GetString(rowset->GetValue("tx_param"));
			actPtr->Name = MTMiscUtil::GetString(rowset->GetValue("atomic_tx_name"));
      actPtr->GUID = MTMiscUtil::GetString(rowset->GetValue("atomic_tx_guid"));
      actPtr->Description = MTMiscUtil::GetString(rowset->GetValue("atomic_tx_desc"));
			actPtr->Editor = MTMiscUtil::GetString(rowset->GetValue("atomic_tx_editor"));
			cctPtr->AddAtomicCapabilityType(actPtr);

			bFirstRow = FALSE;
			rowset->MoveNext();
		}

		(*apNewType) = reinterpret_cast<IMTCompositeCapabilityType*>(cctPtr.Detach());
		context.Complete();
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
	
	return S_OK;
}

STDMETHODIMP CMTCompositeCapabilityTypeReader::GetByInstanceID(long aInstanceID, IMTCompositeCapabilityType **apNewType)
{
	HRESULT hr(S_OK);
	long lTypeID;
	MTAutoContext context(m_spObjectContext);
	MTAUTHEXECLib::IMTCompositeCapabilityTypeReaderPtr thisPtr = this;

	if (!apNewType)
		return E_POINTER;

	*apNewType = NULL;

	try
	{
		lTypeID = thisPtr->GetTypeIDByInstanceID(aInstanceID);
		(*apNewType) = (IMTCompositeCapabilityType*)thisPtr->Get(lTypeID).Detach();
		context.Complete();
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
	
	return S_OK;
}

STDMETHODIMP CMTCompositeCapabilityTypeReader::GetAsRowset(long aTypeID, IMTSQLRowset **apRowset)
{
	HRESULT hr(S_OK);
	MTAutoContext context(m_spObjectContext);
	if (!apRowset)
		return E_POINTER;

	*apRowset = NULL;

	try
	{
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		
		rowset->SetQueryTag("__INIT_CCT__");
		rowset->AddParam("%%CCT_ID%%", aTypeID);
		rowset->Execute();
		context.Complete();
		(*apRowset) = (IMTSQLRowset*)rowset.Detach();
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
	

	return S_OK;
}

STDMETHODIMP CMTCompositeCapabilityTypeReader::GetByInstanceIDAsRowset(long aInstanceID, IMTSQLRowset **apRowset)
{
	HRESULT hr(S_OK);
	long lTypeID;
	MTAutoContext context(m_spObjectContext);
	MTAUTHEXECLib::IMTCompositeCapabilityTypeReaderPtr thisPtr = this;

	if (!apRowset)
		return E_POINTER;

	*apRowset = NULL;

	try
	{
		lTypeID = thisPtr->GetTypeIDByInstanceID(aInstanceID);
		(*apRowset) = (IMTSQLRowset*)thisPtr->GetAsRowset(lTypeID).Detach();
		context.Complete();
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
	
	return S_OK;
}

STDMETHODIMP CMTCompositeCapabilityTypeReader::GetTypeIDByInstanceID(long aInstanceID, long *apTypeID)
{
	HRESULT hr(S_OK);
	MTAutoContext context(m_spObjectContext);
	MTAUTHEXECLib::IMTCompositeCapabilityTypeReaderPtr thisPtr = this;

	if (!apTypeID)
		return E_POINTER;

	*apTypeID = NULL;

	try
	{
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		
		rowset->SetQueryTag("__GET_CCT_ID_BY_INSTANCE_ID__");
		rowset->AddParam("%%INSTANCE_ID%%", aInstanceID);
		rowset->Execute();
		
		if (rowset->GetRowsetEOF().boolVal == VARIANT_TRUE)
		{
			MT_THROW_COM_ERROR(MTAUTH_COMPOSITE_CAPABILITY_TYPE_NOT_FOUND_BY_INSTANCE, aInstanceID);
		}

		(*apTypeID) = (long)rowset->GetValue("id_cap_type");
		context.Complete();
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
	
	return S_OK;
}

STDMETHODIMP CMTCompositeCapabilityTypeReader::GetTypeIDByName(BSTR aTypeName, long *apTypeID)
{
	HRESULT hr(S_OK);
	MTAutoContext context(m_spObjectContext);
	MTAUTHEXECLib::IMTCompositeCapabilityTypeReaderPtr thisPtr = this;

	if (!apTypeID)
		return E_POINTER;

	*apTypeID = NULL;

	try
	{
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		
		rowset->SetQueryTag("__GET_CCT_ID_BY_NAME__");
		rowset->AddParam("%%NAME%%", aTypeName);
		rowset->Execute();

    _bstr_t bstrTypeName = aTypeName;
		
		if (rowset->GetRowsetEOF().boolVal == VARIANT_TRUE)
		{
			
      MT_THROW_COM_ERROR(MTAUTH_COMPOSITE_CAPABILITY_TYPE_NOT_FOUND, (char*)bstrTypeName);
		}
		if (rowset->GetRecordCount() > 1)
		{
			MT_THROW_COM_ERROR(MTAUTH_COMPOSITE_CAPABILITY_TYPE_MORE_THEN_ONE_FOUND, (char*)bstrTypeName);
		}

		(*apTypeID) = (long)rowset->GetValue("id_cap_type");
		context.Complete();
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
	
	return S_OK;
}

STDMETHODIMP CMTCompositeCapabilityTypeReader::GetByName(BSTR aTypeName, IMTCompositeCapabilityType **apNewType)
{
	HRESULT hr(S_OK);
	long lTypeID;
	MTAutoContext context(m_spObjectContext);
	MTAUTHEXECLib::IMTCompositeCapabilityTypeReaderPtr thisPtr = this;

	if (!apNewType)
		return E_POINTER;

	*apNewType = NULL;

	try
	{
		lTypeID = thisPtr->GetTypeIDByName(aTypeName);
		(*apNewType) = (IMTCompositeCapabilityType*)thisPtr->Get(lTypeID).Detach();
		context.Complete();
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
	
	return S_OK;
}


STDMETHODIMP CMTCompositeCapabilityTypeReader::FindRecordsByNameAsRowset(BSTR aTypeName, IMTSQLRowset **apRowset)
{
	HRESULT hr(S_OK);
	MTAutoContext context(m_spObjectContext);
	if (!apRowset)
		return E_POINTER;

	*apRowset = NULL;

	try
	{
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		
		rowset->SetQueryTag("__GET_CCTS_BY_NAME__");
		rowset->AddParam("%%NAME%%", aTypeName);
		rowset->Execute();
		context.Complete();
		(*apRowset) = (IMTSQLRowset*)rowset.Detach();
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
	

	return S_OK;
}

STDMETHODIMP CMTCompositeCapabilityTypeReader::FindNameByProgIDAsRowset(BSTR aProgID, IMTSQLRowset **apRowset)
{
	HRESULT hr(S_OK);
	MTAutoContext context(m_spObjectContext);
	if (!apRowset)
		return E_POINTER;

	*apRowset = NULL;

	try
	{
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		
		rowset->SetQueryTag("__GET_CCT_NAME_BY_PROGID__");
		rowset->AddParam("%%PROGID%%", aProgID);
		rowset->Execute();
		context.Complete();
		(*apRowset) = (IMTSQLRowset*)rowset.Detach();
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
	

	return S_OK;
}

STDMETHODIMP CMTCompositeCapabilityTypeReader::FindInstancesByNameAsRowset(BSTR aTypeName, IMTSQLRowset **apRowset)
{
	HRESULT hr(S_OK);
	MTAutoContext context(m_spObjectContext);
	if (!apRowset)
		return E_POINTER;

	*apRowset = NULL;

	try
	{
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		
		rowset->SetQueryTag("__GET_CCT_INSTANCES_BY_NAME__");
		rowset->AddParam("%%NAME%%", aTypeName);
		rowset->Execute();
		context.Complete();
		(*apRowset) = (IMTSQLRowset*)rowset.Detach();
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
	
	return S_OK;
}

STDMETHODIMP CMTCompositeCapabilityTypeReader::GetAllAsRowset(IMTSessionContext *aCtx, IMTSQLRowset **apRowset)
{
	HRESULT hr(S_OK);
	MTAutoContext context(m_spObjectContext);
	if (!apRowset)
		return E_POINTER;

	*apRowset = NULL;

	try
	{
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		
		rowset->SetQueryTag("__GET_CCTS__");
		rowset->Execute();
		context.Complete();
		(*apRowset) = (IMTSQLRowset*)rowset.Detach();
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
	

	return S_OK;
}
