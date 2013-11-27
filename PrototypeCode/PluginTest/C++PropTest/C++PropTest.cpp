/**************************************************************************
 * @doc C++PerfProp.cpp
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
 * Created by: Boris Boruchovich
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#include <PlugInSkeleton.h>

// import the type library of the plug in interfaces
// so we can use generated smart pointers
#import "MTPipelineLib.tlb" rename ("EOF", "RowsetEOF")

// generate using uuidgen
CLSID CLSID_CPPPropTestPlugIn = { /* 58709784-8AC2-4839-AE90-794179C59BEA */
	0x58709784,
	0x8ac2, 0x4839,
	{0xae, 0x90, 0x79, 0x41, 0x79, 0xc5, 0x9b, 0xea}
};

class ATL_NO_VTABLE MTCPPPropTestPlugIn
	: public MTPipelinePlugIn<MTCPPPropTestPlugIn, &CLSID_CPPPropTestPlugIn>
{
	protected:
		// Initialize the processor, looking up any necessary property IDs.
		// The processor can also use this time to do any other necessary initialization.
		// NOTE: This method can be called any number of times in order to
		//  refresh the initialization of the processor.
		virtual HRESULT PlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
										MTPipelineLib::IMTConfigPropSetPtr aPropSet,
										MTPipelineLib::IMTNameIDPtr aNameID,
										MTPipelineLib::IMTSystemContextPtr aSysContext);

		// Shutdown the processor.  The processor can release any resources
		// it no longer needs.
		virtual HRESULT PlugInShutdown();

		virtual HRESULT PlugInProcessSessions(MTPipelineLib::IMTSessionSetPtr aSet);

		virtual HRESULT PlugInProcessSession(MTPipelineLib::IMTSessionPtr aSession);

	private:

		// Interface to the logging system
		MTPipelineLib::IMTLogPtr mLogger;

		// Property ID's
		long mlBoolProp;
		long mlIntProp;
		long mlStringProp;
		long mlDecimalProp;
		long mlDoubleProp;

		// Totals for each property
		long mlBoolTotal;
		long mlIntTotal;
		long mlStringTotal;
		double mlDecimalTotal;
		double mlDoubleTotal;
};

PLUGIN_INFO(CLSID_CPPPropTestPlugIn, MTCPPPropTestPlugIn,
			"MetraPipeline.CPPPropTest.1", "MetraPipeline.CPPPropTest", "Free")

HRESULT MTCPPPropTestPlugIn::PlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
											 MTPipelineLib::IMTConfigPropSetPtr aPropSet,
											 MTPipelineLib::IMTNameIDPtr aNameID,
											 MTPipelineLib::IMTSystemContextPtr aSysContext)
{
	HRESULT hr = S_OK;

	try
	{
		// Store a pointer to the logger object
		mLogger = aLogger;


//		mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG,
//						   "MTCPPPropTestPlugIn::PlugInConfigure: entered\n");

		// Initialize totals.
		mlBoolTotal = 0;
		mlIntTotal = 0;
		mlStringTotal = 0;
		mlDecimalTotal = 0;
		mlDoubleTotal = 0;

		// Get property ID's
		mlBoolProp = aNameID->GetNameID("boolVal");
		mlIntProp = aNameID->GetNameID("intVal");
		mlStringProp = aNameID->GetNameID("strVal");
		mlDecimalProp = aNameID->GetNameID("decValue");
		mlDoubleProp = aNameID->GetNameID("dVal");
	}
	catch (_com_error err)
	{
		hr = err.Error();
	}

	return hr;
}

HRESULT MTCPPPropTestPlugIn::PlugInProcessSessions(MTPipelineLib::IMTSessionSetPtr aSet)
{
	SetIterator<MTPipelineLib::IMTSessionSetPtr, MTPipelineLib::IMTSessionPtr> it;
	HRESULT hr = it.Init(aSet);
	if (FAILED(hr))
	return hr;

	HRESULT errHr = S_OK;
	while (TRUE)
	{
		MTPipelineLib::IMTSessionPtr session = it.GetNext();
		if (session == NULL)
			break;

		try
		{
			hr = PlugInProcessSession(session);
			if (FAILED(hr))
			{
				HRESULT errHr = hr;
				IErrorInfo * errInfo;
				hr = GetErrorInfo(0, &errInfo);
				if (FAILED(hr))
					throw _com_error(errHr);

				throw _com_error(errHr, errInfo);
			}
		}
		catch (_com_error & err)
		{
			_bstr_t message = err.Description();
			errHr = err.Error();
			session->MarkAsFailed(message.length() > 0 ? message : L"", errHr);
		}
	}
	if (FAILED(errHr))
		return PIPE_ERR_SUBSET_OF_BATCH_FAILED;

//	char szOutput[512];
//	sprintf(szOutput, "BoolTotal=%d; IntTotal=%d; StringTotal=%d; DecimalTotal=%g; DoubleTotal=%g",
//		    mlBoolTotal, mlIntTotal, mlStringTotal, mlDecimalTotal, mlDoubleTotal);

	// Log totals for all the properties
//	mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, szOutput);

	return S_OK;
}

HRESULT MTCPPPropTestPlugIn::PlugInProcessSession(MTPipelineLib::IMTSessionPtr aSession)
{
	HRESULT hr = S_OK;

	try
	{
		mlBoolTotal += (aSession->GetBoolProperty(mlBoolProp) == VARIANT_TRUE ? 1 : 0);
		mlIntTotal += aSession->GetLongProperty(mlIntProp);

		std::string strValue = aSession->GetStringProperty(mlStringProp);
		mlStringTotal += strValue[0];
		mlDecimalTotal += (double) aSession->GetDecimalProperty(mlDecimalProp);
		mlDoubleTotal += aSession->GetDoubleProperty(mlDoubleProp);
	}
	catch (_com_error err)
	{
		hr = err.Error();
	}

	return hr;
}

HRESULT MTCPPPropTestPlugIn::PlugInShutdown()
{
	return S_OK;
}

//-- EOF --