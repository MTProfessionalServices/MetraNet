/**************************************************************************
* Copyright 1997-2000 by MetraTech
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
* Created by: Raju Matta 
* $Header$
* 
***************************************************************************/
// ---------------------------------------------------------------------------
// COMKioskGate.cpp : Implementation of CCOMKioskGate.  
// gateway.asp redirects to \mt\default.asp (which triggers global.asa 
// OnSessionStart)...redirect to main.asp which sets up the rest of the 
// subscriber's session values...this redirects to the SiteStartPage which 
// in the case of our default site is start.asp (which sets up the HTML frame 
// and nothing else).
// ---------------------------------------------------------------------------
#include "StdAfx.h"
#include "COMKiosk.h"
#include "COMKioskGate.h"
#include <mtglobal_msg.h>
#include <multiinstance.h>
#include <makeunique.h>
#include <ConfigDir.h>

#include <loggerconfig.h>

// ---------------------------------------------------------------------------
// Description : This is the default constructor for this object
// ---------------------------------------------------------------------------
CCOMKioskGate::CCOMKioskGate()
{	
  mIsInitialized = FALSE;
}

// ---------------------------------------------------------------------------
// Description : This is the default destructor for this object
// ---------------------------------------------------------------------------
CCOMKioskGate::~CCOMKioskGate() 
{
  // uninitialize the instance
  mIsInitialized = FALSE;
}

STDMETHODIMP CCOMKioskGate::InterfaceSupportsErrorInfo(REFIID riid)
{
  static const IID* arr[] = 
  {
    &IID_ICOMKioskGate,
  };
  for (int i=0;i<sizeof(arr)/sizeof(arr[0]);i++)
  {
    if (InlineIsEqualGUID(*arr[i],riid))
      return S_OK;
  }
  return S_FALSE;
}

// ---------------------------------------------------------------------------
// Description : Get the URL property
// ---------------------------------------------------------------------------
STDMETHODIMP CCOMKioskGate::get_URL(BSTR * pVal)
{
  HRESULT hOK = S_OK;
  string buffer;
  
  // check for mIsInitialized flag or the existence of the pointer
  if (mIsInitialized == TRUE)
  {
    *pVal = SysAllocString(mKioskGate.GetWebURL().c_str());
  }
  else
  {
    hOK = KIOSK_ERR_NOT_INITIALIZED;
	buffer = "Unable to get URL. Gate object not initialized";
    mLogger->LogThis (LOG_ERROR, buffer.c_str());
    return Error (buffer.c_str(), IID_ICOMKioskGate, hOK) ;
  }
  
  return (hOK);  
}

// ---------------------------------------------------------------------------
// Description:	This method initializes the underlying C++ kiosk gate object
// Errors Raised: 0xE140002F - KIOSK_GATE_INITIALIZATION_FAILED 
// ---------------------------------------------------------------------------
STDMETHODIMP CCOMKioskGate::Initialize(BSTR providerName, int port)
{

    // local variables ...
    HRESULT hOK = S_OK;  
  	BOOL bRetCode = TRUE;
  	string buffer;

	if (IsMultiInstance())
	{
		// the mapping between port and unique login name is stored in the registry.
		PortMappings mappings;
		if (!ReadPortMappings(mappings))
			// TODO: log to event log
			return E_FAIL;

		string name = mappings[port];
		if (name.length() == 0)
			// no mapping found
			// TODO: log to event lgo
			return Error("Unable to initialize comkioskgate");

			// set the prefix used to make global names unique.
		string appName = name.c_str();

		SetUniquePrefix(appName.c_str());
		SetNameSpace(appName);
	}

  
  	// initialize the Kiosk Gate server ...
  	if (!mKioskGate.Initialize (providerName))
  	{
    	mIsInitialized = FALSE;
    	hOK = KIOSK_GATE_INITIALIZATION_FAILED;
    	buffer = "Unable to initialize Gate object";
    	mLogger->LogThis (LOG_ERROR, buffer.c_str());
    	return Error (buffer.c_str(), IID_ICOMKioskGate, hOK) ;
  	}
  	else
  	{
    	// initialize the IsInitialized flag
    	mIsInitialized = TRUE;
  	}
  
  	return (hOK);
}
