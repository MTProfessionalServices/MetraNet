// MTRoleWriter.cpp : Implementation of CMTRoleWriter
#include "StdAfx.h"
#include "MTAuthExec.h"
#include "MTRoleWriter.h"

class MTBatchRoleWriter : public MTAccountBatchHelper<MTAUTHEXECLib::IMTRoleWriterPtr>
{
public:
  HRESULT PerformSingleOp(long aIndex, long &aFailedAccount);
  MTBatchRoleWriter(MTAUTHEXECLib::IMTRolePtr aRole) : mRole(aRole){}
private:
  MTAUTHEXECLib::IMTRolePtr mRole;


};

HRESULT MTBatchRoleWriter::PerformSingleOp(long aIndex,long &aFailedAccount)
{
  _variant_t vtAcc = mColPtr->GetItem(aIndex);
  if(!(vtAcc.vt == VT_I4 || vtAcc.vt == VT_I2 || vtAcc.vt == VT_DECIMAL)) {
	  MT_THROW_COM_ERROR("Variant is not the correct type");
  }
  long acc = vtAcc;
  aFailedAccount = acc;
  return mControllerClass->AddMember(mRole.GetInterfacePtr(), acc);
}

/////////////////////////////////////////////////////////////////////////////
// CMTRoleWriter

STDMETHODIMP CMTRoleWriter::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTRoleWriter
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

HRESULT CMTRoleWriter::Activate()
{
	HRESULT hr = GetObjectContext(&m_spObjectContext);
	if (SUCCEEDED(hr))
		return S_OK;
	return hr;
} 

BOOL CMTRoleWriter::CanBePooled()
{
	return FALSE;
} 

void CMTRoleWriter::Deactivate()
{
	m_spObjectContext.Release();
} 


STDMETHODIMP CMTRoleWriter::Create(IMTSessionContext* apCtxt, IMTRole *apRole, long *apID)
{
	HRESULT hr(S_OK);
	MTAutoContext context(m_spObjectContext);
	try
	{
		_variant_t vtGUID;
	  if(!MTMiscUtil::CreateGuidAsVariant(vtGUID)) {
		  return E_FAIL;
	  }
    MTAUTHEXECLib::IMTRolePtr rolePtr = apRole;
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);

		rowset->InitializeForStoredProc ("sp_InsertRole");
    rowset->AddInputParameterToStoredProc ("aGuid", MTTYPE_VARBINARY, INPUT_PARAM, vtGUID);
    rowset->AddInputParameterToStoredProc ("aName", MTTYPE_W_VARCHAR, INPUT_PARAM, rolePtr->Name);
    rowset->AddInputParameterToStoredProc ("aDesc", MTTYPE_W_VARCHAR, INPUT_PARAM, rolePtr->Description);
    rowset->AddInputParameterToStoredProc ("aCSRAssignable", MTTYPE_VARCHAR, INPUT_PARAM, MTTypeConvert::BoolToString(rolePtr->CSRAssignable));
    rowset->AddInputParameterToStoredProc ("aSubAssignable", MTTYPE_VARCHAR, INPUT_PARAM, MTTypeConvert::BoolToString(rolePtr->SubscriberAssignable));
    rowset->AddOutputParameterToStoredProc ("ap_id_prop", MTTYPE_INTEGER, OUTPUT_PARAM);
    rowset->ExecuteStoredProc();
    int propid = rowset->GetParameterFromStoredProc("ap_id_prop");
    if(propid == -99)
      MT_THROW_COM_ERROR("sp_InsertRole returned -99");
    (*apID) = propid;

    // audit
    MTAUTHEXECLib::IMTSessionContextPtr sessionCtxt(apCtxt);
    PCCache::GetAuditor()->FireEvent( AuditEventsLib::AUDITEVENT_ROLE_CREATE,
                                      sessionCtxt ? sessionCtxt->AccountID : -1,
                                      AuditEventsLib::AUDITENTITY_TYPE_ROLE,
                                      (*apID),
                                      "Successfully created the role: " + rolePtr->Name);
    rolePtr->ID = (*apID);

 		context.Complete();

	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
	
	return S_OK;
}

STDMETHODIMP CMTRoleWriter::Update(IMTSessionContext* apCtxt, IMTRole *apRole)
{
	HRESULT hr(S_OK);
  MTAutoContext context(m_spObjectContext);
	
	try
	{
		MTAUTHEXECLib::IMTRolePtr rolePtr = apRole;
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
	
		rowset->SetQueryTag("__UPDATE_ROLE__");
		rowset->AddParam("%%ID%%", rolePtr->ID);
		rowset->AddParam("%%NAME%%", rolePtr->Name);
		rowset->AddParam("%%DESC%%", rolePtr->Description);
		rowset->AddParam("%%CSR%%", MTTypeConvert::BoolToString(rolePtr->CSRAssignable));
		rowset->AddParam("%%SUBSCRIBER%%", MTTypeConvert::BoolToString(rolePtr->SubscriberAssignable));
		rowset->Execute();

    // audit
    MTAUTHEXECLib::IMTSessionContextPtr sessionCtxt(apCtxt);
    PCCache::GetAuditor()->FireEvent( AuditEventsLib::AUDITEVENT_ROLE_UPDATE,
                                      sessionCtxt ? sessionCtxt->AccountID : -1,
                                      AuditEventsLib::AUDITENTITY_TYPE_ROLE,
                                      rolePtr->ID,
                                      "Successfully updated the role: " + rolePtr->Name);

    
    context.Complete();
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
	
	return S_OK;
}

STDMETHODIMP CMTRoleWriter::Remove(IMTSessionContext* apCtxt, IMTRole *aRole, IMTPrincipalPolicy* aPolicy)
{
	
  HRESULT hr(S_OK);
  MTAutoContext context(m_spObjectContext);

  try
  {
    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(CONFIG_DIR);

    MTAUTHEXECLib::IMTPrincipalPolicyPtr policyPtr = aPolicy;
    MTAUTHEXECLib::IMTRolePtr rolePtr = aRole;
    MTAUTHEXECLib::IMTCompositeCapabilityPtr capPtr;

   
    //2. remove all capabilities associated with this role
    
		int numCaps = policyPtr->Capabilities->Count;

    for (int i=1; i <= numCaps; ++i)
		{
			
			capPtr = policyPtr->Capabilities->GetItem(i);
			ASSERT(capPtr != NULL);
			capPtr->Remove(policyPtr);
		}
    
    //3. Remove policy record
    //4. Remove t_role entry
		rowset->SetQueryTag("__REMOVE_ROLE__");
		rowset->AddParam("%%ID%%", rolePtr->ID);
		rowset->Execute();

    // audit
    MTAUTHEXECLib::IMTSessionContextPtr sessionCtxt(apCtxt);
    PCCache::GetAuditor()->FireEvent( AuditEventsLib::AUDITEVENT_ROLE_DELETE,
                                      sessionCtxt ? sessionCtxt->AccountID : -1,
                                      AuditEventsLib::AUDITENTITY_TYPE_ROLE,
                                      rolePtr->ID,
                                      "Successfully deleted the role: " + rolePtr->Name);

		context.Complete();
  }
  catch(_com_error& e)
  {
    return ReturnComError(e);
  }

	return S_OK;
}

STDMETHODIMP CMTRoleWriter::AddMemberBatch(IMTCollection* pCol,
			IMTProgress* pProgress,
			IMTRole* aRole,
			IMTRowSet** ppRowset)
{
	try 
  {
	  MTBatchRoleWriter aWriter(aRole);
    aWriter.Init(m_spObjectContext,MTAUTHEXECLib::IMTRoleWriterPtr(this));
    *ppRowset = reinterpret_cast<IMTRowSet*>(aWriter.PerformBatchOperation(pCol,pProgress).Detach());

	}
	catch(_com_error& err) 
  {
		return ReturnComError(err);
	}
	return S_OK;
}

STDMETHODIMP CMTRoleWriter::AddMember(IMTRole* aRole, long aNewMember)
{
	try 
  {
	  MTAutoContext ctx(m_spObjectContext);
	  long status = 0;
    MTAUTHEXECLib::IMTRolePtr role = aRole;
	  ROWSETLib::IMTSQLRowsetPtr rs(MTPROGID_SQLROWSET);
		rs->Init(CONFIG_DIR);
	  rs->InitializeForStoredProc("AddMemberToRole");
	  rs->AddInputParameterToStoredProc("aRoleID",MTTYPE_INTEGER, INPUT_PARAM, role->ID);
	  rs->AddInputParameterToStoredProc("aAccountID",MTTYPE_INTEGER, INPUT_PARAM, aNewMember);
    rs->AddOutputParameterToStoredProc("status", MTTYPE_DECIMAL, OUTPUT_PARAM);
	  rs->ExecuteStoredProc();
	  status = rs->GetParameterFromStoredProc("status");

		if(status != 1) 
    {
      PCCache::GetAuditor()->FireFailureEvent( AuditEventsLib::AUDITEVENT_ROLE_UPDATE_DENIED,
                                      aNewMember,
                                      AuditEventsLib::AUDITENTITY_TYPE_ROLE,
                                      role->ID,
                                      "Failed to add member to the role '" +  role->Name + "'");                                  
		  	MT_THROW_COM_ERROR(status, (char*)role->Name);

		}
    else
    {
        PCCache::GetAuditor()->FireEvent( AuditEventsLib::AUDITEVENT_ROLE_UPDATE,
                                      aNewMember,
                                      AuditEventsLib::AUDITENTITY_TYPE_ROLE,
                                      role->ID,
                                      "Added the member to the role '" + role->Name + "' successfully");                                    
    }
  	ctx.Complete();

	}
	catch(_com_error& err) 
  {
		return ReturnComError(err);  
	}

	return S_OK;
}

STDMETHODIMP CMTRoleWriter::RemoveMember(IMTRole* aRole, long aMember)
{
	try 
  {
	  MTAutoContext ctx(m_spObjectContext);
	  long status = 0;
    MTAUTHEXECLib::IMTRolePtr role = aRole;
	  ROWSETLib::IMTSQLRowsetPtr rs(MTPROGID_SQLROWSET);
		rs->Init(CONFIG_DIR);
	  rs->InitializeForStoredProc("RemoveMemberFromRole");
	  rs->AddInputParameterToStoredProc("aRoleID",MTTYPE_INTEGER, INPUT_PARAM, role->ID);
	  rs->AddInputParameterToStoredProc("aAccountID",MTTYPE_INTEGER, INPUT_PARAM, aMember);
    rs->AddOutputParameterToStoredProc("status", MTTYPE_DECIMAL, OUTPUT_PARAM);
	  rs->ExecuteStoredProc();
	  status = rs->GetParameterFromStoredProc("status");

		if(status != 1) 
    {
			MT_THROW_COM_ERROR(status);
		}

  	ctx.Complete();

	}
	catch(_com_error& err) 
  {
		return ReturnComError(err);
	}

	return S_OK;
}

STDMETHODIMP CMTRoleWriter::CreateOrUpdate(IMTRole *aRole)
{
	try
	{
		HRESULT hr(S_OK);
    MTAutoContext ctx(m_spObjectContext);
    bool bNameCollision = false;
    MTAUTHLib::IMTRolePtr rolePtr = aRole;
    MTAUTHLib::IMTSecurityPrincipalPtr prPtr = rolePtr;
    ASSERT(prPtr != NULL);

		MTAUTHEXECLib::IMTRoleReaderPtr reader(__uuidof(MTAUTHEXECLib::MTRoleReader));
		MTAUTHEXECLib::IMTRoleWriterPtr writer = this;

    //do not allow saving "orphan roles"
    if(rolePtr->CSRAssignable == VARIANT_FALSE &&
      rolePtr->SubscriberAssignable == VARIANT_FALSE)
    {
      MT_THROW_COM_ERROR(MTAUTH_ORPHAN_ROLE, (char*)rolePtr->Name);
    }
		
    ROWSETLib::IMTSQLRowsetPtr rs = reader->FindRecordsByNameAsRowset(rolePtr->Name);
			
		if (rolePtr->ID == -1)
		{
			if(rs->GetRowsetEOF().boolVal == FALSE)
			{
				MT_THROW_COM_ERROR(MTAUTH_ROLE_DUPLICATE_NAME, (char*)rolePtr->Name);
			}
      
		}
    
		//do not allow updates if there are actors in this role
		if(rolePtr->ID > 0)
		{
      if(rs->GetRecordCount() == 0)
        MT_THROW_COM_ERROR(MTAUTH_ROLE_NO_ENTRIES_FOUND, (char*)rolePtr->Name);
      if(rs->GetRecordCount() > 1)
        MT_THROW_COM_ERROR(MTAUTH_ROLE_MULTIPLE_ENTRIES_FOUND, (char*)rolePtr->Name);

			if( reader->HasMembers(rolePtr->Name) == VARIANT_TRUE ||
          reader->HasCapabilities(rolePtr->Name) == VARIANT_TRUE)
			{
				VARIANT_BOOL bSubAssignable = 
            MTTypeConvert::StringToBool(MTMiscUtil::GetString(rs->GetValue("subscriber_assignable")));
        VARIANT_BOOL bCSRAssignable = 
            MTTypeConvert::StringToBool(MTMiscUtil::GetString(rs->GetValue("csr_assignable")));
        if( bSubAssignable != rolePtr->SubscriberAssignable ||
            bCSRAssignable != rolePtr->CSRAssignable)
          MT_THROW_COM_ERROR(MTAUTH_ROLE_CAN_NOT_UPDATE_FLAGS, (char*)rolePtr->Name);
			}
		  writer->Update((MTAUTHEXECLib::IMTSessionContext*) rolePtr->SessionContext.GetInterfacePtr(),
                     (MTAUTHEXECLib::IMTRole *)rolePtr.GetInterfacePtr());
		}
		else
      writer->Create((MTAUTHEXECLib::IMTSessionContext*) prPtr->SessionContext.GetInterfacePtr(),
                                   (MTAUTHEXECLib::IMTRole *)prPtr.GetInterfacePtr());
    rolePtr->SaveBase();
    ctx.Complete();
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	return S_OK;
}
