/**************************************************************************
* Copyright 1997-2001 by MetraTech
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
* Created by: Boris Partensky
* 
***************************************************************************/

// MTSecurity.cpp : Implementation of CMTSecurity
#include "StdAfx.h"
#include "MTAuth.h"
#include "MTSecurity.h"
#include "MTSessionContext.h"
#include "MTRole.h"

/////////////////////////////////////////////////////////////////////////////
// CMTSecurity

STDMETHODIMP CMTSecurity::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTSecurity
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

STDMETHODIMP CMTSecurity::GetAccountByID(IMTSessionContext *aCtx, long aAccountID,VARIANT aRefDate, IMTYAAC **apAccount)
{
	if (!apAccount)
		return E_POINTER;
	*apAccount = NULL;
	try
	{
		mAccCatalog->Init(reinterpret_cast<MTYAACLib::IMTSessionContext*>(aCtx));
    MTYAACLib::IMTYAACPtr acc = mAccCatalog->GetAccount(aAccountID,aRefDate);
    MTAUTHLib::IMTSecurityPrincipalPtr principalPtr = acc;
    ASSERT(principalPtr != NULL);
    CheckPrincipalAuth2Auth(aCtx, 
      reinterpret_cast<IMTSecurityPrincipal*>(principalPtr.GetInterfacePtr()), "READ");
    //based on account type, check security - 
    //ManageSubscriberAuth or ManageCSRAuth caps
		(*apAccount) = reinterpret_cast<IMTYAAC*>(acc.Detach());
	}
	catch(_com_error& e)
	{
		return ReturnComError(e);
	}
	return S_OK;
}

STDMETHODIMP CMTSecurity::GetAnonymousAccount(IMTSessionContext *aCtx, IMTYAAC **apAccount)
{
	if (!apAccount)
		return E_POINTER;
	*apAccount = NULL;
	try
	{
		mAccCatalog->Init(reinterpret_cast<MTYAACLib::IMTSessionContext*>(aCtx));
    MTYAACLib::IMTYAACPtr acc = mAccCatalog->GetAccountByName("anonymous", "auth");
    MTAUTHLib::IMTSecurityPrincipalPtr principalPtr = acc;
    ASSERT(principalPtr != NULL);
    CheckPrincipalAuth2Auth(aCtx, 
      reinterpret_cast<IMTSecurityPrincipal*>(principalPtr.GetInterfacePtr()), "READ");
    (*apAccount) = reinterpret_cast<IMTYAAC*>(acc.Detach());
	}
	catch(_com_error& e)
	{
		return ReturnComError(e);
	}

	return S_OK;
}

STDMETHODIMP CMTSecurity::GetCSRFolder(IMTSessionContext *aCtx, IMTYAAC **apFolder)
{
	if (!apFolder)
		return E_POINTER;
	*apFolder = NULL;
	try
	{
		//check ManageGlobalAuth capability
    mAccCatalog->Init(reinterpret_cast<MTYAACLib::IMTSessionContext*>(aCtx));
    MTYAACLib::IMTYAACPtr acc = mAccCatalog->GetAccountByName("csr_folder", "auth");
    MTAUTHLib::IMTSecurityPrincipalPtr principalPtr = acc;
    ASSERT(principalPtr != NULL);
    CheckPrincipalAuth2Auth(aCtx, 
      reinterpret_cast<IMTSecurityPrincipal*>(principalPtr.GetInterfacePtr()), "READ");

    (*apFolder) = reinterpret_cast<IMTYAAC*>(acc.Detach());
	}
	catch(_com_error& e)
	{
		return ReturnComError(e);
	}

	return S_OK;

}

STDMETHODIMP CMTSecurity::CreateRole(IMTSessionContext *aCtx, IMTRole **apNewRole)
{
	if (!apNewRole)
		return E_POINTER;
	*apNewRole = NULL;
	// TODO: Check ManageGlobalAuth capability
	try
	{
		//DO NOT check any security in this method!
    //Session context is set on this role, and security check is done in
    //the subsequent operations down the pipe
    MTAUTHLib::IMTRolePtr newRole = CreateRole();
    newRole->SessionContext = reinterpret_cast<MTAUTHLib::IMTSessionContext*>(aCtx);
    MTAUTHLib::IMTSecurityPrincipalPtr principalPtr = newRole;
    ASSERT(principalPtr != NULL);
    (*apNewRole) = (IMTRole*)newRole.Detach();
	}
	catch(_com_error& e)
	{
		return ReturnComError(e);
	}

	return S_OK;
}

STDMETHODIMP CMTSecurity::GetRoleByName(IMTSessionContext *aCtx, BSTR aRoleName, IMTRole **apRole)
{
	if (!apRole)
		return E_POINTER;
	*apRole = NULL;

	// TODO: Do we check security here??
	try
	{
	  /*
    AutoCriticalSection alock(&mLock);
    _bstr_t bstrRoleName(aRoleName, FALSE);
    //get it from collection
    MTAUTHLib::IMTRolePtr outPtr;
    mRoleMapByNameIt = mRoleMapByName.find(bstrRoleName);
    if(mRoleMapByNameIt == mRoleMapByName.end())
      MT_THROW_COM_ERROR(MTAUTH_ROLE_NOT_FOUND, (char*)bstrRoleName);
		
    outPtr = mRoleMapByNameIt->second;
    (*apRole) = (IMTRole*)outPtr.Detach();
    */

    //DO NOT check any security in this method!
    //Session context is set on this role, and security check is done in
    //the subsequent operations down the pipe
    
    MTAUTHEXECLib::IMTSecurityReaderPtr reader(__uuidof(MTAUTHEXECLib::MTSecurityReader));
    MTAUTHLib::IMTRolePtr outPtr = reader->GetRoleByName((MTAUTHEXECLib::IMTSessionContext*)aCtx, aRoleName);
    MTAUTHLib::IMTSecurityPrincipalPtr principalPtr = outPtr;
    ASSERT(principalPtr != NULL);
    
    (*apRole) = (IMTRole*)outPtr.Detach();
	}
	catch(_com_error& e)
	{
		return LogAndReturnAuthError(e);
	}


	return S_OK;
}

STDMETHODIMP CMTSecurity::GetRoleByID(IMTSessionContext *aCtx, long aRoleID, IMTRole **apRole)
{
	if (!apRole)
		return E_POINTER;
	*apRole = NULL;
	// TODO: Do we check security here??
	try
	{
		/*
    AutoCriticalSection alock(&mLock);
    //get it from collection
    MTAUTHLib::IMTRolePtr outPtr;
    mRoleMapByIDIt = mRoleMapByID.find(aRoleID);
    if(mRoleMapByIDIt == mRoleMapByID.end())
      MT_THROW_COM_ERROR(MTAUTH_ROLE_NOT_FOUND_BY_ID, aRoleID);
		
    outPtr = mRoleMapByIDIt->second;
    (*apRole) = (IMTRole*)outPtr.Detach();
    */
    
    //DO NOT check any security in this method!
    //Session context is set on this role, and security check is done in
    //the subsequent operations down the pipe
   
    MTAUTHEXECLib::IMTSecurityReaderPtr reader(__uuidof(MTAUTHEXECLib::MTSecurityReader));
		MTAUTHLib::IMTRolePtr outPtr = reader->GetRoleByID((MTAUTHEXECLib::IMTSessionContext*)aCtx, aRoleID);
    MTAUTHLib::IMTSecurityPrincipalPtr principalPtr = outPtr;
    ASSERT(principalPtr != NULL);
    (*apRole) = (IMTRole*)outPtr.Detach();
	}
	catch(_com_error& e)
	{
		return LogAndReturnAuthError(e);
	}

	return S_OK;

}

STDMETHODIMP CMTSecurity::GetAllRolesAsRowset(IMTSessionContext *aCtx, IMTSQLRowset** apRowset)
{
	if (!apRowset)
		return E_POINTER;
	*apRowset = NULL;
	// TODO: Do we check security here??
	try
	{
		CheckGlobalAuth2Auth(aCtx);
    MTAUTHEXECLib::IMTSecurityReaderPtr reader(__uuidof(MTAUTHEXECLib::MTSecurityReader));
		(*apRowset) = (IMTSQLRowset*)reader->GetAllRolesAsRowset((MTAUTHEXECLib::IMTSessionContext*)aCtx).Detach();
	}
	catch(_com_error& e)
	{
		return ReturnComError(e);
	}

	return S_OK;

}

STDMETHODIMP CMTSecurity::GetCapabilityTypesAsRowset(IMTSessionContext *aCtx, IMTSQLRowset **apRowset)
{
	if (!apRowset)
		return E_POINTER;
	*apRowset = NULL;
	// TODO: Do we check security here??
	try
	{
		CheckGlobalAuth2Auth(aCtx);
    MTAUTHEXECLib::IMTSecurityReaderPtr reader(__uuidof(MTAUTHEXECLib::MTSecurityReader));
		(*apRowset) = (IMTSQLRowset*)reader->GetCapabilityTypesAsRowset((MTAUTHEXECLib::IMTSessionContext*)aCtx).Detach();
	}
	catch(_com_error& e)
	{
		return ReturnComError(e);
	}

	return S_OK;
}

STDMETHODIMP CMTSecurity::GetAvailableCapabilityTypesAsRowset(IMTSessionContext *aCtx, IMTSecurityPrincipal *aPrincipal, IMTSQLRowset **apRowset)
{
	if (!apRowset)
		return E_POINTER;
	*apRowset = NULL;
	// TODO: Do we check security here??
	try
	{
    CheckPrincipalAuth2Auth(aCtx, aPrincipal, "READ");
    MTAUTHLib::IMTSecurityPrincipalPtr prPtr = aPrincipal;
    ASSERT(prPtr != NULL);
    MTAUTHEXECLib::IMTSecurityReaderPtr reader(__uuidof(MTAUTHEXECLib::MTSecurityReader));
		(*apRowset) = (IMTSQLRowset*)reader->GetAvailableCapabilityTypesAsRowset
      ((MTAUTHEXECLib::IMTSessionContext*)aCtx, (MTAUTHEXECLib::IMTSecurityPrincipal*)prPtr.GetInterfacePtr()).Detach();
	}
	catch(_com_error& e)
	{
		return ReturnComError(e);
	}

	return S_OK;

}

STDMETHODIMP CMTSecurity::GetCapabilityTypeByNameControlLogging(BSTR aTypeName, VARIANT_BOOL logErrorIfNotFound, IMTCompositeCapabilityType **apCapType)
{
	if (!apCapType)
		return E_POINTER;
	*apCapType = NULL;
	// TODO: Do we check security here??
	try
	{
		AutoCriticalSection alock(&mLock);

		// make name uppercase, so case won't matter
		mtwstring wName(aTypeName);
		wName.toupper();
		_bstr_t bstrTypeName(wName); // should be in upper case

    //get it from collection
    MTAUTHLib::IMTCompositeCapabilityTypePtr outPtr;
    mCapTypeMapByNameIt = mCapTypeMapByName.find(bstrTypeName);
    if(mCapTypeMapByNameIt == mCapTypeMapByName.end())
    {
      // If logErrorIfNotFound is TRUE, then invoke MT_THROW_COM_ERROR.
      // This will log an error message and throw an exception.
      //
      // If logErrorIfNotFound is FALSE, then just return E_FAIL.
      // No error message will be logged.
      if (logErrorIfNotFound)
      {
        MT_THROW_COM_ERROR(MTAUTH_COMPOSITE_CAPABILITY_TYPE_NOT_FOUND, (char*)bstrTypeName);
      }
      else
      {
        return E_FAIL;
      }
    }
		
    outPtr = mCapTypeMapByNameIt->second;
    (*apCapType) = (IMTCompositeCapabilityType*)outPtr.Detach();
	}
	catch(_com_error& e)
	{
		return LogAndReturnAuthError(e);
	}
	return S_OK;
}

STDMETHODIMP CMTSecurity::GetCapabilityTypeByName(BSTR aTypeName, IMTCompositeCapabilityType **apCapType)
{
    return GetCapabilityTypeByNameControlLogging(aTypeName, true, apCapType);
}

STDMETHODIMP CMTSecurity::GetCapabilityTypeByID(long aTypeID, IMTCompositeCapabilityType **apCapType)
{
	if (!apCapType)
		return E_POINTER;
	*apCapType = NULL;
	// TODO: Do we check security here??
	try
	{
		AutoCriticalSection alock(&mLock);
    //get it from collection
    MTAUTHLib::IMTCompositeCapabilityTypePtr outPtr;
    mCapTypeMapByIDIt = mCapTypeMapByID.find(aTypeID);
    if(mCapTypeMapByIDIt == mCapTypeMapByID.end())
      MT_THROW_COM_ERROR(MTAUTH_COMPOSITE_CAPABILITY_TYPE_NOT_FOUND_BY_ID, aTypeID);
		
    outPtr = mCapTypeMapByIDIt->second;
    (*apCapType) = (IMTCompositeCapabilityType*)outPtr.Detach();
	}
	catch(_com_error& e)
	{
		return LogAndReturnAuthError(e);
	}
	return S_OK;
}

STDMETHODIMP CMTSecurity::GetAtomicCapabilityTypeByName(BSTR aTypeName, IMTAtomicCapabilityType **apCapType)
{
	if (!apCapType)
		return E_POINTER;
	*apCapType = NULL;
	try
	{
		AutoCriticalSection alock(&mLock);
    //get it from collection
    MTAUTHEXECLib::IMTAtomicCapabilityTypeReaderPtr reader(__uuidof(MTAUTHEXECLib::MTAtomicCapabilityTypeReader));
		(*apCapType) = (IMTAtomicCapabilityType*)reader->GetByName(aTypeName).Detach();
	}
	catch(_com_error& e)
	{
		return ReturnComError(e);
	}
	return S_OK;
}

STDMETHODIMP CMTSecurity::RemoveRole(IMTSessionContext *aCtx, long aRoleID)
{
	// TODO: Do we check security here??
	try
	{
		CheckGlobalAuth2Auth(aCtx);
    MTAUTHEXECLib::IMTSecurityReaderPtr reader(__uuidof(MTAUTHEXECLib::MTSecurityReader));
    MTAUTHEXECLib::IMTRoleWriterPtr writer(__uuidof(MTAUTHEXECLib::MTRoleWriter));
		MTAUTHLib::IMTRolePtr rolePtr = 
			reader->GetRoleByID((MTAUTHEXECLib::IMTSessionContext*)aCtx, aRoleID);
    MTAUTHLib::IMTPrincipalPolicyPtr polPtr = 
			rolePtr->GetActivePolicy((MTAUTHLib::IMTSessionContext*)aCtx);
    
     //1. check if role has actors
    if (rolePtr->HasMembers((MTAUTHLib::IMTSessionContext*)aCtx) == VARIANT_TRUE)
	    MT_THROW_COM_ERROR(MTAUTH_ROLE_HAS_MEMBERS, (char*)rolePtr->Name);

		writer->Remove((MTAUTHEXECLib::IMTSessionContext*)aCtx,
                   (MTAUTHEXECLib::IMTRole*)rolePtr.GetInterfacePtr(),
                   (MTAUTHEXECLib::IMTPrincipalPolicy*)polPtr.GetInterfacePtr());
    return InternalBuildCol();
	}
	catch(_com_error& e)
	{
		return LogAndReturnAuthError(e);
	}

	return S_OK;
}

STDMETHODIMP CMTSecurity::GetAvailableRolesAsRowset(IMTSessionContext *aCtx, 
                                                    IMTSecurityPrincipal *aPrincipal, 
                                                    MTPrincipalPolicyType aPolicyType,
                                                    IMTSQLRowset **apRowset)
{
	if (!apRowset)
		return E_POINTER;
	*apRowset = NULL;
	// TODO: Do we check security here??
	try
	{
    CheckPrincipalAuth2Auth(aCtx, aPrincipal, "READ");
    MTAUTHLib::IMTSecurityPrincipalPtr prPtr = aPrincipal;
    ASSERT(prPtr != NULL);
    ROWSETLib::IMTSQLRowsetPtr outPtr;
    MTAUTHEXECLib::IMTSecurityReaderPtr reader(__uuidof(MTAUTHEXECLib::MTSecurityReader));
		outPtr = reader->GetAvailableRolesAsRowset((MTAUTHEXECLib::IMTSessionContext*)aCtx,
    (MTAUTHEXECLib::IMTSecurityPrincipal*)prPtr.GetInterfacePtr(), 
    (MTAUTHEXECLib::MTPrincipalPolicyType)aPolicyType);
    (*apRowset) = (IMTSQLRowset*)outPtr.Detach();
	}
	catch(_com_error& e)
	{
		return ReturnComError(e);
	}

	return S_OK;

}

STDMETHODIMP CMTSecurity::GetMOMFolder(IMTSessionContext *aCtx, IMTYAAC **apFolder)
{
	if (!apFolder)
		return E_POINTER;
	*apFolder = NULL;
	try
	{
		CheckGlobalAuth2Auth(aCtx);
    mAccCatalog->Init(reinterpret_cast<MTYAACLib::IMTSessionContext*>(aCtx));
    MTYAACLib::IMTYAACPtr acc = mAccCatalog->GetAccountByName("mom_folder", "auth");
    (*apFolder) = reinterpret_cast<IMTYAAC*>(acc.Detach());
	}
	catch(_com_error& e)
	{
		return ReturnComError(e);
	}

	return S_OK;

}

STDMETHODIMP CMTSecurity::GetMCMFolder(IMTSessionContext *aCtx, IMTYAAC **apFolder)
{
	if (!apFolder)
		return E_POINTER;
	*apFolder = NULL;
	try
	{
		CheckGlobalAuth2Auth(aCtx);
    mAccCatalog->Init(reinterpret_cast<MTYAACLib::IMTSessionContext*>(aCtx));
    MTYAACLib::IMTYAACPtr acc = mAccCatalog->GetAccountByName("mcm_folder", "auth");
    (*apFolder) = reinterpret_cast<IMTYAAC*>(acc.Detach());
	}
	catch(_com_error& e)
	{
		return ReturnComError(e);
	}

	return S_OK;

}
//Got refresh event, reinitialize
void CMTSecurity::ConfigurationHasChanged()
{
	LogAuthDebug("MTSecurity received RefreshConfig event, reinitializing...");
	// we don't check the error code because we can't do anything
	InternalBuildCol();
  LogAuthDebug("MTSecurity reinitialized.");
}

HRESULT CMTSecurity::InternalBuildCol()
{
	AutoCriticalSection alock(&mLock);
  try
	{
		mCapTypeMapByID.clear();
    mCapTypeMapByName.clear();
    mRoleMapByID.clear();
    mRoleMapByName.clear();

    //below reader methods take session context not for security reasons, but
    //in case we ever want to get localized rowsets. For now
    //contruct empty one in order to pass it in.
     CComObject<CMTSessionContext> * directSc;
 	   CComObject<CMTSessionContext>::CreateInstance(&directSc);
     MTAUTHLib::IMTSessionContextPtr aCtx;
 
    HRESULT hr =  directSc->QueryInterface(IID_IMTSessionContext,
						reinterpret_cast<void**>(&aCtx));
   if (FAILED(hr))
			MT_THROW_COM_ERROR("Failed to QueryInterface on direct CMTSessionContextObject");

    //1. get all capability types
    MTAUTHEXECLib::IMTSecurityReaderPtr reader(__uuidof(MTAUTHEXECLib::MTSecurityReader));
    MTAUTHEXECLib::IMTCompositeCapabilityTypeReaderPtr cctReader(__uuidof(MTAUTHEXECLib::MTCompositeCapabilityTypeReader));
    MTAUTHEXECLib::IMTRoleReaderPtr roleReader(__uuidof(MTAUTHEXECLib::MTRoleReader));
		ROWSETLib::IMTSQLRowsetPtr cctrs = cctReader->GetAllAsRowset((MTAUTHEXECLib::IMTSessionContext*)aCtx.GetInterfacePtr());

    //2. Initialize all the types
    hr = CreateCCTCollection(cctrs);
    if(FAILED(hr))
      MT_THROW_COM_ERROR(hr);
   

    //3. Do the same with roles
    ROWSETLib::IMTSQLRowsetPtr rolers = reader->GetAllRolesAsRowset((MTAUTHEXECLib::IMTSessionContext*)aCtx.GetInterfacePtr());
     
    while(rolers->GetRowsetEOF().boolVal == VARIANT_FALSE)
    {
      MTAUTHLib::IMTRolePtr rolePtr = CreateRole();
      rolePtr->ID = rolers->GetValue("id_role");
		  rolePtr->GUID = MTMiscUtil::GetString(rolers->GetValue("tx_guid"));
		  rolePtr->Name = MTMiscUtil::GetString(rolers->GetValue("tx_name"));
		  rolePtr->Description = MTMiscUtil::GetString(rolers->GetValue("tx_desc"));
		  rolePtr->CSRAssignable = MTTypeConvert::StringToBool(MTMiscUtil::GetString(rolers->GetValue("csr_assignable")));
		  rolePtr->SubscriberAssignable = MTTypeConvert::StringToBool(MTMiscUtil::GetString(rolers->GetValue("subscriber_assignable")));
      
      mRoleMapByID[(long)rolePtr->ID] = rolePtr;

      mRoleMapByName[(_bstr_t)rolePtr->Name] = rolePtr;
      rolers->MoveNext();
    }
	
  }
	catch(_com_error& e)
	{
		return ReturnComError(e);
	}

  return S_OK;
}

MTAUTHLib::IMTRolePtr CMTSecurity::CreateRole()
{
  CComObject<CMTRole> * directRole;
 	CComObject<CMTRole>::CreateInstance(&directRole);
  MTAUTHLib::IMTRolePtr outPtr;
 
	HRESULT hr =  directRole->QueryInterface(IID_IMTRole,
						reinterpret_cast<void**>(&outPtr));
  if (FAILED(hr))
			MT_THROW_COM_ERROR("Failed to QueryInterface on direct CMTRole");

  return outPtr;
}

HRESULT CMTSecurity::CreateCCTCollection(const ROWSETLib::IMTSQLRowsetPtr& aRs)
{
  HRESULT hr(S_OK);
  long lPreviousRowID = 0;
  MTAUTHLib::IMTCompositeCapabilityTypePtr cctPtr = NULL;
  try
  {
    while(aRs->GetRowsetEOF().boolVal == VARIANT_FALSE)
    {
      long cctid = aRs->GetValue("id_cap_type");
      if(cctid != lPreviousRowID)
      {
        //not a first row and type changed, therefore
        //add the type to collection and create new one
        if(cctPtr != NULL)
        {
          mCapTypeMapByID[lPreviousRowID] = cctPtr;
          mtwstring wName(cctPtr->Name);
          wName.toupper();
          _bstr_t bstrName(wName); // this should be all in upper case
          mCapTypeMapByName[bstrName] = cctPtr;
        }
        hr = cctPtr.CreateInstance(__uuidof(MTAUTHLib::MTCompositeCapabilityType));
        if(FAILED(hr))
          MT_THROW_COM_ERROR(hr);
        
        cctPtr->ID = cctid;
        cctPtr->GUID = MTMiscUtil::GetString(aRs->GetValue("tx_guid"));
        _bstr_t bstrName = MTMiscUtil::GetString(aRs->GetValue("tx_name"));
        cctPtr->Name = bstrName;
        _bstr_t bstrDesc = MTMiscUtil::GetString(aRs->GetValue("tx_desc"));
        cctPtr->Description = bstrDesc;
        _bstr_t bstrProgID = MTMiscUtil::GetString(aRs->GetValue("tx_progid"));
        cctPtr->ProgID = bstrProgID;
        cctPtr->Editor = MTMiscUtil::GetString(aRs->GetValue("tx_editor"));
        cctPtr->CSRAssignable = MTTypeConvert::StringToBool(MTMiscUtil::GetString(aRs->GetValue("csr_assignable")));
        cctPtr->SubscriberAssignable = MTTypeConvert::StringToBool(MTMiscUtil::GetString(aRs->GetValue("subscriber_assignable")));
        cctPtr->AllowMultipleInstances = MTTypeConvert::StringToBool(MTMiscUtil::GetString(aRs->GetValue("multiple_instances")));
        cctPtr->UmbrellaSensitive = MTTypeConvert::StringToBool(MTMiscUtil::GetString(aRs->GetValue("umbrella_sensitive")));
      }
      
      //if next value is null, then this composite has 0 atomics, go to next row
			_variant_t atomicProgID = aRs->GetValue("atomic_tx_progid");
      if(V_VT(&atomicProgID) == VT_NULL)
      {
        lPreviousRowID = cctid;
        aRs->MoveNext();
        //take care of the last row
        if(aRs->GetRowsetEOF().boolVal == VARIANT_TRUE)
        {
          mCapTypeMapByID[cctid] = cctPtr;
          mtwstring wName(cctPtr->Name);
          wName.toupper();
          _bstr_t bstrName(wName); // this should be all in upper case
          mCapTypeMapByName[bstrName] = cctPtr;
        }
        continue;
      }
      MTAUTHLib::IMTAtomicCapabilityTypePtr actPtr(__uuidof(MTAUTHLib::MTAtomicCapabilityType));
      actPtr->ProgID = (_bstr_t)atomicProgID;
      long lAtomicTypeID = aRs->GetValue("atomic_id_cap_type");
      actPtr->ID = lAtomicTypeID;
      actPtr->CompositionDescription = MTMiscUtil::GetString(aRs->GetValue("CompositionDescription"));
      actPtr->ParameterName = MTMiscUtil::GetString(aRs->GetValue("tx_param"));
      actPtr->Name = MTMiscUtil::GetString(aRs->GetValue("atomic_tx_name"));
      actPtr->Description = MTMiscUtil::GetString(aRs->GetValue("atomic_tx_desc"));
      actPtr->Editor = MTMiscUtil::GetString(aRs->GetValue("atomic_tx_editor"));
      cctPtr->AddAtomicCapabilityType(actPtr);
      
      
      lPreviousRowID = cctid;
      
      aRs->MoveNext();
      if(cctPtr == NULL)
        continue;
      //take care of the last row
      else if(aRs->GetRowsetEOF().boolVal == VARIANT_TRUE)
      {
         mCapTypeMapByID[cctid] = cctPtr;
         mtwstring wName(cctPtr->Name);
         wName.toupper();
         _bstr_t bstrName(wName); // this should be all in upper case
         mCapTypeMapByName[bstrName] = cctPtr;
      }
    }

   return S_OK;
  }
  catch(_com_error& e)
  {
    return ReturnComError(e);
  }
}



 
