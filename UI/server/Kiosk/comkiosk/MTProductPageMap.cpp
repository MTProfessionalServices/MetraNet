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
// MTProductPageMap.cpp : Implementation of CMTProductPageMap
// ---------------------------------------------------------------------------
#include "StdAfx.h"
#include "COMKiosk.h"
#include "MTProductPageMap.h"
#include "MTSiteCollection.h"
#include "MTProductCollection.h"
#include <mtglobal_msg.h>

#include <mtcomerr.h>

#include <ConfigDir.h>

/////////////////////////////////////////////////////////////////////////////
// CMTProductPageMap

// ----------------------------------------------------------------
// Object: MTProductPageMap
// Prog ID: COMKiosk.MTProductPageMap.1
// Description: An object holding the collection of all Site Collection
//              objects.
// Enumeration Element Type: MTSiteCollection
// ----------------------------------------------------------------

STDMETHODIMP CMTProductPageMap::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTProductPageMap
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

// ---------------------------------------------------------------------------
// Description:   This method initializes itself by reading the
//                viewtoaspmapping.xml file that resides under the
//                PresServer configuration directory.  It creates the
//                MTSiteCollection and MTProductCollection objects.
// Errors Raised: "Bad Configuration Set"
//                "Missing Site Set"
//                "Missing Product View Set"
//                "Unable to initialize Product Page Map"
// ---------------------------------------------------------------------------
STDMETHODIMP CMTProductPageMap::Initialize(BSTR aNameSpace)
{
  	HRESULT hr(S_OK);
	const char* procName = "CMTProductPageMap::Initialize";
	mExtensionName = aNameSpace;

  	string buffer;
	VARIANT_BOOL checksumMatch;

	// ------------------------------------------------------------

  	// start the try ...
  	try
  	{
			string aExtensionDir;
			GetExtensionsDir(aExtensionDir);
			_bstr_t aSiteConfigDir = aExtensionDir.c_str();
			aSiteConfigDir += DIR_SEP;
			aSiteConfigDir += (const wchar_t*)mExtensionName;
			aSiteConfigDir += NEW_MPSSITECONFIG_DIR;
			aSiteConfigDir += VIEW_TO_ASP_MAPPING;
	
    	// open the config file ...
    	IMTConfigPtr config (MTPROGID_CONFIG); 
		IMTConfigPropSetPtr aPropSet = 
		  config->ReadConfiguration(aSiteConfigDir, &checksumMatch);

		// check for null confset
		if (aPropSet == NULL)
    	{
		    hr = KIOSK_ERR_BAD_CONFIG_SET; 
			buffer = "Bad Configuration Set";
			mLogger->LogThis (LOG_ERROR, buffer.c_str());
			return Error (buffer.c_str(), IID_IMTProductPageMap, hr);
		}

		// since this is going to be read with configuration information
		// (effective date) information in it, parse through the
		// <mtconfigdata> tag
		IMTConfigPropSetPtr siteset = aPropSet->NextSetWithName("site");

		// check for null set
		if (siteset == NULL)
		{
		    hr = KIOSK_ERR_MISSING_SITE_SET;
			buffer = "Missing Site Set";
			mLogger->LogThis (LOG_ERROR, buffer.c_str());
			return Error (buffer.c_str(), IID_IMTProductPageMap, hr);
		}

		// all set.. process the file now
		while (siteset != NULL)
		{
		    // create the MTSiteCollection object
		    CComObject<CMTSiteCollection>* pMTSiteCollection;
			hr = CComObject<CMTSiteCollection>::CreateInstance(&pMTSiteCollection);
			ASSERT (SUCCEEDED(hr));

		    _bstr_t bstrDefaultProduct = siteset->NextStringWithName("defaultproduct");
			pMTSiteCollection->put_Name(aNameSpace);
			pMTSiteCollection->put_DefaultProduct(bstrDefaultProduct);

			IMTConfigPropSetPtr productviewset = siteset->NextSetWithName("productview");
			
			// check for null set
			if (productviewset == NULL)
			{
			    hr = KIOSK_ERR_MISSING_PRODUCT_SET; 
				buffer = "Missing product view set "; 
				mLogger->LogThis (LOG_ERROR, buffer.c_str());
				return Error (buffer.c_str(), IID_IMTProductPageMap, hr);
			}
			
			while (productviewset != NULL)
			{
			    // ------------------------------------------------------------
			    // create the MTProductCollection object
			    CComObject<CMTProductCollection>* pMTProductCollection;
				hr = CComObject<CMTProductCollection>::CreateInstance(&pMTProductCollection);
				ASSERT (SUCCEEDED(hr));

			    _bstr_t bstrProductName = productviewset->NextStringWithName("name");
		    	_bstr_t bstrProductLink = productviewset->NextStringWithName("link");
				
				pMTProductCollection->put_Name(bstrProductName);
				pMTProductCollection->put_Link(bstrProductLink);

				pMTSiteCollection->Add(pMTProductCollection);

				productviewset = siteset->NextSetWithName("productview");
			}
			Add(pMTSiteCollection);
			siteset = aPropSet->NextSetWithName("site");
		}
	}
  	catch (_com_error e)
  	{
		mLogger->LogThis (LOG_ERROR, 
						 "Error initializing the product collection");
		return Error ("Error initializing the product collection", 
					  IID_IMTProductPageMap, hr);
  	}

	// ----------------------------------------------------------------------
	// we only pay attention to the new view to asp page mapping event
	if (mObserverInitialized == FALSE)
	{
	  if (!mObserver.Init())
	  {
		mLogger->LogThis(LOG_ERROR, "Unable to initialize Observer.") ;
		return Error ("Could not start config change thread", 
					  IID_IMTProductPageMap, hr);
	  }

	  mObserver.AddObserver(*this);

	  if (!mObserver.StartThread())
	  {
		mLogger->LogThis (LOG_ERROR, "Could not start config change thread");
		return Error ("Could not start config change thread", 
					  IID_IMTProductPageMap, hr);
	  }

	  mObserverInitialized = TRUE;
	}
	// ----------------------------------------------------------------------

	return S_OK;
}

STDMETHODIMP CMTProductPageMap::Add(IMTSiteCollection *pMTSiteCollection)
{
    HRESULT hr = S_OK;
	LPDISPATCH lpDisp = NULL;

	hr = pMTSiteCollection->QueryInterface(IID_IDispatch, (void**)&lpDisp);
	if (FAILED(hr))
	{
		return hr;
	}
	
	// create a variant
	CComVariant var;
	var.vt = VT_DISPATCH;
	var.pdispVal = lpDisp;

	// append data
	mSiteCollectionList.push_back(var);
	mSize++;

	return S_OK;
}

STDMETHODIMP CMTProductPageMap::get_Item(long aIndex, VARIANT *pVal)
{
    ASSERT(pVal);
	if (!pVal)
		return E_POINTER;

	VariantInit(pVal);
	pVal->vt = VT_UNKNOWN;
	pVal->punkVal = NULL;

	if ((aIndex < 1) || (aIndex > mSize))
		return E_INVALIDARG;

	VariantCopy(pVal, &mSiteCollectionList[aIndex-1]);

	return S_OK;
}

STDMETHODIMP CMTProductPageMap::get_Count(long *pVal)
{
    if (!pVal)
		return E_POINTER;

	*pVal = mSize;

	return S_OK;
}

STDMETHODIMP CMTProductPageMap::get__NewEnum(LPUNKNOWN *pVal)
{
    HRESULT hr = S_OK;

	typedef CComObject<CComEnum<IEnumVARIANT, 
	  &IID_IEnumVARIANT, VARIANT, _Copy<VARIANT> > > enumvar;

	enumvar* pEnumVar = new enumvar;
	ASSERT (pEnumVar);

	// Note: end pointer has to be one past the end of the list
	if (mSize == 0)
	{
		hr = pEnumVar->Init(NULL,
							NULL, 
							NULL, 
							AtlFlagCopy);
	}
	else
	{
	    hr = pEnumVar->Init(&mSiteCollectionList[0], 
							&mSiteCollectionList[mSize - 1] + 1, 
							NULL, 
							AtlFlagCopy);
	}

	if (SUCCEEDED(hr))
		hr = pEnumVar->QueryInterface(IID_IEnumVARIANT, reinterpret_cast<void**>(pVal));

	if (FAILED(hr))
		delete pEnumVar;

	return hr;
}

// ----------------------------------------------------------------
// Name:     	ConfigurationHasChanged
// Arguments:     
// Return Value:  void
// Errors Raised: 
// Description:   INTERNAL USE ONLY
// ----------------------------------------------------------------

//Got refresh event, reinitialize
void CMTProductPageMap::ConfigurationHasChanged()
{
    HRESULT hr = S_OK;

	mLogger->LogThis(LOG_DEBUG, "Refresh event received, reinitializing...");
	hr = Initialize(mExtensionName);
}
