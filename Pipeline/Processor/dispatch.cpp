/**************************************************************************
 * @doc DISPATCH
 *
 * Copyright 2000 by MetraTech Corporation
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
 * Created by: Derek Young
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#include <metra.h>
#include <mtcom.h>

/*
 * imports
 */

#import "MTPipelineLib.tlb" rename ("EOF", "RowsetEOF") no_function_mapping
#import "MTConfigLib.tlb"

#include <processor.h>

/******************************** DispatchProcessorInterface ***/

// TODO: store name ID for Initialize and ProcessSessions ahead of time!

DispatchProcessorInterface::DispatchProcessorInterface(IDispatchPtr aInterface)
	: mInterface(aInterface)
{ }

BOOL
DispatchProcessorInterface::Initialize(MTPipelineLib::IMTSystemContextPtr aSystemContext,
																			 PropSet aConfigData)
{
	const char * functionName = "DispatchProcessorInterface::Initialize";

	OLECHAR * pArrayUserConfigNames[] = { L"Configure" };
	DISPID dispid;

	//	Do the GetIDsOfNames here
	//	It takes 5 parameters:
	//	1)	Reserved for future use.  Must be IID_NULL
	//	2)	Passed-in array of names to be mapped
	//	3)	Count of the names to be mapped
	//	4)	The locale context in which to interpret the names
	//	5)	Caller-allocated array, each element of which contains an ID
	//		corresponding to one of the names passed in.
	HRESULT hr = mInterface->GetIDsOfNames(IID_NULL,
																				 pArrayUserConfigNames,
																				 1,
																				 LOCALE_USER_DEFAULT,
																				 &dispid);
	if (FAILED(hr))
	{
		SetError(hr, ERROR_MODULE, ERROR_LINE, functionName,
						 "Could not get ID of name for configure call");
		return FALSE;
	}

	// intitialize the arguments ...
	DISPPARAMS params;
	params.cArgs = 2;
	params.cNamedArgs = 0;

	VARIANTARG variantArgs[2];

	params.rgvarg = variantArgs;


	params.rgvarg[1].vt = VT_DISPATCH;

	hr = aSystemContext.QueryInterface(IID_IDispatch,
																		 (void**) &params.rgvarg[1].pdispVal);
	if (FAILED(hr))
	{
		SetError(hr, ERROR_MODULE, ERROR_LINE, functionName,
						 "Could not query IDispatch interface of system context");
		return FALSE;
	}

	params.rgvarg[0].vt = VT_DISPATCH;
	hr = aConfigData.QueryInterface(IID_IDispatch, (void**) &params.rgvarg[0].pdispVal);
	if (FAILED(hr))
	{
		SetError(hr, ERROR_MODULE, ERROR_LINE, functionName,
						 "Could not query IDispatch interface of configuration data");
		return FALSE;
	}

	//	1)	Identifies the dispatch ID
	//	2)	Reference ID, must be IID_NULL.  Reserved for
	//	3)	The locale context in which to interpret the names
	//	4)	Flag to denote property or a method. In this case, 
	//		DISPATCH_METHOD
	//	5)	Pointer to a structure containing an array of arguments
	//	6)	Pointer to location where the result is to be stored
	//	7)	Pointer to a structure that contains exception information
	//	8)	Error code coming back	
	VARIANT	 varRetValUserConfig;
	UINT	 nArgErrIndexUserConfig;
	EXCEPINFO exception;
	hr = mInterface->Invoke(dispid,
													IID_NULL, // reserved
													LOCALE_USER_DEFAULT,
													DISPATCH_METHOD,
													&params,
													&varRetValUserConfig,
													&exception,
													&nArgErrIndexUserConfig);

	// free interface pointers
	ASSERT(params.rgvarg[0].pdispVal);
	::VariantClear(&params.rgvarg[0]);

	ASSERT(params.rgvarg[1].pdispVal);
	::VariantClear(&params.rgvarg[1]);

	// TODO: exception has data members that need to be cleared or it will leak.
	if (FAILED(hr))
	{
		_bstr_t desc(exception.bstrDescription);

		const char * descPtr = desc;
		if (!descPtr || !*descPtr)
			descPtr = "Invoke failed";

		SetError(hr, ERROR_MODULE, ERROR_LINE, functionName, descPtr);
		return FALSE;
	}

	// NOTE: any other errors throw _com_error objects
	return TRUE;
}

BOOL DispatchProcessorInterface::Shutdown()
{ 
	const char * functionName = "DispatchProcessorInterface::Shutdown";

	OLECHAR * pArrayUserConfigNames[] = { L"Shutdown" };
	DISPID dispid;

	//	Do the GetIDsOfNames here
	//	It takes 5 parameters:
	//	1)	Reserved for future use.  Must be IID_NULL
	//	2)	Passed-in array of names to be mapped
	//	3)	Count of the names to be mapped
	//	4)	The locale context in which to interpret the names
	//	5)	Caller-allocated array, each element of which contains an ID
	//		corresponding to one of the names passed in.

	HRESULT hr = mInterface->GetIDsOfNames(IID_NULL,
																				 pArrayUserConfigNames,
																				 1,
																				 LOCALE_USER_DEFAULT,
																				 &dispid);
	if (FAILED(hr))
	{
		SetError(hr, ERROR_MODULE, ERROR_LINE, functionName,
						 "Could not get ID of name for shutdown call");
		return FALSE;
	}


	// intitialize the arguments ...
	DISPPARAMS params;
	params.cArgs = 0;
	params.cNamedArgs = 0;

	params.rgvarg = NULL;


	//	1)	Identifies the dispatch ID
	//	2)	Reference ID, must be IID_NULL.  Reserved for
	//	3)	The locale context in which to interpret the names
	//	4)	Flag to denote property or a method. In this case, 
	//		DISPATCH_METHOD
	//	5)	Pointer to a structure containing an array of arguments
	//	6)	Pointer to location where the result is to be stored
	//	7)	Pointer to a structure that contains exception information
	//	8)	Error code coming back	
	VARIANT	 varRetValUserConfig;
	UINT	 nArgErrIndexUserConfig;
	EXCEPINFO exception;
	hr = mInterface->Invoke(dispid,
													IID_NULL, // reserved
													LOCALE_USER_DEFAULT,
													DISPATCH_METHOD,
													&params,
													&varRetValUserConfig,
													&exception,
													&nArgErrIndexUserConfig);
	// TODO: exception has data members that need to be cleared or it will leak.
	if (FAILED(hr))
	{
		_bstr_t desc(exception.bstrDescription);

		const char * descPtr = desc;
		if (!descPtr || !*descPtr)
			descPtr = "Invoke failed";

		SetError(hr, ERROR_MODULE, ERROR_LINE, functionName, descPtr);
		return FALSE;
	}

	// NOTE: other errors throw _com_error
	return TRUE;
}


BOOL DispatchProcessorInterface::ProcessSessions(MTPipelineLib::IMTSessionSetPtr aSet)
{
	const char * functionName = "DispatchProcessorInterface::ProcessSessions";

	OLECHAR * pArrayUserConfigNames[] = { L"ProcessSessions" };
	DISPID dispid;

	//	Do the GetIDsOfNames here
	//	It takes 5 parameters:
	//	1)	Reserved for future use.  Must be IID_NULL
	//	2)	Passed-in array of names to be mapped
	//	3)	Count of the names to be mapped
	//	4)	The locale context in which to interpret the names
	//	5)	Caller-allocated array, each element of which contains an ID
	//		corresponding to one of the names passed in.

	HRESULT hr = mInterface->GetIDsOfNames(IID_NULL,
																				 pArrayUserConfigNames,
																				 1,
																				 LOCALE_USER_DEFAULT,
																				 &dispid);
	if (FAILED(hr))
	{
		SetError(hr, ERROR_MODULE, ERROR_LINE, functionName,
						 "Could not get ID of name for ProcessSessions call");
		return FALSE;
	}


	// intitialize the arguments ...
	DISPPARAMS params;
	params.cArgs = 1;
	params.cNamedArgs = 0;

	VARIANTARG variantArgs[1];

	params.rgvarg = variantArgs;

	params.rgvarg[0].vt = VT_DISPATCH;
	hr = aSet.QueryInterface(IID_IDispatch,
													 (void**) &params.rgvarg[0].pdispVal);
	if (FAILED(hr))
	{
		SetError(hr, ERROR_MODULE, ERROR_LINE, functionName,
						 "Query interface on set failed");
		return FALSE;
	}

	//	1)	Identifies the dispatch ID
	//	2)	Reference ID, must be IID_NULL.  Reserved for
	//	3)	The locale context in which to interpret the names
	//	4)	Flag to denote property or a method. In this case, 
	//		DISPATCH_METHOD
	//	5)	Pointer to a structure containing an array of arguments
	//	6)	Pointer to location where the result is to be stored
	//	7)	Pointer to a structure that contains exception information
	//	8)	Error code coming back	
	VARIANT	 varRetValUserConfig;
	UINT	 nArgErrIndexUserConfig;
	EXCEPINFO exception;
	hr = mInterface->Invoke(dispid,
													IID_NULL, // reserved
													LOCALE_USER_DEFAULT,
													DISPATCH_METHOD,
													&params,
													&varRetValUserConfig,
													&exception,
													&nArgErrIndexUserConfig);

	// free interface pointers
	ASSERT(params.rgvarg[0].pdispVal);
	::VariantClear(&params.rgvarg[0]);

	// TODO: exception has data members that need to be cleared or it will leak.
	if (FAILED(hr))
	{
		_bstr_t desc(exception.bstrDescription);

		const char * descPtr = desc;
		if (!descPtr || !*descPtr)
			descPtr = "Invoke failed";

		SetError(hr, ERROR_MODULE, ERROR_LINE, functionName, descPtr);
		return FALSE;
	}

	// NOTE: other errors throw _com_error
	return TRUE;
}

