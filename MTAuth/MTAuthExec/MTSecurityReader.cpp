// MTSecurityReader.cpp : Implementation of CMTSecurityReader
#include "StdAfx.h"
#include "MTAuthExec.h"
#include "MTSecurityReader.h"

/////////////////////////////////////////////////////////////////////////////
// CMTSecurityReader

STDMETHODIMP CMTSecurityReader::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTSecurityReader
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

HRESULT CMTSecurityReader::Activate()
{
	HRESULT hr = GetObjectContext(&m_spObjectContext);
	if (SUCCEEDED(hr))
		return S_OK;
	return hr;
} 

BOOL CMTSecurityReader::CanBePooled()
{
	return FALSE;
} 

void CMTSecurityReader::Deactivate()
{
	m_spObjectContext.Release();
} 

STDMETHODIMP CMTSecurityReader::GetRoleByName(IMTSessionContext *aCtx, BSTR aRoleName, IMTRole **apRole)
{
	
	HRESULT hr(S_OK);
	MTAutoContext context(m_spObjectContext);
	MTAUTHEXECLib::IMTSecurityReaderPtr thisPtr = this;
	
	if (!apRole)
		return E_POINTER;
	
	*apRole = NULL;
	
	try
	{
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		
		rowset->SetQueryTag("__GET_ROLE_ID_BY_NAME__");
		rowset->AddParam("%%NAME%%", aRoleName);
		rowset->Execute();
		
		if(rowset->GetRowsetEOF().boolVal == VARIANT_TRUE)
		{
			MT_THROW_COM_ERROR(MTAUTH_ROLE_NOT_FOUND, (char*)_bstr_t(aRoleName));
		}
		long lRoleID = rowset->GetValue("id_role");
		MTAUTHLib::IMTRolePtr outPtr = thisPtr->GetRoleByID((MTAUTHEXECLib::IMTSessionContext*)aCtx, lRoleID);
    (*apRole) = (IMTRole*)outPtr.Detach();
		context.Complete();
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
	
	return S_OK;
}

STDMETHODIMP CMTSecurityReader::GetRoleByID(IMTSessionContext *aCtx, long aRoleID, IMTRole **apRole)
{
	HRESULT hr(S_OK);
	MTAutoContext context(m_spObjectContext);
	MTAUTHEXECLib::IMTSecurityReaderPtr thisPtr = this;
	
	if (!apRole)
		return E_POINTER;
	
	*apRole = NULL;
	
	try
	{
		MTAUTHLib::IMTSecurityPtr security(MTPROGID_MTSECURITY);
    MTAUTHLib::IMTRolePtr rolePtr = 
      security->CreateRole(reinterpret_cast<MTAUTHLib::IMTSessionContext*>(aCtx));
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

STDMETHODIMP CMTSecurityReader::GetAllRolesAsRowset(IMTSessionContext *aCtx, IMTSQLRowset **apRowset)
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
		
		rowset->SetQueryTag("__GET_ALL_ROLES__");
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

STDMETHODIMP CMTSecurityReader::GetCapabilityTypesAsRowset(IMTSessionContext *aCtx, IMTSQLRowset **apRowset)
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
		
		rowset->SetQueryTag("__GET_COMPOSITE_CAP_TYPES__");
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

STDMETHODIMP CMTSecurityReader::GetAvailableCapabilityTypesAsRowset(IMTSessionContext *aCtx, IMTSecurityPrincipal *aPrincipal, IMTSQLRowset **apRowset)
{
  HRESULT hr(S_OK);
	MTAutoContext context(m_spObjectContext);
	if (!apRowset)
		return E_POINTER;
  

	*apRowset = NULL;

  char flagClause[1024];
  _bstr_t bstrPrincipalColumn;
  _variant_t vPrincipalID;

	try
	{
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		
    //1. query for principal type
    MTAUTHLib::IMTRolePtr rolePtr = aPrincipal;
    
    if(rolePtr != NULL)
    {
      vPrincipalID = rolePtr->ID;
      bstrPrincipalColumn = "id_role";
      _bstr_t bstrSubClause;
      _bstr_t bstrCSRClause;
      VARIANT_BOOL bCSRAssignable = rolePtr->CSRAssignable;
      VARIANT_BOOL bSubscriberAssignable = rolePtr->SubscriberAssignable;
      if(bCSRAssignable == VARIANT_TRUE && bSubscriberAssignable == VARIANT_TRUE)
        sprintf(flagClause, " csr_assignable = N'Y' AND subscriber_assignable = N'Y'");
      else if (bCSRAssignable == VARIANT_TRUE)
        sprintf(flagClause, " csr_assignable = N'Y'");
      else if(bSubscriberAssignable == VARIANT_TRUE)
        sprintf(flagClause, " subscriber_assignable = N'Y'");
      else
        MT_THROW_COM_ERROR(MTAUTH_ORPHAN_ROLE, (char*)rolePtr->Name);
    }
    else
    {
      bstrPrincipalColumn = "id_acc";
      MTAUTHLib::IMTYAACPtr accPtr = aPrincipal;
      ASSERT(accPtr != NULL);
      
      MTSecurityPrincipalType prType = (MTSecurityPrincipalType)accPtr->PrincipalType;
      vPrincipalID = accPtr->ID;
      
      //3. If it's YAAC, then get account types and only retrieve roles that are assignable to
      //    this type
      _bstr_t bstrFlagCondition;
      switch(prType)
      {
        case SUBSCRIBER_ACCOUNT_PRINCIPAL:
        case FOLDER_ACCOUNT_PRINCIPAL:
          bstrFlagCondition = "subscriber_assignable";
          break;
        case CSR_ACCOUNT_PRINCIPAL:
          bstrFlagCondition = "csr_assignable";
          break;
        default:
        ASSERT(!"Why are we here?");
      }
      sprintf(flagClause, " %s = N'Y'", (char*)bstrFlagCondition);

    }
    
		rowset->SetQueryTag("__GET_AVAILABLE_CAP_TYPES__");
    rowset->AddParam("%%PRINCIPAL_COLUMN%%", bstrPrincipalColumn);
    rowset->AddParam("%%PRINCIPAL_ID%%", vPrincipalID);
    rowset->AddParam("%%FLAG_CLAUSE%%", _variant_t(flagClause), VARIANT_TRUE );
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

STDMETHODIMP CMTSecurityReader::GetAvailableRolesAsRowset(IMTSessionContext *aCtx, IMTSecurityPrincipal *aPrincipal,MTPrincipalPolicyType aPolicyType, IMTSQLRowset **apRowset)
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
		
    //1. query for principal type
    MTAUTHLib::IMTRolePtr rolePtr = aPrincipal;
    //2. if it's role, return empty rowset (adding roles to roles is not currently supported)
    if(rolePtr != NULL)
    {
      (*apRowset) = (IMTSQLRowset*)rowset.Detach();
      return S_OK;
    }

    MTAUTHLib::IMTYAACPtr accPtr = aPrincipal;
    ASSERT(accPtr != NULL);
    
    MTSecurityPrincipalType prType = (MTSecurityPrincipalType)accPtr->PrincipalType;
    long prID = accPtr->ID;

    //3. If it's YAAC, then get account types and only retrieve roles that are assignable to
    //    this type
    _bstr_t bstrFlagColumn;
    switch(prType)
    {
    case SUBSCRIBER_ACCOUNT_PRINCIPAL:
    case FOLDER_ACCOUNT_PRINCIPAL:
      bstrFlagColumn = "subscriber_assignable";
      break;
    case CSR_ACCOUNT_PRINCIPAL:
      bstrFlagColumn = "csr_assignable";
      break;
    default:
      ASSERT(!"Why are we here?");
    }

    
		rowset->SetQueryTag("__GET_AVAILABLE_ROLES__");
    rowset->AddParam("%%FLAG_COLUMN%%", bstrFlagColumn);
    rowset->AddParam("%%ID%%", accPtr->ID);
    rowset->AddParam("%%POLICY_TYPE%%",GetStringPolicyType(aPolicyType));
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
char* CMTSecurityReader::GetStringPolicyType(MTPrincipalPolicyType aPolType)
{
	switch(aPolType)
	{
	case DEFAULT_POLICY: 
		return "D";
	case ACTIVE_POLICY: 
		return "A";
	default: 
		return NULL;
	}
}