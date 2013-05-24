// MTRoleReader.cpp : Implementation of CMTRoleReader
#include "StdAfx.h"
#include "MTAuthExec.h"
#include "MTRoleReader.h"

/////////////////////////////////////////////////////////////////////////////
// CMTRoleReader

STDMETHODIMP CMTRoleReader::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTRoleReader
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

HRESULT CMTRoleReader::Activate()
{
	HRESULT hr = GetObjectContext(&m_spObjectContext);
	if (SUCCEEDED(hr))
		return S_OK;
	return hr;
} 

BOOL CMTRoleReader::CanBePooled()
{
	return FALSE;
} 

void CMTRoleReader::Deactivate()
{
	m_spObjectContext.Release();
} 


STDMETHODIMP CMTRoleReader::FindRecordsByNameAsRowset(BSTR aRoleName, IMTSQLRowset **apRowset)
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
		
		rowset->SetQueryTag("__GET_ROLES_BY_NAME__");
		rowset->AddParam("%%NAME%%", aRoleName);
		rowset->Execute();
		(*apRowset) = (IMTSQLRowset*)rowset.Detach();
		context.Complete();
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	return S_OK;
}
STDMETHODIMP CMTRoleReader::HasMembers(BSTR aRoleName, VARIANT_BOOL *apRes)
{
	HRESULT hr(S_OK);
	MTAutoContext context(m_spObjectContext);
	try
	{
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		
		rowset->SetQueryTag("__GET_ROLE_ACTIVE_OR_DEFAULT_ACTORS__");
		rowset->AddParam("%%NAME%%", aRoleName);
		rowset->Execute();
    (*apRes) = (rowset->GetRowsetEOF().boolVal == FALSE) ? VARIANT_TRUE : VARIANT_FALSE;
		context.Complete();
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	return S_OK;
}

STDMETHODIMP CMTRoleReader::HasCapabilities(BSTR aRoleName, VARIANT_BOOL *apRes)
{
	HRESULT hr(S_OK);
	MTAutoContext context(m_spObjectContext);
	try
	{
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		
		rowset->SetQueryTag("__GET_ROLE_CAPS__");
		rowset->AddParam("%%NAME%%", aRoleName);
		rowset->Execute();
    (*apRes) = (rowset->GetRowsetEOF().boolVal == FALSE) ? VARIANT_TRUE : VARIANT_FALSE;
		context.Complete();
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	return S_OK;
}


STDMETHODIMP CMTRoleReader::IsDuplicateName(BSTR aRoleName, VARIANT_BOOL *apRes)
{
	try
	{
		MTAUTHEXECLib::IMTRoleReaderPtr thisPtr = this;
		(*apRes) = 
			thisPtr->FindRecordsByNameAsRowset(aRoleName)->GetRowsetEOF().boolVal == FALSE ?
			VARIANT_TRUE : VARIANT_FALSE;
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
	return S_OK;
}

STDMETHODIMP CMTRoleReader::GetMembersAsRowset(long aRoleID, MTPrincipalPolicyType aPolicyType, IMTSQLRowset **apRowset)
{
	HRESULT hr(S_OK);
	MTAutoContext context(m_spObjectContext);
	if (!apRowset)
		return E_POINTER;

	*apRowset = NULL;

	try
	{
		_bstr_t bstrPolicyType;
    switch(aPolicyType)
    {
    case ACTIVE_POLICY:
      bstrPolicyType = "A";
      break;
    case DEFAULT_POLICY:
      bstrPolicyType = "D";
      break;
    default:
      ASSERT(0);
    }

    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		
		rowset->SetQueryTag("__GET_ROLE_ACTORS_BY_ID__");
		rowset->AddParam("%%ID%%", aRoleID);
    rowset->AddParam("%%POLICY_TYPE%%", bstrPolicyType);
		rowset->Execute();
		(*apRowset) = (IMTSQLRowset*)rowset.Detach();
		context.Complete();
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	return S_OK;
}

STDMETHODIMP CMTRoleReader::Get(IMTSessionContext* aCtx, long aRoleID, IMTRole **apRole)
{
	HRESULT hr(S_OK);
	MTAutoContext context(m_spObjectContext);
	
  if (!apRole)
		return E_POINTER;
	
	*apRole = NULL;
	
	try
	{
		MTAUTHLib::IMTSecurityPtr security(MTPROGID_MTSECURITY);
    MTAUTHLib::IMTRolePtr rolePtr = security->CreateRole
      (reinterpret_cast<MTAUTHLib::IMTSessionContext*>(aCtx));

		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		
		rowset->SetQueryTag("__GET_ROLE_BY_ID__");
		rowset->AddParam("%%ROLE_ID%%", aRoleID);
		rowset->Execute();
		
		if(rowset->GetRowsetEOF().boolVal == VARIANT_TRUE)
		{
			MT_THROW_COM_ERROR(MTAUTH_ROLE_NOT_FOUND_BY_ID, aRoleID);
		}
		
		rolePtr->ID = rowset->GetValue("id_role");
		rolePtr->GUID = MTMiscUtil::GetString(rowset->GetValue("tx_guid"));
		rolePtr->Name = MTMiscUtil::GetString(rowset->GetValue("tx_name"));
		rolePtr->Description = MTMiscUtil::GetString(rowset->GetValue("tx_desc"));
		rolePtr->CSRAssignable = MTTypeConvert::StringToBool(MTMiscUtil::GetString(rowset->GetValue("csr_assignable")));
		rolePtr->SubscriberAssignable = MTTypeConvert::StringToBool(MTMiscUtil::GetString(rowset->GetValue("subscriber_assignable")));
		(*apRole) = reinterpret_cast<IMTRole*>(rolePtr.Detach());
		context.Complete();
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
	
	return S_OK;
}

STDMETHODIMP CMTRoleReader::GetByName(IMTSessionContext* aCtx, BSTR aRoleName, IMTRole** apRole)
{
	HRESULT hr(S_OK);
	MTAutoContext context(m_spObjectContext);
	
	if (!apRole)
		return E_POINTER;
	
	*apRole = NULL;
	
	try
	{
		MTAUTHLib::IMTSecurityPtr security(MTPROGID_MTSECURITY);
    MTAUTHLib::IMTRolePtr rolePtr = security->CreateRole(reinterpret_cast<MTAUTHLib::IMTSessionContext*>(aCtx));
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		
		rowset->SetQueryTag("__GET_ROLE_BY_NAME__");
		rowset->AddParam("%%NAME%%", aRoleName);
		rowset->Execute();
		
		if(rowset->GetRowsetEOF().boolVal == VARIANT_TRUE)
		{
			return S_OK;
		}
		
		rolePtr->ID = rowset->GetValue("id_role");
		rolePtr->GUID = MTMiscUtil::GetString(rowset->GetValue("tx_guid"));
		rolePtr->Name = MTMiscUtil::GetString(rowset->GetValue("tx_name"));
		rolePtr->Description = MTMiscUtil::GetString(rowset->GetValue("tx_desc"));
		rolePtr->CSRAssignable = MTTypeConvert::StringToBool(MTMiscUtil::GetString(rowset->GetValue("csr_assignable")));
		rolePtr->SubscriberAssignable = MTTypeConvert::StringToBool(MTMiscUtil::GetString(rowset->GetValue("subscriber_assignable")));
		(*apRole) = reinterpret_cast<IMTRole*>(rolePtr.Detach());
		context.Complete();
    return S_OK;
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
}
