// MTPrincipalPolicyWriter.cpp : Implementation of CMTPrincipalPolicyWriter
#include "StdAfx.h"
#include "MTAuthExec.h"
#include "MTPrincipalPolicyWriter.h"



/////////////////////////////////////////////////////////////////////////////
// CMTPrincipalPolicyWriter

STDMETHODIMP CMTPrincipalPolicyWriter::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTPrincipalPolicyWriter
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

HRESULT CMTPrincipalPolicyWriter::Activate()
{
	HRESULT hr = GetObjectContext(&m_spObjectContext);
	if (SUCCEEDED(hr))
		return S_OK;
	return hr;
} 

BOOL CMTPrincipalPolicyWriter::CanBePooled()
{
	return FALSE;
} 

void CMTPrincipalPolicyWriter::Deactivate()
{
	m_spObjectContext.Release();
} 


STDMETHODIMP CMTPrincipalPolicyWriter::CreateCompositeInstance(IMTCompositeCapability *aCap, IMTPrincipalPolicy *aPolicy, long *apID)
{
	HRESULT hr(S_OK);
	MTAutoContext context(m_spObjectContext);
	_variant_t vNull;
	vNull.ChangeType(VT_NULL);
	
	try
	{
		MTAUTHEXECLib::IMTCompositeCapabilityPtr capPtr = aCap;
		MTAUTHEXECLib::IMTPrincipalPolicyPtr policyPtr = aPolicy;
		MTAUTHEXECLib::IMTPrincipalPolicyWriterPtr thisPtr = this;
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		
		rowset->InitializeForStoredProc ("sp_InsertCapabilityInstance");
		//why do we need GUID here?
		//TODO: remove guid
		rowset->AddInputParameterToStoredProc ("aGuid", MTTYPE_VARCHAR, INPUT_PARAM, L"ABCD");
		rowset->AddInputParameterToStoredProc ("aParentInstance", MTTYPE_INTEGER, INPUT_PARAM, vNull);
		rowset->AddInputParameterToStoredProc ("aPolicy", MTTYPE_INTEGER, INPUT_PARAM, policyPtr->ID);
		rowset->AddInputParameterToStoredProc ("aCapType", MTTYPE_INTEGER, INPUT_PARAM, capPtr->CapabilityType->ID);
		rowset->AddOutputParameterToStoredProc ("ap_id_prop", MTTYPE_INTEGER, OUTPUT_PARAM);
		rowset->ExecuteStoredProc();
    int propid = rowset->GetParameterFromStoredProc("ap_id_prop");
    if(propid == -99)
      MT_THROW_COM_ERROR("sp_InsertCapabilityInstance returned -99");
    capPtr->ID = propid;
		(*apID) = capPtr->ID;
		
		//save every atomic instance
		long numAtomics = capPtr->AtomicCapabilities->Count;
		
		for (int i=1; i <= numAtomics; ++i)
		{
			MTAUTHLib::IMTAtomicCapabilityPtr atomicCap = capPtr->AtomicCapabilities->GetItem(i);
			atomicCap->ParentID = capPtr->ID;
			atomicCap->Save((MTAUTHLib::IMTPrincipalPolicy *)aPolicy);
		}
		
		context.Complete();
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
	
	return S_OK;
}

STDMETHODIMP CMTPrincipalPolicyWriter::UpdateCompositeInstance(IMTCompositeCapability *aCap, IMTPrincipalPolicy *aPolicy)
{
	HRESULT hr(S_OK);
	MTAutoContext context(m_spObjectContext);
	_variant_t vNull;
	vNull.ChangeType(VT_NULL);
	
	try
	{
		MTAUTHEXECLib::IMTCompositeCapabilityPtr capPtr = aCap;
		MTAUTHEXECLib::IMTPrincipalPolicyPtr policyPtr = aPolicy;
		MTAUTHEXECLib::IMTPrincipalPolicyWriterPtr thisPtr = this;
		//save every atomic instance
		long numAtomics = capPtr->AtomicCapabilities->Count;
		
		for (int i=1; i <= numAtomics; ++i)
		{
			MTAUTHLib::IMTAtomicCapabilityPtr atomicCap = capPtr->AtomicCapabilities->GetItem(i);
			atomicCap->ParentID = capPtr->ID;
			atomicCap->Save((MTAUTHLib::IMTPrincipalPolicy *)aPolicy);
		}
		
		context.Complete();
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
	
	return S_OK;
}

STDMETHODIMP CMTPrincipalPolicyWriter::CreateAtomicInstance(IMTAtomicCapability *aCap, IMTPrincipalPolicy *aPolicy, long *apID)
{
	HRESULT hr(S_OK);
	MTAutoContext context(m_spObjectContext);
	_variant_t vNull;
	vNull.ChangeType(VT_NULL);
	
	try
	{
		MTAUTHEXECLib::IMTAtomicCapabilityPtr capPtr = aCap;
		MTAUTHEXECLib::IMTPrincipalPolicyPtr policyPtr = aPolicy;
		MTAUTHEXECLib::IMTPrincipalPolicyWriterPtr thisPtr = this;
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		
		rowset->InitializeForStoredProc ("sp_InsertCapabilityInstance");
		//why do we need GUID here?
		//TODO: remove guid
		rowset->AddInputParameterToStoredProc ("aGuid", MTTYPE_VARCHAR, INPUT_PARAM, L"ABCD");
		rowset->AddInputParameterToStoredProc ("aParentInstance", MTTYPE_INTEGER, INPUT_PARAM, capPtr->ParentID);
		rowset->AddInputParameterToStoredProc ("aPolicy", MTTYPE_INTEGER, INPUT_PARAM, policyPtr->ID);
		rowset->AddInputParameterToStoredProc ("aCapType", MTTYPE_INTEGER, INPUT_PARAM, capPtr->CapabilityType->ID);
		rowset->AddOutputParameterToStoredProc ("ap_id_prop", MTTYPE_INTEGER, OUTPUT_PARAM);
		rowset->ExecuteStoredProc();
    int propid = rowset->GetParameterFromStoredProc("ap_id_prop");
    if(propid == -99)
      MT_THROW_COM_ERROR("sp_InsertCapabilityInstance returned -99");
    capPtr->ID = propid;
		(*apID) = capPtr->ID;
		context.Complete();
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
	
	return S_OK;
}

STDMETHODIMP CMTPrincipalPolicyWriter::Create(IMTPrincipalPolicy *aPolicy, long* apID)
{
	HRESULT hr(S_OK);
	MTAutoContext context(m_spObjectContext);
	_variant_t vNull;
	vNull.ChangeType(VT_NULL);

	try
	{
		MTAUTHEXECLib::IMTPrincipalPolicyPtr policyPtr = aPolicy;
		MTAUTHEXECLib::IMTSecurityPrincipalPtr principalPtr = policyPtr->Principal;
		MTAUTHEXECLib::IMTPrincipalPolicyWriterPtr thisPtr = this;
		MTAUTHEXECLib::IMTPrincipalPolicyReaderPtr reader(__uuidof(MTAUTHEXECLib::MTPrincipalPolicyReader));
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);

		rowset->InitializeForStoredProc ("sp_InsertPolicy");
    rowset->AddInputParameterToStoredProc ("aPrincipalColumn", MTTYPE_VARCHAR, INPUT_PARAM, GetPrincipalColumn((MTSecurityPrincipalType)principalPtr->PrincipalType));
    rowset->AddInputParameterToStoredProc ("aPrincipalID", MTTYPE_INTEGER, INPUT_PARAM, principalPtr->ID);
    rowset->AddInputParameterToStoredProc ("aPolicyType", MTTYPE_VARCHAR, INPUT_PARAM, GetStringPolicyType((MTPrincipalPolicyType)policyPtr->PolicyType));
    rowset->AddOutputParameterToStoredProc ("ap_id_prop", MTTYPE_INTEGER, OUTPUT_PARAM);
    rowset->ExecuteStoredProc();
    policyPtr->ID = rowset->GetParameterFromStoredProc("ap_id_prop");

		//if principal type is not Role, then also insert role mappings
		if(principalPtr->PrincipalType != ROLE_PRINCIPAL)
			thisPtr->InsertRoleMappings((MTAUTHEXECLib::IMTPrincipalPolicy*)aPolicy);

		policyPtr->SaveCapabilities();

		(*apID) = policyPtr->ID;
		context.Complete();
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
	
	return S_OK;
}
STDMETHODIMP CMTPrincipalPolicyWriter::Update(IMTSessionContext* apCtxt, IMTPrincipalPolicy *aPolicy)
{
	HRESULT hr(S_OK);
	MTAutoContext context(m_spObjectContext);
	_variant_t vNull;
	vNull.ChangeType(VT_NULL);

	try
	{
		MTAUTHEXECLib::IMTPrincipalPolicyPtr policyPtr = aPolicy;
		MTAUTHEXECLib::IMTSecurityPrincipalPtr principalPtr = policyPtr->Principal;
		MTAUTHEXECLib::IMTPrincipalPolicyWriterPtr thisPtr = this;
		//if principal type is not Role, then update role mappings.
		if(principalPtr->PrincipalType != ROLE_PRINCIPAL)
		{
			thisPtr->DeleteRoleMappings((MTAUTHEXECLib::IMTPrincipalPolicy*)aPolicy);
			thisPtr->InsertRoleMappings((MTAUTHEXECLib::IMTPrincipalPolicy*)aPolicy);
		}
		
		policyPtr->SaveCapabilities();


    // audit csr and subscriber updates
    // role updates are audited in RoleWriter
    AuditEventsLib::MTAuditEvent event = AuditEventsLib::AUDITEVENT_UNKNOWN;

    if (principalPtr->PrincipalType == SUBSCRIBER_ACCOUNT_PRINCIPAL) 
      event= AuditEventsLib::AUDITEVENT_SUBAUTH_UPDATE;
    else if (principalPtr->PrincipalType == CSR_ACCOUNT_PRINCIPAL) 
      event= AuditEventsLib::AUDITEVENT_CSRAUTH_UPDATE;
    
    if (event != AuditEventsLib::AUDITEVENT_UNKNOWN)
    { 
      MTAUTHEXECLib::IMTSessionContextPtr sessionCtxt(apCtxt);
      PCCache::GetAuditor()->FireEvent( event,
                                        sessionCtxt ? sessionCtxt->AccountID : -1,
                                        AuditEventsLib::AUDITENTITY_TYPE_ACCOUNT,
                                        principalPtr->ID,
                                        "");
    }


		//(*apID) = policyPtr->ID;
		context.Complete();
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
	
	return S_OK;
}
STDMETHODIMP CMTPrincipalPolicyWriter::InsertRoleMappings(IMTPrincipalPolicy* aPolicy)
{
	HRESULT hr(S_OK);
	MTAutoContext context(m_spObjectContext);
	long numRoles = 0;
	try
	{
		MTAUTHEXECLib::IMTPrincipalPolicyPtr policyPtr = aPolicy;
		MTAUTHEXECLib::IMTRolePtr rolePtr;
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		numRoles = policyPtr->Roles->Count;
		rowset->Init(CONFIG_DIR);

		for (int i=1; i <= numRoles; ++i)
		{
			
			rolePtr = policyPtr->Roles->GetItem(i);
			ASSERT(rolePtr != NULL);
			rowset->Clear();
			rowset->SetQueryTag("__INSERT_ROLE_MAPPINGS__");
			rowset->AddParam("%%POLICY_ID%%", policyPtr->ID);
			rowset->AddParam("%%ROLE_ID%%", rolePtr->ID);
			rowset->Execute();
		}

		context.Complete();
	
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
	
	return S_OK;
}
STDMETHODIMP CMTPrincipalPolicyWriter::DeleteRoleMappings(IMTPrincipalPolicy* aPolicy)
{
	HRESULT hr(S_OK);
	MTAutoContext context(m_spObjectContext);
	long numRoles = 0;
	try
	{
		MTAUTHEXECLib::IMTPrincipalPolicyPtr policyPtr = aPolicy;
		
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		rowset->SetQueryTag("__DELETE_ROLE_MAPPINGS__");
		rowset->AddParam("%%POLICY_ID%%", policyPtr->ID);
		rowset->Execute();
		context.Complete();
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
	
	return S_OK;
}
char* CMTPrincipalPolicyWriter::GetStringPolicyType(MTPrincipalPolicyType aPolType)
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
char* CMTPrincipalPolicyWriter::GetPrincipalColumn(MTSecurityPrincipalType pt)
{
	switch(pt)
	{
	case ROLE_PRINCIPAL: 
		return "id_role";
	default: 
		return "id_acc";
	}
}

