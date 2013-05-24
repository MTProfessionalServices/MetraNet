/**************************************************************************
 * @doc
 * 
 * Copyright 1998 by MetraTech
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
 * 	KioskGate.cpp : 
 *	------------------
 *	This is the implementation of the KioskGate class.
 *	This class expands on the functionality provided by the class 
 *	CCOMKioskGate by providing functionality to get web URL of the
 *  the provider
 ***************************************************************************/


// All the includes
// Local includes
#include <StdAfx.h>
#include <metra.h>
#include <comdef.h>
#include <KioskGate.h>
#include <loggerconfig.h>
#include <mtprogids.h>
#include <mtcomerr.h>
#include <ConfigDir.h>
#include <stdutils.h>

// import the config loader ...
#import <MTCLoader.tlb>
using namespace CONFIGLOADERLib;

// @mfunc CKioskGate default constructor
// @parm 
// @rdesc This implementations is for the default constructor of the 
// Core Kiosk Gate class
DLL_EXPORT 
CKioskGate::CKioskGate() :
    mWebURL(W_NULL_STR)
{
}


// @mfunc CKioskGate copy constructor
// @parm CKioskGate& 
// @rdesc This implementations is for the copy constructor of the 
// Core Kiosk Gate class
DLL_EXPORT 
CKioskGate::CKioskGate(const CKioskGate &c) 
{
	*this = c;
}

// @mfunc CKioskGate assignment operator
// @parm 
// @rdesc This implementations is for the assignment operator of the 
// Core Kiosk Gate class
DLL_EXPORT const CKioskGate&
CKioskGate::operator=(const CKioskGate& rhs)
{
	// set the member attributes here
	mWebURL = rhs.mWebURL;

 	return ( *this );
}


// @mfunc CKioskGate destructor
// @parm 
// @rdesc This implementations is for the destructor of the 
// Core Kiosk Gate class
DLL_EXPORT 
CKioskGate::~CKioskGate()
{
}

// @mfunc Initialize
// @parm value 
// @rdesc This function is responsible for getting the corresponding values 
// for the input parameters from the xml vconfiguration file.
// Returns true or false depending on whether the function succeeded
// or not.  
DLL_EXPORT BOOL
CKioskGate::Initialize(const wstring &arProvider)
{
  BOOL bFound=FALSE ;
  _bstr_t name ;
  _bstr_t webURL ;
  _bstr_t providerName ;
  const char* procName = "CKioskGate::Initialize";
  
  // assert for null value
  ASSERT(arProvider.c_str()!= NULL);
  
  // start the try ...
  try
  {
    // initialize the _com_ptr_t ...
    CONFIGLOADERLib::IMTConfigLoaderPtr configLoader(MTPROGID_CONFIGLOADER);

		
		string aExtensionDir;
		GetExtensionsDir(aExtensionDir);
		_bstr_t aGateWaydir = aExtensionDir.c_str();
		aGateWaydir += DIR_SEP;
		aGateWaydir += arProvider.c_str();
		aGateWaydir += NEW_MPSSITECONFIG_DIR;
    
    // initialize the configLoader ...
    configLoader->InitWithPath(aGateWaydir) ;
    
    // open the config file ...
    CONFIGLOADERLib::IMTConfigPropSetPtr confSet = 
      configLoader->GetEffectiveFile("", GATEWAY_CONFIG);

	// check for the null existence of the object
	if (confSet == NULL)
	{
	  mLogger->LogVarArgs (LOG_ERROR, 
						  "Unable to create configuration set for provider <%s>", 
						  _bstr_t(arProvider.c_str()));
	  mLogger->LogThis (LOG_ERROR, "GetEffectiveFile on gateway.xml file failed");
	  mLogger->LogThis (LOG_ERROR, "Could be because the effective date is ahead of the current GMT time");
	  return (FALSE);
	}
	
    // get the config data ...
    CONFIGLOADERLib::IMTConfigPropSetPtr subset ;
    while (((subset = confSet->NextSetWithName("site")) != NULL) && (bFound == FALSE))
    {
      name = subset->NextStringWithName("name");
      webURL = subset->NextStringWithName("WebURL");
      providerName = subset->NextStringWithName("provider_name");

      // check to see if we read have the info for the appropriate provider ...
      if (mtwcscasecmp(arProvider.c_str(), providerName) == 0)
      {
        bFound = TRUE ;
        mWebURL = (wchar_t *) webURL ;
		break;
      }
    }
  }
  catch (_com_error & e)
  {
    //SetError(e) ;
		ErrorObject * err = CreateErrorFromComError(e);
		SetError(err);
		delete err;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    return (FALSE) ;
  }

  if (bFound == FALSE)
  {
	  _bstr_t bstrProviderName(arProvider.c_str());
    mLogger->LogVarArgs(LOG_ERROR, "Provider name <%s> not found in configuration file", 
					   (const char*)bstrProviderName);
    return (FALSE) ;
  }

  return (TRUE) ;
}

