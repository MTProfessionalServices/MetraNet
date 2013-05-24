// MTHookHandlerImpl.cpp : Implementation of CMTHookHandler
#include "StdAfx.h"
#include <mtcom.h>

#import <MTConfigLib.tlb>

#include "MTHookHandler.h"
#include <MTHookHandlerImpl.h>
#include <loggerconfig.h>
#include <mtcomerr.h>

STDMETHODIMP CMTHookHandler::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTHookHandler,
	};
	for (int i=0;i<sizeof(arr)/sizeof(arr[0]);i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}


/////////////////////////////////////////////////////////////////////////////
// CMTHookHandler

CMTHookHandler::CMTHookHandler(): mHookIndex(0)
{
  LoggerConfigReader configReader;
  mLogger.Init(configReader.ReadConfiguration("MTHookHandler"),"[MTHookHandler]");
}

/////////////////////////////////////////////////////////////////////////////
//CMTHookHandler::Read
/////////////////////////////////////////////////////////////////////////////

// XML Format
// <hooks>
//   <hook>PROGID</hooK>
// </hooks>
#define HOOK_TAG "hook"

STDMETHODIMP CMTHookHandler::Read(IMTConfigPropSet * pPropSet)
{
	ASSERT(pPropSet);
	if(!pPropSet) return E_POINTER;

	try
	{
		MTConfigLib::IMTConfigPropSetPtr aPropset(pPropSet);
		MTConfigLib::IMTConfigPropPtr aProp;

		// interate through the hooks
		aProp = aPropset->NextWithName(HOOK_TAG);
		while(aProp != NULL) {

			std::string str = (const char *) aProp->GetValueAsString();

			// create the hook
			// first try to use the secured hook interface
			IMTSecuredHookPtr securedHook;
			HRESULT hr = securedHook.CreateInstance(str.c_str());
			if (SUCCEEDED(hr))
			{
				// add it to the list of secured hooks
				mSecuredHookList.push_back(securedHook);
			}
			else
			{
				IMTHookPtr hook;
				HRESULT hr = hook.CreateInstance(str.c_str());
				if (FAILED(hr))
				{
					std::string buffer("Unable to create hook ");
					buffer += str;
					return Error(buffer.c_str(), IID_IMTHookHandler, hr);
				}

				// add it to the list
				mHookList.push_back(hook);
			}

			aProp = aPropset->NextWithName(HOOK_TAG);
		}
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }

	return S_OK;
}

/////////////////////////////////////////////////////////////////////////////
//CMTHookHandler::First
/////////////////////////////////////////////////////////////////////////////

STDMETHODIMP CMTHookHandler::First()
{
  mHookIndex = 0;
	if(mHookList.size() ==0 && mSecuredHookList.size() == 0) return S_FALSE;

	VARIANT var;
	::VariantInit(&var);
  return RunHook(mHookIndex++, var, NULL);
}

/////////////////////////////////////////////////////////////////////////////
// CMTHookHandler::Next
/////////////////////////////////////////////////////////////////////////////

STDMETHODIMP CMTHookHandler::Next()
{
  if(mHookIndex >= (mHookList.size() + mSecuredHookList.size())) return S_FALSE;

	VARIANT var;
	::VariantInit(&var);

  return RunHook(mHookIndex++, var, NULL);
}

/////////////////////////////////////////////////////////////////////////////
// CMTHookHandler::ExecuteAll
/////////////////////////////////////////////////////////////////////////////

STDMETHODIMP CMTHookHandler::ExecuteAll()
{
#if 0
  HRESULT hr = First();
  if(SUCCEEDED(hr)) {
    while(Next() == S_OK);
  }

	return S_OK;
#endif

	HRESULT retVal = S_OK;

  HRESULT hr = First();
	if (FAILED(hr))
		retVal = hr;

	// always attempt to run all hooks, even if one fails
	while (TRUE)
	{
		hr = Next();
		if (FAILED(hr))
			retVal = hr;

		if (hr == S_FALSE)
			break;
	}
	return retVal;

}

/////////////////////////////////////////////////////////////////////////////
// CMTHookHandler::FirstHook
/////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CMTHookHandler::FirstHook(/*[in]*/ VARIANT var,
																			 /*[in, out]*/ long* pVal)
{
  mHookIndex = 0;
  if (mHookList.size() == 0 && mSecuredHookList.size() == 0)
	  return S_FALSE;
  return RunHook(mHookIndex++, var, pVal);
}

/////////////////////////////////////////////////////////////////////////////
// CMTHookHandler::NextHook
/////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CMTHookHandler::NextHook(/*[in]*/ VARIANT var,
																			/*[in, out]*/ long* pVal)
{
  if (mHookIndex >= (mHookList.size() + mSecuredHookList.size()))
		return S_FALSE;
  return RunHook(mHookIndex++, var, pVal);
}

/////////////////////////////////////////////////////////////////////////////
// CMTHookHandler::ExecuteAllHooks
/////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CMTHookHandler::ExecuteAllHooks(/*[in]*/ VARIANT var,
																						 /*[in]*/ long val)
{
	long valTemp = val;
	HRESULT retVal = S_OK;

  HRESULT hr = FirstHook(var, &valTemp);
	if (FAILED(hr))
		retVal = hr;

	// always attempt to run all hooks, even if one fails
	while (TRUE)
	{
		valTemp = val;
		hr = NextHook(var, &valTemp);
		if (FAILED(hr))
			retVal = hr;

		if (hr == S_FALSE)
			break;
	}

	return retVal;
}


/////////////////////////////////////////////////////////////////////////////
// CMTHookHandler::get_HookCount
/////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CMTHookHandler::get_HookCount(/*[out, retval]*/ int * count)
{
	if (!count)
		return E_POINTER;

	*count = mHookList.size() + mSecuredHookList.size();

	return S_OK;
}

/////////////////////////////////////////////////////////////////////////////
// CMTHookHandler::Clear
/////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CMTHookHandler::ClearHooks()
{
	mHookList.clear();
	mSecuredHookList.clear();
	return S_OK;
}

/////////////////////////////////////////////////////////////////////////////
// RunHookWithProgid
/////////////////////////////////////////////////////////////////////////////


STDMETHODIMP CMTHookHandler::RunHookWithProgid(BSTR aHookProgid,VARIANT var,long* val)
{
	ASSERT(aHookProgid);
	if(!aHookProgid) return E_POINTER;


	_bstr_t progid(aHookProgid);
  HRESULT hr = S_OK;

  try
	{
		IMTSecuredHookPtr mtsecuredhook;
		HRESULT hr = mtsecuredhook.CreateInstance((const char*)progid);

		if (SUCCEEDED(hr))
		{
			if (mSessionContext == NULL)
				return Error("Session context required to run secured hooks");

			hr = mtsecuredhook->Execute((MTHookLib::IMTSessionContext *) mSessionContext.GetInterfacePtr(), var, val);
		}
		else
		{
			IMTHookPtr mthook((const char*)progid);
			hr = mthook->Execute(var, val);
		}
  } 
  catch(_com_error& e) {

		_bstr_t description	= (const char*)e.Description() != NULL ? e.Description() : "No detailed error";
 		_bstr_t source	= (const char*)e.Source() != NULL ? e.Source() : "unknown";

		mLogger.LogVarArgs(LOG_ERROR,"Hook %s failed with the following error: \"%s\". Source is %s",
      (const char*)progid, (const char*)description, (const char*)source);

		return ReturnComError(e);
 }
  return hr;

}

// ----------------------------------------------------------------
// Description:   Pass in a session context that has already been created by a login call.
// Arguments:     session_context - a session context object previously
//                retrieved by a Login call.
// ----------------------------------------------------------------
STDMETHODIMP CMTHookHandler::put_SessionContext(
	::IMTSessionContext * apSessionContext)
{
	try
	{
		mSessionContext = apSessionContext;
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }

	return S_OK;
}

/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
// Non COM methods
/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////

HRESULT CMTHookHandler::RunHook(unsigned int aIndex, VARIANT var,
																long * val)
{
  if(!(aIndex >= 0 && aIndex < mHookList.size() + mSecuredHookList.size()))
    return E_INVALIDARG;

  HRESULT hr;

  try
	{
		if (aIndex < mHookList.size())
		{
			IMTHookPtr mthook = mHookList[aIndex];
			hr = mthook->Execute(var, val);
		}
		else
		{
			if (mSessionContext == NULL)
				return Error("Session context required to run secured hooks");

			aIndex -= mHookList.size();
			IMTSecuredHookPtr mthook = mSecuredHookList[aIndex];
			hr = mthook->Execute((MTHookLib::IMTSessionContext *) mSessionContext.GetInterfacePtr(), var, val);
		}
  } 
  catch(_com_error e) {
    mLogger.LogVarArgs(LOG_ERROR,"Hook %d failed with the following error: \"%s\"",
      aIndex,(char*)e.Description() != NULL ? (char*)e.Description() :
    "No detailed error");

		return ReturnComError(e);
 }
  return hr;
}






