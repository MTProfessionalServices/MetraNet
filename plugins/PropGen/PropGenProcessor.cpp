/**************************************************************************
 * @doc PropGenProcessor
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
// PropGenProcessor.cpp : Implementation of CPropGenProcessor
#include "StdAfx.h"
#import <MTPipelineLib.tlb> rename ("EOF", "RowsetEOF") no_function_mapping
#include <MTSessionBaseDef.h>
#include "PropGen.h"
#include "PropGenProcessor.h"


using namespace MTPipelineLib;

#include "metra.h"

#include <SetIterate.h>
#include <mtcomerr.h>

/////////////////////////////////////////////////////////////////////////////
// CPropGenProcessor

STDMETHODIMP CPropGenProcessor::InterfaceSupportsErrorInfo(REFIID riid)
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


// --------------------------------------------------------------------------
// Arguments: <systemContext> - contains IMTNameID object and IMTLog object
//						<apPropSet> - PropSet contains rule set
//
// Return Value: S_OK - successfully, or HRESULT if it is error
// Errors Raised: none
// Description: load rule set configuration file
// --------------------------------------------------------------------------
STDMETHODIMP CPropGenProcessor::Configure(IUnknown * systemContext,
																					::IMTConfigPropSet * apPropSet)
{
	char	errStr[MAX_LOG_STRING];

	try
	{
		IMTNameIDPtr idlookup(systemContext);
		mPropIDSession = idlookup->GetNameID(_bstr_t("SessionID"));

		// make sure that we clean up the memory
		if (mpPropGenerator)
		{
			delete mpPropGenerator;
			mpPropGenerator = NULL;
		}

		// application initialization
		mpPropGenerator = new PropGenerator();

		if (mpPropGenerator == NULL)
		{
			sprintf(errStr, 
						"Error: Can not allocate PropGenerator object - %d", 
						::GetLastError());
			return Error(errStr);
		}

		// load the configuration data
		mpPropGenerator->Configure(systemContext, apPropSet);
	}
	catch(ErrorObject aLocalError)
	{
		IMTLogPtr IMTLogPtr = systemContext;
		
		sprintf(errStr, "Error in loading configuration data: %s.", 
						aLocalError.GetProgrammerDetail().c_str());
		IMTLogPtr->LogString(PLUGIN_LOG_ERROR, errStr);

		sprintf(errStr, "Error: %s, %s(%d) %s(error code: %X)", 
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


// --------------------------------------------------------------------------
// Arguments: <systemContext> - contains IMTNameID object and IMTLog object
//						<apPropSet> - PropSet contains rule set
//
// Return Value: S_OK - successfully, or HRESULT if it is error
// Errors Raised: none
// Description: load rule set configuration file
// --------------------------------------------------------------------------
STDMETHODIMP CPropGenProcessor::Shutdown()
{
	// clean up the memory allocation
	if (mpPropGenerator)
	{
		delete mpPropGenerator;
		mpPropGenerator = NULL;
	}

	return S_OK;
}

_COM_SMARTPTR_TYPEDEF(IEnumVARIANT, __uuidof(IEnumVARIANT));


// --------------------------------------------------------------------------
// Arguments: <apSessionSet> - session object contains session info
//
// Return Value: S_OK - successfully, or HRESULT if it is error
// Errors Raised: none
// Description: process session object
// --------------------------------------------------------------------------
STDMETHODIMP CPropGenProcessor::ProcessSessions(::IMTSessionSet * apSessionSet)
{
	char	errStr[MAX_LOG_STRING];

	try
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

			try
			{
				//--------- we have the session here ---------------------
				mpPropGenerator->ProcessSession(session);
			}
			catch(ErrorObject aLocalError)
			{
				sprintf(errStr, "Error: %s, %s(%d) %s(error code: %X)", 
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
				return ReturnComError(err);	
			}
		}
	}
	catch (HRESULT hr)
	{
		return hr;
		//	cout << "Error! " << hex << hr << dec << endl;
	}
	catch (_com_error err)
	{
		return err.Error();
		//cout << "Bigger error" << hex << err.Error() << dec << endl;
	}

	return S_OK;
}
     
STDMETHODIMP CPropGenProcessor::get_ProcessorInfo(/* [out] */ long * info)
{

	return E_NOTIMPL;
}
