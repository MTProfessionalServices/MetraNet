/**************************************************************************
 * @doc ScriptedFrame
 *
 * Copyright 1998 by MetraTech Corporation
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
 * Modification History:
 *		Chen He - September 14, 1998 : Initial version
 *
 * $Header$
 *
 *****************************************************************************/

// ScriptHostProc.cpp : Implementation of CScriptHostProc
#include "StdAfx.h"
#include "ScriptHost.h"
#include "ScriptHostProc.h"

#include "metra.h"

#include <autocritical.h>
#include <SetIterate.h>
#include <mtcomerr.h>


using namespace MTPipelineLib;

/////////////////////////////////////////////////////////////////////////////
// CScriptHostProc

STDMETHODIMP CScriptHostProc::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTPipelinePlugIn,
	};
	for (int i=0;i<sizeof(arr)/sizeof(arr[0]);i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

//////////////////////////////////////////////////////////////////////////
// Interface implementation
//////////////////////////////////////////////////////////////////////////
STDMETHODIMP CScriptHostProc::Configure(IUnknown * systemContext,
																				::IMTConfigPropSet * apPropSet)
{
	string err;

	try
	{
		mSysContext = systemContext;
		mPropSet = apPropSet;

		// make sure that we clean up the memory
		if (mpScriptHosting != NULL)
		{
			delete mpScriptHosting;
			mpScriptHosting = NULL;
		}

		// application initialization
		mpScriptHosting = new CScriptHosting();
		// load the configuration data
		BOOL ret = mpScriptHosting->Serialization(systemContext, apPropSet);

		if (ret == FALSE)
		{
			err = mpScriptHosting->GetErrorMsg();
			return Error(err.c_str());
		}

	}
	catch (HRESULT hr)
	{
		return hr;
	}
	catch (_com_error err)
	{
		return err.Error();
	}
#ifndef _DEBUG
	catch (...)
	{
		return E_FAIL;
	}
#endif // _DEBUG

	return S_OK;
}

STDMETHODIMP CScriptHostProc::ConfigureInternal(IUnknown * systemContext,
																								::IMTConfigPropSet * apPropSet)
{
	IMTNameIDPtr idlookup(systemContext);
	mPropIDSession = idlookup->GetNameID(_bstr_t("SessionID"));

	BOOL ret = mpScriptHosting->InitializeScriptHost(systemContext);
	if (ret == FALSE)
	{
		return E_FAIL;
	}
	mScriptHostProcSessionSet = mpScriptHosting->GetSHProcFlag();

	return S_OK;
}

STDMETHODIMP CScriptHostProc::Shutdown()
{
	if (mpScriptHosting)
	{
		// clean up the memory allocation
		mpScriptHosting->Shutdown();

		delete mpScriptHosting;
		mpScriptHosting = NULL;
	}

	return S_OK;
}

_COM_SMARTPTR_TYPEDEF(IEnumVARIANT, __uuidof(IEnumVARIANT));

STDMETHODIMP CScriptHostProc::ProcessSessions(::IMTSessionSet * apSessionSet)
{
	HRESULT result;
	string err;
	char errStr[MAX_BUFFER_SIZE];

	AutoCriticalSection autolock(&mLock);

	try
	{
		result = ConfigureInternal(mSysContext, 
											(::IMTConfigPropSet *) (MTPipelineLib::IMTConfigPropSet *) mPropSet);
		if (FAILED(result))
		{
			err = mpScriptHosting->GetErrorMsg();
			mpScriptHosting->QuitScript();
			return Error(err.c_str());
		}

		if (mScriptHostProcSessionSet)
		{
			result = mpScriptHosting->ProcessSessionSet(apSessionSet);
			if (FAILED(result))
			{
				err = mpScriptHosting->GetErrorMsg();
				mpScriptHosting->QuitScript();
				return Error(err.c_str());
			}
		}
		else
		{
			IMTSessionSetPtr sessions(apSessionSet);

			SetIterator<IMTSessionSetPtr, IMTSessionPtr> it;
			HRESULT hr = it.Init(sessions);
			if (FAILED(hr))
			  return hr;
	
			while (TRUE)
			{
			    IMTSessionPtr session = it.GetNext();
				if (session == NULL)
				  break;

				//--------- we have the session here ---------------------
				result = mpScriptHosting->ProcessSession(session);
				if (FAILED(result))
				{
					err = mpScriptHosting->GetErrorMsg();
					mpScriptHosting->QuitScript();

					return Error(err.c_str());
				}
			}
		}
	}
	catch (HRESULT hr)
	{
		mpScriptHosting->QuitScript();
	    return hr;
	}
	catch(ErrorObject aLocalError)
	{
	    sprintf(errStr, "Error: %s, %s(%d) %s(%X)", 
				aLocalError.GetModuleName(),
				aLocalError.GetFunctionName(),
				aLocalError.GetLineNumber(),
				aLocalError.GetProgrammerDetail().c_str(),
				aLocalError.GetCode());

		return Error(errStr);
	}
	catch (_com_error err)
	{
		mpScriptHosting->QuitScript();
	    return ReturnComError(err);
	}
#ifndef _DEBUG
	catch (...)
	{
		return E_FAIL;
		//cout << "everything else" << endl;
	}
#endif // _DEBUG

	mpScriptHosting->QuitScript();

	return S_OK;
}
     
STDMETHODIMP CScriptHostProc::get_ProcessorInfo(/* [out] */ long * info)
{

	return S_OK;
}
