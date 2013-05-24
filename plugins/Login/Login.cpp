/**************************************************************************
 * @doc SIMPLE
 *
 * Copyright 1999 by MetraTech Corporation
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
 * NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech Corporation MAKES NO
 * REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
 * PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
 * DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
 * COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech Corporation,
 * and USER agrees to preserve the same.
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/


#include <PlugInSkeleton.h>
#include <string.h>
#include <metra.h>
#include <mtcomerr.h>
#include <propids.h>

#import <MTAuth.tlb> rename ("EOF", "RowsetEOF")

CLSID CLSID_MTLogin = { 
	0x565753d9, 
	0xef87, 
	0x4401, { 
		0xae, 
		0x5e, 
		0x68, 
		0x2f, 
		0xe4, 
		0xa4, 
		0x70, 
		0x1f } 
};

/////////////////////////////////////////////////////////////////////////////
// MTAccountStateCheck
/////////////////////////////////////////////////////////////////////////////


class ATL_NO_VTABLE MTLogin
	: public MTPipelinePlugIn<MTLogin, &CLSID_MTLogin>
{
protected:
	virtual HRESULT PlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
																	MTPipelineLib::IMTConfigPropSetPtr aPropSet,
																	MTPipelineLib::IMTNameIDPtr aNameID,
                                  MTPipelineLib::IMTSystemContextPtr aSysContext);

	// Shutdown the processor.  The processor can release any resources
	// it no longer needs.
	virtual HRESULT PlugInShutdown();

	virtual HRESULT PlugInProcessSession(MTPipelineLib::IMTSessionPtr aSession);

protected: 

private: // data
	MTPipelineLib::IMTLogPtr mLogger;
	MTAUTHLib::IMTLoginContextPtr mLoginContext;
	long mUserName;
	long mPassword;
	long mNamespace;
	long mCtx;
	bool bEncryptedPassword;
	
};


PLUGIN_INFO(CLSID_MTLogin, MTLogin,
						"MetraPipeline.MTLogin.1", "MetraPipeline.MTLogin", "Free")

/////////////////////////////////////////////////////////////////////////a////
//PlugInConfigure
/////////////////////////////////////////////////////////////////////////////

#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "MTLogin::PlugInConfigure"
HRESULT MTLogin::PlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
																				MTPipelineLib::IMTConfigPropSetPtr aPropSet,
																				MTPipelineLib::IMTNameIDPtr aNameID,
                                        MTPipelineLib::IMTSystemContextPtr aSysContext)
{
	mLogger = aLogger;
	HRESULT hr(S_OK);
	mLoginContext.CreateInstance(__uuidof(MTAUTHLib::MTLoginContext));
	ASSERT(mLoginContext != NULL);

	DECLARE_PROPNAME_MAP(inputs)
		DECLARE_PROPNAME("username",&mUserName)
		DECLARE_PROPNAME("password",&mPassword)
		DECLARE_PROPNAME("namespace",&mNamespace)
		DECLARE_PROPNAME("sessioncontext",&mCtx)
	END_PROPNAME_MAP

		hr = ProcessProperties(inputs,aPropSet,aNameID,aLogger,PROCEDURE);
	if(!SUCCEEDED(hr))
		return hr;

	PipelinePropIDs::Init();



	// see if the password string has a trailing underscore
	wstring aTempStr = (const wchar_t*)_bstr_t(aNameID->GetName(mPassword));
	bEncryptedPassword = aTempStr[aTempStr.length()-1] == L'_';

	return S_OK;
}

/////////////////////////////////////////////////////////////////////////////
//PlugInProcessSession
/////////////////////////////////////////////////////////////////////////////

#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "MTLogin::PlugInProcessSession"
HRESULT MTLogin::PlugInProcessSession(MTPipelineLib::IMTSessionPtr aSession)
{
	HRESULT hr(S_OK);
	if (aSession->PropertyExists(mUserName, 
		MTPipelineLib::SESS_PROP_TYPE_STRING) == VARIANT_FALSE)
	{
		return S_OK;
	}

	_bstr_t pw;
	_bstr_t name = aSession->GetStringProperty(mUserName);
	_bstr_t ns = aSession->GetStringProperty(mNamespace);


	// password
	if(bEncryptedPassword) {
		pw = aSession->DecryptEncryptedProp(mPassword);
	}
	else {
		pw = aSession->GetStringProperty(mPassword);
	}

	//Login the user and set serialized context back in session
	_bstr_t serContext = mLoginContext->Login(name, ns, pw)->ToXML();
	aSession->SetStringProperty(mCtx, serContext);
	return S_OK;
}


/////////////////////////////////////////////////////////////////////////////
//PlugInShutdown
/////////////////////////////////////////////////////////////////////////////

HRESULT MTLogin::PlugInShutdown()
{
	
	return S_OK;
}
