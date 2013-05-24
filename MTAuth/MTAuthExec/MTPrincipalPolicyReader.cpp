// MTPrincipalPolicyReader.cpp : Implementation of CMTPrincipalPolicyReader
#include "StdAfx.h"
#include "MTAuthExec.h"
#include "MTPrincipalPolicyReader.h"

/////////////////////////////////////////////////////////////////////////////
// CMTPrincipalPolicyReader

STDMETHODIMP CMTPrincipalPolicyReader::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTPrincipalPolicyReader
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

HRESULT CMTPrincipalPolicyReader::Activate()
{
	HRESULT hr = GetObjectContext(&mpObjectContext);
	if (SUCCEEDED(hr))
		return S_OK;
	return hr;
} 

BOOL CMTPrincipalPolicyReader::CanBePooled()
{
	return FALSE;
} 

void CMTPrincipalPolicyReader::Deactivate()
{
	mpObjectContext.Release();
} 


STDMETHODIMP CMTPrincipalPolicyReader::GetAccountRoles(IMTSessionContext* aCtx, long aAccountID, MTPrincipalPolicyType aPolicyType,  VARIANT_BOOL abIncludeOwnedFolders, IMTCollection **apRoles)
{
	MTAutoContext context(mpObjectContext);
  
	HRESULT hr(S_OK);
	_variant_t vRoleName;
	_variant_t vRoleDesc;
	_variant_t vCapProgID;
	_variant_t vCapInstanceID;
	_variant_t vCapParentInstanceID;
	MTAUTHLib::IMTRolePtr role;
	if (!apRoles)
		return E_POINTER;

	*apRoles = NULL;

	try
	{
		MTObjectCollection<MTAUTHLib::IMTRole> coll;
		MTAUTHLib::IMTSecurityPtr security(MTPROGID_MTSECURITY);
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		
		rowset->SetQueryTag("__GET_ROLES_ON_ACCOUNT__");
		rowset->AddParam("%%ID_ACC%%", aAccountID);
		const char* polType = GetStringPolicyType(aPolicyType);
		ASSERT(polType != NULL);
		rowset->AddParam("%%POLICY_TYPE%%", polType);
		rowset->Execute();

		while(rowset->GetRowsetEOF().boolVal == VARIANT_FALSE)
		{
			long roleID = rowset->GetValue("id_role");
			
      role = security->CreateRole(reinterpret_cast<MTAUTHLib::IMTSessionContext*>(aCtx));
			
			vRoleName = rowset->GetValue("tx_name");
			vRoleDesc = rowset->GetValue("tx_desc");
			role->ID = roleID;
			role->Name = (_bstr_t)vRoleName;
			role->Description = (_bstr_t)vRoleDesc;
			coll.Add(role.GetInterfacePtr());
			rowset->MoveNext();
		}
		coll.CopyTo(apRoles);
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	context.Complete();
	return S_OK;
}



STDMETHODIMP CMTPrincipalPolicyReader::GetPrincipalCapabilities(/*[in]*/IMTSessionContext* aCtx, IMTSecurityPrincipal *aPrincipal, MTPrincipalPolicyType aPolicyType, VARIANT_BOOL abIncludeOwnedFolders, IMTCollection **apCaps)
{
	HRESULT hr(S_OK);
	MTAutoContext context(mpObjectContext);
	_variant_t vCapInstanceID;
	_variant_t vCapParentInstanceID;
	_variant_t vCapTypeName;
  _variant_t vPathValue;
  _variant_t vEnumValue;
  _variant_t vDecValue;
  _variant_t vDecOp;
	
	MTAUTHLib::IMTCompositeCapabilityPtr composite;
	MTAUTHLib::IMTAtomicCapabilityPtr atomic;
	map<long, MTAUTHLib::IMTCompositeCapabilityPtr> caps;
	map<long, MTAUTHLib::IMTCompositeCapabilityPtr>::const_iterator capit;
	
  if (!apCaps || !aPrincipal)
		return E_POINTER;

	MTAUTHLib::IMTSecurityPrincipalPtr principal = aPrincipal;
	MTSecurityPrincipalType type = (MTSecurityPrincipalType)principal->PrincipalType;

	*apCaps = NULL;

	try
	{
    MTAUTHLib::IMTSecurityPtr security(__uuidof(MTAUTHLib::MTSecurity));
    MTObjectCollection<MTAUTHLib::IMTCompositeCapability> coll;
		
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		
		rowset->SetQueryTag("__GET_CAPS_ON_PRINCIPAL__");
		rowset->AddParam("%%ID_PRINCIPAL%%", principal->ID);
		const char* polType = GetStringPolicyType(aPolicyType);
		const char* principalColumn = GetPrincipalColumn(type);

		ASSERT(polType != NULL && principalColumn != NULL);
		rowset->AddParam("%%PRINCIPAL_COLUMN%%", principalColumn);
		rowset->AddParam("%%POLICY_TYPE%%", polType);
		rowset->Execute();

		while(rowset->GetRowsetEOF().boolVal == VARIANT_FALSE)
		{
			vCapParentInstanceID = rowset->GetValue("id_parent_cap_instance");
			vCapInstanceID = rowset->GetValue("id_cap_instance");
			vCapTypeName = rowset->GetValue("type_name");
			if(0 == (long)vCapParentInstanceID)
			{
				MTAUTHLib::IMTCompositeCapabilityTypePtr compositeType = 
          security->GetCapabilityTypeByName((_bstr_t)vCapTypeName);
				composite = compositeType->CreateInstance();
				composite->ID = vCapInstanceID;
				caps[(long)vCapInstanceID]  = composite;
			}
			//atomic capability
      else
      {
        capit = caps.find((long)vCapParentInstanceID);
        ASSERT (capit != caps.end());
        
        if(_wcsicmp((wchar_t*)(_bstr_t)vCapTypeName, L"MTEnumTypeCapability") == 0)
        {
          atomic = (*capit).second->GetAtomicEnumCapability();
          ASSERT(atomic != NULL);
          MTAUTHLib::IMTEnumTypeCapabilityPtr etc = atomic;
          ASSERT(etc != NULL);
          vEnumValue = rowset->GetValue("enumtype_capability_value");
          ASSERT(V_VT(&vEnumValue) != VT_NULL);
          etc->SetParameter(vEnumValue);
        }
        else if(_wcsicmp((wchar_t*)(_bstr_t)vCapTypeName, L"MTDecimalCapability") == 0)
        {
          atomic = (*capit).second->GetAtomicDecimalCapability();
          ASSERT(atomic != NULL);
          MTAUTHLib::IMTDecimalCapabilityPtr dc = atomic;
          ASSERT(dc != NULL);
          vDecValue = rowset->GetValue("decimal_capability_value");
          vDecOp = rowset->GetValue("decimal_capability_op");
          ASSERT( V_VT(&vDecValue) != VT_NULL &&
            V_VT(&vDecOp) != VT_NULL );
          dc->SetParameter(vDecValue, 
            (MTAUTHLib::MTOperatorType)StringToOp((_bstr_t)vDecOp));
        }
        else if(_wcsicmp((wchar_t*)(_bstr_t)vCapTypeName, L"MTPathCapability") == 0)
        {
          atomic = (*capit).second->GetAtomicPathCapability();
          ASSERT(atomic != NULL);
          MTAUTHLib::IMTPathCapabilityPtr pc = atomic;
          ASSERT(pc != NULL);
          vPathValue = rowset->GetValue("path_capability_value");
          ASSERT(V_VT(&vPathValue) != VT_NULL);
          MTHierarchyPathWildCard eOp = SINGLE;
          CMTPathRegEx regex((_bstr_t)vPathValue);
          _bstr_t bstrParam = regex.GetCPath();
          eOp = (MTHierarchyPathWildCard)regex.GetPathWildCard();
          pc->SetParameter(bstrParam, (MTAUTHLib::MTHierarchyPathWildCard)eOp);
        }
		else if(_wcsicmp((wchar_t*)(_bstr_t)vCapTypeName, L"MTStringCollectionCapability") == 0)
        {
			          atomic = (*capit).second->GetAtomicCollectionCapability();
          ASSERT(atomic != NULL);
          MTAUTHLib::IMTStringCollectionCapabilityPtr scc = atomic;
          ASSERT(scc != NULL);
		  scc->InitParams();
		} 
        else
          ASSERT(0);
				atomic->ID = vCapInstanceID;
        atomic->ParentID = vCapParentInstanceID;

			}
			rowset->MoveNext();
		}
		//copy temp map into collection and return it
		for(capit = caps.begin(); capit != caps.end(); capit++)
		{
			coll.Add((*capit).second.GetInterfacePtr());
		}

		coll.CopyTo(apCaps);
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	context.Complete();
	return S_OK;
}

STDMETHODIMP CMTPrincipalPolicyReader::GetCapabilitiesAsRowset(/*[in]*/IMTSessionContext* aCtx, long aPolicyID, IMTSQLRowset **apRowset)
{
	HRESULT hr(S_OK);
	MTAutoContext context(mpObjectContext);
	if (!apRowset)
		return E_POINTER;

	*apRowset = NULL;

	try
	{
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		
		rowset->SetQueryTag("__GET_CAPABILITIES_BY_POLICY__");
		rowset->AddParam("%%ID_POLICY%%", aPolicyID);
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

STDMETHODIMP CMTPrincipalPolicyReader::GetRolesAsRowset(/*[in]*/IMTSessionContext* aCtx, long aPolicyID, IMTSQLRowset **apRowset)
{
	HRESULT hr(S_OK);
	MTAutoContext context(mpObjectContext);
	if (!apRowset)
		return E_POINTER;

	*apRowset = NULL;

	try
	{
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		
		rowset->SetQueryTag("__GET_ROLES_BY_POLICY__");
		rowset->AddParam("%%ID_POLICY%%", aPolicyID);
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
STDMETHODIMP CMTPrincipalPolicyReader::GetPolicyID(/*[in]*/IMTSessionContext* aCtx, IMTPrincipalPolicy* aPolicy, long* apID)
{
	HRESULT hr(S_OK);
	MTAutoContext context(mpObjectContext);
	
	MTAUTHLib::IMTPrincipalPolicyPtr policyPtr = aPolicy;
	MTAUTHLib::IMTSecurityPrincipalPtr principal = policyPtr->Principal;
	MTSecurityPrincipalType type = (MTSecurityPrincipalType)principal->PrincipalType;

	(*apID) = -1;

	try
	{
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		const char* polType = GetStringPolicyType((MTPrincipalPolicyType)policyPtr->PolicyType);
		const char* principalColumn = GetPrincipalColumn(type);
		ASSERT(polType != NULL && principalColumn != NULL);
		
		rowset->SetQueryTag("__GET_POLICY__");
		rowset->AddParam("%%POLICY_TYPE%%", polType);
		rowset->AddParam("%%PRINCIPAL_ID%%", principal->ID);
		rowset->AddParam("%%PRINCIPAL_COLUMN%%", principalColumn);
		rowset->Execute();
		if(rowset->GetRowsetEOF().boolVal == FALSE)
			(*apID) =  rowset->GetValue("id_policy");
		context.Complete();
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
	return S_OK;
}





char* CMTPrincipalPolicyReader::GetStringPolicyType(MTPrincipalPolicyType aPolType)
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
char* CMTPrincipalPolicyReader::GetPrincipalColumn(MTSecurityPrincipalType pt)
{
	switch(pt)
	{
	case ROLE_PRINCIPAL: 
		return "id_role";
	default: 
		return "id_acc";
	}
}
