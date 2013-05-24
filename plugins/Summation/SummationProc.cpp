/**************************************************************************
 * @doc
 *
 * Copyright 1997-2000 by MetraTech Corporation
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
 *
 * Created by: Chen He
 *
 * $Header$
 ***************************************************************************/
// SummationProc.cpp : Implementation of CSummationProc
#include "StdAfx.h"
#include "Summation.h"
#include "SummationProc.h"

#include "metra.h"

#include <SetIterate.h>
#include <mtcomerr.h>

using namespace MTPipelineLib;

/////////////////////////////////////////////////////////////////////////////
// CSummationProc

STDMETHODIMP CSummationProc::InterfaceSupportsErrorInfo(REFIID riid)
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


////////////////////////////////////////////////////////////////////////////
// --------------------------------------------------------------------------
// Arguments: none
//
// Return Value: none
// Errors Raised: none
// Description: destruction - clean up the collection list
// --------------------------------------------------------------------------
CSummationProc::~CSummationProc()
{
}


////////////////////////////////////////////////////////////////////////////
// --------------------------------------------------------------------------
// Arguments: <systemContext> - idLookup object and MTLog object
//						<apPropSet> - propSet configuration file
//
// Return Value: S_OK - successfully, HRESULT - if error
// Errors Raised: none
// Description: plug-in configuration
// --------------------------------------------------------------------------
STDMETHODIMP CSummationProc::Configure(IUnknown * systemContext,
																			::IMTConfigPropSet * apPropSet)
{
	char		errStr[MAX_LOG_STRING];
	_bstr_t	propName;

	if (mInitialized == TRUE)
	{
		if (mSumItemCollection.size() > 0)
		{
			mSumItemCollection.clear();
		}
	}
	else
	{
		mInitialized = TRUE;
	}

	try
	{
		
		IMTNameIDPtr idlookup(systemContext);
		mPropIDSession = idlookup->GetNameID(_bstr_t(SESSION_ID));

		// read in configuration
		IMTConfigPropSetPtr propSet(apPropSet);

		propName = propSet->NextStringWithName(COUNTER_PROP_NAME);
		mCounterPropID = idlookup->GetNameID(propName);

		///////////////////////////////////////////////////////////////////
		// load configuration data
		IMTConfigPropSetPtr item;
		while((item = propSet->NextSetWithName(SUMMATION_ITEM)) != NULL)
		{
			SumItem sumItem;
      
      sumItem.SumItemConfig(idlookup, item);

			mSumItemCollection.push_back(sumItem);
		}

		///////////////////////////////////////////////////////////////////
	}
	catch(ErrorObject aLocalError)
	{
		sprintf(errStr, "Error: %s, %s(%d) %s(%d)", 
						aLocalError.GetModuleName(),
						aLocalError.GetFunctionName(),
						aLocalError.GetLineNumber(),
						aLocalError.GetProgrammerDetail().c_str(),
						aLocalError.GetCode());

		return Error(errStr);
	}
	catch (HRESULT hr)
	{
		return hr;
	}
	catch (_com_error err)
	{
		return err.Error();
	}

	return S_OK;
}


///////////////////////////////////////////////////////////////////////////////
// --------------------------------------------------------------------------
// Arguments: none
//
// Return Value: none
// Errors Raised: none
// Description: plug-in shutdown - clean up the collection list
// --------------------------------------------------------------------------
STDMETHODIMP CSummationProc::Shutdown()
{
	// clean up the memory allocation
	if (mInitialized == TRUE)
	{
		if (mSumItemCollection.size() > 0)
		{
			mSumItemCollection.clear();
		}

		mInitialized = FALSE;
	}

	return S_OK;
}


_COM_SMARTPTR_TYPEDEF(IEnumVARIANT, __uuidof(IEnumVARIANT));


///////////////////////////////////////////////////////////////////////////////
// --------------------------------------------------------------------------
// Arguments: <apSessionSet> - session object
//
// Return Value: none
// Errors Raised: none
// Description: process session set
// --------------------------------------------------------------------------
STDMETHODIMP CSummationProc::ProcessSessions(::IMTSessionSet * apSessionSet)
{

	char	errStr[MAX_LOG_STRING];

	try
	{
	  int itemCount = mSumItemCollection.size();
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
			IMTSessionSetPtr children = session->SessionChildren();

			//////////////////////////////////////////////////
			//Loop through each sumItem
			for (int entries = 0; entries < itemCount; entries++)
			{
				SumItem& sumItem = mSumItemCollection[entries];
				sumItem.SumItemProc(session, children);
			}

			// count total number of children
			session->SetLongProperty(mCounterPropID, children->GetCount());
		}
	}
	catch (HRESULT hr)
	{
		return hr;
		//	cout << "Error! " << hex << hr << dec << endl;
	}
	catch(ErrorObject aLocalError)
	{
		sprintf(errStr, "Error: %s, %s(%d) %s(%d)", 
						aLocalError.GetModuleName(),
						aLocalError.GetFunctionName(),
						aLocalError.GetLineNumber(),
						aLocalError.GetProgrammerDetail().c_str(),
						aLocalError.GetCode());

		return Error(errStr);
	}
	catch (_com_error err)
	{
		return ReturnComError(err);
		//cout << "Bigger error" << hex << err.Error() << dec << endl;
	}
#ifndef DEBUG
	catch (...)
	{
		return E_FAIL;
		//cout << "everything else" << endl;
	}
#endif

	return S_OK;
}
 

///////////////////////////////////////////////////////////////////////////////    
STDMETHODIMP CSummationProc::get_ProcessorInfo(/* [out] */ long * info)
{
	return E_NOTIMPL;
}

