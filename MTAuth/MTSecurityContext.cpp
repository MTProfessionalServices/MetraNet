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

// MTSecurityContext.cpp : Implementation of CMTSecurityContext
#include "StdAfx.h"
#include "MTAuth.h"
#include "MTSecurityContext.h"

/////////////////////////////////////////////////////////////////////////////
// CMTSecurityContext

STDMETHODIMP CMTSecurityContext::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTSecurityContext
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

STDMETHODIMP CMTSecurityContext::Init(BSTR aName, BSTR aNameSpace)
{
	HRESULT hr(S_OK);
	_variant_t vRoleName;
	_variant_t vCapInstanceID;
	_variant_t vCapParentInstanceID;
	_variant_t vCapTypeName;
	_variant_t vParentCapTypeName;
  _variant_t vPathValue;
  _variant_t vEnumValue;
  _variant_t vDecValue;
  _variant_t vDecOp;
	CapIterator capit;
	//HACK: fix it in query
	set<long> dups;
	//cache types
	set<long>::iterator dupit;

	_bstr_t manageOwnedAccountsCapName(L"Manage Owned Accounts");
	
	MTAUTHLib::IMTAtomicCapabilityPtr atomic;
	MTAUTHLib::IMTCompositeCapabilityPtr composite;
	_bstr_t bstrProgID;
	
	try
	{
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    MTAUTHLib::IMTSecurityPtr security(__uuidof(MTAUTHLib::MTSecurity));
		rowset->Init(CONFIG_DIR);
		
		rowset->SetQueryTag("__GET_ALL_CAPABILITIES_ON_ACCOUNT_AND_OWNED_FOLDERS__");
		//rowset->AddParam("%%ID_ACC%%", aAccountID);
		//rowset->AddParam("%%POLICY_TYPE%%", "A");
    _bstr_t bstrName = aName;
    _bstr_t bstrNameSpace = aNameSpace;
    rowset->AddParam("%%NM_LOGIN%%", bstrName);
    rowset->AddParam("%%NAMESPACE%%", bstrNameSpace);
		rowset->Execute();
		while(rowset->GetRowsetEOF().boolVal == VARIANT_FALSE)
		{
			if(mAccountID < 0)
        mAccountID = rowset->GetValue("id_actor");
      //collect all role names and store them in the context
			vRoleName = rowset->GetValue("tx_name");
			if (V_VT(&vRoleName) != VT_NULL)
				mRoleNames.insert((_bstr_t)vRoleName);
			vCapInstanceID = rowset->GetValue("id_cap_instance");
			
			//if cap instance is NULL then it means one of
      //two things:
			//1. there is a role with 0 capabilities -
			//unlikely and incorrect, but possible.
      //2. It's a dummy record that we stick to the end of the result set
      //    in order to get account id if a principal has 0 capabilities
			//just proceed to next row

			if (V_VT(&vCapInstanceID) == VT_NULL){
				rowset->MoveNext();
				continue;
			}

			vCapParentInstanceID = rowset->GetValue("id_parent_cap_instance");
			vCapTypeName = rowset->GetValue("type_name");
			
			//if parent instance id is null, then it's a composite cap
			//construct it and insert it into the map
			
			//Replaced NULLs with 0s from in the query
      //beacuse of different ORDER BY behaviour in
      //SQL server and Oracle
      //if(V_VT(&vCapParentInstanceID) == VT_NULL)
      if(0 == (long)vCapParentInstanceID)
      {
				capit = mCapabilities.find((long)vCapInstanceID);
				//take care of possible duplicate instances from query
				//that can happen if one role sits on more then one principal
				//TODO: should be fixed on the query
				if (capit != mCapabilities.end()){
					rowset->MoveNext();
					continue;
				}

				MTAUTHLib::IMTCompositeCapabilityTypePtr compositeType = 
            security->GetCapabilityTypeByName((_bstr_t)vCapTypeName);
        composite = compositeType->CreateInstance();
        
		  if (manageOwnedAccountsCapName == ((_bstr_t)vCapTypeName ))
		  {
			composite->ActorAccountID = mAccountID;
		  }
        

				composite->ID = vCapInstanceID;
				mCapabilities[(long)vCapInstanceID]  = composite;
			}
			// the capability is atomic, look up it's parent in map
			//if not found - error because all composites get processed first
			//(not true as of 3.6 see comment below)

			//CR 10448 fix - it's too expensive to ORDER BY in the query. We
			//need to leave the ordering up to the code below
      else
      {
        capit = mCapabilities.find((long)vCapParentInstanceID);
        
				//ASSERT (capit != mCapabilities.end());
				//if record for parent object is not in the map
				//create it by parent_type_name and insert it there

				if(capit == mCapabilities.end())
				{
					vParentCapTypeName = rowset->GetValue("parent_type_name");
					ASSERT(V_VT(&vParentCapTypeName) != VT_NULL);
					MTAUTHLib::IMTCompositeCapabilityTypePtr compositeType = 
					security->GetCapabilityTypeByName((_bstr_t)vParentCapTypeName);
					composite = compositeType->CreateInstance();
					composite->ID = vCapParentInstanceID;
          
          		  if (manageOwnedAccountsCapName == ((_bstr_t)vCapTypeName ))
				  {
						composite->ActorAccountID = mAccountID;composite->ActorAccountID = mAccountID;
				  }
          
					mCapabilities[(long)vCapParentInstanceID]  = composite;
				}
				
				capit = mCapabilities.find((long)vCapParentInstanceID);
				ASSERT (capit != mCapabilities.end());
					
        //HACK: ensure there is no duplicate atomic instances:
        //TODO: fix on query
        dupit = dups.find((long)vCapInstanceID);
        if (dupit == dups.end())
        {
          //based on vCapTypeName call appropriate
          //GetAtomic... and set parameters
          dups.insert((long)vCapInstanceID);
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
			  else
        {
				  rowset->MoveNext();
				  continue;
			  }
		  }
		  rowset->MoveNext();
		}
	}
	catch (_com_error & err)
	{
		return LogAndReturnAuthError(err);
	}
	
	return S_OK;
}

STDMETHODIMP CMTSecurityContext::CheckAccess(IMTCompositeCapability* aCap)
{
  try
  {
    MTAUTHLib::IMTCompositeCapabilityPtr demandedCap = aCap;
    BOOL bSuccess(FALSE);
    CapIterator capit;
    for (capit = mCapabilities.begin(); capit != mCapabilities.end(); capit++)
    {
      if (capit->second->Implies(demandedCap, VARIANT_TRUE/*check atomics*/))
      {
        bSuccess = TRUE;
        //TODO: success audit trail
        return S_OK;
      }
    }
    
    //TODO: audit security failure
    char buf[1024];
	sprintf(buf, "Access Denied: Required Capability: %s ", (char*)demandedCap->ToString());
	MT_THROW_COM_ERROR(buf);
  }
  catch(_com_error& e)
  {
    return ReturnComError(e);
  }
  return S_OK;
}


STDMETHODIMP CMTSecurityContext::CoarseHasAccess(IMTCompositeCapability *aCap, VARIANT_BOOL *apHasAccess)
{
  try
  {
    (*apHasAccess) = VARIANT_FALSE;
    MTAUTHLib::IMTCompositeCapabilityPtr demandedCap = aCap;
    CapIterator capit;
    for (capit = mCapabilities.begin(); capit != mCapabilities.end(); capit++)
    {
      if (capit->second->Implies(demandedCap, VARIANT_FALSE/*do not check atomics*/))
      {
        (*apHasAccess) = VARIANT_TRUE;
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

STDMETHODIMP CMTSecurityContext::HasAccess(IMTCompositeCapability *aCap, VARIANT_BOOL *apHasAccess)
{
  try
  {
    (*apHasAccess) = VARIANT_FALSE;
    MTAUTHLib::IMTCompositeCapabilityPtr demandedCap = aCap;
    CapIterator capit;
    for (capit = mCapabilities.begin(); capit != mCapabilities.end(); capit++)
    {
      if (capit->second->Implies(demandedCap, VARIANT_TRUE/*do check atomics*/))
      {
        (*apHasAccess) = VARIANT_TRUE;
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

STDMETHODIMP CMTSecurityContext::get_AccountID(long *pVal)
{
	(*pVal) = mAccountID;

	return S_OK;
}

STDMETHODIMP CMTSecurityContext::put_AccountID(long newVal)
{
	mAccountID = newVal;

	return S_OK;
}

STDMETHODIMP CMTSecurityContext::IsInRole(BSTR aRoleName, VARIANT_BOOL *apResult)
{
	_bstr_t r = aRoleName;
	set<_bstr_t>::iterator it = mRoleNames.find(r);

	(*apResult) = (it != mRoleNames.end());
	
	return S_OK;
}


STDMETHODIMP CMTSecurityContext::ToXML(BSTR *apXMLString)
{
  try
  {
    MSXML2::IXMLDOMNodePtr topLevelNode;
    MSXML2::IXMLDOMNodePtr accountIDNode;
    MSXML2::IXMLDOMNodePtr rolesNode;
    MSXML2::IXMLDOMNodePtr capsNode;
    MSXML2::IXMLDOMNodePtr roleNode;
    MSXML2::IXMLDOMNodePtr compositeCapNode;
    MSXML2::IXMLDOMNodePtr atomicCapsNode;
    MSXML2::IXMLDOMNodePtr atomicCapNode;
    MSXML2::IXMLDOMNodePtr textNode;
    MSXML2::IXMLDOMNodePtr valueNode;
    MSXML2::IXMLDOMNodePtr opNode;
    MSXML2::IXMLDOMNodePtr wcNode;
	MSXML2::IXMLDOMNodePtr appNameNode;
    MSXML2::IXMLDOMNodePtr loggedInAsNode;

    MTAUTHLib::IMTAtomicCapabilityPtr atomic;
    _variant_t elType;
    elType.ChangeType(VT_I2);
    elType.iVal = NODE_ELEMENT;
    
    
    MSXML2::IXMLDOMDocumentPtr domdoc("Microsoft.XMLDOM");
    accountIDNode = domdoc->createNode(elType, ACCOUNT_ID_TAG, "");

    char strAccountID[25];
    _ltoa(mAccountID, strAccountID, 10);
    accountIDNode->text = strAccountID;
    
    topLevelNode = domdoc->createNode(elType, SECURITY_CONTEXT_TAG, "");
    topLevelNode->appendChild(accountIDNode);
    rolesNode = domdoc->createNode(elType, ROLES_TAG, "");
    capsNode = domdoc->createNode(elType, COMPOSITE_CAPS_TAG, "");

    RoleNameSet::iterator roleit = mRoleNames.begin();

    for(;roleit != mRoleNames.end();++roleit)
    {
      _bstr_t roleName = (*roleit);
      roleNode = domdoc->createNode(elType, ROLE_TAG, "");
      roleNode->text = roleName;
      rolesNode->appendChild(roleNode);
    }
    topLevelNode->appendChild(rolesNode);
    
    //append capabilities
    CapIterator capit = mCapabilities.begin();
    while( capit != mCapabilities.end() )
    {
      MTAUTHLib::IMTCompositeCapabilityPtr composite = capit->second;
      compositeCapNode = domdoc->createNode(elType, COMPOSITE_CAP_TAG, "");
      textNode = domdoc->createNode(elType, AUTH_NAME_TAG, "");
      textNode->text = composite->CapabilityType->Name;
      compositeCapNode->appendChild(textNode);
      textNode = domdoc->createNode(elType, AUTH_PROGID_TAG, "");
      textNode->text = composite->CapabilityType->ProgID;
      compositeCapNode->appendChild(textNode);
      textNode = domdoc->createNode(elType, DBID_TAG, "");
      char strID[25];
      _ltoa(composite->ID, strID, 10);
      textNode->text = strID;
      compositeCapNode->appendChild(textNode);
      
      //generate XML directly until ToXML is implemented
      long numAtomics = composite->AtomicCapabilities->Count;
      if(numAtomics > 0)
      {
        atomicCapsNode = domdoc->createNode(elType, ATOMIC_CAPS_TAG, "");
        MTAUTHLib::IMTEnumTypeCapabilityPtr enumPtr = composite->GetAtomicEnumCapability();
        MTAUTHLib::IMTPathCapabilityPtr pathPtr = composite->GetAtomicPathCapability();
        MTAUTHLib::IMTDecimalCapabilityPtr decPtr = composite->GetAtomicDecimalCapability();
        MTAUTHLib::IMTStringCollectionCapabilityPtr strColPtr = composite->GetAtomicCollectionCapability();

        if(enumPtr != NULL)
        {
          atomicCapNode = domdoc->createNode(elType, ENUMTYPE_CAP_TAG, "");
          valueNode = domdoc->createNode(elType, VALUE_TAG, "");
          valueNode->text = (_bstr_t)enumPtr->GetParameter()->Value;
          atomicCapNode->appendChild(valueNode);
          atomicCapsNode->appendChild(atomicCapNode);
          
        }
        
        if(pathPtr != NULL)
        {
          atomicCapNode = domdoc->createNode(elType, PATH_CAP_TAG, "");
          valueNode = domdoc->createNode(elType, VALUE_TAG, "");
          wcNode = domdoc->createNode(elType, WILDCARD_TAG, "");
          valueNode->text = (_bstr_t)pathPtr->GetParameter()->Path;
          char strWC[25];
          _ltoa((int)pathPtr->GetParameter()->WildCard, strWC, 10);
          wcNode->text = strWC;
          atomicCapNode->appendChild(valueNode);
          atomicCapNode->appendChild(wcNode);
          atomicCapsNode->appendChild(atomicCapNode);
        }
        if(decPtr != NULL)
        {
          atomicCapNode = domdoc->createNode(elType, DECIMAL_CAP_TAG, "");
          valueNode = domdoc->createNode(elType, VALUE_TAG, "");
          opNode = domdoc->createNode(elType, OP_TAG, "");
          valueNode->text = (_bstr_t)decPtr->GetParameter()->Value;
          opNode->text = (_bstr_t)decPtr->GetParameter()->Test;
          atomicCapNode->appendChild(valueNode);
          atomicCapNode->appendChild(opNode);
          atomicCapsNode->appendChild(atomicCapNode);
        }
        if(strColPtr != NULL)
		{
			atomicCapNode = domdoc->createNode(elType, STR_COL_CAP_TAG, "");
			MTAUTHLib::IMTCollectionPtr colPtr = strColPtr->GetParameter();
			long count = 0;
			colPtr->get_Count(&count);
			for(int idx = 1; idx <= count; idx++)
			{
				_bstr_t value;
				colPtr->get_Item(idx, (VARIANT *)&value);
				valueNode = domdoc->createNode(elType, VALUE_TAG, "");
				valueNode->text = value;
				atomicCapNode->appendChild(valueNode);
			}

			atomicCapsNode->appendChild(atomicCapNode);
		}

        compositeCapNode->appendChild(atomicCapsNode);
      }
      capsNode->appendChild(compositeCapNode);
      
      capit++;
    }
    topLevelNode->appendChild(capsNode);
    
	// additional information about who was logged in    
	appNameNode = domdoc->createNode(elType, APPLICATION_NAME_TAG, "");    
	appNameNode->text = mApplicationName;    
    
	topLevelNode->appendChild(appNameNode);
	

	loggedInAsNode = domdoc->createNode(elType, LOGGEDINAS_TAG, "");    
	loggedInAsNode->text = mLoggedInAs;    
    
	topLevelNode->appendChild(loggedInAsNode);
	
    //base 64 encode it
    _bstr_t bstrTemp = (char*)topLevelNode->xml;
    char* temp = (char*)bstrTemp;
	LogAuthDebug("In ToXML");
    LogAuthDebug(temp);

    BYTE* byte = NULL;
    byte = (BYTE*)temp;
    
    ULONG len = strlen(temp);
    std::string dest;
    
    BOOL ok = rfc1421encode_nonewlines(byte, len, dest);
    if (!ok)
      return Error("Unable to encode session context");
    _bstr_t bstrOut = dest.c_str();
    
    (*apXMLString) = bstrOut.copy();
    
  }
  catch(_com_error& e)
  {
    return LogAndReturnAuthError(e);
  }
  
  
  return S_OK;
}

STDMETHODIMP CMTSecurityContext::FromXML(BSTR aXMLString)
{
  try
  {
    MTAUTHLib::IMTSecurityPtr security(__uuidof(MTAUTHLib::MTSecurity));
    MSXML2::IXMLDOMNodeListPtr roleNodes = NULL;
    
    MSXML2::IXMLDOMNodePtr securityContextNodePtr = NULL;
    MSXML2::IXMLDOMNodeListPtr atomicCapNodes = NULL;
    MSXML2::IXMLDOMNodeListPtr capNodes = NULL;
    MSXML2::IXMLDOMNodePtr atomicCapsNode = NULL;
    MSXML2::IXMLDOMNodePtr atomicCapNode = NULL;
    MSXML2::IXMLDOMNodePtr topLevelNode = NULL;
    MSXML2::IXMLDOMNodePtr rolesNode= NULL;
    MSXML2::IXMLDOMNodePtr roleNode = NULL;
    MSXML2::IXMLDOMNodePtr capNode = NULL;
    MSXML2::IXMLDOMNodePtr progidNode = NULL;
    MSXML2::IXMLDOMNodePtr dbidNode = NULL;
    MSXML2::IXMLDOMNodePtr paramNode = NULL;
    MSXML2::IXMLDOMNodePtr nameNode = NULL;
    MSXML2::IXMLDOMNodePtr accountIDNode = NULL;
    MSXML2::IXMLDOMNodePtr appNameNode = NULL;
    MSXML2::IXMLDOMNodePtr loggedInAsNode = NULL;
    
    //<roles>
    //	<role>Super User</role>
    //</roles>
    //<caps>
    // <cap>
    //	 <progid>Metratech.MTManageAH</progid>
    //	 <dbid>111</dbid>
    // </cap>
    //</caps>
    
    _bstr_t manageOwnedAccountsCapName(L"Manage Owned Accounts");
    _bstr_t encodedString(aXMLString);
    
    //decode it first;
    int alen = strlen(encodedString);
    int len = encodedString.length();
    std::vector<unsigned char> dest;
    int err = rfc1421decode((const char*)encodedString, len, dest);
    if (err != ERROR_NONE)
      MT_THROW_COM_ERROR("Unable to decode session context");
    
    char * szTemp;
    szTemp = new char[dest.size()+1];
    
    memcpy(szTemp, &dest[0], dest.size());
    szTemp[dest.size()]='\0';
    
    _bstr_t decodedString(szTemp);
		delete [] szTemp;
    
	LogAuthDebug("In FromXML");
	LogAuthDebug(decodedString);

    MSXML2::IXMLDOMDocumentPtr domdoc("Microsoft.XMLDOM");
    domdoc->loadXML(decodedString);
    securityContextNodePtr = domdoc->selectSingleNode(SECURITY_CONTEXT_TAG);
    accountIDNode = securityContextNodePtr->selectSingleNode(ACCOUNT_ID_TAG);
    if(accountIDNode == NULL)
      MT_THROW_COM_ERROR(MTAUTH_SESSION_CONTEXT_DESERIALIZATION_FAILED);
    long lAccountID = atol(accountIDNode->text);
    mAccountID = lAccountID;
    roleNodes = domdoc->getElementsByTagName(ROLE_TAG);
    
    for(;;)
    {
      roleNode = roleNodes->nextNode();
      //no more
      if(roleNode == NULL)
        break;
      mRoleNames.insert(roleNode->text);
    }
    
    //construct capabilities collection
    
    capNodes = domdoc->getElementsByTagName(COMPOSITE_CAP_TAG);
    for(;;)
    {
      capNode = capNodes->nextNode();
      //no more
      if(capNode == NULL)
        break;
      
      progidNode = capNode->selectSingleNode(AUTH_PROGID_TAG);
      if(progidNode == NULL)
        MT_THROW_COM_ERROR(MTAUTH_SESSION_CONTEXT_DESERIALIZATION_FAILED);
      dbidNode = capNode->selectSingleNode(DBID_TAG);
      if(dbidNode == NULL)
        MT_THROW_COM_ERROR(MTAUTH_SESSION_CONTEXT_DESERIALIZATION_FAILED);
      
      nameNode = capNode->selectSingleNode(AUTH_NAME_TAG);
      if(nameNode == NULL)
        MT_THROW_COM_ERROR(MTAUTH_SESSION_CONTEXT_DESERIALIZATION_FAILED);
      
      //_bstr_t progID = progidNode->text;
      MTAUTHLib::IMTCompositeCapabilityPtr composite;
      composite = security->GetCapabilityTypeByName(nameNode->text)->CreateInstance();
      composite->FromXML(capNode);
      long lDBID = atol(dbidNode->text);
      composite->ID = lDBID;
	  
      if ((_bstr_t)(nameNode->text) == manageOwnedAccountsCapName)
			{
				composite->ActorAccountID = mAccountID;
			}
     
				mCapabilities[(long)composite->ID] = composite;      
		}
    
		// additional information about who was logged in

		appNameNode = securityContextNodePtr->selectSingleNode(APPLICATION_NAME_TAG);

		if(appNameNode != NULL)
			mApplicationName = appNameNode->text;      

		loggedInAsNode = securityContextNodePtr->selectSingleNode(LOGGEDINAS_TAG);

    if(loggedInAsNode != NULL)
			mLoggedInAs = loggedInAsNode->text;    
	}
  catch(_com_error& e)
  {
    return LogAndReturnAuthError(e);
  }
  
  
  return S_OK;
}



STDMETHODIMP CMTSecurityContext::IsSuperUser(VARIANT_BOOL *apRes)
{
	CapIterator it = mCapabilities.begin();
	(*apRes) = VARIANT_FALSE;
	try
	{
		MTAUTHLib::IMTCompositeCapabilityPtr cap;
		
		for(; it != mCapabilities.end(); it++)
		{
			cap = it->second;
			if (_wcsicmp((wchar_t*)cap->CapabilityType->ProgID, L"metratech.MTAllCapability") == 0)
			{
				(*apRes) = VARIANT_TRUE;
				return S_OK;
			}
			
		}
	}
	catch(_com_error& e)
	{
		return ReturnComError(e);
	}
	
	return S_OK;
}

STDMETHODIMP CMTSecurityContext::GetCapabilitiesOfType(BSTR aTypeName, IMTCollection **apColl)
{
	
  if (apColl == NULL)
    return E_POINTER;
  (*apColl) = NULL;
  try
  {
    _bstr_t bstrName = aTypeName;
    MTObjectCollection<IMTCompositeCapability> outColl;
    
    CapIterator it = mCapabilities.begin();
    for(; it != mCapabilities.end(); it++)
    {
      MTAUTHLib::IMTCompositeCapabilityPtr cap = it->second;
      if (_wcsicmp((wchar_t*)cap->CapabilityType->Name, (wchar_t*)bstrName) == 0)
      {
        outColl.Add((IMTCompositeCapability*)cap.GetInterfacePtr());
      }
    }
    outColl.CopyTo(apColl);
  }
  catch(_com_error& e)
  {
    return LogAndReturnAuthError(e);
  }
  return S_OK;
}

STDMETHODIMP CMTSecurityContext::get_LoggedInAs(BSTR *pVal)
{
	*pVal = mLoggedInAs.copy();
	return S_OK;
}

STDMETHODIMP CMTSecurityContext::put_LoggedInAs(BSTR newVal)
{
	mLoggedInAs = newVal;
	return S_OK;
}

STDMETHODIMP CMTSecurityContext::get_ApplicationName(BSTR *pVal)
{
	*pVal = mApplicationName.copy();
	return S_OK;
}

STDMETHODIMP CMTSecurityContext::put_ApplicationName(BSTR newVal)
{
	mApplicationName = newVal;
	return S_OK;
}
