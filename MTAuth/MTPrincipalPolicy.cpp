/**************************************************************************
* Copyright 1997-2002 by MetraTech
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
* REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
* OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
* INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
* RIGHTS.
*
* Title to copyright in this software and any associated
* documentation shall at all times remain with MetraTech, and USER
* agrees to preserve the same.
*
***************************************************************************/

#include "StdAfx.h"
#include "MTAuth.h"
#include "MTPrincipalPolicy.h"
#include "MTRole.h"
#include "PCCache.h"


/////////////////////////////////////////////////////////////////////////////
// CMTPrincipalPolicy

STDMETHODIMP CMTPrincipalPolicy::InterfaceSupportsErrorInfo(REFIID riid)
{
  static const IID* arr[] = 
  {
    &IID_IMTPrincipalPolicy
  };
  for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
  {
    if (InlineIsEqualGUID(*arr[i],riid))
      return S_OK;
  }
  return S_FALSE;
}



STDMETHODIMP CMTPrincipalPolicy::get_Name(BSTR *pVal)
{
  return E_NOTIMPL;
}

STDMETHODIMP CMTPrincipalPolicy::put_Name(BSTR newVal)
{
  return E_NOTIMPL;
}

STDMETHODIMP CMTPrincipalPolicy::get_Description(BSTR *pVal)
{
  return E_NOTIMPL;
}

STDMETHODIMP CMTPrincipalPolicy::put_Description(BSTR newVal)
{
  return E_NOTIMPL;
}

STDMETHODIMP CMTPrincipalPolicy::get_Principal(IMTSecurityPrincipal **pVal)
{
  if(pVal == NULL)
    return E_POINTER;
  (*pVal) = NULL;
  MTAUTHLib::IMTSecurityPrincipalPtr outPtr = mPrincipal;
  (*pVal) = (IMTSecurityPrincipal*)outPtr.Detach();
  return S_OK;
}

STDMETHODIMP CMTPrincipalPolicy::put_Principal(IMTSecurityPrincipal *pVal)
{
  if(pVal == NULL)
    return E_POINTER;
  mPrincipal = pVal;
  return S_OK;
}


STDMETHODIMP CMTPrincipalPolicy::get_ID(long *pVal)
{
  (*pVal) = mID;

  return S_OK;
}

STDMETHODIMP CMTPrincipalPolicy::put_ID(long newVal)
{
  mID = newVal;
  return S_OK;
}

STDMETHODIMP CMTPrincipalPolicy::GetActive(IMTSessionContext *aCtx, IMTSecurityPrincipal *aPrincipal, IMTPrincipalPolicy **apPolicy)
{
  //1. Check access depending on what aPrincipal is:
  // role, subscriber, CSr or folder
  HRESULT hr(S_OK);

  try
  {
    CheckPrincipalAuth2Auth(aCtx, aPrincipal, "READ");
    hr = InternalGet(aPrincipal, ACTIVE_POLICY, apPolicy);
    if(FAILED(hr))
      MT_THROW_COM_ERROR(hr);
  }
  catch(_com_error& e)
  {
    return LogAndReturnAuthError(e);
  }

  return S_OK;
}

STDMETHODIMP CMTPrincipalPolicy::InternalGet(IMTSecurityPrincipal *aPrincipal, 
  MTPrincipalPolicyType aPolicyType, 
  IMTPrincipalPolicy **apPolicy)
{
  try
  {
    CComObject<CMTPrincipalPolicy> * pInternalPolicy;
    CComObject<CMTPrincipalPolicy>::CreateInstance(&pInternalPolicy);
    MTAUTHLib::IMTPrincipalPolicyPtr outPtr;
    HRESULT hr =  pInternalPolicy->QueryInterface(IID_IMTPrincipalPolicy,
      reinterpret_cast<void**>(&outPtr));
    outPtr->PolicyType = (MTAUTHLib::MTPrincipalPolicyType)aPolicyType;
    outPtr->Principal = (MTAUTHLib::IMTSecurityPrincipal*)aPrincipal;
    pInternalPolicy->Initialize();
    (*apPolicy) = (IMTPrincipalPolicy*)outPtr.Detach();
  }
  catch(_com_error& e)
  {
    return LogAndReturnAuthError(e);
  }

  return S_OK;
}

STDMETHODIMP CMTPrincipalPolicy::GetDefault(IMTSessionContext *aCtx, IMTSecurityPrincipal *aPrincipal, IMTPrincipalPolicy **apPolicy)
{


  try
  {
    HRESULT hr(S_OK);
    //1. Check access depending on what aPrincipal is:
    //	role, subscriber, CSR 
    CheckPrincipalAuth2Auth(aCtx, aPrincipal, "READ");

    //2. return NULL if principal is anything but a folder
    MTAUTHLib::IMTYAACPtr accPtr = aPrincipal;
    //commented out in 5.0.  Folder no longer determines whether an account can have descendents. No harm
    //in allowing the account to have a default security policy.  Worst that could happen is it won't be used.
    //We could have looked at the type of the account and found if this type could have any descendents underneath.
    //Maybe, we should do that.
    /*if(accPtr != NULL)
    {
    if(accPtr->IsFolder == VARIANT_FALSE)
    {
    LogAuthWarning("Default security policy can only be associated with folders (CMTPrincipalPolicy::GetDefault)");
    (*apPolicy) = NULL;
    return S_OK;
    }
    }*/
    hr = InternalGet(aPrincipal, DEFAULT_POLICY, apPolicy);
    if(FAILED(hr))
      MT_THROW_COM_ERROR(hr);
  }
  catch(_com_error& e)
  {
    return LogAndReturnAuthError(e);
  }

  return S_OK;
}

STDMETHODIMP CMTPrincipalPolicy::GetAll(IMTSessionContext *aCtx, IMTSecurityPrincipal *aPrincipal, IMTCollection **apPolicy)
{
  return E_NOTIMPL;
}

STDMETHODIMP CMTPrincipalPolicy::get_PolicyType(MTPrincipalPolicyType *pVal)
{
  (*pVal) = mPolicyType;
  return S_OK;
}

STDMETHODIMP CMTPrincipalPolicy::put_PolicyType(MTPrincipalPolicyType newVal)
{
  mPolicyType = newVal;

  return S_OK;
}

STDMETHODIMP CMTPrincipalPolicy::AddCapability(IMTCompositeCapability *aCap)
{
  //Check business rules
  //rule 1: if someone forcefully tries to add role which
  //is not assignable to account's type return error
  try
  {
    MTAUTHLib::IMTCompositeCapabilityPtr cap = aCap;

    switch((MTSecurityPrincipalType)mPrincipal->PrincipalType)
    {
    case SUBSCRIBER_ACCOUNT_PRINCIPAL:
      if(cap->CapabilityType->SubscriberAssignable == VARIANT_FALSE)
        MT_THROW_COM_ERROR(MTAUTH_CAPABILITY_CAN_NOT_BE_ASSIGNED_TO_SUBSCRIBER, (char*)cap->CapabilityType->Name);
      break;
    case CSR_ACCOUNT_PRINCIPAL:
      if(cap->CapabilityType->CSRAssignable == VARIANT_FALSE)
        MT_THROW_COM_ERROR(MTAUTH_CAPABILITY_CAN_NOT_BE_ASSIGNED_TO_CSR, (char*)cap->CapabilityType->Name);
      break;
    case ROLE_PRINCIPAL:
      {
        //reject IMTManageAH capability if this role is
        //subscriber assignable
        MTAUTHLib::IMTRolePtr r = mPrincipal;
        ASSERT (r != NULL);
        if(r->SubscriberAssignable == VARIANT_TRUE)
        {
          MTAUTHCAPABILITIESLib::IMTManageAHCapabilityPtr mah = cap;
          if(mah != NULL)
            MT_THROW_COM_ERROR(MTAUTH_MANAGE_AH_CAN_NOT_BE_ASSIGNED_TO_ROLE, (char*)r->Name);
        }
        VARIANT_BOOL bCapSubAssignable = cap->CapabilityType->SubscriberAssignable;
        VARIANT_BOOL bCapCSRAssignable = cap->CapabilityType->CSRAssignable;
        VARIANT_BOOL bRoleSubAssignable = r->SubscriberAssignable;
        VARIANT_BOOL bRoleCSRAssignable = r->CSRAssignable;
        _bstr_t bstrTypeName = cap->CapabilityType->Name;
        if(bCapSubAssignable == VARIANT_FALSE && bRoleSubAssignable == VARIANT_TRUE)
          MT_THROW_COM_ERROR(MTAUTH_ROLE_SUB_ASSIGNABLE_FLAG_MISMATCH, (char*)r->Name, (char*)cap->CapabilityType->Name);
        if(bCapCSRAssignable == VARIANT_FALSE && bRoleCSRAssignable == VARIANT_TRUE)
          MT_THROW_COM_ERROR(MTAUTH_ROLE_CSR_ASSIGNABLE_FLAG_MISMATCH, (char*)r->Name, (char*)cap->CapabilityType->Name);
        break;
      }

    }
    mCaps.Add(aCap);
  }
  catch(_com_error& e)
  {
    return LogAndReturnAuthError(e);
  }
  return S_OK;
}

STDMETHODIMP CMTPrincipalPolicy::AddRole(IMTRole *aRole)
{
  HRESULT hr(S_OK);
  //has to be idempotent

  long count;    

  MTAUTHLib::IMTRolePtr newRole = aRole;
  MTAUTHLib::IMTRolePtr rolePtr;
  MTAUTHLib::IMTSecurityPrincipalPtr thisPtr = this;
  MTAUTHLib::IMTPrincipalPolicyPtr polPtr;   

  MTAUTHEXECLib::IMTSessionContextPtr sessionCtxt;

  MTYAACLib::IMTYAACPtr acc = mPrincipal;

  try
  { 

    CMTRole* pInternalRole;
    HRESULT hr = newRole.QueryInterface(IID_NULL,(void**)&pInternalRole);
    if(FAILED(hr)) 
    {
      MT_THROW_COM_ERROR(hr);
    }
    pInternalRole->InternalGetActivePolicy((IMTPrincipalPolicy**)&polPtr);
    ASSERT(polPtr != NULL);

    sessionCtxt = (MTAUTHEXECLib::IMTSessionContext*) polPtr->Principal->SessionContext.GetInterfacePtr();
    //check business rules:

    //rule 1: roles can not be added to roles
    if(mPrincipal->PrincipalType == ROLE_PRINCIPAL)
      MT_THROW_COM_ERROR(MTAUTH_ADDING_ROLE_TO_ROLE_NOT_SUPPORTED);

    //rule 2: if someone forcefully (not through MAM) tries to add role which
    //is not assignable to account's type return error
    switch((MTSecurityPrincipalType)mPrincipal->PrincipalType)
    {
    case SUBSCRIBER_ACCOUNT_PRINCIPAL:
      if(newRole->SubscriberAssignable == VARIANT_FALSE)
        MT_THROW_COM_ERROR(MTAUTH_ROLE_CAN_NOT_BE_ASSIGNED_TO_SUBSCRIBER, (char*)newRole->Name);              
      break;
    case CSR_ACCOUNT_PRINCIPAL:
      if(newRole->CSRAssignable == VARIANT_FALSE)        
        MT_THROW_COM_ERROR(MTAUTH_ROLE_CAN_NOT_BE_ASSIGNED_TO_CSR, (char*)newRole->Name);
      break;
    }

    mRoles.Count(&count);
    for (int i = 1; i<= count; ++i)
    {
      mRoles.Item(i, (IMTRole**)&rolePtr);
      if(rolePtr->ID == newRole->ID)
        return S_OK;
    }

    mRoles.Add(aRole);      
    PCCache::GetAuditor()->FireEvent(AuditEventsLib::AUDITEVENT_ROLE_UPDATE,
      sessionCtxt ? sessionCtxt->AccountID : -1,
      AuditEventsLib::AUDITENTITY_TYPE_ROLE,
      newRole->ID,
      " Role '" + newRole->Name + "' has been assigned to a Subscriber '" + ((acc != NULL) ? (" '" + acc->AccountName + "(" + (_bstr_t)acc->AccountID + ")'") : "")); 
  }
  catch(_com_error& e)
  {     

    if(newRole->SubscriberAssignable == VARIANT_FALSE)
    {
      PCCache::GetAuditor()->FireEvent(AuditEventsLib::AUDITEVENT_ROLE_UPDATE_DENIED,
        sessionCtxt ? sessionCtxt->AccountID : -1,
        AuditEventsLib::AUDITENTITY_TYPE_ROLE,
        newRole->ID,
        " Role '" + newRole->Name + "' cannot be assigned to a Subscriber" + ((acc != NULL) ? (" '" + acc->AccountName + "(" + (_bstr_t)acc->AccountID + ")'") : "")); 
    }

    if(newRole->CSRAssignable == VARIANT_FALSE)        
    {
      PCCache::GetAuditor()->FireEvent( AuditEventsLib::AUDITEVENT_ROLE_UPDATE_DENIED,
        sessionCtxt ? sessionCtxt->AccountID : -1,
        AuditEventsLib::AUDITENTITY_TYPE_ROLE,
        newRole->ID,
        " Role '" + newRole->Name + "' cannot be assigned to a csr" + ((acc != NULL) ? (" '" + acc->AccountName + "(" + (_bstr_t)acc->AccountID + ")'") : ""));  
    }



    return LogAndReturnAuthError(e);
  }
  return S_OK;
}

STDMETHODIMP CMTPrincipalPolicy::RemoveCapability(long aCapInstanceID)
{
  long count;
  mCaps = mAllCaps;
  mCaps.Count(&count);
  MTAUTHLib::IMTCompositeCapabilityPtr capPtr;
  try
  {
    for (int i = 1; i<= count; ++i)
    {
      mCaps.Item(i, (IMTCompositeCapability**)&capPtr);
      if(capPtr->ID == aCapInstanceID)
      {
        mDeletedCaps.Add((IMTCompositeCapability*)capPtr.GetInterfacePtr());
        mCaps.Remove(i);
        return S_OK;
      }
    }
  }
  catch(_com_error& e)
  {
    return LogAndReturnAuthError(e);
  }

  return S_OK;
}

STDMETHODIMP CMTPrincipalPolicy::RemoveCapabilityAt(long aCollectionPosition)
{
  try
  {
    MTAUTHLib::IMTCompositeCapabilityPtr capPtr;
    if(aCollectionPosition < 1)
      MT_THROW_COM_ERROR(DISP_E_BADINDEX);
    mCaps.Item(aCollectionPosition, (IMTCompositeCapability**)&capPtr);
    if (capPtr != NULL)
    {
      if(capPtr->ID > 0)
        mDeletedCaps.Add((IMTCompositeCapability*)capPtr.GetInterfacePtr());
      mCaps.Remove(aCollectionPosition);
    }
    return S_OK;
  }
  catch(_com_error& e)
  {
    return LogAndReturnAuthError(e);
  }

  return S_OK;
}
STDMETHODIMP CMTPrincipalPolicy::RemoveAllCapabilities()
{
  long count;
  mCaps = mAllCaps;
  mCaps.Count(&count);
  MTAUTHLib::IMTCompositeCapabilityPtr capPtr;
  try
  {

    for (int i = 1; i<= count; ++i)
    {
      mCaps.Item(i, (IMTCompositeCapability**)&capPtr);
      mDeletedCaps.Add((IMTCompositeCapability*)capPtr.GetInterfacePtr());

    }

    mCaps.Clear();
  }
  catch(_com_error& e)
  {
    return LogAndReturnAuthError(e);
  }

  return S_OK;
}

STDMETHODIMP CMTPrincipalPolicy::RemoveAllRoles()
{
  mRoles.Clear();
  return S_OK;
}


STDMETHODIMP CMTPrincipalPolicy::RemoveRole(long aRoleID)
{
  long count;
  mRoles.Count(&count);
  MTAUTHLib::IMTRolePtr rolePtr;

  for (int i = 1; i<= count; ++i)
  {
    mRoles.Item(i, (IMTRole**)&rolePtr);
    if(rolePtr->ID == aRoleID)
    {
      mRoles.Remove(i);
      return S_OK;
    }
  }

  return S_OK;
}

STDMETHODIMP CMTPrincipalPolicy::RemoveCapabilitiesOfType(long aTypeID)
{
  long count;
  MTAUTHLib::IMTCompositeCapabilityPtr capPtr;

  try
  {
    mDeletedCaps.Clear();
    mCaps = mAllCaps;
    mCaps.Count(&count);

    for (int i = count; i > 0; --i)
    {
      mCaps.Item(i, (IMTCompositeCapability**)&capPtr);
      if(capPtr->CapabilityType->ID == aTypeID)
      {
        mDeletedCaps.Add((IMTCompositeCapability*)capPtr.GetInterfacePtr());
        mCaps.Remove(i);
      }
    }
  }
  catch(_com_error& e)
  {
    return LogAndReturnAuthError(e);
  }

  return S_OK;
}

STDMETHODIMP CMTPrincipalPolicy::GetCapabilitiesAsRowset(IMTSQLRowset **apRowset)
{
  if (!apRowset)
    return E_POINTER;
  *apRowset = NULL;

  MTAUTHLib::IMTPrincipalPolicyPtr thisPtr = this;
  try
  {
    MTAUTHEXECLib::IMTPrincipalPolicyReaderPtr reader(__uuidof(MTAUTHEXECLib::MTPrincipalPolicyReader));
    (*apRowset) = (IMTSQLRowset*)reader->GetCapabilitiesAsRowset((MTAUTHEXECLib::IMTSessionContext*)thisPtr->Principal->SessionContext.GetInterfacePtr(), thisPtr->ID).Detach();
  }
  catch(_com_error& e)
  {
    return LogAndReturnAuthError(e);
  }


  return S_OK;
}

STDMETHODIMP CMTPrincipalPolicy::GetCapabilitiesOfType(long aCapTypeID, IMTCollection **apCaps)
{
  long count;
  try
  {
    MTObjectCollection<IMTCompositeCapability> coll;
    mCaps.Count(&count);
    for (int i = 1; i<= count; ++i)
    {
      MTAUTHLib::IMTCompositeCapabilityPtr capPtr;
      mCaps.Item(i, (IMTCompositeCapability**)&capPtr);
      if(capPtr->CapabilityType->ID == aCapTypeID)
      {
        coll.Add((IMTCompositeCapability*)capPtr.GetInterfacePtr());
      }
    }
    mCaps = coll;
    coll.CopyTo(apCaps);
  }
  catch(_com_error& e)
  {
    return LogAndReturnAuthError(e);
  }
  return S_OK;
}

STDMETHODIMP CMTPrincipalPolicy::GetRolesAsRowset(IMTSQLRowset **apRowset)
{
  if (!apRowset)
    return E_POINTER;
  *apRowset = NULL;

  MTAUTHLib::IMTPrincipalPolicyPtr thisPtr = this;
  try
  {
    MTAUTHEXECLib::IMTPrincipalPolicyReaderPtr reader(__uuidof(MTAUTHEXECLib::MTPrincipalPolicyReader));
    (*apRowset) = (IMTSQLRowset*)reader->GetRolesAsRowset
      ((MTAUTHEXECLib::IMTSessionContext*)thisPtr->Principal->SessionContext.GetInterfacePtr(), thisPtr->ID).Detach();
  }
  catch(_com_error& e)
  {
    return LogAndReturnAuthError(e);
  }

  return S_OK;
}

STDMETHODIMP CMTPrincipalPolicy::IsPrincipalInRole(BSTR aRoleName, VARIANT_BOOL *apResult)
{
  (*apResult) = VARIANT_FALSE;
  try
  {
    _bstr_t nm = aRoleName;
    long count;
    mRoles.Count(&count);
    MTAUTHLib::IMTRolePtr rolePtr;

    for (int i = 1; i<= count; ++i)
    {
      mRoles.Item(i, (IMTRole**)&rolePtr);
      if(!_wcsicmp((wchar_t*)rolePtr->Name, (wchar_t*)nm))
      {
        (*apResult) = VARIANT_TRUE;
        return S_OK;
      }
    }
  }
  catch(_com_error& e)
  {
    return LogAndReturnAuthError(e);
  }
  return S_OK;
}

STDMETHODIMP CMTPrincipalPolicy::get_Roles(IMTCollection **apRoles)
{
  mRoles.CopyTo(apRoles);
  return S_OK;
}

STDMETHODIMP CMTPrincipalPolicy::get_Capabilities(IMTCollection **apCaps)
{
  mCaps = mAllCaps;
  mCaps.CopyTo(apCaps);
  return S_OK;
}

STDMETHODIMP CMTPrincipalPolicy::Save()
{
  try
  {

    //create policy entry or get id for existing one back
    MTAUTHEXECLib::IMTPrincipalPolicyPtr thisPtr = this;
    MTAUTHLib::IMTSecurityPrincipalPtr prPtr = thisPtr->Principal;
    MTAUTHEXECLib::IMTSessionContextPtr ctx = prPtr->SessionContext;

    //check "WRITE" auth and audit failure
    CheckAndAuditPrincipalAuth2Auth
      ((IMTSessionContext*)ctx.GetInterfacePtr(), 
      (IMTSecurityPrincipal*)prPtr.GetInterfacePtr(),
      "WRITE");

    MTAUTHEXECLib::IMTPrincipalPolicyReaderPtr reader(__uuidof(MTAUTHEXECLib::MTPrincipalPolicyReader));
    MTAUTHEXECLib::IMTPrincipalPolicyWriterPtr writer(__uuidof(MTAUTHEXECLib::MTPrincipalPolicyWriter));

    //see if the policy of the given type was already there for this principal
    (thisPtr->ID) = reader->GetPolicyID(
      (MTAUTHEXECLib::IMTSessionContext*)ctx.GetInterfacePtr(), 
      (MTAUTHEXECLib::IMTPrincipalPolicy*)thisPtr);

    if(thisPtr->ID > 0)
      return writer->Update((MTAUTHEXECLib::IMTSessionContext*) thisPtr->Principal->SessionContext,
      thisPtr);
    else
    {
      thisPtr->ID = writer->Create(thisPtr);
      return S_OK;
    }
  }
  catch(_com_error& e)
  {
    return LogAndReturnAuthError(e);
  }

  return S_OK;
}

STDMETHODIMP CMTPrincipalPolicy::SaveCapabilities()
{
  try
  {
    long capcount = 0;
    long deletedcapcount = 0;
    mCaps.Count(&capcount);
    mDeletedCaps.Count(&deletedcapcount);
    MTAUTHLib::IMTCompositeCapabilityPtr capPtr;
    MTAUTHLib::IMTPrincipalPolicyPtr thisPtr = this;

    for (int i=1; i<= capcount; ++i)
    {
      mCaps.Item(i, (IMTCompositeCapability**)&capPtr);
      ASSERT(capPtr != NULL);
      //rule 2: for subscriber accounts role can not contain
      //capabilities that are outside his corporate account
      if(mPrincipal->PrincipalType == SUBSCRIBER_ACCOUNT_PRINCIPAL)
      {
        MTYAACLib::IMTYAACPtr acc = mPrincipal;
        //TODO: is it fully initialized or do I do that?
        ASSERT(acc != NULL);
        //Query for path capability; Only check capabilities
        //that have Path as their atomic (hopefully only IMTManageAH)
        MTAUTHLib::IMTPathCapabilityPtr pathCap = capPtr->GetAtomicPathCapability();
        //in case  of ManageOwnedAccounts we will let that slide. Because PathCapability
        //is utilized differently in ManageOwnedAccounts

        if(pathCap != NULL && _wcsicmp(capPtr->GetCapabilityType()->ProgID, L"Metratech.Auth.Capabilities.ManageOwnedAccounts") != 0 && _wcsicmp(capPtr->GetCapabilityType()->ProgID, L"Metratech.MTManageAHCapability") != 0)
        {
          //only check corporation boundaries if corp business rule is enforced
          if(PCCache::IsBusinessRuleEnabled(PCCONFIGLib::MTPC_BUSINESS_RULE_Hierarchy_RestrictedOperations) == VARIANT_TRUE)
            CheckSubscriberCorporateAccount(pathCap, acc);
        }
      }

      capPtr->Save(thisPtr.GetInterfacePtr());
    }
    for (i=1; i<= deletedcapcount; ++i)
    {
      mDeletedCaps.Item(i, (IMTCompositeCapability**)&capPtr);
      ASSERT(capPtr != NULL);
      capPtr->Remove(thisPtr.GetInterfacePtr());
    }


  }
  catch(_com_error& e)
  {
    return LogAndReturnAuthError(e);
  }

  return S_OK;
}

void CMTPrincipalPolicy::Initialize()
{

  long aPolicyID = -1;
  //create policy entry or get id for existing one back
  MTAUTHEXECLib::IMTPrincipalPolicyPtr thisPtr = this;
  ASSERT(mPrincipal != NULL);
  MTSecurityPrincipalType principalType = (MTSecurityPrincipalType)mPrincipal->PrincipalType;
  MTAUTHEXECLib::IMTPrincipalPolicyReaderPtr reader(__uuidof(MTAUTHEXECLib::MTPrincipalPolicyReader));
  MTAUTHEXECLib::IMTRoleReaderPtr roleReader(__uuidof(MTAUTHEXECLib::MTRoleReader));

  if(mPrincipal->ID > 0)
  {

    //see if the policy of the given type was already there for this principal
    (thisPtr->ID) = reader->GetPolicyID(
      (MTAUTHEXECLib::IMTSessionContext*)thisPtr->Principal->SessionContext.GetInterfacePtr(),
      (MTAUTHEXECLib::IMTPrincipalPolicy*)thisPtr);

    //initialize roles if principal is account
    if(principalType != ROLE_PRINCIPAL)
      mRoles = (IMTCollection*)reader->GetAccountRoles
      ((MTAUTHEXECLib::IMTSessionContext*)thisPtr->Principal->SessionContext, mPrincipal->ID, 
      (MTAUTHEXECLib::MTPrincipalPolicyType)mPolicyType, VARIANT_FALSE).GetInterfacePtr();
    else
      mRoles = NULL;
    //initialize capabilities
    mCaps = (IMTCollection*)reader->GetPrincipalCapabilities
      ((MTAUTHEXECLib::IMTSessionContext*)thisPtr->Principal->SessionContext, 
      (MTAUTHEXECLib::IMTSecurityPrincipal *)mPrincipal.GetInterfacePtr(),
      (MTAUTHEXECLib::MTPrincipalPolicyType)mPolicyType, VARIANT_FALSE).GetInterfacePtr();
    mAllCaps = mCaps;
  }
  else
  {
    MTAUTHLib::IMTCollectionPtr caps("Metratech.MTCollection.1");
    mCaps = reinterpret_cast<IMTCollection*>(caps.GetInterfacePtr());
    mAllCaps = mCaps;
    if(principalType != ROLE_PRINCIPAL)
    {
      MTAUTHLib::IMTCollectionPtr roles("Metratech.MTCollection.1");
      mRoles = reinterpret_cast<IMTCollection*>(roles.GetInterfacePtr());
    }
    else
      mRoles = NULL;
  }
}

STDMETHODIMP CMTPrincipalPolicy::FromXML(IMTSessionContext* aCtx, IDispatch* aDomNode)
{
  try
  {
    //1. Base on the principal and policy type, initialize current set
    //of roles and capabilities, clear them out.
    Initialize();
    RemoveAllRoles();
    RemoveAllCapabilities();

    MTAUTHEXECLib::IMTRoleReaderPtr roleReader(__uuidof(MTAUTHEXECLib::MTRoleReader));
    MTAUTHLib::IMTPrincipalPolicyPtr thisPtr = this;
    MSXML2::IXMLDOMNodePtr policyNode = aDomNode;
    MSXML2::IXMLDOMNodePtr rolesNode = NULL;
    MSXML2::IXMLDOMNodeListPtr roleNodes = NULL;
    MSXML2::IXMLDOMNodePtr roleNode = NULL;
    MSXML2::IXMLDOMNodePtr compositeCapsNode = NULL;
    MSXML2::IXMLDOMNodeListPtr compositeCapNodes = NULL;
    MSXML2::IXMLDOMNodePtr compositeCapNode = NULL;
    MSXML2::IXMLDOMNodePtr nameAttrib;
    MSXML2::IXMLDOMNodePtr guidAttrib;
    MSXML2::IXMLDOMNamedNodeMapPtr attribs;


    if(aDomNode == NULL)
      MT_THROW_COM_ERROR(IID_IMTPrincipalPolicy, "QueryInterface for IXMLDOMNode* failed!");

    rolesNode = policyNode->selectSingleNode(ROLES_TAG);

    if(rolesNode != NULL)
    {
      roleNodes = rolesNode->selectNodes(ROLE_TAG);
      if(roleNodes->length > 0)
      {
        if(mPrincipal->PrincipalType == MTAUTHLib::ROLE_PRINCIPAL)
          MT_THROW_COM_ERROR(MTAUTH_ADDING_ROLE_TO_ROLE_NOT_SUPPORTED);
      }
      for(;;)
      {
        roleNode = roleNodes->nextNode();
        if(roleNode == NULL)
          break;
        attribs = roleNode->attributes;
        nameAttrib = attribs->getNamedItem(NAME_ATTRIB);
        guidAttrib = attribs->getNamedItem(GUID_ATTRIB);
        if(nameAttrib == NULL) //&& guidAttrib == NULL)
        {
          //LogAuthError("Either 'name' or 'guid' attributes has to be specified");
          LogAuthError("'name' attribute has to be specified on role node");
          MT_THROW_COM_ERROR(MTAUTH_PRINCIPAL_POLICY_DESERIALIZATION_FAILED);
        }
        MTAUTHLib::IMTRolePtr role = roleReader->GetByName(
          (MTAUTHEXECLib::IMTSessionContext*)thisPtr->Principal->SessionContext.GetInterfacePtr(),
          nameAttrib->text);
        if(role == NULL)
          MT_THROW_COM_ERROR(MTAUTH_ROLE_NOT_FOUND, (char*)nameAttrib->text);
        thisPtr->AddRole(role.GetInterfacePtr());
      }
    }

    compositeCapsNode = policyNode->selectSingleNode(COMPOSITE_CAPS_TAG);

    if(compositeCapsNode != NULL)
    {
      compositeCapNodes = compositeCapsNode->selectNodes(COMPOSITE_CAP_TAG);
      if(compositeCapNodes == NULL)
        return S_OK;
      //default policies can't contain capabilities
      if(compositeCapNodes->length > 0 && mPolicyType == DEFAULT_POLICY)
      {
        //LogAuthWarning("Default Policy can not contain capabilities!");
        MT_THROW_COM_ERROR(MTAUTH_DEFAULT_POLICY_CAN_ONLY_CONTAIN_ROLES);
      }

      MTAUTHLib::IMTSecurityPtr security(__uuidof(MTAUTHLib::MTSecurity));
      for(;;)
      {
        compositeCapNode = compositeCapNodes->nextNode();
        if(compositeCapNode == NULL)
          break;
        attribs = compositeCapNode->attributes;
        nameAttrib = attribs->getNamedItem(NAME_ATTRIB);
        guidAttrib = attribs->getNamedItem(GUID_ATTRIB);
        if(nameAttrib == NULL) //&& guidAttrib == NULL)
        {
          //LogAuthError("Either 'name' or 'guid' attributes has to be specified");
          LogAuthError("'name' attribute has to be specified in compositecapability node");
          MT_THROW_COM_ERROR(MTAUTH_PRINCIPAL_POLICY_DESERIALIZATION_FAILED);
        }


        MTAUTHLib::IMTCompositeCapabilityPtr cap;
        cap = security->GetCapabilityTypeByName(nameAttrib->text)->CreateInstance();
        cap->FromXML(compositeCapNode);
        thisPtr->AddCapability(cap.GetInterfacePtr());
      }
    }

  }
  catch(_com_error& e)
  {
    return LogAndReturnAuthError(e);
  }

  return S_OK;
}

STDMETHODIMP CMTPrincipalPolicy::ToXML(BSTR* apXmlString)
{
  try
  {
    return E_NOTIMPL;
  }
  catch(_com_error& e)
  {
    return LogAndReturnAuthError(e);
  }

  return S_OK;
}




STDMETHODIMP CMTPrincipalPolicy::CheckSubscriberCorporateAccount(MTAUTHLib::IMTPathCapabilityPtr& aAttemptedCapability, MTYAACLib::IMTYAACPtr& aAccount)
{
  long corpAccountID = aAccount->CorporateAccountID;

  MTAUTHLib::IMTPathCapabilityPtr corporatePathCap(__uuidof(MTAUTHLib::MTPathCapability));
  corporatePathCap->SetParameter((_bstr_t)_variant_t(corpAccountID), MTAUTHLib::RECURSIVE);

  //the logic is following:
  //corporatePathCap is constructed to be "All accounts under corpAccountID corporation recursively"
  //Check if it implies attempted one. Id it doesn't, then it means that someone istrying to
  //give a subscriber capability that covers another corporation
  if(corporatePathCap->Implies(aAttemptedCapability) == VARIANT_FALSE)
    //MT_THROW_COM_ERROR(MTAUTH_CAPABILITY_OUTSIDE_OF_CORPORATE_ACCOUNT, corpAccountID, corpAccountID);
    MT_THROW_COM_ERROR(MTAUTH_CAPABILITY_OUTSIDE_OF_CORPORATE_ACCOUNT);
  return S_OK;
}





