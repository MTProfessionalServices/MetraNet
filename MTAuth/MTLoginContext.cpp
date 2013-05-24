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


// MTLoginContext.cpp : Implementation of CMTLoginContext
#include <StdAfx.h>
#include <MTAuth.h>
#include <MTLoginContext.h>
#include <MTSecurityContext.h>
#include <MTSessionContext.h>


/////////////////////////////////////////////////////////////////////////////
// CMTLoginContext

STDMETHODIMP CMTLoginContext::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTLoginContext
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

STDMETHODIMP CMTLoginContext::Login(BSTR aAlias, BSTR aNamespace, BSTR aPassword, IMTSessionContext **aCtx)
{
	try
	{
		COMKIOSKLib::ICOMCredentialsPtr credentials(__uuidof(COMKIOSKLib::COMCredentials));
		COMKIOSKLib::ICOMKioskAuthPtr kiosk(__uuidof(COMKIOSKLib::COMKioskAuth));
	
		credentials->LoginID = aAlias;
		credentials->Name_Space = aNamespace;
		credentials->pwd = aPassword;

		kiosk->Initialize();

		VARIANT_BOOL bAuthentic = kiosk->IsAuthentic(credentials);
    if(bAuthentic == VARIANT_FALSE)
      MT_THROW_COM_ERROR(MTAUTH_LOGON_DENIED);


	  MTAUTHLib::IMTSessionContextPtr sessctx = CreateAndInitSessionContext(aAlias, aNamespace);

		(*aCtx) = reinterpret_cast<IMTSessionContext*>(sessctx.Detach());

	}
	catch(_com_error& e)
	{
		return ReturnComError(e);
	}
	return S_OK;
}

STDMETHODIMP CMTLoginContext::LoginWithAdditionalData(BSTR aAlias, BSTR aNamespace, BSTR aPassword, BSTR aLoggedInAs, BSTR aApplicationName, IMTSessionContext **aCtx)
{
	Login(aAlias, aNamespace, aPassword, aCtx);

	if(aLoggedInAs)
	{
		(*aCtx)->put_LoggedInAs(aLoggedInAs);
	}

	if (aApplicationName)
	{
		(*aCtx)->put_ApplicationName(aApplicationName);
	}

	return S_OK;
}

STDMETHODIMP CMTLoginContext::LoginAnonymous(IMTSessionContext **aCtx)
{
	try
	{
		// the anonymous context is cached.
		// return a pointer to the already created version if it exists
		if (mAnonymousContext == NULL)
		{
			mAnonymousContext = CreateAndInitSessionContext(_bstr_t("anonymous"), _bstr_t("auth"));
		}
		(*aCtx) = reinterpret_cast<IMTSessionContext*>(mAnonymousContext.GetInterfacePtr());
		(*aCtx)->AddRef();
	}
	catch(_com_error& e)
	{
		return LogAndReturnAuthError(e);
	}
	return S_OK;
}

STDMETHODIMP CMTLoginContext::LoginWithTicket(BSTR aNameSpace, BSTR aTicket, IMTSessionContext **apCtx)
{
	try
	{
		MTAUTHLib::IMTSessionContextPtr sessctx;
		COMKIOSKLib::ICOMCredentialsPtr credentials(__uuidof(COMKIOSKLib::COMCredentials));
		COMKIOSKLib::ICOMKioskAuthPtr kiosk(__uuidof(COMKIOSKLib::COMKioskAuth));
	
		credentials->Name_Space = aNameSpace;
		credentials->Ticket = aTicket;

		kiosk->Initialize();

		VARIANT_BOOL bAuthentic = kiosk->IsAuthentic(credentials);
    if(bAuthentic == VARIANT_FALSE)
      MT_THROW_COM_ERROR(MTAUTH_LOGON_DENIED);

		sessctx = CreateAndInitSessionContextWithAdditionalData(credentials->LoginID, credentials->Name_Space, credentials->LoggedInAs, credentials->ApplicationName);

		(*apCtx) = reinterpret_cast<IMTSessionContext*>(sessctx.Detach());
	}
	catch(_com_error& e)
	{
		return ReturnComError(e);
	}
	return S_OK;
}

STDMETHODIMP CMTLoginContext::LoginAsAccount(/*[in]*/ IMTSessionContext * apCurrentContext,
																						 /*[in]*/ int aAccountID,
																						 /*[out, retval]*/IMTSessionContext** apCtx)
{
	try
	{
	  MTAUTHLib::IMTSessionContextPtr currentCtx = apCurrentContext;
    MTAUTHLib::IMTSecurityPtr mSec(__uuidof(MTAUTHLib::MTSecurity));
    currentCtx->SecurityContext->CheckAccess
      (mSec->GetCapabilityTypeByName("Unlimited Capability")->CreateInstance());

    long lAccountID = aAccountID;
    //look up credentials based on this account id
    
    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		
		rowset->SetQueryTag("__GET_ACCOUNT_CREDENTIALS__");
		_bstr_t bstrName;
    _bstr_t bstrNameSpace;
    rowset->AddParam("%%ID%%", (long)aAccountID);
    rowset->Execute();

    //there could be multiple mappings, just get the first one
		if(rowset->GetRowsetEOF().boolVal == VARIANT_FALSE)
		{
      bstrName = rowset->GetValue("nm_login");
      bstrNameSpace = rowset->GetValue("nm_space");
    }
    else
    {
      char buf[256];
      sprintf(buf, "There are no mappings in t_account_mapper for account id <%d>", aAccountID);
      MT_THROW_COM_ERROR(buf);
    }

    MTAUTHLib::IMTSessionContextPtr sessctx = CreateAndInitSessionContext(bstrName, bstrNameSpace);
		
		(*apCtx) = reinterpret_cast<IMTSessionContext*>(sessctx.Detach());
	}
	catch(_com_error& e)
	{
		return ReturnComError(e);
	}

	return S_OK;
}

STDMETHODIMP CMTLoginContext::LoginAsAccountByName(/*[in]*/ IMTSessionContext * apCurrentContext, /*[in]*/ BSTR aNamespace, /*[in]*/ BSTR aUserName,
														/*[out, retval]*/IMTSessionContext** apCtx)
{
	try
	{
		MTAUTHLib::IMTSessionContextPtr currentCtx = apCurrentContext;
		MTAUTHLib::IMTSecurityPtr mSec(__uuidof(MTAUTHLib::MTSecurity));
		currentCtx->SecurityContext->CheckAccess
		  (mSec->GetCapabilityTypeByName("Unlimited Capability")->CreateInstance());

	    MTAUTHLib::IMTSessionContextPtr sessctx = CreateAndInitSessionContext(aUserName, aNamespace, apCurrentContext);

		(*apCtx) = reinterpret_cast<IMTSessionContext*>(sessctx.Detach());
	}
	catch(_com_error& e)
	{
		return ReturnComError(e);
	}

	return S_OK;

}

STDMETHODIMP CMTLoginContext::LoginAsMPSAccount(IMTSessionContext * apCurrentContext, BSTR aNamespace, BSTR aUserName, IMTSessionContext** apCtx)
{
try
	{
	  MTAUTHLib::IMTSessionContextPtr currentCtx = apCurrentContext;
    MTAUTHLib::IMTSecurityPtr mSec(__uuidof(MTAUTHLib::MTSecurity));

	
    currentCtx->SecurityContext->CheckAccess
		(mSec->GetCapabilityTypeByName("Impersonation")->CreateInstance());

	ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
	
		rowset->SetQueryTag("__IS_SYSTEM_MPS_USER__");
		rowset->AddParam("%%NAMESPACE%%", aNamespace);
		rowset->AddParam("%%USERNAME%%", aUserName);
		rowset->Execute(); 

		if(rowset->GetRowsetEOF().boolVal == VARIANT_FALSE)
		{
			MTAUTHLib::IMTSessionContextPtr sessctx = CreateAndInitSessionContext(aUserName, aNamespace);
			 
				(*apCtx) = reinterpret_cast<IMTSessionContext*>(sessctx.Detach());
		}
		else
		{
			char buf[256]; 
			sprintf(buf, "User does not exist or not part of MPS name space for username <%d>", aUserName);
			MT_THROW_COM_ERROR(buf);
		}
	}
	catch(_com_error& e)
	{
		return ReturnComError(e);
	}

	return S_OK;
}

STDMETHODIMP CMTLoginContext::LoginAsMPSAccountWithAdditionalData(IMTSessionContext * apCurrentContext, BSTR aNamespace, BSTR aUserName, BSTR aLoggedInAs, BSTR aApplicationName, IMTSessionContext** apCtx)
{
	LoginAsMPSAccount(apCurrentContext, aNamespace, aUserName, apCtx);

	if(aLoggedInAs)
	{
		(*apCtx)->put_LoggedInAs(aLoggedInAs);
	}

	if (aApplicationName)
	{
		(*apCtx)->put_ApplicationName(aApplicationName);
	}

	return S_OK;
}

MTAUTHLib::IMTSecurityContextPtr CMTLoginContext::CreateSecurityContext()
{
  CComObject<CMTSecurityContext> * directSc;
 	CComObject<CMTSecurityContext>::CreateInstance(&directSc);
  MTAUTHLib::IMTSecurityContextPtr outPtr;
 
	HRESULT hr =  directSc->QueryInterface(IID_IMTSecurityContext,
						reinterpret_cast<void**>(&outPtr));
  if (FAILED(hr))
			MT_THROW_COM_ERROR("Failed to QueryInterface on direct CMTSecurityContextObject");

  return outPtr;
}

MTAUTHLib::IMTSessionContextPtr CMTLoginContext::CreateAndInitSessionContext(BSTR aName, BSTR aNameSpace)
{
  CComObject<CMTSecurityContext> * directSc;
 	CComObject<CMTSecurityContext>::CreateInstance(&directSc);
  MTAUTHLib::IMTSecurityContextPtr secCtxPtr;
  MTAUTHLib::IMTSessionContextPtr outPtr(__uuidof(MTAUTHLib::MTSessionContext));
 
	HRESULT hr =  directSc->QueryInterface(IID_IMTSecurityContext,
						reinterpret_cast<void**>(&secCtxPtr));
  if (FAILED(hr))
			MT_THROW_COM_ERROR("Failed to QueryInterface on direct CMTSecurityContextObject");

  directSc->Init(aName, aNameSpace);
  long accID = -1;
  hr  = directSc->get_AccountID(&accID);
  if(FAILED(hr))
    MT_THROW_COM_ERROR(hr);
  ASSERT(accID > 0);
  outPtr->AccountID = accID;
  outPtr->SecurityContext = secCtxPtr;
  return outPtr;
}
  
MTAUTHLib::IMTSessionContextPtr CMTLoginContext::CreateAndInitSessionContext(BSTR aName, BSTR aNameSpace, IMTSessionContext * apCurrentContext)
{
	BSTR loggedInAsTemp;
	BSTR applicationNameTemp;
	
	MTAUTHLib::IMTSessionContextPtr outPtr = CreateAndInitSessionContext(aName, aNameSpace);	

	apCurrentContext->get_LoggedInAs(&loggedInAsTemp);
	apCurrentContext->get_ApplicationName(&applicationNameTemp);

	_bstr_t loggedInAs(loggedInAsTemp, false);
	_bstr_t applicationName(applicationNameTemp, false);	

	if (loggedInAs.length() > 0)
	{
		outPtr->LoggedInAs = loggedInAs;
	}	

	if (applicationName.length() > 0)
	{
		outPtr->ApplicationName = applicationName;
	}

	return outPtr;
}

MTAUTHLib::IMTSessionContextPtr CMTLoginContext::CreateAndInitSessionContextWithAdditionalData(BSTR aName, BSTR aNameSpace, BSTR aLoggedInAs, BSTR aApplicationName)
{
	MTAUTHLib::IMTSessionContextPtr outPtr = CreateAndInitSessionContext(aName, aNameSpace);

	outPtr->LoggedInAs			= aLoggedInAs;
	outPtr->ApplicationName = aApplicationName;

	return outPtr;
}

MTAUTHLib::IMTSessionContextPtr CMTLoginContext::CreateSessionContext()
{
  CComObject<CMTSessionContext> * directSc;
 	CComObject<CMTSessionContext>::CreateInstance(&directSc);
  MTAUTHLib::IMTSessionContextPtr outPtr;
 
	HRESULT hr =  directSc->QueryInterface(IID_IMTSessionContext,
						reinterpret_cast<void**>(&outPtr));
  if (FAILED(hr))
			MT_THROW_COM_ERROR("Failed to QueryInterface on direct CMTSessionContextObject");

  return outPtr;
}

