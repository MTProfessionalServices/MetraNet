/******************************************************************************
 * @doc MTScriptHost
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
 ****************************************************************************
 *   File:   MTScriptHost.cpp
 *
 *   Date:   March 3, 1998
 *
 *   Description:   This file contains the definition of a generic class that
 *               implements the IDispatch interface, which allows the 
 *               methods of this class to be called by any object that 
 *               understands the IDispatch interface.
 *
 * Modification History:
 *		Chen He - September 14, 1998 : Initial version
 *
 * $Header$
******************************************************************************/

#include "StdAfx.h"
#include "MTScriptHost.h"
#include "MTScriptingDispids.h"
#include <stdio.h>
#include <comdef.h>
#include "ScriptHostInclude.h"

using namespace MTPipelineLib;

//Constructor
#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "CMTScriptHost::CMTScriptHost()"
CMTScriptHost::CMTScriptHost()
{
#if MTDEBUG
	printf("CMTScriptHost::CMTScriptHost()\n");
#endif
	char logBuf[MAX_BUFFER_SIZE];


	mRefCount = 0;
	mpTypeInfo = NULL;
	mpTheConnection = NULL;

	// initialize log
	LoggerConfigReader configReader;
	mLogger.Init(configReader.ReadConfiguration("logging"), PIPELINE_TAG);

	HRESULT hr = LoadTypeInfo(&mpTypeInfo, CLSID_MTScriptHost, 0x0);
	if (FAILED(hr))
	{
#if MTDEBUG
		printf("Error: Can't load type info in CMTScriptHost.");
#endif
		sprintf (logBuf, "Error: Can't load type info in CMTScriptHost(HRESULT=%lx): %s", 
			hr,
			PROCEDURE);
		mLogger.LogThis(LOG_ERROR, logBuf);
	}

}

//Destructor
CMTScriptHost::~CMTScriptHost()
{
#if MTDEBUG
	printf("CMTScriptHost::~CMTScriptHost()\n");
#endif
	if (mpTypeInfo != NULL)
	{
		mpTypeInfo->Release();
		mpTypeInfo = NULL;
	}

}

/******************************************************************************
*   LoadTypeInfo -- Gets the type information of an object's interface from the 
*   type library.  Returns S_OK if successful.
******************************************************************************/
#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "CMTScriptHost::LoadTypeInfo()"
STDMETHODIMP CMTScriptHost::LoadTypeInfo(ITypeInfo** pptinfo, 
																				 REFCLSID clsid,
																				 LCID lcid)
{
#if MTDEBUG
	//tracing purposes only
	printf("CMTScriptHost::LoadTypeInfo\n");
#endif

	HRESULT hr;
	LPTYPELIB ptlib = NULL;
  LPTYPEINFO ptinfo = NULL;
  *pptinfo = NULL;

  // First try to load the type info from a registered type library
	hr = LoadRegTypeLib(LIBID_SCRIPTHOSTLib, 1, 0, lcid, &ptlib);
  if (FAILED(hr))
	{
		//if the libary is not registered, try loading from a file
		hr = LoadTypeLib(L"ScriptHost.tlb", &ptlib);
    if (FAILED(hr))
		{
#if MTDEBUG
			printf("CMTScriptHost::LoadTypeInfo - Can't get the type information\n");
#endif
			// Can't get the type information
			return hr;
		}
	}

	// Get type information for interface of the object.
	hr = ptlib->GetTypeInfoOfGuid(clsid, &ptinfo);
	if (FAILED(hr))
	{
		ptlib->Release();
		return hr;
	}

	ptlib->Release();
	*pptinfo = ptinfo;
	return S_OK;
}

/******************************************************************************
*   IUnknown Interfaces -- All COM objects must implement, either directly or 
*   indirectly, the IUnknown interface.
******************************************************************************/

/******************************************************************************
*   QueryInterface -- Determines if this component supports the requested 
*   interface, places a pointer to that interface in ppvObj if it's available,
*   and returns S_OK.  If not, sets ppvObj to NULL and returns E_NOINTERFACE.
******************************************************************************/
#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "CMTScriptHost::QueryInterface()"
STDMETHODIMP CMTScriptHost::QueryInterface(REFIID riid, void ** ppvObj)
{
#if MTDEBUG
	//tracing purposes only
	printf("CMTScriptHost::QueryInterface->");
#endif

	if (riid == IID_IUnknown)
	{
#if MTDEBUG
		printf("IUnknown\n");
#endif
		*ppvObj = static_cast<IDispatch*>(this);
	}
	else if (riid == IID_IDispatch)
	{
#if MTDEBUG
		printf("IDispatch\n");
#endif
		*ppvObj = static_cast<IDispatch*>(this);
	}
	else if (riid == DIID_IMTObject)
	{
#if MTDEBUG
		printf("IMTObject\n");
#endif
		*ppvObj = static_cast<IMTObject*>(this);
	}
	else if (riid == IID_IProvideMultipleClassInfo)
	{
#if MTDEBUG
		printf("IProvideMultipleClassInfo\n");
#endif
    *ppvObj = static_cast<IProvideMultipleClassInfo*>(this);
  }
  else if (riid == IID_IConnectionPointContainer)
	{
#if MTDEBUG
		printf("IConnectionPointContainer\n");
#endif
		*ppvObj = static_cast<IConnectionPointContainer*>(this);
	}
  else if (riid == IID_IConnectionPoint)
	{
#if MTDEBUG
		printf("IConnectionPoint\n");
#endif
		*ppvObj = static_cast<IConnectionPoint*>(this);
	}
  else
	{
#if MTDEBUG
		printf("Unsupported Interface\n");
#endif
    *ppvObj = NULL;
    return E_NOINTERFACE;
  }

  static_cast<IUnknown*>(*ppvObj)->AddRef();
  return S_OK;

}

/******************************************************************************
*   AddRef() -- In order to allow an object to delete itself when it is no 
*   longer needed, it is necessary to maintain a count of all references to 
*   this object.  When a new reference is created, this function increments
*   the count.
******************************************************************************/
STDMETHODIMP_(ULONG) CMTScriptHost::AddRef()
{
#if MTDEBUG
	//tracing purposes only
  cout << "CMTScriptHost::AddRef: " << mRefCount + 1 << endl;
#endif

  return ++mRefCount;
}

/******************************************************************************
*   Release() -- When a reference to this object is removed, this function 
*   decrements the reference count.  If the reference count is 0, then this 
*   function deletes this object and returns 0;
******************************************************************************/
STDMETHODIMP_(ULONG) CMTScriptHost::Release()
{
#if MTDEBUG
	//tracing purposes only
  cout << "CMTScriptHost::Release: " << mRefCount - 1 << endl;
#endif

	if (--mRefCount == 0)
  {
		delete this;
		return 0;
  }

  return mRefCount;
}

/******************************************************************************
*   IDispatch Interface -- This interface allows this class to be used as an
*   automation server, allowing its functions to be called by other COM
*   objects
******************************************************************************/

/******************************************************************************
*   GetTypeInfoCount -- This function determines if the class supports type 
*   information interfaces or not.  It places 1 in iTInfo if the class supports
*   type information and 0 if it doesn't.
******************************************************************************/
STDMETHODIMP CMTScriptHost::GetTypeInfoCount(UINT *iTInfo)
{
#if MTDEBUG
	//tracing purposes only
	printf("CMTScriptHost::GetTypeInfoCount\n");
#endif

	*iTInfo = 1;
	return S_OK;
}

/******************************************************************************
*   GetTypeInfo -- Returns the type information for the class.  For classes 
*   that don't support type information, this function returns E_NOTIMPL;
******************************************************************************/
STDMETHODIMP CMTScriptHost::GetTypeInfo(UINT iTInfo, LCID lcid, 
																				ITypeInfo **ppTInfo)
{
#if MTDEBUG
   //tracing purposes only
   printf("CMTScriptHost::GetTypeInfo\n");
#endif

   mpTypeInfo->AddRef();
   *ppTInfo = mpTypeInfo;

   return S_OK;
}

/******************************************************************************
*   GetIDsOfNames -- Takes an array of strings and returns an array of DISPID's
*   which corespond to the methods or properties indicated.  If the name is not 
*   recognized, returns DISP_E_UNKNOWNNAME.
******************************************************************************/
#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "CMTScriptHost::GetIDsOfNames()"
STDMETHODIMP CMTScriptHost::GetIDsOfNames(REFIID riid,  
                               OLECHAR **rgszNames, 
                               UINT cNames,  LCID lcid,
                               DISPID *rgDispId)
{
#if MTDEBUG
	//tracing purposes only
	printf("CMTScriptHost::GetIDsOfNames\n");
#endif

	HRESULT hr;

	//Validate arguments
	if (riid != IID_NULL)
	{
#if MTDEBUG
		//tracing purposes only
		printf("CMTScriptHost::GetIDsOfNames: INVALIDARG\n");
#endif
		return E_INVALIDARG;
	}

	//this API call gets the DISPID's from the type information
	hr = mpTypeInfo->GetIDsOfNames(rgszNames, cNames, rgDispId);

	//DispGetIDsOfNames may have failed, so pass back its return value.
	return hr;
}

/******************************************************************************
*   Invoke -- Takes a dispid and uses it to call another of this class's 
*   methods.  Returns S_OK if the call was successful.
******************************************************************************/
#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "CMTScriptHost::Invoke()"
STDMETHODIMP CMTScriptHost::Invoke(DISPID dispIdMember, REFIID riid, LCID lcid,
																	WORD wFlags, DISPPARAMS* pDispParams,
																	VARIANT* pVarResult, EXCEPINFO* pExcepInfo,
																	UINT* puArgErr)
{
#if MTDEBUG
	//tracing purposes only
	printf("CMTScriptHost::Invoke\n");
#endif

	//Validate arguments
	if ((riid != IID_NULL) || !(wFlags & DISPATCH_METHOD))
	{
		return E_INVALIDARG;
	}

	HRESULT hr = S_OK;
	LPDISPATCH pDisp = 0;

	switch(dispIdMember)
	{
		case 0x1:
			SaySomething(pDispParams->rgvarg[0].bstrVal);
      break;
		case 0x2:
			if(pDispParams->rgvarg[0].vt != VT_BSTR)
			{
				hr = DISP_E_BADVARTYPE;
			}
			else
			{
				hr = CreateObject(pDispParams->rgvarg[0].bstrVal, &pDisp);
				if(SUCCEEDED(hr) && (pVarResult != 0))
				{
					pVarResult->vt = VT_DISPATCH;
					pVarResult->pdispVal = pDisp;
				}
			}
			break;

		default:
      hr = E_FAIL;
      break;
	}

  return hr;
}

/******************************************************************************
*   IProvideClassInfo method -- GetClassInfo -- this method returns the 
*   ITypeInfo* that corresponds to the objects coclass type information.
******************************************************************************/
STDMETHODIMP CMTScriptHost::GetClassInfo( ITypeInfo** ppTI )
{
#if MTDEBUG
	//tracing purposes only
	printf("CMTScriptHost::GetClassInfo\n");
#endif

	return LoadTypeInfo( ppTI, CLSID_MTScriptHost, 0);
}

/******************************************************************************
*   IProvideClassInfo2 method -- GetGUID -- returns the IID of the object's
*   default outgoing event set.
******************************************************************************/
#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "CMTScriptHost::GetGUID()"
STDMETHODIMP CMTScriptHost::GetGUID( DWORD dwGuidKind, GUID* pGUID)
{
#if MTDEBUG
	//tracing purposes only
	printf("CMTScriptHost::GetGUID\n");
#endif

	if (dwGuidKind != GUIDKIND_DEFAULT_SOURCE_DISP_IID)
	{
		return E_INVALIDARG;
	}
  else
	{
		*pGUID = DIID_IMTObject;
    return S_OK;
  }
}

/******************************************************************************
*   IProvideMultipleClassInfo methods -- provides access to type information
*   for the default interfaces of this class
******************************************************************************/

/******************************************************************************
*   GetMultiTypeInfoCount -- returns the number of type information interfaces
*   that make up the composite interface
******************************************************************************/
STDMETHODIMP CMTScriptHost::GetMultiTypeInfoCount(ULONG *pcti)
{
#if MTDEBUG
	//tracing purposes only
	printf("CMTScriptHost::GetMultiTypeInfoCount\n");
#endif

	*pcti = 1;
	return S_OK;
}

/******************************************************************************
*   GetInfoOfIndex -- returns information associated with a particular 
*   interface in this composite class.
******************************************************************************/
#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "CMTScriptHost::GetInfoOfIndex()"
STDMETHODIMP CMTScriptHost::GetInfoOfIndex(ULONG iti, DWORD dwMCIFlags, 
																					ITypeInfo **pptiCoClass, 
																					DWORD *pdwTIFlags, 
																					ULONG *pcdispidReserved, 
																					IID *piidPrimary, IID *piidSource)
{
#if MTDEBUG
	//tracing purposes only
	printf("CMTScriptHost::GetInfoOfIndex\n");
#endif

	if (iti != 0)
		return E_INVALIDARG;

	if (dwMCIFlags & MULTICLASSINFO_GETTYPEINFO)
	{
		LoadTypeInfo(pptiCoClass, CLSID_MTScriptHost, 0);
  }

	if (dwMCIFlags & MULTICLASSINFO_GETNUMRESERVEDDISPIDS)
	{
		*pdwTIFlags = 0;
    *pcdispidReserved = 0;
  }

  if (dwMCIFlags & MULTICLASSINFO_GETIIDPRIMARY)
	{
		*piidPrimary =  DIID_IMTObject;
  }

  if (dwMCIFlags & MULTICLASSINFO_GETIIDSOURCE)
	{
		*piidSource = DIID_IMTObject;
  }

  return S_OK;
}

/******************************************************************************
*   IConnectionPointContainer methods -- These methods support connection 
*   points for use with outgoing interfaces.
******************************************************************************/

/******************************************************************************
*   EnumConnectionPoints -- provides an enumeration of the connection points
*    that this object supports.
******************************************************************************/
STDMETHODIMP CMTScriptHost::EnumConnectionPoints(IEnumConnectionPoints **ppEnum)
{
#if MTDEBUG
  //tracing purposes only
  printf("CMTScriptHost::EnumConnectionPoints\n");
#endif

  return E_NOTIMPL;
}

/******************************************************************************
*   FindConnectionPoint -- This function returns the IConnectionPoint* 
*   specified by riid.  Returns S_OK if successful, CONNECT_E_NOCONNECTION if
*   this object doesn't support the specified interface, and E_POINTER if
*   ppCP is invalid.
******************************************************************************/
STDMETHODIMP CMTScriptHost::FindConnectionPoint(REFIID riid, 
																								IConnectionPoint **ppCP)
{
#if MTDEBUG
  //tracing purposes only
  printf("CMTScriptHost::FindConnectionPoint\n");
#endif

  if (riid == DIID_IMTEvents)
	{
		*ppCP = static_cast<IConnectionPoint*>(this);
	}
  else
	{
    *ppCP = NULL;
    return CONNECT_E_NOCONNECTION;
  }

  static_cast<IUnknown*>(*ppCP)->AddRef();
  return S_OK;
}

/******************************************************************************
*   IConnectionPoint methods -- These methods allow objects to inform this 
*   object that they wish to be informed when events occur, and to check
*   the IID's of outgoing interfaces this object supports.
******************************************************************************/

/******************************************************************************
*   GetConnectionInterface -- This function returns the IID of the outgoing
*   interface that this object supports.  If the address of pIID is not valid
*   this function returns E_POINTER.  If successful, it returns S_OK.
******************************************************************************/
STDMETHODIMP CMTScriptHost::GetConnectionInterface( IID *pIID)
{
#if MTDEBUG
  //tracing purposes only
  printf("CMTScriptHost::GetConnectionInterface\n");
#endif

  HRESULT hr = S_OK;
  if (pIID == NULL)
		hr = E_POINTER;
  else
    *pIID = DIID_IMTEvents;

  return hr;
}

/******************************************************************************
*   GetConnectionPointContainer -- This function returns the 
*   IConnectionPointContainer that is the parent of this IConnectionPoint.  If
*   the address of ppCPC is invalid, this function returns E_POINTER.  If
*   successful, it returns S_OK.
******************************************************************************/
STDMETHODIMP CMTScriptHost::GetConnectionPointContainer(
																						IConnectionPointContainer **ppCPC)
{
#if MTDEBUG
  //tracing purposes only
  printf("CMTScriptHost::GetConnectionPointContainer\n");
#endif

  HRESULT hr = S_OK;
  if (ppCPC == NULL)
	{
		hr = E_POINTER;
	}
  else
	{
    *ppCPC = static_cast<IConnectionPointContainer*>(this);
    static_cast<IUnknown*>(*ppCPC)->AddRef();
  }

  return hr;
}

/******************************************************************************
*   Advise -- This function establishes a connection to an event sink that
*   receives events from the outgoing interface that this object supports.
*   It takes an IUnknown* from the sink, and places a cookie that the sink
*   uses to disconnect in pdwCookie.  If the connection is established and 
*   the cookie is placed in pdwCookie, then this function returns S_OK.  If
*   the sink does not recieve events from this object, this function returns
*   CONNECT_E_CANNOTCONNECT.  In addition, this function can return E_POINTER
*   if either parameter is invalid, and CONNECT_E_ADVISELIMIT if this object
*   has reached it's connection limit and cannot accept any more.
******************************************************************************/
STDMETHODIMP CMTScriptHost::Advise( IUnknown* pUnk, DWORD *pdwCookie)
{
#if MTDEBUG
  //tracing purposes only
  printf("CMTScriptHost::Advise\n");
#endif

  //First check to make sure the parameters are valid
  if (pUnk == NULL)
	{
		return E_POINTER;
	}

  if (pdwCookie == NULL)
	{
    return E_POINTER;
	}

  //Make sure there's room for the connection
  if (mpTheConnection != NULL)
	{
		return CONNECT_E_ADVISELIMIT;
	}

  //Query interface to make sure the sink supports the right interface
  HRESULT hr = pUnk->QueryInterface(DIID_IMTEvents, (void**)&mpTheConnection);
  if (FAILED(hr))
	{
		return CONNECT_E_CANNOTCONNECT;
	}

  //We got a connection, so set the cookie value
  *pdwCookie = 1;

  //ready to send events
  return S_OK;
}

/******************************************************************************
*   Unadvise -- This function uses the value in dwCookie to disconnect from an
*   event sink.  It releases the pointer that was saved in Advise and used to 
*   call sink functions.  This function returns S_OK if the disconnect was 
*   successful, and CONNECT_E_NOCONNECTION if the connection specified by 
*   dwCookie was invalid.
******************************************************************************/
STDMETHODIMP CMTScriptHost::Unadvise( DWORD dwCookie)
{
#if MTDEBUG
  //tracing purposes only
  printf("CMTScriptHost::Unadvise\n");
#endif

  //Check the value in dwCookie to make sure it's valid
  if (dwCookie != 1)
	{
		return CONNECT_E_NOCONNECTION;
	}
  else
	{
    mpTheConnection->Release();
    mpTheConnection = NULL;
    return S_OK;
  }

}

/******************************************************************************
*   EnumConnections -- provides an enumeration of all the sinks that are 
*   currently connected to this object source.
******************************************************************************/
STDMETHODIMP CMTScriptHost::EnumConnections( IEnumConnections** ppEnum)
{
#if MTDEBUG
  //tracing purposes only
  printf("CMTScriptHost::EnumConnections\n");
#endif

  return E_NOTIMPL;
}

/******************************************************************************
*   Class-specific methods -- ObjectFrame is designed to be copied and used as
*   a base for IDispatch-derived classes.  Functions that are not part of the 
*   framework appear below.
******************************************************************************/


/******************************************************************************
*   OnFireEvent() -- This function calls the MTEvents method defined in the 
*   script, through the engine's IDispatch-like interface.
******************************************************************************/
#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "CMTScriptHost::OnFireEvent()"
void CMTScriptHost::OnFireEvent()
{
#if MTDEBUG
	//tracing purposed only
	printf("CMTScriptHost::OnFireEvent\n");
#endif
	char logBuf[MAX_BUFFER_SIZE];

	if (mpTheConnection != NULL)
	{
		DISPPARAMS l_dispParams;
		EXCEPINFO l_exceptions;
		UINT l_error = 0;

		l_dispParams.rgvarg            = NULL;
		l_dispParams.rgdispidNamedArgs = NULL;
		l_dispParams.cArgs             = 0;
		l_dispParams.cNamedArgs        = 0;

		HRESULT hr = mpTheConnection->Invoke( DISPID_ONFIREEVENT, 
																					IID_NULL, 
																					0, 
																					DISPATCH_METHOD, 
																					&l_dispParams, 
																					NULL, 
																					&l_exceptions, 
																					&l_error);
		if (FAILED(hr))
		{
#if MTDEBUG
			printf("Error calling event.\n");
#endif
			sprintf (logBuf, "Error invoke OnFireEvent event(HRESULT=%lx): %s", 
				hr,
				PROCEDURE);
			mLogger.LogThis(LOG_ERROR, logBuf);
		}
	}
	else
	{
#if MTDEBUG
		printf("Error: no connection.\n");
#endif
		sprintf (logBuf, "Error: no connection: %s", PROCEDURE);
		mLogger.LogThis(LOG_ERROR, logBuf);
	}
}


/////////////////////////////////////////////////////////////////////////////
#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "CMTScriptHost::Configure()"
HRESULT CMTScriptHost::Configure(IMTConfigPropSetPtr apPropSet)
{
#if MTDEBUG
	//tracing purposed only
	printf("CMTScriptHost::Configure\n");
#endif
	char logBuf[MAX_BUFFER_SIZE];

	if (mpTheConnection != NULL)
	{
		DISPPARAMS l_dispParams;
		EXCEPINFO l_exceptions;
		UINT l_error = 0;

	  VARIANTARG  var;
		VariantInit(&var);
		var.vt = VT_DISPATCH;

		IDispatch * disp = NULL;

		if (apPropSet != NULL)
		{
			HRESULT queryRes = apPropSet->QueryInterface(IID_IDispatch, (void **) &disp);
			if (FAILED(queryRes))
			{
				sprintf (logBuf, "Error: calling QueryInterface(IID_IDispatch)(HRESULT=%lx): %s", 
					queryRes,
					PROCEDURE);
				mLogger.LogThis(LOG_ERROR, logBuf);
				return queryRes;
			}
		}
		var.pdispVal = disp;

		l_dispParams.rgvarg            = &var;
		l_dispParams.rgdispidNamedArgs = NULL;
		l_dispParams.cArgs             = 1;
		l_dispParams.cNamedArgs        = 0;

		HRESULT hr = mpTheConnection->Invoke( DISPID_CONFIGURE, 
																					IID_NULL, 
																					0, 
																					DISPATCH_METHOD, 
																					&l_dispParams, 
																					NULL, 
																					&l_exceptions, 
																					&l_error);

		VariantClear(&var);

		if (FAILED(hr))
		{
#if MTDEBUG
			printf("Error Invoke Configure event.\n");
#endif
			sprintf (logBuf, "Error Invoke Configure event(HRESULT=%lx): %s", 
				hr,
				PROCEDURE);
			mLogger.LogThis(LOG_ERROR, logBuf);
		}
		return hr;
	}
	else
	{
#if MTDEBUG
		printf("Error: no connection.\n");
#endif
		sprintf (logBuf, "Error: no connection: %s", PROCEDURE);
		mLogger.LogThis(LOG_ERROR, logBuf);

		return E_FAIL;
	}
}


////////////////////////////////////////////////////////////////////////////////
#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "CMTScriptHost::ProcessSession()"
HRESULT CMTScriptHost::ProcessSession(IMTSessionPtr apSession)
{
#if MTDEBUG
	//tracing purposed only
	printf("CMTScriptHost::ProcessSession\n");
#endif
	char logBuf[MAX_BUFFER_SIZE];

	if (mpTheConnection != NULL)
	{
		DISPPARAMS l_dispParams;
		EXCEPINFO l_exceptions;
		UINT l_error = 0;

	  VARIANTARG  var;
		VariantInit(&var);
		var.vt = VT_DISPATCH;
		IDispatch * disp;
		HRESULT queryRes = apSession->QueryInterface(IID_IDispatch, (void **) &disp);
		if (FAILED(queryRes))
		{
			sprintf (logBuf, "Error: calling QueryInterface(IID_IDispatch)(HRESULT=%lx): %s", 
				queryRes,
				PROCEDURE);
			mLogger.LogThis(LOG_ERROR, logBuf);
			return queryRes;
		}

		var.pdispVal = disp;

		l_dispParams.rgvarg            = &var;
		l_dispParams.rgdispidNamedArgs = NULL;
		l_dispParams.cArgs             = 1;
		l_dispParams.cNamedArgs        = 0;

		HRESULT hr = mpTheConnection->Invoke( DISPID_PROCESSSESSION, 
																					IID_NULL, 
																					0, 
																					DISPATCH_METHOD, 
																					&l_dispParams, 
																					NULL, 
																					&l_exceptions, 
																					&l_error);
		VariantClear(&var);

		if (FAILED(hr))
		{
#if MTDEBUG
			printf("Error Invoke ProcessSession event.\n");
#endif
			sprintf (logBuf, "Error Invoke ProcessSession event(HRESULT=%lx): %s", 
				hr,
				PROCEDURE);
			mLogger.LogThis(LOG_ERROR, logBuf);
		}
		return hr;
	}
	else
	{
#if MTDEBUG
		printf("Error: no connection.\n");
#endif

		sprintf (logBuf, "Error: no connection: %s", PROCEDURE);
		mLogger.LogThis(LOG_ERROR, logBuf);

		return E_FAIL;
	}
}

//**************************************************************************
//
//
//
//**************************************************************************
#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "CMTScriptHost::ProcessSessionSet()"
HRESULT CMTScriptHost::ProcessSessionSet(IMTSessionSetPtr apSessionSet)
{
#if MTDEBUG
	//tracing purposed only
	printf("CMTScriptHost::ProcessSessionSet\n");
#endif
	char logBuf[MAX_BUFFER_SIZE];

	if (mpTheConnection != NULL)
	{
		DISPPARAMS l_dispParams;
		EXCEPINFO l_exceptions;
		UINT l_error = 0;

	  VARIANTARG  var;
		VariantInit(&var);
		var.vt = VT_DISPATCH;

		IDispatch * disp;
		HRESULT queryRes = apSessionSet->QueryInterface(IID_IDispatch, (void **) &disp);
		if (FAILED(queryRes))
		{
			sprintf (logBuf, "Error: calling QueryInterface(IID_IDispatch)(HRESULT=%lx): %s", 
							queryRes,
							PROCEDURE);
			mLogger.LogThis(LOG_ERROR, logBuf);
			return queryRes;
		}

		var.pdispVal = disp;

		l_dispParams.rgvarg            = &var;
		l_dispParams.rgdispidNamedArgs = NULL;
		l_dispParams.cArgs             = 1;
		l_dispParams.cNamedArgs        = 0;

		HRESULT hr = mpTheConnection->Invoke( DISPID_PROCESSSESSIONSET, 
																					IID_NULL, 
																					0, 
																					DISPATCH_METHOD, 
																					&l_dispParams, 
																					NULL, 
																					&l_exceptions, 
																					&l_error);

		VariantClear(&var);

		if (FAILED(hr))
		{
#if MTDEBUG
			printf("Error Invoke ProcessSessionSet event.\n");
#endif
			sprintf (logBuf, "Error Invoke ProcessSessionSet event(HRESULT=%lx): %s",
				hr,
				PROCEDURE);
			mLogger.LogThis(LOG_ERROR, logBuf);
		}
		return hr;
	}
	else
	{
#if MTDEBUG
		printf("Error: no connection.\n");
#endif
		sprintf (logBuf, "Error: no connection: %s", PROCEDURE);
		mLogger.LogThis(LOG_ERROR, logBuf);

		return E_FAIL;
	}
}


//*************************************************************************
//
//	SaySomething() for debug purposes
//
//*************************************************************************
void CMTScriptHost::SaySomething(BSTR bstrSomething)
{
	_bstr_t myBstr(bstrSomething, TRUE);

	//MessageBox(NULL, (char *)myBstr, "Script Message", MB_OK);
	printf("%s\n", myBstr);
}


HRESULT CMTScriptHost::CreateObject(BSTR bstrProgId, LPDISPATCH *pDisp)
{
	CLSID theCLSID;
	HRESULT hr = S_OK;
	char logBuf[MAX_BUFFER_SIZE];

	hr = CLSIDFromProgID(bstrProgId, &theCLSID);

	if(SUCCEEDED(hr))
	{
		hr = CoCreateInstance(theCLSID, 
													0, 
													CLSCTX_INPROC_SERVER, 
													IID_IDispatch, 
													(void **)pDisp);
		if (FAILED(hr))
		{
			sprintf (logBuf, 
							"Error: create object instance(HRESULT=%lx): %s", 
							hr,
							PROCEDURE);
			mLogger.LogThis(LOG_ERROR, logBuf);
		}
	}
	else
	{
		sprintf (logBuf, 
						"Error: calling CLSIDFromProgID(bstrProgId, &theCLSID)(HRESULT=%lx): %s", 
						hr,
						PROCEDURE);
		mLogger.LogThis(LOG_ERROR, logBuf);
	}

	return hr;
}
