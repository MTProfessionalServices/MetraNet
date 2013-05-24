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

#ifndef __MTSECURITYPRINCIPALIMPLBASE_H__
#define __MTSECURITYPRINCIPALIMPLBASE_H__
#pragma once

#include <MTPrincipalPolicy.h>


template<class T,const IID* piid, const GUID* plibid>
class MTSecurityPrincipalImplBase : public IDispatchImpl<T,piid,plibid>
{
public:
	MTSecurityPrincipalImplBase() 
	{
		mActivePolicy = NULL;
		mDefaultPolicy = NULL;
		mID = -1;
	}
	virtual ~MTSecurityPrincipalImplBase() {}

  STDMETHOD(LogAndReturnPrincipalError)(_com_error& err)  = 0;
  STDMETHOD(LogPrincipalError)(char* aMsg)  = 0;


	STDMETHOD(get_ID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_ID)(/*[in]*/ long newVal);
	STDMETHOD(get_PrincipalType)(/*[out, retval]*/ MTSecurityPrincipalType *pVal);
	STDMETHOD(put_PrincipalType)(/*[in]*/ MTSecurityPrincipalType newVal);
	STDMETHOD(GetActivePolicy)(/*[in]*/IMTSessionContext* aCtx,/*[out, retval]*/ IMTPrincipalPolicy** apPolicy);
  STDMETHOD(InternalGetActivePolicy)(IMTPrincipalPolicy** apPolicy);
	STDMETHOD(GetDefaultPolicy)(/*[in]*/IMTSessionContext* aCtx, /*[out, retval]*/ IMTPrincipalPolicy** apPolicy);
	STDMETHOD(Save)(IMTSecurityPrincipal* aConcretePrincipal);
  STDMETHOD(FromXML)(/*[in]*/IMTSessionContext* aCtx, BSTR aXmlString);
  STDMETHOD(ToXML)(BSTR* apXmlString);
  STDMETHOD(get_SessionContext)(/*[out, retval]*/ IMTSessionContext** pVal);
	STDMETHOD(put_SessionContext)(/*[in]*/ IMTSessionContext* newVal);

protected:
	MTAUTHLib::IMTPrincipalPolicyPtr mActivePolicy;
	MTAUTHLib::IMTPrincipalPolicyPtr mDefaultPolicy;
  MTAUTHLib::IMTSessionContextPtr mSessionContext;
	long mID;
	MTSecurityPrincipalType mPrincipalType;
private:
  //bool IsActivePolicy(_bstr_t& aTag);
  //bool IsDefaultPolicy(_bstr_t& aTag);
  //MTAUTHLib::IMTPrincipalPolicyPtr CreatePrincipalPolicy();


};


template<class T,const IID* piid, const GUID* plibid>
STDMETHODIMP MTSecurityPrincipalImplBase<T,piid,plibid>::get_ID(long *aVal)
{
	(*aVal) = mID;
	return S_OK;
}

template<class T,const IID* piid, const GUID* plibid>
STDMETHODIMP MTSecurityPrincipalImplBase<T,piid,plibid>::put_ID(long newVal)
{
	//Properties.Item("ID").Value = 
	mID = newVal;

	return S_OK;
}

template<class T,const IID* piid, const GUID* plibid>
STDMETHODIMP MTSecurityPrincipalImplBase<T,piid,plibid>::get_SessionContext(IMTSessionContext** aVal)
{
  if(mSessionContext == NULL) {
    return E_POINTER;
  }
	(*aVal) = reinterpret_cast<IMTSessionContext*>(mSessionContext.GetInterfacePtr());
	(*aVal)->AddRef();
	return S_OK;
}

template<class T,const IID* piid, const GUID* plibid>
STDMETHODIMP MTSecurityPrincipalImplBase<T,piid,plibid>::put_SessionContext(IMTSessionContext* newVal)
{
	mSessionContext = newVal;
	return S_OK;
}


template<class T,const IID* piid, const GUID* plibid>
STDMETHODIMP MTSecurityPrincipalImplBase<T,piid,plibid>::get_PrincipalType(MTSecurityPrincipalType* apVal)
{
	(*apVal) = mPrincipalType;

	return S_OK;
}

template<class T,const IID* piid, const GUID* plibid>
STDMETHODIMP MTSecurityPrincipalImplBase<T,piid,plibid>::put_PrincipalType(MTSecurityPrincipalType newVal)
{
	mPrincipalType = newVal;
	return S_OK;
}

template<class T,const IID* piid, const GUID* plibid>
STDMETHODIMP MTSecurityPrincipalImplBase<T,piid,plibid>::Save(IMTSecurityPrincipal* aPrincipal)
{
	try
	{
		//do sec check and audit
    if(mActivePolicy)
			mActivePolicy->Save();
		if(mDefaultPolicy)
			mDefaultPolicy->Save();
	}
	catch(_com_error& e)
	{
		return LogAndReturnPrincipalError(e);
	}
	return S_OK;
}

template<class T,const IID* piid, const GUID* plibid>
STDMETHODIMP MTSecurityPrincipalImplBase<T,piid,plibid>::GetActivePolicy(/*[in]*/IMTSessionContext* aCtx, 
																																		 /*[out, retval]*/ IMTPrincipalPolicy** apPolicy)
{
	//TODO: check security here?
	try
	{
		if (mActivePolicy == NULL)
		{
      MTAUTHLib::IMTPrincipalPolicyPtr pp(__uuidof(MTAUTHLib::MTPrincipalPolicy));
      mSessionContext = aCtx;
			mActivePolicy =  
			pp->GetActive((MTAUTHLib::IMTSessionContext*) aCtx,
			reinterpret_cast<MTAUTHLib::IMTSecurityPrincipal*>(this));
		}
		MTAUTHLib::IMTPrincipalPolicyPtr outPtr = mActivePolicy;
		(*apPolicy) = (IMTPrincipalPolicy*)outPtr.Detach();
	}
	catch(_com_error& e)
	{
		return LogAndReturnPrincipalError(e);
	}

	return S_OK;
}

template<class T,const IID* piid, const GUID* plibid>
STDMETHODIMP MTSecurityPrincipalImplBase<T,piid,plibid>::GetDefaultPolicy(/*[in]*/IMTSessionContext* aCtx, 
																																			/*[out, retval]*/ IMTPrincipalPolicy** apPolicy)
{
	//TODO: check security here?
	try
	{
		if (mDefaultPolicy == NULL)
		{
			MTAUTHLib::IMTPrincipalPolicyPtr pp(__uuidof(MTAUTHLib::MTPrincipalPolicy));
      mSessionContext = aCtx;
			mDefaultPolicy = pp->GetDefault((MTAUTHLib::IMTSessionContext*) aCtx,
				reinterpret_cast<MTAUTHLib::IMTSecurityPrincipal*>(this));
		}
		MTAUTHLib::IMTPrincipalPolicyPtr outPtr = mDefaultPolicy;
		(*apPolicy) = (IMTPrincipalPolicy*)outPtr.Detach();
	}
	catch(_com_error& e)
	{
		return LogAndReturnPrincipalError(e);
	}

	return S_OK;
}

template<class T,const IID* piid, const GUID* plibid>
STDMETHODIMP MTSecurityPrincipalImplBase<T,piid,plibid>::InternalGetActivePolicy(IMTPrincipalPolicy** apPolicy)
{
	HRESULT hr(S_OK);
  try
	{
		CMTPrincipalPolicy* pDirectPolicy;
    if (mActivePolicy == NULL)
		{
			MTAUTHLib::IMTPrincipalPolicyPtr pp(__uuidof(MTAUTHLib::MTPrincipalPolicy));
      hr = pp.QueryInterface(IID_NULL, (void**)&pDirectPolicy);
      if(FAILED(hr))
        MT_THROW_COM_ERROR(hr);
			hr = pDirectPolicy->InternalGet(
			  reinterpret_cast<IMTSecurityPrincipal*>(this), 
        ACTIVE_POLICY, 
        (IMTPrincipalPolicy**)&mActivePolicy);
		}
		MTAUTHLib::IMTPrincipalPolicyPtr outPtr = mActivePolicy;
		(*apPolicy) = (IMTPrincipalPolicy*)outPtr.Detach();
	}
	catch(_com_error& e)
	{
		return LogAndReturnPrincipalError(e);
	}
  
	return S_OK;
}

template<class T,const IID* piid, const GUID* plibid>
STDMETHODIMP MTSecurityPrincipalImplBase<T,piid,plibid>::FromXML(/*[in]*/IMTSessionContext* aCtx, BSTR aXmlString)
{
	//TODO: check security here?
	try
	{
    bool GotActive = false;
    bool GotDefault = false;

    mSessionContext = aCtx;
    //retrieve all policy tags
    //throw errors for types that are not active or default
    MSXML2::IXMLDOMNodePtr prNode = NULL;
    MSXML2::IXMLDOMNodePtr policiesNode = NULL;
    MSXML2::IXMLDOMNodeListPtr policyNodes = NULL;
    MSXML2::IXMLDOMNodePtr policyNode = NULL;
    MSXML2::IXMLDOMNodePtr textNode = NULL;
    MSXML2::IXMLDOMNodePtr typeAttrib;
    MSXML2::IXMLDOMNamedNodeMapPtr attribs;
		MSXML2::IXMLDOMDocumentPtr domdoc("Microsoft.XMLDOM");
    _bstr_t xml = aXmlString;
		domdoc->loadXML(xml);
		
    domdoc->raw_selectSingleNode(_bstr_t(PRINCIPAL_TAG), &prNode);
    if(prNode == NULL)
    {
      LogPrincipalError("'principal' set not found!");
      MT_THROW_COM_ERROR(MTAUTH_SECURITY_PRINCIPAL_DESERIALIZATION_FAILED);
    }

    prNode->raw_selectSingleNode(_bstr_t(POLICIES_TAG), &policiesNode);
    
    if(policiesNode == NULL)
    {
      LogPrincipalError("'policies' set not found!");
      MT_THROW_COM_ERROR(MTAUTH_SECURITY_PRINCIPAL_DESERIALIZATION_FAILED);
    }
    domdoc->raw_getElementsByTagName(_bstr_t(POLICY_TAG), &policyNodes);
    if(policyNodes == NULL)
    {
      //TODO: do we log warning?
      char buf[512];
      sprintf(buf, "Principal Contains 0 policies, exiting");
      LogPrincipalError(buf);
      return S_OK;
    }

		for(;;)
		{
			policyNodes->raw_nextNode(&policyNode);
      //no more
			if(policyNode == NULL)
				break;
      attribs = policyNode->attributes;
      attribs->raw_getNamedItem(_bstr_t(TYPE_ATTRIB), &typeAttrib);
      _variant_t vAttribValue;
       typeAttrib->get_nodeValue(&vAttribValue);
      _bstr_t bstrPolicyType = (_bstr_t)vAttribValue;
      
      if(stricmp((char*)bstrPolicyType, "A") == 0)
      {
        if(GotActive)
        {
          LogPrincipalError("More then one Active Policy is found!");
          MT_THROW_COM_ERROR(MTAUTH_SECURITY_PRINCIPAL_DESERIALIZATION_FAILED);
        }
        GotActive = true;
        MTAUTHLib::IMTPrincipalPolicyPtr pp(__uuidof(MTAUTHLib::MTPrincipalPolicy));
        pp->PolicyType =  MTAUTHLib::ACTIVE_POLICY;
        pp->Principal = reinterpret_cast<MTAUTHLib::IMTSecurityPrincipal*>(this);
        pp->FromXML((MTAUTHLib::IMTSessionContext*)aCtx, policyNode);
        mActivePolicy = pp;
      }
      else if(stricmp((char*)bstrPolicyType, "D") == 0)
      {
        if(GotDefault)
        {
          LogPrincipalError("More then one Default Policy is found!");
          MT_THROW_COM_ERROR(MTAUTH_SECURITY_PRINCIPAL_DESERIALIZATION_FAILED);
        }
        GotDefault = true;
        MTAUTHLib::IMTPrincipalPolicyPtr pp(__uuidof(MTAUTHLib::MTPrincipalPolicy));
        pp->PolicyType =  MTAUTHLib::DEFAULT_POLICY;
        pp->Principal = reinterpret_cast<MTAUTHLib::IMTSecurityPrincipal*>(this);
        pp->FromXML((MTAUTHLib::IMTSessionContext*)aCtx, policyNode);
        mDefaultPolicy = pp;
      }
      else
      {
        char buf[512];
        sprintf(buf, "Unknown Policy Type: <%s> ('A' and 'D' are known ones)", (char*)bstrPolicyType);
        LogPrincipalError(buf);
        MT_THROW_COM_ERROR(MTAUTH_SECURITY_PRINCIPAL_DESERIALIZATION_FAILED);
      }
      
		}
	}
	catch(_com_error& e)
	{
		return LogAndReturnPrincipalError(e);
	}

	return S_OK;
}

template<class T,const IID* piid, const GUID* plibid>
STDMETHODIMP MTSecurityPrincipalImplBase<T,piid,plibid>::ToXML(BSTR* apXmlString)
{
	//TODO: check security here?
	try
	{
		return E_NOTIMPL;
	}
	catch(_com_error& e)
	{
		return LogAndReturnPrincipalError(e);
	}

	return S_OK;
}
/*
template<class T,const IID* piid, const GUID* plibid>
MTAUTHLib::IMTPrincipalPolicyPtr MTSecurityPrincipalImplBase<T,piid,plibid>::CreatePrincipalPolicy()
{
  CComObject<CMTPrincipalPolicy> * directPP;
 	CComObject<CMTPrincipalPolicy>::CreateInstance(&directPP);
  MTAUTHLib::IMTPrincipalPolicyPtr outPtr;
 
	HRESULT hr =  directPP->QueryInterface(IID_IMTPrincipalPolicy,
						reinterpret_cast<void**>(&outPtr));
  if (FAILED(hr))
			MT_THROW_COM_ERROR("Failed to QueryInterface on direct CMTPrincipalPolicy");

  return outPtr;
}
*/
#endif // __MTSECURITYPRINCIPALIMPLBASE_H__